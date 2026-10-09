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
--Section FIVE - Lag in Receipt of Batches
--**********************************************************************************************************************
SELECT
	 '5-Lag in Receipt'						AS 'Section'
	,cc.CLIENT_NAME							AS 'Client Name'
	,cr.first_name + ' ' + cr.last_name		AS 'District Rep'
	,ib.File_Name							AS 'File Name'
	,convert(date,ib.Oldest_DOS)			AS 'Oldest DOS'
	,convert(date,ib.Date_Recieved)			AS 'Date Received'
	
	
FROM spedmon.dbo.INPUT_BATCHES			AS ib
JOIN spedmon.dbo.CLIENTS_Client			AS cc	ON cc.CLIENT_ID = ib.ClientID
JOIN spedmon.dbo.CLIENTS_Client_Reps	AS cr	ON cr.id = cc.ClientRepIDLEACurrent  

WHERE 1=1
	AND Date_Recieved >= @FirstDayThisMoLastYear

ORDER BY
	cc.CLIENT_NAME
	,convert(date,ib.Date_Recieved)
	,convert(date,ib.Oldest_DOS)
GO