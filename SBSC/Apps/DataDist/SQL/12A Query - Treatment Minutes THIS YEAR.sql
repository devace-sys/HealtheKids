GO
USE SPEDMON

--CHANGE THIS to select ALL PATIENTS IN ALL CLIENTS
--...replace the NULL with the Client ID to get just one
DECLARE @ClientID bigint, @ClientIDArg varchar(30)
	SET @ClientIDArg = %s
	
	SET @ClientID =
		CASE WHEN @Clientidarg = '' THEN NULL
		ELSE CAST(@ClientIDArg AS bigint)
		END

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
--*************To get the July 1 one year before the most recent past July 1
DECLARE @LastFYJuly DATE
	SET @LastFYJuly = DATEADD(year,-1, @LatestJuly)
--*************To get the July 1 two years before the most recent past July 1
DECLARE @TriennialJuly DATE
	SET @TriennialJuly = DATEADD(year,-2, @LatestJuly)
--*************To get the most recent past June 30
DECLARE @LastestJune30 DATE
	SET @LastestJune30 = DATEADD(day,-1, @LatestJuly)

--*************************************************************************************************************
-- This section only show what the "DECLARE" dates calculate to be and do NOT get copied into the workbook
--*************************************************************************************************************
--SELECT @LastestJune30
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
	--,@LatestJuly				as '@LatestJuly'
	--,@LastFYJuly				as 'July Before Latest'
--	,@TriennialJuly				as '@TriennialJuly'

SELECT
	  ccr.first_name + ' ' + ccr.last_name		AS 'Consultant'
	 ,cc.CLIENT_NAME							AS 'Client'
	 ,pat.CONCAT_NAME							AS 'Patient'
	 ,convert(date,pat.DATE_CREATED)			AS 'Patient Added to SpEdCare'
	 ,CASE
		WHEN sr.nameIDAliasID IS NOT NULL
		THEN alias.NAME
		ELSE iep.NAME
		END										AS 'Service Name'
	 ,prac.CONCAT_NAME							AS 'Practitioner'
	 ,@LatestJuly								AS 'From'
	 ,@Today									AS 'Through'
	 ,COUNT(sr.id)								AS '# Services'
	 ,SUM(sr.numMins)							AS '# Minutes'
	 
FROM dbo.SERVICE_RECORDS								AS sr
	JOIN dbo.PRACTITIONER_Practitioner					AS prac		ON prac.PRACTITIONER_ID = sr.pracID
	JOIN dbo.PATIENTS_Patient							AS pat		ON pat.PATIENT_ID = sr.patID
	JOIN dbo.CLIENTS_Client								AS cc		ON cc.CLIENT_ID = sr.clientID
	JOIN dbo.CLIENTS_Client_Reps						AS ccr		ON ccr.id = cc.ClientRepIDLEACurrent
	LEFT OUTER JOIN dbo.CLAIM_IEPandIFSPNames			AS iep		ON iep.IEP_IFSP_NAME_ID = sr.nameID
	LEFT OUTER JOIN dbo.CLAIM_IEPandIFSPNames_ALIAS		AS alias	ON alias.ID = sr.nameIDAliasID

WHERE	1=1
		AND sr.dos >= @LatestJuly
		AND (sr.clientID = @ClientID OR @ClientID IS NULL)
		AND iep.NAME NOT LIKE '%Ass%'
		AND iep.NAME NOT LIKE '%Target%'
		AND iep.NAME NOT LIKE '%Trans%'
		AND cc.LEA = 1
		AND cc.CLIENT_ID <> 112
		
GROUP BY (ccr.first_name + ' ' + ccr.last_name), cc.CLIENT_NAME
			, pat.CONCAT_NAME,prac.CONCAT_NAME,iep.NAME,pat.DATE_CREATED,
			CASE
				WHEN sr.nameIDAliasID IS NOT NULL
				THEN alias.NAME
				ELSE iep.NAME
				END

ORDER BY (ccr.first_name +' ' +ccr.last_name), cc.CLIENT_NAME, pat.CONCAT_NAME, iep.NAME ,prac.CONCAT_NAME
GO
