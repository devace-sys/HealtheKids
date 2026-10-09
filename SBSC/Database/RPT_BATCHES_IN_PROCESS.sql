USE [spedmon]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_BATCHES_IN_PROCESS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[RPT_BATCHES_IN_PROCESS]
GO

USE [spedmon]
GO



CREATE FUNCTION [dbo].[RPT_BATCHES_IN_PROCESS]
(
 /* RPT_BATCHES_IN_PROCESS */
  @cliID               BIGINT
, @consultantID        BIGINT
, @lastAssignedID      BIGINT
, @currentStatus        INT
 
)

RETURNS @ReturnTable TABLE(
    "client name" varchar(MAX),
    "client id" bigint,
	"Batch ID" bigint,
	"Section" char(20),
	"Current Status Code" integer,
	"Current Status Description" varchar(MAX),
	"Date Received" date,
	"Oldest DOS" date,
	"File Name" varchar(MAX),
    "Type of Work" varchar(MAX),
	"Last Assigned to" varchar(MAX),
	"Status Date" date,
	"Practi-Cal Consultant" varchar(MAX)
)
AS BEGIN

--*************To get today
DECLARE @Today DATE
	Set @Today = GETDATE()
--*************To get A YEAR before today
DECLARE @YearAgoToday DATE
	Set @YearAgoToday = DATEADD(year,-1, GETDATE())
--*************To get "Week Start Date" (Sunday) for THIS week
DECLARE @LastSunday DATE
	Set @LastSunday = DATEADD(wk,DATEDIFF(wk,7,GETDATE()),6)
--*************To get "Week Start Date" (Sunday) for NEXT week
DECLARE @NextSunday DATE
	Set @NextSunday = DATEADD(wk,DATEDIFF(wk,0,GETDATE()),6)
--*************To get 320 days before today for thing like a list of batches for priority input
DECLARE @AgingDate DATE
	Set @AgingDate = DATEADD(day,-320, GETDATE())
--*************To get a month after today
DECLARE @YearAgoTodayPLUS1Mo DATE
	Set @YearAgoTodayPLUS1Mo = DATEADD(month,1, @YearAgoToday)
--*************To get the last day of NEXT month LAST year
DECLARE @AgeOutCheck DATE
	Set @AgeOutCheck = DATEADD(mm, DATEDIFF(mm, 0, @YearAgoTodayPLUS1Mo)+1, -1)
--*************To get the first day of THIS month LAST year
DECLARE @FirstDayThisMoLastYear DATE
	Set @FirstDayThisMoLastYear = DATEADD(month, DATEDIFF(month, 0, @YearAgoToday), 0) --AS StartOfMonth
--*************To get the most recent past January 1
DECLARE @Year VARCHAR (10)
DECLARE @LatestJanuary DATE
	SET @Year=(DATEPART (YYYY, GETDATE()))
	SET @LatestJanuary = ('01/01/'+@Year)
--*************To get the January 1 two years before the most recent past January 1
DECLARE @TriennialJanuary DATE
	Set @TriennialJanuary = DATEADD(year,-2, @LatestJanuary)
--*************To get the most recent past July 1
DECLARE @LatestJuly DATE
	Set @LatestJuly = 
			CASE 
				WHEN @Today >= ('07/01/' + @Year)
				THEN ('07/01/' + @Year)
				ELSE DATEADD (Year,-1,('07/01/' + @Year))
				END
--*************To get the July 1 one year before the most recent past July 1
DECLARE @LastFYJuly DATE
	Set @LastFYJuly = DATEADD(year,-1, @LatestJuly)
--*************To get the January 1 two years before the most recent past July 1
DECLARE @TriennialJuly DATE
	Set @TriennialJuly = DATEADD(year,-2, @LatestJuly)

--*************************************************************************************************************
--3 - This section LISTS all the batches CURRENTLY IN PROCESS
--*************************************************************************************************************
INSERT @ReturnTable
SELECT DISTINCT
    cc.CLIENT_NAME,
    cc.CLIENT_ID as '[client id]',
	 ib.id																			as '[Batch ID]'
	,'3 - List in Process'															as '[Section]'
	,convert(integer, ib.Current_status_Code)										as '[Current Status Code]'
	,ibs.Status																		as '[Current Status Description]'
	,convert(date,ib.Date_Recieved)													as '[Date Received]'
	,Oldest_DOS																		as '[Oldest DOS]'
	,ib.File_Name																	as '[File Name]'
    ,wt.WorkType																	as '[Type of Work]'
	--,ib.Estimated_Input_Hours														as 'Hours'
	,isnull(um.FirstName + ' ' + um.LastName, '')									as '[Last Assigned to]'
  	,convert(date,ib.Current_Status_Date)	as '[Status Date]' --,iba.FROM_STATUS		as 'From'
	,cr.first_name + ' ' + cr.last_name												as '[Practi-Cal Consultant]'
	
FROM dbo.INPUT_BATCHES as ib
	join dbo.Input_Batches_Status			as ibs		on ibs.Status_Code = ib.Current_status_Code
	                                                       AND (@currentStatus IS NULL OR @currentStatus = ibs.Status_Code)
	join CLIENTS_Client						as cc		on cc.CLIENT_ID = ib.ClientID
	                                                       AND (@cliID IS NULL OR @cliID = cc.CLIENT_ID)
	join dbo.TYPE_OF_WORK					as wt		on wt.id = ib.Type_Of_Work
	left outer join users.dbo.users			as uu		on uu.userrid = ib.Current_status_UserID2 AND (@lastAssignedID IS NULL OR @lastAssignedID = uu.userrid)
	left outer join users.dbo.Membership	as um		on um.UserId = uu.userid
	join dbo.CLIENTS_Client_Reps			as cr		on cr.id = cc.ClientRepIDLEACurrent AND (@consultantID IS NULL OR @consultantID = cr.id)
	
WHERE 
    Current_status_Code in (10,30,50,60,70,80,85,90,100,110,130,250)		--Batches currently in Process
	--AND cc.CLIENT_ID = 38
	AND (@lastAssignedID IS NULL OR @lastAssignedID = uu.userrid)
	
	
ORDER BY  convert(integer, ib.Current_status_Code), convert(date,ib.Date_Recieved), ib.File_Name
RETURN
END

GO

GRANT SELECT ON [dbo].[RPT_BATCHES_IN_PROCESS] to [webuser]
GO