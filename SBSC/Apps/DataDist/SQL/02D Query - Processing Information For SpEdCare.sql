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
--Section FOUR - Batches Received by Date
--**********************************************************************************************************************
SELECT
	 '4-Batches Received by Date'			AS 'Section'
	,DATENAME (month, Date_Recieved)		AS 'Month'
	,DATENAME (year, Date_Recieved)			AS 'Year'
	,DATENAME ( weekday , Date_Recieved)	AS 'Day'
	,convert(date,Date_Recieved)			AS 'Date Received'
	,Count(id)								AS '# of Batches'

FROM spedmon.dbo.INPUT_BATCHES

WHERE 1=1
	AND convert(date,Date_Recieved) >= @FirstDayThisMoLastYear
	AND Partial_File <> 1

GROUP BY convert(date,Date_Recieved), DATENAME ( weekday , Date_Recieved), DATENAME (month, Date_Recieved), DATENAME (year, Date_Recieved)

ORDER BY convert(date,Date_Recieved)
GO