USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_SAVE
GO


/*-------------------------------
 * Create
 *------------------------------*/

CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_REQUEST_SAVE] (
    @userID                            BIGINT
  , @userGroup                         INT
  , @userRank                          INT
  , @clientID                          BIGINT
  , @districtContactUserID                            BIGINT
  , @patID                             BIGINT
  , @svcAuthorizationRequestTypeID     BIGINT
  , @referencedEntityID                BIGINT
  , @svcDescription                    VARCHAR (8000)
  , @formBuilderQuestionsJSON          VARCHAR(max)
  , @formBuilderAnswersJSON            VARCHAR(max)
  , @reqSvcAuthFromSelectionID         BIGINT
  , @reqSvcAuthMethodSelectionID       BIGINT
  , @prtGrd1PersonID                   BIGINT
  , @prtGrd2PersonID                   BIGINT
  , @orpPracID                         BIGINT 
  , @selectedFileList                  varchar(max)
  , @pwdMinLen                         INT
  , @svcAuthRequestMsgUrlBase          varchar(512)
  , @svcAuthRequestPaperUploadUrlBase  varchar(512)
  , @editDelReason         VARCHAR(7000)
  , @validateRec           BIT
  , @saveType              INT
  , @recID                 BIGINT
  , @MsgNoRec              VARCHAR(1000)
  , @MsgNoEdit             VARCHAR(1000)
  , @MsgDupRec             VARCHAR(1000)
  , @MsgDataError          VARCHAR(1000)
  , @MsgNotActive          VARCHAR(1000)
  , @recordID              BIGINT        OUTPUT
  , @jsonData              varchar(max)  OUTPUT
  , @spDetails             VARCHAR(8000) OUTPUT )
AS
BEGIN

/***************************************************************************
 * SERVICE_AUTHORIZATION_REQUEST_SAVE */
/**
 * Creates new or edits existing
 *
 * @param   userID          The userid of who saved the record
 * @param   userGroup       Users group
 * @param   userRank        User rank
 * @param   clientID        Client id
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
 * @param   MsgDataError    Desired error message for data errors
 * @returns spDetails       Validation or error details
 * @returns recordID        New record id or record id of service record that
 *                          was changed or deleted
 ***************************************************************************/

SET NOCOUNT ON

/*============================================================
 * Variables
 *============================================================*/

declare @tranOpen                       as bit            -- Is a transaction open

BEGIN TRY

BEGIN TRANSACTION

SET @TranOpen = 1

exec dbo.SERVICE_AUTHORIZATION_REQUEST_SAVE_CORE
    @userID
  , @userGroup
  , @userRank
  , @clientID
  , @districtContactUserID
  , @patID
  , 15 /* Request Screen */
  , 25 /* Initial Request */
  , @svcAuthorizationRequestTypeID
  , @referencedEntityID
  , @svcDescription
  , @formBuilderQuestionsJSON
  , @formBuilderAnswersJSON
  , @reqSvcAuthFromSelectionID
  , @reqSvcAuthMethodSelectionID
  , @prtGrd1PersonID
  , @prtGrd2PersonID
  , @orpPracID
  , @selectedFileList
  , @pwdMinLen
  , @svcAuthRequestMsgUrlBase
  , @svcAuthRequestPaperUploadUrlBase
  , @editDelReason
  , @validateRec
  , @saveType
  , @recID
  , @MsgNoRec
  , @MsgNoEdit
  , @MsgDupRec
  , @MsgDataError
  , @MsgNotActive
  , @recordID                      OUTPUT
  , @jsonData                      OUTPUT
  , @spDetails                     OUTPUT

/*============================================================
 * All done, commit changes and get out
 *============================================================*/

COMMIT TRANSACTION
SET @TranOpen = 0
RETURN(0)
END TRY

/*============================================================
 * Exception handling
 *============================================================*/

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

  -- Only send really bad exceptions back with sp details

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

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_SAVE] TO [webuser]
GO
