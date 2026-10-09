USE [SPEDMON]
GO


DROP FUNCTION if exists [dbo].[TimeKeeper_TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRpt]
GO

CREATE FUNCTION [dbo].[TimeKeeper_TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRpt] (@empid bigint, @dispdate datetime, @includeFormData bit)
returns table
AS    
return  
(

  SELECT * FROM [TimeKeeper].[dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRpt] (@empid, @dispdate, @includeFormData)

)
GO

grant select on [TimeKeeper_TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRpt] to webuser
GO