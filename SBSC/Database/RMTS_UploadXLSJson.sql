USE SPEDMON
GO



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_UploadXLSJson') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_UploadXLSJson
GO

CREATE PROCEDURE [dbo].[RMTS_UploadXLSJson] (
    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    
  , @clientID      INT
  , @notes         VARCHAR(max)

  , @quarterID     int


  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT  
  , @recID         BIGINT    
  , @msgDupRec          VARCHAR(1000)    

  , @MsgNoRec           VARCHAR(1000)     
  , @MsgNoEdit          VARCHAR(1000)     
  , @MsgDataError       VARCHAR(1000)    

  , @MsgNotActive       VARCHAR(1000)

  , @spDetails          VARCHAR(8000) OUTPUT
  , @recordID           BIGINT        OUTPUT)    
AS    
BEGIN     
     
SET NOCOUNT ON    

declare @today             as datetime
set @today                     = getdate()
set @spDetails                 = ''
set @recordID                  = 0

declare @TranOpen bit = 0


IF (@clientID   IS NULL) RAISERROR ('clientID is required',   11, 1)
IF (@notes   IS NULL) RAISERROR ('content is required',   11, 1)
IF (@quarterID   IS NULL) RAISERROR ('FY quarter is required',   11, 1)


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
)
SELECT
	  @clientID
	, @quarterID
	, 'unknown file name' /* TODO */
	, @notes
	, 'unknown vendor' /* TODO */
	, 0 -- matchingToSvcRecsComplete
	, @today
	, @userID
	, 1 -- active

set @recordID = SCOPE_IDENTITY()

BEGIN TRANSACTION

SET @TranOpen = 1;

exec [dbo].[RMTS_SERVICE_RECORD_AUTOMATCH_HEURISTIC] @clientID, @quarterID, @recordID, @userID

IF (@TranOpen  = 1) COMMIT TRANSACTION 

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
 
GRANT EXECUTE ON  [dbo].[RMTS_UploadXLSJson] TO [webuser]
GO