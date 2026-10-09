USE [SPEDMON]
GO

DROP FUNCTION if exists [dbo].[TimeKeeper_TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRptWeekGlance]
GO

CREATE FUNCTION [dbo].[TimeKeeper_TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRptWeekGlance] (@empid bigint, @dispdate datetime, @includeFormData bit)

returns table

AS    
return  
(
  SELECT * FROM [TimeKeeper].[dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRptWeekGlance] (@empid, @dispdate, @includeFormData)
)
GO

grant select on TimeKeeper_TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRptWeekGlance to webuser
go