USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetTimeEntriesForEmployeeAndDate]    Script Date: 1/25/2020 7:16:24 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetTimeEntriesForEmployeeAndDate]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetTimeEntriesForEmployeeAndDate]    Script Date: 1/25/2020 7:16:24 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetTimeEntriesForEmployeeAndDate]
  @EmployeeId                BIGINT,
  @StartDate                 DATETIME
AS    
BEGIN    
SET NOCOUNT ON;
	  
	SELECT 
		TE.id
		,TE.timeEntryDayID
		,TE.timeOfTask
		,TE.numberMinutes
		,TE.timeEntrytaskID
		,TE.orgClientID
		,TE.note
		,TET.name AS task
		,O.name AS client
	FROM 
		[TimeKeeper].[dbo].[TimeEntry_Day] TED
		INNER JOIN [TimeKeeper].[dbo].[TimeEntries] TE
			ON TE.timeEntryDayID = TED.id
		LEFT JOIN [TimeKeeper].[dbo].[TimeEntry_Tasks] TET
			ON TET.id = TE.timeEntrytaskID
		LEFT JOIN [TimeKeeper].[dbo].[Organizations] O
			ON O.id = TE.orgClientID
	where 
		TED.employeeID = @EmployeeId
		AND      
               /* Date */
              --(
                --(  CAST(timeOfTask as date) = @startDate )
                --OR
                ( TED.dateForTimeEntry = @startDate )
              --)
				     
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetTimeEntriesForEmployeeAndDate]  TO [webuser]
GO


