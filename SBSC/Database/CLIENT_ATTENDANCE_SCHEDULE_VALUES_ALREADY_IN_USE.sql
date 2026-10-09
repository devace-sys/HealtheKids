USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_SCHEDULE_VALUES_ALREADY_IN_USE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_ATTENDANCE_SCHEDULE_VALUES_ALREADY_IN_USE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLIENT_ATTENDANCE_SCHEDULE_VALUES_ALREADY_IN_USE]
(@clientID      int,
 @fiscalYearID  int,
 @scheduleID    int,
 @dayType       int,
 @whatValues    int,
 @includeQuotes bit)

RETURNS TABLE 

/***************************************************************************    
 * CLIENT_ATTENDANCE_SCHEDULE_VALUES_ALREADY_IN_USE */    
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
    adt.ID                                                     as attendanceDayTypeID
  from CLIENT_ATTENDANCE_SCHEDULE            as asd
  join CLIENT_ATTENDANCE_SCHEDULE_TIMES      as asdt on asdt.scheduleID   = asd.id
  join CLIENT_ATTENDANCE_DAY_TYPES           as adt  on adt.id            = asdt.attendanceDayTypeID
  where 
    asd.clientID             =  @clientID     and
    asd.fiscalYearID         =  @fiscalYearID and
    asd.id                   =  @scheduleID   and 
    asdt.active              =  1             and
   ((@dayType is null) or (asdt.attendanceDayTypeID != @dayType))         
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
)
select [Values] from cte_values_in_use_summary where WhatValues = @whatValues
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_ATTENDANCE_SCHEDULE_VALUES_ALREADY_IN_USE] TO [webuser]
GO   

