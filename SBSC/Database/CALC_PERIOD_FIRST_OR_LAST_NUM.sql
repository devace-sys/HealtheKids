USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_PERIOD_FIRST_OR_LAST_NUM') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_PERIOD_FIRST_OR_LAST_NUM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CALC_PERIOD_FIRST_OR_LAST_NUM]
(@what              SMALLINT,
 @period0TimeStart  TIME,
 @period0TimeEnd    TIME,
 @period1TimeStart  TIME,
 @period1TimeEnd    TIME,
 @period2TimeStart  TIME,
 @period2TimeEnd    TIME,
 @period3TimeStart  TIME,
 @period3TimeEnd    TIME,
 @period4TimeStart  TIME,
 @period4TimeEnd    TIME,
 @period5TimeStart  TIME,
 @period5TimeEnd    TIME,
 @period6TimeStart  TIME,
 @period6TimeEnd    TIME,
 @period7TimeStart  TIME,
 @period7TimeEnd    TIME,
 @period8TimeStart  TIME,
 @period8TimeEnd    TIME,
 @period9TimeStart  TIME,
 @period9TimeEnd    TIME,
 @period10TimeStart TIME,
 @period10TimeEnd   TIME
 
)

RETURNS int 
WITH SCHEMABINDING 
AS    
BEGIN
  
  /***************************************************************************    
   * CALC_PERIOD_FIRST_OR_LAST_NUM */    
  /**    
   * Returns the number of the first or last period depending on value of what
   *   
   * @param  what              0 = First 1 = Last
   * @param  periodxTimeStart  Start time or null if not used
   * @param  periodxTimeEnd    Start time or null if not used
   * @return                   Integer 0-10
   ***************************************************************************/  
    
  /*-------------------------------    
   * Find first period
   *------------------------------*/  

  if (@what = 0)
  begin
    if ((@period0TimeStart  is not null) and (@period0TimeEnd  is not null)) return 0
    if ((@period1TimeStart  is not null) and (@period1TimeEnd  is not null)) return 1
    if ((@period2TimeStart  is not null) and (@period2TimeEnd  is not null)) return 2
    if ((@period3TimeStart  is not null) and (@period3TimeEnd  is not null)) return 3
    if ((@period4TimeStart  is not null) and (@period4TimeEnd  is not null)) return 4
    if ((@period5TimeStart  is not null) and (@period5TimeEnd  is not null)) return 5
    if ((@period6TimeStart  is not null) and (@period6TimeEnd  is not null)) return 6
    if ((@period7TimeStart  is not null) and (@period7TimeEnd  is not null)) return 7
    if ((@period8TimeStart  is not null) and (@period8TimeEnd  is not null)) return 8
    if ((@period9TimeStart  is not null) and (@period9TimeEnd  is not null)) return 9
    if ((@period10TimeStart is not null) and (@period10TimeEnd is not null)) return 10
  end

  /*-------------------------------    
   * Find last period
   *------------------------------*/  

  if (@what = 1)
  begin
  
    if ((@period10TimeStart is not null) and (@period10TimeEnd is not null)) return 10
    if ((@period9TimeStart  is not null) and (@period9TimeEnd  is not null)) return 9
    if ((@period8TimeStart  is not null) and (@period8TimeEnd  is not null)) return 8
    if ((@period7TimeStart  is not null) and (@period7TimeEnd  is not null)) return 7
    if ((@period6TimeStart  is not null) and (@period6TimeEnd  is not null)) return 6
    if ((@period5TimeStart  is not null) and (@period5TimeEnd  is not null)) return 5
    if ((@period4TimeStart  is not null) and (@period4TimeEnd  is not null)) return 4
    if ((@period3TimeStart  is not null) and (@period3TimeEnd  is not null)) return 3
    if ((@period2TimeStart  is not null) and (@period2TimeEnd  is not null)) return 2
    if ((@period1TimeStart  is not null) and (@period1TimeEnd  is not null)) return 1
    if ((@period0TimeStart  is not null) and (@period0TimeEnd  is not null)) return 0
  
  end
     
  /*-------------------------------    
   * If we reach this point we
   * dont know what to do
   *------------------------------*/
    
  return null
  
END    
GO
