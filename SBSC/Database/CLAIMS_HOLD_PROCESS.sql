USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_HOLD_PROCESS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIMS_HOLD_PROCESS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLAIMS_HOLD_PROCESS] (
   @today         as DATETIME
 , @userID        as bigint   = 0    
 , @clientID      as bigint   = null
 , @oldestDOS     as DATETIME
 , @newestDOS     as datetime
 , @validate      as BIT   = 1)
     
AS    

BEGIN     
    
/***************************************************************************    
 * CLAIMS_HOLD_PROCESS */    
/**    
 * Processes claims that need to be held.
 * 
 * @param   today           Todays date
 * @param   userID          The userID of who is running this  
 * @param   clientID        Client ID you wish to work with or null for all
 * @param   oldestDOS       Earliest date of service to work with
 * @param   validate        0 = Return counts and process records
 *                          1 = Just return counts
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE @msg        AS VARCHAR(1000)
DECLARE @recCount   AS INT

declare @claimsToHold as table (
    svcRecID bigint
  , minBased bit
  , mileBased bit
  , claimID1 bigint
  , claimID2 bigint
)

BEGIN TRY    
    
/*============================================================
 * Display client name
 *============================================================*/  

SET @msg = ''
select top 1 @msg = CLIENT_NAME from dbo.CLIENTS_CLIENT   as clc where clc.CLIENT_ID  = @clientID
RAISERROR (@msg, 0, 1) WITH NOWAIT 

/*============================================================
 * Starting
 *============================================================*/  
    
RAISERROR ('Holding claims', 0, 1) WITH NOWAIT

SET @msg        = ''
SET @recCount   = 0

/*============================================================
 * Get claims to hold
 *
 * Note: This list is limited to services that have claims and
 * have not been submitted yet and for where we can submit the
 * claim.  This list also includes services that require
 * a supervising practitoner to approve.
 *============================================================*/  

RAISERROR ('Determining how many claims need to be considered for hold or aggregation', 0, 1) WITH NOWAIT


insert into @claimsToHold
select
    svcRecID 
  , minBased
  , mileBased
  , claimID1
  , claimID2
from dbo.CLAIMS_TO_HOLD_VIEW_CORE (@clientID,@oldestDOS,@newestDOS)

/*============================================================
 * Get and report count
 *============================================================*/  

SET @recCount    = 0
SELECT @recCount = isnull(COUNT(svcRecID),0) from @claimsToHold
SET @msg = 'There are ' + CONVERT(varchar(50),@recCount) + ' services with claims that need to be considered for holding or aggregation'
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*============================================================
 * If there are no records, get out
 *============================================================*/   

IF (@recCount = 0) 
BEGIN
  RAISERROR ('Nothing to do.', 0, 1) WITH NOWAIT
  GOTO getout
END

/*============================================================
 * If we are validating get out
 *============================================================*/   
 
IF (@validate = 1)
BEGIN
  GOTO getout
END

/*============================================================
 * Hold claims 
 *============================================================*/    

RAISERROR ('Setting hold flag on applicable claim records', 0, 1) WITH NOWAIT

/*--------------------------------------
 * Claim 1
 *-------------------------------------*/

update dbo.CLAIM_Claim
set 
  LAST_UPDATED = @today,
  HOLD         = 1 
where CLAIM_ID in (select claimID1 as CLAIM_ID from @claimsToHold where (claimID1 is not null))

/*--------------------------------------
 * Claim 2
 *-------------------------------------*/

update dbo.CLAIM_Claim
set 
  LAST_UPDATED = @today,
  HOLD         = 1 
where CLAIM_ID in (select claimID2 as CLAIM_ID from @claimsToHold where (claimID2 is not null))

/*============================================================
 * Early exit point
 *============================================================*/    

getout:

/*============================================================
 * Done
 *============================================================*/  

RAISERROR ('Done', 0, 1) WITH NOWAIT
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
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CLAIMS_HOLD_PROCESS] TO [webuser]
GO
