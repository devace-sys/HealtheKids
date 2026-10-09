/* Keep in synch with PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW.sql */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CDE_COMPLIANCE_FOR_PRAC_CASELOAD_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CDE_COMPLIANCE_FOR_PRAC_CASELOAD_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_CDE_COMPLIANCE_FOR_PRAC_CASELOAD_SUMMARY]
(
   @userID                 bigint
 , @userGroup              int
 , @userRank               int 
 , @clientID               bigint
 , @pracID                 bigint
 , @useMinsPerFreqAssigned bit   = 0
)
returns
table
as
return
(

with
cte_p0
as
(
  select top 1
      currentDate = convert(date,getdate())
    , clientID    = @clientID
    , pracID      = @pracID
)
,
cte_p1
as
(
select 
  q1.* 
from cte_p0 as p0

cross apply (
  select 
      ppces.clientID
    , ppces.patID
	, ppces.pracID
    , ppces.spEdServiceCode
	, ppces.startDate
    , ppces.endDate
	, ppces.spEdFreqCode
	, ppces.minsPerFreq
	, endDateOrCurrent       = dbo.DATE_VALUE_OR_REPLACEMENT_IF_GT_LT( ppces.endDate, p0.currentDate, 1)    
      
	/* If prac is responsible for a portion of plan either by start date and/or mins.  */

    , svcTrackingPracID      = iif((@useMinsPerFreqAssigned = 0), null,              ppces.pracID)
    , svcTrackingStartDate   = iif((@useMinsPerFreqAssigned = 0), ppces.startDate,   ppces.startDateAssigned)
	, svcTrackingMinsPerFreq = iif((@useMinsPerFreqAssigned = 0), ppces.minsPerFreq, ppces.minsPerFreqAssigned)
  
  from dbo.PRACTITIONER_PATIENT_CASELOAD                     as ppc
  join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES   as ppces on ppces.caseloadEntryID = ppc.id
  
  where (
         (ppc.clientID = p0.clientID)
    and  (ppc.pracID   = p0.pracID)
    and  (ppces.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED())
	and  (ppces.active = 1)
  )
) as q1
)
,
cte_p2
as
(
  select 
      totMinsExpected   = sum(pdc2.totalMinutesExpected)
    , totMinsApplicable = sum(pdc2.totalMinutesSatisfied)
  from cte_p1 as p1
  cross apply (
    select 
        pdc1.totalMinutesExpected
      , pdc1.totalMinutesSatisfied      
	from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE (
          p1.clientID                   
        , p1.patID
		, p1.svcTrackingPracID
        , p1.spEdServiceCode
        , p1.startDate
		, null
		, p1.spEdFreqCode 
		, p1.minsPerFreq
		, p1.svcTrackingMinsPerFreq 
		, p1.svcTrackingStartDate
        , p1.endDateOrCurrent
        , null   /*@patHasBIC*/
        , null   /*@patHasSSID*/
        , null   /*@billableSvcs*/
        , 1      /*@limitCalcToEndDate*/ 
        , 0      /*@calcPctExpectedSatisfied */
        , 0      /*@calcPotLostReimbursement */
	    , 1      /*@limitDosToStartEndDate*/
	    , 1      /*@reqPatSvcCode*/
		, @useMinsPerFreqAssigned     /*@usePpsSvcTermsProvided*/
		, 1 /* Pat absent counts as mins satisfied */
		, 0 /* Exit without calc */
	) as pdc1
  ) as pdc2
)
,
cte_p3
as
(
  select 
    p2.totMinsExpected
  , p2.totMinsApplicable
  , totMinsDiff = (p2.totMinsExpected - p2.totMinsApplicable)
  , pctExpectedApplicable = dbo.CALC_PERCENTAGE (p2.totMinsApplicable, p2.totMinsExpected,1,1,0)
  from cte_p2 as p2
)
select 
    spEdServiceCodeAndName = 'CDE Implementation - My Caseload'
  , p3.totMinsExpected
  , p3.totMinsApplicable
  , p3.totMinsDiff
  , p3.pctExpectedApplicable 
  , pctExpectedApplicableStr = convert(varchar(50),p3.pctExpectedApplicable) + '%'
from cte_p3 as p3

)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_CDE_COMPLIANCE_FOR_PRAC_CASELOAD_SUMMARY TO [webuser]
GO