GO
USE SPEDMON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @today DATETIME, @oldestDOS datetime, @clientID bigint, @clientidarg varchar(30)
	SET @clientidarg = NULL
	
	SET @clientID =
		CASE WHEN @clientidarg = '' THEN NULL
		ELSE CAST(@clientidarg AS bigint)
		END

IF @today IS NULL SET @today = GETDATE()
	--SET @today     = dbo.DATE_ONLY(@today)
	SET @today     = DATEADD(dd, 0, DATEDIFF(dd, 0, @today))
	--SET @oldestDOS = dbo.CALC_OLDEST_DOS_ALLOWED(@today)
	SET @oldestDOS = DATEADD(day, (-1*(DAY(@today)-1)), DATEADD(year,-1, @today))
	
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

--***************SECTION FIVE - List of RECURRING SERVICES Records
SELECT  
	   '2-Who has Recurring Service Records'	AS 'Section'
      ,ccr.first_name +' ' +ccr.last_name		AS 'Consultant'
	  ,uu.UserName								AS 'Created by'
      ,CONVERT(VARCHAR(10),rs.created,101)		AS 'Date Created'
      ,cc.CLIENT_NAME							AS 'Client'
      ,fy.FY_DEFINITION							AS 'School Year'
      ,prac.CONCAT_NAME							AS 'Practitioner'
      ,pp.CONCAT_NAME							AS 'Patient'
      ,rs.startDate								AS 'Start Date'
      ,rs.endDate								AS 'End Date'
      ,rs.notes									AS 'Notes'
      
FROM [SPEDMON].[dbo].[RECURRING_SERVICES]								AS rs
	JOIN dbo.PATIENTS_Patient											AS pp		ON pp.PATIENT_ID = rs.patID
	JOIN dbo.RECURRING_SERVICES_DETAILS_SVC_SCHEDULE_OR_MINUTE_BASED	AS rssm		ON rssm.rcrSvcID = rs.id
	JOIN dbo.PRACTITIONER_Practitioner									AS prac		ON prac.PRACTITIONER_ID = rssm.pracID
	JOIN users.dbo.Users												AS uu		ON uu.userrid = rs.createdBy
	JOIN dbo.COMPANY_FISCAL_YEARS										AS fy		ON fy.ID = rs.fiscalYearID
	JOIN dbo.CLIENTS_Client												AS cc		ON cc.CLIENT_ID = rs.clientID
	JOIN dbo.CLIENTS_Client_Reps										AS ccr		ON ccr.id = cc.ClientRepIDLEACurrent
  
WHERE 1=1	
	AND rs.endDate > @FirstDayThisMoLastYear
	AND rs.active = 1
	
ORDER BY (ccr.first_name +' ' +ccr.last_name), cc.CLIENT_NAME, prac.CONCAT_NAME, pp.CONCAT_NAME, rs.startDate
GO