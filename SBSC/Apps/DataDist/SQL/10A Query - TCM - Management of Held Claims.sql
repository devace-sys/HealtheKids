GO
USE SPEDMON
/****** Script for SelectTopNRows command from SSMS  ******/
--*************************************************************************************************************
--This section defines (declares) certain dates in relation to the date this query is executed
--*************To get today
DECLARE @Today DATE
	SET @Today = GETDATE()
--*************To get A YEAR before today
DECLARE @YearAgoToday DATE
	SET @YearAgoToday = DATEADD(year,-1, GETDATE())
--*************To get "Week Start Date" (Sunday) for THIS week
DECLARE @LastSunday DATE
	SET @LastSunday = DATEADD(wk,DATEDIFF(wk,7,GETDATE()),6)
--*************To get "Week Start Date" (Sunday) for NEXT week
DECLARE @NextSunday DATE
	SET @NextSunday = DATEADD(wk,DATEDIFF(wk,0,GETDATE()),6)
--*************To get 320 days before today for thing like a list of batches for priority input
DECLARE @AgingDate DATE
	SET @AgingDate = DATEADD(day,-320, GETDATE())
--*************To get a month after today
DECLARE @YearAgoTodayPLUS1Mo DATE
	SET @YearAgoTodayPLUS1Mo = DATEADD(month,1, @YearAgoToday)
--*************To get the last day of NEXT month LAST year
DECLARE @AgeOutCheck DATE
	SET @AgeOutCheck = DATEADD(mm, DATEDIFF(mm, 0, @YearAgoTodayPLUS1Mo)+1, -1)
--*************To get the first day of THIS month LAST year
DECLARE @FirstDayThisMoLastYear DATE
	SET @FirstDayThisMoLastYear = DATEADD(month, DATEDIFF(month, 0, @YearAgoToday), 0) --AS StartOfMonth
--*************To get the most recent past January 1
DECLARE @Year VARCHAR (10)
DECLARE @LatestJanuary DATE
	SET @Year=(DATEPART (YYYY, GETDATE()))
	SET @LatestJanuary = ('01/01/'+@Year)
--*************To get the January 1 two years before the most recent past January 1
DECLARE @TriennialJanuary DATE
	SET @TriennialJanuary = DATEADD(year,-2, @LatestJanuary)
--*************To get the most recent past July 1
DECLARE @LatestJuly DATE
	SET @LatestJuly = 
			CASE 
				WHEN @Today >= ('07/01/' + @Year)
				THEN ('07/01/' + @Year)
				ELSE DATEADD (Year,-1,('07/01/' + @Year))
				END
--*************To get the January 1 two years before the most recent past July 1
DECLARE @TriennialJuly DATE
	SET @TriennialJuly = DATEADD(year,-2, @LatestJuly)
--*************************************************************************************************************
-- This section only show what the "DECLARE" dates calculate to be and do NOT get copied into the workbook
--*************************************************************************************************************
--SELECT
--	 @Today						as '@Today'
--	,@YearAgoToday				as '@YearAgoToday'
--	,@LastSunday				as '@LastSunday'
--	,@NextSunday				as '@NextSunday'
--	,@AgingDate					as '@AgingDate'
--	,@YearAgoTodayPLUS1Mo		as '@YearAgoTodayPLUS1Mo'
--	,@AgeOutCheck				as '@AgeOutCheck'
--	,@FirstDayThisMoLastYear	as '@FirstDayThisMoLastYear'
--	,@Year						as '@Year'
--	,@LatestJanuary				as '@LatestJanuary'
--	,@TriennialJanuary			as '@TriennialJanuary'
--	,@LatestJuly				as '@LatestJuly'
--	,@TriennialJuly				as '@TriennialJuly'
--The query starts here********************************************************************************************
--This section lists all the TCM claims during the claiming period being held because the practitioners are marked "MAA"
SELECT 
	 cc.CLIENT_NAME							AS ' Client'
	,pp.CONCAT_NAME							AS 'Practitioner'
	,gg.GROUP_NAME							AS 'Group Name'
	,convert(date,clm.SERVICE_DATE)			AS 'Service Date'
	,clm.SERVICE_UNITS						AS 'Service Units'

FROM [SPEDMON].[dbo].[CLAIM_Claim]			AS clm
	JOIN dbo.CLAIM_Procedures				AS cp	ON cp.PROCEDURE_ID = clm.PROCEDURE_ID
	JOIN dbo.CLIENTS_Client					AS cc	ON cc.CLIENT_ID = clm.CLIENT_ID
	JOIN dbo.PRACTITIONER_Practitioner		AS pp	ON pp.PRACTITIONER_ID = clm.PRACTITIONER_ID
	JOIN dbo.PRACTITIONER_GROUPS			AS pg	ON pg.PRACTITIONER_ID = clm.PRACTITIONER_ID
	JOIN dbo.GROUP_Group					AS gg	ON gg.GROUP_ID = pg.GROUP_ID
	
WHERE 1=1
	--and clm.CLIENT_ID = 1
	AND PROCEDURE_CODE = 'QT1017'
	AND gg.GROUP_TYPE IN (1, 2)
	AND clm.SERVICE_DATE >= @FirstDayThisMoLastYear
	
ORDER BY cc.CLIENT_NAME, pp.CONCAT_NAME, clm.SERVICE_DATE
GO