USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_OLDEST_DOS_ALLOWED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_OLDEST_DOS_ALLOWED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_OLDEST_DOS_ALLOWED](@refDate DATETIME) 
RETURNS DATETIME 
WITH SCHEMABINDING
AS

/***************************************************************************    
 * CALC_OLDEST_DOS_ALLOWED */    
/**    
 * Determines oldest date of service that will not result in a reject
 * with respect to refDate.
 *   
 * @param   refDate  Reference date, usually today
 * @return  datetime  
 ***************************************************************************/   
     
BEGIN

   
/* 1. If @refDate is null set it to today
 * 2. Remove time component from @refDate  
 * 3. Calculate the date 13 months back with respect to @refDate 
 * 4. Calculate what the end of the month date is for that date
 * 5. Add a day to that date.
*/
  return convert(datetime,(dateadd(day,1,(EOMONTH(dateadd(month,-13,convert(date,isnull(@refDate,getdate()))))))))

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_OLDEST_DOS_ALLOWED] TO [webuser]
GO