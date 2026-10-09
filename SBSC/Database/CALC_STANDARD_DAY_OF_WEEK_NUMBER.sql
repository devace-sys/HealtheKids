USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_STANDARD_DAY_OF_WEEK_NUMBER') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_STANDARD_DAY_OF_WEEK_NUMBER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[CALC_STANDARD_DAY_OF_WEEK_NUMBER] ( @value datetime )
RETURNS int
WITH SCHEMABINDING 
AS     
BEGIN        

  /***************************************************************************    
   * CALC_STANDARD_DAY_OF_WEEK_NUMBER */    
  /**    
   * Standardize day of week number (insulating us against datefirst
   * changes).  Sunday will always be 0 and Saturday will always be 6
   * Days between will be 1-5. 
   * Courtesey of https://stackoverflow.com/a/1113891 see comment
   * by https://stackoverflow.com/users/196451/endy-tjahjono 
   *   
   * @param  value  Date to get a day of week number for
   * @return                 Integer
   ***************************************************************************/  

  set @value = isnull(@value,getdate())
  return ( @@datefirst - 1 + datepart(weekday, @value) ) % 7 

END				
				   
GO  