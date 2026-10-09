USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_HAS_VALUE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_HAS_VALUE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[STRING_HAS_VALUE](@string VARCHAR(8000)) RETURNS bit AS    
BEGIN
  
  /***************************************************************************    
   * STRING_HAS_VALUE */    
  /**    
   * Returns true if the input string is not null or blank otherwise returns 
   * false.
   *   
   * @param  string          String to evaluate
   * @return                 bit
   ***************************************************************************/  
      
  if (dbo.STRING_IS_NULL_OR_EMPTY(@string) = 1) return 0
  return 1
END    
GO
