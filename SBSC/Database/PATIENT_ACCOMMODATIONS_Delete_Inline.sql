USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_ACCOMMODATIONS_Delete_Inline') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_ACCOMMODATIONS_Delete_Inline
GO
 
CREATE PROCEDURE dbo.PATIENT_ACCOMMODATIONS_Delete_Inline (
    @userID              BIGINT
  , @userGroup           INT
  , @userRank            INT
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
IF (@recID         IS NULL) RAISERROR ('Record id is required',   11, 1)    

/*============================================================
 * Lookup record
 *============================================================*/  

set @recordID = 0

select top 1 
    @recordID = isnull(pa.id,0)
from dbo.PATIENTS_Accommodations as pa
where (
  (pa.id = @recID)
)

if (@recordID = 0)
begin
  RAISERROR ('Record not found',  11, 1)
end

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END                          

/*-------------------------------    
 * Delete record    
 *------------------------------*/    

UPDATE [dbo].[PATIENTS_Accommodations]
SET 
    active             = 0
  , lastModified       = @today
  , lastModifiedBy     = @userID
 where ([id]  = @recID)

       
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
 
GRANT EXECUTE ON  dbo.PATIENT_ACCOMMODATIONS_Delete_Inline TO webuser
GO