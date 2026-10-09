USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_DATA_INCOMPLETE_DELETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_DATA_INCOMPLETE_DELETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SERVICE_RECORD_DATA_INCOMPLETE_DELETE]
 (
    @userID        BIGINT
  , @userGroup     INT
  , @userRank      INT
  , @clientID      bigint
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @recID         BIGINT
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )
AS
BEGIN

/***************************************************************************
 * SERVICE_RECORD_DATA_INCOMPLETE_DELETE */
/**
 * Deletes an existing incomplete service record entry.
 *
 * @param   validateRec     1 = Performs data integrity validation tasks
 *                              and then exits WITHOUT deleting the record
 *                          0 = Performs data integrity validation tasks and
 *                              if these tasks succeed performs the delete
 * @param   recID           Record id of the incomplete service record to delete
 * @param   MsgNoRec        Error message when record is not found
 * @param   MsgNoEdit       Error message when record cannot be deleted
 * @returns spDetails       Validation or error details
 * @returns recordID        Record id of the deleted record
 ***************************************************************************/

SET NOCOUNT ON

DECLARE @TranOpen     AS BIT
DECLARE @today        AS DATETIME

BEGIN TRY

/*-------------------------------
 * Init our output parameters
 *------------------------------*/

SET @recordID  = 0
SET @spDetails = ''
SET @today     = GETDATE()

/*-------------------------------
 * Verify all parameters that
 * indicate what type of operation
 * to perform have been passed in
 *------------------------------*/

IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)

/*-------------------------------
 * If we are just validating
 * get out now
 *------------------------------*/

IF (@validateRec = 1) RETURN(0)

/*-------------------------------
 * Write changes to the data
 *------------------------------*/

BEGIN TRANSACTION

  SET @TranOpen = 1
  SET @recordID = @recID

  update dbo.SERVICE_RECORD_DATA_INCOMPLETE
  set 
      active         = 0
    , lastModified   = getdate()
    , lastModifiedBy = @userID
  where (
        (id = @recID)
    and ((@clientID is null) or (clientID = @clientID)) /* Middleware forces clientID selection for client users.  This logic partitions by client making sure client users cant change records that are not associated with their clientID */
    and (active = 1)
  )

/*-------------------------------
 * If we reach this point
 * everything is OK, commit our
 * changes and exit
 *------------------------------*/

COMMIT TRANSACTION
SET @TranOpen = 0
RETURN(0)
END TRY

BEGIN CATCH

/*-------------------------------
 * If we end up here something
 * went wrong.  Cancel any pending
 * transactions and return any
 * error messages to the caller
 *------------------------------*/

  IF @TranOpen = 1 ROLLBACK TRANSACTION

  DECLARE @ErrorMessage  AS NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()

  SET @ErrorMessage = @ErrorMessage

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_DATA_INCOMPLETE_DELETE] TO [webuser]
GO
