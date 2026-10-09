USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_CALENDAR_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_ATTENDANCE_CALENDAR_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLIENT_ATTENDANCE_CALENDAR_VIEW]
(@userID        INT,    
 @userGroup     INT,    
 @userRank      INT,
 @clientID      int,
 @fiscalYearID  int,
 @active        bit,
 @recID         bigint)

RETURNS TABLE 

/***************************************************************************    
 * CLIENT_ATTENDANCE_CALENDAR_VIEW */    
/**    
 * Returns a table of 
 *
 * @return table 
 ***************************************************************************/     

AS RETURN
(

  select top (dbo.CONST_MAX_ROWS())
    ac.*,
    ay.StartDate,
    ay.EndDate,
    ay.AttendanceYear,
    cc.CLIENT_NAME          as clientName, 
    cf.FY_DEFINITION        as fiscalYearName
  from CLIENT_ATTENDANCE_CALENDAR      as ac
  join CLIENT_ATTENDANCE_YEARS_VIEW (@userID,@userGroup,@userRank,null,null) 
                                       as ay  on ay.id = ac.fiscalYearID
  join CLIENTS_CLIENT                  as cc  on cc.CLIENT_ID = ac.clientID
  left join dbo.COMPANY_FISCAL_YEARS   as cf  on cf.id        = ac.fiscalYearID
  where
        (1=1)
    and ((@clientID     is null) or (ac.clientID     = @clientID))
    and ((@fiscalYearID is null) or (ac.fiscalYearID = @fiscalYearID))   
    and ((@active       is null) or (ac.Active       = @active))
    and ((@recID        is null) or (ac.id           = @recID))
  order by cc.CLIENT_NAME, cf.FY_DEFINITION, ac.Name 
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_ATTENDANCE_CALENDAR_VIEW] TO [webuser]
GO   

