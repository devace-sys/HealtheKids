/* Keep in synch with RPT_CDE_COMPLIANCE_FOR_PRAC_CASELOAD_SUMMARY.sql */

USE SPEDMON
GO
 

/*###########################################################################
 *#                                                                         #
 *#             !!!!!!!!!!!!!!!! NOTICE !!!!!!!!!!!!!!!!!!                  #
 *#                                                                         #
 *# The value of planType is NOT our standard values for planType           #
 *#                                                                         #
 *# In this context.....                                                    #
 *#                                                                         #
 *# 1 = IEP or IFSP, 2 = No Plan, 3 = CYBHI                                 #
 *#                                                                         #
 *# Everywhere else                                                         #
 *#                                                                         #
 *#  1 = IFSP, 2 = IEP, 3 = No Plan , 4 = CYBHI                             #
 *###########################################################################*/


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW] (
    @userID                 BIGINT    
  , @userGroup              INT    
  , @userRank               INT     
  , @clientID               bigint     
  , @pracID                 bigint
  , @patID                  bigint
  , @useMinsPerFreqAssigned bit   = 0
  , @recID                  bigint
  , @disableComplianceCalc  bit = 0    
)
    
returns table     
as
 
return 
(    

/*###########################################################################
 *#  Base Data                                                              #
 *###########################################################################*/

with
cte_p1
as
(
select 
     vc.* 
   , svcTrackingPracID        = iif((@useMinsPerFreqAssigned = 0), null, vc.pracID)   
   , svcTrackingMinsPerFreq   = iif((@useMinsPerFreqAssigned = 0), vc.minsPerFreq, vc.minsPerFreqAssigned)
   , svcTrackingStartDate     = iif((@useMinsPerFreqAssigned = 0), vc.startDate,   vc.startDateAssigned)

   , spEdServiceName = iif( (ss.id is null)
                            , 'Unknown'
                            , (convert(varchar(50),ss.codeValue) + ' ' + ss.name))							    

   , orpDocName      = isnull(odc2.ORP_DOCUMENT_STANDARD_SELECTION_NAME,'Unknown')

   , svcName         = dbo.BUILD_FULL_SERVICE_NAME_STRING (  vc.svcNamesListDataSourceID
	                                                       
														   , cip.NAME
													       , cnp.NAME
													       , ccy.NAME
														   , cru.NAME

													       , null
													       , null
													       , null
													       , null

														   , vc.svcTypeID
													       , vc.groupBase
													       , 0
													       , 0
												           , 0
													       , 0 
													       , 0 )
, svcTrackingClassName = ppcstc.[name]

from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_CORE (  @clientID
                                                                    , @pracID
																	, @patID
																	, @recID) as vc

join dbo.PRACTITIONER_PATIENT_CASELOAD_SVC_TRACKING_CLASSES as ppcstc on ppcstc.[value] = vc.svcTrackingClass

/* For svc tracking class 100 */

left join dbo.SpEd_Service as ss on ss.codeValue = vc.spEdServiceCode

/* For svc tracking class 200.  Note: ORP Doc ID is used to retrieve svc name, freq, dur, etc */

outer apply (
   select top 1 
       odc1.ORP_DOCUMENT_STANDARD_SELECTION_NAME
     , odc1.planStartDate
	 , odc1.planEndDate
	 , odc1.frequency
	 , odc1.projectedMinutes
  from dbo.ORP_DOCUMENTS_DATA_CORE (
      vc.clientID
	, vc.groupSvcClassNameID
	, vc.patID
	, null
	, null
	, vc.orpDocID
	, null) as odc1
) as odc2

/* For svc tracking class 300 */

left join dbo.CLAIM_IEPandIFSPNames             as cip    on cip.IEP_IFSP_NAME_ID  = vc.nameID
left join dbo.CLAIM_NoPlanNames                 as cnp    on cnp.NO_PLAN_NAME_ID   = vc.nameID
left join dbo.CLAIM_CYBHI_Names                 as ccy    on ccy.CYBHI_NAME_ID     = vc.nameID
left join dbo.CLAIM_RU_HEALTH_NAMES             as cru    on cru.RU_HEALTH_NAME_ID = vc.nameID
)
,

/*###########################################################################
 *#  Pass 2                                                                 #
 *#  - Specify columns from previous passes we will pass on to output.      #
 *#  - Calculate service tracking data                                      #
 *###########################################################################*/

cte_p2
as
(
select 
    p1.id
  , p1.caseloadEntryID
  , p1.clientID
  , p1.groupID
  , p1.groupName
  , p1.groupSvcClassNameID
  , p1.pracID
  , p1.patID
  , siteID = psvc.SITE_ID
  , siteName = psvc.SITE_NAME
  , p1.planType     
  , planTypeStr     = convert(varchar(50),p1.planType)
  , planTypeName	= iif(p1.planType = 1, 'IEP / IFSP', 'Other (IHP, 504, Counseling, etc.)')
  , p1.svcTrackingClass
  , svcTrackingClassStr = convert(varchar(50),p1.svcTrackingClass)
  , p1.svcTrackingClassName
  , p1.spEdFreqCode
  , p1.minsPerFreq
  , p1.startDate	
  , p1.endDate
  , p1.endDateOrCurrent
  , p1.currentDate
  , p1.maxEndDate
  , p1.planRanking 
  , p1.numRelatedScheduledServices
  , p1.numRelatedScheduledServicesCurrentlyInEffect
  , p1.schedulesExpired
  , p1.numOfSvcDetails

  , numMinsExpected  = case 
      when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED()          then pps2.totMinsExpected
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()      then odc2.totMinsExpected
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED() then sr2.totalMinutesExpected
	end

  , numMinsApplicable = case 
      when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED()          then pps2.totMinsApplicable
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()      then odc2.totMinsApplicable
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED() then sr2.totalMinutesSatisfied
	end

  , numMinsDiff = case 
      when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED()          then pps2.totMinsDiff
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()      then odc2.totMinsDiff
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED() then sr2.diffMinutesExpectedSatified
	end

  , numMinsPlans = case 
      when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED()          then pps2.totPlanMins
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()      then odc2.totPlanMins
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED() then sr2.totalMinutesExpected
	end

  , numMinsBreaks = case 
      when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED()          then pps2.totBreakMins
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()      then odc2.totBreakMins
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED() then 0
	end

  , numPlans = case 
      when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED()          then pps2.numPlans
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()      then odc2.numPlans
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED() then 1
	end
  
  , tmtDoseSummary = case 
      when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED()          then pps2.tmtDoseSummary
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()      then odc2.tmtDoseSummary
	  when p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED() then ''
	end
  
  , p1.spEdServiceCode
  , p1.spEdServiceName
  , p1.orpDocID
  , p1.orpDocName

  , p1.svcNamesListDataSourceID
  , p1.nameID
  , p1.svcName
  , p1.altModalityNameID
  , p1.viaTeleHealth
  , p1.svcTypeID
  , p1.planTypeID
  , p1.includeAltModalityInTracking

  , p1.startDateAssigned
  , p1.minsPerFreqAssigned
  , p1.hasSvcDetails
  , p1.svcDetailsJSON
  , p1.clientName
  , p1.pracName
  , p1.pracLastName
  , p1.pracFirstName

from cte_p1 as p1
join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID) as psvc on psvc.PATIENT_ID  = p1.patID

/* Tracking promised service */

outer apply (
   
    select 
        totMinsExpected   = sum(pdc1.totalMinutesExpected)
      , totMinsApplicable = sum(pdc1.totalMinutesSatisfied)
      , totMinsDiff       = sum(pdc1.diffMinutesExpectedSatified)
      , totPlanMins       = sum(pdc1.projectedTotalExpectedMinsForPlan)
	  , totBreakMins      = sum(pdc1.projectedTotalExpectedMinsForBreaks)
      , numPlans          = count(pdc1.idx)
	  , tmtDoseSummary    = string_agg(
	       '* From '
		  + (dbo.RPT_DATE_FMT(pdc1.startDate)
	      + ' to '
		  + dbo.RPT_DATE_FMT(pdc1.endDate)
	      + ' : ' 
		  + convert(varchar(50),pdc1.minsPerFreq)
		  + ' minutes ' 
		  + ssf1.name)
		, ' and ' )
	  	  
	from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE (
        p1.clientID                   
      , p1.patID
	  , p1.svcTrackingPracID  /* Either svcs entered by any prac or this prac */
      
	  , p1.spEdServiceCode    /* For plans associated with this service code */
	  , p1.startDate          /* For plans starting on this exact date */
	  , null
	  , p1.spEdFreqCode       /* For plans with this frequency */
	  , p1.minsPerFreq        /* And this minutes per frequency */
	  
	  , p1.svcTrackingMinsPerFreq  /* Calculate compliance based on plan mins or assigned mins */
      , p1.svcTrackingStartDate    /* Calculate compliance based on plan start or this start */
      , p1.endDateOrCurrent        
      , null   /*@patHasBIC*/
      , null   /*@patHasSSID*/
      , null   /*@billableSvcs*/
      , 1      /*@limitCalcToEndDate*/ 
      , 0      /*@calcPctExpectedSatisfied */
      , 0      /*@calcPotLostReimbursement */
	  , 1      /*@limitDosToStartEndDate*/
	  , 1      /*@reqPatSvcCode*/
	  , @useMinsPerFreqAssigned      /*@usePpsSvcTermsProvided*/
	  , 1 /* Pat absent counts as mins satisfied */
	  , @disableComplianceCalc /* exit without calc */
	) 
	as pdc1
	join dbo.SpEd_Service_Frequency as ssf1 on ssf1.codeValue = pdc1.spEdFreqCode

    where (
        (p1.spEdServiceCode is not null)
	and (p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED())		
	)
    group by 
        pdc1.clientID
	  , pdc1.patID	
) as pps2

/* Tracking order */

outer apply (

  /* Determine service delivery compliance (realtime) */
  
  select 
      totMinsExpected   = sum(odc1.totalMinutesExpected)
    , totMinsApplicable = sum(odc1.totalMinutesSatisfied)
    , totMinsDiff       = sum(odc1.diffMinutesExpectedSatified)
	, totPlanMins       = sum(odc1.projectedTotalExpectedMinsForPlan)
	, totBreakMins      = sum(odc1.projectedTotalExpectedMinsForBreaks)
	, numPlans          = count(odc1.idx)
  	, tmtDoseSummary    = string_agg(
	       '* From '		
		  + (dbo.RPT_DATE_FMT(odc1.startDate)
	      + ' to '
		  + dbo.RPT_DATE_FMT(odc1.endDate)
	      + ' : ' 
		  + convert(varchar(50),odc1.minsPerFreq)
		  + ' minutes ' 
		  + ssf1.name)
		, ' and ' )

  from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_SUMMARY_VIEW_DATA_CORE (
      p1.clientID
    , p1.patID
    , p1.groupSvcClassNameID
    , null /* orpDocID */
    , p1.startDate
    , p1.endDateOrCurrent
    , null   /*@patHasBIC*/
    , null   /*@patHasSSID*/
    , null   /*@billableSvcs*/
    , 1      /*@limitCalcToEndDate*/ 
    , 0      /*@calcPctExpectedSatisfied */
    , 0      /*@calcPotLostReimbursement */
    , 1
	, 1 
	, @disableComplianceCalc /* exit without calc*/
	) as odc1
   
   join dbo.SpEd_Service_Frequency as ssf1 on ssf1.codeValue = odc1.spEdFreqCode

   where  (
         (p1.orpDocID is not null)
     and (p1.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED())      
   )
   group by 
        odc1.clientID
	  , odc1.patID	 
) as odc2

/* Tracking service */

outer apply (
  
  /* Determine service delivery compliance (realtime) */
  
  select top 1
      ppsbst1.totalMinutesExpected
	, ppsbst1.totalMinutesSatisfied
	, ppsbst1.diffMinutesExpectedSatified
  from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_BY_GRP_SVC_CLASS_SVC_TYPE_PLAN_TYPE_NAME_ID_SUMMARY_VIEW_DATA_CORE (
      p1.clientID
    , p1.patID
    , p1.spEdFreqCode 
	, p1.minsPerFreq  
    , p1.groupSvcClassNameID
	, p1.pracID
	, p1.svcTypeID
	, p1.planTypeID
	, p1.nameID
	, p1.altModalityNameID
	, p1.viaTeleHealth
	, p1.includeAltModalityInTracking
	, p1.startDate
    , p1.endDateOrCurrent
	, @disableComplianceCalc /* Exit without calc */) as ppsbst1  
) as sr2

)
,

/*###########################################################################
 *#  Pass 3                                                                 #
 *#  - Get names and str reps of various fields                             #
 *###########################################################################*/

cte_p3
as
(
select 
    p2.*
  , patName             = pap.CONCAT_NAME
  , patLastName         = pap.LAST_NAME
  , patFirstName        = pap.FIRST_NAME
  , patSSID             = isnull(pap.CSIS,N'')  
  , dob                 = pap.DATE_OF_BIRTH
  , dobStr              = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
  , spEdCaseManagerName = isnull(pap.spEdCaseManagerName,'')
  , altFormat           = isnull(pap.altFormat,'')
  , spEdFreqName        = isnull(ssf.name,'')
  , startDateStr        = dbo.RPT_DATE_FMT(p2.startDate)
  , startDateStrYMD     = dbo.RPT_DATE_FMT_YYYY_MM_DD(p2.startDate)
  , endDateStr          = dbo.RPT_DATE_FMT(p2.endDate)
  , endDateStrYMD       = dbo.RPT_DATE_FMT_YYYY_MM_DD(p2.endDate)
  , endDateOrCurrentStr = dbo.RPT_DATE_FMT(p2.endDateOrCurrent)
  , endDateOrCurrentYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(p2.endDateOrCurrent)
  
  , svcTrackingName = svcTrackingClassName + ' - ' + case 
      when p2.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED()          then p2.spEdServiceName
	  when p2.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()      then p2.orpDocName
	  when p2.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED() then p2.svcName 	   
	end

  , groupSvcClassName     = scn.GROUP_SERVICE_CLASS_NAME
  , pctExpectedApplicable = dbo.CALC_PERCENTAGE (p2.numMinsApplicable, p2.numMinsExpected, 1, 1 ,0) /* Note: We use calc_percentage instead of percentage_fullfillment because we want users to see if they over delivered */
  
  , startDateAssignedStr    = dbo.RPT_DATE_FMT(p2.startDateAssigned)
  , startDateAssignedStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(p2.startDateAssigned)

  , minsPerFreqAssignedStr    = convert(varchar(256),p2.minsPerFreqAssigned)
  
  , hasSvcDetailsStr          = dbo.RPT_BIT_TO_YN(p2.hasSvcDetails)  
  , minsPerFreqStr            = convert(varchar(256),p2.minsPerFreq)
  , minsPerFreqIsCombinedMins = convert(bit,(iif((p2.hasSvcDetails = 1),iif((p2.numOfSvcDetails > 1),1,0),0)))
  , hasAssignedMin            = convert(bit,(iif((p2.minsPerFreq != p2.minsPerFreqAssigned),1,0)))
  , hasAssignedStartDate      = convert(bit,(iif((p2.startDate   != p2.startDateAssigned),1,0)))

from cte_p2 as p2

join      dbo.PATIENTS_Patient                   as pap on pap.PATIENT_ID                  = p2.patID
join      dbo.GROUP_GROUP_SERVICE_CLASS_NAMES    as scn on scn.GROUP_SERVICE_CLASS_NAME_ID = p2.groupSvcClassNameID
left join dbo.SpEd_Service_Frequency             as ssf on ssf.codeValue                   = p2.spEdFreqCode


)
,

/*###########################################################################
 *#  Pass 4                                                                 #
 *# - Create various str versions of fields                                 #
 *###########################################################################*/

cte_p4
as
(
select 
    p3.* 
  , pctExpectedApplicableStr              = convert(varchar(50),p3.pctExpectedApplicable) + '%'

  , minsPerFreqAndSpEdFreqName            = p3.minsPerFreqStr 
                                          + iif((p3.minsPerFreqIsCombinedMins = 1),' Combined','')
										  + ' Mins ' 										  
										  + p3.spEdFreqName
										  
  , minsPerFreqAssignedStrAndSpEdFreqName = isnull(p3.minsPerFreqAssignedStr,'?')                                             
											+ ' Mins ' 
											+ p3.spEdFreqName         
  
  , minsPerFreqIsCombinedMinsStr = dbo.RPT_BIT_TO_YN(p3.minsPerFreqIsCombinedMins)

  , assignedEntirePlan = convert(bit, (case 
      when p3.hasAssignedMin = 0 and p3.hasAssignedStartDate  = 0 then 1
      when p3.hasAssignedMin = 0 and p3.hasAssignedStartDate  = 1 then 0
	  when p3.hasAssignedMin = 1 and p3.hasAssignedStartDate  = 0 then 0
	  when p3.hasAssignedMin = 1 and p3.hasAssignedStartDate  = 1 then 0
	end))

from cte_p3 as p3
)

/*###########################################################################
 *#  Output                                                                 #
 *###########################################################################*/

select top (dbo.CONST_MAX_ROWS())
    p4.* 
  , [name] = p4.svcTrackingName  
  , assignedEntirePlanStr = dbo.RPT_BIT_TO_YN(p4.assignedEntirePlan)
  , startDateAssignedStrMinsPerFreqAssignedStrAndSpEdFreqName = p4.startDateAssignedStr + ' ' + p4.minsPerFreqAssignedStrAndSpEdFreqName
  , pgm.patGroupMembershipJSON
from cte_p4 as p4

cross apply (

  select 
    patGroupMembershipJSON = isnull(convert(varchar(max),(
      select 
          ppg.id
        , ppg.groupName 
        , memberID = ppgm.id
      from dbo.PRACTITIONER_PATIENT_GROUP        as ppg
      join dbo.PRACTITIONER_PATIENT_GROUP_MEMBER as ppgm on ppgm.pracPatGroupID = ppg.id
      where (
            (ppg.clientID = p4.clientID)
        and (ppg.pracID   = p4.pracID)
        and (ppgm.patID   = p4.patID)  
      )
      for json path
    )),'[]')
) as pgm

order by 
   p4.clientName
 , p4.patName
 , p4.startDate

) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW] TO [webuser]
GO