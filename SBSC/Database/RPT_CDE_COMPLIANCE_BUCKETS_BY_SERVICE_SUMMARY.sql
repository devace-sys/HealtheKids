USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_SUMMARY] (
    @userID               bigint 
  , @userGroup            int
  , @userRank             int 
  , @clientID             bigint
  , @siteID               bigint
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
      pps.clientID
	, pps.spEdServiceCode
    , pps.patID
	, startDate                  = min(pps.planStartDate)
	, endDate                    = max(pps.endDate)
	, totMinsExpected            = sum(pps.totalMinutesExpected)
	, totMinsApplicable          = sum(pps.totalMinutesSatisfied)
	, totMinsDiff                = sum(pps.diffMinutesExpectedSatified)
	, potLostReimbursement       = sum(pps.potentialLostReimbursment)

  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services as pps
  where (
            (pps.clientID = @clientID)
        and ((@siteID IS NULL) or (pps.siteID = @siteID))
  )
  group by
      pps.clientID
	, pps.spEdServiceCode
	, pps.patID  
	, pps.generatedOn
)
,
cte_p2
as
(
  select
      p1.clientID
	, p1.spEdServiceCode
    , totPats                    = count(p1.patID)
	, startDate                  = min(p1.startDate)
	, endDate                    = max(p1.endDate)
	, totMinsExpected            = sum(p1.totMinsExpected)
	, totMinsApplicable          = sum(p1.totMinsApplicable)
    , totMinsDiff                = sum(p1.totMinsDiff)
	, potLostReimbursement       = sum(p1.potLostReimbursement)

  from cte_p1 as p1
  group by  
      p1.clientID
    , p1.spEdServiceCode
)
,
cte_p3
as
(
  select  
      p2.*
    , startDateStr            = dbo.RPT_DATE_FMT(p2.startDate)
	, endDateStr              = dbo.RPT_DATE_FMT(p2.endDate)
	, pctExpectedApplicable   = dbo.CALC_PERCENTAGE(p2.totMinsApplicable,p2.totMinsExpected,1,1,0)
    , potLostReimbursementStr = convert(varchar(50),p2.potLostReimbursement)        
    , siteIDStr               = iif ((@siteID is null)
	                                  , ''
									  , (convert(varchar(50),@siteID)))
  from cte_p2 as p2

)
select top (dbo.CONST_MAX_ROWS())  
    p3.*
  , spEdServiceName          = ss.[name]
  , spEdServiceCodeAndName   = convert(varchar(50),p3.spEdServiceCode) + '-' + ss.[name]
  , pctExpectedApplicableStr = convert(varchar(50),p3.pctExpectedApplicable) + '%'

from cte_p3           as p3
join dbo.SpEd_Service as ss on ss.codeValue = p3.spEdServiceCode
order by 
  p3.spEdServiceCode
)

GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON dbo.RPT_CDE_COMPLIANCE_BUCKETS_BY_SERVICE_SUMMARY TO [webuser]
GO