USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Generate_Request_Data_Recipient_List') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Generate_Request_Data_Recipient_List
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[Patient_Data_Imports_Generate_Request_Data_Recipient_List] (
   @cronTabSelectionID bigint
)    

returns @messages table (
    [appName]              varchar(50) default('spedcare')
  , [senderUserID]         bigint
  , [recipientUserIDsStr]  varchar(max)
  , [subject]              varchar(256)
  , [body]                 varchar(max)
  , [sendEmail]            bit default(1)
  , [promptUserToGotoURL]  bit default(0)
  , [gotoURL]              varchar(256)
) 
as
begin

/***************************************************************************    
 * Patient_Data_Imports_Generate_Request_Data_Recipient_List */    
/**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         

declare @contacts as table (
    [clientID]              bigint
  , [totPopIsExpected]      bit
  , [spedIsExpected]        bit
  , [sendRequestsForTotPop] bit
  , [sendRequestsForSpEd]   bit
  , [contactName]           varchar(256)
  , [contactEmail]          varchar(256)
  , [contactUserID]         bigint
) 

declare @senderUserIDTotPop            as bigint = 0
declare @senderUserIDSpEd              as bigint = 0
declare @subjectTemplateTotPop         as varchar(256)
declare @bodyTemplateTotPop            as varchar(max)
declare @subjectTemplateSpEd           as varchar(256)
declare @bodyTemplateSpEd              as varchar(max)
declare @uploadReminderEnabledTotalPop as bit = 0
declare @uploadReminderEnabledSpEd     as bit = 0

/* Get system wide on/off flag for total pop reminders */

set @uploadReminderEnabledTotalPop = convert(bit,users.dbo.APP_SETTING_GET_VALUE ('spedcare','patientdata','totalpop','notification','reminder','upload-reminder-enabled'))

/* Get system wide on/off flag for sped reminders */

set @uploadReminderEnabledSpEd = convert(bit,users.dbo.APP_SETTING_GET_VALUE ('spedcare','patientdata','sped','notification','reminder','upload-reminder-enabled'))

select top 1 
  @subjectTemplateTotPop = emt.subjectTemplate
, @bodyTemplateTotPop    = emt.bodyTemplate
, @senderUserIDTotPop    = emt.defaultSenderUserID
from users.dbo.EMAIL_AND_MESSAGE_TEMPLATES as emt
where (
      (emt.appName     = 'spedcare')
  and (emt.[namespace] = 'patientdata')
  and (emt.[class]     = 'totalpop')
  and (emt.active = 1)
)

select top 1 
  @subjectTemplateSpEd = emt.subjectTemplate
, @bodyTemplateSpEd    = emt.bodyTemplate
, @senderUserIDSpEd    = emt.defaultSenderUserID
from users.dbo.EMAIL_AND_MESSAGE_TEMPLATES as emt
where (
      (emt.appName     = 'spedcare')
  and (emt.[namespace] = 'patientdata')
  and (emt.[class]     = 'sped')
  and (emt.active = 1)
)

insert into @contacts     
select distinct 
     clientID              = clc.CLIENT_ID
   , totPopIsExpected      = convert(bit,(iif((clc.cronTabExpectedTotPop     = @cronTabSelectionID),1,0)))
   , spEdIsExpected        = convert(bit,(iif((clc.cronTabExpectedSpecEdSvcs = @cronTabSelectionID),1,0)))
   , sendRequestsForTotPop = clc.sendRequestsForTotPop
   , sendRequestsForSpEd   = clc.sendRequestsForSpEd
   , clcc.contactName
   , contactEmail          = clcc.email
   , contactUserID         = clcc.contactUserID

from dbo.CLIENTS_Client       as clc
join dbo.CLIENTS_Contacts     as clcc on ((clcc.clientID = clc.CLIENT_ID) and (clcc.contactRoleID in (7,8)))
join dbo.CLIENT_CONTACT_ROLES as ccr  on (ccr.id = clcc.contactRoleID)
join users.dbo.Users          as u    on ((u.userrid = clcc.contactUserID) and (u.UserName not like '%@QUIT@%'))
join users.dbo.UsersInRoles   as ur   on ((ur.UserId = u.UserId) and (ur.RoleId != users.dbo.CONST_ROLE_INACTIVE()))

where (
      (clc.LEA = 1)
  and ((clc.cronTabExpectedTotPop = @cronTabSelectionID) or (clc.cronTabExpectedSpecEdSvcs = @cronTabSelectionID))
  and (clcc.active = 1)
)

insert into @messages (
    [senderUserID] 
  , [recipientUserIDsStr]
  , [subject]
  , [body]
  , [promptUserToGotoURL]  
  , [gotoURL]              
)

select distinct
    [senderUserID]        = q1.senderUserID
  , [recipientUserIDsStr] = iif((q1.contactUserID is null),'',convert(varchar(50),q1.contactUserID))
  , q1.[subject]
  , q1.[body] 
  , [promptUserToGotoURL] = 1
  , [gotoURL]             = 'user_all_patients_data_import.aspx' /* For now, same url for both TPOP and SpEd */
from
(
  select distinct
      senderUserID     = @senderUserIDTotPop
	, c1.contactEmail
    , c1.contactUserID
    , [subject]        = @subjectTemplateTotPop
    , [body]           = @bodyTemplateTotPop
  from @contacts as c1 
  where ((c1.totPopIsExpected = 1) and (c1.sendRequestsForTotPop = 1) and (@uploadReminderEnabledTotalPop = 1))
  
  union all
  
  select 
      senderUserID     = @senderUserIDSpEd
	, c2.contactEmail
    , c2.contactUserID
    , [subject]        = @subjectTemplateSpEd
    , [body]           = @bodyTemplateSpEd
  from @contacts as c2 
  where ((c2.spedIsExpected = 1) and (c2.sendRequestsForSpEd = 1) and (@uploadReminderEnabledSpEd = 1))
) as q1
   
return

end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].Patient_Data_Imports_Generate_Request_Data_Recipient_List TO [webuser]
GO  
