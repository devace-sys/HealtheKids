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
--Section ONE - Not Billable
--**********************************************************************************************************************
SELECT 
	'1-Not Billable'								AS 'Section'
	,cr.first_name + ' ' + cr.last_name				AS 'District Rep'
    ,cc.CLIENT_NAME									AS 'Client Name'
	,cc.OwnedByCompanyID_LEA						AS 'Company'
    ,ib.File_Name									AS 'File Name'
    ,wt.WorkType									AS 'Type of Work'
    ,convert(date,ib.Current_Status_Date)			AS 'Date Returned'

FROM SPEDMON.dbo.INPUT_BATCHES						AS ib
	JOIN spedmon.dbo.Input_Batches_Status			AS ibs		ON ibs.Status_Code = ib.Current_status_Code
	JOIN spedmon.dbo.CLIENTS_Client					AS cc		ON cc.CLIENT_ID = ib.ClientID
	JOIN spedmon.dbo.TYPE_OF_WORK					AS wt		ON wt.id = ib.Type_Of_Work
	LEFT OUTER JOIN users.dbo.users					AS uu		ON uu.userrid = ib.Current_status_UserID2
	LEFT OUTER JOIN users.dbo.Membership			AS um		ON um.UserId = uu.userid
	JOIN spedmon.dbo.CLIENTS_Client_Reps			AS cr		ON cr.id = cc.ClientRepIDLEACurrent  

WHERE 1=1
	AND ib.Date_Recieved > @StartDate
	AND ib.Current_status_Code = 310		--Not Billable
	AND cc.LEA = 1
	
ORDER BY ib.Date_Recieved, cc.CLIENT_NAME, ib.File_Name, convert(date,ib.Current_Status_Date)
GO