USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_Bucket_Summary_Rpt') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_Bucket_Summary_Rpt
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_Bucket_Summary_Rpt] (
    @userID               bigint
  , @userGroup            int
  , @userRank             int 
  , @clientID             bigint
  , @patAbsentMinsAreSatisfiedMins bit = 1
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
    t1.clientID 
  , auditStartDate = t1.startDate
  , auditEndDate   = t1.endDate
  , q2.siteID
  , q2.patID
  , q2.ppxIdx
  , pctExpectedSatisfied = dbo.CALC_PERCENTAGE_Fulfillment(q2.totMinsSatisfied,q2.totMinsExpected)
from dbo.Patients_Promised_Services_CDE_Audits_Current as t1
cross apply (
  select 
      q1.siteID
	, q1.patID
	, q1.ppxIdx
	, q1.totMinsSatisfied
    , q1.totMinsExpected 
  from
  (
    select 
        q0.siteID
	  , q0.patID
	  , q0.ppxIdx
      , totMinsSatisfied = sum(q0.totalMinutesSatisfied)
      , totMinsExpected  = sum(q0.totalMinutesExpected)
    from dbo.Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View_Core (
	    t1.clientID
	  , null
	  , 0
	  , @patAbsentMinsAreSatisfiedMins) as q0
    group by    
	   q0.siteID
	  ,q0.patID
	  ,q0.ppxIdx
  ) as q1
) as q2
where (
       (1=1)
   and ((@clientID is null) or (t1.clientID = @clientID))
   --and (t1.clientID != 112)
   and (t1.active = 1)
)
)
,
cte_p2
as
(
  select 
      p1.clientID
	, p1.auditStartDate
	, p1.auditEndDate
	, p1.siteID
    , totalInBucketC = sum(convert(int,(iif((dbo.CALC_IN_CDE_BUCKET_C (p1.pctExpectedSatisfied) = 1), 1,0))))
    , totalInBucketB = sum(convert(int,(iif((dbo.CALC_IN_CDE_BUCKET_B (p1.pctExpectedSatisfied) = 1), 1,0))))
    , totalInBucketA = sum(convert(int,(iif((dbo.CALC_IN_CDE_BUCKET_A (p1.pctExpectedSatisfied) = 1), 1,0))))
  from cte_p1 as p1
  group by
    p1.clientID
  , p1.auditStartDate
  , p1.auditEndDate
  , p1.siteID
)
select top (dbo.CONST_MAX_ROWS()) 
   p2.clientID
 , clientName        = clc.CLIENT_NAME
 , auditStartDate    = dbo.RPT_DATE_FMT(p2.auditStartDate)
 , auditEndDate      = dbo.RPT_DATE_FMT(p2.auditEndDate)
 , p2.siteID
 , siteName          = ss.SITE_NAME
 , p2.totalInBucketC
 , p2.totalInBucketB
 , p2.totalInBucketA
 , totalInBuckets    = (p2.totalInBucketC + p2.totalInBucketB + p2.totalInBucketA)
from cte_p2             as p2
join dbo.CLIENTS_Client as clc on clc.CLIENT_ID = p2.clientID
join dbo.SITES_Site     as ss  on ss.SITE_ID    = p2.siteID
order by 
    clc.CLIENT_NAME
  , ss.SITE_NAME

)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_Bucket_Summary_Rpt TO [webuser]
GO