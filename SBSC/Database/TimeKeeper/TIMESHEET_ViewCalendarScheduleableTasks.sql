USE [TimeKeeper]
GO

DROP FUNCTION if exists [dbo].[TIMESHEET_ViewCalendarScheduleableTasks]
GO

CREATE FUNCTION [dbo].[TIMESHEET_ViewCalendarScheduleableTasks] (@empid bigint, @startdate datetime, @enddate datetime)
returns table
AS    
return
  
(
	  
  SELECT
    sched.*, CAST(id as varchar) + '_' + CAST(daynum as varchar) "tetid_daynum"
  FROM [dbo].[TIMESHEET_ViewCalendarScheduledTasks] (@empid, @startdate, @enddate) sched

  UNION

  SELECT
    list.*, null, null, null, null, null
  FROM [dbo].[ViewListOfTasks] (@empid) list
    WHERE id NOT IN (

  SELECT
    id
  FROM [dbo].[TIMESHEET_ViewCalendarScheduledTasks] (@empid, @startdate, @enddate) schedd

    )
  

)

GO

grant select on TIMESHEET_ViewCalendarScheduleableTasks to webuser
GO

