USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_DELETE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_DELETE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_REQUEST_DELETE_CORE] (
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
 * SERVICE_AUTHORIZATION_REQUEST_DELETE_CORE */
/**    
 * Note: This sproc is not meant to be stand alone.  Call this sproc 
 * from within a transaction block
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
BEGIN TRY 

/*============================================================
 * Init
 *============================================================*/  

declare @today                         as datetime = null
declare @requestID                     as bigint   = null
declare @clientID                      as bigint   = null
declare @patID                         as bigint   = null
declare @pracID                        as bigint   = null
declare @orpPracID                     as bigint   = null
declare @svcStartDate                  as date     = null
declare @reqSvcAuthFromSelectionID     as bigint   = null
declare @svcAuthorizationRequestTypeID as bigint   = null
declare @referencedEntityID            as bigint   = null
declare @orpDocID                      as bigint   = null

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

    @requestID                     = sar.id
  , @clientID                      = sar.clientID
  , @patID                         = sar.patID
  , @pracID                        = sar.pracID
  , @orpPracID                     = sar.orpPracID
  , @svcStartDate                  = sar.svcStartDate 
  , @reqSvcAuthFromSelectionID     = sar.reqSvcAuthFromSelectionID
  , @svcAuthorizationRequestTypeID = sar.svcAuthorizationRequestTypeID
  , @referencedEntityID            = sar.referencedEntityID
  , @orpDocID                      = sar.orpDocID

from dbo.SERVICE_AUTHORIZATION_REQUESTS as sar
where (
      (sar.id = @recID)
  and (sar.closed  = 0)
  and (sar.active  = 1)
)

/*============================================================
 * If a record was found and we are not performing validation 
 * only then proceed with "delete" operation (cancel and close)
 *============================================================*/  

if ((@requestID is not null) and (@validateRec = 0))
begin

  /*-------------------------------    
   * Add status log entry to indicate
   * request was cancelled
   *------------------------------*/    
  
  exec dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS @requestID, @today, @userID, 1100, null
	
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
    , active  = 0
  where (id = @requestID)

/*============================================================
 * Save confirmation status as CANCELLED (if applicable)
 *
 * Note:
 *
 * SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE 
 * will determine if the status should be saved or not
 *============================================================*/  

declare @statusConfirmationRuleIDApplied          bigint  
declare @createDirectAuthorizationRequestResponse bit     
declare @confirmStatusRecordID                    as bigint

exec dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE 
    @clientID
  , @patID
  , @pracID
  , @orpPracID
  , @today
  , @today
  , 400  /* Cancelled */
  , @reqSvcAuthFromSelectionID
  , @svcAuthorizationRequestTypeID
  , @referencedEntityID
  , @orpDocID
  , @requestID /*@serviceAuthorizationRequestID*/
  , 15        /*@entrySourceCode */
  , @today
  , @userID
  , @statusConfirmationRuleIDApplied          OUTPUT
  , @createDirectAuthorizationRequestResponse OUTPUT /* Should NEVER be 1 in this context */
  , @confirmStatusRecordID                    OUTPUT
   
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

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_DELETE_CORE] TO [webuser]
GO
