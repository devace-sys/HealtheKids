USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_CALENDAR_SCHEDULE_DOS_DETAIL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_ATTENDANCE_CALENDAR_SCHEDULE_DOS_DETAIL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_ATTENDANCE_CALENDAR_SCHEDULE_DOS_DETAIL]
(@clientID   as int,
 @calendarID as int,
 @scheduleID as int,
 @dos        as datetime)

/***************************************************************************    
 * CLIENT_ATTENDANCE_CALENDAR_SCHEDULE_DOS_DETAIL */    
/**    
 * Returns details of posssible attendance minutes for the given clientID
 * calendarID, scheduleID, and date of service
 *
 * @param   clientID        Client ID you wish to work with or null for all
 * @param   calendarID      Client attendance calendar
 * @param   scheduleID      Client attendance bell schedule
 * @param   dos             Date of service 
 ***************************************************************************/   

 
RETURNS TABLE 
AS 
RETURN
(
with

/*============================================================
 * Calendars
 *============================================================*/ 

cte_cal
as
(
  select 
  
    cac.id                   as [calendarID],
    cac.name                 as [calendarName],
    cacdd.attendanceDay      as [calendarDay], 
    cacd.attendanceDayTypeID as [calendarDayTypeID]
  
    
  from CLIENT_ATTENDANCE_CALENDAR_DATES_DAYS as cacdd
  join CLIENT_ATTENDANCE_CALENDAR_DATES      as cacd on cacd.id = cacdd.calendarDatesID
  join CLIENT_ATTENDANCE_CALENDAR            as cac  on cac.id  = cacd.calendarID
  where 
        cacdd.attendanceDay = @dos
    and cac.clientID        = @clientID
    and cac.id              = @calendarID
)
,

/*============================================================
 * Schedules
 *============================================================*/ 

cte_sch
as
(
  select 
    cs.id                    as [scheduleID],
    cs.name                  as [scheduleName],   
    cst.attendanceDayTypeID  as [scheduleDayTypeID],
   
    /*-------------------------------
     * Total Times/Minutes
     *------------------------------*/
   
    cst.attendanceTimeStart,
    cst.attendanceTimeEnd,
    DATEDIFF(minute,cst.attendanceTimeStart, cst.attendanceTimeEnd) as attendanceMin,
    
    /*-------------------------------
     * Determine first period
     *------------------------------*/
    
    [firstPeriod] = dbo.CALC_PERIOD_FIRST_OR_LAST_NUM(0,
                                                      cst.period0TimeStart,
                                                      cst.period0TimeEnd,
                                                      cst.period1TimeStart,
                                                      cst.period1TimeEnd,
                                                      cst.period2TimeStart,
                                                      cst.period2TimeEnd,
                                                      cst.period3TimeStart,
                                                      cst.period3TimeEnd,
                                                      cst.period4TimeStart,
                                                      cst.period4TimeEnd,
                                                      cst.period5TimeStart,
                                                      cst.period5TimeEnd,
                                                      cst.period6TimeStart,
                                                      cst.period6TimeEnd,
                                                      cst.period7TimeStart,
                                                      cst.period7TimeEnd,
                                                      cst.period8TimeStart,
                                                      cst.period8TimeEnd,
                                                      cst.period9TimeStart,
                                                      cst.period9TimeEnd,
                                                      cst.period10TimeStart,
                                                      cst.period10TimeEnd),
    /*-------------------------------
     * Determine last period
     *------------------------------*/
    
    [lastPeriod] = dbo.CALC_PERIOD_FIRST_OR_LAST_NUM(1,
                                                     cst.period0TimeStart,
                                                     cst.period0TimeEnd,
                                                     cst.period1TimeStart,
                                                     cst.period1TimeEnd,
                                                     cst.period2TimeStart,
                                                     cst.period2TimeEnd,
                                                     cst.period3TimeStart,
                                                     cst.period3TimeEnd,
                                                     cst.period4TimeStart,
                                                     cst.period4TimeEnd,
                                                     cst.period5TimeStart,
                                                     cst.period5TimeEnd,
                                                     cst.period6TimeStart,
                                                     cst.period6TimeEnd,
                                                     cst.period7TimeStart,
                                                     cst.period7TimeEnd,
                                                     cst.period8TimeStart,
                                                     cst.period8TimeEnd,
                                                     cst.period9TimeStart,
                                                     cst.period9TimeEnd,
                                                     cst.period10TimeStart,
                                                     cst.period10TimeEnd),
                                                                                                            
    /*-------------------------------
     * Period 0
     *------------------------------*/
    
    cst.period0TimeStart,
    cst.period0TimeEnd,
    DATEDIFF(minute,cst.period0TimeStart, cst.period0TimeEnd) as period0Min,   
    
    /*-------------------------------
     * Passing 0 to 1 
     *------------------------------*/

    DATEDIFF(minute,cst.period0TimeEnd, cst.Period1TimeStart) as pass0to1Min,
    
    /*-------------------------------
     * Period 1
     *------------------------------*/

    cst.period1TimeStart,
    cst.period1TimeEnd,
    DATEDIFF(minute,cst.period1TimeStart, period1TimeEnd) as period1Min,   

    /*-------------------------------
     * Passing 1 to 2 
     *------------------------------*/

    DATEDIFF(minute,cst.period1TimeEnd, cst.Period2TimeStart) as pass1to2Min,
    
    /*-------------------------------
     * Period 2
     *------------------------------*/

    cst.period2TimeStart,
    cst.period2TimeEnd,
    DATEDIFF(minute,cst.period2TimeStart, period2TimeEnd) as period2Min,
  
    /*-------------------------------
     * Passing 2 to 3 
     *------------------------------*/

    DATEDIFF(minute,cst.period2TimeEnd, cst.Period3TimeStart) as pass2to3Min,    
    
    /*-------------------------------
     * Period 3
     *------------------------------*/
    
    cst.period3TimeStart,
    cst.period3TimeEnd,
    DATEDIFF(minute,cst.period3TimeStart, period3TimeEnd) as period3Min,

    /*-------------------------------
     * Passing 3 to 4 
     *------------------------------*/

    DATEDIFF(minute,cst.period3TimeEnd, cst.Period4TimeStart) as pass3to4Min,

    /*-------------------------------
     * Period 4
     *------------------------------*/

    cst.period4TimeStart,
    cst.period4TimeEnd,
    DATEDIFF(minute,cst.period4TimeStart, period4TimeEnd) as period4Min,

    /*-------------------------------
     * Passing 4 to 5 
     *------------------------------*/

    DATEDIFF(minute,cst.period4TimeEnd, cst.Period5TimeStart) as pass4to5Min,

    /*-------------------------------
     * Period 5
     *------------------------------*/

    cst.period5TimeStart,
    cst.period5TimeEnd,
    DATEDIFF(minute,cst.period5TimeStart, period5TimeEnd) as period5Min,

    /*-------------------------------
     * Passing 5 to 6 
     *------------------------------*/

    DATEDIFF(minute,cst.period5TimeEnd, cst.Period6TimeStart) as pass5to6Min,

    /*-------------------------------
     * Period 6
     *------------------------------*/

    cst.period6TimeStart,
    cst.period6TimeEnd,
    DATEDIFF(minute,cst.period6TimeStart, period6TimeEnd) as period6Min,

    /*-------------------------------
     * Passing 6 to 7 
     *------------------------------*/

    DATEDIFF(minute,cst.period6TimeEnd, cst.Period7TimeStart) as pass6to7Min,

    /*-------------------------------
     * Period 7
     *------------------------------*/

    cst.period7TimeStart,
    cst.period7TimeEnd,
    DATEDIFF(minute,cst.period7TimeStart, period7TimeEnd) as period7Min,

    /*-------------------------------
     * Passing 7 to 8 
     *------------------------------*/

    DATEDIFF(minute,cst.period7TimeEnd, cst.Period8TimeStart) as pass7to8Min,

    /*-------------------------------
     * Period 8
     *------------------------------*/

    cst.period8TimeStart,
    cst.period8TimeEnd,
    DATEDIFF(minute,cst.period8TimeStart, period8TimeEnd) as period8Min,

    /*-------------------------------
     * Passing 8 to 9 
     *------------------------------*/

    DATEDIFF(minute,cst.period8TimeEnd, cst.Period9TimeStart) as pass8to9Min,

    /*-------------------------------
     * Period 9
     *------------------------------*/

    cst.period9TimeStart,
    cst.period9TimeEnd,
    DATEDIFF(minute,cst.period9TimeStart, period9TimeEnd) as period9Min,

    /*-------------------------------
     * Passing 9 to 10 
     *------------------------------*/

    DATEDIFF(minute,cst.period9TimeEnd, cst.Period10TimeStart) as pass9to10Min,

    /*-------------------------------
     * Period 10
     *------------------------------*/

    cst.period10TimeStart,
    cst.period10TimeEnd,
    DATEDIFF(minute,cst.period10TimeStart, period10TimeEnd) as period10Min
        
    
  from CLIENT_ATTENDANCE_SCHEDULE       as cs
  join CLIENT_ATTENDANCE_SCHEDULE_TIMES as cst on cst.scheduleID = cs.id
  where 
        cs.clientID = @clientID
    and cs.id       = @scheduleID
)
,

/*============================================================
 * Combined
 *============================================================*/ 

cte_cal_sch
as
(

  select 
    c.*,
    s.*,
    isnull(s.[lastPeriod],0) - isnull(s.[firstPeriod],0) as [numPeriods],
    d.id          as [dayTypeID],
    d.name        as [dayTypeName],
    d.description as [dayTypeDescription]
  from cte_cal                     as c
  join cte_sch                     as s on s.scheduleDayTypeID = c.calendarDayTypeID
  join CLIENT_ATTENDANCE_DAY_TYPES as d on     d.id = c.calendarDayTypeID 
                                           and d.id = s.scheduleDayTypeID
)
select * from cte_cal_sch 
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_ATTENDANCE_CALENDAR_SCHEDULE_DOS_DETAIL] TO [webuser]
GO
