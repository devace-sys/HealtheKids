USE [spedmon]
GO

DROP FUNCTION if exists [dbo].[TimeKeeper_TIMESHEET_ViewCalendarScheduleableTasks]
GO

CREATE FUNCTION [dbo].[TimeKeeper_TIMESHEET_ViewCalendarScheduleableTasks] (@empid bigint, @startdate datetime, @enddate datetime)
returns table
AS    
return
  
(
	  
  SELECT
    *
  FROM [TimeKeeper].[dbo].[TIMESHEET_ViewCalendarScheduleableTasks] (@empid, @startdate, @enddate) sched
  
)

GO

grant select on TimeKeeper_TIMESHEET_ViewCalendarScheduleableTasks to webuser
GO

