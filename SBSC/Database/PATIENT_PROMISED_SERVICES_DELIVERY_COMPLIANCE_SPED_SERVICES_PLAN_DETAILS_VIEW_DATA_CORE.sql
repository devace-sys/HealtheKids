/* Note: Only using option recompile in cases where permanent tables are accessed.  */

USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DETAILS_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DETAILS_VIEW_DATA_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DETAILS_VIEW_DATA_CORE] (
    @clientID                      bigint
  , @patID                         bigint
  , @spEdServiceCode               int  /* Original */
  , @startDate                     date /* Exact plan start date not range */
  , @endDate                       date /* Exact plan start date not range */
  , @spEdFreqCode                  int  /* Original or replacement */
  , @minsPerFreq                   int  /* Original or replacement */
  , @planInEffectStartDate         date /* Date range*/
  , @planInEffectEndDate           date /* Date range */
  , @patHasBIC                     bit
  , @patHasSSID                    bit
  , @billableSvcs                  bit
  , @limitCalcToEndDate            bit = 0   
  , @calcPctExpectedSatisfied      bit = 0
  , @calcPotLostReimbursement      bit = 0
  , @limitDosToStartEndDate        bit = 0
  , @patAbsentMinsAreSatisfiedMins bit = 1 )   

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
  , dosStart                             datetime
  , dosEnd                               datetime
  , projectedTotalExpectedMinsForPlan    int
  , projectedTotalExpectedMinsForBreaks  int  
  , totalMinutesExpected                 int
  , totalMinutesSatisfied                int
  , totalMinutesSatisfiedUpToExpected    int
  , pctExpectedSatisfied                 real
  , diffMinutesExpectedSatified          int
  , lessThanExpected                     bit
  , potentialLostReimbursment            money
  , isNonPeriodicPlan                    bit
  , billableSvc                          bit 
  , nonPerPlanSvcMinsEntDurDosRange      int
  , numPatAbsentTot                      int
  , numPracAbsentTot                     int
  , numSvcRecs                           int 
  , generatedOn                          datetime
  , ppsIdx                               bigint
  , idx                                  bigint identity(1,1)
  --unique clustered  (clientID, patID, spEdServiceCode, startDate, endDate, idx)
)     
as
begin

/*============================================================
 * Dont allow requests for all patients and all spedcodes
 * it will take too long to process
 *===========================================================*/  

if ((@patID is null) and (@spEdServiceCode is null)) return


declare @today                  as datetime = getdate()
declare @pps                    as PatientPromisedServicesPlans 
declare @svcMinsExpectedEntered as PatientPromisedServicesSvcMinsExpectedEnteredSummaryOrDetail

/*============================================================
 * Default dates to rolling 12 month
 *===========================================================*/  

if (@planInEffectStartDate is null) and (@planInEffectEndDate is null) 
begin

  select  @planInEffectStartDate = dbo.CALC_OLDEST_DOS_ALLOWED(@today)
        , @planInEffectEndDate   = @today
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
	, lpps.minsPerFreq
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
 * Get mins expected / entered
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
    smee2.ppsIdx
  , smee2.dosStart
  , smee2.dosEnd
  , smee2.minsProjectedForPlan
  , smee2.minsProjectedForBreak            
  , smee2.svcExceptionMinsToSubFromExpected
  , smee2.numMinsExpected                  
  , smee2.numSvcMinsEntered                
  , smee2.svcExceptionMinsToAddToSatisfied 
  , smee2.numMinsSatisfied
  , smee2.nonPeriodicPlanSvcMinsEnteredDuringDosRange                 
  , smee2.numPatAbsentTot             
  , smee2.numPracAbsentTot
  , smee2.numSvcRecs
from @pps as pps
cross apply (
  select 
    sme1.* 
  from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_SLOTS (
          pps.clientID
        , pps.patID
		, null
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
) as smee2
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
  , dosStart
  , dosEnd
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
  , ppsIdx
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
  , sme.dosStart
  , sme.dosEnd
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

return 
end 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DETAILS_VIEW_DATA_CORE] TO [webuser]
GO