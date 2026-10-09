USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SITES_Site_Delete') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SITES_Site_Delete
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE PROCEDURE dbo.SITES_Site_Delete(@userID        BIGINT,    
                                       @userGroup     INT,    
                                       @userRank      INT,    
                                       @editDelReason VARCHAR(7000),    
                                       @validateRec   BIT,
                                       @clientID      INT,  
                                       @recID         INT,    
                                       @MsgNoRec      VARCHAR(1000),    
                                       @MsgNoEdit     VARCHAR(1000),    
                                       @spDetails     VARCHAR(8000) OUTPUT,    
                                       @recordID      BIGINT        OUTPUT)
AS 
BEGIN

SET NOCOUNT ON


DECLARE @TranOpen     AS BIT    
DECLARE @today        AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT            -- Audit record id    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT    
   
BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    
   
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
   
  /*-------------------------------    
   * "Delete" existing entity    
   * record    
   *------------------------------*/    
     
  SET @updateState = dbo.CONST_SVC_REC_STATE_DEL()    
  
  UPDATE dbo.SITES_Site
  SET
    active           = 0
  , DATE_MODIFIED    = @today
  , LAST_MODIFIED_BY = @userID
  WHERE 
  (
    (1=1)
    and ((@clientID is null) or (SITE_CLIENT_ID = @clientID))
    and (SITE_ID = @recID)
  )
  

 /*-------------------------------    
  * Create audit record
  *------------------------------*/    
   
 EXEC SITES_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
         
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
   
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SITES_Site_Delete] TO [webuser]
GO