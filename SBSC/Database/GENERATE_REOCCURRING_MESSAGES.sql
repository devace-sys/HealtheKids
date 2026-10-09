USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GENERATE_REOCCURRING_MESSAGES') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.GENERATE_REOCCURRING_MESSAGES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[GENERATE_REOCCURRING_MESSAGES] (
  @refDate date
)

AS
BEGIN

set nocount on

declare @currIdx               as bigint
declare @minIdx                as bigint
declare @maxIdx                as bigint
declare @cronTabSelectionName  as varchar(128)
declare @cronTabSelectionValue as bigint
declare @msgStr                as varchar(512)
declare @numMessagesToSend     as int
declare @numRows               as int
declare @appName               as varchar(50)
declare @senderUserID          as bigint
declare @senderUserGroupID     as int
declare @senderUserRank        as int
declare @recipientEmailsStr    as varchar(max)
declare @recipientUserIDsStr   as varchar(max)
declare @subject               as varchar(256)
declare @body                  as varchar(max)
declare @sendEmail             as bit
declare @promptUserToGotoURL   as bit
declare @gotoURL               as varchar(256)



declare @cronTabSelections     as table (
   idx             bigint identity(1,1)
  ,[name]          varchar(128)
  ,selection_value bigint
)

declare @messages table (
    [idx]                  bigint identity(1,1)
  , [appName]              varchar(50)
  , [senderUserID]         bigint
  , [recipientUserIDsStr]  varchar(max)
  , [subject]              varchar(256)
  , [body]                 varchar(max)
  , [sendEmail]            bit
  , [promptUserToGotoURL]  bit
  , [gotoURL]              varchar(256)
  , [selection_value]      bigint
)

exec dbo.PRINT_STATUS_MESSAGE 'Generating and sending reoccuring messages - Starting'

if (@refDate is null) set @refDate = convert(date,getdate())

set @msgStr = 'Reference date : ' + convert(varchar,@refDate)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

/*============================================================
 * Update client contact user associations
 *============================================================*/

exec dbo.PRINT_STATUS_MESSAGE 'Update client contact user associations'

update cc

  set cc.contactUserID =  u.userrid

from dbo.CLIENTS_Contacts   as cc
join users.dbo.Membership   as m on ((m.District_ID = cc.clientID)
                                 and (m.Email = cc.email))
join users.dbo.Users        as u on ((u.UserId = m.UserId)
                                 and (u.UserName not like '%@QUIT@%'))
join users.dbo.UsersInRoles as ur on  ((ur.UserId = u.UserId)
                                  and (ur.RoleId != users.dbo.CONST_ROLE_INACTIVE()))
join users.dbo.RoleData     as rd on ((rd.RoleId = ur.RoleId)
                                  and (rd.appName = @appName))


/*============================================================
 * Get all possible reoccurance values (scenerios)
 *============================================================*/

exec dbo.PRINT_STATUS_MESSAGE 'Fetching all possible reoccurance values'

insert into @cronTabSelections (
    [name]
  , [selection_value]
)
select
    [name]
  , [selection_value]
from dbo.CRON_TAB_SELECTIONS as cts
where
  ((cts.selection_value != 99) and (cts.active = 1))

/*============================================================
 * For each reoccurance scenerio
 *============================================================*/

exec dbo.PRINT_STATUS_MESSAGE 'Generating reoccuring messages'

set @minIdx = 0
set @maxIdx = 0
set @currIdx = 0
select
    @minIdx = min(cts.idx)
  , @maxIdx = max(cts.idx)
from @cronTabSelections as cts
set @currIdx = @minIdx

while (@currIdx <= @maxIdx)
begin

  /* Get reoccurance value */

  select top 1
      @cronTabSelectionName  = cts.[name]
	, @cronTabSelectionValue = cts.selection_value
  from @cronTabSelections as cts
  where (cts.idx = @currIdx)

  /*-------------------------------
   * If the reference date matches
   * the reoccurance scenerio
   *------------------------------*/

  if (dbo.IS_REF_DATE_CRON_TAB_SELECTION_VALUE (@refDate, @cronTabSelectionValue) = 1)
  begin

    set @msgStr = 'Generating all applicable ' + @cronTabSelectionName + ' messages'
	exec dbo.PRINT_STATUS_MESSAGE @msgStr

    /*-------------------------------
     * Generate any applicable
     * patient data import requests
     *------------------------------*/

	set @msgStr = 'Generating any ' + @cronTabSelectionName + ' patient data import request messages'
	exec dbo.PRINT_STATUS_MESSAGE @msgStr

	insert into @messages (
	    [appName]
      , [senderUserID]
      , [recipientUserIDsStr]
      , [subject]
      , [body]
      , [sendEmail]
	  , [promptUserToGotoURL]
      , [gotoURL]
	  , [selection_value] )

	select
	    t1.[appName]
      , t1.[senderUserID]
      , t1.[recipientUserIDsStr]
      , t1.[subject]
      , t1.[body]
      , t1.[sendEmail]
	  , t1.[promptUserToGotoURL]
	  , t1.[gotoURL]
	  , [selection_value] = @cronTabSelectionValue

	from dbo.Patient_Data_Imports_Generate_Request_Data_Recipient_List(@cronTabSelectionValue) as t1

    /*-------------------------------
     * NOTE: Expansion hook
     * Insert additional messages
	 * for other subsystems that
	 * need messages
     *------------------------------*/

  end

  set @currIdx = @currIdx+1
end

/*============================================================
 * Count messages to send
 *============================================================*/

set @numMessagesToSend = 0
select @numMessagesToSend = count(m.idx) from @messages as m

/*============================================================
 * If there are no messages to send get out
 *============================================================*/

if (@numMessagesToSend = 0)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'There are no messages to send'
  exec dbo.PRINT_STATUS_MESSAGE 'Generating and sending reoccuring messages - Finished'
  return(0)
end

/*============================================================
 * Otherwise proceed with sending messages
 *============================================================*/

set @msgStr = 'There are ' + convert(varchar(50),@numMessagesToSend) + ' messages to send'
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @minIdx  = 0
set @maxIdx  = 0
set @currIdx = 0

select
    @minIdx = min(m.idx)
  , @maxIdx = max(m.idx)
from @messages as m
set @currIdx = @minIdx

/*============================================================
 * Send messages
 *============================================================*/

exec dbo.PRINT_STATUS_MESSAGE 'Sending messages'

while (@currIdx <= @maxIdx)
begin

   /*-------------------------------
     * Fetch message to send
     *------------------------------*/

  select top 1
      @appName              = m.appName
    , @senderUserID         = m.senderUserID
    , @recipientUserIDsStr  = m.recipientUserIDsStr
    , @subject              = m.[subject]
    , @body                 = m.[body]
    , @promptUserToGotoURL  = m.[promptUserToGotoURL]
    , @gotoURL              = m.[gotoURL]
	, @cronTabSelectionName = cts.[name]
  from @messages          as m
  join @cronTabSelections as cts on cts.selection_value = m.selection_value
  where (m.idx = @currIdx)

  /*-------------------------------
   * Send message
   *------------------------------*/

  if (@recipientUserIDsStr != '')
  begin

  set @msgStr = 'Sending message ' + convert(varchar(50),@currIdx) + ' (' + @cronTabSelectionName + ') message'
  exec dbo.PRINT_STATUS_MESSAGE @msgStr

  select top 1
      @senderUserGroupID = ua.userGroupID
	, @senderUserRank    = ua.roleRank

  from users.dbo.USERS_ALL as ua
  where
      (ua.appName = @appName)
  and (ua.id = @senderUserID)

  declare @spDetails as varchar(8000) = ''

  declare @msgID as bigint            = 0

  exec users.dbo.USERS_MESSAGES_SAVE_GENERATED
      @senderUserID
	, @senderUserGroupID
	, @senderUserRank
	, @appName
	, @recipientUserIDsStr
	, @subject
	, @body
	, 1 /* Send email */
	, null /*@respPromptOptionsBitwise*/
	, null /*@respPromptOptionsJSON*/
	, @promptUserToGotoURL
  , @gotoUrl
  , ''   -- @gotoURLAdditionalParams

	, 1  /* save type*/
	, 0  /* Rec id */
	, @spDetails output
	, @msgID output

    set @msgStr = 'Message saved.  Message id : ' + convert(varchar(50),@msgID)
    exec dbo.PRINT_STATUS_MESSAGE @msgStr

  end
  else
  begin
    set @msgStr = 'Skipping message ' + convert(varchar(50),@currIdx) + ' because recipient(s) have no user account(s) (' + @cronTabSelectionName + ') message'
    exec dbo.PRINT_STATUS_MESSAGE @msgStr
  end

  set @currIdx = @currIdx + 1
end

exec dbo.PRINT_STATUS_MESSAGE 'Generating and sending reoccuring messages - Finished'

RETURN(0)
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[GENERATE_REOCCURRING_MESSAGES] TO [webuser]
GO
