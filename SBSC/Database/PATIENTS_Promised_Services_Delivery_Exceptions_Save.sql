USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_Promised_Services_Delivery_Exceptions_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENTS_Promised_Services_Delivery_Exceptions_Save
GO
 
CREATE PROCEDURE dbo.PATIENTS_Promised_Services_Delivery_Exceptions_Save (
    @userID                          int
  , @userGroup                       int
  , @userRank                        int
  , @clientID                        bigint
  , @patID                           bigint
  , @svcTrackingClass                int          
  , @spEdServiceCode                 int          
  , @orpDocStandardSelectionNameID   int  
  , @planStartDate                   date 
  , @planEndDate                     date 
  , @spEdFreqCode                    int  
  , @minsPerFreq                     int  
  , @dosStart                        datetime 
  , @dosEnd                          datetime 
  , @numMinsMissing                  int  
  , @deliveryExceptionAddedReasonID  int
  , @deliveryExceptionAddedNotes     varchar(max)              
  
  , @editDelReason       varchar(7000)
  , @validateRec         bit    
  , @recID               bigint
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
   
DECLARE @today     AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen  AS BIT = 0        -- Is a transaction open
 
BEGIN TRY    
   
/*============================================================
 * Init
 *============================================================*/  

/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID   = 0    
SET @spDetails  = '' 
SET @today      = GETDATE()   
set @tranOpen   = 0   

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
if (@clientID      is null) RAISERROR ('Client id is required',  11, 1)
if (@patID         is null) RAISERROR ('Patient id is required',  11, 1)
 
/*============================================================
 * Validation
 *============================================================*/  

declare @datesAreOk as bit = 0

select @datesAreOk = dbo.[DATES_HAVE_OVERLAP](  @planStartDate
                                              , @planEndDate
							                  , @dosStart
							                  , @dosEnd,1,1,0)
if (@datesAreOk = 0)
begin
  RAISERROR ('Plan dates and service dates must overlap', 11, 1)
end

if (@numMinsMissing <=0) 
begin
  RAISERROR ('Number of minutes must be greater than 0',  11, 1)
end

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END                          
 
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  /*-------------------------------    
   * New record
   *------------------------------*/    
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN        
    
    INSERT INTO [dbo].[PATIENTS_Promised_Services_Delivery_Exceptions] (                   
	    clientID
      , patID 
      , svcTrackingClass
      , spEdServiceCode 
      , orpDocStandardSelectionNameID
      , planStartDate
      , planEndDate 
      , spEdFreqCode
      , minsPerFreq
      , dosStart
      , dosEnd
      , numMinsMissing 
      , deliveryExceptionAddedReasonID 
      , deliveryExceptionAddedNotes
      , created
	  , createdBy
	  , active
    )    
    VALUES (  
	    @clientID
      , @patID 
      , @svcTrackingClass
      , @spEdServiceCode 
      , @orpDocStandardSelectionNameID
      , @planStartDate
      , @planEndDate 
      , @spEdFreqCode
      , @minsPerFreq
      , @dosStart
      , @dosEnd
      , @numMinsMissing 
      , @deliveryExceptionAddedReasonID 
      , @deliveryExceptionAddedNotes
      , @today
	  , @userID
	  , 1
    )      
    
    SET @recordID = SCOPE_IDENTITY()    
  END           
  ELSE    
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
      
       
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
     
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ''    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.PATIENTS_Promised_Services_Delivery_Exceptions_Save TO webuser
GO