USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_SCHEDULE_TIMES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_ATTENDANCE_SCHEDULE_TIMES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLIENT_ATTENDANCE_SCHEDULE_TIMES_VIEW]
(@userID        INT,    
 @userGroup     INT,    
 @userRank      INT,
 @clientID      int,
 @fiscalYearID  int,
 @scheduleID    bigint,
 @active        bit,
 @recID         bigint)

RETURNS TABLE 

/***************************************************************************    
 * CLIENT_ATTENDANCE_SCHEDULE_TIMES_VIEW */    
/**    
 * Returns a table of day types and times assigned to that day type 
 * for a given bell schedule
 *
 * @return table 
 ***************************************************************************/     

AS RETURN
(

  select 
    st.id,
    st.clientID,
    st.scheduleID,
    st.attendanceDayTypeID,
    st.attendanceTimeStart,
    st.attendanceTimeEnd,
    st.period0TimeStart,
    st.period0TimeEnd,
    st.period1TimeStart,
    st.period1TimeEnd,
    st.period2TimeStart,
    st.period2TimeEnd,
    st.period3TimeStart,
    st.period3TimeEnd,
    st.period4TimeStart,
    st.period4TimeEnd,
    st.period5TimeStart,
    st.period5TimeEnd,
    st.period6TimeStart,
    st.period6TimeEnd,
    st.period7TimeStart,
    st.period7TimeEnd,
    st.period8TimeStart,
    st.period8TimeEnd,
    st.period9TimeStart,
    st.period9TimeEnd,
    st.period10TimeStart,
    st.period10TimeEnd,
    CONVERT(varchar(20),st.period0TimeStart,22)               as p0StartTimeStr,
    CONVERT(varchar(20),st.period0TimeEnd,22)                 as p0EndTimeStr,
    CONVERT(varchar(20),st.period1TimeStart,22)               as p1StartTimeStr,
    CONVERT(varchar(20),st.period1TimeEnd,22)                 as p1EndTimeStr, 
    CONVERT(varchar(20),st.period2TimeStart,22)               as p2StartTimeStr,
    CONVERT(varchar(20),st.period2TimeEnd,22)                 as p2EndTimeStr, 
    CONVERT(varchar(20),st.period3TimeStart,22)               as p3StartTimeStr,
    CONVERT(varchar(20),st.period3TimeEnd,22)                 as p3EndTimeStr, 
    CONVERT(varchar(20),st.period4TimeStart,22)               as p4StartTimeStr,
    CONVERT(varchar(20),st.period4TimeEnd,22)                 as p4EndTimeStr, 
    CONVERT(varchar(20),st.period5TimeStart,22)               as p5StartTimeStr,
    CONVERT(varchar(20),st.period5TimeEnd,22)                 as p5EndTimeStr, 
    CONVERT(varchar(20),st.period6TimeStart,22)               as p6StartTimeStr,
    CONVERT(varchar(20),st.period6TimeEnd,22)                 as p6EndTimeStr, 
    CONVERT(varchar(20),st.period7TimeStart,22)               as p7StartTimeStr,
    CONVERT(varchar(20),st.period7TimeEnd,22)                 as p7EndTimeStr, 
    CONVERT(varchar(20),st.period8TimeStart,22)               as p8StartTimeStr,
    CONVERT(varchar(20),st.period8TimeEnd,22)                 as p8EndTimeStr, 
    CONVERT(varchar(20),st.period9TimeStart,22)               as p9StartTimeStr,
    CONVERT(varchar(20),st.period9TimeEnd,22)                 as p9EndTimeStr, 
    CONVERT(varchar(20),st.period10TimeStart,22)              as p10StartTimeStr,
    CONVERT(varchar(20),st.period10TimeEnd,22)                as p10EndTimeStr,   
    CONVERT(varchar(20),st.attendanceTimeStart,22)            as timeStartStr,
    CONVERT(varchar(20),st.attendanceTimeEnd,22)              as timeEndStr,
    st.created,
    st.createdBy,
    st.lastUpdated,
    st.lastUpdatedBy,
    st.active,
    cc.CLIENT_NAME as clientName, 
    s.name                                                   as scheduleName,
    fy.FY_DEFINITION as fiscalYearName,
    s.fiscalYearID,
    adt.name                                                 as attendanceDayType
  
  from CLIENT_ATTENDANCE_SCHEDULE_TIMES     as st
  join CLIENT_ATTENDANCE_SCHEDULE           as s   on s.id   = st.scheduleID
  join CLIENT_ATTENDANCE_DAY_TYPES          as adt on adt.id = st.attendanceDayTypeID
  join COMPANY_FISCAL_YEARS                 as fy  on fy.id  = s.fiscalYearID
  join CLIENTS_Client                       as cc  on cc.CLIENT_ID = s.clientID 

  where
    (1=1)
    and ((@clientID     is null) or (st.clientID    = @clientID))
    and ((@fiscalYearID is null) or (s.fiscalYearID = @fiscalYearID))
    and ((@scheduleID   is null) or (st.scheduleID  = @scheduleID))
    and ((@active       is null) or (st.Active      = @active))
    and ((@recID        is null) or (st.id          = @recID))

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_ATTENDANCE_SCHEDULE_TIMES_VIEW] TO [webuser]
GO   

