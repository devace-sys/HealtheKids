USE [TimeKeeper]
GO

DROP FUNCTION if exists [dbo].[TIMESHEET_ViewCalendarScheduledTasks]
GO

CREATE FUNCTION [dbo].[TIMESHEET_ViewCalendarScheduledTasks] (@empid bigint, @startdate datetime, @enddate datetime)
returns table
AS    
return
 
(
	  
  SELECT

    TE_T.id,

    TE_T."name" "taskName",
    APTD.dayid + 1 daynum,
    APT_SST.starttime,  --starttime = CONVERT(varchar(5), 
    APT_SST.stoptime,  --stoptime = CONVERT(varchar(5), 
    CASE WHEN APT_SST.starttime IS NOT NULL AND APT_SST.stoptime IS NOT NULL THEN DATEDIFF(minute, APT_SST.starttime, APT_SST.stoptime) ELSE numberOfMinutes END numberOfMinutes

  from 
	Employee_TimeEntry_Tasks_Favorites ETTF
	JOIN TimeEntry_Tasks TE_T
		ON TE_T.id = ETTF.taskID
  JOIN Employees E
    ON E.id = ETTF.EmployeeID
  JOIN People P
    ON P.id = E.personID

  JOIN [dbo].[AutoPopulateTaskTemplate] APTT
    ON APTT."name" = ( P.lastName + ', ' + P.firstName + '(' + CAST (E.id as varchar) + ')' )

  JOIN [dbo].[AutoPopulateTaskDetails] APT_Det
   ON APT_Det.timeentrytaskid = TE_T.id

   AND APT_Det.[autoPopulateTaskTemplateId] = APTT.id

  JOIN [dbo].[AutoPopulateTaskDays] APTD
  ON APTD.autoPopulateTaskDetailsId = APT_Det.id

  LEFT JOIN [dbo].[AutoPopulateTaskDaysStartStopTime] APT_SST
  ON APTD.id = APT_SST.[autoPopulateTaskDaysId]

            WHERE ( 
              ETTF.EmployeeID = @empid AND
              ( APTD.dayid + 1
               ) >= DATEPART(WEEKDAY, @startdate)
               AND
               ( APTD.dayid + 1 <= DATEPART(WEEKDAY, @enddate) )

            )

)

GO

grant select on TIMESHEET_ViewCalendarScheduledTasks to webuser
GO

