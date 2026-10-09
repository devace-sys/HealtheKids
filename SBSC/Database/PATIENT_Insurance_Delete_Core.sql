USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_Insurance_Delete_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_Insurance_Delete_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PATIENT_Insurance_Delete_Core] (
      @userID        BIGINT
    , @userGroup     INT   
    , @userRank      INT
    , @editDelReason VARCHAR(7000)
    , @validateRec   BIT
    , @clientID      bigint
    , @recID         INT
	, @today         datetime
    , @MsgNoRec      VARCHAR(1000)
    , @MsgNoEdit     VARCHAR(1000)
    , @spDetails     VARCHAR(8000) OUTPUT
    , @recordID      BIGINT        OUTPUT
 )     
AS    
BEGIN    
              
SET NOCOUNT ON    
   
BEGIN TRY    
       
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    

if (@userID      is null) RAISERROR ('UserID is required',      11,1)
if (@clientID    is null) RAISERROR ('ClientID is required',    11,1)
if (@validateRec is null) RAISERROR ('Validate rec is required',11,1)
IF (@recID       is null) RAISERROR ('recID is required',       11, 1)    

/*-------------------------------    
 * Set defaults
 *------------------------------*/    

if (@today is null) set @today = getdate()          

set @recordID = -1

SELECT top 1
  @recordID = isnull(t1.ID,-1)
FROM dbo.PATIENT_INSURANCE_CARRIERS as t1
where (
  (t1.ID = @recID)
  and
  (t1.clientID = @clientID)
  and
  (t1.active = 1 )
)
   
/*-------------------------------    
 * If no record or already
 * deactivated exit silently
 *------------------------------*/    

if (@recordID = -1)
begin
  set @recordID = @recID
  return
end

/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
  
UPDATE dbo.PATIENT_INSURANCE_CARRIERS
SET   
    active         = 0
  , lastmodified   = @today
  , lastModifiedBy = @userID		
WHERE 
  (ID = @recordID)    
 
/*-------------------------------    
 * If we reach this point    
 * everything is OK    
 *------------------------------*/    
   
RETURN(0)    
END TRY    
   
BEGIN CATCH       
      
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

GRANT EXECUTE ON  [dbo].[PATIENT_Insurance_Delete_Core] TO [webuser]
GO
