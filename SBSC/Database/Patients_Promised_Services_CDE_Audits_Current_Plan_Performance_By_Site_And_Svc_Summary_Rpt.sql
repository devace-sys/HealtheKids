USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_And_Svc_Summary_Rpt') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_And_Svc_Summary_Rpt
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_And_Svc_Summary_Rpt] (
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
select top (dbo.CONST_MAX_ROWS())
    t1.clientID 
  , clientName             = clc.CLIENT_NAME
  , q2.siteID
  , q2.siteName
  , q2.spEdServiceCode
  , q2.spEdServiceName
  , spEdServiceCodeAndName = convert(varchar(50),q2.spEdServiceCode) + ' - ' + q2.spEdServiceName
  , startDate         = dbo.RPT_DATE_FMT(t1.startDate)
  , endDate           = dbo.RPT_DATE_FMT(t1.endDate)

                        -- renaming slightly, to allow the same defineCols to be used with multiple reports;
                        -- startDate and endDate are being renamed in middleware, so the col names here don't matter all that much


  , q2.totPlans
  , q2.totMinsSatisfied
  , q2.totMinsExpected
  , pctExpectedSatisfied = dbo.CALC_PERCENTAGE_Fulfillment(q2.totMinsSatisfied,q2.totMinsExpected)
  , pctExpectedSatisfiedStr = convert(varchar(50),(dbo.CALC_PERCENTAGE_Fulfillment(q2.totMinsSatisfied,q2.totMinsExpected))) + '%'

from dbo.Patients_Promised_Services_CDE_Audits_Current as t1
join dbo.CLIENTS_Client                                as clc on clc.CLIENT_ID = t1.clientID
cross apply (
  select 
      q1.siteID
	, siteName = ss.SITE_NAME
	, q1.spEdServiceCode
    , spEdServiceName = sps.[name]
	, q1.totPlans
    , q1.totMinsSatisfied
    , q1.totMinsExpected 
  from
  (
    select 
        q0.siteID
	  , q0.spEdServiceCode
	  , totPlans         = count(q0.spEdServiceCode)
      , totMinsSatisfied = sum(q0.totalMinutesSatisfied)
      , totMinsExpected  = sum(q0.totalMinutesExpected)
    from dbo.Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View_Core (
	    t1.clientID
	  , null
	  , 0
	  , @patAbsentMinsAreSatisfiedMins) as q0
    group by    
	   q0.siteID
	  ,q0.spEdServiceCode
  ) as q1
  join dbo.SpEd_Service as sps on sps.codeValue = q1.spEdServiceCode
  join dbo.SITES_Site   as ss  on ss.SITE_ID    = q1.siteID
) as q2
where ( 
      (1=1)
  and ((@clientID is null) or (t1.clientID = @clientID))
  --and (t1.clientID != 112)
  and (t1.active = 1)
)
order by 
    clc.CLIENT_NAME
  , q2.siteName
  , q2.spEdServiceCode
)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.Patients_Promised_Services_CDE_Audits_Current_Plan_Performance_By_Site_And_Svc_Summary_Rpt TO [webuser]
GO