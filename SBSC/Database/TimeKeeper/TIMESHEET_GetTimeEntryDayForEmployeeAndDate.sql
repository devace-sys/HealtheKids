USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetTimeEntryDayForEmployeeAndDate]    Script Date: 1/25/2020 7:15:28 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetTimeEntryDayForEmployeeAndDate]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetTimeEntryDayForEmployeeAndDate]    Script Date: 1/25/2020 7:15:28 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetTimeEntryDayForEmployeeAndDate]
  @EmployeeId                BIGINT,
  @StartDate                 DATETIME
AS    
BEGIN    
SET NOCOUNT ON;
	  
	SELECT 
		id
		,employeeID  
		,dateForTimeEntry
	FROM 
		[TimeKeeper].[dbo].[TimeEntry_Day]
	where 
		employeeID = @EmployeeId
		AND dateForTimeEntry = @StartDate
				     
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetTimeEntryDayForEmployeeAndDate] TO [webuser]
GO

