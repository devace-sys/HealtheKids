USE [TimeKeeper]
GO

DROP FUNCTION if exists [dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTasks]
GO

CREATE FUNCTION [dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTasks] (@empid bigint, @startdate datetime, @enddate datetime)
returns table
AS    
return
  
(
   with taskID_recordedInfoAll as (	  

           select --top 10000
	            --id,
              taskID,
              "date",
              "daynum" = DATEPART(weekday, "date"),
              STRING_ESCAPE( taskName, 'json') "taskName",
              --STRING_ESCAPE( "title", 'json') "taskName",

              SUM( "minutes" ) recordedMinutesTotal,
              "hoursMinutesRecordedTotal" = CONVERT(varchar(5), 
                  DATEADD(minute, SUM("minutes"), 0), 114),
              taskRecordedInfo = '[' +
              STRING_AGG(
          '{'   + '"start": "' + ISNULL( "start", '') + '",' +
                + '"end": "' + ISNULL( "end", '')  + '",' +
                + '"note": "' + STRING_ESCAPE( ISNULL( note , '') , 'json') + '",' +
                + '"taskName": "' + STRING_ESCAPE( ISNULL( "taskName" , '') , 'json') + '",' +
                + '"organizationName": "' + STRING_ESCAPE( ISNULL( "organizationName" , '') , 'json') + '",' +
                + '"taskID_orgID": "' + ISNULL( taskID_orgID , '') + '",' +
                + '"te_id": ' + CAST( id as varchar ) + ',' +

                + '"recordedTaskTitle": "' + STRING_ESCAPE( ISNULL(  title , '') , 'json') + '",' +

                + '"allDay": "' + ISNULL( CAST( allDay as VARCHAR), '0')  + '",' +
                + '"minutes": "' + ISNULL( cast( "minutes" as varchar) , '') + '",' +
                + '"hourMinutes": "' + ISNULL( cast( "hoursMinutes" as varchar) , '') + '",' +
                + '"date": "' + ISNULL( cast( "date" as varchar) , '') + '"' +
          '}'
              ,
              ','
              ) + ']'

            from
	            [dbo].[TIMESHEET_ViewCalendarRecordedTasks] (@empid, @startdate, @enddate)
              WHERE "minutes" > 0
              GROUP BY taskID, taskName, "date" --, "title"
  ),

  /*
  taskID_recordedInfoForClient as (	  
           select --top 10000
	            --id,
              taskID,

              "date",
              "daynum" = DATEPART(weekday, "date"),
              STRING_ESCAPE( taskName, 'json') "taskName",
              STRING_ESCAPE( "title", 'json') "taskTitle",
              SUM( "minutes" ) recordedMinutesTotal,
              "hoursMinutesRecordedTotal" = CONVERT(varchar(5), 
                  DATEADD(minute, SUM("minutes"), 0), 114),
              taskRecordedInfo = '[' +
              STRING_AGG(
          '{'   + '"start": "' + ISNULL( "start", '') + '",' +
                + '"end": "' + ISNULL( "end", '')  + '",' +
                + '"note": "' + ISNULL( note , '') + '",' +
                + '"taskName": "' + ISNULL( "taskName" , '') + '",' +
                + '"organizationName": "' + ISNULL( "organizationName" , '') + '",' +
                + '"taskID_orgID": "' + ISNULL( taskID_orgID , '') + '",' +

                + '"te_id": ' + CAST( id as varchar ) + ',' +

                + '"title": "' + ISNULL( STRING_ESCAPE( title, 'json') , '') + '",' +

                + '"allDay": "' + ISNULL( CAST( allDay as VARCHAR), '0')  + '",' +
                + '"minutes": "' + ISNULL( cast( "minutes" as varchar) , '') + '",' +
                + '"hourMinutes": "' + ISNULL( cast( "hoursMinutes" as varchar) , '') + '",' +
                + '"date": "' + ISNULL( cast( "date" as varchar) , '') + '"' +
          '}'
              ,
              ','
              ) + ']'

            from
	            [dbo].[TIMESHEET_ViewCalendarRecordedTasks] (@empid, @startdate, @enddate)
              WHERE organizationName IS NOT NULL
              GROUP BY taskID, taskName, "title", "date"
  ),
  */
  taskID_scheduledInfoAll as (
           select --top 10000
             id taskID,
             taskName,
             daynum,
             SUM( "numberOfminutes" ) scheduledMinutesTotal,
             "hoursMinutesScheduledTotal" = CONVERT(varchar(5), 
                  DATEADD(minute, SUM("numberOfMinutes"), 0), 114),
             taskScheduledInfo = '[' +
               STRING_AGG(
          '{'   + '"starttime": "' + ISNULL( cast("starttime" as varchar), '') + '",' +
                + '"endtime": "' + ISNULL( cast( "stoptime" as varchar), '') + '",' +
                + '"numberOfMinutes": "' + ISNULL( cast("numberOfMinutes" as varchar), '') + '"' +
          '}'
             ,
             ','
             ) +
             ']'

             FROM [dbo].[TIMESHEET_ViewCalendarScheduledTasks] (@empid, @startdate, @enddate)
             GROUP BY id, taskName, daynum
  )
  SELECT top 100000 * FROM (
  SELECT
   taskID = COALESCE( ri.taskID, si.taskID),

   taskName = COALESCE( ri.taskName, si.taskName),
   null "recordedTaskTitle",  -- create this column for UNIONing
   ri.recordedMinutesTotal recordedMinutesTotal,
   hoursMinutesRecordedTotal,
   si.scheduledMinutesTotal scheduledMinutesTotal,
   hoursMinutesScheduledTotal,
   daynum = COALESCE( ri.daynum, si.daynum),
   dateRecorded = ri."date",
   taskRecordedInfo,
   isScheduled = CASE WHEN si.taskID IS NULL THEN 0 ELSE 1 END,
   isRecorded = CASE WHEN ri.taskID IS NULL THEN 0 ELSE 1 END,
   taskScheduledInfo
  FROM
    taskID_recordedInfoAll ri
    FULL OUTER JOIN taskID_scheduledInfoAll si
    ON ri.taskID = si.taskID AND ri.daynum = si.daynum

    /*
  UNION

  SELECT

   taskID = rc.taskID,

   taskName = rc.taskName,
   rc.taskTitle "recordedTaskTitle",
   rc.recordedMinutesTotal recordedMinutesTotal,
   hoursMinutesRecordedTotal,
   null scheduledMinutesTotal,
   null,
   rc.daynum,
   dateRecorded = rc."date",
   taskRecordedInfo,
   isScheduled = null,
   isRecorded = 1,
   null
  FROM
    taskID_recordedInfoForClient rc
*/
  ) s2

   where ISNULL(recordedMinutesTotal, 0) > 0 OR ISNULL(scheduledMinutesTotal, 0) > 0
   ORDER BY taskName, recordedMinutesTotal DESC, recordedTaskTitle

)

GO


grant select on TIMESHEET_ViewCalendarCombinedScheduledRecordedTasks to webuser
GO

