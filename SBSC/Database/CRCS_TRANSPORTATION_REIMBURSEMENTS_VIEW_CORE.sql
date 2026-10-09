USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_TRANSPORTATION_REIMBURSEMENTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_TRANSPORTATION_REIMBURSEMENTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_TRANSPORTATION_REIMBURSEMENTS_VIEW_CORE] ( 
	   @clientID          BigInt    
	 , @fiscalYearID      BigInt
	 , @recID             Bigint
)
     
RETURNS TABLE  

AS RETURN (
	with cte_trans_reimbursements as (
		select   
			  amtPaid  = isnull(sum(cca.AMOUNT_PAID),0)
			, patID    = clm.PATIENT_ID
		from dbo.COMPANY_FISCAL_YEARS      as cfy
		join dbo.CLAIM_Claim               as clm  on ((clm.CLIENT_ID = @clientID)
													and (clm.SERVICE_DATE between cfy.FY_START and cfy.FY_END)
													and ((clm.STATUS = convert(char(10),3)) /* Claim Paid */))
		join dbo.CLAIM_Procedures          as cp   on ((cp.PROCEDURE_ID = clm.PROCEDURE_ID)
													and (cp.SERVICE_TYPE_ID = 3) /* Transportation Service */)
 
		join dbo.CLAIM_Claim_Adjudication  as cca on cca.CLAIM_ID        = clm.CLAIM_ID
		where 
			(cfy.ID = @fiscalYearID)
		group by clm.PATIENT_ID
	)

	select 
		  tr.amtPaid
		, tr.patID  
		, dob      = pp.DATE_OF_BIRTH
		, dobStr   = dbo.RPT_DATE_FMT(pp.DATE_OF_BIRTH)
		, patName  = pp.CONCAT_NAME
		, siteName = ps.SITE_NAME
	from cte_trans_reimbursements as tr
	join dbo.PATIENTS_Patient as pp on pp.PATIENT_ID = tr.patID
	left join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID)  as ps on ps.PATIENT_ID = tr.patID 
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_TRANSPORTATION_REIMBURSEMENTS_VIEW_CORE] TO [webuser]
GO