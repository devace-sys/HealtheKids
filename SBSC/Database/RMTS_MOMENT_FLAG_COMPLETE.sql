USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_MOMENT_FLAG_COMPLETE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_MOMENT_FLAG_COMPLETE
GO

CREATE PROCEDURE [dbo].[RMTS_MOMENT_FLAG_COMPLETE] (
    @userID        BIGINT
  , @userGroup     INT
  , @userRank      INT

  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT

  , @recID         BIGINT -- svcrecID

  , @clientID      int

  , @environmentID int  -- NECESSARY FOR DOUBLE_CHECKING FILE UPLOAD STATUS

                           -- and on secondthought, I don't know why we need to check file uploads when flagging complete.
                           -- TODO: look at this later.  If it aint broke...

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

declare @existingRecIsPreComplete int=0;

-- validation

select @existingRecIsPreComplete = isPreComplete ,
       @recordID                 = id
       from [dbo].[RPT_RMTS_MOMENTS_VIEW]
       (
          @userID     ,
          @userGroup  ,
          @userRank   ,

          @recid ,

          @environmentID  ,

          null , -- @fyquarterid   BIGINT,


          null , -- @fyID        int,
          null , -- @quarterNum   int,

          null , -- @activityCode char(10),
          null , -- @matched      bit,
          null , -- @clientID     bigint,

           --
          null , -- @pracID       bigint,   --
           --

          null , -- @isComplete   bit,
          null , -- @pcalReviewStatusCode int ,

          null  -- @isDeferred    bit
       )
       where id = @recID AND clientID = @clientID       --  AND isPreComplete = 1



IF ( ISNULL( @recordID, 0) = 0)
  RAISERROR('Error: item not found.  Cannot mark this item as complete', 11, 1)


IF ( ISNULL(@existingRecIsPreComplete, 0) != 1)
  RAISERROR('Not ready to mark complete; cannot mark this item as complete', 11, 1)


BEGIN TRANSACTION

SET @TranOpen = 1;

--IF (
--    @uploadedRptType = '15col'
--  )
  UPDATE [dbo].[RMTS_Moments]
  SET

   [isComplete] = 1,
   mustCorrectThisMistake = 0,
   rmtsReqNextStep = 3

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

GRANT EXECUTE ON  [dbo].[RMTS_MOMENT_FLAG_COMPLETE] TO [webuser]
GO
