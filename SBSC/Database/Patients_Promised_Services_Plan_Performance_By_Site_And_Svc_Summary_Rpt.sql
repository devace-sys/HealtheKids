USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_Plan_Performance_By_Site_And_Svc_Summary_Rpt') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_Plan_Performance_By_Site_And_Svc_Summary_Rpt
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patients_Promised_Services_Plan_Performance_By_Site_And_Svc_Summary_Rpt] (

   @userID               bigint
 , @userGroup            int
 , @userRank             int 
 , @clientID             bigint



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
      t1.*
    , siteName    = isnull(ss2.SITE_NAME,N'')
    , spEdService = convert(varchar(256),ss.codeValue) + ' - ' + ss.[name]
    , cc.CLIENT_NAME  clientName
	, numAbsentTot = t1.numPatAbsentTot + t1.numPracAbsentTot

  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services as t1 
  join dbo.SpEd_Service                                                 as ss on ss.codeValue    = t1.spEdServiceCode
  join dbo.CLIENTS_Client                                               as cc on cc.CLIENT_ID    = t1.clientID

  outer apply (
    select top 1 
      ss1.SITE_NAME 
    from dbo.SITES_Site as ss1
    where 
      (ss1.SITE_ID = t1.siteID)
  ) as ss2

  where
    (t1.clientID = @clientID)
)
,
cte_p2
as
(
  select  
      p1.siteName
    , p1.spEdService                                       
    , totMinsExpected  = sum(p1.totalMinutesExpected)
    , totMinsSatisfied = sum(p1.totalMinutesSatisfied)
    , startDos         = min(p1.startDate)
    , endDos           = max(p1.endDate)
	, totPatAbsent     = sum(p1.numPatAbsentTot)
    , totPracAbsent    = sum(p1.numPracAbsentTot)
	, totSvcRecs       = sum(p1.numSvcRecs)
	, totAbsent        = sum(p1.numAbsentTot)
    , numPlans         = count(p1.id)
	, clientName
  from cte_p1 as p1
  group by
      p1.siteName
    , p1.spEdService
    , clientName
)
,
cte_p3
as
(
select 
    p2.clientName
  , p2.siteName
  , p2.spEdService
  , spEdServiceCodeAndName = p2.spEdService                                                                 
  , startDate = p2.startDos                                                                    
  , endDate   = p2.endDos                                                                      
  , totPlans  = p2.numPlans                                                                    
  , p2.totMinsExpected
  , p2.totMinsSatisfied
  
  , p2.totPatAbsent
  , p2.totPracAbsent
  , p2.totSvcRecs
  , p2.totAbsent

  , pctExpectedSatisfied = dbo.CALC_PERCENTAGE(p2.totMinsSatisfied,p2.totMinsExpected,1,1,0) 
  , pctAbsencePat        = dbo.CALC_PERCENTAGE (p2.totPatAbsent,p2.totSvcRecs,1,1,0)
  , pctAbsencePrac       = dbo.CALC_PERCENTAGE (p2.totPracAbsent,p2.totSvcRecs,1,1,0)
  , pctAbsence           = dbo.CALC_PERCENTAGE (p2.totAbsent,p2.totSvcRecs,1,1,0)

from cte_p2 as p2
)
select top (dbo.CONST_MAX_ROWS())
    p3.* 
  , pctExpectedSatisfiedStr  = convert(varchar(50),p3.pctExpectedSatisfied) + '%'
  , pctAbsencePatStr         = convert(varchar(50),p3.pctAbsencePat)        + '%'
  , pctAbsencePracStr        = convert(varchar(50),p3.pctAbsencePrac)       + '%'
  , pctAbsenceStr            = convert(varchar(50),p3.pctAbsence)           + '%'
from cte_p3 as p3
order by
    p3.siteName
  , p3.spEdService
  , p3.clientName

)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.Patients_Promised_Services_Plan_Performance_By_Site_And_Svc_Summary_Rpt TO [webuser]
GO