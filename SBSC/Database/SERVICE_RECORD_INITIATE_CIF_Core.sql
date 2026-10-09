USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_INITIATE_CIF_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_INITIATE_CIF_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_INITIATE_CIF_Core]     
 (@userID            BIGINT,    
  @userGroup         INT,    
  @userRank          INT,    
  @editDelReason     VARCHAR(7000),    
  @validateRec       BIT,
  @clientID          INT,    
  @recID             INT,
  @today             DATETIME,    
  @spDetails         VARCHAR(8000) OUTPUT,    
  @recordID          BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_INITIATE_CIF_Core */    
/**    
 *
 * NOTE: You MUST call this sproc within the context of a transaction from
 *       another sproc.  Do not use this sproc directly!
 *
 * Deletes (hides) an existing service record    
 * and manages any associated claim records.    
 *
 *    
 * @param   userID          The userid of who saved the record    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recID           Record id of existng service record to edit or    
 *                          delete.  
 * @param   today           Current date/time  
 * @param   MsgNoRec        Desired error message for edit/delete service record    
 *                          operations when record is not found    
 * @param   MsgNoEdit       Desired error message for edit/delete service record    
 *                          operations if the service record cannot be edited or     
 *                          deleted     
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE @TranOpen     AS BIT    
DECLARE @tempRecID    AS INT            -- Used for determining if a rec exists    
DECLARE @auditRecID   AS BIGINT         -- Audit record id    
DECLARE @recUserID    AS BIGINT    
DECLARE @canEdit      AS BIT    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT     
DECLARE @srState      as INT
    
BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @saveType   = dbo.CONST_SAVE_TYPE_EDIT()    
SET @recordID   = 0    
SET @spDetails  = ''    
    
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
    
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)    
    
/*-------------------------------    
 * See if the record can be     
 * modified
 *------------------------------*/    
     
SET @recordID = null    
SET @canEdit  = 0    
      
select top 1
    @recordID     = sr.id
  , @srState      = sr.state
  , @canEdit      = (case when (sr.state = dbo.CONST_SVC_REC_STATE_SUB()) then 1 else 0 end)
from dbo.SERVICE_RECORDS as sr
where (
      (sr.id = @recID) 
  and ((@clientID is null) or (sr.clientID = @clientID))
)
      
/*-------------------------------    
 * If there are any problems    
 * let the user know    
 *------------------------------*/    
    
IF (@recordID IS NULL) 
BEGIN
  RAISERROR ('Service record not found',  11, 1) -- Record not found     
END
ELSE
BEGIN
  IF (@canEdit = 0)      
  BEGIN
    if      (@srState = dbo.CONST_SVC_REC_STATE_NEW()) RAISERROR ('Service record has not been submitted for claims yet.  Delete the service record.', 11, 1)
    else if (@srState = dbo.CONST_SVC_REC_STATE_MOD()) RAISERROR ('Service record has not been submitted for claims yet.  Delete the service record.', 11, 1)
    else if (@srState = dbo.CONST_SVC_REC_STATE_DEL()) RAISERROR ('Service record has been deleted.', 11, 1)
    else if (@srState = dbo.CONST_SVC_REC_STATE_CIF()) RAISERROR ('Service record has already been requested for CIF', 11, 1)
    else RAISERROR ('Service record can not be modified', 11, 1)
  END
END

/*-------------------------------    
 * If we are just validating     
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
        
/*-------------------------------    
 * Mark existing service    
 * record as being CIFd
 *------------------------------*/    
      
SET @updateState = dbo.CONST_SVC_REC_STATE_CIF()    

UPDATE dbo.SERVICE_RECORDS     
SET     
  lastmodified  = @today,    
  state         = @updateState     
WHERE (id = @recordID)    
           
/*-------------------------------    
 * Put related claims on the
 * do not resubmit list
 *------------------------------*/    

declare @claimsToNotResub as table (
  CLAIM_ID bigint
)

/* Get claims from service record claims */

insert into @claimsToNotResub
select 
  clm.CLAIM_ID 
from dbo.SERVICE_RECORD_CLAIMS as src
join dbo.CLAIM_Claim           as clm on clm.CLAIM_ID = src.claimID
where (src.svcRecID = @recordID)

/* Get any related proxy claims */

insert into @claimsToNotResub
select distinct
  CLAIM_ID = clm.REFERENCE_CLAIM_ID_1
from @claimsToNotResub as cnr
join dbo.CLAIM_Claim   as clm on clm.CLAIM_ID = cnr.CLAIM_ID
where (
      (clm.HAS_PROXY = 1) 
  and (clm.IS_PROXY = 0)
)

/* Remove any claims that have already been added to the list before */

delete cnr 
from @claimsToNotResub               as cnr
join dbo.CLAIMS_LIST_DO_NOT_RESUBMIT as cldnr on cldnr.claim_id = cnr.CLAIM_ID

/* Finally add to the permanent list */

insert into dbo.CLAIMS_LIST_DO_NOT_RESUBMIT 
select 
    claim_id = cnr.CLAIM_ID
  , added    = @today 
from @claimsToNotResub as cnr

/*-------------------------------    
 * Create audit record    
 *------------------------------*/    
       
EXEC SERVICE_RECORD_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT
       

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
    
  ---IF @tranOpen = 1 ROLLBACK TRANSACTION    
    
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

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_INITIATE_CIF_Core] TO [webuser]
GO
