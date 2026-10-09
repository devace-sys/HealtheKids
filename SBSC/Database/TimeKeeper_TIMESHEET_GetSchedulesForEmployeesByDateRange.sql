USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRange]    Script Date: 1/25/2020 9:09:32 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRange]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRange]    Script Date: 1/25/2020 9:09:32 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRange]
(
	@startDate DATETIME
	,@endDate DATETIME
	,@employeeId BIGINT
)
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRange] @startDate, @endDate, @employeeId

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRange]    TO [webuser]
GO


