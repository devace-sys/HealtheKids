USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_MESSAGES_SAVE_SIMPLE_W_NAV') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.USERS_MESSAGES_SAVE_SIMPLE_W_NAV
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[USERS_MESSAGES_SAVE_SIMPLE_W_NAV]  (
    @userID                   BIGINT
  , @userGroup                INT
  , @userRank                 INT
  , @appName                  VARCHAR(50)
  , @recipientUserIDsStr      VARCHAR(max)
  , @subject                  VARCHAR(256)
  , @body                     VARCHAR(max)
  , @sendEmail                bit
  , @respPromptOptionsBitwise int
  , @respPromptOptionsJSON    varchar(max)

  , @promptUserToGotoURL      bit
  , @gotoURL                  varchar(256)
  , @gotoURLAdditionalParams  varchar(140)

  , @saveType                 INT
  , @recID                    BIGINT
  , @spDetails                VARCHAR(8000) OUTPUT
  , @recordID                 BIGINT        OUTPUT
)
AS
BEGIN

/***************************************************************************
 * USERS_MESSAGES_SAVE_SIMPLE_W_NAV */
/**
 * Creates a new notification, with or without an email, that includes a finger navlink.
 *
 * @param   userID                    The userid of who saved the record
 * @param   userGroup                 Users group
 * @param   userRank                  User rank


 * @param   @appName                  app name from MBA.Constants
 * @param   @recipientUserIDsStr      numeric UserIDs of recipient users, as comma-separated string
 * @param   @subject                  subject
 * @param   @body                     message body
 * @param   @sendEmail                send email?

 * @param   @respPromptOptionsBitwise respPromptOptionsBitwise
 *                                     TODO: document all valid bitwise options, here
 * @param   @respPromptOptionsJSON    respPromptOptionsJSON
 *                                     TODO: document all valid JSON properties, here
 *                                     TODO: also make a validate function that throws error w/ invalid, undefined JSON options

 * @param   @promptUserToGotoURL      promptUserToGotoURL
 * @param   @gotoURL                  gotoURL
 * @param   @gotoURLAdditionalParams  gotoURLAdditionalParams


 * @param   saveType        Type of operation to perform
 *                          1 = New, 2 = Edit, 3 = Delete

 * @param   recID           Record id of existing patient record to edit or
 *                          delete.

 * @returns spDetails       Validation or error details
 * @returns recordID        New record id or record id of service record that
 *                          was changed or deleted
 ***************************************************************************/

SET NOCOUNT ON

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
  , @respPromptOptionsBitwise
  , @respPromptOptionsJSON

  , @promptUserToGotoURL
  , @gotoURL
  , @gotoURLAdditionalParams

  , 1                      /* OktoShow  */

  , 0                      /* System generated */


  , 0                      /* Allow reply */
  , @sendEmail             /* Send email */
  , 0                      /* Email sent */
  , 1                      /*@active*/
  , ''                     /*@editDelReason  */
  , 0                      /*@validateRec  */
  , @saveType
  , @recID
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


GRANT EXECUTE ON  [dbo].[USERS_MESSAGES_SAVE_SIMPLE_W_NAV] TO [webuser]
GO
