USE [TimeKeeper]
GO


/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRange]    Script Date: 1/26/2020 11:57:41 AM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRange]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRange]    Script Date: 1/26/2020 11:57:41 AM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRange]
(
	@startDate DATETIME
	,@endDate DATETIME
	,@employeeId BIGINT
)
AS    
BEGIN    
SET NOCOUNT ON;
	
	select
	  *
	from [dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF] (
	 @startDate
	,@endDate
	,@employeeId
        )
END


GO

GRANT EXECUTE ON [dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRange] TO [webuser] AS [dbo]
GO


