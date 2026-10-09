USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DATA_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DATA_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DATA_VIEW_CORE] (
    @clientID                 bigint
  , @patID                    bigint
  , @spEdServiceCode          int
  , @startDate                date /* Exact date not range */
  , @endDate                  date /* Exact date not range */
  , @spEdFreqCode             int
  , @minsPerFreq              int
  , @planInEffectStartDate    date
  , @planInEffectEndDate      date
  , @patHasBIC                bit
  , @patHasSSID               bit
  , @billableSvcs             bit
  , @limitCalcToEndDate       bit = 0   
  , @limitDosToStartEndDate   bit = 0
)   

returns
table
as
return
(
with
cte_p0
as
(
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
	, planStartDate  = lpps.startDate
    , planEndDate    = lpps.endDate	
    , lpps.isNonPeriodicPlan
	
  from dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA (
      @clientID
    , @patID
    , @spEdServiceCode
    , @startDate /* Exact plan start date, not range*/
	, @endDate   /* Exact plan end date not range */
    , @spEdFreqCode 
    , @minsPerFreq  
    , @planInEffectStartDate
    , @planInEffectEndDate
    , @patHasBIC
    , @patHasSSID) as lpps
  
  where  (
        (lpps.startDate <= lpps.endDate)
    and ((@spEdFreqCode is null) or (lpps.spEdFreqCode = @spEdFreqCode))
  )
)
,
cte_p1
as
(
  select  
      p0.clientID
    , p0.patID
    , p0.patHasBIC
	, p0.patHasSSID
	, p0.spEdExitedSpEdDate
	, p0.spEdServiceCode
	, p0.spEdFreqCode
	, p0.minsPerFreq
	
	/*============================================================
     * If we are limiting to start and end date
     *===========================================================*/  

    , startDate = iif ( ((@limitDosToStartEndDate = 1) and (@planInEffectStartDate between p0.startDate and p0.endDate) and (p0.startDate <= @planInEffectStartDate))
                       , @planInEffectStartDate
				       , p0.startDate) 

    , endDate   = iif ( ( ((@limitDosToStartEndDate = 1) or (@limitCalcToEndDate = 1)) and (@planInEffectEndDate between p0.startDate and p0.endDate) and (p0.endDate >= @planInEffectEndDate) )
                       , @planInEffectEndDate
					   , p0.endDate) 
    , p0.planStartDate 
    , p0.planEndDate   
    , p0.isNonPeriodicPlan
    
  from cte_p0 as p0

)
,
cte_p2
as
(
  select 
      p1.clientID
    , p1.patID
    , p1.patHasBIC
	, p1.patHasSSID
	, p1.spEdExitedSpEdDate
	, p1.spEdServiceCode
	, p1.spEdFreqCode
	, p1.minsPerFreq
    , p1.startDate 

	/*============================================================
     * If patient exited sped, modifiy applicable dates
     *===========================================================*/  

	, endDate = iif ( ((p1.spEdExitedSpEdDate is not null) and (p1.spEdExitedSpEdDate >= p1.startDate) and (spEdExitedSpEdDate <= p1.endDate))
	                , p1.spEdExitedSpEdDate
					, p1.endDate)			

    , p1.planStartDate 
    , p1.planEndDate   
    , p1.isNonPeriodicPlan
	, ard.avgRate
	, ard.avgUnitPerMinFactor
	, ard.billableSvc
 from cte_p1 as p1
 join dbo.SpEd_Service_Avg_Rate_Data_Cached as ard on ard.spEdSvcCodeValue = p1.spEdServiceCode 

 where (
       (1=1)
   and ((@billableSvcs is null) or (ard.billableSvc = @billableSvcs))
 )
)
select 
  p2.* 
from cte_p2 as p2
) 
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DATA_VIEW_CORE] TO [webuser]
GO