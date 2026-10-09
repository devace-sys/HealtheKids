USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_IS_WEEKDAY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_IS_WEEKDAY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[DATE_IS_WEEKDAY] ( @value datetime )
RETURNS bit
AS     
BEGIN        

  /***************************************************************************    
   * DATE_IS_WEEKDAY */    
  /**    
   * Determines if value is a weekday.  Returns 1 or 0.
   *   
   * @param  value  Date to test
   * @return bit
   ***************************************************************************/  
  
  /* 
   * Courtesey of http://www.dataplatformcentral.com/2012/08/18/creating-server-independent-day-comparison-logic-in-transact-sql/ 
   */   

  if ( dbo.CALC_SERVER_INDEPENDENT_DAY_OF_WEEK_NUMBER(@value) ) in (0,1,2,3,4) return 1
  return 0
  
END				
				   
GO  