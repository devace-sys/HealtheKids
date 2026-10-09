USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_MOMENT_REVIEW') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_MOMENT_REVIEW
GO


-- TODO: I don't remember what this SPROC is, as I haven't touched it in forever,
--       but it appears that the @clientID isn't being checked.
--       Let's fix this later.

CREATE PROCEDURE [dbo].[RMTS_MOMENT_REVIEW] (
    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    

  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT

  , @pcalReviewStatus int
  , @pcalReviewSuggestedActivityCode varchar(10)

  , @pcalReviewReason varchar(max)
  
  , @pcalReviewNotes varchar(max)

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

BEGIN TRY

BEGIN TRANSACTION

SET @TranOpen = 1;


  UPDATE [dbo].[RMTS_Moments]
  SET
    pcalReviewStatus = @pcalReviewStatus
  , pcalReviewSuggestedActivityCode = @pcalReviewSuggestedActivityCode

  , pcalReviewReason = @pcalReviewReason
  -- NOTE: neither the original mockup nor the followup instructions indicated what is supposed to pre-fill the Reasons dropdown;
  --       we'll worry about this later...
  --       ... some fine day

  , pcalReviewNotes = @pcalReviewNotes

  WHERE id = @recID



if ( @pcalReviewStatus = 300 )
BEGIN

  declare @spDetailsSaveExternalMsg  varchar(max)
                   , @externalMsgID  bigint

  declare @reason varchar(max), @additionalNotes varchar(max), @externalMsgrecipientUserIDsStr varchar(max), @rmtsClientID bigint

  SELECT
     @reason = pcalReviewReason
   , @additionalNotes = pcalReviewNotes
   , @rmtsClientID = [clientID]
  FROM [RMTS_Moments]
  WHERE id = @recID
 
  SELECT
     @externalMsgrecipientUserIDsStr = STRING_AGG( CAST( [userIDInt] as varchar ), ',' )
  FROM users.[dbo].[USERS_ALL]
  where
    [clientID] = @rmtsClientID
  AND
    userGroupRank = 200 AND roleRank = 9  -- leacoordinator

  declare @outgoingmsg varchar(max) =
   'Reason: ' + @reason + ' Additional Notes: ' + @additionalNotes

  -- NOTE: sometimes automated followup messages are fired off in SPROCs, and sometimes we do it in middleware after a flag or save op.
  --       This needs to be documented better (for example we should always note in the C# comments when the underlying SPROC sends a notif message).
  --       Ideally the dev should comment the underlying engineering decision, why we implemented an automated notif in C# rather than the SPROC,
  --       or vise versa.
  exec users.dbo.USERS_MESSAGES_SAVE_GENERATED
     0
   , 0
   , 0
   , 'spedcare'
   , @externalMsgrecipientUserIDsStr

   , 'RMTS moment marked as incorrect code; appeal possible'
   , @outgoingmsg

   , 0 -- Send email
   , null -- @respPromptOptionsBitwise
   , null -- @respPromptOptionsJSON

   , 1
   , 'user_all_rmts_moment_pcal_review.aspx' -- @gotoUrl
   , 'possible_appeal=1'

   , 1  -- save type
   , 0  -- Rec id
   , @spDetailsSaveExternalMsg output
   , @externalMsgID            output


END




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
 
GRANT EXECUTE ON  [dbo].[RMTS_MOMENT_REVIEW] TO [webuser]
GO