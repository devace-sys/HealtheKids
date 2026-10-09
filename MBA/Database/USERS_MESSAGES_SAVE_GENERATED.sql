USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_MESSAGES_SAVE_GENERATED') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.USERS_MESSAGES_SAVE_GENERATED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[USERS_MESSAGES_SAVE_GENERATED] (
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
 * USERS_MESSAGES_SAVE_GENERATED */
/**
 * Creates a new
 *
 * @param   userID          The userid of who saved the record
 * @param   userGroup       Users group
 * @param   userRank        User rank

 * @param   editDelReason   Reason for record edit or delete
 * @param   validateRec     1 = Performs data integrity validation tasks
                                Perform advisory validation tasks that can
 *                              only be conducted by referencing data from the
 *                              database and then exits WITHOUT saving the record
 *                          0 = Peform data integrity validation tasks and
 *                              if these tasks succeed peforms the desired
 *                              operation (saveType) on the record and exits
 * @param   saveType        Type of operation to perform
 *                          1 = New, 2 = Edit, 3 = Delete
 * @param   recID           Record id of existing patient record to edit or
 *                          delete.
 * @param   MsgNoRec        Desired error message if a recID is not found
 * @param   MsgNoEdit       Desired error message if a record cannot be edited
 * @param   MsgDupRec       Desired error message for duplicate detection
 * @param   MsgNoClient     Desired error message if a clientID is not found
 * @param   MsgNoSite       Desired error message if a siteID is not found
 * @param   MsgDataError    Desired error message for data errors
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
  , 1                      /* System generated */
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

GRANT EXECUTE ON  [dbo].[USERS_MESSAGES_SAVE_GENERATED] TO [webuser]
GO
