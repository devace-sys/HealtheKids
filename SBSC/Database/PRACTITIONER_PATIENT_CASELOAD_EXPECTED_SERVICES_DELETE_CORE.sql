USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_CORE] (
    @userID        BIGINT
  , @userGroup     INT   
  , @userRank      INT
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @clientID      bigint
  , @pracID        bigint
  , @recID         INT
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_CORE */    
/**    
 * Delete record and manages any associated records.    
 *    
 * @param   userID          The userid of who saved the record    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT deleting the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recID           Record id of existng Patient to edit or    
 *                          delete.    
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
   
DECLARE @today        AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID   AS BIGINT            -- Audit record id    
DECLARE @saveType     AS INT    
DECLARE @updateState  AS INT    

declare @caseloadEntryID as bigint = null
declare @patID           as bigint = null
declare @numOfRecs       as int    = 0

BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    
   
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
 * Get related caseload entry
 * and other related data
 *------------------------------*/    

select top 1
    @caseloadEntryID = ppces.caseloadEntryID
  , @clientID        = ppc.clientID
  , @pracID          = ppc.pracID
  , @patID           = ppc.patID  
from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces
join dbo.PRACTITIONER_PATIENT_CASELOAD                   as ppc on ppc.id = ppces.caseloadEntryID
where (
      (ppces.id     = @recID)
  and (ppc.clientID = @clientID)
  and (ppc.pracID   = @pracID)
)

/*-------------------------------    
 * Exit if record and related 
 * data not found
 *------------------------------*/    

if (@caseloadEntryID is null) 
begin
  return(0)
end

/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
SET @updateState = dbo.CONST_SVC_REC_STATE_DEL()    
set @recordID = @recID

/*-------------------------------    
 * Deactivate related recurring
 * schedule entries
 *------------------------------*/    

 update dbo.Practitioner_Patient_Scheduled_Services	
 set 
	  lastModified   = @today
    , lastModifiedBy = @userID	 
	, active         = 0 
 where (
        (clientID  = @clientID)
	and (pracID    = @pracID)
    and (patID     = @patID)
	and (practitionerPatientCaseloadExpectedServiceID = @recID)
	and (recurring = 1)  
	and (active    = 1)
  )

  /*-------------------------------    
   * Deactivate expected service
   *------------------------------*/    
  
  update dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES
  set 
      active            = 0
    , lastModified      = @today
    , lastModifiedBy    = @userID    
  where (
        ([id] = @recID)   
    and (caseloadEntryID = @caseloadEntryID)
	and (active = 1)
  )
  
  /*-------------------------------    
   * Check to see if this was the 
   * very last record
   *------------------------------*/    

  set @numOfRecs = 0

  select 
    @numOfRecs = count(t2.id) 
  from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as t2
  where ( 
        (t2.caseloadEntryID = @caseloadEntryID)
    and (t2.active = 1)
  )

  /*-------------------------------    
   * If this was the last expected
   * service record then we need   
   * to delete the caseload entry
   * for that patient (and all of
   * its related data) and we need
   * to deactivate all RECURRING
   * scheduled services for that 
   * patient.
   *------------------------------*/    

  if (@numOfRecs = 0)
  begin
    
	/* Delete caseload entry for patient */

	exec dbo.PRACTITIONER_CASELOAD_MEMBER_Delete_Core @clientID, @pracID, @patID, @caseloadEntryID, @recordID output    
    
	/* Deactivate all recurring (recurring ONLY) scheduled services for patient */
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
  
  end

/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
     
RETURN(0)    
END TRY    
   
BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong. Return any error 
   * messages to the caller    
   *------------------------------*/    
   
  -- Error or raise error with severity 11 to 19 will be caught here    
   
   
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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_CORE] TO [webuser]
GO
