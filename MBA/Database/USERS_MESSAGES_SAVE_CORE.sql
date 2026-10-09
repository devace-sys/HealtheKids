USE [SPEDMON];
GO
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_MESSAGES_SAVE_CORE') AND type in (N'P', N'PC'))
	DROP PROCEDURE dbo.USERS_MESSAGES_SAVE_CORE
	GO
GRANT SELECT ON OBJECT ::dbo.PATIENTS_PERSON TO [webuser];
GO



USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_MESSAGES_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.USERS_MESSAGES_SAVE_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[USERS_MESSAGES_SAVE_CORE] (
    @userID                   BIGINT
  , @userGroup                INT
  , @userRank                 INT
  , @appName                  VARCHAR(50)
  , @recipientUserIDsStr      VARCHAR(max)
  , @subject                  VARCHAR(256)
  , @body                     VARCHAR(max)
  , @isReply                  BIT
  , @previousMsgID            BIGINT
  , @hasRead                  BIT
  , @respPromptOptionsBitwise int
  , @respPromptOptionsJSON    varchar(max)
 
  , @promptUserToGotoURL      bit
  , @gotoURL                  varchar(256)
  , @gotoURLAdditionalParams  varchar(140)
 
  , @OktoShow                 BIT
  , @systemGenerated          bit
  , @allowReply               bit
  , @sendEmail                bit
  , @emailSent                bit
  , @active             BIT
  , @editDelReason            VARCHAR(7000)
  , @validateRec              BIT
  , @saveType                 INT
  , @recID                    BIGINT
  , @MsgNoRec                 VARCHAR(1000)
  , @MsgNoEdit                VARCHAR(1000)
  , @MsgDupRec                VARCHAR(1000)
  , @MsgDataError             VARCHAR(1000)
  , @MsgNotActive             VARCHAR(1000)
  , @spDetails                VARCHAR(8000) OUTPUT
  , @recordID                 BIGINT        OUTPUT
)
AS
BEGIN
 
/***************************************************************************
 * USERS_MESSAGES_SAVE_CORE */
/**
 * Creates a new
 *
 *                          was changed or deleted
 ***************************************************************************/
 
SET NOCOUNT ON
 
DECLARE @TranOpen            AS BIT
DECLARE @today               AS DATETIME
DECLARE @userUID             AS UNIQUEIDENTIFIER
DECLARE @clientID            AS BIGINT
DECLARE @userMessageID       AS BIGINT
DECLARE @userIsPCAL          AS BIT
declare @userRoleID          as bigint
 
declare @limitRecipientsToAssociatedClient as bit = 1
 
declare @associatedClientIDs as table (clientID bigint)
declare @recipientUserIDs    as table (id int, recid bigint)
 
BEGIN TRY
 
/*============================================================
 * Init
 *============================================================*/
 
set @spDetails  = ''
set @recordID = 0
set @today    = GETDATE()
 
/*============================================================
 * Clean up incoming parameters
 *============================================================*/
 
set @subject = trim(isnull(@subject,''))
set @body    = trim(isnull(@body,''))
if (@sendEmail           is null) set @sendEmail           = 0
if (@promptUserToGotoURL is null) set @promptUserToGotoURL = 0
 
/*============================================================
 * Verify required parameterers
 *============================================================*/
 
IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)
 
/*============================================================
 * Get sender user info
 *============================================================*/
 
if (@systemGenerated = 0)
begin
 
  select top 1
   @userUID    = ua.uid
    , @clientID   = ua.clientID
    , @userIsPCAL = ua.pcalStaff
    , @userRoleID = ua.roleID
  from dbo.USERS_ALL as ua
  where (
       (ua.id = @userID)
   and (ua.appName = @appName)
  )
  /* PCAL users have no associated client limit */
 
  if (@userIsPCAL = 1)
  begin
    set @limitRecipientsToAssociatedClient = 0
  end
  /* All other roles have a limit */
  else
  begin
    set @limitRecipientsToAssociatedClient = 0
    /* Parent guardians can have multiple clients */
 
 if (@userRoleID = 12)
    begin

   insert into @associatedClientIDs (
        clientID
      )
      select distinct
        clientID = pp.CLIENT_ID 
      from spedmon.dbo.PATIENTS_PERSON as pp 
      where ( 
            (pp.USER_ID_INT = @userID)
        and (pp.ACTIVE = 1)
      )
    end
    /* Everyone else */
 
 else
    begin
      
   insert into @associatedClientIDs (
     clientID
   )
   values (@clientID)
    end
  end
end
 
/* System generated */
 
else
begin
   set @userUID    = null
   set @clientID   = 0
   set @userIsPCAL = 0
   set @limitRecipientsToAssociatedClient = 0
end
 
/*============================================================
 * Extract individual user ids
 *============================================================*/
 
set @recipientUserIDsStr = trim(isnull(@recipientUserIDsStr,''))
 
INSERT INTO @recipientUserIDs
SELECT t1.*
FROM dbo.MULTI_RECORD_ID_PARSE(@recipientUserIDsStr,',') as t1
 
/*-------------------------------
 * Validation exit
 *------------------------------*/
 
IF (@validateRec = 1)
BEGIN
  SET @recordID = 0
  RETURN(0)
END
 
/*============================================================
 * Write data
 *============================================================*/
 
/*==============================
 * New Record
 *==============================*/
 
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
BEGIN
 
  /*-------------------------------
   * Validate recipient options
   *
   * clients cannot message people
   * outside of their own client
   *------------------------------*/
 
   IF (@limitRecipientsToAssociatedClient = 1)
   BEGIN
 
  IF (
   -- check for no recipients passed
     (isnull(@recipientUserIDsStr, '') = '')
 
   -- check for invalid/non-existing user AND check for same client
  or ((select count(*) from @recipientUserIDs)
       !=
       (select count(*) 
   from @recipientUserIDs as ru            
       join dbo.users_all     as ua on ua.id = ru.recid
   join @associatedClientIDs as ac on ac.clientID = ua.clientID
        where 
      ua.appName  = @appName
       )
       )
  )
  begin
   RAISERROR ('Invalid recipient',   11, 1)
  end
    END
 
  ELSE
  BEGIN
      IF (
       -- check for no recipients passed
         (isnull(@recipientUserIDsStr, '') = '')
 
       -- check for invalid/non-existing user
      or ((select count(*) from @recipientUserIDs)
          !=
          (select count(*) from @recipientUserIDs as ru
           join dbo.users_all as ua on ua.id = ru.recid
           where ua.appName  = @appName
          )
          )
      )
      begin
       RAISERROR ('Invalid recipient',   11, 1)
      end
  END
 
     /*==============================
      * Insert message into Messages
      *==============================*/
 
     INSERT INTO dbo.MESSAGES (
       [appName]
     , [senderUserID]
  , [senderUID]
  , [subject]
  , [body]
  , [isReply]
  , [PreviousMsgID]
  , [created]
  , [createdBy]
  , [active]
        , [respPromptOptionsBitwise]
        , [respPromptOptionsJSON]
     , [systemGenerated]
  , [allowReply]
                , promptUserToGotoURL
                , gotoURL
                , gotoURLAdditionalParams
   )
   values (
       @appName
     , @userID
  , @userUID
     , @subject
  , @body
  , @isReply
  , @previousMsgID
  , @today
  , @userID
  , @active
        , @respPromptOptionsBitwise
        , @respPromptOptionsJSON
  , @systemGenerated
  , @allowReply
        , @promptUserToGotoURL
        , @gotoURL
        , @gotoURLAdditionalParams
   )
 
   SET @recordID = SCOPE_IDENTITY()
 
     /*==============================
      * Set up recipients
      *==============================*/
 
  INSERT INTO dbo.USERS_MESSAGES (
    [messageID]
  , [recipientUserID]
  , [recipientUID]
  , [sendEmail]
  , [active]
  )
  SELECT
    [messageID]        = @recordID
  , [recipientUserID] = ua.id
  , [recipientUID]    = ua.uid
  , [sendEmail]       = @sendEmail
  , [active]          = 1
  FROM @recipientUserIDs as ru
  join dbo.users_all     as ua on ua.id = ru.recid and ua.appName = @appName
 
 END
 
 /*==============================
  * Edit Record
  *==============================*/
 
 ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
 BEGIN
 
 if (@recID is null)
 begin
  RAISERROR('recID is required for edits', 11, 1)
 end
 
 select top 1
  @userMessageID = um.id  /* Gets rec we need to update */
   , @recordID       = m.id   /* Makes sure @recordID returned is the same value as @recID for the caller */
 from dbo.USERS_MESSAGES as um
 join dbo.MESSAGES       as m on m.id = um.messageID
 where (
    (um.recipientUserID = @userID)
   and (um.messageID       = @recID)
   and (m.appName          = @appName)
 )
 
 if (@userMessageID is null) RAISERROR('Invalid Record ID'    ,11, 2)
 
 if (@hasRead is not null)
 begin
    update dbo.USERS_MESSAGES
    set hasRead        = @hasRead
     , lastModified   = @today
        , lastModifiedBy = @userID
    where (id = @userMessageID)
 end
 
 if (@okToShow is not null)
 begin
  update dbo.USERS_MESSAGES
  set   okToShow       = @okToShow
      , lastModified   = @today
      , lastModifiedBy = @userID
  where (id = @userMessageID)
 end
 
 if (@emailSent is not null)
 begin
  update dbo.USERS_MESSAGES
  set   emailSent      = @emailSent
      , lastModified   = @today
      , lastModifiedBy = @userID
  where (id = @userMessageID)
 end
 
 END
 ELSE
 BEGIN
   RAISERROR ('Unknown or unsupported save type', 11, 1)
 END
 

/*-------------------------------
 * If we reach this point
 * everything is OK
 *------------------------------*/
 
RETURN(0)
END TRY
BEGIN CATCH
 
  /*-------------------------------
   * If we end up here something
   * went wrong.  Cancel any pending
   * transactions and return any
   * error any error messages to
   * the caller
   *------------------------------*/
 

  DECLARE @ErrorMessage  AS NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT
 
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()
 
   if (@ErrorSeverity > 11)
     SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'
 
  -- Reraise the error so it returns back to the server
 
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
 
END CATCH
END
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[USERS_MESSAGES_SAVE_CORE] TO [webuser]
GO
 
