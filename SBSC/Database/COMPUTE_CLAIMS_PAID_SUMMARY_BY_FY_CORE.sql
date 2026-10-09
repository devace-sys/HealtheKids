USE SPEDMON
GO

/*-------------------------------
* Exists/Drop
*------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.COMPUTE_CLAIMS_PAID_SUMMARY_BY_FY_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.COMPUTE_CLAIMS_PAID_SUMMARY_BY_FY_CORE
GO

CREATE FUNCTION [dbo].[COMPUTE_CLAIMS_PAID_SUMMARY_BY_FY_CORE] (    
   @fyStart               date
 , @fyEnd                 date
 , @okToReportUpToDate    date
)

returns TABLE 
WITH SCHEMABINDING 
as
return
(

  select      
        cc.CLIENT_ID
      , TOT_SVCS   = sum(case when cp.SERVICE_TYPE_ID is not null then ca.AMOUNT_PAID else 0.00 end)
      , TOT_ADJS   = sum(case when cp.SERVICE_TYPE_ID is null     then ca.AMOUNT_PAID else 0.00 end)
      , TOT_PAID   = sum(ca.AMOUNT_PAID)
      , TOT_DISB   = sum(CONVERT(NUMERIC(18,8),(ca.AMOUNT_PAID * ca.EDSPERCENT)))
    
    from dbo.CLAIM_Claim_Adjudication as ca    
    join dbo.CLAIM_Claim              as cc on cc.CLAIM_ID       = ca.CLAIM_ID
    join dbo.CLAIM_Procedures         as cp on cp.PROCEDURE_ID   = cc.PROCEDURE_ID 
    
    where ( 	       
	      (cc.IS_PROXY = 0)
	  and (ca.AMOUNT_PAID != 0)
	  and (convert(date,ca.DATE_ADJUDICATED) between @fyStart and @fyEnd)    
	  and (convert(date,ca.DATE_ADJUDICATED) <= @okToReportUpToDate)
	)
    
	group by 
      cc.CLIENT_ID   
)

GO

GRANT SELECT ON  [dbo].[COMPUTE_CLAIMS_PAID_SUMMARY_BY_FY_CORE] TO [webuser]
GO