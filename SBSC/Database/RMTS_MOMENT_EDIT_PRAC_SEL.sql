USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_MOMENT_EDIT_PRAC_SEL') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_MOMENT_EDIT_PRAC_SEL
GO

CREATE PROCEDURE [dbo].[RMTS_MOMENT_EDIT_PRAC_SEL] (
    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    
  , @clientID      INT

  , @pracID        BIGINT


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

declare @foundPracID bigint, @pracUserID  bigint ;

SELECT  @foundPracID = p_p.PRACTITIONER_ID, @pracUserID = p_p.UserID
       FROM PRACTITIONER_Practitioner  p_p
       JOIN PRACTITIONER_Client        p_c  ON p_p.PRACTITIONER_ID = p_c.PRACTITIONER_ID
       WHERE  p_p.PRACTITIONER_ID = @pracID AND p_c.CLIENT_ID = @clientID

IF ( @foundPracID  IS  NULL   )
	   RAISERROR('Practitioner Not Found', 11, 1);

SELECT  @recordID = r_m.id
       FROM RMTS_Moments r_m
       WHERE r_m.id = @recID  AND  r_m.clientID = @clientID

IF ( ISNULL(@recordID,0) = 0   )
	   RAISERROR('Rmts Moment Not Found', 11, 1);

declare @TranOpen bit = 0

IF (@validateRec = 1) RETURN;

BEGIN TRY

BEGIN TRANSACTION

SET @TranOpen = 1;

  UPDATE  RMTS_Moments
    SET   PracID = @pracID ,
	      pracUserID = @pracUserID
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
 
GRANT EXECUTE ON  [dbo].[RMTS_MOMENT_EDIT_PRAC_SEL] TO [webuser]
GO