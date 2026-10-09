USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_MOMENT_FLAG_DEFERRALREASON') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_MOMENT_FLAG_DEFERRALREASON
GO



/*-------------------------------
 * Create 
 *------------------------------*/

    
CREATE PROCEDURE [dbo].[RMTS_MOMENT_FLAG_DEFERRALREASON] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT


  , @clientID          bigint
  , @flagDeferred      bit
  , @deferralReason		 VARCHAR(200)
  --, @deferralDate		 date

  , @deferralReasonNotes		 VARCHAR(max)


  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT

  , @saveType            INT
  , @recID               BIGINT

  , @MsgNoRec            VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @MsgDupRec           VARCHAR(1000)
  , @MsgDataError        VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)

  , @spDetails           VARCHAR(8000) OUTPUT
  , @recordID            BIGINT        OUTPUT )

AS    
BEGIN              
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/

DECLARE @today              AS date       -- Current date/time stamp    
DECLARE @tranOpen           AS BIT            -- Is a transaction open

BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID  = 0    
SET @spDetails = ''    
SET @today     = GETDATE()    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    

IF ( @saveType      != 2 ) RAISERROR ('Save type is undefined',   11, 1)    


/*============================================================
 * Validation
 *============================================================*/

IF ( @flagDeferred = 1)
BEGIN

  IF ( ( SELECT COUNT(*) FROM dbo.RMTS_Moments
        where ([id] = @recID  AND  clientID = @clientID
          AND   isComplete = 1   )
    ) > 0)   RAISERROR ('Cannot defer a moment already marked complete',   11, 1) 

  IF ( ( SELECT COUNT(*) FROM dbo.RMTS_Moments
        where ([id] = @recID  AND  clientID = @clientID
          AND   deferralDate IS NOT NULL   )
    ) > 0)   RAISERROR ('No reason to defer a moment already deferred',   11, 1) 

END
ELSE IF ( @flagDeferred = 0)
BEGIN

  IF ( ( SELECT COUNT(*) FROM dbo.RMTS_Moments
        where ([id] = @recID  AND  clientID = @clientID
          AND   isComplete = 1   )
    ) > 0)   RAISERROR ('Cannot undefer a moment already marked complete',   11, 1) 

  IF ( ( SELECT COUNT(*) FROM dbo.RMTS_Moments
        where ([id] = @recID  AND  clientID = @clientID
          AND   deferralDate IS NULL   )
    ) > 0)   RAISERROR ('No reason to undefer a moment not deferred',   11, 1) 

END
ELSE
BEGIN

  RAISERROR ('Invalid/unspecified flag value',   11, 1)   
 
END

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END        

BEGIN TRANSACTION
SET @TranOpen = 1

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  IF ( @flagDeferred = 1)
    update [dbo].[RMTS_Moments]
    set       
 
	  [deferralReason]         = @deferralReason
  , [deferralReasonNotes]    = @deferralReasonNotes
	, [deferralDate]           = @today
        , [deferredBy]             = @userID

    --, lastModified   = @today
    --, lastModifiedBy = @userID

    where ([id] = @recID  AND  clientID = @clientID )

  ELSE IF ( @flagDeferred = 0)

    update [dbo].[RMTS_Moments]
    set       
 
	  [deferralReason]         = null
	, [deferralDate]           = null
        , [deferredBy]         = null

    , lastModified   = @today
    , lastModifiedBy = @userID

    where ([id] = @recID  AND  clientID = @clientID )
  
  set @recordID = @recID

end


/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RMTS_MOMENT_FLAG_DEFERRALREASON] TO [webuser]
GO
