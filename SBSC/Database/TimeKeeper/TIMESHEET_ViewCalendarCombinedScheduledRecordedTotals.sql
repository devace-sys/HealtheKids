USE [TimeKeeper]
GO

DROP FUNCTION if exists [dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTotals]
GO

CREATE FUNCTION [dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTotals] (@empid bigint, @startdate datetime, @enddate datetime)
returns table

AS    

return
  
(
   with recordedTotalsByDay as (	  
           select

              "date",
              "daynum" = DATEPART(weekday, "date"),
              SUM( "minutes" ) recordedMinutesTotal,
              "hoursMinutesRecordedTotal" = CONVERT(varchar(5), 
                  DATEADD(minute, SUM("minutes"), 0), 114)

             from
	            [dbo].[TIMESHEET_ViewCalendarRecordedTasks] (@empid, @startdate, @enddate)
              GROUP BY "date"
  ),

  scheduledTotalsByDay as (
           select --top 10000

             daynum,
             SUM( "numberOfminutes" ) scheduledMinutesTotal,
            "hoursMinutesScheduledTotal" = CONVERT(varchar(5), 
                  DATEADD(minute, SUM("numberOfminutes"), 0), 114)

             FROM [dbo].[TIMESHEET_ViewCalendarScheduledTasks] (@empid, @startdate, @enddate)
             GROUP BY daynum
  )

  SELECT
              "date",
              ISNULL(ri."daynum", si.daynum) "daynum",
              recordedMinutesTotal,
              "hoursMinutesRecordedTotal",
              scheduledMinutesTotal,
              "hoursMinutesScheduledTotal"
  FROM
    recordedTotalsByDay ri
    FULL OUTER JOIN scheduledTotalsByDay si
    ON ri.daynum = si.daynum

)

GO


grant select on TIMESHEET_ViewCalendarCombinedScheduledRecordedTotals to webuser
GO

