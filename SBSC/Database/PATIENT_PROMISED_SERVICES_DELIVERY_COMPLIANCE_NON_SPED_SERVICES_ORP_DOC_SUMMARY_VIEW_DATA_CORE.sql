USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_SUMMARY_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_SUMMARY_VIEW_DATA_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_SUMMARY_VIEW_DATA_CORE] (
    @clientID                 bigint
  , @patID                    bigint
  , @groupSvcClassNameID      bigint
  , @orpDocID                 bigint 
  , @planInEffectStartDate    date
  , @planInEffectEndDate      date
  , @patHasBIC                bit
  , @patHasSSID               bit
  , @billableSvcs             bit
  , @limitCalcToEndDate       bit = 0   
  , @calcPctExpectedSatisfied bit = 0
  , @calcPotLostReimbursement bit = 0
  , @limitDosToStartEndDate   bit = 0
  , @requireClientPatOrdCode  bit = 0
  , @exitWithoutCalculation   bit = 0
)
     
returns @recs table  (
    clientID                             bigint
  , patID                                bigint
  , patHasBIC                            bit
  , patHasSSID                           bit
  , groupSvcClassNameID                  bigint
  , orpDocID                             bigint
  , orpDocStandardSelectionNameID        bigint
  , orpDocTypeID                         bigint
  , orpDocRefID                          bigint
  , spEdFreqCode                         int
  , minsPerFreq                          int
  , startDate                            date
  , endDate                              date
  , planStartDate                        date
  , planEndDate                          date
  , projectedTotalExpectedMinsForPlan    int
  , projectedTotalExpectedMinsForBreaks  int
  , totalMinutesExpected                 int
  , totalMinutesSatisfied                int
  , pctExpectedSatisfied                 real
  , diffMinutesExpectedSatified          int
  , lessThanExpected                     bit
  , potentialLostReimbursment            money
  , billableSvc                          bit 
  , generatedOn                          datetime
  , idx                                  bigint identity(1,1)
    unique clustered  (clientID, patID, groupSvcClassNameID, orpDocID, startDate, endDate, idx)
)     
begin

if (@exitWithoutCalculation = 1) return

/*============================================================
 * Early return mode for optimizing patient specific reports
 *===========================================================*/  

if (@requireClientPatOrdCode = 1)
begin
  if (@clientID is null)            return
  if (@patID    is null)            return
  if (@groupSvcClassNameID is null) return

end

declare @earliestPlanStart as datetime
declare @latestPlanEnd     as datetime
declare @numRows           as int = 0
declare @today             as datetime = getdate()

declare @orpDocs as table (
      idx                                  bigint identity(1,1) 
    , clientID                             int
    , patID                                int
	, patHasBIC                            bit
	, patHasSSID                           bit
    , groupSvcClassNameID                  bigint
	, orpDocID                             bigint
	, orpDocStandardSelectionNameID        bigint
	, orpDocTypeID                         bigint
    , orpDocRefID                          bigint
    , spEdFreqCode                         int
    , minsPerFreq                          int
    , startDate                            date
    , endDate                              date
	, planStartDate                        date
	, planEndDate                          date
    , startDateTime                        datetime
    , endDateTime                          datetime
	, billableSvc                          bit default(1)
    , projectedTotalExpectedMinsForPlan    int default(0)
    , projectedTotalExpectedMinsForBreaks  int default(0)
    , totalMinutesExpected                 int default(0)
    , totalMinutesSatisfied                int default(0)
	, diffMinutesExpectedSatified          int default(0)
	, lessThanExpected                     bit default(0)
  unique clustered (clientID, patID, groupSvcClassNameID, orpDocID, idx)
)

declare @expectedClientWideBreaks as table (
      startDate      datetime
    , endDate        datetime
    , idx            bigint identity(1,1)
  unique clustered (startDate,endDate,idx)
)

declare @expectedPatSiteSpecificBreaks as table (
      patID          bigint
    , startDate      datetime
    , endDate        datetime
    , idx       bigint identity(1,1)
  unique clustered (patID, startDate, endDate, idx)
)

declare @svcMinsEntered as table (
      orpDocIdx         bigint
	, numMinsSatisfied  int
    , idx               bigint identity(1,1) 
  unique clustered (orpDocIdx, idx)
)

declare @rateData as table (
    groupSvcClassNameID bigint
  , rate                money
  , unitPerMinFactor    int
unique clustered (groupSvcClassNameID)
)

/*============================================================
 * Default dates to rolling 12 month
 *===========================================================*/  

if (@planInEffectStartDate is null) and (@planInEffectEndDate is null) 
begin

  select  @planInEffectStartDate = dbo.CALC_OLDEST_DOS_ALLOWED (@today)
        , @planInEffectEndDate = @today
end

/*============================================================
 * Check dates
 *===========================================================*/  

if (@planInEffectStartDate is null) return
if (@planInEffectEndDate   is null) return
if (@planInEffectStartDate > @planInEffectEndDate) return

/*============================================================
 * Get orp docs
 *===========================================================*/  

insert into @orpDocs (
    clientID
  , patID   
  , patHasBIC
  , patHasSSID 
  , groupSvcClassNameID
  , orpDocID  
  , orpDocStandardSelectionNameID
  , orpDocTypeID
  , orpDocRefID
  , spEdFreqCode 
  , minsPerFreq 
  , startDate 
  , endDate 
  , planStartDate
  , planEndDate  
  , startDateTime
  , endDateTime  
  , billableSvc
)
select
    ppsns.clientID
  , ppsns.patID 
  , ppsns.patHasBIC
  , ppsns.patHasSSID
  , ppsns.groupSvcClassNameID  
  , ppsns.orpDocID
  , ppsns.orpDocStandardSelectionNameID 
  , ppsns.orpDocTypeID
  , ppsns.orpDocRefID
  , ppsns.spEdFreqCode
  , ppsns.minsPerFreq
  , ppsns.startDate
  , ppsns.endDate
  , ppsns.planStartDate
  , ppsns.planEndDate
  , ppsns.startDateTime
  , ppsns.endDateTime
  , ppsns.billableSvc

from dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA_NON_SPED (
    @clientID
  , @groupSvcClassNameID
  , @patID
  , @orpDocID
  , @planInEffectStartDate
  , @planInEffectEndDate
  , @patHasBIC
  , @patHasSSID
  , @billableSvcs) as ppsns

/*============================================================
 * If no data, exit
 *===========================================================*/  

select @numRows = count(ord.idx) from @orpDocs as ord
if (@numRows = 0) return

/*============================================================
 * If we are limiting to start and end date
 *===========================================================*/  

if (@limitDosToStartEndDate = 1)
begin

  update @orpDocs
  set 
     startDate      = @planInEffectStartDate
   , startDateTime  = @planInEffectStartDate
  where (
        (@planInEffectStartDate between startDate and endDate)
    and (startDate <= @planInEffectStartDate) 
  )

  update @orpDocs
  set 
     endDate      = @planInEffectEndDate
   , endDateTime  = @planInEffectEndDate
  where (
        (@planInEffectEndDate between startDate and endDate)
    and (endDate >= @planInEffectEndDate) 
  )

end

/*============================================================
 * Limit any recent plan data to end date
 *===========================================================*/  

if (@limitCalcToEndDate = 1)
begin
  update @orpDocs
  set 
     endDate      = @planInEffectEndDate
   , endDateTime  = @planInEffectEndDate
  where (
        (@planInEffectEndDate between startDate and endDate)
    and (endDate >= @planInEffectEndDate) 
  )
end

/*============================================================
 * Populate projected expected minutes for the plan
 *===========================================================*/  

update @orpDocs 
set 
  projectedTotalExpectedMinsForPlan = isnull(dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_PLAN (startDateTime, endDateTime, spEdFreqCode, minsPerFreq),0)

/*============================================================
 * Get earliest and latest break dates applicable to set
 *===========================================================*/  

select 
    @earliestPlanStart = min(ord.startDateTime)
  , @latestPlanEnd     = max(ord.endDateTime) 
from @orpDocs as ord

/*============================================================
 * Get client wide breaks
 *===========================================================*/  

insert into @expectedClientWideBreaks (
    startDate
  , endDate
)
select distinct
    ssa.startDate
  , ssa.endDate
from dbo.CLIENT_SCHOOL_SESSION_CLIENT_WIDE_CALC_DATES_NOT_IN_SESSION (@clientID, @earliestPlanStart, @latestPlanEnd) as ssa

/*============================================================
 * Get patient specific site breaks
 *
 * (StartA <= EndB) and (EndA >= StartB)
 *
 *===========================================================*/  
 
insert into @expectedPatSiteSpecificBreaks (
    patID
  , startDate
  , endDate
)
select distinct
    patID = ps.PATIENT_ID  
  , ssb.startDate
  , ssb.endDate
from @orpDocs                         as ord
join dbo.PATIENTS_School              as ps  on ps.PATIENT_ID = ord.patID
join dbo.CLIENT_SCHOOL_SESSION_BREAKS as ssb on ((ssb.clientID = @clientID) and (ssb.siteID = ps.SITE_ID))											
where (
      ((@earliestPlanStart <= isnull(ps.END_DATE,@today)) and (@latestPlanEnd >= ps.START_DATE))
  and ((@earliestPlanStart <= ssb.endDate) and (@latestPlanEnd >= ssb.startDate))
  and (ssb.clientWideBreak = 0)
  and (ssb.active = 1)
)

/*============================================================
 * Calculate projected break minutes for client wide breaks
 *===========================================================*/  

-- (StartA <= EndB) and (EndA >= StartB)

update ord
  set ord.projectedTotalExpectedMinsForBreaks = isnull(breakAdjust.numMinsToSubForBreaksTot,0)
from @orpDocs                      as ord
cross apply (
  select
    numMinsToSubForBreaksTot = sum(q1.numMinsToSubForBreaksSubTot)
  from
  (
    select 
      numMinsToSubForBreaksSubTot = dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK (cwb.startDate, cwb.endDate, ord.spEdFreqCode, ord.minsPerFreq)
    from @expectedClientWideBreaks as cwb
    where 
      ((cwb.startDate <= ord.endDateTime) and (cwb.endDate >= ord.startDateTime))
  ) as q1
) as breakAdjust

/*============================================================
 * Calculate projected break minutes for site specific breaks
 *===========================================================*/  

-- (StartA <= EndB) and (EndA >= StartB)

update ord
  set ord.projectedTotalExpectedMinsForBreaks = isnull(breakAdjust.numMinsToSubForBreaksTot,0)
from @orpDocs as ord
cross apply (
  select
    numMinsToSubForBreaksTot = sum(q1.numMinsToSubForBreaksSubTot)
  from
  (
    select      
      numMinsToSubForBreaksSubTot = dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK (ssb.startDate, ssb.endDate, ord.spEdFreqCode, ord.minsPerFreq)
    from @expectedPatSiteSpecificBreaks as ssb
    where (
          (ssb.patID = ord.patID)
	  and ((ssb.startDate <= ord.endDateTime) and (ssb.endDate >= ord.startDateTime))
    )
  ) as q1
) as breakAdjust
where (
  (ord.projectedTotalExpectedMinsForBreaks = 0)   /* Break not accounted for by client wide */
)

/*============================================================
 * Get services entered data
 *===========================================================*/  

insert into @svcMinsEntered (
    orpDocIdx
  , numMinsSatisfied
)
select 
    orpDocIdx        = ord.idx	  
  , numMinsSatisfied = isnull(sr2.totMinsSatisfied,0)
from @orpDocs as ord
cross apply (
  select 
    totMinsSatisfied = sum(isnull(dbo.CALC_PROMISED_MINS_SATISFIED (sr1.numMins, sr1.patAbsent, sr1.pracAbsent, sr1.makeupSession, 1, sr1.attendanceSelectionID),0))
  from dbo.SERVICE_RECORDS as sr1 
  where (
     /* Optimized for index, CLIENT_PAT_GRP_FAM_SVCTYPE_IDX_W_ADD_COLS */
     ((sr1.clientID = ord.clientID) 
  and (sr1.patID = ord.patID)
  and (sr1.pracGrpSvcClsNameID = ord.groupSvcClassNameID)
  and (sr1.svcType = 2)
  and (sr1.dos between ord.startDateTime and ord.endDateTime)
  and (sr1.id is not null))

  and (sr1.isIFSPorIEP = 0)
  and (sr1.state not in (99,199))
  --and (sr1.orpDocID = ord.orpDocID)
  )
) as sr2

/*============================================================
 * Calculate total minutes expected
 *===========================================================*/  

update @orpDocs set totalMinutesExpected = (projectedTotalExpectedMinsForPlan - projectedTotalExpectedMinsForBreaks)

/*============================================================
 * Assign total minutes satisfied
 *===========================================================*/  

update ord
  set ord.totalMinutesSatisfied = sme.numMinsSatisfied
from @orpDocs            as ord
join @svcMinsEntered     as sme on sme.orpDocIdx = ord.idx

/*============================================================
 * Calculate difference and less than expected
 *===========================================================*/  

update ord
  set ord.diffMinutesExpectedSatified = (ord.totalMinutesExpected - ord.totalMinutesSatisfied)
from @orpDocs as ord

update @orpDocs set lessThanExpected = 1 where ((totalMinutesExpected > 0) and (diffMinutesExpectedSatified > 0))

insert into @recs (
    clientID
  , patID   
  , patHasBIC 
  , patHasSSID
  , groupSvcClassNameID
  , orpDocID  
  , orpDocStandardSelectionNameID
  , orpDocTypeID
  , orpDocRefID
  , spEdFreqCode 
  , minsPerFreq 
  , startDate 
  , endDate 
  , planStartDate
  , planEndDate  
  , projectedTotalExpectedMinsForPlan 
  , projectedTotalExpectedMinsForBreaks
  , totalMinutesExpected
  , totalMinutesSatisfied
  , pctExpectedSatisfied 
  , diffMinutesExpectedSatified
  , lessThanExpected  
  , potentialLostReimbursment 
  , billableSvc 
  , generatedOn 
)
select   
    ord.clientID
  , ord.patID   
  , ord.patHasBIC 
  , ord.patHasSSID
  , ord.groupSvcClassNameID
  , ord.orpDocID  
  , ord.orpDocStandardSelectionNameID
  , ord.orpDocTypeID
  , ord.orpDocRefID
  , ord.spEdFreqCode 
  , ord.minsPerFreq 
  , ord.startDate 
  , ord.endDate 
  , ord.planStartDate
  , ord.planEndDate
  , ord.projectedTotalExpectedMinsForPlan 
  , ord.projectedTotalExpectedMinsForBreaks
  , ord.totalMinutesExpected
  , ord.totalMinutesSatisfied
  , pctExpectedSatisfied = iif( (@calcPctExpectedSatisfied = 1)
                               , dbo.CALC_PERCENTAGE (ord.totalMinutesSatisfied,ord.totalMinutesExpected,1,1,0)
							   , null )
  , ord.diffMinutesExpectedSatified
  , ord.lessThanExpected  
  , potentialLostReimbursment =  iif ( (@calcPotLostReimbursement = 1)
                                        , iif ( ((ord.lessThanExpected = 1) and (ord.patHasBic = 1))
									          , convert(money,(round ( (pr.RATE_TMT * (ord.diffMinutesExpectedSatified / pr.UNIT_PER_MIN_FACTOR_TMT ) ),2)))
										      , 0)
									    ,null)
  , billableSvc = ord.billableSvc
  , generatedOn = @today
from @orpDocs                                      as ord
join dbo.GROUP_GROUP_SERVICE_CLASS_POTENTIAL_RATES as pr on pr.GROUP_SERVICE_CLASS_NAME_ID = ord.groupSvcClassNameID

order by 
    ord.clientID
  , ord.patID
  , ord.orpDocID
  , ord.startDate
  , ord.endDate

return
end
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_SUMMARY_VIEW_DATA_CORE] TO [webuser]
GO