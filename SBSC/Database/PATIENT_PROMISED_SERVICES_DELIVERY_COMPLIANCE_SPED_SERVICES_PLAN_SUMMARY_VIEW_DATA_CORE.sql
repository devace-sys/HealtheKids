USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE] (
    @clientID                      bigint
  , @patID                         bigint
  , @pracID                        bigint
  , @spEdServiceCode               int  /* Plan original */
  
  , @startDate                     date /* Exact plan start date not range */
  , @endDate                       date /* Exact plan start date not range */
  , @spEdFreqCode                  int  /* Plan original or replacement */
  , @minsPerFreq                   int  /* Plan original or replacement */

  , @minsPerFreqAssigned           int
  , @planInEffectStartDate         date /* Date range */
  , @planInEffectEndDate           date /* Date range */
  , @patHasBIC                     bit
  , @patHasSSID                    bit
  , @billableSvcs                  bit
  , @limitCalcToEndDate            bit = 0   
  , @calcPctExpectedSatisfied      bit = 0
  , @calcPotLostReimbursement      bit = 0
  , @limitDosToStartEndDate        bit = 0
  , @requireClientPatSvcCode       bit = 0
  , @useMinsPerFreqAssigned        bit = 0
  , @patAbsentMinsAreSatisfiedMins bit = 1
  , @exitWithoutCalculation        bit = 0
)   

returns @recs table  (
    clientID                             bigint
  , patID                                bigint  
  , patHasBIC                            bit
  , patHasSSID                           bit
  , spEdExitedSpEdDate                   date
  , spEdServiceCode                      int
  , startDate                            date
  , endDate                              date
  , planStartDate                        date
  , planEndDate                          date
  , spEdFreqCode                         int
  , minsPerFreq                          int
  , projectedTotalExpectedMinsForPlan    int
  , projectedTotalExpectedMinsForBreaks  int
  , totalMinutesExpected                 int
  , totalMinutesSatisfied                int
  , totalMinutesSatisfiedUpToExpected    int
  , pctExpectedSatisfied                 real
  , diffMinutesExpectedSatified          int
  , lessThanExpected                     bit
  , potentialLostReimbursment            money
  , billableSvc                          bit 
  , isNonPeriodicPlan                    bit
  , nonPerPlanSvcMinsEntDurDosRange      int
  , numPatAbsentTot                      int
  , numPracAbsentTot                     int
  , numSvcRecs                           int 
  , generatedOn                          datetime
  , ppxIdx                               bigint
  , idx                                  bigint identity(1,1)
  --  unique clustered  (clientID, patID, spEdServiceCode, startDate, endDate, idx)
)     
as
begin

if (@exitWithoutCalculation = 1) return

/*============================================================
 * Early return mode for optimizing patient specific reports
 *===========================================================*/  

if (@requireClientPatSvcCode = 1)
begin
  if (@spEdServiceCode is null) return
  if (@clientID        is null) return
  if (@patID           is null) return
end

/*============================================================
 * If we are using minsPerFreqAssigned then the pps will be 
 * limited to the svcCode, date range, and freq
 * and mins per freq looked up will be replaced with minAssigned
 * and the mins delivered will be limited to mins delivered 
 * by the prac.
 *
 * Note: The intended application for this is caseload mgmt
 * where pracs track the portion of a promised service that 
 * they have been assigned to deliver.  If you need to see
 * mins delivered by a prac towards total promised to pat
 * district wide, then set this flag to 0 and pass pracID. 
 *===========================================================*/  

if (@useMinsPerFreqAssigned = 1)
begin
  if (@clientID              is null) return
  if (@patID                 is null) return
  if (@pracID                is null) return
  if (@spEdServiceCode       is null) return
  if (@startDate             is null) return
  if (@spEdFreqCode          is null) return
  if (@minsPerFreq           is null) return
  
  if (@minsPerFreqAssigned   is null) return
  if (@planInEffectStartDate is null) return
  if (@planInEffectEndDate   is null) return
  if (@minsPerFreqAssigned <= 0)      return
end

declare @today                  as datetime = getdate()
declare @pps                    as PatientPromisedServicesPlans
declare @svcMinsExpectedEntered as PatientPromisedServicesSvcMinsExpectedEnteredSummaryOrDetail

/*============================================================
 * Default dates to rolling 12 month
 *===========================================================*/  

if (@planInEffectStartDate is null) and (@planInEffectEndDate is null) 
begin

  select  @planInEffectStartDate = dbo.CALC_OLDEST_DOS_ALLOWED (@today)
        , @planInEffectEndDate = @today
end


/*============================================================
 * Get promised service data
 *===========================================================*/  

insert into @pps (
    clientID
  , patID   
  , patHasBIC
  , patHasSSID
  , spEdExitedSpEdDate
  , spEdServiceCode   
  , spEdFreqCode
  , minsPerFreq 
  , startDate 
  , endDate 
  , planStartDate
  , planEndDate
  , isNonPeriodicPlan
  , avgRate             
  , avgUnitPerMinFactor 
  , billableSvc         
)
select   
      lpps.clientID
    , lpps.patID
    , lpps.patHasBIC
	, lpps.patHasSSID
	, lpps.spEdExitedSpEdDate
	, lpps.spEdServiceCode
	, lpps.spEdFreqCode
	, minsPerFreq = iif((@useMinsPerFreqAssigned = 0),lpps.minsPerFreq, @minsPerFreqAssigned)
	, lpps.startDate
    , lpps.endDate
	, lpps.planStartDate
    , lpps.planEndDate
    , isNonPeriodicPlan
	, avgRate             
    , avgUnitPerMinFactor 
    , billableSvc         
from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DATA_VIEW_CORE (
    @clientID
  , @patID
  , @spEdServiceCode
  , @startDate 
  , @endDate
  , @spEdFreqCode
  , @minsPerFreq 
  , @planInEffectStartDate
  , @planInEffectEndDate
  , @patHasBIC
  , @patHasSSID
  , @billableSvcs
  , @limitCalcToEndDate
  , @limitDosToStartEndDate) as lpps
OPTION(recompile)

/*============================================================
 * Get summary of mins expected / entered
 *===========================================================*/  

insert into @svcMinsExpectedEntered (
    ppsIdx
  , dosStart
  , dosEnd
  , minsProjectedForPlan
  , minsProjectedForBreak            
  , svcExceptionMinsToSubFromExpected
  , numMinsExpected                  
  , numSvcMinsEntered                
  , svcExceptionMinsToAddToSatisfied 
  , numMinsSatisfied
  , nonPerPlanSvcMinsEntDurDosRange    
  , numPatAbsentTot             
  , numPracAbsentTot
  , numSvcRecs
)
select 
    ppsIdx   = pps.idx
  , dosStart = @planInEffectStartDate
  , dosEnd   = @planInEffectEndDate
  , sme2.minsProjectedForPlan
  , sme2.minsProjectedForBreak            
  , sme2.svcExceptionMinsToSubFromExpected
  , sme2.numMinsExpected                  
  , sme2.numSvcMinsEntered                
  , sme2.svcExceptionMinsToAddToSatisfied 
  , sme2.numMinsSatisfied          
  , sme2.nonPerPlanSvcMinsEntDurDosRange  
  , sme2.numPatAbsentTot 
  , sme2.numPracAbsentTot
  , sme2.numSvcRecs
from @pps as pps
cross apply (
 select       
 	    minsProjectedForPlan              = sum(sme1.minsProjectedForPlan)
      , minsProjectedForBreak             = sum(sme1.minsProjectedForBreak)            
      , svcExceptionMinsToSubFromExpected = sum(sme1.svcExceptionMinsToSubFromExpected)
      , numMinsExpected                   = sum(sme1.numMinsExpected)
      , numSvcMinsEntered                 = sum(sme1.numSvcMinsEntered)
      , svcExceptionMinsToAddToSatisfied  = sum(sme1.svcExceptionMinsToAddToSatisfied)
      , numMinsSatisfied                  = sum(sme1.numMinsSatisfied)
      , nonPerPlanSvcMinsEntDurDosRange   = sum(sme1.nonPeriodicPlanSvcMinsEnteredDuringDosRange)
	  , numPatAbsentTot                   = sum(sme1.numPatAbsentTot)
      , numPracAbsentTot                  = sum(sme1.numPracAbsentTot)
	  , numSvcRecs                        = sum(sme1.numSvcRecs)
     from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_SLOTS (
          pps.clientID
        , pps.patID
		, @pracID
        , pps.spEdServiceCode
        , pps.planStartDate
        , pps.planEndDate
        , pps.spEdFreqCode
        , pps.minsPerFreq
        , pps.startDate /* Used as dos */
        , pps.endDate   /* Used as dos */
        , pps.isNonPeriodicPlan
        , pps.idx
		, @patAbsentMinsAreSatisfiedMins
      ) as sme1  
    group by 
      sme1.ppsIdx
) as sme2
OPTION(recompile)

/*============================================================
 * Apply mins considered satisfied set points (if applicable)
 * overrides
 *===========================================================*/  

update sme
set 
sme.numMinsSatisfied = dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_APPLY_MINS_CONSIDERED_SATISFIED_SET_POINT (
    pps.clientID
  , pps.spEdServiceCode
  , pps.spEdFreqCode
  , pps.minsPerFreq
  , pps.planStartDate
  , pps.planEndDate
  , sme.numMinsExpected  
  , sme.numMinsSatisfied )
from @pps                    as pps
join @svcMinsExpectedEntered as sme on sme.ppsIdx = pps.idx
OPTION(recompile)

/*============================================================
 * Calculate diff and less than expected (keep these here)
 *===========================================================*/  

update @svcMinsExpectedEntered set diffMinsExpectedSatisfied = (numMinsExpected - numMinsSatisfied)
update @svcMinsExpectedEntered set lessThanExpected = 1 where ((numMinsExpected > 0) and (diffMinsExpectedSatisfied > 0))
update @svcMinsExpectedEntered set totalMinutesSatisfiedUpToExpected = dbo.INT_CAPPED_AT_MAX(numMinsSatisfied, numMinsExpected) 

/*============================================================
 * Calculate percent expected if required
 *===========================================================*/  

if (@calcPctExpectedSatisfied = 1)
begin
  update @svcMinsExpectedEntered set pctExpectedSatisfied = dbo.CALC_PERCENTAGE (numMinsSatisfied,numMinsExpected,1,1,0)
end

/*============================================================
 * Calculate potential lost reimbursement if required
 *===========================================================*/  

if (@calcPotLostReimbursement = 1)
begin                           

  update sme 
  set sme.potentialLostReimbursment = iif (((sme.diffMinsExpectedSatisfied > 0) and (pps.patHasBic = 1))
	  								     , convert(money,(round ( (pps.avgRate * (sme.diffMinsExpectedSatisfied / pps.avgUnitPerMinFactor ) ),2)))
									     , 0)									
  from @pps                    as pps
  join @svcMinsExpectedEntered as sme on sme.ppsIdx = pps.idx 
  OPTION(recompile)
end	

/*============================================================
 * Output
 *===========================================================*/  

insert into @recs (
    clientID
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
  , pctExpectedSatisfied
  , diffMinutesExpectedSatified
  , lessThanExpected
  , potentialLostReimbursment
  , billableSvc
  , isNonPeriodicPlan
  , nonPerPlanSvcMinsEntDurDosRange
  , numPatAbsentTot  
  , numPracAbsentTot 
  , numSvcRecs
  , generatedOn
  , ppxIdx
)
select
    pps.clientID
  , pps.patID
  , pps.patHasBIC
  , pps.patHasSSID
  , pps.spEdExitedSpEdDate 
  , pps.spEdServiceCode 
  , pps.startDate  
  , pps.endDate
  , pps.planStartDate
  , pps.planEndDate  
  , pps.spEdFreqCode 
  , pps.minsPerFreq 
  
  , sme.minsProjectedForPlan
  , sme.minsProjectedForBreak
  , sme.numMinsExpected
  , sme.numMinsSatisfied
  , sme.totalMinutesSatisfiedUpToExpected
  , sme.pctExpectedSatisfied
  , sme.diffMinsExpectedSatisfied
  , sme.lessThanExpected
  , sme.potentialLostReimbursment									
  , pps.billableSvc
  , pps.isNonPeriodicPlan
  , sme.nonPerPlanSvcMinsEntDurDosRange
  , sme.numPatAbsentTot   
  , sme.numPracAbsentTot 
  , sme.numSvcRecs
  , generatedOn = @today
  , sme.ppsIdx

from @pps                    as pps
join @svcMinsExpectedEntered as sme on sme.ppsIdx = pps.idx

OPTION(recompile)
/*
order by 
    pps.clientID
  , pps.patID
  , pps.spEdServiceCode
  , pps.startDate
  , pps.endDate
*/
return 
end 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE] TO [webuser]
GO