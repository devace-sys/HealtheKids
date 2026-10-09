USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICE_Save_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PROMISED_SERVICE_Save_Core
GO
 
CREATE PROCEDURE dbo.PATIENT_PROMISED_SERVICE_Save_Core (
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
   
DECLARE @today                     AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen                  AS BIT            -- Is a transaction open
declare @fromSpEdDataFiles         as bit = 0

BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID          = 0    
SET @spDetails         = '' 
SET @today             = GETDATE()   

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
if (@patID         is null) RAISERROR ('Patient id is required',  11, 1)
 
/*============================================================
 * Default values
 *============================================================*/  

set @minsPerFreq      = isnull (@minsPerFreq,      1)
set @spEdFreqCode     = isnull (@spEdFreqCode,     90)    /* Default to other */
set @spEdServiceCode  = isnull (@spEdServiceCode,  900)   /* Default to other */
set @spEdProviderCode = isnull (@spEdProviderCode, 100)   /* Default to district of service */
set @spEdLocationCode = isnull (@spEdLocationCode, 510)   /* Default to regular classroom/school */

/*============================================================
 * Sanity checks for patient
 *============================================================*/  

declare @patDob as date = null

select top 1  
  @patDob = pap.DATE_OF_BIRTH
from dbo.PATIENTS_Patient as pap
where (pap.PATIENT_ID = @patID)

if (@patDob is null) RAISERROR ('Invalid patient', 11, 1)

/*============================================================
 * Sanity checks for dates
 *============================================================*/  

if ((@startDate is not null) and (@endDate is not null))
begin
  if (@startDate > @endDate)  RAISERROR ('Start date cannot be after end date', 11, 1)
end

if (@startDate is not null)
begin
 if (@startDate < @patDob)
 begin
   RAISERROR ('Start date cannot be before patients date of birth',  11, 1)
 end
end

if (@endDate is not null)
begin
 if (@endDate < @patDob)
 begin
   RAISERROR ('End date cannot be before patients date of birth',  11, 1)
 end
end

/*============================================================
 * Lookup record
 *============================================================*/  

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN    

  set @recordID          = 0
  set @fromSpEdDataFiles = 0

  select top 1 
      @recordID          = isnull(pps.id,0)
    , @fromSpEdDataFiles = isnull(pps.fromSpEdDataFiles,0)	
  from dbo.PATIENTS_Promised_Services as pps
  where (
    (pps.id = @recID)
  )
  
  if (@recordID = 0)
  begin
    RAISERROR ('Record not found',  11, 1)
  end

END
  
/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END                          
 
     
/*-------------------------------    
 * New record
 *------------------------------*/    
   
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN        
    
  INSERT INTO [dbo].[PATIENTS_Promised_Services]
  (                   
	   patID            
     , spEdServiceCode   
	 , spEdProviderCode  
	 , spEdFreqCode      
	 , spEdLocationCode  
	 , startDate         
	 , endDate           
	 , individualDelivery
	 , groupDelivery    
	 , minsPerFreq       
	 , fromSpEdDataFiles 
     , latestFileRowID 
     , doNotReplace 
	 , created
	 , createdBy
	 , active
  )    
  VALUES    
  (  
       @patID             
	 , @spEdServiceCode   
	 , @spEdProviderCode  
	 , @spEdFreqCode      
	 , @spEdLocationCode  
	 , @startDate         
	 , @endDate           
	 , @individualDelivery
	 , @groupDelivery     
	 , @minsPerFreq 
	 , 0             /* From SpEd data file*/
	 , 0             /* Latest file row ID */
	 , 1             /* Do not replace */
	 , @today
     , @userID
	 , 1         
   )      
    
  SET @recordID = SCOPE_IDENTITY()    
END           

/*-------------------------------    
 * Edit existing record    
 *------------------------------*/    

ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN    
   
   
  /* Only allow full edit for pps that is not from sped data files */
 	                   
  if (@fromSpEdDataFiles = 0)
  begin
       
    
    UPDATE [dbo].[PATIENTS_Promised_Services]
    SET 
        patID              = @patID             
      , spEdServiceCode    = @spEdServiceCode   
      , spEdProviderCode   = @spEdProviderCode  
      , spEdFreqCode       = @spEdFreqCode      
      , spEdLocationCode   = @spEdLocationCode  
      , startDate          = @startDate         
      , endDate            = @endDate           
      , individualDelivery = @individualDelivery
      , groupDelivery      = @groupDelivery     
      , minsPerFreq        = @minsPerFreq 
	  , lastModified       = @today
      , lastModifiedBy     = @userID
     where ([id]  = @recID)
  end
  else
  begin
  	   
	 /*-------------------------------    
      * This was from a student data 
	  * file so only make a note of
	  * the last modified values 
      *------------------------------*/    
 
	 UPDATE [dbo].[PATIENTS_Promised_Services]
     SET 
		lastModified       = @today
      , lastModifiedBy     = @userID
     where ([id]  = @recID)
	 
	 set @recordID = @recid	  
	 
	/*-------------------------------    
     * Get the stored svc terms
	 * Note: We do this because the
	 * user might have attempted to 
	 * change the svc term values
	 * even though if we are in this
	 * edit mode, those changes are
	 * not saved.
     *------------------------------*/    

	select top 1 
	     @spEdServiceCode = pps.spEdServiceCode
	   , @startDate        = pps.startDate
	   , @endDate          = pps.endDate
	   , @spEdFreqCode     = pps.spEdFreqCode
	   , @minsPerFreq      = pps.minsPerFreq
	from dbo.PATIENTS_Promised_Services as pps
	where 
	  (pps.id = @recID)
      
	/*-------------------------------    
     * Save or replace correction data
     *------------------------------*/    
 
    declare @saveTypeOut  as smallint 
    declare @spDetailsOut as varchar(8000)
    declare @recordIDOut  as bigint
 
    exec dbo.PATIENT_PROMISED_SERVICE_SpEd_Data_Error_Correction_Data_Save_Or_Replace_Core
        @userID
      , @userGroup
      , @userRank 
      , @patID 
      , @spEdServiceCode 
      , @startDate
      , @endDate 
      , @spEdFreqCode
      , @minsPerFreq
      , @replacementDataActive
      , @replacementSpEdServiceCode
      , @replacementSpEdFreqCode
      , @replacementMinsPerFreq 
      , @validateRec    
      , @saveTypeOut  output
      , @spDetailsOut output    
      , @recordIDOut  output   

    end    
END    
ELSE    
BEGIN    
  RAISERROR ('Unknown save type', 11, 1)    
END    

       
/*-------------------------------    
 * If we reach this point    
 * everything is OK.  Exit    
 *------------------------------*/    
   
RETURN(0)    
END TRY 

BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong. Return any    
   * error messages to the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
          
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
 
GRANT EXECUTE ON  dbo.PATIENT_PROMISED_SERVICE_Save_Core TO webuser
GO