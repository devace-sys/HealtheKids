USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_HOLD_RELEASE_PROCESS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIMS_HOLD_RELEASE_PROCESS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLAIMS_HOLD_RELEASE_PROCESS]  (
   @userID    as bigint    = null    
 , @clientID  as bigint    = null
 , @today     as datetime  = null   
 , @oldestDOS as datetime  = null
 , @newestDOS as datetime  = null
 , @validate  as BIT       = 1) 
    
AS    

BEGIN     
    
/***************************************************************************    
 * CLAIMS_HOLD_RELEASE_PROCESS */    
/**    
 * Processes claims that need to be held and released.
 *
 * Note: This needs to be run at the start of the 837 process.
 *   
 * @param   userID          The userID of who is running this  
 * @param   clientID        Client ID you wish to work with or null for all
 * @param   validate        0 = Return counts and process records
 *                          1 = Just return counts
 ***************************************************************************/         
     
SET NOCOUNT ON    
    

BEGIN TRY    
    
/*============================================================
 * Notify user if we are validating
 *===========================================================*/  

if (@validate = 1) RAISERROR ('Validate mode', 0, 1) WITH NOWAIT
else               RAISERROR ('Live mode',     0, 1) WITH NOWAIT

/*============================================================
 * Setup dates
 *============================================================*/  

if (@today is null) set @today = GETDATE()
set @today = dbo.DATE_ONLY(@today)

if (@oldestDOS is null) set @oldestDOS = dbo.CALC_OLDEST_DOS_ALLOWED(@today)
if (@newestDOS is null) set @newestDOS = @today

/*============================================================
 * Set or renew holds
 *============================================================*/  

exec dbo.CLAIMS_HOLD_PROCESS @today, @userID, @clientID, @oldestDOS, @newestDOS, @validate

/*============================================================
 * Release holds 
 *============================================================*/  

exec dbo.CLAIMS_RELEASE_PROCESS @today, @userID, @clientID, @oldestDOS, @newestDOS, @validate

/*============================================================
 * Done
 *============================================================*/  

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
 
GRANT EXECUTE ON  [dbo].[CLAIMS_HOLD_RELEASE_PROCESS] TO [webuser]
GO
