USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_Plan_Performance_By_SpEdSvc_Summary_Rpt') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_Plan_Performance_By_SpEdSvc_Summary_Rpt
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patients_Promised_Services_Plan_Performance_By_SpEdSvc_Summary_Rpt] (

    @userID                        bigint
  , @userGroup                     int
  , @userRank                      int 
  , @clientID                      bigint


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
    , spEdService  = convert(varchar(256),ss.codeValue) + ' - ' + ss.[name]
    , clientName   = cc.CLIENT_NAME 
	, numAbsentTot = t1.numPatAbsentTot + t1.numPracAbsentTot
  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services as t1
  join dbo.SpEd_Service                                                 as ss   on ss.codeValue    = t1.spEdServiceCode
  join dbo.CLIENTS_Client                                               as cc on cc.CLIENT_ID      = t1.clientID
  where
    (t1.clientID = @clientID)
)
,
cte_p2
as
(
  select  
      p1.spEdService
    , totMinsExpected  = sum(p1.totalMinutesExpected)
    , totMinsSatisfied = sum(p1.totalMinutesSatisfied)
    , startDos         = min(p1.startDate)
    , endDos           = max(p1.endDate)
	, totPatAbsent     = sum(p1.numPatAbsentTot)
    , totPracAbsent    = sum(p1.numPracAbsentTot)
	, totAbsent        = sum(p1.numAbsentTot)
	, totSvcRecs       = sum(p1.numSvcRecs)
	, numPlans         = count(p1.id)
    , clientName
  from cte_p1 as p1
  group by      
      p1.spEdService
    , clientName
)
,
cte_p3
as
(
select 
    p2.* 
  , pctExpectedSatisfied = dbo.CALC_PERCENTAGE (p2.totMinsSatisfied,p2.totMinsExpected,1,1,0)            
  , pctAbsencePat        = dbo.CALC_PERCENTAGE (p2.totPatAbsent,p2.totSvcRecs,1,1,0)
  , pctAbsencePrac       = dbo.CALC_PERCENTAGE (p2.totPracAbsent,p2.totSvcRecs,1,1,0)
  , pctAbsence           = dbo.CALC_PERCENTAGE (p2.totAbsent,p2.totSvcRecs,1,1,0)
from cte_p2 as p2
)
select top (dbo.CONST_MAX_ROWS())
    p3.clientName 
  , p3.spEdService
  , spEdServiceCodeAndName = p3.spEdService
  , startDate              = p3.startDos
  , endDate                = p3.endDos  
  , totPlans               = p3.numPlans
  , p3.totMinsExpected
  , p3.totMinsSatisfied
  , p3.totPatAbsent
  , p3.totPracAbsent
  , p3.totAbsent
  , p3.totSvcRecs
  , p3.pctExpectedSatisfied 
  , p3.pctAbsencePat
  , p3.pctAbsencePrac
  , p3.pctAbsence

  , pctExpectedSatisfiedStr  = convert(varchar(50),p3.pctExpectedSatisfied) + '%'
  , pctAbsencePatStr         = convert(varchar(50),p3.pctAbsencePat)        + '%'
  , pctAbsencePracStr        = convert(varchar(50),p3.pctAbsencePrac)       + '%'
  , pctAbsenceStr            = convert(varchar(50),p3.pctAbsence)           + '%'

from cte_p3 as p3
order by  
  p3.spEdService
)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.Patients_Promised_Services_Plan_Performance_By_SpEdSvc_Summary_Rpt TO [webuser]
GO