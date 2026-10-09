GO
--Query - Processing Information For A&I
USE USERS

DECLARE @StartDate DATE
	SET @StartDate = DATEADD(year,-1, GETDATE())			--This is a YEAR before the date this query runs
DECLARE @LastSunday DATE									--This is the "Week Start Date" for THIS week
	SET @LastSunday = DATEADD(wk,DATEDIFF(wk,7,GETDATE()),6)
DECLARE @NextSunday DATE									--This is the "Week Start Date" for NEXT week
	SET @NextSunday = DATEADD(wk,DATEDIFF(wk,0,GETDATE()),6)
DECLARE @AgingDate DATE
	SET @AgingDate = DATEADD(day,-320, GETDATE())
DECLARE @StartDatePLUS1Mo DATE
	SET @StartDatePLUS1Mo = DATEADD(month,1, @StartDate)
DECLARE @AgeOutCheck DATE
	SET @AgeOutCheck = DATEADD(mm, DATEDIFF(mm, 0, @StartDatePLUS1Mo)+1, -1)
DECLARE @FirstDayThisMoLastYear DATE													--First day of THIS month LAST year
	SET @FirstDayThisMoLastYear = DATEADD(month, DATEDIFF(month, 0, @StartDate), 0)		--AS StartOfMonth
	
--**********************************************************************************************************************
--Section SIX - Counts the number of service records for each practitioner since this month last year	
--**********************************************************************************************************************
SELECT
	'6-Practitioners'								AS 'Section' 
	 ,cc.CLIENT_NAME								AS 'Client Name'
	,cr.first_name + ' ' + cr.last_name				AS 'District Rep'
	,pp.CONCAT_NAME									AS 'Practitioner Name'
	,isnull(COUNT(sr.id),0)							AS 'Service Records Since This Month LAST Year'

FROM [SPEDMON].[dbo].[PRACTITIONER_Practitioner]				AS pp
  JOIN spedmon.dbo.PRACTITIONER_Client							AS pc	ON pc.PRACTITIONER_ID = pp.PRACTITIONER_ID
  JOIN spedmon.dbo.CLIENTS_Client								AS cc	ON cc.CLIENT_ID = pc.CLIENT_ID
  LEFT OUTER JOIN spedmon.dbo.SERVICE_RECORDS					AS sr	ON sr.pracID = pp.PRACTITIONER_ID
																	AND sr.dos >= @FirstDayThisMoLastYear 
																	AND sr.clientID = cc.CLIENT_ID
JOIN spedmon.dbo.CLIENTS_Client_Reps							AS cr	ON cr.id = cc.ClientRepIDLEACurrent  

WHERE 1=1
	AND cc.LEA = 1
	AND pp.ACTIVE = 1
	AND cc.CLIENT_ID <> 112

GROUP BY 
	cc.CLIENT_NAME
	,pp.practitioner_id
	,pp.CONCAT_NAME
	,cr.first_name + ' ' + cr.last_name

ORDER BY 
	cc.CLIENT_NAME
	,pp.CONCAT_NAME
GO