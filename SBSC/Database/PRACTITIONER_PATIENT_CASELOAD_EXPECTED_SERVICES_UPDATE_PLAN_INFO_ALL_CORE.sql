USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_CORE] (
    @userID                 bigint  = null
  , @clientID               bigint  = null
  , @pracID                 bigint  = null
  , @patID                  bigint  = null
  , @spEdSvcCode            int     = null
  , @updateToNewerPlan      bit     = 0  
  , @validateRec            bit     = 1
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )    
AS    
BEGIN    
   
/*****************************************************************************    
 * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_CORE */    
/**    
 * Bulk updates practitoners caseloads that have SpEd plan associations
 * with any changed data that has been put into patient promised services   
 ****************************************************************************/        
     
SET NOCOUNT ON
   
declare @caseloadExceptedServiceChanges as table (
    caseloadEntryID        bigint
  , id                     bigint
  , newStartDate           datetime
  , newEndDate             datetime
  , newSpEdFreqCode        int
  , newMinsPerFreq         int
  , newMinsPerFreqAssigned int
  , newHasSvcDetails       bit
  , newSvcDetailsJSON      varchar(max)
)

declare @today               as datetime = getdate()
declare @numPlansWithChanges as int = 0

BEGIN TRY    
   
/*-------------------------------    
 * Init 
 *------------------------------*/    
   
set @recordID            = 0    
set @spDetails           = ''    
set @numPlansWithChanges = 0

/*-------------------------------    
 * Verify required parms 
 *------------------------------*/    

IF (@userID      IS NULL) RAISERROR ('User id is required',          11, 1)    
IF (@clientID    IS NULL) RAISERROR ('Client id is required',        11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',       11, 1)    
   
/*-------------------------------    
 * Find changes (if any) 
 *------------------------------*/    

insert into @caseloadExceptedServiceChanges (
    caseloadEntryID 
  , id              
  , newStartDate    
  , newEndDate      
  , newSpEdFreqCode 
  , newMinsPerFreq  
  , newMinsPerFreqAssigned 
  , newHasSvcDetails
  , newSvcDetailsJSON 
)
select 
    t1.caseloadEntryID 
  , t1.id              
  , t1.newStartDate    
  , t1.newEndDate      
  , t1.newSpEdFreqCode 
  , t1.newMinsPerFreq  
  , t1.newMinsPerFreqAssigned 
  , t1.newHasSvcDetails
  , t1.newSvcDetailsJSON 
from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATES_CORE (    
    @clientID
  , @pracID  
  , @patID 
  , @spEdSvcCode
  , @updateToNewerPlan) as t1
option(recompile)

/*-------------------------------    
 * Count # of changes detected
 * and return that # in recordid
 * (our standard practice for
 * multi row operations)
 *------------------------------*/    

select @numPlansWithChanges = count(t2.id) from @caseloadExceptedServiceChanges as t2
set @recordID = @numPlansWithChanges

/*-------------------------------    
 * If we are just validating    
 * get out
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
   
/*-------------------------------    
 * If there is nothing to update
 * get out
 *------------------------------*/    

if (@numPlansWithChanges = 0) return(0)

/*-------------------------------    
 * Update time stamp
 *------------------------------*/    

set @today = getdate()

/*-------------------------------    
 * Update expected service data
 * Note: Inactive ppces rows
 * have already been factored out
 * in PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATES_CORE
 *------------------------------*/    

update ppces
set 
    ppces.startDate           = cd.newStartDate
  , ppces.endDate             = cd.newEndDate
  , ppces.spEdFreqCode        = cd.newSpEdFreqCode
  , ppces.minsPerFreq         = cd.newMinsPerFreq
  , ppces.minsPerFreqAssigned = cd.newMinsPerFreqAssigned
  , ppces.hasSvcDetails       = cd.newHasSvcDetails
  , ppces.svcDetailsJSON      = cd.newSvcDetailsJSON
  , ppces.lastModified        = @today
  , ppces.lastModifiedBy      = @userID
from @caseloadExceptedServiceChanges                     as cd
join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces on ppces.id = cd.id
   
/*-------------------------------    
 * Update caseload entry stats
 *------------------------------*/   

update ppc
set 
    ppc.lastModified       = @today
  , ppc.lastModifiedBy     = @userID
from @caseloadExceptedServiceChanges   as cd
join dbo.PRACTITIONER_PATIENT_CASELOAD as ppc on ppc.id = cd.caseloadEntryID

RETURN(0)    
END TRY    
   
BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong. Return any    
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
   
  SET @ErrorMessage = @ErrorMessage
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_CORE] TO [webuser]
GO
