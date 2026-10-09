USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_MISSING_TREATMENTS_DETAILS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_MISSING_TREATMENTS_DETAILS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_MISSING_TREATMENTS_DETAILS]
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
  , mtc.patID
  , mtc.groupServiceClassNameID
  , mtc.groupServiceClassNames
  , startDate         = mtc.planStart
  , endDate           = mtc.planEnd
  , mtc.spEdServiceCode
  , mtc.spEdServiceCodeStr
  , mtc.spEdServiceName
  , mtc.spEdServiceCodeName
  , mtc.orpDocStandardSelectionNameID
  , mtc.orpDocStandardSelectionName
  , mtc.orpDocID
  , mtc.svcTrackingClass
  , mtc.serviceOrOrderName
  , totMinsExpected   = mtc.numMinsExpected
  , totMinsApplicable = mtc.numMinsApplicable
  , totMinsDiff       = mtc.minsExpectedApplicableDiff
  , estReimburse      = mtc.estLostReimburse
  , mtc.spEdFreqCode
  , mtc.spEdFreqName
  , mtc.minsPerFreq
  , planStartDate   = mtc.planStart
  , planEndDate     = mtc.planEnd
  , planStartDateStr = dbo.RPT_DATE_FMT(mtc.planStart)
  , planEndDateStr   = dbo.RPT_DATE_FMT(mtc.planEnd)  
 
from dbo.RPT_MISSING_TREATMENTS_CORE (
    @clientID
  , @repID
  , @groupSvcClassNameID
  , @spEdServiceCode
  , @mcalPatients
  , @leaBopSvc
  , @missingTmt
  , @svcTrackingClass) as mtc

)
,
cte_p2
as
(
select 
    p1.* 
  , startDateStr          = dbo.RPT_DATE_FMT(p1.startDate)
  , endDateStr            = dbo.RPT_DATE_FMT(p1.endDate)
  , estReimburseStr       = dbo.RPT_ROUND_FMT(p1.estReimburse)
  , pctExpectedApplicable = dbo.CALC_PERCENTAGE(p1.totMinsApplicable,p1.totMinsExpected,1,1,0)
from cte_p1 as p1

)
select top (dbo.CONST_MAX_ROWS())     
  
    patName                = pap.CONCAT_NAME
  , patDOB                 = pap.DATE_OF_BIRTH
  , patCSIS                = isnull(pap.CSIS,N'')
  , patDOBStr              = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
  , p2.*  
  , pctExpectedApplicableStr = convert(varchar(50),p2.pctExpectedApplicable) + '%'
  , spEdCaseManagerName      = isnull(pap.spEdCaseManagerName,'')
  , pap.spEdExitedSpEdDate
  , spEdExitedSpEdDateStr    = dbo.RPT_DATE_FMT(pap.spEdExitedSpEdDate)
  , inCDEBucketA             = dbo.CALC_IN_CDE_BUCKET_A (p2.pctExpectedApplicable)
  , inCDEBucketB             = dbo.CALC_IN_CDE_BUCKET_B (p2.pctExpectedApplicable)
  , inCDEBucketC             = dbo.CALC_IN_CDE_BUCKET_C (p2.pctExpectedApplicable)

from cte_p2                     as p2  
join dbo.PATIENTS_Patient       as pap on pap.PATIENT_ID = p2.patID

order by
    pap.CONCAT_NAME
  , p2.serviceOrOrderName
  , p2.startDate
)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_MISSING_TREATMENTS_DETAILS TO [webuser]
GO