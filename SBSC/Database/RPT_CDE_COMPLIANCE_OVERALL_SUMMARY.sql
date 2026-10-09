USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CDE_COMPLIANCE_OVERALL_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CDE_COMPLIANCE_OVERALL_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_CDE_COMPLIANCE_OVERALL_SUMMARY]
(
   @userID       bigint
 , @userGroup    int
 , @userRank     int 
 , @clientID     bigint
 , @siteID       bigint
)
returns 
table
as
return (

with
cte_p1
as
(
  /* We need 1 rec per patient as pps has multiple per pat */
 
  select distinct 
      pps.patID
    , pps.totalFullfillFactorForPat
    , pps.totSvcsForPatInIEP
  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services as pps
  where ( 
        ((pps.clientID = @clientID) and (pps.patID is not null) and (pps.id is not null))
    and ((@siteID is null) or (pps.siteID = @siteID))
  )
)
,
cte_p2
as
(

/* We use total fullfill factor over total svcs to compute pct compliant */

select
    totFullfillFactorForPat = sum(p1.totalFullfillFactorForPat)
  , totSvcsForPatInIEP      = sum(p1.totSvcsForPatInIEP)
from cte_p1 as p1

)
,

/* Compute values */

cte_p3 
as
(
  select    
	  numPlans        = p2.totSvcsForPatInIEP
    , planFulfillment = p2.totFullfillFactorForPat
    , pctCompliant    = dbo.CALC_PERCENTAGE_Fulfillment(p2.totFullfillFactorForPat,p2.totSvcsForPatInIEP)
  from cte_p2 as p2
)
,
cte_p4
as
(
select 
    p3.* 
  , numOfSvcsOverDelivered               = isnull(sod.numOf,0)
  , numOfUnreviewedSvcDeliveryExpections = isnull(sde.numOf,0)
from cte_p3 as p3

outer apply (
  select 
    numOf = count(pps.id)
  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services as pps  
  where ( 
        ((pps.clientID = @clientID) and (pps.patID is not null) and (pps.id is not null))
    and ((@siteID is null) or (pps.siteID = @siteID))
    and (pps.diffMinutesExpectedSatified < 0)	
  )
  group by 
    pps.clientID
) as sod

outer apply ( 
  select 
      numOf = count(ppsde.id)
  from dbo.PATIENTS_Promised_Services_Delivery_Exceptions as ppsde
  where ( 
        ((ppsde.clientID = @clientID) and (ppsde.patID is not null) and (ppsde.id is not null))
    and (ppsde.svcTrackingClass = 100)
	and (ppsde.reviewed         = 0)
    and (ppsde.active           = 1)
  )
  group by 
    ppsde.clientID
) as sde


)

select top 1 
  p4.* 
from cte_p4 as p4

)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_CDE_COMPLIANCE_OVERALL_SUMMARY TO [webuser]
GO