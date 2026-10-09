USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORD_SET_FILE_UPLOAD_PENDING') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORD_SET_FILE_UPLOAD_PENDING
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORD_SET_FILE_UPLOAD_PENDING] (
    @userID              BIGINT
  , @userGroup           INT
  , @userRank            INT 
  , @fileUploadPending   BIT
  , @fileUploadID        BIGINT  
  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT
  , @recID               BIGINT
  , @MsgNoRec      VARCHAR(1000)    
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
 
/***************************************************************************    
 * SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORD_SET_FILE_UPLOAD_PENDING */    
/**    
 ***************************************************************************/         
 
SET NOCOUNT ON    
 
DECLARE @TranOpen            AS BIT  
DECLARE @auditRecID          AS BIGINT
DECLARE @today               as DATETIME

BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
SET @spDetails  = ''    
SET @recordID = NULL 
SET @today    = GETDATE()
  
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
 
IF (@userID      IS NULL) RAISERROR ('userID is required',   11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
    
/*============================================================
 * Validation exit
 *============================================================*/  
  
IF (@validateRec = 1) 
BEGIN    
  set @recordID = @recID
  RETURN(0)    
END        
 
/*============================================================
 * Make our changes
 *============================================================*/  

BEGIN TRANSACTION    
 
  SET @TranOpen = 1  
  
  update dbo.SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORDS 
  set 
    fileUploadPending = @fileUploadPending
  , uploadID          = @fileUploadID
  , lastModified      = @today
  , lastModifiedBy    = @userID
  where (id = @recID)
  
 
 set @recordID = @recID

 /*-------------------------------    
  * Create audit record    
  *------------------------------*/    
 
 --EXEC Noun_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
 
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
 
GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORD_SET_FILE_UPLOAD_PENDING] TO [webuser]
GO