USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DETAILS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DETAILS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DETAILS] ()    

RETURNS 
TABLE
AS
RETURN
(

/***************************************************************************    
 * RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DETAILS */    
/**    
 ***************************************************************************/                         

with
cte_p1
as
(
select 

    t1.REASON
  , CLAIM_AGES_OUT_IN_DAYS = datediff(day,t1.REF_DATE_OLDEST_DOS,clm.SERVICE_DATE)
  , t1.CLAIM_ID
  , W                      = t1.SLOT
  , W_DATE                 = convert(date,t1.CHECK_DATE) /* Used in sort and paging... dont convert to string */
  , t1.CCN	 
  , CURRENT_CLAIM_STATUS   = csc.STATUS_NAME  
  , PATIENT                = pap.CONCAT_NAME	
  , DOB                    = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
  , BIC                    = trim(isnull(pap.BIC,N''))
  , PATIENT_ELIGIBLE       = dbo.RPT_BIT_TO_YNU(pen2.IS_ELIG)
  , DOS                    = dbo.RPT_DATE_FMT(clm.SERVICE_DATE)
  , SERVICE_RENDERED       = trim(isnull(st2.SERVICE_TYPE_NAME,'') + ' ' + st1.SERVICE_TYPE_NAME)
  
  , PROC_MOD_COMBO         = dbo.RPT_PROC_MOD_COMBO (  cp.PROCEDURE_CODE
	                                                 , cp.PROCEDURE_MODIFIER_1
	                                                 , cp.PROCEDURE_MODIFIER_2
	                                                 , cp.PROCEDURE_MODIFIER_3
	                                                 , cp.PROCEDURE_MODIFIER_4 )

  , clm.SERVICE_UNITS
  , RENDERED_BY_A          = gg.GROUP_NAME
  , CLIENT                 = clc.CLIENT_NAME
 	
from dbo.CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DATA_CORE( null, 8 /* Change if we expand*/) as t1

join dbo.CLAIM_Claim                 as clm  on clm.CLAIM_ID     = t1.CLAIM_ID
join dbo.CLAIM_Claim_Status_Codes    as csc  on csc.STATUS_CODE  = clm.STATUS
join dbo.GROUP_Group                 as gg   on gg.GROUP_ID      = clm.GROUP_ID
join dbo.CLAIM_Procedures            as cp   on cp.PROCEDURE_ID  = clm.PROCEDURE_ID
join dbo.PATIENTS_Patient            as pap  on pap.PATIENT_ID   = clm.PATIENT_ID
join dbo.CLIENTS_Client              as clc  on clc.CLIENT_ID    = t1.CLIENT_ID
  
join      dbo.CLAIM_Procedures_Service_Types as st1 on st1.SERVICE_TYPE_ID = cp.SERVICE_TYPE_ID
left join dbo.CLAIM_Procedures_Service_Types as st2 on st2.SERVICE_TYPE_ID = cp.SERVICE_SUB_TYPE_1_ID

outer apply (
  select top 1 
    pen1.IS_ELIG 
  from dbo.PATIENTS_ELIGIBILITY_NORMALIZED as pen1 
  where (
        (pen1.PATIENT_ID = clm.PATIENT_ID)
    and (pen1.MONTH_DATE = (DATEFROMPARTS ( ( DATEPART(YEAR,clm.SERVICE_DATE)),( DATEPART(month,clm.SERVICE_DATE)),1)))
  )
) as pen2 

)

select top (dbo.CONST_MAX_ROWS())
  p1.* 
from cte_p1 as p1
order by 
    p1.REASON
  , p1.CLAIM_AGES_OUT_IN_DAYS
  , p1.CLAIM_ID
  , p1.W 
  , p1.W_DATE
  , p1.CCN
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DETAILS] TO [webuser]
GO  
