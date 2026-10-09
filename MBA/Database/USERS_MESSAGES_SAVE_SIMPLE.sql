USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_MESSAGES_SAVE_SIMPLE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.USERS_MESSAGES_SAVE_SIMPLE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[USERS_MESSAGES_SAVE_SIMPLE] (
    @userID                   BIGINT
  , @userGroup                INT
  , @userRank                 INT
  , @appName                  VARCHAR(50)
  , @recipientUserIDsStr      VARCHAR(max)
  , @subject                  VARCHAR(256)
  , @body                     VARCHAR(max)
  , @allowReply               bit = 0
  , @sendEmail                bit = 0
  , @spDetails                VARCHAR(8000) OUTPUT
  , @recordID                 BIGINT        OUTPUT
)
AS
BEGIN

/***************************************************************************
 * USERS_MESSAGES_SAVE_SIMPLE */
/**
 * Meant for simple message hooks for user -> user messages in other
 * stored procedures.  If you need to create non reply notifications, use
 * USERS_MESSAGES_SAVE_GENERATED.
 ***************************************************************************/

SET NOCOUNT ON

set @spDetails = ''
set @recordID  = 0

DECLARE @tranOpen as bit

BEGIN TRY

begin transaction

set @tranOpen = 1

exec dbo.USERS_MESSAGES_SAVE_CORE
    @userID
  , @userGroup
  , @userRank
  , @appName
  , @recipientUserIDsStr
  , @subject
  , @body
  , 0                       /*@isReply*/
  , null                    /*@previousMsgID */
  , 0                       /*@hasRead*/
   , null  /* @respPromptOptionsBitwise*/
   , null  /* @respPromptOptionsJSON*/
  , 0     /*@promptUserToGotoURL*/
  , null  /*@gotoURL*/
  , null  /*@gotoURLAdditionalParams*/
  , 1                      /* OktoShow  */
  , 0                      /* System generated */
  , @allowReply            /* Allow reply */
  , @sendEmail             /* Send email */
  , 0                      /* Email sent */
  , 1                      /*@active*/
  , ''                     /*@editDelReason  */
  , 0                      /*@validateRec  */
  , 1 /* @saveType */
  , null /*@recID*/
  , 'No record'        /*@MsgNoRec  */
  , 'No edit'          /*@MsgNoEdit  */
  , 'Duplicate record' /*@MsgDupRec */
  , 'Data error'       /*@MsgDataError */
  , 'Not active'       /*@MsgNotActive */
  , @spDetails                OUTPUT
  , @recordID                 OUTPUT

commit transaction
set @tranOpen = 0

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

  -- Error or raise error with severity 11 to 19 will be caught here

  IF @tranOpen = 1 ROLLBACK TRANSACTION

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

GRANT EXECUTE ON  [dbo].[USERS_MESSAGES_SAVE_SIMPLE] TO [webuser]
GO
