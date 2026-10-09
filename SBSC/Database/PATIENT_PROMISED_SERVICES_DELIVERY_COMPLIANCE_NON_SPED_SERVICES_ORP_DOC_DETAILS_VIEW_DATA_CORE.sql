USE SPEDMON
GO
 
 /*-------------------------------
  * Exists/Drop
  *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_DETAILS_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_DETAILS_VIEW_DATA_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_DETAILS_VIEW_DATA_CORE] (
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
    , dosStart          datetime
	, dosEnd            datetime
	, numMinsSatisfied  int
    , idx               bigint identity(1,1) 
  unique clustered (orpDocIdx, dosStart, dosEnd, idx)
)

declare @svcMinsExpectedEntered as table (
    orpDocIdx                       bigint
  , idx                             bigint identity(1,1)
  , dosStart                        datetime
  , dosEnd                          datetime
  , minsProjectedForPlan            int default(0)
  , minsProjectedForBreak           int default(0)
  , numMinsExpected                 int default(0)
  , numMinsSatisfied                int default(0)
  , diffMinsExpectedSatisfied       int default(0)
  , lessThanExpected                bit default(0)
unique clustered (orpDocIdx, dosStart, dosEnd, idx)
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
from dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA_NON_SPED (@clientID, @groupSvcClassNameID, @patID, @orpDocID, @planInEffectStartDate, @planInEffectEndDate, @patHasBIC, @patHasSSID, @billableSvcs) as ppsns

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
 * Calc minutes projected
 *===========================================================*/  

insert into @svcMinsExpectedEntered (
    orpDocIdx
  , dosStart
  , dosEnd
  , minsProjectedForPlan
)
select 
    orpDocIdx = ord.idx
  , cedm2.dosStart
  , cedm2.dosEnd
  , minsProjectedForPlan = cedm2.numMinsExpected
from @orpDocs as ord
cross apply (
  select 
  	    dosStart                    = cedm1.startDate
	  , dosEnd                      = cedm1.endDate
	  , numMinsExpected             = cedm1.expectedMinutes
  from dbo.PATIENT_PROMISED_SERVICES_CALC_EXPECTED_DATES_AND_MINUTES (  ord.startDate
                                                                      , ord.endDate
		  			  											      , ord.spEdFreqCode
																	  , ord.minsPerFreq ) as cedm1
) as cedm2


/*============================================================
 * Calculate projected break minutes for client wide breaks
 *===========================================================*/  
-- (StartA <= EndB) and (EndA >= StartB)

update sme
  set sme.minsProjectedForBreak = dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK (sme.dosStart, sme.dosEnd, ord.spEdFreqCode, ord.minsPerFreq)
from @orpDocs                  as ord
join @svcMinsExpectedEntered   as sme on sme.orpDocIdx  = ord.idx
join @expectedClientWideBreaks as cwb on ((cwb.startDate <= sme.dosEnd) and (cwb.endDate >= sme.dosStart))

/*============================================================
 * Calculate projected break minutes for site specific breaks
 *===========================================================*/  
-- (StartA <= EndB) and (EndA >= StartB)

update sme
  set sme.minsProjectedForBreak = dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK (sme.dosStart, sme.dosEnd, ord.spEdFreqCode, ord.minsPerFreq)
from @orpDocs                       as ord
join @svcMinsExpectedEntered        as sme on sme.orpDocIdx  = ord.idx
join @expectedPatSiteSpecificBreaks as ssb on ((ssb.startDate <= sme.dosEnd) and (ssb.endDate >= sme.dosStart) and (ssb.patID = ord.patID))
where (
    (sme.minsProjectedForBreak = 0)   /* Break not accounted for by client wide */
)

/*============================================================
 * Calculate mins expected
 *===========================================================*/  

update @svcMinsExpectedEntered set numMinsExpected = (minsProjectedForPlan - minsProjectedForBreak)



/*============================================================
 * Get services entered data
 *===========================================================*/  

insert into @svcMinsEntered (
     orpDocIdx
   , dosStart
   , dosEnd
   , numMinsSatisfied
)

select 
    sme.orpDocIdx	  
  , sme.dosStart
  , sme.dosEnd
  , numMinsSatisfied = sum(dbo.CALC_PROMISED_MINS_SATISFIED (sr.numMins, sr.patAbsent, sr.pracAbsent, sr.makeupSession, 1, sr.attendanceSelectionID))
    
from @orpDocs                                  as ord
join @svcMinsExpectedEntered                   as sme on sme.orpDocIdx = ord.idx
join dbo.SERVICE_RECORDS                       as sr  on ( 
   (   
         (sr.clientID = ord.clientID) 
     and (sr.patID = ord.patID)
     and (sr.pracGrpSvcClsNameID = ord.groupSvcClassNameID)
     and (sr.svcType = 2)
     and (sr.dos between sme.dosStart and sme.dosEnd)
     and (sr.id is not null)
   )
   and (sr.isIFSPorIEP = 0)
   and (sr.state not in (99,199))
   --and (sr.orpDocID = ord.orpDocID)
)
group by 
    sme.orpDocIdx	  
  , sme.dosStart
  , sme.dosEnd

/*============================================================
 * Update expected entered with services entered
 *===========================================================*/  

update sme 
set 
  sme.numMinsSatisfied = sm.numMinsSatisfied
                      
from @svcMinsEntered                           as sm 
join @svcMinsExpectedEntered                   as sme on ((sme.orpDocIdx = sm.orpDocIdx)
                                                      and (sme.dosStart  = sm.dosStart)
                                                      and (sme.dosEnd    = sm.dosEnd))

/*============================================================
 * Calculate diff and less than expected
 *===========================================================*/  

update @svcMinsExpectedEntered set diffMinsExpectedSatisfied = (numMinsExpected - numMinsSatisfied)
update @svcMinsExpectedEntered set lessThanExpected = 1 where ((numMinsExpected > 0) and (diffMinsExpectedSatisfied > 0))

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
  , ord.startDate 
  , ord.endDate 
  , ord.planStartDate
  , ord.planEndDate
  , ord.spEdFreqCode 
  , ord.minsPerFreq 
  , sme.dosStart
  , sme.dosEnd

  , sme.minsProjectedForPlan
  , sme.minsProjectedForBreak
  , sme.numMinsExpected
  , sme.numMinsSatisfied
  , pctExpectedSatisfied = iif( (@calcPctExpectedSatisfied = 1)
                               , dbo.CALC_PERCENTAGE (sme.numMinsSatisfied,sme.numMinsExpected,1,1,0)
							   , null )
  , sme.diffMinsExpectedSatisfied
  , sme.lessThanExpected  
  , potentialLostReimbursment =  iif ( (@calcPotLostReimbursement = 1)
                                        , iif ( ( (sme.diffMinsExpectedSatisfied > 0) and (ord.patHasBic = 1) )
									          , convert(money,(round ( (pr.RATE_TMT * (sme.diffMinsExpectedSatisfied / pr.UNIT_PER_MIN_FACTOR_TMT ) ),2)))
										      , 0)
									    ,null)
  , billableSvc = ord.billableSvc
  , generatedOn = @today
from @orpDocs                                      as ord
join dbo.GROUP_GROUP_SERVICE_CLASS_POTENTIAL_RATES as pr  on pr.GROUP_SERVICE_CLASS_NAME_ID = ord.groupSvcClassNameID
join @svcMinsExpectedEntered                       as sme on sme.orpDocIdx = ord.idx
order by 
    ord.clientID
  , ord.patID
  , ord.orpDocID
  , ord.startDate
  , sme.dosStart

return
end
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_NON_SPED_SERVICES_ORP_DOC_DETAILS_VIEW_DATA_CORE] TO [webuser]
GO