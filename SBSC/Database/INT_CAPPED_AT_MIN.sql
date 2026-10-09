USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INT_CAPPED_AT_MIN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INT_CAPPED_AT_MIN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[INT_CAPPED_AT_MIN]
(@int as int, 
 @min as int) 

RETURNS int 
WITH SCHEMABINDING 
AS    
BEGIN
  
  /***************************************************************************    
   * INT_CAPPED_AT_MIN */    
  /**    
   * Returns int if it is greater than or equal to min or min if it is less than min
   * max.
   *   
   * @param  int             Integer to evaluate
   * @param  min             Min value
   * @return                 Integer
   ***************************************************************************/  
      
  declare @value as int
    
  if (@int is null) return null
  if (@min is null) return null
  
  if (@int <  @min) set @value = @min
  if (@int >= @min) set @value = @int
  
  return @value
  
END    
GO
