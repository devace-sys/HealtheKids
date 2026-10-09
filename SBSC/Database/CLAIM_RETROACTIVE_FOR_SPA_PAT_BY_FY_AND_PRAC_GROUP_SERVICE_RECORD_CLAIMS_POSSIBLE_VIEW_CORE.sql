USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SERVICE_RECORD_CLAIMS_POSSIBLE_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SERVICE_RECORD_CLAIMS_POSSIBLE_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SERVICE_RECORD_CLAIMS_POSSIBLE_VIEW_CORE] (
    @forSpaID   as   bigint
  , @clientID   as   bigint
  , @fyID       as   bigint
)    
    
returns table     
as    
    
/***************************************************************************    
 * CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SERVICE_RECORD_CLAIMS_POSSIBLE_VIEW_CORE */    
/**    
 * @returns table                
 ***************************************************************************/     
    
return (    
with
cte_p1
as
(
  select distinct 
      forSpaID    = @forSpaID
    , clientID    = @clientID
    , fyID        = cfy.ID
    , START_DOS    = convert(datetime,cfy.FY_START)
    , END_DOS      = convert(datetime,cfy.FY_END)
	, EARLIEST_DOS = convert(datetime,crfs.earliestDOSAllowed)
	, LATEST_DOS   = convert(datetime,crfs.latestDOSAllowed)
	, FIFTY_CENTS  = convert(money,.50)
from dbo.CLAIM_RETROACTIVE_FOR_SPA   as crfs
join dbo.COMPANY_FISCAL_YEARS        as cfy on  cfy.FY_START between crfs.earliestDOSAllowed and crfs.latestDOSAllowed
                                            and cfy.FY_END   between crfs.earliestDOSAllowed  and crfs.latestDOSAllowed
where (
         (crfs.id = @forSpaID)
    and ((@fyID is null) or (cfy.ID = @fyID))
  )
)
,
cte_p2
as
(
  select
    forSpaID  = p1.forSpaID
  , fyID      = p1.fyID
  , sd.*
  , estReimburse = ((sd.svcUnits * sd.svcFee) * p1.FIFTY_CENTS)
  from cte_p1                                      as p1
  join dbo.CLAIM_RETROACTIVE_FOR_SPA_WHAT_SERVICES as crfsws on crfsws.forSpaID = p1.forSpaID
  
  cross apply (
    select        
	   sr.clientID
	 , sr.pracID
	 , sr.patID 
	 , patBIC  = trim(isnull(pap.BIC,N''))
	 , sr.dos
     , sr.groupID 
     , sr.isIFSPorIEP
	 , sr.nameID
	 , src.svcRecID
	 , src.claimID
	 , svcFee   = convert(money,isnull(cp.SERVICE_FEE,0))
	 , svcUnits = convert(money,isnull(cc.SERVICE_UNITS,0))
	from dbo.SERVICE_RECORDS       as sr 
	join dbo.SERVICE_RECORD_CLAIMS as src on src.svcRecID   = sr.id		
    join dbo.PATIENTS_Patient      as pap on pap.PATIENT_ID = sr.patID
	join dbo.CLAIM_Claim           as cc  on cc.CLAIM_ID    = src.claimID
	join dbo.CLAIM_Procedures      as cp  on cp.PROCEDURE_ID = cc.PROCEDURE_ID
	join dbo.CLAIM_PROCEDURES_TRANSMITTABLE() as prt on prt.PROCEDURE_ID = cp.PROCEDURE_ID
	where (
          (sr.clientID = @clientID)
      and (sr.pracID is not null)
      and (sr.patID is not null)
      and (sr.dos between p1.START_DOS and p1.END_DOS) 
	  and (sr.dos between p1.EARLIEST_DOS and p1.LATEST_DOS)
	  and (sr.state not in (20,75,99,199))
      and (sr.svcType in (1,2,3,4))
      and (sr.groupID     = crfsws.groupID)
      and (sr.isIFSPorIEP = crfsws.isIFSPorIEP)
      and (sr.nameID      = crfsws.nameID)
	)
  ) as sd
)
,
cte_p3
as
(
  select 
      p2.*
	 , sca2.authorized
	 , authorizedYNU = iif (sca2.authorized is null,'?',iif(sca2.authorized = 1,'Y','N'))
  from cte_p2 as p2
  outer apply (
    select top 1 
	    sca1.authorized
	from dbo.CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION as sca1
	where (
	      (sca1.forSpaID    = p2.forSpaID)
	  and (sca1.clientID    = p2.clientID)
      and (sca1.fyID        = p2.fyID)
	  and (sca1.pracID      = p2.pracID)
	  and (sca1.isIFSPorIEP = p2.isIFSPorIEP)
      and (sca1.groupID     = p2.groupID)
      and (sca1.nameID      = p2.nameID)
    )
   ) as sca2
   where (p2.patBIC != '')
  )
  select 
    p3.* 
  from cte_p3 as p3
)
GO
