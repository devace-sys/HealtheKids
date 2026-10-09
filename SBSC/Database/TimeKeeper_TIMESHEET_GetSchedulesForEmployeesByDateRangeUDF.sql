USE [SPEDMON]
GO


DROP FUNCTION IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF]
GO

-- TODO: this UDF has been designed to replace the SPROC TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRange.
--       It has been tested and seems suitable; please test further and consider deleting/removing the SPROC.


CREATE FUNCTION [dbo].[TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF]
(
	@startDate DATETIME
	,@endDate DATETIME
	,@employeeId BIGINT
)
RETURNS TABLE AS RETURN

    SELECT * FROM [TimeKeeper].[dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF] (@startDate, @endDate, @employeeId)

GO

GRANT SELECT ON [dbo].[TimeKeeper_TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF] TO [webuser]
GO


