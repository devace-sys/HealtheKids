USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES ( 
    @userID                            BIGINT
  , @userGroup                         INT
  , @userRank                          INT
  , @requestID                         bigint
  , @selectedFileList                  varchar(max)
)
AS
BEGIN

SET NOCOUNT ON

/*============================================================
 * Variables
 *============================================================*/

declare @today               as datetime
declare @tranOpen            as bit            -- Is a transaction open

BEGIN TRY

BEGIN TRANSACTION

SET @TranOpen = 1
set @today    = getdate()

/*============================================================
 * Call core routine
 *============================================================*/

exec dbo.SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES_CORE @requestID, @selectedFileList,@userID,@today

 
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
                         
GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES] TO [webuser]
GO