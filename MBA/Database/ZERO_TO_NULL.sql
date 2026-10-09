USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ZERO_TO_NULL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ZERO_TO_NULL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[ZERO_TO_NULL](@int as int) RETURNS int 
WITH SCHEMABINDING 
AS    
BEGIN
  
  /***************************************************************************    
   * ZERO_TO_NULL */    
  /**    
   * Cleanup function to return null if an int is 0
   *   
   * @param  int             Integer to evaluate
   * @return                 int or null
   ***************************************************************************/  
      
  if (@int is null) return null
  if (@int = 0)     return null
  if (@int < 0)     return null
  return @int
END    
GO
