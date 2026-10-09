/*###########################################################
 *#
 *# NOTE: This is the "heart" of the CDE current audit views 
 *#
 *###########################################################
 */

USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View_Core
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View_Core] (
    @clientID                      bigint 
  , @patID                         bigint 
  , @calcPctExpectedSatisfied      bit = 0
  , @patAbsentMinsAreSatisfiedMins bit = 1  /* CDE added guidance for 2024 audit that stated that patient absence DOES NOT count as mins satisfied.  */
)
    
returns @recs table (
   patientsPromisedServicesCDEAuditsCurrentID         bigint
 , patientsPromisedServicesCDEAuditsCurrentPatientsID bigint
 , clientID                                           bigint
 , patID                                              bigint
 , patHasBIC                                          bit
 , patHasSSID                                         bit
 , spEdExitedSpEdDate                                 date
 , spEdServiceCode                                    int
 , startDate                                          date
 , endDate                                            date
 , planStartDate                                      date
 , planEndDate                                        date
 , spEdFreqCode                                       int
 , minsPerFreq                                        int
 , projectedTotalExpectedMinsForPlan                  int
 , projectedTotalExpectedMinsForBreaks                int
 , totalMinutesExpected                               int
 , totalMinutesSatisfied                              int
 , diffMinutesExpectedSatified                        int
 , lessThanExpected                                   bit
 , potentialLostReimbursment                          money
 , billableSvc                                        bit
 , generatedOn                                        datetime
 , ppxIdx                                             bigint
 , idx                                                bigint
 , hasUserProvidedDeliveryComplianceStat              bit
 , userProvidedDeliveryComplianceMinsExpected         int
 , userProvidedDeliveryComplianceMinsSatisfied        int
 , userProvidedDeliveryCompliancePctSatisfied         int
 , userProvidedDeliveryComplianceNotes                varchar(max)
 , moreThanExpected                                   bit
 , pctExpectedSatisfied                               real
 , moreThanExpectedCtr                                int
 , notes                                              varchar(max) default('')
 , siteID                                             bigint
 , cdeAuditStartDate                                  date
 , cdeAuditEndDateOrCurrent                           date
 , cdeAuditID                                         bigint
 , numPatAbsentTot                                    int
 , numPracAbsentTot                                   int
 , numSvcRecs                                         int
)

begin
 
declare @today                   as date = getdate()
declare @auditID                 as bigint
declare @auditStartDate          as datetime
declare @auditEndDateOrCurrent   as datetime

declare @auditPats as table (
     patID                                              bigint
   , patientsPromisedServicesCDEAuditsCurrentPatientsID bigint
   , siteID                                             bigint
  unique clustered (patID)
)

declare @ppsForCurAud as table (
   patientsPromisedServicesCDEAuditsCurrentID         bigint
 , patientsPromisedServicesCDEAuditsCurrentPatientsID bigint
 , clientID                                           bigint
 , patID                                              bigint
 , patHasBIC                                          bit
 , patHasSSID                                         bit
 , spEdExitedSpEdDate                                 date
 , spEdServiceCode                                    int
 , startDate                                          date
 , endDate                                            date
 , planStartDate                                      date
 , planEndDate                                        date
 , spEdFreqCode                                       int
 , minsPerFreq                                        int
 , projectedTotalExpectedMinsForPlan                  int
 , projectedTotalExpectedMinsForBreaks                int
 , totalMinutesExpected                               int
 , totalMinutesSatisfied                              int
 , totalMinutesSatisfiedUpToExpected                  int
 , diffMinutesExpectedSatified                        int
 , lessThanExpected                                   bit
 , potentialLostReimbursment                          money
 , billableSvc                                        bit
 , nonPerPlanSvcMinsEntDurDosRange                    int
 , generatedOn                                        datetime
 , ppxIdx                                             bigint
 , idx                                                bigint
 , nonPeriodicPlan                                    bit default(0)
 , nonPeriodicPlanNeedToCheckForDataAdjust            bit default(0)
 , hasUserProvidedDeliveryComplianceStat              bit
 , userProvidedDeliveryComplianceMinsExpected         int
 , userProvidedDeliveryComplianceMinsSatisfied        int
 , userProvidedDeliveryCompliancePctSatisfied         int
 , userProvidedDeliveryComplianceNotes                varchar(max)
 , notes                                              varchar(max)
 , siteID                                             bigint
 , numPatAbsentTot                                    int
 , numPracAbsentTot                                   int
 , numSvcRecs                                         int
 , rowNum                                             int identity(1,1)
   unique clustered    (rowNum)
 , unique nonclustered (nonPeriodicPlan, rowNum)
)

/*#############################################################################################################################
  #                                             Get audit id and audit dates
  #############################################################################################################################*/  

select top 1 
      @auditID               = t1.id 
    , @auditStartDate        = t1.startDate
    , @auditEndDateOrCurrent = dbo.DATE_VALUE_OR_REPLACEMENT_IF_GT_LT(t1.endDate,@today,1)
from dbo.Patients_Promised_Services_CDE_Audits_Current as t1
where ( 
      (t1.clientID = @clientID)
  and (t1.active = 1)
)
option (recompile)

/*#############################################################################################################################
  #                                                   Get audit patients
  #############################################################################################################################*/  

insert into @auditPats (
     patID
   , patientsPromisedServicesCDEAuditsCurrentPatientsID
   , siteID 
)
select 
    t2.patID
  , patientsPromisedServicesCDEAuditsCurrentPatientsID = t2.id
  , ps2.siteID
from dbo.Patients_Promised_Services_CDE_Audits_Current_Patients as t2 

/*============================================================
 * Attempt to locate the site that the patient was at during
 * the audit period.
 *===========================================================*/  

outer apply (
  select top 1  
    siteID = psg.SITE_ID
  from dbo.PATIENT_SITES_GET(t2.patID) as psg
  where (@auditStartDate between psg.START_DATE and psg.END_DATE)  
  order by 
    psg.PATIENT_SCHOOL_ID desc
  , psg.START_DATE desc
) as ps2
where ( 
      (t2.patientsPromisedServicesCDEAuditsCurrentID = @auditID)
  and ((@patID is null) or (t2.patID = @patID))
)
option (recompile)

/*============================================================
 * For the cases where the site that the patient was at during
 * the audit period could not be located, use the patients
 * current site.
 *===========================================================*/  

update ap
  set ap.siteID = psvc.SITE_ID
from @auditPats as ap
join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID) as psvc on psvc.PATIENT_ID = ap.patID
where (ap.siteID is null)
option (recompile)

/*#############################################################################################################################
  #                                               Get Expected/Entered Data
  #############################################################################################################################*/  

;with
cte_p2
as
(
  /*============================================================
   * For each patient in the audit
   *===========================================================*/  

  select 
      patientsPromisedServicesCDEAuditsCurrentID          = @auditID
	, patientsPromisedServicesCDEAuditsCurrentPatientsID  = t1.patientsPromisedServicesCDEAuditsCurrentPatientsID
    , t1.siteID
    , ps2.*
  from @auditPats as t1  

  /*============================================================
   * Get service record and service exceptions summary for
   * each plan each patient has that is in effect during the
   * audit period
   *===========================================================*/  

  cross apply (
    select 
      ps1.* 
    from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE (
        @clientID
      , t1.patID
	  , null -- pracID
      , null -- svcCode
	  , null
	  , null
      , null  -- freqCode
	  , null
	  , null  -- mins per freq assigned
	  , @auditStartDate
      , @auditEndDateOrCurrent
      , null   /*@patHasBIC*/
      , null   /*@patHasSSID*/
      , null   /*@billableSvcs*/
      , 1      /*@limitCalcToEndDate*/ 
      , @calcPctExpectedSatisfied 
      , 0      /*@calcPotLostReimbursement */
	  , 1      /*@limitDosToStartEndDate*/
	  , 0     /*@reqPatSvcCode*/
	  , 0     /*@usePpsSvcTermsProvided*/
	  , @patAbsentMinsAreSatisfiedMins /* Pat absent counts as mins satisfied */
	  , 0 /* Exit without calc */
    ) as ps1
  ) as ps2
)
,
cte_p3
as
(

  /*============================================================
   * For each patient and plan result set found
   * get any user provided delivery compliance stats (if any)
   *===========================================================*/  

  select 
      p2.*
    , hasUserProvidedDeliveryComplianceStat       = convert(bit,(iif((updcs2.id is not null),1,0)))
    , userProvidedDeliveryComplianceMinsExpected  = isnull(updcs2.minsExpected,p2.totalMinutesExpected)
    , userProvidedDeliveryComplianceMinsSatisfied = isnull(updcs2.minsSatisfied,0)
    , userProvidedDeliveryCompliancePctSatisfied  = isnull(updcs2.pctExpectedApplicable,0)
    , userProvidedDeliveryComplianceNotes         = isnull(updcs2.notes,'')
  from cte_p2 as p2

  outer apply (
    select top 1
        updcs1.id
      , updcs1.minsExpected
	  , updcs1.minsSatisfied
	  , updcs1.pctExpectedApplicable
      , updcs1.notes
    from dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_User_Provided_Delivery_Compliance_Stats as updcs1 
  
    /* Match index predicate */
    where (
          (updcs1.patientsPromisedServicesCDEAuditsCurrentPatientsID = p2.patientsPromisedServicesCDEAuditsCurrentPatientsID)
      and (updcs1.spEdServiceCode = p2.spEdServiceCode)
	  and (updcs1.planStartDate   = p2.planStartDate)
	  and (updcs1.spEdFreqCode    = p2.spEdFreqCode)
	  and (updcs1.minsPerFreq     = p2.minsPerFreq)	
	  and (updcs1.active = 1)
	  and (updcs1.id is not null)
    )  
  ) as updcs2
)

/*#############################################################################################################################
  #                                             Store Data Temporarily
  #############################################################################################################################*/  

insert into @ppsForCurAud (
   patientsPromisedServicesCDEAuditsCurrentID 
 , patientsPromisedServicesCDEAuditsCurrentPatientsID
 , clientID
 , patID
 , patHasBIC 
 , patHasSSID
 , spEdExitedSpEdDate
 , spEdServiceCode 
 , startDate 
 , endDate 
 , planStartDate 
 , planEndDate 
 , spEdFreqCode
 , minsPerFreq 
 , projectedTotalExpectedMinsForPlan 
 , projectedTotalExpectedMinsForBreaks 
 , totalMinutesExpected 
 , totalMinutesSatisfied 
 , totalMinutesSatisfiedUpToExpected
 , diffMinutesExpectedSatified
 , lessThanExpected
 , potentialLostReimbursment 
 , billableSvc
 , nonPerPlanSvcMinsEntDurDosRange
 , generatedOn 
 , ppxIdx 
 , idx 
 , nonPeriodicPlan                              
 , nonPeriodicPlanNeedToCheckForDataAdjust 
 , hasUserProvidedDeliveryComplianceStat  
 , userProvidedDeliveryComplianceMinsExpected
 , userProvidedDeliveryComplianceMinsSatisfied
 , userProvidedDeliveryCompliancePctSatisfied 
 , userProvidedDeliveryComplianceNotes
 , siteID
 , numPatAbsentTot
 , numPracAbsentTot
 , numSvcRecs
)
select 
    patientsPromisedServicesCDEAuditsCurrentID 
  , patientsPromisedServicesCDEAuditsCurrentPatientsID
  , clientID
  , patID
  , patHasBIC 
  , patHasSSID
  , spEdExitedSpEdDate
  , spEdServiceCode 
  , startDate 
  , endDate 
  , planStartDate 
  , planEndDate 
  , spEdFreqCode
  , minsPerFreq 
  , projectedTotalExpectedMinsForPlan 
  , projectedTotalExpectedMinsForBreaks 
  , totalMinutesExpected 
  , totalMinutesSatisfied 
  , totalMinutesSatisfiedUpToExpected
  , diffMinutesExpectedSatified
  , lessThanExpected
  , potentialLostReimbursment 
  , billableSvc
  , nonPerPlanSvcMinsEntDurDosRange
  , generatedOn 
  , ppxIdx 
  , idx 
  , nonPeriodicPlan                         = isNonPeriodicPlan
  , nonPeriodicPlanNeedToCheckForDataAdjust = isNonPeriodicPlan
  , hasUserProvidedDeliveryComplianceStat  
  , userProvidedDeliveryComplianceMinsExpected
  , userProvidedDeliveryComplianceMinsSatisfied
  , userProvidedDeliveryCompliancePctSatisfied 
  , userProvidedDeliveryComplianceNotes
  , siteID
  , numPatAbsentTot
  , numPracAbsentTot
  , numSvcRecs
from cte_p3 as p3
OPTION(recompile)

/*#############################################################################################################################
  #                        Apply exceptions (if any) for non periodic plans for this audit
  #                      We need to do this because the audit period may be less than a year
  #############################################################################################################################*/  

/*============================================================
 * Add notes for yearly and other where the plan minutes are
 * satisfied and clear our check for data adjust flag.  
 * We will skip these in the next set of checks.
 *===========================================================*/  

update @ppsForCurAud
set   
    notes                                   = 'Minutes expected are satisfied'
  , nonPeriodicPlanNeedToCheckForDataAdjust = 0
where ( 
        (nonPeriodicPlan                         = 1)
	and (nonPeriodicPlanNeedToCheckForDataAdjust = 1)
	and (lessThanExpected = 0)                          
)

/*============================================================
 * Add notes for yearly and other where the plan ended during
 * the audit period and not all minutes are satisfied
 * and clear our check for data adjust flag.  
 * We will skip these in the next set of checks.
 *===========================================================*/  

update @ppsForCurAud
set   
    notes                                   = 'This plan ends during the audit period and all expected minutes have yet to be satisfied. All minutes expected for the plan need to be accounted for.'
  , nonPeriodicPlanNeedToCheckForDataAdjust = 0
where ( 
        (nonPeriodicPlan = 1)
	and (nonPeriodicPlanNeedToCheckForDataAdjust = 1)
	and (lessThanExpected = 1)                      
    and (planEndDate between startDate and endDate) 
)

/*============================================================
 * Apply adjustements (from CDE FAQ on Yearly) 
 * for non periodic plans WHERE minutes were satisified
 * during the audit period and clear our check for data 
 * adjust flag. We will skip these in the next set of checks.
 *
 * CDE basically said use minutes you planned on delivering 
 * during period as mins expected and use minutes actually 
 * delivered as mins satisfied.
 *
 * Please note the adjustements to minutes expected, satisified
 * etc. 
 *===========================================================*/  

update @ppsForCurAud
set 
    totalMinutesExpected                    = nonPerPlanSvcMinsEntDurDosRange
  , totalMinutesSatisfied                   = nonPerPlanSvcMinsEntDurDosRange
  , totalMinutesSatisfiedUpToExpected       = nonPerPlanSvcMinsEntDurDosRange
  , diffMinutesExpectedSatified             = 0 
  , lessThanExpected                        = 0
  , nonPeriodicPlanNeedToCheckForDataAdjust = 0
  , notes                                   = 'This plan does not end during the audit period, minutes are still owed, and minutes have been satisfied during the audit period.  Per CDE guidance for this audit only the minutes expected during the audit period need to be accounted for.'
where ( 
        (nonPeriodicPlan                         = 1)
	and (nonPeriodicPlanNeedToCheckForDataAdjust = 1)
	and (lessThanExpected = 1)                          /* Plan was not already satisfied */
    and (planEndDate not between startDate and endDate) /* Plan did not end during audit period */
	and (nonPerPlanSvcMinsEntDurDosRange != 0)          /* Services were entered into SpEdCare between audit start and end period */
)
 
/*============================================================
 * Apply adjustements (from CDE FAQ on Yearly) 
 * for non periodic plans where NO minutes were satisified
 * during the audit period and clear our check for data 
 * adjust flag. There should be no futher checks needed.
 *
 * CDE basically said use minutes you planned on delivering 
 * during period as mins expected and use minutes actually 
 * delivered as mins satisfied.
 * 
 * In these cases we show annual minutes epxected
 * We keep totalMinutesExpected as annual total
 *===========================================================*/  

update @ppsForCurAud
set         
    totalMinutesExpected                    = (totalMinutesExpected - totalMinutesSatisfied) /* We show remainder if any*/
  , totalMinutesSatisfied                   = 0
  , diffMinutesExpectedSatified             = (totalMinutesExpected - totalMinutesSatisfied)
  , totalMinutesSatisfiedUpToExpected       = 0  
  , nonPeriodicPlanNeedToCheckForDataAdjust = 0
  , notes                                   = 'This plan does not end during the audit period, minutes are still owed, and no minutes were satisfied during the audit period.  Per CDE guidance for this audit only the minutes expected during the audit period need to be accounted for.'
where ( 
        (nonPeriodicPlan                         = 1)
	and (nonPeriodicPlanNeedToCheckForDataAdjust = 1)
	and (lessThanExpected = 1)                          /* Plan was not already satisfied */
    and (planEndDate not between startDate and endDate) /* Plan did not end during audit period */
	and (nonPerPlanSvcMinsEntDurDosRange = 0)           /* Services were not entered into SpEdCare between audit start and end period */
)

/*#############################################################################################################################
  #                                                   Generate output
  #############################################################################################################################*/  

;
with
cte_p4
as
(
select  
    p3.patientsPromisedServicesCDEAuditsCurrentID
  , p3.patientsPromisedServicesCDEAuditsCurrentPatientsID
  , p3.clientID
  , p3.patID 
  , p3.patHasBIC
  , p3.patHasSSID 
  , p3.spEdExitedSpEdDate
  , p3.spEdServiceCode
  , p3.startDate 
  , p3.endDate 
  , p3.planStartDate
  , p3.planEndDate
  , p3.spEdFreqCode 
  , p3.minsPerFreq
  , p3.projectedTotalExpectedMinsForPlan
  , p3.projectedTotalExpectedMinsForBreaks

  , totalMinutesExpected = iif ((p3.hasUserProvidedDeliveryComplianceStat = 1)
                                , p3.userProvidedDeliveryComplianceMinsExpected
                                , p3.totalMinutesExpected
                          )
	
  , totalMinutesSatisfied = iif ((p3.hasUserProvidedDeliveryComplianceStat = 1)
                                , p3.userProvidedDeliveryComplianceMinsSatisfied
                                , p3.totalMinutesSatisfiedUpToExpected
                          )						  
 
  , p3.diffMinutesExpectedSatified
  , p3.lessThanExpected 
  , p3.potentialLostReimbursment
  , p3.billableSvc 
  , p3.generatedOn 
  , p3.ppxIdx
  , p3.idx 
  , p3.hasUserProvidedDeliveryComplianceStat
  , p3.userProvidedDeliveryComplianceMinsExpected
  , p3.userProvidedDeliveryComplianceMinsSatisfied
  , p3.userProvidedDeliveryCompliancePctSatisfied
  , p3.userProvidedDeliveryComplianceNotes
  , moreThanExpected = convert(bit,(iif((p3.diffMinutesExpectedSatified < 0),1,0)))
  , p3.notes
  , p3.siteID

  , p3.numPatAbsentTot
  , p3.numPracAbsentTot
  , p3.numSvcRecs

from @ppsForCurAud as p3
)
 
insert into @recs (
   patientsPromisedServicesCDEAuditsCurrentID 
 , patientsPromisedServicesCDEAuditsCurrentPatientsID
 , clientID
 , patID
 , patHasBIC 
 , patHasSSID
 , spEdExitedSpEdDate
 , spEdServiceCode 
 , startDate 
 , endDate 
 , planStartDate 
 , planEndDate 
 , spEdFreqCode
 , minsPerFreq 
 , projectedTotalExpectedMinsForPlan 
 , projectedTotalExpectedMinsForBreaks 
 , totalMinutesExpected 
 , totalMinutesSatisfied 
 , diffMinutesExpectedSatified
 , lessThanExpected
 , potentialLostReimbursment 
 , billableSvc
 , generatedOn 
 , ppxIdx 
 , idx 
 , hasUserProvidedDeliveryComplianceStat 
 , userProvidedDeliveryComplianceMinsExpected  
 , userProvidedDeliveryComplianceMinsSatisfied 
 , userProvidedDeliveryCompliancePctSatisfied
 , userProvidedDeliveryComplianceNotes 
 , moreThanExpected 
 , pctExpectedSatisfied 
 , moreThanExpectedCtr 
 , notes
 , siteID
 , cdeAuditStartDate
 , cdeAuditEndDateOrCurrent
 , cdeAuditID
 , numPatAbsentTot
 , numPracAbsentTot
 , numSvcRecs  
)
select 
    patientsPromisedServicesCDEAuditsCurrentID 
  , patientsPromisedServicesCDEAuditsCurrentPatientsID
  , clientID
  , patID
  , patHasBIC 
  , patHasSSID
  , spEdExitedSpEdDate
  , spEdServiceCode 
  , startDate 
  , endDate 
  , planStartDate 
  , planEndDate 
  , spEdFreqCode
  , minsPerFreq 
  , projectedTotalExpectedMinsForPlan 
  , projectedTotalExpectedMinsForBreaks 
  , totalMinutesExpected 
  , totalMinutesSatisfied 
  , diffMinutesExpectedSatified
  , lessThanExpected
  , potentialLostReimbursment 
  , billableSvc
  , generatedOn 
  , ppxIdx 
  , idx 
  , hasUserProvidedDeliveryComplianceStat
  , userProvidedDeliveryComplianceMinsExpected 
  , userProvidedDeliveryComplianceMinsSatisfied
  , userProvidedDeliveryCompliancePctSatisfied
  , userProvidedDeliveryComplianceNotes
  , moreThanExpected  
  , pctExpectedSatisfied = null                              
  , moreThanExpectedCtr = convert(int,(iif((p4.moreThanExpected = 1),1,0)))
  , notes
  , siteID
  , @auditStartDate
  , @auditEndDateOrCurrent
  , @auditID
  , numPatAbsentTot
  , numPracAbsentTot
  , numSvcRecs  
from cte_p4 as p4

/*#############################################################################################################################
  #                                           Calculate percentage if required
  #############################################################################################################################*/  

if (@calcPctExpectedSatisfied = 1)
begin
  update @recs set pctExpectedSatisfied = dbo.CALC_PERCENTAGE_Fulfillment (totalMinutesSatisfied, totalMinutesExpected)
end

/*#############################################################################################################################
  #                                                     Done
  #############################################################################################################################*/  

return

end
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View_Core] TO [webuser]
GO