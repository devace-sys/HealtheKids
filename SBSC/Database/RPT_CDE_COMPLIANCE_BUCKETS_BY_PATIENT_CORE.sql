USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_CORE]
(
   @clientID             bigint
 , @startDate            date
 , @endDate              date
)
returns
table
as
return
(

with
cte_p1
as
(
  select 
      pps.patID
    , startDate                     = min(pps.planStartDate)
	, endDate                       = max(pps.endDate)
	, totPlans                      = count(pps.id)
	, totMinsExpected               = sum(pps.totalMinutesExpected)
    , totMinsApplicable             = sum(pps.totalMinutesSatisfied)
	, totDiffMinsExpectedApplicable = sum(pps.diffMinutesExpectedSatified)
	, totPotLostReimbursement       = sum(pps.potentialLostReimbursment)

  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services as pps
  where 
    (pps.clientID = @clientID)
  group by
      pps.clientID
    , pps.patID
)
,
cte_p2
as
(
  select  
    p1.*
  , pctExpectedApplicable =  dbo.CALC_PERCENTAGE(p1.totMinsApplicable,p1.totMinsExpected,1,1,0)
  from cte_p1 as p1
)
,
cte_p3
as
(
  select 
      p2.*  
    , pctExpectedApplicableStr = convert(varchar(50),p2.pctExpectedApplicable) + '%'
    , inCDEBucketC = dbo.CALC_IN_CDE_BUCKET_C (p2.pctExpectedApplicable)
    , inCDEBucketB = dbo.CALC_IN_CDE_BUCKET_B (p2.pctExpectedApplicable)
    , inCDEBucketA = dbo.CALC_IN_CDE_BUCKET_A (p2.pctExpectedApplicable)
  from cte_p2 as p2
)

select  
    clientID  = @clientID
  , p3.*
  , inCdeBucket = dbo.CALC_IN_CDE_BUCKET_NAME(p3.inCDEBucketC,p3.inCDEBucketB,p3.inCDEBucketA)
from cte_p3 as p3

)

GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_PATIENT_CORE TO [webuser]
GO