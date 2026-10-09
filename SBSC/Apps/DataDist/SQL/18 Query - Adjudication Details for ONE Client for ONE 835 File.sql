GO
USE SPEDMON
SELECT 
	   cca.DATE_ADJUDICATED						AS 'Adjudication Date'
      ,cca.CCN									AS 'DHCS Clm Conttrol #'
      ,clm.SERVICE_DATE							AS 'Date of Service'
      ,pat.CONCAT_NAME							AS 'Patient Name'
      ,prac.CONCAT_NAME							AS 'Practitioner Name'
      ,cp.PROCEDURE_NAME						AS 'Procedure Name'
      ,cca.AMOUNT_PAID							AS 'Amount'
      
      
FROM [dbo].[CLAIM_Claim_Adjudication] AS cca
	JOIN CLAIM_Claim AS clm on clm.CLAIM_ID = cca.CLAIM_ID
	JOIN CLIENTS_Client AS cc on cc.CLIENT_ID = clm.CLIENT_ID
	JOIN CLAIM_Procedures AS cp on cp.PROCEDURE_ID = clm.PROCEDURE_ID
	JOIN PRACTITIONER_Practitioner AS prac on prac.PRACTITIONER_ID = clm.PRACTITIONER_ID
	JOIN PATIENTS_Patient AS pat on pat.PATIENT_ID = clm.PATIENT_ID
	
WHERE 1=1
	AND cca.DATE_ADJUDICATED = %s
	AND clm.CLIENT_ID = %d
	
ORDER by pat.CONCAT_NAME, clm.SERVICE_DATE
GO