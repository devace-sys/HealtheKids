USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_CLOSE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_CLOSE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_REQUEST_CLOSE_CORE] (
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
 * SERVICE_AUTHORIZATION_REQUEST_CLOSE_CORE */
/**    
 * Note: This sproc is not meant to be stand alone.  Call this sproc 
 * from within a transaction block
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
BEGIN TRY 

/*============================================================
 * Init
 *============================================================*/  

declare @today     as datetime = null
declare @requestID as bigint   = null

set @today      = getdate()
set @recordID   = 0    
set @spDetails  = ''    
set @requestID  = null

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  

IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',     11, 1)
IF (@userID        IS NULL) RAISERROR ('user id is required',       11, 1)
IF (@userRank      IS NULL) RAISERROR ('userRank is required',      11, 1)
If (@validateRec   IS NULL) RAISERROR ('validaterec is required',   11, 1)
if (@recID         IS NULL) RAISERROR ('recID is required',         11, 1)

/*============================================================
 * Find the request
 * Note: Request needs to be open and active
 *============================================================*/  

select top 1
  @requestID = sar.id
from dbo.SERVICE_AUTHORIZATION_REQUESTS as sar
where (
      (sar.id = @recID)
  and (sar.closed  = 0)
  and (sar.active  = 1)
)

/*============================================================
 * If a record was found and we are not performing validation 
 * only then proceed with close operation
 *============================================================*/  

if ((@requestID is not null) and (@validateRec = 0))
begin

	
  /*-------------------------------    
   * Add status log entry to indicate
   * request was closed
   *------------------------------*/    

  exec dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS @requestID, @today, @userID, 9999, null
	
  /*-------------------------------    
   * Update request record itself
   *------------------------------*/    

  update dbo.SERVICE_AUTHORIZATION_REQUESTS 
  set	  
      lastModified   = @today
    , lastModifiedBy = @userID	  
    , closed  = 1  
  where (id = @requestID)

  /*-------------------------------    
   * Pass back record id
   *------------------------------*/      
  
  set @recordID = @requestID

end
 
/*============================================================
 * All done
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
          
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_CLOSE_CORE] TO [webuser]
GO
