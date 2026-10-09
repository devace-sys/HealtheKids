USE SPEDMON
GO


/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_DELETE') AND type in (N'P', N'PC'))
	DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_DELETE
GO


/*-------------------------------
 * Delete 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_REQUEST_DELETE] (
    @userID                BIGINT    
  , @userGroup             INT  
  , @userRank              INT 
  , @editDelReason         VARCHAR(7000)
  , @validateRec           BIT
  , @recID                 BIGINT  
  , @MsgNoRec              VARCHAR(1000)
  , @MsgNoEdit             VARCHAR(1000)
  , @recordID              BIGINT        OUTPUT   
  , @spDetails             VARCHAR(8000) OUTPUT )
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_AUTHORIZATION_REQUEST_DELETE */    
/**    
* same parameters as SERVICE_AUTHORIZATION_REQUEST_DELETE_CORE
****************************************************************************/         
     
SET NOCOUNT ON    


BEGIN TRY
/*============================================================
 * Variables
 *============================================================*/  

declare  @tranOpen                as bit            = 0 -- Is a transaction open  
 

BEGIN TRANSACTION

set @TranOpen = 1

/*-------------------------------    
 * Perform delete operation
 *------------------------------*/    

exec dbo.SERVICE_AUTHORIZATION_REQUEST_DELETE_CORE
    @userID
  , @userGroup
  , @userRank
  , @editDelReason
  , @validateRec
  , @recID
  , @MsgNoRec
  , @MsgNoEdit
  , @spDetails OUTPUT
  , @recordID  OUTPUT


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

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_DELETE] TO [webuser]
GO
