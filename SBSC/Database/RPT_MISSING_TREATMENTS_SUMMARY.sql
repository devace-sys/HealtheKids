USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_MISSING_TREATMENTS_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_MISSING_TREATMENTS_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_MISSING_TREATMENTS_SUMMARY]
(
    @userID               BIGINT
  , @userGroup            INT  
  , @userRank             INT 
  , @clientID             bigint
  , @repID                bigint  = null  /* null = all reps */
  , @groupSvcClassNameID  bigint  = null
  , @spEdServiceCode      int     = null
  , @mcalPatients         bit     = null
  , @leaBopSvc            bit     = null
  , @missingTmt           bit     = null
  , @svcTrackingClass     int     = null
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
      mtc.clientID
    , mtc.clientName
    , mtc.repID
    , mtc.repName
    , mtc.svcTrackingClass
    , mtc.spEdServiceCode
    , mtc.groupServiceClassNameID
    , mtc.serviceOrOrderName
    , startDate         = min(mtc.planStart)
	, endDate           = max(mtc.planEnd)
	, totMinsExpected   = sum(mtc.numMinsExpected)
	, totMinsApplicable = sum(mtc.numMinsApplicable)
    , totMinsMissing    = sum(mtc.minsExpectedApplicableDiff) 
    , totEstReimburse   = sum(mtc.estLostReimburse)
    
from dbo.RPT_MISSING_TREATMENTS_CORE (
    @clientID
  , @repID
  , @groupSvcClassNameID
  , @spEdServiceCode
  , @mcalPatients
  , @leaBopSvc 
  , @missingTmt
  , @svcTrackingClass) as mtc

group by
      mtc.clientID
    , mtc.clientName
    , mtc.repID
    , mtc.repName
    , mtc.svcTrackingClass
    , mtc.spEdServiceCode
    , mtc.groupServiceClassNameID
    , mtc.serviceOrOrderName
)
,
cte_p2
as
(
  select 
      id = convert(varchar(10),p1.svcTrackingClass) 
	     + '-' 
		 + convert(varchar(50),(iif((p1.svcTrackingClass=100),p1.spEdServiceCode,p1.groupServiceClassNameID)))
    , p1.*
	, startDateStr           = dbo.RPT_DATE_FMT(p1.startDate)
    , endDateStr             = dbo.RPT_DATE_FMT(p1.endDate)
    , totEstReimburseStr     = dbo.RPT_ROUND_FMT(p1.totEstReimburse)
	, pctExpectedApplicable  = dbo.CALC_PERCENTAGE (p1.totMinsApplicable, p1.totMinsExpected,1,1,0)
	, active                 = convert(bit,1)
  from cte_p1 as p1
)
select top (dbo.CONST_MAX_ROWS()) 
   p2.*
 , pctExpectedApplicableStr = convert(varchar(50),p2.pctExpectedApplicable) + '%' 
from cte_p2 as p2
order by 
    p2.svcTrackingClass
  , p2.serviceOrOrderName
)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_MISSING_TREATMENTS_SUMMARY TO [webuser]
GO