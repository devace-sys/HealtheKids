USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.POTENTIAL_LOST_REIMBURSEMENT_ACTION_ITEM_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.POTENTIAL_LOST_REIMBURSEMENT_ACTION_ITEM_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[POTENTIAL_LOST_REIMBURSEMENT_ACTION_ITEM_VIEW] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT 
  , @clientID            BIGINT
  , @pracID              BIGINT 
  , @repID               BIGINT 
  , @groupSvcClassNameID BIGINT
  , @refDate             DATE  /*Keep as date */
  , @dataSource          INT
  , @holdCodes           VARCHAR(256)
)    

RETURNS @recs table (

    dataSource                bigint
  , totalNumVal               bigint
  , totalNumStr               varchar(256)
  , totalAmtVal               money
  , totalAmtStr               varchar(256)
  , goalNumVal                bigint
  , goalAmtVal                money
  , goalNumStr                varchar(256)
  ,	goalAmtStr                varchar(256)
  , compareNumVal             bigint
  , compareAmtVal             money
  , compareNumStr             varchar(256)
  , compareAmtStr             varchar(256)
  , totalNumGoalNumDiffVal    bigint
  , totalAmtGoalAmtDiffVal    money
  , totalNumGoalNumDiffStr    varchar(256)
  , totalAmtGoalAmtDiffStr    varchar(256)  
) 

BEGIN

 /***************************************************************************    
  * POTENTIAL_LOST_REIMBURSEMENT_ACTION_ITEM_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
declare @today             as datetime = getdate()
declare @newestDOSAllowed  as date     = convert(date,@today)
declare @oldestDOSAllowed  as date     = convert(date,(dbo.CALC_OLDEST_DOS_ALLOWED(@newestDOSAllowed)))

/* Clients we are going to work with */

declare @clients as table (
    CLIENT_ID         bigint
  , LEARecoveryBudget money
)

insert into @clients (
  CLIENT_ID
, LEARecoveryBudget
)
select 
   clc.CLIENT_ID 
 , cc.LEARecoveryBudget
from dbo.CLIENTS_Client_Active_LEA as clc
join dbo.CLIENTS_CLIENT            as cc on cc.CLIENT_ID = clc.CLIENT_ID
where (
    (1=1) 
and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
and ((@repID    is null) or (clc.REP_ID    = @repID))
)
option (recompile)

/* Data source 1, PLR data */

if (@dataSource = 1)
begin
;
with
cte_ds_1_p1
as
(
select 
   clc.CLIENT_ID 
 , cc.LEARecoveryBudget
from dbo.CLIENTS_Client_Active_LEA as clc
join dbo.CLIENTS_CLIENT            as cc on cc.CLIENT_ID = clc.CLIENT_ID
where (
    (1=1) 
and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
and ((@repID is null)    or (clc.REP_ID = @repID))
)
)
,
cte_ds_1_p2
as
(
select 
    rd.NUM_CLAIMS
  , rd.TOT_EST_AMT
  , p1.LEARecoveryBudget
from cte_ds_1_p1 as p1
join dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA as rd on rd.CLIENT_ID = p1.CLIENT_ID
left join dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA_RESPONSES as chcr on 
	    chcr.PLR_ID_STRING = rd.PLR_ID_STRING
join (
  select 
    holdCodeIn = convert(bigint,hc1.value) 
  from STRING_SPLIT (@holdCodes,',') as hc1
) as hc2 on hc2.holdCodeIn = rd.HOLD_CODE
where ( 
      (1=1) 
  and ((@groupSvcClassNameID is null) or (rd.PRAC_GROUP_FAMILY_ID = @groupSvcClassNameID))
  and (isnull(chcr.DEFER, 0) = 0)
)
)
,
cte_ds_1_p3
as
(
  select 
     sum(p2.NUM_CLAIMS)        as totalNumVal  
   , sum(p2.TOT_EST_AMT)       as totalAmtVal
   , sum(p2.LEARecoveryBudget) as compareAmtVal
 from cte_ds_1_p2 as p2
)

insert into @recs (dataSource,totalNumVal,totalAmtVal,compareAmtVal)
select 
   @dataSource 
 , p3.totalNumVal
 , p3.totalAmtVal
 , p3.compareAmtVal
from cte_ds_1_p3 as p3
option (recompile)

end

/* Data Source = 2, Missing Assessements All */

else if (@dataSource = 2)
begin

;
with
cte_ds_2_p1
as
(

select 
    sum(cp.totalNumVal)   as totalNumVal
  , sum(cp.totalAmtVal)   as totalAmtVal
  , sum(cp.compareAmtVal) as compareAmtVal
from @clients as c
cross apply (
select 
   count(mac.NumOfAssmts)    as totalNumVal
 , sum(mac.AssessementRate)  as totalAmtVal
 , sum(cc.LEARecoveryBudget) as compareAmtVal
from dbo.RPT_MISSING_ASSESSMENTS_CORE (c.CLIENT_ID, @repID,1,1) as mac
join dbo.CLIENTS_CLIENT                                            as cc on cc.CLIENT_ID = mac.ClientID
) as cp
where ( 
     (@dataSource = 2)
)
)

insert into @recs (dataSource,totalNumVal,totalAmtVal,compareAmtVal)
select 
  @dataSource 
 ,p1.totalNumVal
 ,p1.totalAmtVal
 ,p1.compareAmtVal
from cte_ds_2_p1 as p1
option (recompile)

end

/* Data Source = 3, Missing Assessements Group family (for future use) */

/* Data Source = 4, Missing Assessments, prac caseload only */

else if (@dataSource = 4)
begin

;
with
cte_ds_4_p1
as
(

select 
   count(pce.id) as totalNumVal
 , 0 as totalAmtVal

from [dbo].[PRACTITIONER_CASELOAD_EXPECTED_PATIENT_ASSESSMENT_SERVICES_COMPLIANCE_VIEW] (
   @userID            
 , @userGroup         
 , @userRank        
 , @clientID        
 , @pracID  
 , 1  /* null = For upcoming shows any patient and for missing shows just caseload
       * 1    = For upcoming and missing shows just caseload
 	   */      
) as pce

where ( 
     (@dataSource = 4)
)
)
insert into @recs (dataSource,totalNumVal,totalAmtVal)
select 
  @dataSource 
 ,p1.totalNumVal
 ,p1.totalAmtVal
from cte_ds_4_p1 as p1
option (recompile)

end

/* Data Source = 5, Missing Consent */

else if (@dataSource = 5)
begin

;
with
cte_ds_5_p1
as
(

select 
    sum(cp.totalNumVal)   as totalNumVal
  , sum(cp.totalAmtVal)   as totalAmtVal
  , sum(cp.compareAmtVal) as compareAmtVal
from @clients as c
cross apply (
select 
   count(ppmc.id) as totalNumVal
 , sum(ppmc.HELD_CLAIMS_TOTAL_EST_REIMBURSE_AMOUNT_VAL) as totalAmtVal
 , sum(cc.LEARecoveryBudget)                            as compareAmtVal
from  dbo.PATIENT_PARENT_MCAL_CONSENT_VIEW (c.CLIENT_ID, null, null, null, 1) as ppmc
join dbo.CLIENTS_CLIENT                                                       as cc on cc.CLIENT_ID = ppmc.CLIENT_ID
) as cp
where ( 
     (@dataSource = 5)
)
)
insert into @recs (dataSource,totalNumVal,totalAmtVal,compareAmtVal)
select 
  @dataSource 
 ,p1.totalNumVal
 ,p1.totalAmtVal
 ,p1.compareAmtVal
from cte_ds_5_p1 as p1
option (recompile)

end

/* Data Source = 6, Reimbursement history by dos */

else if (@dataSource = 6)
begin

;
with
cte_ds_6_p1
as
(
  select top 1 
	  totalNumVal            = 0
    , totalAmtVal            = dosTots.Total
	, goalNumVal             = 0
	, goalAmtVal             = dosTots.RecoveryGoal
	, totalNumGoalNumDiffVal = 0
	, totalAmtGoalAmtDiffVal = (dosTots.Total - dosTots.RecoveryGoal)
	
  from dbo.COMPANY_FISCAL_YEARS as cfy
  cross apply (
    select
      Total        = dbo.BANKERS_ROUND(sum(cpdc_q3.NEW_SVCS_ONLY_TOTAL),0)
    , RecoveryGoal = dbo.CALC_LEA_REIMBURSEMENT_GOAL_EXPECTED_PROGESS_BY_FY_MONTH(@refDate,sum(cpdc_q3.LEA_RECOVERY_GOAL))
	from
    (
      select
           LEA_RECOVERY_GOAL   = cpdc_q2.LEA_RECOVERY_GOAL
		 , NEW_SVCS_ONLY_TOTAL = sum(cpdc_q2.NEW_SVCS_ONLY)
		
      from
      (
	    select 
		    cp.NEW_SVCS_ONLY
		  , cp.LEA_RECOVERY_GOAL
		from @clients as c
		cross apply (
        select 
            NEW_SVCS_ONLY = (cpdc_q1.ASSESSMENTS + cpdc_q1.SERVICES_AND_TRANSPORTATION + cpdc_q1.TCM) 
		  , cpdc_q1.LEA_RECOVERY_GOAL
        from dbo.RPT_CLAIMS_PAID_BY_DATE_CORE (c.CLIENT_ID,cfy.FY_START, cfy.FY_END,null,null) as cpdc_q1
		) as cp

      ) as cpdc_q2
	  group by 
	    cpdc_q2.LEA_RECOVERY_GOAL
    ) as cpdc_q3
  ) as dosTots
  where ( 
      (@dataSource = 6)
  and (@refDate between cfy.FY_START and cfy.FY_END)
  )
)
  
insert into @recs (dataSource,totalNumVal,totalAmtVal,goalNumVal,goalAmtVal,totalNumGoalNumDiffVal,totalAmtGoalAmtDiffVal)
select 
   @dataSource 
 , p1.totalNumVal
 , p1.totalAmtVal
 , p1.goalNumVal
 , p1.goalAmtVal
 , p1.totalNumGoalNumDiffVal
 , p1.totalAmtGoalAmtDiffVal
from cte_ds_6_p1 as p1
option (recompile)

	
/* If there is no financial report data then we have to return a row with 0s for everything */
 
if not exists (select * from @recs) 
begin
    insert into @recs (dataSource,totalNumVal,totalAmtVal,goalNumVal,goalAmtVal,totalNumGoalNumDiffVal,totalAmtGoalAmtDiffVal)
    select 
       @dataSource 
     , totalNumVal = 0
     , totalAmtVal = 0
     , goalNumVal  = 0
     , goalAmtVal  = 0
     , totalNumGoalNumDiffVal = 0
     , totalAmtGoalAmtDiffVal = 0
    
end

end

/* Data Source = 7, Reimbursement history by checkdate */

else if (@dataSource = 7)
begin

;
with
cte_ds_7_p1
as
(
select 
	  totalNumVal            = 0
    , totalAmtVal            = dosTots.Total
	, goalNumVal             = 0
	, goalAmtVal             = dosTots.RecoveryGoal
	, totalNumGoalNumDiffVal = 0
	, totalAmtGoalAmtDiffVal = (dosTots.Total - dosTots.RecoveryGoal)

  from dbo.COMPANY_FISCAL_YEARS as cfy
  cross apply (
    select
      Total        = dbo.BANKERS_ROUND(sum(cpdc_q3.NEW_SVCS_ONLY_TOTAL),0)	     
    , RecoveryGoal = sum(cpdc_q3.LEA_RECOVERY_GOAL)
    from
    (
      select
	     LEA_RECOVERY_GOAL   = cpdc_q2.LEA_RECOVERY_GOAL
       , NEW_SVCS_ONLY_TOTAL = sum(cpdc_q2.NEW_SVCS_ONLY)
      from
      (
        select 
		    NEW_SVCS_ONLY     = isnull(cp.NEW_SVCS_ONLY, 0)
		  , LEA_RECOVERY_GOAL = c.LEARecoveryBudget
		from @clients as c
		outer apply (
		select 
            NEW_SVCS_ONLY = (cpdc_q1.ASSESSMENTS + cpdc_q1.SERVICES_AND_TRANSPORTATION + cpdc_q1.TCM)   
        from dbo.RPT_CLAIMS_PAID_BY_DATE_CORE (c.CLIENT_ID,null,null,cfy.FY_START, cfy.FY_END) as cpdc_q1
        ) as cp
	  
	  ) as cpdc_q2
      group by 
	    cpdc_q2.LEA_RECOVERY_GOAL
	) as cpdc_q3
  ) as dosTots
where( (@dataSource = 7) 
   and (@refDate between cfy.FY_START and cfy.FY_END)
)
)
insert into @recs (dataSource,totalNumVal,totalAmtVal,goalNumVal,goalAmtVal,totalNumGoalNumDiffVal,totalAmtGoalAmtDiffVal)
select 
   @dataSource 
 , p1.totalNumVal
 , p1.totalAmtVal
 , p1.goalNumVal
 , p1.goalAmtVal
 , p1.totalNumGoalNumDiffVal
 , p1.totalAmtGoalAmtDiffVal
from cte_ds_7_p1 as p1
option (recompile)

end


/* Data Source = 8, Reimbursement annual goal */

else if (@dataSource = 8)
begin

;
with
cte_ds_8_p1
as
(
select top 1
	  totalNumVal = 0
    , totalAmtVal = cc.LEARecoveryBudget
  from dbo.CLIENTS_Client as cc
where ( (@dataSource = 8) 
   and (cc.CLIENT_ID = @clientID)
)
)
insert into @recs (dataSource,totalNumVal,totalAmtVal)
select 
  @dataSource 
 ,p1.totalNumVal
 ,p1.totalAmtVal
from cte_ds_8_p1 as p1
option (recompile)

end

/* Data Source = 9, Missing SpEd treatments */

else if (@dataSource = 9)
begin
;
with
cte_ds_9_p1
as
( 
  /* This is now using CALPADS data*/
   
  select 
      totalNumVal = sum(mtc.minsExpectedApplicableDiff) 
    , totalAmtVal = sum(mtc.estLostReimburse)
   
  from dbo.RPT_MISSING_TREATMENTS_CORE ( 
      @clientID
	, @repID
	, @groupSvcClassNameID
	, null /*  @spEdServiceCode */
	, 1 , 1 , 1, null ) as mtc

)
insert into @recs (dataSource,totalNumVal,totalAmtVal)
select 
  @dataSource 
 ,p1.totalNumVal
 ,p1.totalAmtVal
from cte_ds_9_p1 as p1
option (recompile)

end

update t1
set
    totalNumStr            = format(round(isnull(t1.totalNumVal,             0), 0), 'N0')
  , totalAmtStr            = format(round(isnull(t1.totalAmtVal,             0), 0), 'N0')
  , goalNumStr             = format(round(isnull(t1.goalNumVal,              0), 0), 'N0')
  , goalAmtStr             = format(round(isnull(t1.goalAmtVal,              0), 0), 'N0')
  , compareNumStr          = format(round(isnull(t1.compareNumVal,           0), 0), 'N0')
  , compareAmtStr          = format(round(isnull(t1.CompareAmtVal,           0), 0), 'N0')
  , totalNumGoalNumDiffStr = format(round(isnull(t1.totalNumGoalNumDiffVal,  0), 0), 'N0')
  , totalAmtGoalAmtDiffStr = format(round(isnull(t1.totalAmtGoalAmtDiffVal,  0), 0), 'N0')
  
from @recs as t1
option (recompile)

return

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[POTENTIAL_LOST_REIMBURSEMENT_ACTION_ITEM_VIEW] TO [webuser]
GO  
