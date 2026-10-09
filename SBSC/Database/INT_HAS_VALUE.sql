USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INT_HAS_VALUE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INT_HAS_VALUE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[INT_HAS_VALUE](@int as bigint) 
RETURNS bit 
WITH SCHEMABINDING 
AS    
BEGIN
  
  /***************************************************************************    
   * INT_HAS_VALUE */    
  /**    
   * Returns true if the input integer is not null otherwise returns 
   * false.
   *   
   * @param  int             Integer to evaluate
   * @return                 bit
   ***************************************************************************/  
      
  if (@int is null) return 0
  return 1
END    
GO
