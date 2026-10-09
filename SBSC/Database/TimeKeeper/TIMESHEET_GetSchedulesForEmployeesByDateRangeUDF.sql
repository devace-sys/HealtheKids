USE [TimeKeeper]
GO

DROP FUNCTION if exists [dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF]
GO

CREATE FUNCTION [dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF]
(
	@startDate DATETIME
	,@endDate DATETIME
	,@employeeId BIGINT
)
RETURNS TABLE AS
RETURN
  SELECT top 100000
    *,
    "numHoursInterval" = CAST("numMinutesInterval" AS DECIMAL(6,2)) / 60
  FROM
(
	select
	    S.id as 'ScheduleId'
	    ,SSS.id as 'ScheduleStartAndStopTimeId'
	    ,E.id as 'EmployeeId'
		,S.dateOfSchedule
	    ,SSS.starttime
	    ,SSS.stoptime
      , "numMinutesInterval" = DATEDIFF(minute, SSS.starttime, SSS.stoptime)

	 from
	    [TimeKeeper].[dbo].[Schedule] S
	    INNER JOIN[TimeKeeper].[dbo].[ScheduleStartAndStopTime] SSS
	        ON SSS.scheduleid = S.id
	    INNER JOIN[TimeKeeper].[dbo].[Employees] E
	        ON E.id = S.employeeID

	where 
	    S.dateOfSchedule >= @startDate AND CAST(S.dateOfSchedule as DATE) <= CAST(@endDate AS date)
		AND E.id = @employeeId
) s1
	ORDER BY
		S1.dateOfSchedule

GO

GRANT SELECT ON [dbo].[TIMESHEET_GetSchedulesForEmployeesByDateRangeUDF] TO [webuser]
GO


