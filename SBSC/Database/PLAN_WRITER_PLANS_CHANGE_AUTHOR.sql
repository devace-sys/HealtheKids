USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_CHANGE_AUTHOR') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PLAN_WRITER_PLANS_CHANGE_AUTHOR
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[PLAN_WRITER_PLANS_CHANGE_AUTHOR] (
    @userID              BIGINT    
  , @userGroup           INT    
  , @userRank            INT
  , @clientID            BIGINT
  , @newPlanAuthorUserID BIGINT
  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT
  , @recID               BIGINT
  , @MsgNoRec            VARCHAR(1000)   
  , @MsgNoEdit           VARCHAR(1000)
  , @spDetails           VARCHAR(8000) OUTPUT
  , @recordID            BIGINT        OUTPUT
)    
AS    
BEGIN    
 
/***************************************************************************    
 * PLAN_WRITER_PLANS_CHANGE_AUTHOR */    
/**    
 *    
 ***************************************************************************/        
 
SET NOCOUNT ON    
 
DECLARE @tranOpen     AS BIT    
DECLARE @today        AS DATETIME          -- Current date/time stamp    
 
BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
SET @recordID    = 0    
SET @spDetails   = ''    
SET @today       = GETDATE()    
 
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
 
IF (@userGroup           is null) RAISERROR ('userGroup is required',       11, 1)    
IF (@userRank            is null) RAISERROR ('userRank is required',        11, 1)    
IF (@clientID            is null) RAISERROR ('Client id is required',       11, 1)    
IF (@newPlanAuthorUserID is null) RAISERROR ('New plan userID is required', 11, 1)
IF (@validateRec         is null) RAISERROR ('Validate flag required',      11, 1)    
IF (@recID               is null) RAISERROR ('updateRecID is required',     11, 1)    

/*-------------------------------    
 * Find record
 *------------------------------*/    

set @recordID = 0
 
select top 1 
  @recordID = isnull(pwp.ID,0)
from dbo.PLAN_WRITER_PLANS as pwp
where (
      (pwp.ID        = @recID) 
  and (pwp.CLIENT_ID = @clientID) 
  and (pwp.ACTIVE    = 1)
)


/*-------------------------------    
 * Not found, get out
 *------------------------------*/    

if (@recordID = 0) return 0

/*-------------------------------    
 * Check if user exists and is
 * related to client
 *------------------------------*/    

if not exists (
  select 
    top 1 1 
  from users.dbo.USERS_ALL as ua
  where ( 
      (ua.clientID = @clientID)
  and (ua.userIDInt = @newPlanAuthorUserID)
  )
)
begin
  RAISERROR ('User not found', 11, 1)    
end

/*-------------------------------    
 * Validating, get out
 *------------------------------*/    

if (@validateRec = 1) return(0)    
 
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
 
BEGIN TRANSACTION    
 
  SET @TranOpen = 1    
    
  UPDATE dbo.PLAN_WRITER_PLANS
  SET 
      CREATED_BY       = @newPlanAuthorUserID
    , LAST_MODIFIED_BY = @userID
    , LAST_MODIFIED_ON = @today
    , planCreatorSigned       = 0
	, planCreatorSignedDate   = null
	, planCreatorSignatureImg = null	
  WHERE
    (ID = @recordID)

/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
 
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY    
 
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
 
GRANT EXECUTE ON  [dbo].[PLAN_WRITER_PLANS_CHANGE_AUTHOR] TO [webuser]
GO