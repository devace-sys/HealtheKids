/*

Run the following to stop this procedure running :

declare @saveTypeOut   as int = 0
declare @recordIDOut   as int = 0
exec users.dbo.APP_SETTING_SET_VALUE 0,'spedcare','batch-task','PATIENT_PROMISED_SERVICE_UPDATE_Delivery_Compliance_Sped_Services','control-flag','global','stop-run', '1', @saveTypeOut output, @recordIdOut output

*/ 



USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICE_UPDATE_Delivery_Compliance_Sped_Services') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PROMISED_SERVICE_UPDATE_Delivery_Compliance_Sped_Services
GO

CREATE PROCEDURE dbo.PATIENT_PROMISED_SERVICE_UPDATE_Delivery_Compliance_Sped_Services ( 
  @clientIDIn bigint = null
)   
AS    
BEGIN    
     
SET NOCOUNT ON    

declare @clients as table (
    idx        int identity(1,1)
  , clientID   bigint
  , clientName varchar(256)
  unique clustered (idx)
)

declare @newPPSData as table  (
    clientID                             bigint
  , patID                                bigint
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
  , pctExpectedSatisfied                 real
  , diffMinutesExpectedSatified          int
  , potentialLostReimbursment            money
  , billableSvc                          bit 
  , generatedOn                          datetime   
  , patHasBIC                            bit
  , patHasSSID                           bit
  , lessThanExpected                     bit
  , siteID                               bigint
  , numPatAbsentTot                      int
  , numPracAbsentTot                     int
  , numSvcRecs                           int
  , pctFulfillment                       real
  , fulfillmentFactor                    real
  , totalFullfillFactorForPat            real
  , totSvcsForPatInIEP                   int
  , iepCompliancePctForPat               real
  , pcalComplianceRatingForPat           tinyint
)     

declare @patSites as table (
    patID    bigint
  , siteID   bigint
)

declare @pcalComplianceRatings as table (
    patID                      bigint
  , totSvcsForPatInIEP         int
  , totalFullfillFactorForPat  real
  , iepCompliancePctForPat     real
  , pcalComplianceRatingForPat tinyint
)


declare @clientID                           as bigint       = -1
declare @clientName                         as varchar(256) = ''
declare @curIdx                             as int          = 0
declare @maxIdx                             as int          = 0
declare @cdeCompliancePlanInEffectStartDate as date         = null
declare @cdeCompliancePlanInEffectEndDate   as date         = null
declare @leaBopPlanInEffectStartDate        as date         = null
declare @leaBopPlanInEffectEndDate          as date         = null

declare @today                    as date         = getdate()
declare @msgStr                   as varchar(512) = ''
declare @okToReplaceData          as bit          = 0
declare @problemCount             as int          = 0
declare @todayDateOnly            as date
declare @fyStartCurr              as date
declare @fyEndCurr                as date
declare @fyStartPrev              as date
declare @fyEndPrev                as date
declare @saveTypeOut              as int          = 0
declare @recordIDOut              as int          = 0
declare @newStartDateStr          as varchar(max) = ''
declare @newEndDateStr            as varchar(max) = ''
declare @stopRun                  as bit          = 0
declare @okToGenerateWeekly       as bit          = 0

/*#####################################################################################################################*/
/* Reset stop run flag */
/*#####################################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Reset stop run flag'
set @stopRun = 0
exec users.dbo.APP_SETTING_SET_VALUE 0,'spedcare','batch-task','PATIENT_PROMISED_SERVICE_UPDATE_Delivery_Compliance_Sped_Services','control-flag','global','stop-run', '0', @saveTypeOut output, @recordIdOut output
set @stopRun = convert(bit,users.dbo.APP_SETTING_GET_VALUE ('spedcare','batch-task','PATIENT_PROMISED_SERVICE_UPDATE_Delivery_Compliance_Sped_Services','control-flag','global','stop-run'))

/*#####################################################################################################################*/
/* Replace claim service name xref calpad code snx data */
/*#####################################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Replace cached service name xref calpad code snx data'
exec dbo.CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED_UPDATE_CORE

/*#####################################################################################################################*/
/* Replace cached average rate data */
/*#####################################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Replace cached average rate data'

delete dbo.SpEd_Service_Avg_Rate_Data_Cached
option(recompile)

insert into dbo.SpEd_Service_Avg_Rate_Data_Cached (
    spEdSvcCodeValue
  , avgRate
  , avgUnitPerMinFactor
  , billableSvc
  , generatedOn
)
select 
    t1.spEdSvcCodeValue
  , t1.avgRate
  , t1.avgUnitPerMinFactor
  , t1.billableSvc
  , generatedOn = @today
from dbo.SpEd_Service_Avg_Rate_Data as t1
option(recompile)

/*#####################################################################################################################*/
/* Get current and previous fiscal year date ranges */
/*#####################################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Getting date ranges for current and previous fiscal years'

set @today = getdate()
set @todayDateOnly = convert(date,@today)

select top 1 
    @fyStartCurr = cfy1.FY_START 
  , @fyEndCurr  = cfy1.FY_END 
from dbo.COMPANY_FISCAL_YEARS as cfy1
where (@todayDateOnly between cfy1.FY_START and cfy1.FY_END) 
OPTION(recompile)

select top 1 
    @fyStartPrev = cfy1.FY_START 
  , @fyEndPrev  = cfy1.FY_END 
from dbo.COMPANY_FISCAL_YEARS as cfy1
where (dateadd(year,-1,@todayDateOnly) between cfy1.FY_START and cfy1.FY_END) 
OPTION(recompile)

/*#####################################################################################################################*/
/* Determine if its OK to update everything */
/*#####################################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Determine if its OK to update everything'
set @okToGenerateWeekly = 0

if (dbo.CALC_SERVER_INDEPENDENT_DAY_OF_WEEK_NUMBER(@today) in (5,6))
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Its a weekend day so its OK to recalculate'
  set @okToGenerateWeekly = 1
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Its a weekday so its not OK to recalculate.  Keep the cached value.'
  set @okToGenerateWeekly = 0
end

/*#####################################################################################################################*/
/* Get and set CDE compliance window dates (this is for the annual - not reported to CDE) */
/* This is NOT for the current audit window */
/*#####################################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Calculating and updating CDE (annual - not reported to CDE) compliance window dates'

set @cdeCompliancePlanInEffectStartDate = @fyStartCurr 
set @cdeCompliancePlanInEffectEndDate   = @today

set @newStartDateStr = dbo.RPT_DATE_FMT(@cdeCompliancePlanInEffectStartDate)
set @newEndDateStr   = dbo.RPT_DATE_FMT(@cdeCompliancePlanInEffectEndDate)

exec users.dbo.APP_SETTING_SET_VALUE 0,'spedcare','cde','compliance','dates','global','current-window-start-date', @newStartDateStr, @saveTypeOut output, @recordIdOut output
exec users.dbo.APP_SETTING_SET_VALUE 0,'spedcare','cde','compliance','dates','global','current-window-end-date',   @newEndDateStr,   @saveTypeOut output, @recordIdOut output

set @msgStr = 'Calculating CDE compliance data for plans in effect between ' + convert(varchar,@cdeCompliancePlanInEffectStartDate) + ' and ' + convert(varchar,@cdeCompliancePlanInEffectEndDate)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

/*#####################################################################################################################*/
/* Calculate BOP compliance window dates */
/*#####################################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Calculating LEA BOP compliance window dates'

set @leaBopPlanInEffectStartDate = dbo.CALC_OLDEST_DOS_ALLOWED (@today)
set @leaBopPlanInEffectEndDate   = @today

set @msgStr = 'Calculating LEA BOP compliance data for plans in effect between ' + convert(varchar,@leaBopPlanInEffectStartDate) + ' and ' + convert(varchar,@leaBopPlanInEffectEndDate)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

/*#####################################################################################################################*/
/* Get all active LEA clients */
/*#####################################################################################################################*/

if (@clientIDIn is null)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Getting all active LEA clients'
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Getting data for single client if client is active LEA'
end

insert into @clients (
    clientID
  , clientName
)
select 
   clientID   = clc.CLIENT_ID 
 , clientName = left(clc.CLIENT_NAME,255)
from dbo.CLIENTS_Client as clc
where (
      (1=1)
  and ((@clientIDIn is null) or (clc.CLIENT_ID = @clientIDIn))
  and (clc.LEA = 1)
)
OPTION(recompile)

/*#####################################################################################################################*/
/* Process updates */
/*#####################################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Processing updates'

set @curIdx = 1
select @maxIdx = max(clc.idx) from @clients as clc

while (@curIdx <= @maxIdx)
begin

  
  set @okToReplaceData = 0

  set @msgStr = 'Processing ' + convert(varchar,@curIdx) + ' of ' + convert(varchar,@maxIdx)
  exec dbo.PRINT_STATUS_MESSAGE @msgStr
 
  /* Get client data */

  select top 1 
      @clientID = clc.clientID
	, @clientName = clc.clientName 
  from @clients as clc where (clc.idx = @curIdx)
  
  exec dbo.PRINT_STATUS_MESSAGE @clientName

  /*#####################################################################################################################*/
  /* CDE Compliance Reports Cached Data */
  /*#####################################################################################################################*/
 
  exec dbo.PRINT_STATUS_MESSAGE 'Checking stop run flag status'
 
  set @stopRun = convert(bit,users.dbo.APP_SETTING_GET_VALUE ('spedcare','batch-task','PATIENT_PROMISED_SERVICE_UPDATE_Delivery_Compliance_Sped_Services','control-flag','global','stop-run'))
  if (@stopRun = 1)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Stop run flag has been set.  Exiting.'
	break
  end
  else
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Stop run flag has not been set.  Continuing'
  end
 
  begin try
    
 	 exec dbo.PRINT_STATUS_MESSAGE 'Generating new compliance data for CDE compliance reports'
	 set @msgStr = 'Calculating CDE compliance data for plans in effect between ' + convert(varchar,@cdeCompliancePlanInEffectStartDate) + ' and ' + convert(varchar,@cdeCompliancePlanInEffectEndDate)
     exec dbo.PRINT_STATUS_MESSAGE @msgStr

	 /* Clear table variable */

     exec dbo.PRINT_STATUS_MESSAGE 'Clearing temp data'
     delete @newPPSData
	 option(recompile)

	 delete @patSites
	 option(recompile)

	 delete @pcalComplianceRatings 
	 option(recompile)

	 /* Get new data and put in table variable */
  
	 exec dbo.PRINT_STATUS_MESSAGE 'Generating data and storing in temp data'

     insert into @newPPSData (
          clientID
        , patID
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
        , pctExpectedSatisfied  
        , diffMinutesExpectedSatified 
        , potentialLostReimbursment
        , billableSvc
        , generatedOn
	    , patHasBIC
        , patHasSSID 
		, lessThanExpected   
		, numPatAbsentTot
        , numPracAbsentTot
		, numSvcRecs			
    )
    select 
          pps.clientID
        , pps.patID
        , pps.spEdExitedSpEdDate
        , pps.spEdServiceCode
        , pps.startDate
        , pps.endDate
		, pps.planStartDate
		, pps.planEndDate  
        , pps.spEdFreqCode
        , pps.minsPerFreq 
        , pps.projectedTotalExpectedMinsForPlan
        , pps.projectedTotalExpectedMinsForBreaks
        , pps.totalMinutesExpected 
        , pps.totalMinutesSatisfied
        , pps.pctExpectedSatisfied  
        , pps.diffMinutesExpectedSatified 
        , pps.potentialLostReimbursment
        , pps.billableSvc
        , pps.generatedOn
    	, pps.patHasBIC
        , pps.patHasSSID 
		, pps.lessThanExpected
		, pps.numPatAbsentTot
        , pps.numPracAbsentTot
		, pps.numSvcRecs
		
	from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE ( @clientID
		   																			                  , null /* @patID*/
																					                  , null /* @pracID */
																									  , null /* @spEdSvcCode */
																					                  , null
																									  , null
																									  , null /* @spEdFreqCode */
																									  , null
																									  , null /* @minsPerFreqAssigned */
																									  , @cdeCompliancePlanInEffectStartDate
																					                  , @cdeCompliancePlanInEffectEndDate
																					                  , null
																					                  , null
																					                  , null
																					                  , 1 
																					                  , 1 
																					                  , 1
																									  , 0 
																									  , 0
																									  , 0
																									  , 1 /* Pat absent counts as mins satisfied */
																									  , 0 /* Exit without calc */) as pps



	OPTION(recompile)

	exec dbo.PRINT_STATUS_MESSAGE 'Getting patient site data'

	insert into @patSites (patID)
    select distinct npd.patID from @newPPSData as npd
	
    update ps
    set 
      ps.siteID = psvc.SITE_ID
    from @patSites as ps
    join dbo.PATIENTS_SITES_VIEW_CURRENT ( @clientID ) as psvc on psvc.PATIENT_ID = ps.patID
	OPTION(recompile)

	exec dbo.PRINT_STATUS_MESSAGE 'Updating temp data with site data'

    update npd
    set
      npd.siteID = ps.siteID
    from @newPPSData as npd
    join @patSites   as ps on ps.patID = npd.patID

	exec dbo.PRINT_STATUS_MESSAGE 'Calculating fulfillment percentage'

	update @newPPSData
	  set pctFulfillment = dbo.CALC_PERCENTAGE_Fulfillment (totalMinutesSatisfied, totalMinutesExpected)

	exec dbo.PRINT_STATUS_MESSAGE 'Calculating fulfillment factor'

	update @newPPSData
	  set fulfillmentFactor = ((pctFulfillment / 100) * 1)

	exec dbo.PRINT_STATUS_MESSAGE 'Calculating pcal promised svc compliance rating for patient'

;with
cte_p1
as
(
  select 
    
    pps.patID
  , totSvcsForPatInIEP        = count(pps.patID)
  , totalFullfillFactorForPat = sum(pps.fulfillmentFactor)

from @newPPSData as pps

group by 
  pps.patID
)
,
cte_p2
as
(
select 
    p1.*  
  , iepCompliancePctForPat = dbo.CALC_PERCENTAGE_Fulfillment(p1.totalFullfillFactorForPat,p1.totSvcsForPatInIEP)
from cte_p1 as p1
)

insert into @pcalComplianceRatings (
    patID
  , totSvcsForPatInIEP
  , totalFullfillFactorForPat
  , iepCompliancePctForPat
  , pcalComplianceRatingForPat )

select     
    p2.patID
  , p2.totSvcsForPatInIEP
  , p2.totalFullfillFactorForPat
  , p2.iepCompliancePctForPat
  , pcalComplianceRatingForPat = dbo.CALC_PCAL_PROMISED_SERVICE_DELIVERY_COMPLIANCE_RATING(p2.iepCompliancePctForPat)
from cte_p2 as p2

exec dbo.PRINT_STATUS_MESSAGE 'Updating temp data with pcal promised svc compliance rating for patient'
	
	update npd
    set
      
        npd.totSvcsForPatInIEP         = pcr.totSvcsForPatInIEP
      , npd.totalFullfillFactorForPat  = pcr.totalFullfillFactorForPat
      , npd.iepCompliancePctForPat     = pcr.iepCompliancePctForPat
      , npd.pcalComplianceRatingForPat = pcr.pcalComplianceRatingForPat
	from @newPPSData              as npd
    join @pcalComplianceRatings   as pcr on pcr.patID = npd.patID

    exec dbo.PRINT_STATUS_MESSAGE 'New compliance data generated successfully for CDE compliance reports'
    set @okToReplaceData = 1


  end try
  begin catch
    exec dbo.PRINT_STATUS_MESSAGE 'There was a problem generating new compliance data for CDE compliance reports'
    print ERROR_MESSAGE()
	set @okToReplaceData = 0
	set @problemCount = @problemCount + 1
  end catch

  /* Note: It is very important that the next two operations complete as fast as possible to minimize disruption to the reports.
   * This is why we are retrieving fresh data into a table variable prior to deleting from the actual table instead of deleting
   * rows from the actual table then importing fresh data into the table.
   */

  if (@okToReplaceData = 1)
  begin
    
	/* Clear previously cached data for this client */
  
    exec dbo.PRINT_STATUS_MESSAGE 'Clearing previously saved data for CDE compliance reports'
    
	delete dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services where (clientID = @clientID)
	OPTION(recompile)

    /* Then save the new data */
  
    exec dbo.PRINT_STATUS_MESSAGE 'Saving updated data for CDE compliance reports'

    insert into dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services (
          clientID
        , patID
        , spEdExitedSpEdDate
        , spEdServiceCode
        , startDate
        , endDate  
        , spEdFreqCode
        , minsPerFreq 
        , projectedTotalExpectedMinsForPlan
        , projectedTotalExpectedMinsForBreaks
        , totalMinutesExpected 
        , totalMinutesSatisfied
        , pctExpectedSatisfied  
        , diffMinutesExpectedSatified 
        , potentialLostReimbursment
        , billableSvc
        , generatedOn
		, patHasBIC
        , patHasSSID 
		, lessThanExpected
		, planStartDate
		, planEndDate
        , siteID
        , numPatAbsentTot
        , numPracAbsentTot
		, numSvcRecs
		
		, pctFulfillment
		, fulfillmentFactor
		, totSvcsForPatInIEP
        , totalFullfillFactorForPat
        , iepCompliancePctForPat   
		, pcalComplianceRatingForPat
	
	  )
      select 
          pps.clientID
        , pps.patID
        , pps.spEdExitedSpEdDate
        , pps.spEdServiceCode
        , pps.startDate
        , pps.endDate  
        , pps.spEdFreqCode
        , pps.minsPerFreq 
        , pps.projectedTotalExpectedMinsForPlan
        , pps.projectedTotalExpectedMinsForBreaks
        , pps.totalMinutesExpected 
        , pps.totalMinutesSatisfied
        , pps.pctExpectedSatisfied  
        , pps.diffMinutesExpectedSatified 
        , pps.potentialLostReimbursment
        , pps.billableSvc
        , pps.generatedOn
		, pps.patHasBIC
        , pps.patHasSSID 
		, pps.lessThanExpected
		, pps.planStartDate
		, pps.planEndDate
        , pps.siteID
        , pps.numPatAbsentTot
        , pps.numPracAbsentTot
		, pps.numSvcRecs
		, pps.pctFulfillment
		, pps.fulfillmentFactor
		, pps.totSvcsForPatInIEP
        , pps.totalFullfillFactorForPat
        , pps.iepCompliancePctForPat   
    	, pps.pcalComplianceRatingForPat
	
	from @newPPSData as pps
	option(recompile)

    exec dbo.PRINT_STATUS_MESSAGE 'Updated data for CDE compliance reports saved'

  end
  else
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Retaining previously saved data for CDE compliance reports until issue is resolved.'
  end

 /*#####################################################################################################################*/
  /* Is it ok to update data that we (for performance reasons) only update at the end of the week */
  /*#####################################################################################################################*/
 
  if (@okToGenerateWeekly = 1)
  begin
  
  /*#####################################################################################################################*/
  /* LEA BOP Health Report Cached Data */
  /* NOTE: The minutes expected/satisfied and PLR data is limited to dates of service to/from oldest DOS allowed to today*/
  /*#####################################################################################################################*/

  exec dbo.PRINT_STATUS_MESSAGE 'Checking stop run flag status'
 
  set @stopRun = convert(bit,users.dbo.APP_SETTING_GET_VALUE ('spedcare','batch-task','PATIENT_PROMISED_SERVICE_UPDATE_Delivery_Compliance_Sped_Services','control-flag','global','stop-run'))
  if (@stopRun = 1)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Stop run flag has been set.  Exiting.'
	break
  end
  else
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Stop run flag has not been set.  Continuing'
  end


  begin try
    
 	 exec dbo.PRINT_STATUS_MESSAGE 'Generating new compliance data for LEA BOP health reports'
	 
	 set @msgStr = 'Calculating LEA BOP compliance data for plans in effect between ' + convert(varchar,@leaBopPlanInEffectStartDate) + ' and ' + convert(varchar,@leaBopPlanInEffectEndDate)
     exec dbo.PRINT_STATUS_MESSAGE @msgStr

	  /* Clear table variable */

     exec dbo.PRINT_STATUS_MESSAGE 'Clearing temp data'
     delete @newPPSData
	 option(recompile)

	 /* Get new data and put in table variable */
  
	 exec dbo.PRINT_STATUS_MESSAGE 'Generating data and storing in temp data'

     -- inserting into @newPPSData

     insert into @newPPSData (
          clientID
        , patID
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
        , pctExpectedSatisfied  
        , diffMinutesExpectedSatified 
        , potentialLostReimbursment
        , billableSvc
        , generatedOn
	    , patHasBIC
        , patHasSSID 
		, lessThanExpected
    )
    select 
          pps.clientID
        , pps.patID
        , pps.spEdExitedSpEdDate
        , pps.spEdServiceCode
        , pps.startDate
        , pps.endDate
		, pps.planStartDate
		, pps.planEndDate  
        , pps.spEdFreqCode
        , pps.minsPerFreq 
        , pps.projectedTotalExpectedMinsForPlan
        , pps.projectedTotalExpectedMinsForBreaks
        , pps.totalMinutesExpected 
        , pps.totalMinutesSatisfied
        , pps.pctExpectedSatisfied  
        , pps.diffMinutesExpectedSatified 
        , pps.potentialLostReimbursment
        , pps.billableSvc
        , pps.generatedOn
    	, pps.patHasBIC
        , pps.patHasSSID 
		, pps.lessThanExpected

	from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE ( @clientID
		   																			                  , null
																									  , null
																					                  , null
																									  , null
																									  , null
																									  , null
																									  , null
																									  , null
																					                  , @leaBopPlanInEffectStartDate
																					                  , @leaBopPlanInEffectEndDate
																					                  , null
																					                  , null
																					                  , null
																					                  , 1 
																					                  , 1 
																					                  , 1
																									  , 1 
																									  , 0
																									  , 0
																									  , 1 /* Pat absent counts as mins satisfied */
																									  , 0 /* Exit without calc */ ) as pps
    OPTION(recompile)

    exec dbo.PRINT_STATUS_MESSAGE 'New compliance data generated successfully for LEA BOP Health reports'
    set @okToReplaceData = 1
  end try
  begin catch
    exec dbo.PRINT_STATUS_MESSAGE 'There was a problem generating new compliance data for LEA BOP Health reports'
    print ERROR_MESSAGE()
	set @okToReplaceData = 0
	set @problemCount = @problemCount + 1
  end catch

  
  /* Note: It is very important that the next two operations complete as fast as possible to minimize disruption to the reports.
   * This is why we are retrieving fresh data into a table variable prior to deleting from the actual table instead of deleting
   * rows from the actual table then importing fresh data into the table.
   */

  if (@okToReplaceData = 1)
  begin
    
	/* Clear previously cached data for this client */
  
    exec dbo.PRINT_STATUS_MESSAGE 'Clearing previously saved data for LEA BOP health reports'
    
	delete dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services_For_LEA_BOP_Reports 
	where (clientID = @clientID)
	OPTION(recompile)

    /* Then save the new data */
  
    exec dbo.PRINT_STATUS_MESSAGE 'Saving updated data for LEA BOP Health reports'

    insert into dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services_For_LEA_BOP_Reports (
          clientID
        , patID
        , spEdExitedSpEdDate
        , spEdServiceCode
        , startDate
        , endDate  
        , spEdFreqCode
        , minsPerFreq 
        , projectedTotalExpectedMinsForPlan
        , projectedTotalExpectedMinsForBreaks
        , totalMinutesExpected 
        , totalMinutesSatisfied
        , pctExpectedSatisfied  
        , diffMinutesExpectedSatified 
        , potentialLostReimbursment
        , billableSvc
        , generatedOn
		, patHasBIC
        , patHasSSID 
		, lessThanExpected
		, planStartDate
		, planEndDate
      )
      select 
          pps.clientID
        , pps.patID
        , pps.spEdExitedSpEdDate
        , pps.spEdServiceCode
        , pps.startDate
        , pps.endDate  
        , pps.spEdFreqCode
        , pps.minsPerFreq 
        , pps.projectedTotalExpectedMinsForPlan
        , pps.projectedTotalExpectedMinsForBreaks
        , pps.totalMinutesExpected 
        , pps.totalMinutesSatisfied
        , pps.pctExpectedSatisfied  
        , pps.diffMinutesExpectedSatified 
        , pps.potentialLostReimbursment
        , pps.billableSvc
        , pps.generatedOn
		, pps.patHasBIC
        , pps.patHasSSID 
		, pps.lessThanExpected
		, pps.planStartDate
		, pps.planEndDate
    from @newPPSData as pps
    option(recompile)

    exec dbo.PRINT_STATUS_MESSAGE 'Updated data for LEA BOP health reports saved'

  end
  else
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Retaining previously saved data for LEA BOP health reports until issue is resolved.'
  end

  exec dbo.PRINT_STATUS_MESSAGE 'Generating new totals data for LEA BOP health reports'

  /*#####################################################################################################################*/
  /* LEA BOP Health Report Totals Cached Data */
  /*#####################################################################################################################*/
  
  exec dbo.PRINT_STATUS_MESSAGE 'Checking stop run flag status'
 
  set @stopRun = convert(bit,users.dbo.APP_SETTING_GET_VALUE ('spedcare','batch-task','PATIENT_PROMISED_SERVICE_UPDATE_Delivery_Compliance_Sped_Services','control-flag','global','stop-run'))
  if (@stopRun = 1)
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Stop run flag has been set.  Exiting.'
	break
  end
  else
  begin
    exec dbo.PRINT_STATUS_MESSAGE 'Stop run flag has not been set.  Continuing'
  end

  declare @potLostReimburseLast12 as money = 0
  declare @potLostReimburseCurrFY as money = 0
  declare @potLostReimbursePrevFY as money = 0

  begin try

  /*============================================================
   * Promised services for last 12
   *============================================================*/  
  
  exec dbo.PRINT_STATUS_MESSAGE 'Generating new totals data for LEA BOP health reports - Last 12 months'

  select 
    @potLostReimburseLast12 = sum(pslast12_1.potentialLostReimbursment)
  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services_For_LEA_BOP_Reports as pslast12_1
  where (
         (pslast12_1.clientID         = @clientID)
	 and (pslast12_1.lessThanExpected = 1)	 
	 and (pslast12_1.billableSvc      = 1)
	 and (pslast12_1.patHasBIC        = 1)
  )
  group by
    pslast12_1.clientID
  OPTION(recompile)
  
  /*============================================================
   * Promised services for current fiscal year
   *============================================================*/  
  
  exec dbo.PRINT_STATUS_MESSAGE 'Generating new totals data for LEA BOP health reports - Current fiscal year'

  select
     @potLostReimburseCurrFY = sum(pscurr.potentialLostReimbursment)
  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services as pscurr
  where (
         (pscurr.clientID         = @clientID)
	 and (pscurr.lessThanExpected = 1)	 
	 and (pscurr.billableSvc      = 1)
	 and (pscurr.patHasBIC        = 1)
  )
   group by
     pscurr.clientID 
   OPTION(recompile)
  
   /*============================================================
    * Promised services for previous fiscal year
    *============================================================*/  


    exec dbo.PRINT_STATUS_MESSAGE 'Generating new totals data for LEA BOP health reports - Previous fiscal year'
 
    select
       @potLostReimbursePrevFY = sum(psprev.potentialLostReimbursment)
    from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE ( @clientID,null,null,null,null,null,null,null,null
		  	  																						    ,@fyStartPrev
																									    ,@fyEndPrev
																									    ,1,null,1,1,1,1,0,0,0,1,0) as psprev
     where 
       (psprev.lessThanExpected = 1)
   
     group by
       psprev.clientID 
     OPTION(recompile)
        
	exec dbo.PRINT_STATUS_MESSAGE 'Generating new totals data for LEA BOP health reports - Data generated successfully'  
    
	set @okToReplaceData = 1
  end try
  begin catch
    exec dbo.PRINT_STATUS_MESSAGE 'Generating new totals data for LEA BOP health reports - There was an error'
    print ERROR_MESSAGE()
	set @okToReplaceData = 0
	set @problemCount = @problemCount + 1
  end catch

  if (@okToReplaceData = 1)
  begin

    /*============================================================
     * Remove previous row for client
     *============================================================*/  
  
    exec dbo.PRINT_STATUS_MESSAGE 'Generating new totals data for LEA BOP health reports - Removing old row'

    delete dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services_For_LEA_BOP_Reports_Totals
    where (clientID = @clientID)
	OPTION(recompile)

    /*============================================================
     * Add fresh data client
     *============================================================*/  

    exec dbo.PRINT_STATUS_MESSAGE 'Generating new totals data for LEA BOP health reports - Adding fresh row'

    insert into dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services_For_LEA_BOP_Reports_Totals (
        clientID               
      , potLostReimburseLast12 
      , potLostReimburseCurrFY 
      , potLostReimbursePrevFY 
      , last12Start            
      , last12End              
      , fyStartCurr            
      , fyEndCurr              
      , fyStartPrev            
      , fyEndPrev              
      , generatedOn            
    )
    select top 1 
        clientID               = @clientID
      , potLostReimburseLast12 = isnull(@potLostReimburseLast12,0)
      , potLostReimburseCurrFY = isnull(@potLostReimburseCurrFY,0)
      , potLostReimbursePrevFY = isnull(@potLostReimbursePrevFY,0)
      , last12Start            = @leaBopPlanInEffectStartDate
      , last12End              = @leaBopPlanInEffectEndDate
      , fyStartCurr            = @fyStartCurr
      , fyEndCurr              = @fyEndCurr
      , fyStartPrev            = @fyStartPrev
      , fyEndPrev              = @fyEndPrev
      , generatedOn            = @today
	option(recompile)

  end
  else
  begin
   exec dbo.PRINT_STATUS_MESSAGE 'Retaining previously saved data for LEA BOP health reports totals until issue is resolved.'
  end


  end /* Ok to generate weekly updates */

  set @curIdx = @curIdx + 1
end /* While */

exec dbo.PRINT_STATUS_MESSAGE 'Done'

if (@problemCount > 0)
begin
  RAISERROR ('There were problems with the updates', 11, 1)
end
    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.PATIENT_PROMISED_SERVICE_UPDATE_Delivery_Compliance_Sped_Services TO webuser
GO