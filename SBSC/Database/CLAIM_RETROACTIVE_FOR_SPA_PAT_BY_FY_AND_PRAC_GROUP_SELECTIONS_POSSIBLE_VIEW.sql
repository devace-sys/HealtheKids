USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW] (
    @userID        as   BIGINT    
  , @userGroup     as   BIGINT    
  , @userRank      as   INT
  , @forSpaID      as   bigint
  , @clientID      as   bigint
  , @fyID          as   bigint
  , @authorizedYNU as   varchar(1)
)    
    
returns table     
as    
    
/***************************************************************************    
 * CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW */    
/**    
 * @returns table    
 ***************************************************************************/     
    
return (    
with
cte_p1
as
(
select top (dbo.CONST_MAX_ROWS())
    t1.id
  , fyName    = cfy.FY_DEFINITION
  , pracName  = prp.CONCAT_NAME
  , groupName = gg.GROUP_NAME
  , svcPlan   = iif(t1.isIFSPorIEP = 1,'IEP','Non IEP')
  , svcName   = coalesce(ipn.NAME, npn.NAME)
  , t1.authorizedYNU
  , t1.numSvcRecs
  , t1.totEstReimburse
  , totEstReimburseStr = dbo.RPT_ROUND_FMT(t1.totEstReimburse)
  , t1.forSpaID
  , t1.clientID
  , t1.fyID
  , t1.pracID
  , t1.isIFSPorIEP
  , t1.groupID
  , t1.nameID
  
from dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW_CORE ( @forSpaID, @clientID, @fyID, @authorizedYNU ) as t1

join      dbo.COMPANY_FISCAL_YEARS      as cfy on cfy.ID               = t1.fyID
join      dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID  = t1.pracID
join      dbo.GROUP_Group               as gg  on gg.GROUP_ID          = t1.groupID
left join dbo.CLAIM_IEPandIFSPNames     as ipn on ipn.IEP_IFSP_NAME_ID = t1.nameID  and t1.isIFSPorIEP = 1
left join dbo.CLAIM_NoPlanNames         as npn on npn.NO_PLAN_NAME_ID  = t1.nameID  and t1.isIFSPorIEP = 0
)

select top (dbo.CONST_MAX_ROWS())
  p1.* 
from cte_p1 as p1
order by /* Keep in synch with viewTbl paging order and restView paging order */
    p1.pracName
  , p1.fyName 
  , p1.groupName
  , p1.svcPlan
  , p1.svcName
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW] TO [webuser]
GO