USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_YEARS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_ATTENDANCE_YEARS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLIENT_ATTENDANCE_YEARS_VIEW]
(@userID       INT,    
 @userGroup    INT,    
 @userRank     INT,
 @refDate      DATETIME,
 @active       BIT)

RETURNS TABLE 

/***************************************************************************    
 * CLIENT_ATTENDANCE_YEARS_VIEW */    
/**    
 * Returns a table of attendance years with an optional window of current
 * (active) years,
 *
 * Note: This is using company fiscal years table
 *
 * @param   userID          The userid of who is calling this   
 * @param   userGroup       That users group    
 * @param   userRank        That user rank    
 * @param   active          1    = show only next, current, and last 
 *                                 attendance years.
 *                          0    = show all except next, current, and last 
 *                          null = show all
 * @return table 
 ***************************************************************************/     

AS RETURN
(
  select top (dbo.CONST_MAX_ROWS())
    *,
    [startDateStr] + ' to ' + [endDateStr] as [description]
  from
  (
    select   
      fy.id,
      fy.FY_DEFINITION                        as [name],
      fy.FY_START                             as [startDate],
      fy.FY_END                               as [endDate],
      dbo.RPT_DATE_FMT(fy.FY_START)           as [startDateStr],
      dbo.RPT_DATE_FMT(fy.FY_END)             as [endDateStr],
      fy.FY_DEFINITION                        as [attendanceYear],
      [active] = case
        when (yr.[yearRange] is null)     then cast(0 as bit)
        when (yr.[yearRange] is not null) then cast(1 as bit)   
      end,    
      [current] = case
        when GETDATE() between fy.FY_START and fy.FY_END then cast(1 as bit)
        else cast(0 as bit)
      end
    from COMPANY_FISCAL_YEARS                       as fy
    left join dbo.YEAR_RANGE_WINDOW(GETDATE(),-1,2) as yr on yr.yearRange = fy.FY_DEFINITION
  ) as q1
  where 
        (1=1)
    and (@active  is null) or ([active] = @active)
    and (@refDate is null) or (@refDate between startDate and endDate)
  order by [Current] desc, name
  
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_ATTENDANCE_YEARS_VIEW] TO [webuser]
GO   

