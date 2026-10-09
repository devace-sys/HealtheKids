GO
USE SPEDMON
SELECT 
	  cc.CLIENT_NAME							as 'Client'
	 ,pp.LAST_NAME + ', ' + pp.FIRST_NAME		as 'Patient'
	 ,prac.LAST_NAME + ', ' + prac.FIRST_NAME	as 'Practitioner'
	 ,CONVERT(date, clm.SERVICE_DATE)			as 'Service Date'
	 ,iep.NAME									as 'Service'
	 ,cca.ADJUDICATION_ID						as 'ID#'
	 ,cdc.CODE_VALUE							as 'Denial Code'
	 ,cdc.DETAIL_TEXT							as 'Denial Comments'
	 	,CASE
			WHEN sr.reference like '%.%.%'
			THEN um.LastName + ', ' +um.FirstName
			ELSE sr.reference
			END									as 'Recorded by OR Document #'
	,convert(date,clm.ENTRY_DATE)				as 'Date Recorded'
	
FROM dbo.CLAIM_Claim_Adjudication				as cca
	JOIN dbo.CLAIM_CLAIM_ADJUDICATION_DETAILS	as cad	on cad.ADJUDICATION_ID = cca.ADJUDICATION_ID
	JOIN dbo.CLAIM_DETAIL_CODES					as cdc	on cdc.CODE_ID = cad.DETAIL_CODE_ID
	JOIN dbo.CLAIM_DETAIL_GROUPS				as cdg	on cdg.GROUP_ID = cad.DETAIL_GROUP_ID
	JOIN dbo.CLAIM_Claim						as clm	on clm.CLAIM_ID = cca.CLAIM_ID
	JOIN dbo.CLAIM_Procedures					as cp	on cp.PROCEDURE_ID = clm.PROCEDURE_ID
	JOIN dbo.CLAIM_IEPandIFSPNames				as iep	on iep.IEP_IFSP_NAME_ID = cp.IEP_IFSP_NAME
	LEFT JOIN dbo.CLAIM_NoPlanNames				as np	on np.NO_PLAN_NAME_ID = cp.NO_PLAN_NAME
	JOIN dbo.CLIENTS_Client						as cc	on cc.CLIENT_ID = clm.CLIENT_ID
	JOIN dbo.PATIENTS_Patient					as pp	on pp.PATIENT_ID = clm.PATIENT_ID
	JOIN dbo.PRACTITIONER_Practitioner			as prac	on prac.PRACTITIONER_ID = clm.PRACTITIONER_ID
	JOIN users.dbo.Users						as uu	on uu.userrid = clm.USER_ID
	JOIN users.dbo.Membership					as um	on um.UserId = uu.UserId
	JOIN SERVICE_RECORDS						as sr	on sr.claimID1 = clm.CLAIM_ID

WHERE 1=1
	and cca.DATE_ADJUDICATED >= DATEADD(wk,DATEDIFF(wk,7,GETDATE()),6) --Last Sunday
	and cca.DATE_ADJUDICATED <= DATEADD(wk,DATEDIFF(wk,0,GETDATE()),6) --Next Sunday
	and cca.AMOUNT_PAID = 0
	and cc.CLIENT_ID = %d

ORDER BY cc.CLIENT_NAME, pp.LAST_NAME, pp.FIRST_NAME, clm.SERVICE_DATE, cdc.CODE_VALUE
GO