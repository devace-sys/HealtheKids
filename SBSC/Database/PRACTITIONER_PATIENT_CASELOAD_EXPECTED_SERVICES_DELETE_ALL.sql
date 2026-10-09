USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_ALL') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_ALL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_ALL] (
    @userID        BIGINT
  , @userGroup     INT   
  , @userRank      INT
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @clientID      bigint
  , @pracID        bigint
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_ALL */    
/**    
 * Bulk deletes a practitioners entire caseload
 *
 * TODO: Need to add code to delete all recurring scheduled services
 * for caseload.
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @TranOpen     AS BIT    
DECLARE @today        AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT            -- Audit record id    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT    

declare @caseloadEntryID as bigint = null
declare @patID           as bigint = null
declare @maxIdx          as int = 0
declare @curIdx          as int = 0

BEGIN TRY    
   
/*-------------------------------    
 * Init 
 *------------------------------*/    
   
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    
set @TranOpen   = 0   

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',        11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',         11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',       11, 1)    
IF (@clientID    IS NULL) RAISERROR ('Client id is required',        11, 1)    
IF (@pracID      IS NULL) RAISERROR ('Practitioner id is required',  11, 1)    
   

/*-------------------------------    
 * Get all caseload service 
 * entries
 *------------------------------*/    

declare @caseloadData as table (
    idx                       int identity(1,1)
  , caseloadExpectedServiceID bigint
  , caseloadEntryID           bigint
  , patID                     bigint
 unique clustered (idx)
)

insert into @caseloadData (
    caseloadExpectedServiceID
  , caseloadEntryID 
  , patID
)
select 
    caseloadExpectedServiceID = ppces.id
  , ppces.caseloadEntryID
  , ppc.patID
from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces
join dbo.PRACTITIONER_PATIENT_CASELOAD                   as ppc on ppc.id = ppces.caseloadEntryID
where (
      (ppc.clientID = @clientID)
  and (ppc.pracID   = @pracID)
  and (ppces.active = 1)
)

/*-------------------------------    
 * Setup loop
 *------------------------------*/    

select @maxIdx = max(cd.idx) from @caseloadData as cd
set @curIdx = 1

/*-------------------------------    
 * If there is nothing to delete
 * get out
 *------------------------------*/    

if (@maxIdx = 0) return 0

/*-------------------------------    
 * If we are just validating    
 * get out
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
  SET @updateState = dbo.CONST_SVC_REC_STATE_DEL()    

  /*-------------------------------    
   * Deactivate all expected services
   * for this practitioner
   *------------------------------*/    
  
  update ppces
  set 
      ppces.active            = 0
    , ppces.lastModified      = getdate()
    , ppces.lastModifiedBy    = @userID    
  from @caseloadData                                       as cd
  join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces on ((ppces.id = cd.caseloadExpectedServiceID)
                                                                    and (ppces.caseloadEntryID = cd.caseloadEntryID))
  where 
    (ppces.active = 1)  
  
  /*-------------------------------    
   * Delete caseload entries and
   * deactivate any recurring
   * scheduled services for each
   * patient that was on caseload
   *------------------------------*/    
  
  while (@curIdx <= @maxIdx)
  begin

    /* Get patient */

	select top 1 
	    @patID           = cd.patID
	  , @caseloadEntryID = cd.caseloadEntryID 
	from @caseloadData as cd where (cd.idx = @curIdx)
    
	/* Delete caseload entry for this patient */

	exec dbo.PRACTITIONER_CASELOAD_MEMBER_Delete_Core @clientID, @pracID, @patID, @caseloadEntryID, @recordID output    

    /* Deactivate any recurring scheduled services for this patient */
    /* TODO: Refactor PRACTITIONER_CASELOAD_MEMBER_Delete_Core so we can move this logic into it. */

	update dbo.Practitioner_Patient_Scheduled_Services	
	set 
	    lastModified   = @today
	  , lastModifiedBy = @userID	 
	  , active         = 0 
	where (
	      (clientID  = @clientID)
	  and (pracID    = @pracID)
	  and (patID     = @patID)
	  and (recurring = 1)
	  and (active    = 1)
	)

	set @curIdx = @curIdx + 1
  end
  
  set @recordID = @maxIdx

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
   
  SET @ErrorMessage = @ErrorMessage
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_ALL] TO [webuser]
GO
