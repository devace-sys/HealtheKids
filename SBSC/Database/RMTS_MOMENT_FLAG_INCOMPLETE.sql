USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_MOMENT_FLAG_INCOMPLETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_MOMENT_FLAG_INCOMPLETE
GO

CREATE PROCEDURE [dbo].[RMTS_MOMENT_FLAG_INCOMPLETE] (
    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    

  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT

  , @recID         BIGINT -- svcrecID   

  --  , @clientID  bigint

  -- TODO! This SPROC is called only from the work-in-progress, abandoned maintenance screen.
  --       This will probably need to be checked by @clientID if this SPROC ever gets put back into usage...
  --       actually it shouldn't, because we're using the UNMATCH sproc instead.

  --      Actually, maybe we need a way to un-flag an item as complete, since its getting flagged automatically
  --      upon fileupload, as per Chuck.  But what if somebody uploads a bad/irrelevant file?  Untested edge case.
  --      Surely the admin will eventually need an option to unflag it.

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

BEGIN TRY

BEGIN TRANSACTION

SET @TranOpen = 1;

--IF (
--    @uploadedRptType = '15col'
--  )


  UPDATE [dbo].[RMTS_Moments]
  SET
    [svcRecID] = null,
    [svcrecIsAutoMatched] = 0,
    [isComplete] = 0,
    rmtsReqNextStep = 1

  WHERE id = @recID

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
 
GRANT EXECUTE ON  [dbo].[RMTS_MOMENT_FLAG_INCOMPLETE] TO [webuser]
GO