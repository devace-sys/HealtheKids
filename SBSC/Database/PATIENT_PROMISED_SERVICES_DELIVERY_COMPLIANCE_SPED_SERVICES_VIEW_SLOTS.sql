/*
 * Note: This is common functionality used by 
 *
 *   PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_DETAILS_VIEW_DATA_CORE
 *   PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_PLAN_SUMMARY_VIEW_DATA_CORE
 */

USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_SLOTS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_SLOTS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_SLOTS] (
    @clientID                      bigint  
  , @patID                         bigint  
  , @pracID                        bigint
  , @spEdServiceCode               int     
  , @planStartDate                 date    
  , @planEndDate                   date    
  , @spEdFreqCode                  int
  , @minsPerFreq                   int
  , @dosStart                      datetime
  , @dosEnd                        datetime
  , @nonPeriodicPlan               bit
  , @ppxIdx                        bigint
  , @patAbsentMinsAreSatisfiedMins bit = 1
)   
returns 
table as
return
(


with
cte_init
as
(
  select 
      ppsIdx          = @ppxIdx
	, nonPeriodicPlan = @nonPeriodicPlan
)
,

/*============================================================
 * For CDE current audit compliance calculations
 * if this is a non periodic plan we have to capture 
 * the number of minutes actually satisfied between the
 * dosStart and dosEnd.  This will be used in later calcs. 
 *===========================================================*/  

cte_p0
as
(
  select 
      p.*
	, nonPeriodicPlanSvcMinsEnteredDuringDosRange = isnull(sms2.numMinsSatisfiedTot,0)
  from cte_init as p
  outer apply (
    select 
	  sms1.numMinsSatisfiedTot
	from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_STATS_FOR_A_SLOT (
	    @clientID 
      , @patID
      , @pracID
	  , @spEdServiceCode
      , @dosStart
      , @dosEnd
	  , @patAbsentMinsAreSatisfiedMins ) as sms1
	where (@nonPeriodicPlan = 1)
  ) as sms2  
)
,

/*============================================================
 * Get all possible service delivery slots based on plan
 * dates and minutes.
 *===========================================================*/  

cte_p1
as
(
   select 
     p0.* 
   , q1.*
   from cte_p0 as p0
   cross apply (
     select     
       dosStart               = cedm.startDate
     , dosEnd                 = cedm.endDate
     , minsProjectedForPlan   = cedm.expectedMinutes   
    from dbo.PATIENT_PROMISED_SERVICES_CALC_EXPECTED_DATES_AND_MINUTES (
	  
	  /*============================================================
       * If this is a non periodic plan and dos start is later than
       * the plan start then we have to set the dos start to match
       * the plan start otherwise not all applicable minutes may be
       * considered in calculating compliance.
	   *
	   * NOTE: We cannot calculate this as part of a result set and
	   * pass the column name into the tvf as this will prevent
	   * a parallel execution plan.
       *===========================================================*/  

	  (iif ( ((@nonPeriodicPlan = 1) and (@dosStart > convert(datetime,@planStartDate)))
	        , @planStartDate 
		    , @dosStart)) 
	, @dosEnd
	, @spEdFreqCode
	, @minsPerFreq) as cedm
  ) as q1
)
,

/*============================================================
 * Get any service minutes satified through service record
 * entry
 *===========================================================*/  

cte_p2
as
(
  select      
     sme.*
	 /* TODO: Rename this to numMinsSatisfiedViaSvcRecs */
   , numSvcMinsEntered = isnull(sms2.numMinsSatisfiedTot,0)   
   , numPatAbsentTot   = isnull(sms2.numPatAbsentTot,0)   
   , numPracAbsentTot  = isnull(sms2.numPracAbsentTot,0)
   , numSvcRecs        = isnull(sms2.numSvcRecs,0)

  from cte_p1 as sme
  outer apply (
    select 
	    sms1.numMinsSatisfiedTot
	  , sms1.numPatAbsentTot 
	  , sms1.numPracAbsentTot      
      , sms1.numSvcRecs
	from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_RECORDS_STATS_FOR_A_SLOT (    
	    @clientID 
      , @patID
	  , @pracID
      , @spEdServiceCode
      , sme.dosStart 
      , sme.dosEnd   
	  , @patAbsentMinsAreSatisfiedMins
	) as sms1
  ) as sms2  
)
,

/*============================================================
 * Get any delivery exceptions that need to be subtracted
 *===========================================================*/  

cte_p3
as
(
  select 
      p2.* 
    , svcExceptionMinsToSubFromExpected = isnull(sde2.numMins,0)
  from cte_p2 as p2
  outer apply (
    select top 1 
	  sde1.numMins 
	from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_DELIVERY_EXCEPTION_FOR_SLOT_AS_ROW (
	    @clientID
	  , @patID
	  , @planStartDate
	  , @planEndDate
	  , @spEdServiceCode
	  , @spEdFreqCode
	  , @minsPerFreq
	  , p2.dosStart
	  , p2.dosEnd) as sde1 
	where 
	  (sde1.detailSlotSubFromMinutesExpected = 1)
  ) as sde2
)
,
/*============================================================
 * Get any delivery exceptions that need to be added
 *===========================================================*/  

cte_p4
as
(
  select 
      p3.* 
    , svcExceptionMinsToAddToSatisfied = isnull(sde2.numMins,0)
  from cte_p3 as p3
  outer apply (
    select top 1 
	  sde1.numMins 
	from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SERVICE_DELIVERY_EXCEPTION_FOR_SLOT_AS_ROW (
	    @clientID
	  , @patID
	  , @planStartDate
	  , @planEndDate
	  , @spEdServiceCode
	  , @spEdFreqCode
	  , @minsPerFreq
	  , p3.dosStart
	  , p3.dosEnd) as sde1 
	where 
      (sde1.detailSlotAddToMinutesSatisfied = 1)
  ) as sde2
)
,

/*============================================================
 * Get client wide breaks
 *===========================================================*/  

cte_p5
as
(
  select 
      p4.* 
    , minsProjectedForBreakClientWide = cwb2.totMins
  from cte_p4 as p4
  outer apply (
    select top 1 
	  cwb1.totMins 
	from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_CLIENT_WIDE_BREAK_FOR_SLOT_AS_ROW (
	    @clientID
	  , @planStartDate
	  , @planEndDate
	  , @spEdFreqCode
	  , @minsPerFreq
	  , p4.dosStart
	  , p4.dosEnd) as cwb1
  ) as cwb2
)
,
/*============================================================
 * Get site specific breaks
 *===========================================================*/  

cte_p6
as
(
  select 
      p5.* 
    , minsProjectedForBreakSiteWide = swb2.totMins
  from cte_p5 as p5
  outer apply (
    select top 1 
	  swb1.totMins 
	from dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SITE_WIDE_BREAK_FOR_SLOT_AS_ROW (
	    @clientID
	  , @patID
	  , @planStartDate
	  , @planEndDate
	  , @spEdFreqCode
	  , @minsPerFreq
	  , p5.dosStart
	  , p5.dosEnd) as swb1
  ) as swb2
)
,

/*============================================================
 * Determine mins for break.  Client wide takes precedence
 * over site wide.  
 *===========================================================*/  

cte_p7
as
(
  select 
      p6.* 
    , minsProjectedForBreak = coalesce(  p6.minsProjectedForBreakClientWide
	                                   , p6.minsProjectedForBreakSiteWide
									   , 0)
  from cte_p6 as p6
)
,

/*============================================================
 * Detect ESY minutes
 *===========================================================*/  

cte_p8
as
(
  select 
      p7.*
    , minsDetectedForESY = iif ( ((p7.minsProjectedForBreak > 0) and (p7.numSvcMinsEntered > 0))
	                            ,  p7.numSvcMinsEntered
								 , 0)
  from cte_p7 as p7
)
,

/*============================================================
 * Calculated mins expected and minutes satisfied
 *===========================================================*/  

cte_p9
as
(
  select 
     p8.* 
   , numMinsExpected  = ((p8.minsProjectedForPlan - (p8.minsProjectedForBreak - p8.minsDetectedForESY)) - p8.svcExceptionMinsToSubFromExpected)
   , numMinsSatisfied = (p8.numSvcMinsEntered + p8.svcExceptionMinsToAddToSatisfied)
  from cte_p8 as p8
)

/*============================================================
 * Output neccessary columns
 *===========================================================*/  

select 
    p9.ppsIdx
  , p9.dosStart 
  , p9.dosEnd   
  , p9.minsProjectedForPlan              
  , p9.minsProjectedForBreak             
  , p9.minsDetectedForESY                
  , p9.svcExceptionMinsToSubFromExpected 
  , p9.numMinsExpected                   
  , p9.numSvcMinsEntered                 
  , p9.svcExceptionMinsToAddToSatisfied  
  , p9.numMinsSatisfied 
  , p9.nonPeriodicPlan 
  , p9.nonPeriodicPlanSvcMinsEnteredDuringDosRange 
  , p9.numPatAbsentTot
  , p9.numPracAbsentTot
  , p9.numSvcRecs
from cte_p9 as p9
) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_VIEW_SLOTS] TO [webuser]
GO