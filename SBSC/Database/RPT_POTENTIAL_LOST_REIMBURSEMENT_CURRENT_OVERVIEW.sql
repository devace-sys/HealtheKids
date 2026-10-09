USE [SPEDMON]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW]
GO

 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW] (  
    @clientID       bigint
  , @repID          bigint
)
 
RETURNS TABLE
 
 /***************************************************************************    
  * RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW */    
 /**    
  * Returns a table 
  *    
  * @param   clientID       Record ID of client to run report for
  * @param   repID          ID of the consultant who has been assigned that client.
  * @return                 Table of report rows
  ***************************************************************************/     
 
AS RETURN (

  select top (dbo.CONST_MAX_ROWS())
       REP_NAME
     , REP_EMAIL
     , CLIENT_NAME
	 , HOLD_REASON
     , numClaims
	 , estReimb
    

  from
  (

    select
        cch.REP_NAME
      , cch.REP_EMAIL
      , cch.CLIENT_NAME
	  , chc.HOLD_REASON  
      , sum(cch.NUM_CLAIMS)   as numClaims   
      , sum(cch.TOT_EST_AMT)  as estReimb
    
	from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA as cch
    join dbo.CLAIM_HOLD_CODES                                        as chc   on chc.HOLD_CODE     = cch.HOLD_CODE

    where (
           (1=1)
      and  ((@clientID  is null) or (CLIENT_ID = @clientID))
      and  ((@repID     is null) or (REP_ID    = @repID))
    )
    
	group by 
      cch.REP_NAME
    , cch.REP_EMAIL
    , cch.CLIENT_NAME
    , chc.HOLD_REASON 

	) as q1

	  order by
      REP_NAME   asc
    , REP_EMAIL   asc
    , CLIENT_NAME asc 
    , estReimb   desc


) 
 GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT_OVERVIEW] TO [webuser]     
GO
 