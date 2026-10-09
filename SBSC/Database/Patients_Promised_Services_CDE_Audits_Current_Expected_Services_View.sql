USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View] (
    @userID      bigint
  , @userGroup   int   
  , @userRank    int 
  , @clientID    bigint   
  , @patID       bigint  
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
      t1.* 
    , patName                  = pap.CONCAT_NAME 
	, patLastName              = pap.LAST_NAME
	, patFirstName             = pap.FIRST_NAME
    , patDOBStr                = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
    , patSSID                  = isnull(pap.CSIS,N'')
    , patBIC                   = N'' /* Intentionally left blank */
    , spEdCaseManagerName      = isnull(pap.spEdCaseManagerName,'')
    , spEdExitedSpEdDateStr    = dbo.RPT_DATE_FMT(t1.spEdExitedSpEdDate)
    , spEdServiceName          = ss.[name]
    , spEdServiceCodeAndName   = convert(varchar(50),t1.spEdServiceCode) + ' - ' + ss.[name]			
    , spEdFreqName             = ssf.[name]
    , planStartDateStr         = dbo.RPT_DATE_FMT(t1.planStartDate)
    , planEndDateStr           = dbo.RPT_DATE_FMT(t1.planEndDate)
	, startDateStr             = dbo.RPT_DATE_FMT(t1.startDate)
	, endDateStr               = dbo.RPT_DATE_FMT(t1.endDate)
	, totMinsExpected          = t1.totalMinutesExpected
    , totMinsApplicable        = t1.totalMinutesSatisfied
    , totMinsDiff              = t1.diffMinutesExpectedSatified
    , pctExpectedApplicable    = t1.pctExpectedSatisfied
    , pctExpectedApplicableStr = convert(varchar(50),t1.pctExpectedSatisfied) + '%'
	, hasUserProvidedDeliveryComplianceStatStr = dbo.RPT_BIT_TO_YN(t1.hasUserProvidedDeliveryComplianceStat)
	, usersToFollowupWithJSON  = dbo.Patients_Promised_Services_Find_Possible_Users_Responsible_For_Pat (  t1.clientID
	                                                                                                     , t1.patID
	                                                                                                     , t1.planStartDate
	                                                                                                     , t1.planEndDate
	                                                                                                     , null
	                                                                                                     , t1.spEdServiceCode
	                                                                                                     , null
																										 , pap.spEdCaseManagerName)
   , siteName   = pss.SITE_NAME
   , moreThanExpectedStr  = dbo.RPT_BIT_TO_YN(t1.moreThanExpected)
   , numOverDeliveredMins = iif((t1.moreThanExpected = 1),abs(t1.diffMinutesExpectedSatified),0)
   , minsPerFreqStr       = convert(varchar(50),t1.minsPerFreq)
   
  from dbo.Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View_Core (
      @clientID
    , @patID
    , 1
    , @patAbsentMinsAreSatisfiedMins) as t1

  join dbo.PATIENTS_Patient       as pap on pap.PATIENT_ID = t1.patID
  join dbo.SpEd_Service           as ss  on ss.codeValue   = t1.spEdServiceCode
  join dbo.SpEd_Service_Frequency as ssf on ssf.codeValue  = t1.spEdFreqCode  
  join dbo.SITES_Site             as pss on pss.SITE_ID    = t1.siteID
)
,
cte_p2
as
(

select 
    p1.*
  , planServiceDeliverySummary = p1.spEdServiceCodeAndName
                               + '<br><br><sup>'
							   + 'SpEd plan '   + p1.planStartDateStr
                               + ' to '           + p1.planEndDateStr                               
							   + ' | '            + p1.minsPerFreqStr 							   
							   + ' minutes / '   + p1.spEdFreqName 							   
							   + '</sup>'
from cte_p1 as p1
)
select top (dbo.CONST_MAX_ROWS())
  p2.*
from cte_p2 as p2
order by 
    p2.patName
  , p2.spEdServiceCode
  , p2.planStartDate
  , p2.planEndDate
) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View] TO [webuser]
GO