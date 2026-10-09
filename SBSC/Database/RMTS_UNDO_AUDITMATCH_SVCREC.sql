USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_UNDO_AUDITMATCH_SVCREC') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_UNDO_AUDITMATCH_SVCREC
GO

CREATE PROCEDURE [dbo].[RMTS_UNDO_AUDITMATCH_SVCREC] (
    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    

  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT

  --

  , @recID         BIGINT -- svcrecID   

  , @clientID      BIGINT   --

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

  -- validate --

  select
       @recordID                 = id
       from [dbo].[RMTS_Moments]
       where id = @recID AND clientID = @clientID

 IF ( ISNULL( @recordID, 0) = 0) 
  RAISERROR('Error: item not found.  Cannot unmatch.', 11, 1)

 IF (@validateRec = 1)
   RETURN (0)

BEGIN TRANSACTION

SET @TranOpen = 1;

--

--IF (
--    @uploadedRptType = '15col'
--  )


  UPDATE [dbo].[RMTS_Moments]
  SET [svcRecID] = null,

    [svcrecIsAutoMatched] = 0,
    isComplete = 0,

    mustCorrectThisMistake = 1,

    rmtsReqNextStep = 1,
    rmtsReqState = CASE WHEN rmtsReqState = 1 THEN 2 ELSE 6 END

  WHERE ( id = @recID
    AND clientID = @clientID )
  

IF (@TranOpen  = 1) COMMIT TRANSACTION    

--

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
 
GRANT EXECUTE ON  [dbo].[RMTS_UNDO_AUDITMATCH_SVCREC] TO [webuser]
GO