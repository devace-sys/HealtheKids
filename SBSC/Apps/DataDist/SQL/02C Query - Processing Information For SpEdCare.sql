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
--Section THREE - Questions Not Yet Answered
--**********************************************************************************************************************
SELECT 
	'3-Q no A'								AS 'Section'
	,rep.first_name +' ' +rep.last_name		AS 'District Rep' 
	,cc.CLIENT_NAME							AS 'Client Name'
	,ib.File_Name							AS 'File name'
	,tow.WorkType							AS 'Type of Work'
	,convert(VARCHAR(10),ib.Oldest_DOS,101)	AS 'Oldest DOS'
	,convert(VARCHAR(10),ur.CreatedOn,101)	AS 'Date Returned'
	,ur.Email_To							AS 'Sent to'
	,isnull(ur.Email_CC,'')					AS 'CC email to'
	,udr.Question							AS 'Question Asked'
	
FROM users.dbo.INFO_REQUEST_RESPONSE_DETAILS		AS udr
JOIN users.dbo.INFO_REQUEST_RESPONSE				AS ur		ON ur.id = udr.InfoRequestResponseID
LEFT OUTER JOIN SPEDMON.dbo.INPUT_BATCHES			AS ib		ON ur.ReferenceID = ib.id
JOIN SPEDMON.dbo.TYPE_OF_WORK						AS tow		ON tow.id = ib.Type_Of_Work
JOIN SPEDMON.dbo.CLIENTS_Client						AS cc		ON cc.CLIENT_ID = ur.ClientID
JOIN SPEDMON.dbo.CLIENTS_Client_Reps				AS rep		ON rep.id = cc.ClientRepIDLEACurrent

WHERE 1=1
	AND udr.Answer IS NULL
	AND ur.CreatedOn >= @StartDate
	--and ib.id is null
	AND ib.Current_status_Code IN (290, 300)
	
ORDER BY [District Rep], [Client Name], [Date Returned], [File name]
GO