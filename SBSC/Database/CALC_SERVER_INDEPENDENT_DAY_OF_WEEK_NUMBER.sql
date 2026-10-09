USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_SERVER_INDEPENDENT_DAY_OF_WEEK_NUMBER') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_SERVER_INDEPENDENT_DAY_OF_WEEK_NUMBER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[CALC_SERVER_INDEPENDENT_DAY_OF_WEEK_NUMBER] ( @value datetime )
RETURNS int
WITH SCHEMABINDING 
AS     
BEGIN        

  /***************************************************************************    
   * CALC_SERVER_INDEPENDENT_DAY_OF_WEEK_NUMBER */    
  /**    
   * Returns day of week number for value indepedent of @@DateFirst
   *
   * 0 = Mon,  1 = Tue,  2 = Wed,  3 = Thu, 4 = Fri, 5 = Sat, 6 = Sun
   *   
   * @param  value  Date to get a day of week number for
   * @return                 Integer
   ***************************************************************************/  
  
  /* 
   * Courtesey of http://www.dataplatformcentral.com/2012/08/18/creating-server-independent-day-comparison-logic-in-transact-sql/ 
   */   

  return DATEDIFF(dd,0,@value)% 7

END				
				   
GO  