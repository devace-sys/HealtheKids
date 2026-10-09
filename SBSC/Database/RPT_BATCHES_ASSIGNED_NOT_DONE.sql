USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_BATCHES_ASSIGNED_NOT_DONE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_BATCHES_ASSIGNED_NOT_DONE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

 CREATE FUNCTION [dbo].[RPT_BATCHES_ASSIGNED_NOT_DONE]
(
   @consultantID	   BIGINT
 , @lastAssignedID     BIGINT   )
 RETURNS @ReturnTable TABLE
 (
    "id" INT
	,"Section" CHAR(26)
	,"Last Assigned to" VARCHAR(100)
	,"Current Status Code" INT
	,"Current Status Description" VARCHAR(100)
  	,"Status Date" DATE
	,"Date Received" DATE
	,"Oldest DOS" DATE
	,"File Name" VARCHAR(100)
    ,"Type of Work" VARCHAR(100)
	,"Practi-Cal Consultant" VARCHAR(100)
 )
 AS BEGIN
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
--4 - This section LISTS all the batches Assigned but NOT DoneYet
--*************************************************************************************************************
INSERT @ReturnTable SELECT DISTINCT
	 ib.id
	,'4 - Assigned Work NOT Done'													as 'Section'
	,um.FirstName + ' ' + um.LastName								            	as 'Last Assigned to' 
	,convert(integer, ib.Current_status_Code)										as 'Current Status Code'
	,ibs.Status																		as 'Current Status Description'
  	,convert(date,ib.Current_Status_Date)											as 'Status Date'
	,convert(date,ib.Date_Recieved)													as 'Date Received'
	,convert(date,Oldest_DOS)														as 'Oldest DOS'
	,ib.File_Name																	as 'File Name'
    ,wt.WorkType																	as 'Type of Work'
    --,ib.Estimated_Input_Hours														as 'Hours'
	--,isnull(um1.FirstName + ' ' + um1.LastName, '')									as 'Other Name'
	,cr.first_name + ' ' + cr.last_name												as 'Practi-Cal Consultant'

FROM dbo.INPUT_BATCHES						as ib
	join dbo.Input_Batches_Status			as ibs		on ibs.Status_Code = ib.Current_status_Code
	join CLIENTS_Client						as cc		on cc.CLIENT_ID = ib.ClientID
	join dbo.TYPE_OF_WORK					as wt		on wt.id = ib.Type_Of_Work
	left outer join users.dbo.users			as uu		on uu.userrid = ib.Current_status_UserID2 AND (@lastAssignedID IS NULL OR @lastAssignedID = uu.userrid)
	left outer join users.dbo.users			as uu1		on uu1.userrid = ib.Current_status_UserID1
	left outer join users.dbo.Membership	as um		on um.UserId = uu.userid 
	left outer join users.dbo.Membership	as um1		on um1.UserId = uu1.userid
	join dbo.CLIENTS_Client_Reps			as cr		on cr.id = cc.ClientRepIDLEACurrent AND (@consultantID IS NULL OR @consultantID = cr.id)

WHERE
 Current_status_Code in (60,70,130,80,85,100,110,130)
 AND (@lastAssignedID IS NULL OR @lastAssignedID = uu.userrid) /* because we used an outer join rather than an inner join,
                                                                  we must use a where-clause as well, to completely remove the row from the results.
                                                                  The WHERE happens last; restricting the join helps improve performance.
                                                                  That is why we are using the filter params both places. */ 
 AND (@consultantID IS NULL OR @consultantID = cr.id)
 

ORDER BY [Last Assigned to], convert(date,ib.Current_Status_Date)

RETURN

END

GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  [dbo].[RPT_BATCHES_ASSIGNED_NOT_DONE] TO [webuser]
GO