USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INT_CAPPED_AT_MAX') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INT_CAPPED_AT_MAX
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[INT_CAPPED_AT_MAX]
(@int as int, 
 @max as int) 

RETURNS int 
WITH SCHEMABINDING 
AS    
BEGIN
  
  /***************************************************************************    
   * INT_CAPPED_AT_MAX */    
  /**    
   * Returns int if it is less than equal to max or max if it is greater than
   * max.
   *   
   * @param  int             Integer to evaluate
   * @param  max             Max value
   * @return                 Integer
   ***************************************************************************/  
      
  declare @value as int
    
  if (@int is null) return null
  if (@max is null) return null
  
  if (@int <= @max) set @value = @int
  if (@int >  @max) set @value = @max
  
  return @value
  
END    
GO
