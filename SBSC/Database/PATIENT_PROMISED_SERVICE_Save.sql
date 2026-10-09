USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICE_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PROMISED_SERVICE_Save
GO
 
CREATE PROCEDURE dbo.PATIENT_PROMISED_SERVICE_Save (
    @userID                     BIGINT
  , @userGroup                  INT
  , @userRank                   INT
  , @patID                      bigint
  , @spEdServiceCode            int
  , @spEdProviderCode           int
  , @spEdFreqCode               int
  , @spEdLocationCode           int
  , @startDate                  date
  , @endDate                    date
  , @individualDelivery         bit
  , @groupDelivery              bit
  , @minsPerFreq                int
  , @replacementDataActive      bit
  , @replacementSpEdServiceCode int
  , @replacementSpEdFreqCode    int
  , @replacementMinsPerFreq     int
  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT    
  , @recID               BIGINT
  , @MsgNoRec            VARCHAR(1000)   
  , @MsgDupRec           VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)
  , @MsgDataError        VARCHAR(1000)
  , @saveType            smallint
  , @spDetails           VARCHAR(8000) OUTPUT    
  , @recordID            BIGINT        OUTPUT)   
AS    
BEGIN    
     
SET NOCOUNT ON    
   
DECLARE @tranOpen AS BIT = 0 

BEGIN TRY    
   
/*-------------------------------    
 * Init 
 *------------------------------*/    
   
SET @recordID  = 0    
SET @spDetails = '' 
set @tranOpen  = 0

begin transaction
set @tranOpen = 1

  exec dbo.PATIENT_PROMISED_SERVICE_Save_Core 
      @userID
    , @userGroup 
    , @userRank 
    , @patID 
    , @spEdServiceCode 
    , @spEdProviderCode
    , @spEdFreqCode 
    , @spEdLocationCode
    , @startDate 
    , @endDate 
    , @individualDelivery
    , @groupDelivery  
    , @minsPerFreq 
    , @replacementDataActive 
    , @replacementSpEdServiceCode
    , @replacementSpEdFreqCode 
    , @replacementMinsPerFreq  
    , @editDelReason  
    , @validateRec 
    , @recID  
    , @MsgNoRec 
    , @MsgDupRec
    , @MsgNoEdit
    , @MsgNotActive 
    , @MsgDataError 
    , @saveType 
    , @spDetails OUTPUT    
    , @recordID  OUTPUT
       
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
   
commit transaction   
set @tranOpen = 0    
return(0)
    
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
     
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ''    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.PATIENT_PROMISED_SERVICE_Save TO webuser
GO