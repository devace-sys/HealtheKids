USE SPEDMON
GO

/*-------------------------------
* Exists/Drop
*------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED_CORE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED_CORE
GO

/***************************************************************************
 * RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED_CORE */
/**
 * Note: This query provides a overview of the organizations
 * health via a collection of the outputs of various reports.
 * 
 * It takes some time to run.
 ***************************************************************************/

CREATE FUNCTION [dbo].[RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED_CORE] (
   @today       datetime
 , @startWeek   datetime
 , @endWeek     datetime
)
RETURNS TABLE
AS RETURN
(

with
cte_dates_0
as
(
  /* Calculate year part only for @today */

  select top 1 
      today         = @today
	, startWeek     = @startWeek
    , endWeek       = @endWeek
    , todayDateOnly = convert(date,@today)
)
,
cte_dates_1
as
(

  /* Calculate todays date minus 1 year and todays date minus 3 days */

  select top 1 
      d0.*
	, todayLastYearDateOnly  = dateadd(year,-1,d0.todayDateOnly)	
	, today30DaysAgoDateOnly = DATEADD(day,-30,d0.todayDateOnly)
  from cte_dates_0 as d0
)
,
cte_dates_2
as
(
  /* Fiscal years */

  select 
      d1.*
    , cfyCurr.FY_START_CURR
    , cfyCurr.FY_END_CURR
    , cfyPrev.FY_START_PREV
    , cfyPrev.FY_END_PREV
  from cte_dates_1 as d1

  /* Get current fy date range */

  cross apply (
    select top 1 
        FY_START_CURR = cfy1.FY_START 
      , FY_END_CURR   = cfy1.FY_END 
    from dbo.COMPANY_FISCAL_YEARS as cfy1
    where 
	  (d1.todayDateOnly between cfy1.FY_START and cfy1.FY_END) 
  ) as cfyCurr

  /* Get prev fy date range */

  cross apply (
    select top 1 
        FY_START_PREV = cfy1.FY_START 
      , FY_END_PREV   = cfy1.FY_END 
    from dbo.COMPANY_FISCAL_YEARS as cfy1
    where 
	  (d1.todayLastYearDateOnly between cfy1.FY_START and cfy1.FY_END) 
  ) as cfyPrev

)
,
cte_p1
as
(
  select      
      bd.*
    , d2.*
  from cte_dates_2 as d2
  
  /* Get base data.  Totals are based on DOW not DOS  */

  cross apply (
    select   
        [CLIENT_REP] = fyData.REP_NAME 
      --, fyData.COMPANY_NAME 
      , fydata.CLIENT_NAME
      , fyData.CLIENT_ID
      --, fyData.CLIENT_CDS 
      --, fyData.LEA      
      , LEARecoveryBudget  = isnull(fyData.LEA_RECOVERY_BUDGET,0)    
            
	  , FY1_TOT_DISB       = isnull(fyData.FY1_TOT_DISB,0)
      , FY1_TOT_STATE_FEES = isnull(fyData.FY1_TOT_ADJS,0)
      , FY1_TOT_SVCS       = isnull(fyData.FY1_TOT_SVCS,0)

      , FY0_TOT_DISB       = isnull(fyData.FY0_TOT_DISB,0)
      , FY0_TOT_STATE_FEES = isnull(fyData.FY0_TOT_ADJS,0)
      , FY0_TOT_SVCS       = isnull(fyData.FY0_TOT_SVCS,0)

	from dbo.COMPUTE_FY_TOTALS_LAST_7_CORE ( null, 1, d2.todayDateOnly, 2, 1) as fyData
  ) as bd
)
,
cte_p2
as
(

  select   
     p1.*          	   
 													          
    , [CurrentWorkComparedToPrevious] = iif ( (p1.[FY1_TOT_SVCS ] != 0)
	                                        , (p1.[FY0_TOT_SVCS] / p1.[FY1_TOT_SVCS])
	                                        , 0 )

   , [NUM_SVCS_ENTERED_BY_CLIENT_LAST_30_DAYS] = svcRecByClientLast30.NUM_OF    
   , [NUM_SVCS_ENTERED_ALL_USERS_THIS_WEEK]    = svcRecAllUsersLastWeek.NUM_OF    
   , [NUM_SVCS_ENTERED_ALL_USERS_THIS_YEAR]    = svcRecAllUsersThisFY.NUM_OF
   , [RMTS Moments Not Matched]                = rmtsMissingMatches.notMatched

   , [LAST_TX_DATE]  = dbo.RPT_DATE_FMT(dateOfLastTx.DATE_OF)
   
   , [Previous Year - Date of Service]                       = convert(money,isnull(pfybdt.PreviousFYTotalsByDOS,0))
   , [Current Year - Date of Service]                        = convert(money,isnull(cfybdt.CurrentFYTotalsByDOS,0))   

   , [Missing Orders for DOS]                                = convert(money,isnull(potLostReimburse.c1,0))
   , [Transportation Missing Eligible Services]              = convert(money,isnull(potLostReimburse.c2,0))
   , [Missing ORP Professional]                              = convert(money,isnull(potLostReimburse.c3,0))
   , [No Medi-Cal Consent]                                   = convert(money,isnull(potLostReimburse.c4,0))
   , [Patient Set to Do Not Bill]                            = convert(money,isnull(potLostReimburse.c5,0))
   , [Practitioner Set to Do Not Bill]                       = convert(money,isnull(potLostReimburse.c6,0))
   , [Journal Not Closed or Waiting For Supervised Approval] = convert(money,isnull(potLostReimburse.c7,0))
   , [Practitioner Not In RMTS]                              = convert(money,isnull(potLostReimburse.c8,0))
   , [Missing Supervision]                                   = convert(money,isnull(potLostReimburse.c9,0))  
   , [Missing Assessments]                                   = convert(money,isnull(missingAssmts.maAmt,0))   
   
   , [Promised Services Prior Year]                          = isnull(psleabop2.promisedServicesPrevFY, 0)
   , [Promised Services Current Year]                        = isnull(psleabop2.promisedServicesCurrFY, 0)
   , [Promised Services Past 12 Months]                      = isnull(psleabop2.promisedServicesLast12, 0)	

from cte_p1 as p1
	                              
/*============================================================
 * Total Service Records Entered by Clients over Last 30 Days
 *============================================================*/  

cross apply (
  select 
    NUM_OF = COUNT(sr.id) 
  from dbo.SERVICE_RECORDS  as sr
  join users.dbo.Users      as u on u.userrid = sr.userID
  join users.dbo.Membership as m on m.UserId  = u.UserId
  where (      
        /* Uses following index for sr : [CLIENT_PRAC_PAT_DOS_CREATED_ID_W_EXTRA_COLS] */
	    ((sr.clientID = p1.CLIENT_ID)
		and (sr.pracID is not null)
		and (sr.patID  is not null)
		and (sr.dos    is not null)
        and (sr.created >= p1.today30DaysAgoDateOnly)
		and (sr.id is not null))
        and (m.SBSC_Employee = 0)
  )
) as svcRecByClientLast30

/*============================================================
 * Total Service Records Entered by All Users for Week
 *============================================================*/  
 
cross apply (
  select 
    NUM_OF = COUNT(sr.id) 
  from dbo.SERVICE_RECORDS as sr
  where (        
	    /* Uses following index for sr : [CLIENT_PRAC_PAT_DOS_CREATED_ID_W_EXTRA_COLS] */
		((sr.clientID = p1.CLIENT_ID)
		and (sr.pracID is not null)
		and (sr.patID  is not null)
		and (sr.dos    is not null)
        and (sr.created between p1.startWeek and p1.endWeek)
		and (sr.id is not null))	        
  )
) as svcRecAllUsersLastWeek


/*============================================================
 * Total Service Records Entered by All Users 
 * for Current Fiscal Year
 *============================================================*/  

cross apply (
  select 
    NUM_OF = COUNT(sr.id)
  from dbo.SERVICE_RECORDS as sr
  where (        
       /* Uses following index for sr : [CLIENT_PRAC_PAT_DOS_CREATED_ID_W_EXTRA_COLS] */
	        ((sr.clientID = p1.CLIENT_ID)
		and (sr.pracID is not null)
		and (sr.patID  is not null)
		and (sr.dos    is not null)
        and (sr.created >= p1.FY_START_CURR)
		and (sr.id is not null))
  )
) as svcRecAllUsersThisFY

/*============================================================
 * RMTS - Missing Matches 
 * Uses index : [FOR_SPEDCARE_WEEKLY_RPT]
 *============================================================*/  

cross apply (
  select 
    notMatched = count(rm1.id)
  from dbo.RMTS_Moments as rm1
  where ( 
        ((rm1.clientID = p1.CLIENT_ID) and (rm1.id is not null))
    and (rm1.matched = 0)
	and (rm1.active = 1)
	and (trim(isnull(rm1.ActivityCode,'')) = '2A')
  )
) as rmtsMissingMatches


/*============================================================
 *  Latest Transmission Data 
 *============================================================*/  

outer apply (
  select top 1 
    DATE_OF = ts.TRANSMISSION_DATE 
  from dbo.Transmission_Summary_By_Client_837 as ts
  where (
        (ts.client_id = p1.CLIENT_ID)
	and (ts.TRANSMISSION_DATE    is not null)
	and (ts.TRANSMISSION_LINE_ID is not null)
  )
  order by 
    ts.TRANSMISSION_DATE desc
) as dateOfLastTx


/*============================================================
 * Previous Fiscal Year by DOS Totals
 *============================================================*/  

outer apply 
(
    select
      PreviousFYTotalsByDOS = dbo.BANKERS_ROUND(cpdc_q3.NEW_SVCS_ONLY_TOTAL,0)
    from
    (
      select
        NEW_SVCS_ONLY_TOTAL = sum(cpdc_q2.NEW_SVCS_ONLY)
      from
      (
        select 
		  NEW_SVCS_ONLY = (cpdc_q1.ASSESSMENTS + cpdc_q1.SERVICES_AND_TRANSPORTATION + cpdc_q1.TCM)
        from dbo.RPT_CLAIMS_PAID_BY_DATE_CORE(p1.CLIENT_ID,p1.FY_START_PREV, p1.FY_END_PREV,null,null) as cpdc_q1
      ) as cpdc_q2
    ) as cpdc_q3
) as pfybdt

/*============================================================
 * Current Fiscal Year by DOS Totals
 *============================================================*/  

outer apply 
(
    select
       CurrentFYTotalsByDOS = dbo.BANKERS_ROUND(cpdc_q3.NEW_SVCS_ONLY_TOTAL,0)
    from
    (
      select
        NEW_SVCS_ONLY_TOTAL = sum(cpdc_q2.NEW_SVCS_ONLY)
      from
      (
        select           
          NEW_SVCS_ONLY = (cpdc_q1.ASSESSMENTS + cpdc_q1.SERVICES_AND_TRANSPORTATION + cpdc_q1.TCM)
        from dbo.RPT_CLAIMS_PAID_BY_DATE_CORE (p1.CLIENT_ID,p1.FY_START_CURR, p1.FY_END_CURR,null,null) as cpdc_q1
      ) as cpdc_q2
    ) as cpdc_q3
) as cfybdt


/*============================================================
 * Potential Lost Reimbursement Summary
 * Derived from cached data
 *============================================================*/  

outer apply (
  select top 1
    plrc.*		
  from dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW_WEEKLY_REPORT_SUMMARY(p1.CLIENT_ID) as plrc  
) as potLostReimburse

/*============================================================
 * Missing Assessments Summary
 * Partially derived from cached data
 * Does perform svc rec check
 *============================================================*/  

outer apply (
  select 
    maAmt = sum(ppsmac.totPlrAmt) 
  from dbo.RPT_PATIENT_PROMISED_SERVICES_MISSING_ASSESSMENTS_CORE(p1.CLIENT_ID) as ppsmac
  group by 
    ppsmac.clientID
) as missingAssmts


/*============================================================
 * Promised services totals 
 * Cached data
 *============================================================*/  

outer apply (    
  select top 1 
      promisedServicesLast12  = psleabop1.potLostReimburseLast12
	, promisedServicesCurrFY  = psleabop1.potLostReimburseCurrFY
	, promisedServicesPrevFY  = psleabop1.potLostReimbursePrevFY
  from dbo.PATIENTS_Promised_Services_Delivery_Compliance_Sped_Services_For_LEA_BOP_Reports_Totals as psleabop1
  where 
    (psleabop1.clientID = p1.CLIENT_ID)
) as psleabop2

)

select 
  p2.* 
from cte_p2 as p2
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED_CORE] TO [webuser]
GO
  
