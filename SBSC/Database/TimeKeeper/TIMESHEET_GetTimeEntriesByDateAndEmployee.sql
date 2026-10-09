USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetTimeEntriesByDateAndEmployee]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetTimeEntriesByDateAndEmployee]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetTimeEntriesByDateAndEmployee]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetTimeEntriesByDateAndEmployee]
		@StartDate DateTime
		,@EndDate DateTime
		,@EmployeeId BIGINT 
AS    
BEGIN    
SET NOCOUNT ON;
	
SELECT
	TED.employeeID
	,TE.id AS 'timeEntryID'
	,TE.timeEntryDayID
	,TED.dateForTimeEntry
	,ISNULL(TET.name, '') AS 'TaskName'
	,ISNULL(TE.timeEntrytaskID, 0) AS 'timeEntrytaskID'
	,ISNULL(TET.CanHaveMultipleClients, 0) AS 'CanHaveMultipleClients'
	,ISNULL(TE.orgClientID, 0) AS 'orgClientID'
	,ISNULL(O.name, 'All Clients') AS 'OrganizationName'
	,TE.numberMinutes
	,ISNULL(TKH.Name, '') AS 'HolidayName'
	,ISNULL(TE.holidayTaskID, 0) AS 'holidayTaskID'
FROM
	TimeEntries TE
	INNER JOIN TimeEntry_Day TED
		ON TED.id = TE.timeEntryDayID
	LEFT JOIN TimeEntry_Tasks TET
		ON TET.id = TE.timeEntrytaskID
	LEFT JOIN TimeKeeperHolidays TKH
		ON TKH.ID = TE.holidayTaskID
	LEFT JOIN Organizations O
		ON O.id = TE.orgClientID
WHERE
	TE.timeEntryDayID IN
	(
		SELECT
			ID
		FROM
			TimeEntry_Day
		WHERE
			employeeID = @EmployeeID
			AND dateForTimeEntry >= @StartDate
			AND dateForTimeEntry < @EndDate
	)
ORDER BY
	TE.timeEntryDayID, TE.timeEntrytaskID


END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetTimeEntriesByDateAndEmployee]  TO [webuser]
GO


