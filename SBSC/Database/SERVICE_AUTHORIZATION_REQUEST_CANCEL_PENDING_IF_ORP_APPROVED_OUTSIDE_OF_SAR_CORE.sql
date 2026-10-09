USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_CANCEL_PENDING_IF_ORP_APPROVED_OUTSIDE_OF_SAR_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_CANCEL_PENDING_IF_ORP_APPROVED_OUTSIDE_OF_SAR_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_REQUEST_CANCEL_PENDING_IF_ORP_APPROVED_OUTSIDE_OF_SAR_CORE](
    @userID                BIGINT    
  , @userGroup             INT  
  , @userRank              INT 
  , @clientID              bigint
  , @patID                 bigint
  , @orpDocID              bigint
  , @createDirectAuthorizationRequestResponse bit
  , @svcAuthStatusConfirmRespCode bigint
  , @validateRec           BIT
  , @MsgNoRec              VARCHAR(1000)
  , @MsgNoEdit             VARCHAR(1000)
)  
AS    
BEGIN    
   
/*************************************************************************************  
 * SERVICE_AUTHORIZATION_REQUEST_CANCEL_PENDING_IF_ORP_APPROVED_OUTSIDE_OF_SAR_CORE */    
/*
 ************************************************************************************/        
     
declare @sarRecIDIn as bigint = null
declare @sarRecIDOut as bigint = 0
declare @spDetailsDelRequest as VARCHAR(8000) = ''

SET NOCOUNT ON    

BEGIN TRY    

if (
      (@createDirectAuthorizationRequestResponse = 0) 
  and (@svcAuthStatusConfirmRespCode = 100)
)
begin
 
 
 /* Find pending request */
 
 select top 1 
   @sarRecIDIn = sar.id 
 from dbo.SERVICE_AUTHORIZATION_REQUESTS as sar
 where ( 
 
   /* For index */
       (sar.clientID = @clientID)
   and (sar.closed = 0)
   and (sar.active = 1)
   and (sar.currentResponseCode = 2000)
   and (sar.id is not null)
 
   /* Included cols */
   and (sar.patID    = @patID)
   and (sar.reqSvcAuthFromSelectionID = 20 ) /* Requests to ORP only */
   and (sar.orpDocID = @orpDocID)  
   )
  
  /* Delete if found */
  
  if (@sarRecIDIn is not null)
  begin
    exec dbo.SERVICE_AUTHORIZATION_REQUEST_DELETE_CORE 
        @userID   
      , @userGroup  
      , @userRank 
      , 'Received approval outside of auth system'
      , @validateRec
      , @sarRecIDIn
      , @MsgNoRec
      , @MsgNoEdit
      , @sarRecIDOut    
      , @spDetailsDelRequest OUTPUT
  end
end

/*============================================================
 * All done, commit changes and get out
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
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_CANCEL_PENDING_IF_ORP_APPROVED_OUTSIDE_OF_SAR_CORE] TO [webuser]
GO
