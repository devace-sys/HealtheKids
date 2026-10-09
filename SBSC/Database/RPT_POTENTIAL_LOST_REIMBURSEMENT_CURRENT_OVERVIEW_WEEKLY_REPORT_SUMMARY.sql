USE [SPEDMON]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW_WEEKLY_REPORT_SUMMARY]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW_WEEKLY_REPORT_SUMMARY]
GO

 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW_WEEKLY_REPORT_SUMMARY] (  
    @clientID       bigint
)
 
RETURNS TABLE
 
 /***************************************************************************    
  * RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW_WEEKLY_REPORT_SUMMARY */    
 /**    
  * Returns a table 
  *    
  * @param   clientID       Record ID of client to run report for
  * @return                 Table of report rows
  ***************************************************************************/     
 
AS RETURN (

  with
  cte_p1
  as
  (
    select 
        cch.HOLD_CODE
	  , cch.TOT_EST_AMT
    from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA as cch
    where 
	  /* Uses index : [CLIENT_ID_IDX]*/
	  ((cch.CLIENT_ID = @clientID) and (cch.idx is not null))
  )
  ,
  cte_p2
  as
  (
    select 	 
	   c1d = case when p1.HOLD_CODE in (1200,1300,1400)           then p1.TOT_EST_AMT else 0 end
	 , c2d = case when p1.HOLD_CODE in (1100)                     then p1.TOT_EST_AMT else 0 end
	 , c3d = case when p1.HOLD_CODE in (1500,1600,1625,1700,1725) then p1.TOT_EST_AMT else 0 end
	 , c4d = case when p1.HOLD_CODE in (1000)                     then p1.TOT_EST_AMT else 0 end
	 , c5d = case when p1.HOLD_CODE in (900)                      then p1.TOT_EST_AMT else 0 end
	 , c6d = case when p1.HOLD_CODE in (400)                      then p1.TOT_EST_AMT else 0 end
	 , c7d = case when p1.HOLD_CODE in (1800,1900,200,2100)       then p1.TOT_EST_AMT else 0 end
	 , c8d = case when p1.HOLD_CODE in (910)                      then p1.TOT_EST_AMT else 0 end
	 , c9d = case when p1.HOLD_CODE in (920)                      then p1.TOT_EST_AMT else 0 end
	from cte_p1 as p1
  )
  ,
  cte_p3
  as
  (
  select 
       c1s = sum(p2.c1d)
	  ,c2s = sum(p2.c2d)
	  ,c3s = sum(p2.c3d)
	  ,c4s = sum(p2.c4d)
	  ,c5s = sum(p2.c5d)
	  ,c6s = sum(p2.c6d)
	  ,c7s = sum(p2.c7d)
	  ,c8s = sum(p2.c8d)
	  ,c9s = sum(p2.c9d)
   from cte_p2 as p2   
  )
  -----Dont change these column names from c1-c9
  select
      [c1] = c1s /* Missing Orders and Missing orders for DOS*/
    , [c2] = c2s /* Transportation - Missing Eligible Service */
    , [c3] = c3s /* Missing ORP Professional*/
    , [c4] = c4s /* No Medi-Cal Consent */
    , [c5] = c5s /* Patient set to do not bill */
    , [c6] = c6s /* Practitioner set to do not bill */
    , [c7] = c7s /* Journal Not Closed or Waiting For Supervised Approval */
	, [c8] = c8s /* RMTS requriements not met */
	, [c9] = c9s /* Supervision requirements not met */
  from cte_p3 as p3
           
) 
 GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW_WEEKLY_REPORT_SUMMARY] TO [webuser]     
GO
 

 ---SELECT * FROM [RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW_WEEKLY_REPORT_SUMMARY] (38)