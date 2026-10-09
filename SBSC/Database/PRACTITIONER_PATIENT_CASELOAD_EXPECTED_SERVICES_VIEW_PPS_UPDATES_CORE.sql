USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATES_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATES_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATES_CORE] (    
    @clientID               bigint
  , @pracID                 bigint
  , @patID                  bigint
  , @spEdSvcCode            int
  , @updateToNewerPlan      bit = 0
)
returns
table
as
return
(


/*-------------------------------    
 * Pass 1 
 *
 * Limit to single instances of
 * spEdSvcCode/Plan/Patient/start date
 *
 * We are not going to try to
 * figure out what records to
 * update in cases where a prac
 * is tracking multiple instances
 * of the same spEdSvcCode and 
 * same start date
 * but different end dates
 * for the same patient.  Note:
 * this case should not happen
 * under normal circumstances.
 *------------------------------*/    

with
cte_p1
as
(
  select 
      caseloadEntryID = ppc.id
    , ppc.clientID
	, ppc.pracID
	, ppc.patID
    , ppces.spEdServiceCode
	, ppces.startDate
  from dbo.PRACTITIONER_PATIENT_CASELOAD                   as ppc 
  join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces on ppces.caseloadEntryID = ppc.id
  where (
        ((ppc.clientID = @clientID)
    and ((@pracID is null) or (ppc.pracID = @pracID))
    and ((@patID  is null) or (ppc.patID  = @patID))) 
    and ((@spEdSvcCode is null) or (ppces.spEdServiceCode = @spEdSvcCode))
	and (ppces.svcTrackingClass = 100)
    and (ppces.active           = 1)
  )
  group by 
      ppc.id
    , ppc.clientID
	, ppc.pracID
	, ppc.patID
    , ppces.spEdServiceCode
	, ppces.startDate
  having 
    count(ppces.id) = 1
)
,

/*-------------------------------    
 * Pass 2 
 *
 * Get individual entries
 *------------------------------*/    

cte_p2
as
(
  select distinct
	  p1.caseloadEntryID
	, ppces.id
  from cte_p1                                              as p1
  join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces on (  (ppces.caseloadEntryID  = p1.caseloadEntryID)
                                                                      and (ppces.clientID         = p1.clientID)
																	  and (ppces.pracID           = p1.pracID)
																	  and (ppces.patID            = p1.patID)
	  					 										      and (ppces.spEdServiceCode  = p1.spEdServiceCode)
																	  and (ppces.startDate        = p1.startDate) )
)

/*-------------------------------    
 * Pass 3 
 *
 * Output
 *------------------------------*/    

select
    p2.caseloadEntryID
  , ppces.id
  , ppces.clientID
  , ppces.pracID
  , ppces.patID
  , ppces.spEdServiceCode
  , oldStartDate           = ppces.startDate
  , oldEndDate             = ppces.endDate
  , oldSpEdFreqCode        = ppces.spEdFreqCode
  , oldMinsPerFreq         = ppces.minsPerFreq
  , oldMinsPerFreqAssigned = ppces.minsPerFreqAssigned
  , oldHasSvcDetails       = ppces.hasSvcDetails
  , oldSvcDetailsJSON      = ppces.svcDetailsJSON
  , ppsUpdates2.*
from cte_p2 as p2
join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces on ppces.id = p2.id
cross apply (
    select top 1  
        newStartDate           = ppsUpdates1.startDate
	  , newEndDate             = ppsUpdates1.endDate
	  , newSpEdFreqCode        = ppsUpdates1.spEdFreqCode
	  , newMinsPerFreq         = ppsUpdates1.minsPerFreq
	  , newMinsPerFreqAssigned = ppsUpdates1.minsPerFreqAssigned
	  , newHasSvcDetails       = ppsUpdates1.hasSvcDetails
	  , newSvcDetailsJSON      = ppsUpdates1.svcDetailsJSON	
    
    from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATE_CORE (    
        ppces.patID
      , ppces.spEdServiceCode
      , ppces.startDate
      , ppces.endDate
      , ppces.spEdFreqCode
      , ppces.minsPerFreq 
	  , ppces.minsPerFreqAssigned
      , ppces.hasSvcDetails
      , ppces.svcDetailsJSON
      , ppces.svcTrackingClass
	  , ppces.created
	  , ppces.lastModified
	  , @updateToNewerPlan
    ) as ppsUpdates1
    where ( 
          (ppsUpdates1.matchFound = 1) and (ppsUpdates1.updateNeeded = 1)
    )
  ) as ppsUpdates2  

)
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATES_CORE] TO [webuser]
GO