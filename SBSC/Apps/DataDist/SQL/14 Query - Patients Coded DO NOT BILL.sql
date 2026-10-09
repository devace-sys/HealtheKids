GO
USE SPEDMON
SELECT 
	   ccr.first_name + ' ' + ccr.last_name
	  ,cc.CLIENT_NAME
      ,pp.CONCAT_NAME
      ,CONVERT(DATE, pp.DATE_OF_BIRTH)
      ,ISNULL(pp.CSIS, 'UNKNOWN')

FROM [SPEDMON].[dbo].[PATIENTS_Patient]		AS pp
	JOIN dbo.PATIENTS_Client				AS pc	ON pc.PATIENT_ID = pp.PATIENT_ID
	JOIN dbo.CLIENTS_Client					AS cc	ON cc.CLIENT_ID = pc.CLIENT_ID
	JOIN dbo.CLIENTS_Client_Reps			AS ccr	ON ccr.id = cc.ClientRepIDLEACurrent
  
WHERE 1=1
	AND SUBMIT_CLAIMS = 0
	AND pp.ACTIVE <> 'N'
	AND cc.LEA = 1

ORDER BY (ccr.first_name + ' ' + ccr.last_name), cc.CLIENT_NAME, pp.CONCAT_NAME
GO