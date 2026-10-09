USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT] (  
    @clientID       bigint
)
 
RETURNS TABLE
 
 /***************************************************************************    
  * RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT */    
 /**    
  * Returns a table 
  *    
  * @param   userID         The userid of who is requesting the report
  * @param   userGroup      Users group    
  * @param   userRank       User rank
  * @param   clientID       Record ID of client to run report for
  * @param   startDate      Starting DOS
  * @param   endDate        Ending DOS      
  * @return                 Table of report rows
  ***************************************************************************/     
 
AS RETURN (

  select top (dbo.CONST_MAX_ROWS())
      cch.REP_NAME
    , cch.REP_EMAIL
    , cch.CLIENT_NAME
    , SVC_DOS_MONTH_YEAR  = dbo.RPT_DATE_FMT(cch.SVC_DOS_MONTH_YEAR)
	, SVC_DOS_USE_OR_LOSE = dbo.RPT_BIT_TO_YN(cch.SVC_DOS_USE_OR_LOSE)
	, cch.PAT_NAME
	, cch.PAT_CSIS
    , cch.PAT_BIC
	, PAT_DOB = dbo.RPT_DATE_FMT(cch.PAT_DOB)
    , cch.PRAC_GROUP_FAMILY_NAME
    , cch.PRAC_NAME
    , cch.PRAC_GROUP_NAME
    , cch.SVC_TYPE_NAME
    , CURRENT_HOLD_REASON = chc.HOLD_REASON    
	, RECOMMENDED_ACTION = chrac.ACTION_TEXT
	, cch.ADDITIONAL_INFORMATION	
	, cch.NUM_CLAIMS
    , cch.TOT_EST_AMT
	, LAST_UPDATED = dbo.RPT_DATE_FMT(cch.LAST_UPDATED)
  
from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA as cch
join dbo.CLAIM_HOLD_CODES                                        as chc   on chc.HOLD_CODE     = cch.HOLD_CODE
join dbo.CLAIM_HOLD_RECOMMENDED_ACTION_CODES                     as chrac on chrac.ACTION_CODE = cch.RECOMMENDED_ACTION_CODE

where (
  (cch.CLIENT_ID = @clientID)
)

order by
  cch.SVC_DOS_MONTH_YEAR  desc     
) 
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_POTENTIAL_LOST_REIMBURSEMENT_CURRENT] TO [webuser]
GO