USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoSchedulerTimeEntryDay]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetAutoSchedulerTimeEntryDay]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoSchedulerTimeEntryDay]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetAutoSchedulerTimeEntryDay]
	@EmployeeID BIGINT
	,@dateForTimeEntry DATE
AS    
BEGIN    
SET NOCOUNT ON;
	
select 
	*
from 
	TimeEntry_Day
where
	employeeID = @EmployeeID
	AND dateForTimeEntry = @dateForTimeEntry

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetAutoSchedulerTimeEntryDay]  TO [webuser]
GO


