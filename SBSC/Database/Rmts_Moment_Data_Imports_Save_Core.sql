USE SPEDMON
GO



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Rmts_Moment_Data_Imports_Save_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Rmts_Moment_Data_Imports_Save_Core
GO

CREATE PROCEDURE [dbo].[Rmts_Moment_Data_Imports_Save_Core] (
    @userID                  BIGINT
  , @userGroup               INT
  , @userRank                INT
  , @clientID                BIGINT
  , @fyQuarterID             BIGINT
  , @structuredDataImportID  BIGINT
  , @spDetails               VARCHAR(8000) OUTPUT
  , @recordID                BIGINT        OUTPUT)    
AS    
BEGIN     
     
SET NOCOUNT ON    

/*-------------------------------    
 * declare variables
 *------------------------------*/ 

declare @today             as datetime
declare @fileContentJSON   as varchar(max)

set @today                     = getdate()
set @spDetails                 = ''
set @recordID                  = 0

declare @TranOpen bit = 0

/*-------------------------------    
 * Preload worker variables
 * from data import table
 *------------------------------*/ 

select 
    @fileContentJSON = isnull(fileData.fileContentJSON, '[]')
from dbo.Structured_Data_Imports as sdi
outer apply
	OpenJson(sdi.importDataJSON)
	WITH (
		fileContentJSON  NVARCHAR(MAX) '$."structuredDataRows"'  AS JSON
	)
as fileData
where sdi.id = @structuredDataImportID

IF (@clientID   IS NULL) RAISERROR ('clientID is required',   11, 1)
IF (@fileContentJSON   IS NULL) RAISERROR ('content is required',   11, 1)
IF (@fyQuarterID   IS NULL) RAISERROR ('FY quarter is required',   11, 1)


BEGIN TRY

INSERT INTO [dbo].[RMTS_Moments_Data_Imports]
(
	  clientID					
	, quarterID					
	, [fileName]			    
	, fileContentJSON			
	, vendor					
	, matchingToSvcRecsComplete	
	, created					
	, createdBy								
	, active 
	, structuredDataImportID					
)
SELECT
	  @clientID
	, @fyQuarterID
	, 'unknown file name' /* TODO */
	, @fileContentJSON
	, 'unknown vendor' /* TODO */
	, 0 -- matchingToSvcRecsComplete
	, @today
	, @userID
	, 1 -- active
	, @structuredDataImportID

set @recordID = SCOPE_IDENTITY()

BEGIN TRANSACTION

SET @TranOpen = 1;

exec [dbo].[RMTS_SERVICE_RECORD_AUTOMATCH_HEURISTIC] @clientID, @fyQuarterID, @recordID, @userID

IF (@TranOpen  = 1) COMMIT TRANSACTION 

set @spDetails = @fileContentJSON

/*-------------------------------    
 * And we are done
 *------------------------------*/  

SET @TranOpen = 0    
RETURN(0)    

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
  
  -- Error or raise error with severity 11 to 19 will be caught here    
    
  /*-------------------------------    
   * Cancel any pending    
   * transactions  
   *------------------------------*/    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    


  /*-------------------------------    
   * Identify error
   *------------------------------*/    
  
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage 
      
 /*-------------------------------    
   * Return the error message to
   * the caller. 
   *------------------------------*/    
 
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[Rmts_Moment_Data_Imports_Save_Core] TO [webuser]
GO