use timekeeper
go


DROP function if exists [dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRpt]
GO

CREATE FUNCTION [dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRpt] (@empid bigint, @dispdate datetime, @includeFormData bit)
returns table

AS    

return  
(

  with criticaldates as (

    SELECT
      c_d.*,
      ted.id ted_id
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
    LEFT JOIN
      [dbo].[TimeEntry_Day] ted ON ted.employeeID = @empid AND ted.dateForTimeEntry =  CAST( @dispdate as date)
  ),
  totals_by_day as (

    SELECT

    c_t.daynum, c_t."date", /* dateRecorded, */

    ISNULL("recordedMinutesTotal",0) recordedMinutesTotal, ISNULL("hoursMinutesRecordedTotal", '0:00') hoursMinutesRecorded,
    
                  
    ISNULL("scheduledMinutesTotal", 0) scheduledMinutesTotal,

    ISNULL("hoursMinutesScheduledTotal", '0:00') "hoursMinutesScheduled"

    FROM
     criticaldates
     OUTER APPLY
     [dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTotals] ( @empid, criticaldates."sunday", criticaldates."saturday") c_t
    -- WHERE organizationName IS NULL
    --GROUP BY daynum, "date" --, dateRecorded
  ),
  totals_by_week as (

    SELECT s1.* FROM
    (
    SELECT
      "dispdate", ted.id ted_id_dispdate, SUM("recordedMinutesTotal") "recordedMinutesTotal", SUM("scheduledMinutesTotal") "scheduledMinutesTotal"
    FROM
     criticaldates
    LEFT JOIN
      [dbo].[TimeEntry_Day] ted ON ted.employeeID = @empid AND ted.dateForTimeEntry =  CAST( @dispdate as date)
     --OUTER APPLY
     --[dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTasks] ( @empid, criticaldates."sunday", criticaldates."saturday")
     --WHERE organizationName IS NULL
     OUTER APPLY totals_by_day -- ON "date" = "dispdate"
     GROUP BY "dispdate", ted.id
     ) s1

  ),
  all_totals as (SELECT *  FROM ( SELECT
    "hoursMinutesRecorded" = CAST( totals_by_week."recordedMinutesTotal" / 60 as VARCHAR) + ':' + CAST( FORMAT(totals_by_week."recordedMinutesTotal" % 60, '00') as VARCHAR),
    "hoursMinutesScheduled" = CAST( totals_by_week."scheduledMinutesTotal" / 60 as VARCHAR) + ':' + CAST( FORMAT(totals_by_week."scheduledMinutesTotal" % 60, '00') as VARCHAR),
    *
   FROM totals_by_week OUTER APPLY totals_by_day
   FOR JSON AUTO) s1(all_totals) 

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
    SELECT * FROM [dbo].[ViewListOfFavoriteClients] (@empid) ORDER BY "name" ASC
  for JSON auto ) q(clients) ) te_saveform_render_info_favorite_clients ON (@includeFormData > 0 )

  LEFT JOIN ( select * from (
    SELECT * FROM [dbo].[ViewListOfTasks] (@empid)
  for JSON auto ) q2 (tasks) ) te_saveform_render_info_tasks ON (@includeFormData > 0 )

  ---FOR JSON AUTO ) s1(te_saveform_render_info)
  )

  

  SELECT * FROM ( SELECT * FROM
  
  
  ( select * from
    all_totals
        LEFT JOIN
    (select * from te_saveform_render_info FOR JSON AUTO ) q2 (te_saveform_render_info)
   ON (@includeFormData > 0 ) 
  ) all_totals

    OUTER APPLY (
    SELECT
      taskID,
      taskName,
      recordedTaskTitle,
      recordedMinutesTotal,
      hoursMinutesRecordedTotal,
      scheduledMinutesTotal,
      hoursMinutesScheduledTotal,
      daynum,
      dateRecorded,
      JSON_QUERY(taskRecordedInfo, '$') taskRecordedInfo,
      isScheduled,
      isRecorded,
      JSON_QUERY( taskScheduledInfo, '$') taskScheduledInfo
    FROM [dbo].[TIMESHEET_ViewCalendarCombinedScheduledRecordedTasks] ( @empid, @dispdate, @dispdate )

   FOR JSON AUTO) listings_selected_day(l_s_d) 
   

   
   FOR JSON AUTO ) allcontent(allcontent)

)
GO

grant select on TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRpt to webuser
GO