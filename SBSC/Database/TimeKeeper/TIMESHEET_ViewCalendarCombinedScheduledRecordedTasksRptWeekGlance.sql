use timekeeper
go

DROP function if exists [dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRptWeekGlance]
GO

CREATE FUNCTION [dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRptWeekGlance] (@empid bigint, @dispdate datetime, @includeFormData bit)
returns table

AS 

return
(
  with criticaldates as (

    SELECT
      c_d.*--,
      --ted.id ted_id
      FROM
    (
    select
      @dispdate dispdate,
      "sunday" = DATEADD(
        day,
        ( 1 - ( DATEPART(WEEKDAY, @dispdate) ) ),
        @dispdate
      ),
      "saturday" = DATEADD(
        day,
        (7 - (DATEPART(WEEKDAY, @dispdate) )),
        @dispdate
      )
    ) c_d
    --LEFT JOIN
    --  [dbo].[TimeEntry_Day] ted ON ted.employeeID = @empid AND ted.dateForTimeEntry =  CAST( @dispdate as date)
  ),
  recorded_totals_by_day as (

    SELECT
      /* daynum = RANK() OVER(ORDER BY "date" ASC), */ "date", ISNULL(SUM("minutes"), 0) "minutesRecorded",
      daynum = DATEPART(weekday, "date"),
      "hoursMinutesRecorded" = CONVERT(varchar(5), 
                  DATEADD(minute, ISNULL(SUM("minutes"), 0), 0), 114)
    FROM
     criticaldates
     OUTER APPLY
     [dbo].[TIMESHEET_ViewCalendarRecordedTasks] ( @empid, criticaldates."sunday", criticaldates."saturday")
    GROUP BY "date"
  ),

  scheduled_and_recorded_totals_by_day as (

    SELECT
      v_rt.*, /* ISNULL(SUM(v_st."numberOfMinutes"), 0) "minutesScheduled",
      "hoursMinutesScheduled" = CONVERT(varchar(5), 
                  DATEADD(minute, ISNULL(SUM(v_st."numberOfMinutes"), 0), 0), 114) */
      v_st.*

    FROM
    criticaldates c_d
     OUTER APPLY
     recorded_totals_by_day v_rt
     OUTER APPLY
     (SELECT
      -- *,
      SUM(v_st."numberOfMinutes") "minutesScheduled",
      "hoursMinutesScheduled" = CONVERT(varchar(5), 
                  DATEADD(minute, SUM(v_st."numberOfMinutes"), 0), 114)
     FROM [dbo].[TIMESHEET_ViewCalendarScheduledTasks] ( @empid, c_d."sunday", c_d."saturday") v_st
     WHERE v_st."daynum" = v_rt."daynum" -- + 1 
     GROUP BY v_st."daynum"
     ) v_st
  ),

  recorded_totals_by_week as (
    SELECT
      "dispdate", SUM("minutes") "minutesRecordedThisWeek"

    FROM
     criticaldates
     OUTER APPLY
     [dbo].[TIMESHEET_ViewCalendarRecordedTasks] ( @empid, criticaldates."sunday", criticaldates."saturday")
     GROUP BY "dispdate"
  ),

  scheduled_and_recorded_totals_by_week as (
    SELECT
      r_tw.*, "minutesScheduledThisWeek", ted.id ted_id_dispdate

    FROM
     criticaldates
    LEFT JOIN
      [dbo].[TimeEntry_Day] ted ON ted.employeeID = @empid AND ted.dateForTimeEntry =  CAST( @dispdate as date)
     OUTER APPLY
     recorded_totals_by_week r_tw
     OUTER APPLY
     (
     SELECT SUM(s_tw."numberOfMinutes") "minutesScheduledThisWeek"
     FROM [dbo].[TIMESHEET_ViewCalendarScheduledTasks] ( @empid, criticaldates."sunday", criticaldates."saturday") s_tw
     ) s_tw

  ),
  /*
  all_totals_recorded as (SELECT *  FROM ( SELECT * FROM ( SELECT
    "hoursMinutesRecordedThisWeek" = CAST( by_wk."minutesRecordedThisWeek" / 60 as VARCHAR) + ':' + CAST( FORMAT(by_wk."minutesRecordedThisWeek" % 60, '00') as VARCHAR),
    "hoursMinutesScheduledThisWeek" = CAST( by_wk."minutesScheduledThisWeek" / 60 as VARCHAR) + ':' + CAST( FORMAT(by_wk."minutesScheduledThisWeek" % 60, '00') as VARCHAR),
    *
   FROM scheduled_and_recorded_totals_by_week by_wk OUTER APPLY scheduled_and_recorded_totals_by_day ) s2
   FOR JSON AUTO) s1(all_totals_recorded) ),
  */
   all_weekly_totals_recorded as (SELECT *  FROM ( SELECT * FROM ( SELECT
    "hoursMinutesRecordedThisWeek" = CAST( by_wk."minutesRecordedThisWeek" / 60 as VARCHAR) + ':' + CAST( FORMAT(by_wk."minutesRecordedThisWeek" % 60, '00') as VARCHAR),
    "hoursMinutesScheduledThisWeek" = CAST( by_wk."minutesScheduledThisWeek" / 60 as VARCHAR) + ':' + CAST( FORMAT(by_wk."minutesScheduledThisWeek" % 60, '00') as VARCHAR),
    *
   FROM scheduled_and_recorded_totals_by_week by_wk /* OUTER APPLY scheduled_and_recorded_totals_by_day */ ) s2
   /* FOR JSON AUTO */ ) s1 /* (all_totals_recorded) */ ),

   all_totals_recorded as ( SELECT * FROM ( SELECT
    *
   FROM all_weekly_totals_recorded OUTER APPLY scheduled_and_recorded_totals_by_day
   
   FOR JSON AUTO ) s1(all_totals_recorded)

   ) ,
   --FOR JSON AUTO) s1 (all_totals_recorded) ,

  glance_recorded_for_week_list_nested as (
    SELECT
      v_rt."date", v_rt.taskName, v_rt.organizationName, v_rt."title", v_rt.taskID_orgID, v_rt.taskID,
      ISNULL(SUM(v_rt."minutes"), 0) "minutesRecorded",
      "hoursMinutesRecorded" = CAST( SUM(v_rt."minutes") / 60 as VARCHAR) + ':' + CAST( FORMAT( SUM(v_rt."minutes") % 60, '00') as VARCHAR),
      COUNT(v_rt.id) "countRecorded",
      "SpecifyStartStopTime",
      --daynum = ((DATEPART(WEEKDAY, v_rt."date") ) - 1  ),
      ted_id,
      day_entries = '[' +
      ISNULL( STRING_AGG(
        '{ "taskName": "' + ISNULL( v_rt.taskName, '') +
        '", "organizationName": "' + ISNULL(v_rt.organizationName, '') +
        '", "title": "' + ISNULL( title, '') +
        '", "minutes": "' + ISNULL( CAST( v_rt."minutes" as varchar) , '') +
        '", "hoursMinutes": "' + ISNULL( CAST( v_rt."hoursMinutes" as varchar) , '0:00') +
        '", "te_id": ' + CAST( id as varchar ) +
   --     ', "SpecifyStartStopTime": ' + ( CASE WHEN ISNULL(SpecifyStartStopTime, 0) = 1 THEN '1' else '0' END ) +
        '}'
        ,
        ','
      ), '') + ']'
  

    FROM
     criticaldates
     OUTER APPLY
     [dbo].[TIMESHEET_ViewCalendarRecordedTasks] ( @empid, criticaldates."sunday", criticaldates."saturday") v_rt
     GROUP BY "date", ted_id, taskName, organizationName, "title", taskID, taskID_orgID, "SpecifyStartStopTime"
  ),

  glance_scheduled_and_recorded_for_week_list_nested as (
    SELECT
      g1.*,

      v_st.*,
      daynum = ((DATEPART(WEEKDAY, g1."date") ) /* - 1 */ )

    FROM
     glance_recorded_for_week_list_nested g1
     OUTER APPLY
     ( SELECT

      ISNULL(SUM(v_st."numberOfMinutes"), 0) "minutesScheduled",
      "hoursMinutesScheduled" = CAST( SUM(v_st."numberOfMinutes") / 60 as VARCHAR) + ':' + CAST( FORMAT( SUM(v_st."numberOfMinutes") % 60, '00') as VARCHAR),

      COUNT(v_st.id) "countScheduled",
      day_scheduled = '[' +
      ISNULL( STRING_AGG(
        '{ "taskName": "' + ISNULL( STRING_ESCAPE(v_st.taskName, 'json') , '') +  /* TODO: we prolly need to STRING_ESCAPE in other places as well */
        '", "minutes": "' + ISNULL( CAST( v_st."numberOfMinutes" as varchar) , '') +
        '"}'
        ,
        ','
      ), '') + ']'  
       FROM [dbo].[TIMESHEET_ViewCalendarScheduledTasks] ( @empid, g1."date", g1."date") v_st
       WHERE g1.organizationName IS NULL AND g1.taskID = v_st.id
       AND v_st."numberOfMinutes" > 0
       ) v_st
  ),

  glance_recorded_for_week_by_weekday_blob as (
    SELECT
      taskName, organizationName, "title", taskID_orgID, "SpecifyStartStopTime",
      blob = '[' +
        STRING_AGG(
          '{"daynum": "' + CAST(daynum /* - 1 */ as varchar) +
          '", "date": "' + CAST("date" as varchar) +

          '", "ted_id": "' + CAST( "ted_id" as varchar ) +

          '", "minutesRecorded": "' + ISNULL( CAST("minutesRecorded" as varchar), '0') +
          '", "hoursMinutesRecorded": "' + ISNULL( CAST( "hoursMinutesRecorded" as varchar) , '0:00') +

          '", "minutesScheduled": "' + ISNULL( CAST("minutesScheduled" as varchar), '0' ) +
          '", "hoursMinutesScheduled": "' + ISNULL( CAST( "hoursMinutesScheduled" as varchar) , '0:00') +

          '", "countRecorded": "' +  ISNULL( CAST("countRecorded" as varchar), '0') +
          '", "countScheduled": "' +  ISNULL( CAST("countRecorded" as varchar), '0') +

          '", "breakdown": { "day_entries": ' +  ISNULL( "day_entries", '[]' )  +
                          ' ,"day_scheduled": ' + ISNULL( "day_scheduled", '[]') +
           '}' + 
         '}'
        ,
        ','
        ) WITHIN GROUP ( ORDER BY "daynum" ASC )
        + ']'
    FROM glance_scheduled_and_recorded_for_week_list_nested
    GROUP BY taskName, organizationName, "title", taskID_orgID, "SpecifyStartStopTime"

  ),

  te_saveform_render_info_employers as ( select * from (

     select --top 1
                                                  o.id org_id,
                                                  o.name org_name
                                             from
                                                  TimeKeeper.dbo.Employees e
                                                  inner join TimeKeeper.dbo.Organizations o
                                                       on o.id = e.organizationID
                                             where 
                                                  e.id = @empid
                                                  and o.active = 1

  FOR JSON AUTO ) q(employers)
  ),

  te_saveform_render_info as ( --SELECT * FROM (

    select * FROM te_saveform_render_info_employers

      LEFT JOIN ( select * from (
    SELECT * FROM [dbo].[ViewListOfFavoriteClients] (@empid)  ORDER BY "name" ASC
  for JSON auto ) q(clients) ) te_saveform_render_info_favorite_clients ON (@includeFormData > 0 )

  LEFT JOIN ( select * from (
    SELECT * FROM [dbo].[ViewListOfTasks] (@empid)
  for JSON auto ) q2 (tasks) ) te_saveform_render_info_tasks ON (@includeFormData > 0 )

  ---FOR JSON AUTO ) s1(te_saveform_render_info)
  )


  
  SELECT * FROM ( SELECT * FROM 
  
  
  ( select * from
    all_totals_recorded
        LEFT JOIN
    (select * from te_saveform_render_info FOR JSON AUTO ) q2 (te_saveform_render_info)
   ON (@includeFormData > 0 ) 
  ) all_totals_recorded


  OUTER APPLY (
  
   SELECT "title", taskName, organizationName, taskID_orgID, JSON_QUERY(blob, '$') blob FROM glance_recorded_for_week_by_weekday_blob

  ) recorded_week_glance
  
    
  /* (w_g) */ FOR JSON AUTO ) allcontent(allcontent)




)
GO

grant select on TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRptWeekGlance to webuser
GO