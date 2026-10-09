USE [TimeKeeper]
GO


DROP FUNCTION if exists [dbo].[TIMESHEET_ViewCalendarRecordedTasks]
GO

CREATE FUNCTION [dbo].[TIMESHEET_ViewCalendarRecordedTasks] (@empid bigint, @startdate datetime, @enddate datetime)
returns table

AS
    
return
  
(	  
            select --top 10000
	            TE.id,
              COALESCE(
                convert(varchar, TE.StartEntryDateTime, 126),
                convert(varchar, TE_D.[dateForTimeEntry], 23)
               ) "start",
              convert(varchar, TE.EndEntryDateTime, 126) "end",
              TE.note,
              TE_T.name "taskName",
              O.name "organizationName",
              taskID_orgID = ISNULL(
                CAST(TE_T.id as varchar) + '_' + CAST(O.id as varchar),
                CAST(TE_T.id as varchar)
              ),
              taskID = TE_T.id,
              title = COALESCE(TE_T.name + ' - ' + O.name, TE_T.name),
              allDay =  CASE WHEN TE.StartEntryDateTime IS NULL THEN CAST( 1 AS BIT) ELSE CAST( 0 AS BIT) END,


              "minutes" = numberMinutes,
              "hoursMinutes" = CONVERT(varchar(5), 
                  DATEADD(minute, numberMinutes, 0), 114),
              "date" = CAST( TE_D.[dateForTimeEntry] AS date),

              TE_T."SpecifyStartStopTime",

              TE_D.id "ted_id"

            from
	            
	            [dbo].[TimeEntry_Day] TE_D
                    left join [dbo].[TimeEntries] TE
		            ON TE.timeEntryDayID = TE_D.id
              left join Organizations O
                ON TE.orgClientID = O.id
	            inner join [dbo].[TimeEntry_Tasks] TE_T
		            ON TE.timeEntrytaskID = TE_T.id

            WHERE ( 
              TE_D.employeeID = @empid AND
              ( COALESCE(
                TE_D.[dateForTimeEntry], TE.StartEntryDateTime
                 )
               ) >= @startdate
               AND
               (dateForTimeEntry <= @enddate)

            )

            --ORDER BY id DESC

)

GO

grant select on TIMESHEET_ViewCalendarRecordedTasks to webuser
GO

