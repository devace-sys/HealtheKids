GO
--Set the date and client in these two "declare" statements:
DECLARE @WarrantDate DATE
	Set @WarrantDate = %s
DECLARE @ClientID bigint
	Set @ClientID = %d
USE SPEDMON
-----************ Claim List
SELECT
	   'Claim List'								AS 'Section'
	  ,ccr.first_name + ' ' + ccr.last_name		AS 'Consultant'
      ,cc.CLIENT_NAME							AS 'Client'
      ,prac.CONCAT_NAME							AS 'Practitioner'
      ,pat.CONCAT_NAME							AS 'Patient'
      ,convert(date,clm.SERVICE_DATE)			AS 'Service Date'
      ,clm.SERVICE_UNITS						AS 'Service Units'
      ,convert(date,cca.DATE_ADJUDICATED)		AS 'Date Paid'
      
FROM [SPEDMON].[dbo].[CLAIM_Claim]		AS clm
	JOIN dbo.PATIENTS_Patient			AS pat		ON pat.PATIENT_ID = clm.PATIENT_ID
	JOIN dbo.PRACTITIONER_Practitioner	AS prac		ON prac.PRACTITIONER_ID = clm.PRACTITIONER_ID
	JOIN dbo.CLIENTS_Client				AS cc		ON cc.CLIENT_ID = clm.CLIENT_ID
	JOIN dbo.CLAIM_Claim_Adjudication	AS cca		ON cca.CLAIM_ID = clm.CLAIM_ID
	JOIN dbo.CLIENTS_Client_Reps		AS ccr		ON ccr.id = cc.ClientRepIDLEACurrent
	
WHERE 1=1
	AND cc.CLIENT_ID = @ClientID
	AND cca.DATE_ADJUDICATED = @WarrantDate
	
GROUP BY ccr.first_name + ' ' + ccr.last_name
      ,cc.CLIENT_NAME
      ,prac.CONCAT_NAME
      ,pat.CONCAT_NAME
      ,clm.SERVICE_DATE
      ,clm.SERVICE_UNITS
      ,convert(date,cca.DATE_ADJUDICATED)

ORDER BY prac.CONCAT_NAME, pat.CONCAT_NAME, convert(date,clm.SERVICE_DATE)
GO
