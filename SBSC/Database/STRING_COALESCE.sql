USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_COALESCE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_COALESCE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[STRING_COALESCE](@string1 VARCHAR(8000), @string2 VARCHAR(8000)) RETURNS VARCHAR(8000) AS    
BEGIN    
  
  /***************************************************************************    
   * STRING_COALESCE */    
  /**    
   * Returns the first non null or blank string or returns a blank
   *    
   * @param  string1         First string to evaluate
   * @param  string2         Second string to evaluate
   * @return                 string
   ***************************************************************************/  
   
  if (dbo.STRING_IS_NULL_OR_EMPTY(@string1) = 0) return @string1
  if (dbo.STRING_IS_NULL_OR_EMPTY(@string2) = 0) return @string2
  return ''
END    
GO
