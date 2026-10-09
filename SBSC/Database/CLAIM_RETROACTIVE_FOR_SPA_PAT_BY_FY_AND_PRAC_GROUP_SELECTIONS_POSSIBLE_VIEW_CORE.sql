USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW_CORE] (
    @forSpaID   as   bigint
  , @clientID   as   bigint
  , @fyID       as   bigint
  , @authorizedYNU as varchar(1)
)    
    
returns table     
as    
    
/***************************************************************************    
 * CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW_CORE*/    
/**    
 * Possible patient by practitioner group selections 
 *     
 * @param  clientID        Client ID (required)    
 * @param  pracID          Practitioner ID    
 * @param  patID           PatientID    
 * @param  recID           Service record, record id (will only return one record)    
 * @return                 Service records    
 ***************************************************************************/     
    
return (    
with

/* Sums up claims for each service record */

cte_p1
as
(
  select  
       t1.forSpaID
	 , t1.clientID
	 , t1.fyID
     , t1.pracID
     , t1.isIFSPorIEP
     , t1.groupID 
	 , t1.nameID
     , t1.svcRecID
	 , t1.authorizedYNU
	 , estTotReimburse = sum(t1.estReimburse)
  from dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SERVICE_RECORD_CLAIMS_POSSIBLE_VIEW_CORE (@forSpaID, @clientID, @fyID) as t1
  where ( 
       (1=1) 
	and ((@authorizedYNU is null) or (t1.authorizedYNU = @authorizedYNU))
  )
  group by
       t1.forSpaID
	 , t1.clientID
	 , t1.fyID
     , t1.pracID
     , t1.isIFSPorIEP
     , t1.groupID 
	 , t1.nameID
     , t1.svcRecID
	 , t1.authorizedYNU

 )
,

/* Sums up service records */

cte_p2
as
(
  select  
       p1.forSpaID
	 , p1.clientID
	 , p1.fyID
     , p1.pracID
     , p1.isIFSPorIEP
     , p1.groupID 
	 , p1.nameID
     , p1.authorizedYNU
	 , numSvcRecs      = count(p1.svcRecID)
	 , totEstReimburse = sum(estTotReimburse)
  from cte_p1 as p1
  group by 
       p1.forSpaID
	 , p1.clientID
     , p1.fyID
	 , p1.pracID
	 , p1.isIFSPorIEP
     , p1.groupID 
     , p1.nameID
	 , p1.authorizedYNU
 )

select     
   id = dbo.CLAIM_RETROACTIVE_FOR_SPA_GENERATE_SELECTION_ID (p2.forSpaID,p2.clientID,p2.fyID,p2.pracID,p2.isIFSPorIEP,p2.groupID,p2.nameID)
 , p2.*
from cte_p2 as p2

)
GO
