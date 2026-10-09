GO
USE SPEDMON

SELECT
     cc.client_name
    ,clm.claim_ID
    ,cp.procedure_code
    ,convert(date,clm.service_date)		AS 'Service Date'
    ,trc.Amount_Transmitted
    ,cca.AMOUNT_PAID					AS 'Paid Amount B4 EDS percent'
    ,(cca.AMOUNT_PAID*cca.EDSPERCENT)	AS 'Amount Paid x EDS Percent'

FROM [SPEDMON].[dbo].[CLAIM_Claim]		AS clm
	JOIN dbo.CLAIM_Claim_Adjudication	AS cca	ON cca.CLAIM_ID = clm.CLAIM_ID
	JOIN dbo.CLAIM_Procedures			AS cp	ON cp.PROCEDURE_ID = clm.PROCEDURE_ID
	JOIN dbo.CLIENTS_Client				AS cc	ON cc.CLIENT_ID = clm.CLIENT_ID
	JOIN dbo.Transmission_Record_Claims	AS trc	ON trc.claim_id=cca.CLAIM_ID

WHERE 1=1
	AND cp.PROCEDURE_CODE IN ('A0425', 'T2003')
	AND cca.DATE_ADJUDICATED >= %s
	AND cca.CCN LIKE '%532855%'

ORDER BY cc.CLIENT_NAME,clm.SERVICE_DATE,clm.CLAIM_ID
GO

