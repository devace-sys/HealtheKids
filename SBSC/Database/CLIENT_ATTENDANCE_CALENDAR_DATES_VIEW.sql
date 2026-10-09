USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_CALENDAR_DATES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_ATTENDANCE_CALENDAR_DATES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLIENT_ATTENDANCE_CALENDAR_DATES_VIEW]
(@userID        INT,    
 @userGroup     INT,    
 @userRank      INT,
 @clientID      int,
 @fiscalYearID  int,
 @calendarID    bigint, 
 @active        bit,
 @recID         bigint)

RETURNS TABLE 

/***************************************************************************    
 * CLIENT_ATTENDANCE_CALENDAR_DATES_VIEW */    
/**    
 * Returns a table of day types and dates assigned to that day type 
 * for a given calendar
 *
 * @return table 
 ***************************************************************************/     

AS RETURN
(

  select 
    acd.*,
    ac.name,
    ac.fiscalYearID,
    fy.FY_START      as startDate,
    fy.FY_END        as endDate,
    cc.CLIENT_NAME   as clientName,
    fy.FY_DEFINITION as fiscalYearName,
    adt.name         as attendanceDayType
  from CLIENT_ATTENDANCE_CALENDAR_DATES     as acd
  join CLIENT_ATTENDANCE_CALENDAR           as ac  on ac.id        = acd.calendarID
  join CLIENT_ATTENDANCE_DAY_TYPES          as adt on adt.id       = acd.attendanceDayTypeID
  join COMPANY_FISCAL_YEARS                 as fy  on fy.id        = ac.fiscalYearID
  join CLIENTS_Client                       as cc  on cc.CLIENT_ID = ac.clientID 
  where
    (1=1)
    and ((@clientID     is null) or (acd.clientID    = @clientID))
    and ((@fiscalYearID is null) or (ac.fiscalYearID = @fiscalYearID))
    and ((@calendarID   is null) or (acd.calendarID  = @calendarID))    
    and ((@active       is null) or (acd.Active      = @active))
    and ((@recID        is null) or (acd.id          = @recID))
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_ATTENDANCE_CALENDAR_DATES_VIEW] TO [webuser]
GO   

