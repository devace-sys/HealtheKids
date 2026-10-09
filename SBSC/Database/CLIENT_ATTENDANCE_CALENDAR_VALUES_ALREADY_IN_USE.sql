USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_CALENDAR_VALUES_ALREADY_IN_USE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_ATTENDANCE_CALENDAR_VALUES_ALREADY_IN_USE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLIENT_ATTENDANCE_CALENDAR_VALUES_ALREADY_IN_USE]
(@clientID      int,
 @fiscalYearID  int,
 @calendarID    int,
 @dayType       int,
 @whatValues    int,
 @includeQuotes bit)

RETURNS TABLE 

/***************************************************************************    
 * CLIENT_ATTENDANCE_CALENDAR_VALUES_ALREADY_IN_USE */    
/**    
 * Returns a table of day types or dates already in use, depending on 
 * whatValues choice.
 *
 * @return table 
 ***************************************************************************/     

AS RETURN
(

with
cte_values_in_use_detail
as
(
  select 
    convert(varchar(100),adt.ID)                               as attendanceDayTypeIDStr,
    adt.Name                                                   as attendanceDayTypeName,       
    convert(varchar(10),acdd.attendanceDay, 101)               as attendanceDateStr,
    acdd.attendanceDay                                         as attendanceDate,
    adt.ID                                                     as attendanceDayTypeID
  from CLIENT_ATTENDANCE_CALENDAR            as ac
  join CLIENT_ATTENDANCE_CALENDAR_DATES      as acd  on acd.calendarID       = ac.id
  join CLIENT_ATTENDANCE_CALENDAR_DATES_DAYS as acdd on acdd.calendarDatesID = acd.id
  join CLIENT_ATTENDANCE_DAY_TYPES           as adt  on adt.id               = acd.attendanceDayTypeID
  where 
    ac.clientID             =  @clientID     and
    ac.fiscalYearID         =  @fiscalYearID and
    ac.id                   =  @calendarID   and 
    acd.active              =  1             and
   ((@dayType is null) or (acd.attendanceDayTypeID != @dayType))         
)
,
cte_dates_in_use
as
(
  select DatesInUseStr as [Values]
  from 
  (
    select substring(
      (select ',' + 
        case when @includeQuotes = 1 
          then '''' + s.attendanceDateStr + '''' 
          else s.attendanceDateStr 
        end              
       from cte_values_in_use_detail s
       order by s.attendanceDate
       for xml path(''))
     ,2,200000) as [DatesInUseStr]
   ) as s1
)
,
cte_day_type_ids_in_use
as
(
  select DayTypeIDsInUseStr as [Values]
  from 
  (
    SELECT SUBSTRING(
      (SELECT ',' + s.attendanceDayTypeIDStr
       FROM 
       (
       select distinct attendanceDayTypeID, attendanceDayTypeIDStr from cte_values_in_use_detail
       ) as s
       ORDER BY s.attendanceDayTypeID
       FOR XML PATH(''))
     ,2,200000) as [DayTypeIDsInUseStr]
   ) as s1
)
,
cte_values_in_use_summary
as
(
  select 1 as WhatValues, * from cte_day_type_ids_in_use
  union
  select 2 as WhatValues, * from cte_dates_in_use
)
select [Values] from cte_values_in_use_summary where WhatValues = @whatValues
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_ATTENDANCE_CALENDAR_VALUES_ALREADY_IN_USE] TO [webuser]
GO   

