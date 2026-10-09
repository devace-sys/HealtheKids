USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_MISSING_TREATMENTS_FOR_A_PATIENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_MISSING_TREATMENTS_FOR_A_PATIENT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_MISSING_TREATMENTS_FOR_A_PATIENT] (
   @userID                        bigint
 , @userGroup                     int  
 , @userRank                      int 
 , @clientID                      bigint
 , @patID                         bigint  = null
 , @groupSvcClassNameID           bigint  = null
 , @spEdServiceCode               int     = null
 , @orpDocID                      bigint  = null
 , @svcTrackingClass              int     = null
 , @mcalPatients                  bit     = null
 , @leaBopSvc                     bit     = null
 , @missingTmt                    bit     = null
 , @startDate                     date    = null
 , @endDate                       date    = null
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
      t1.planStartDate
	, t1.planEndDate
	, t1.dosStart
	, t1.dosEnd
	, numMinsExpected            = t1.totalMinutesExpected
    , numMinsApplicable          = t1.totalMinutesSatisfied
    , minsExpectedApplicableDiff = t1.diffMinutesExpectedSatified
	, numMinsDiff                = t1.diffMinutesExpectedSatified
    , t1.clientID
    , groupServiceClassNameID = null
	, t1.patID
    , t1.spEdServiceCode
	, spEdServiceCodeStr        = convert(varchar(50),t1.spEdServiceCode)
	, spEdServiceCodeName       = convert(varchar(50),t1.spEdServiceCode) + ' - ' + ss.[name]
	, orpDocStandardSelectionNameID = null
	, orpDocStandardSelectionName   = ''
	, svcTrackingClass              = dbo.CONST_SVC_TRACKING_CLASS_SPED()
	, serviceOrOrderName            = convert(varchar(50),t1.spEdServiceCode) + ' - ' + ss.[name]
    , t1.spEdFreqCode
	, estReimburse              = t1.potentialLostReimbursment
	, pctExpectedApplicable     = t1.pctExpectedSatisfied
	, t1.minsPerFreq
	, deliveryExceptionsSupported = convert(bit,1)
	
from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DETAILS_VIEW_DATA_CORE (  @clientID
                                                                                                  , @patID
																								  , @spEdServiceCode
																								  , null
																								  , null
																								  , null -- freq code
																								  , null
																								  , @startDate
																								  , @endDate
																								  , @mcalPatients
																								  , null
																								  , @leaBopSvc
																								  , 1
																								  , 1
																								  , 1
																								  , 1
																								  , @patAbsentMinsAreSatisfiedMins) as t1
join dbo.SpEd_Service as ss  on ss.codeValue = t1.spEdServiceCode
where ( 
        (@svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED())        
    and ((@missingTmt is null) or (t1.lessThanExpected = @missingTmt))
)

union all

select 
      t2.planStartDate
	, t2.planEndDate
	, t2.dosStart
	, t2.dosEnd
	, numMinsExpected            = t2.totalMinutesExpected
    , numMinsApplicable          = t2.totalMinutesSatisfied
    , minsExpectedApplicableDiff = t2.diffMinutesExpectedSatified
	, numMinsDiff                = t2.diffMinutesExpectedSatified
    , t2.clientID
    , groupServiceClassNameID    = t2.groupSvcClassNameID	
    , t2.patID
    , spEdServiceCode     = null
	, spEdServiceCodeStr  = null
	, spEdServiceCodeName = null
	, t2.orpDocStandardSelectionNameID
	, orpDocStandardSelectionName   = ssn.NAME
	, svcTrackingClass              = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()
	, serviceOrOrderName            = ssn.NAME
	, t2.spEdFreqCode
	, estReimburse              = t2.potentialLostReimbursment
	, pctExpectedApplicable     = t2.pctExpectedSatisfied
	, t2.minsPerFreq
	, deliveryExceptionsSupported = convert(bit,0)

from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_DETAILS_VIEW_DATA_CORE (
    @clientID 
  , @patID
  , @groupSvcClassNameID 
  , @orpDocID 
  , @startDate
  , @endDate 
  , @mcalPatients
  , null
  , @leaBopSvc
  , 1
  , 1
  , 1
  , 1) as t2
join dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES as ssn on ssn.id = t2.orpDocStandardSelectionNameID
where ( 
        (@svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED())        
    and ((@missingTmt is null) or (t2.lessThanExpected = @missingTmt))
)

)
select top (dbo.CONST_MAX_ROWS()) 
      patName                  = pap.CONCAT_NAME
    , patDOB                   = pap.DATE_OF_BIRTH
    , patDOBStr                = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
    , patCSIS                  = trim(isnull(pap.CSIS,N''))
    , patBIC                   = trim(isnull(pap.BIC,N''))
	, p1.*
	, startDate                 = p1.planStartDate
	, endDate                   = p1.planEndDate
    , datesOfService            = iif ((p1.spEdFreqCode != 10)
	                                , dbo.RPT_DATE_FMT(p1.dosStart) + ' - ' + dbo.RPT_DATE_FMT(p1.dosEnd)
									, dbo.RPT_DATE_FMT(p1.dosStart))
	, startDateStr              = dbo.RPT_DATE_FMT (p1.planStartDate)
	, endDateStr                = dbo.RPT_DATE_FMT (p1.planEndDate)	
    , estReimburseStr           = dbo.RPT_ROUND_FMT(p1.estReimburse)
    , pctExpectedApplicableStr  = convert(varchar(50),p1.pctExpectedApplicable) + '%'
	, spEdFreqName              = ssf.name
	, spEdCaseManagerName       = isnull(pap.spEdCaseManagerName,'')
    , pap.spEdExitedSpEdDate
    , spEdExitedSpEdDateStr     = dbo.RPT_DATE_FMT(pap.spEdExitedSpEdDate)

	/* Added for additional info and for delivery exception additions */

	, planStartDateStr          = dbo.RPT_DATE_FMT (p1.planStartDate)
	, planEndDateStr            = dbo.RPT_DATE_FMT (p1.planEndDate)	
	, dosStartDateStr           = dbo.RPT_DATE_FMT(p1.dosStart)
	, dosEndDateStr             = dbo.RPT_DATE_FMT(p1.dosEnd)
	, numMinsMissing           = abs((iif(p1.numMinsDiff > 0, numMinsDiff, 0)))

from cte_p1                      as p1
join dbo.SpEd_Service_Frequency  as ssf on ssf.codeValue = p1.spEdFreqCode
join dbo.PATIENTS_Patient        as pap on pap.PATIENT_ID   = p1.patID

order by
    pap.CONCAT_NAME
  , pap.PATIENT_ID
  , p1.serviceOrOrderName
  , p1.planStartDate
  , p1.planEndDate
  , p1.dosStart 
  , p1.dosEnd

)

GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_MISSING_TREATMENTS_FOR_A_PATIENT TO [webuser]
GO