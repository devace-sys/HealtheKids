USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_MOMENT_MATCH_SERVICE_RECORD') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_MOMENT_MATCH_SERVICE_RECORD
GO

CREATE PROCEDURE [dbo].[RMTS_MOMENT_MATCH_SERVICE_RECORD] (
    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    
  , @clientID      INT

  , @rmtsReqID     BIGINT

  , @uploadedRptType int  -- TODO: don't think I'm using this anymore, should be removed
                          -- TODO: some fine day...

  , @isPrac        BIT

  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT

  , @recID         BIGINT -- svcrecID   

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

 exec [RMTS_MOMENT_MATCH_SERVICE_RECORD_CORE]
    @userID
  , @userGroup
  , @userRank
  , @clientID

  , @rmtsReqID
  , @uploadedRptType -- TODO: don't think I'm using this anymore, should be removed

  , @isPrac

  , @editDelReason
  , @validateRec
  , @saveType

  , @recID

  , @msgDupRec

  , @MsgNoRec
  , @MsgNoEdit
  , @MsgDataError


  , @MsgNotActive


  , @spDetails          OUTPUT
  , @recordID           OUTPUT  
  


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
 
GRANT EXECUTE ON  [dbo].[RMTS_MOMENT_MATCH_SERVICE_RECORD] TO [webuser]
GO