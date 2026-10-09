USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.WORK_BATCHES_NOT_INPUT_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.WORK_BATCHES_NOT_INPUT_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[WORK_BATCHES_NOT_INPUT_VIEW_CORE] (  
   @clientID       bigint
 , @startDateDOS   datetime
 , @endDateDOS     datetime
 , @today          datetime )
 
RETURNS TABLE
 
 /***************************************************************************    
  * WORK_BATCHES_NOT_INPUT_VIEW_CORE */    
 /**    
  * Returns a table of report rows
  *    
  * @param   clientID       
  * @param   oldestDOS
  * @returns Table
  ***************************************************************************/     
 
AS RETURN (

with
cte_p1
as
(
select  
     clc.*
   , INPUT_BATCH_ID                  = ib.id
   , UPLOAD_ID                       = fu.id
   , UPLOADED_BY_EMAIL               = fileUploaderContactEmail
   , FILE_NAME_ORIGINAL              = fu.originalName
   , FILE_NAME_FILED_AS              = fu.filedName
   , FILE_NAME_BATCH                 = ib.File_Name
   , FILE_LOCATION_BATCH             = ib.File_Location
   , RECEIVED_ON                     = ib.Date_Recieved
   , OLDEST_SVC_DATE_ESTIMATE        = isnull(ib.Oldest_DOS, ib.Date_Recieved)
   , TYPE_OF_WORK_CODE               = tow.WorkCode
   , TYPE_OF_WORK                    = tow.WorkType
   , CURRENT_STATUS_DATE             = ib.Current_Status_Date
   , CURRENT_STATUS_CODE             = ib.Current_status_Code
   , CURRENT_STATUS                  = ibs.Status 
   , CURRENT_STATUS_USER_ID_1        = ib.Current_status_UserID1
   , CURRENT_STATUS_USER_NAME_1      = u1.UserName
   , CURRENT_STATUS_USER_EMAIL_1     = m1.Email
   , CURRENT_STATUS_USER_ID_2        = ib.Current_status_UserID2
   , CURRENT_STATUS_USER_NAME_2      = u2.UserName
   , CURRENT_STATUS_USER_EMAIL_2     = m2.Email

from dbo.CLIENTS_Client_Active_LEA          as clc
join dbo.INPUT_BATCHES                      as ib on ib.ClientID = clc.CLIENT_ID
join dbo.TYPE_OF_WORK                       as tow on tow.id = ib.Type_Of_Work
join dbo.Input_Batches_Status               as ibs on ibs.Status_Code = ib.Current_status_Code

join dbo.FILE_UPLOAD_ID_INPUT_BATCH_ID_XREF(null) as fur on fur.inputBatchID = ib.id
join dbo.FILE_UPLOADS                             as fu  on fu.id            = fur.uploadID

left join users.dbo.Users                   as u1    on  u1.userrid           = ib.Current_status_UserID1
left join users.dbo.Membership              as m1    on  m1.UserId            = u1.UserId

left join users.dbo.Users                   as u2    on  u2.userrid           = ib.Current_status_UserID2
left join users.dbo.Membership              as m2    on  m2.UserId            = u2.UserId

left join dbo.INPUT_BATCHES_SERVICE_RECORDS as ibsr on ibsr.inputBatchID = ib.id

where (
        (1=1)
    and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
    and (ib.Active = 1) 
    and (ibsr.id is null)
    and (ib.Current_status_Code not in (200,310,400))
  )
)
,
cte_p2
as
(
  select 
      *  
    , SERVICE_DATE_AGE_IN_DAYS = DATEDIFF(day,OLDEST_SVC_DATE_ESTIMATE,@today)
    , USE_OR_LOSE              = dbo.CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM(OLDEST_SVC_DATE_ESTIMATE,@today)
  from cte_p1   
  where
      (1=1)
  and (OLDEST_SVC_DATE_ESTIMATE between @startDateDOS and @endDateDOS)
)  

select 
  *  
from cte_p2
)
 
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[WORK_BATCHES_NOT_INPUT_VIEW_CORE] TO [webuser]
GO