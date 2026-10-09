USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_SCHEDULE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_ATTENDANCE_SCHEDULE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLIENT_ATTENDANCE_SCHEDULE_VIEW]
(@userID        INT,    
 @userGroup     INT,    
 @userRank      INT,
 @clientID      int,
 @fiscalYearID  int,
 @active        bit,
 @recID         bigint)

RETURNS TABLE 

/***************************************************************************    
 * CLIENT_ATTENDANCE_SCHEDULE_VIEW */    
/**    
 * Returns a table
 *
 * @return table 
 ***************************************************************************/     

AS RETURN
(

  select top (dbo.CONST_MAX_ROWS()) 
    ad.*, 
    ay.StartDate,
    ay.EndDate,
    ay.AttendanceYear,
    ay.name          as fiscalYearName,
    cc.CLIENT_NAME   as clientName 
  from CLIENT_ATTENDANCE_SCHEDULE      as ad
  join CLIENT_ATTENDANCE_YEARS_VIEW (@userid,@usergroup,@userrank,null,null) 
                                       as ay  on ay.id        = ad.fiscalYearID
  join CLIENTS_CLIENT                  as cc  on cc.CLIENT_ID = ad.clientID
  where
        (1=1)
    and ((@clientID     is null) or (ad.clientID      = @clientID))
    and ((@fiscalYearID is null) or (ad.fiscalYearID  = @fiscalYearID))   
    and ((@active       is null) or (ad.Active        = @active))
    and ((@recID        is null) or (ad.id            = @recID))
  order by cc.CLIENT_NAME, ay.Name, ad.Name 
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_ATTENDANCE_SCHEDULE_VIEW] TO [webuser]
GO   

