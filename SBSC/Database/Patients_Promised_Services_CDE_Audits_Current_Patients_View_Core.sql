USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.[Patients_Promised_Services_CDE_Audits_Current_Patients_View_Core]
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_View_Core] (
   @clientID                      bigint  
 , @patID                         bigint
 , @patAbsentMinsAreSatisfiedMins bit = 1
)
    
returns table     
as
 
return 
(    

with
cte_p1
as
(
  select 
      t1.patientsPromisedServicesCDEAuditsCurrentID
    , t1.patientsPromisedServicesCDEAuditsCurrentPatientsID
    , t1.clientID
    , t1.patID
	, t1.siteID
    , totMinsExpected         = sum(t1.totalMinutesExpected)
	, totMinsApplicable       = sum(t1.totalMinutesSatisfied)
	, numPlans                = count(t1.idx) 
	, totMoreThanExpectedCtr  = sum(t1.moreThanExpectedCtr)

    , numPatAbsentTot         = sum(t1.numPatAbsentTot)
    , numPracAbsentTot        = sum(t1.numPracAbsentTot)
    , numSvcRecs              = sum(t1.numSvcRecs)  

from dbo.Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View_Core (
    @clientID
  , @patID
  , 0
  , @patAbsentMinsAreSatisfiedMins) as t1
group by
      t1.patientsPromisedServicesCDEAuditsCurrentID
    , t1.patientsPromisedServicesCDEAuditsCurrentPatientsID
    , t1.clientID
    , t1.patID
	, t1.siteID
)
,
cte_p2
as
(
select     
    p1.*
  , pctExpectedApplicable = dbo.CALC_PERCENTAGE_Fulfillment (p1.totMinsApplicable, p1.totMinsExpected)
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
    p3.*   
  , inCdeBucket = dbo.CALC_IN_CDE_BUCKET_NAME(p3.inCDEBucketC,p3.inCDEBucketB,p3.inCDEBucketA)
from cte_p3 as p3
) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_View_Core] TO [webuser]
GO