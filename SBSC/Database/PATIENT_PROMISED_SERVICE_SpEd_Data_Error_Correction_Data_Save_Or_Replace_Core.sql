USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICE_SpEd_Data_Error_Correction_Data_Save_Or_Replace_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PROMISED_SERVICE_SpEd_Data_Error_Correction_Data_Save_Or_Replace_Core
GO
 
CREATE PROCEDURE dbo.PATIENT_PROMISED_SERVICE_SpEd_Data_Error_Correction_Data_Save_Or_Replace_Core (
    @userID                     bigint
  , @userGroup                  INT
  , @userRank                   INT
  , @patID                      bigint
  , @originalspEdServiceCode    int
  , @originalStartDate          date
  , @originalEndDate            date
  , @originalSpEdFreqCode       int
  , @originalMinsPerFreq        int

  , @replacementDataActive      bit
  , @replacementSpEdServiceCode int
  , @replacementSpEdFreqCode    int
  , @replacementMinsPerFreq     int

  , @validateRec                bit    
  , @saveType                   smallint output
  , @spDetails                  varchar (8000) OUTPUT    
  , @recordID                   bigint         OUTPUT)   
AS    
BEGIN    
     
SET NOCOUNT ON    
   
DECLARE @today                     AS DATETIME       -- Current date/time stamp    
 
BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID   = 0    
SET @spDetails  = '' 
SET @today     = GETDATE()   
SEt @saveType  = 0
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/ 
    
IF (@userGroup                     IS NULL) RAISERROR ('userGroup is required',   11, 1)
IF (@userID                        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank                      IS NULL) RAISERROR ('userRank is required',    11, 1)      
if (@patID                         is null) RAISERROR ('Patient id is required',  11, 1)
if (@originalSpEdServiceCode       is null) RAISERROR ('SpEd service code required',  11, 1)
if (@originalSpEdFreqCode          is null) RAISERROR ('SpEd freq code required',  11, 1)
if (@originalStartDate             is null) RAISERROR ('Start date required',  11, 1)
if (@originalEndDate               is null) RAISERROR ('End date required',  11, 1)
if (@originalMinsPerFreq           is null) RAISERROR ('Mins per freq required',  11, 1)
if (@replacementDataActive         is null) RAISERROR ('Replacement data active is required',  11, 1)
IF (@validateRec                   IS NULL) RAISERROR ('Validate flag required',  11, 1)     

/*============================================================
 * Find existing record and set save type
 *============================================================*/  

set @recordID  = 0
set @saveType  = 0

select top 1
  @recordID = isnull(t1.id,0) 
from dbo.PATIENTS_Promised_Services_SpEd_Data_Error_Correction_Data as t1
where ( 
      (t1.patID                   = @patID)
  and (t1.originalSpEdServiceCode = @originalspEdServiceCode)
  and (t1.originalStartDate       = @originalStartDate)
  and (t1.originalSpEdFreqCode    = @originalSpEdFreqCode)
  and (t1.originalMinsPerFreq     = @originalMinsPerFreq)
)

if      (@recordId = 0) set @saveType = dbo.CONST_SAVE_TYPE_NEW()
else if (@recordID > 0) set @saveType = dbo.CONST_SAVE_TYPE_EDIT()
else                    set @saveType = 0

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END                          
 
/*============================================================
 * Save data
 *============================================================*/  
       
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN        
    
  INSERT INTO [dbo].[PATIENTS_Promised_Services_SpEd_Data_Error_Correction_Data]
  (                   
	     patID            
	   , originalSpEdServiceCode
	   , originalStartDate
	   , originalEndDate
	   , originalSpEdFreqCode
	   , originalMinsPerFreq
	   , replacementSpEdServiceCode    
	   , replacementSpEdFreqCode
	   , replacementMinsPerFreq
	   , created
	   , createdBy
	   , active
    )    
    VALUES    
    (  
     	 @patID            
	   , @originalSpEdServiceCode
	   , @originalStartDate
	   , @originalEndDate
	   , @originalSpEdFreqCode
	   , @originalMinsPerFreq
	   , @replacementSpEdServiceCode    
	   , @replacementSpEdFreqCode
	   , @replacementMinsPerFreq
	   , @today
	   , @userID
	   , @replacementDataActive
    )      
    
    SET @recordID = SCOPE_IDENTITY()    
END         
  
ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN    
      
    update [dbo].[PATIENTS_Promised_Services_SpEd_Data_Error_Correction_Data]
    set                  
	     replacementSpEdServiceCode = @replacementSpEdServiceCode    
	   , replacementSpEdFreqCode    = @replacementSpEdFreqCode
	   , replacementMinsPerFreq     = @replacementMinsPerFreq
	   , active                     = @replacementDataActive
	   , lastModified               = @today
	   , lastModifiedBy             = @userID
    where (id = @recordID)        
  END    
ELSE    
BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
END    
             
/*-------------------------------    
 * If we reach this point    
 * everything is OK exit    
 *------------------------------*/    
   
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
     
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ''    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.PATIENT_PROMISED_SERVICE_SpEd_Data_Error_Correction_Data_Save_Or_Replace_Core TO webuser
GO