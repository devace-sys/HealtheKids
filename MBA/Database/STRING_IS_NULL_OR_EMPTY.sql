USE USERS
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_IS_NULL_OR_EMPTY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_IS_NULL_OR_EMPTY
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[STRING_IS_NULL_OR_EMPTY](@string VARCHAR(8000)) 
RETURNS bit 
WITH SCHEMABINDING 
AS    
BEGIN
  /***************************************************************************    
   * STRING_IS_NULL_OR_EMPTY */    
  /**    
   * Returns true if the input string is null or blank otherwise returns 
   * false.
   *   
   * @param  string          String to evaluate
   * @return                 bit
   ***************************************************************************/  
    
  if  @string is null return 1
  set @string = ltrim(rtrim(@string))
  if (len(@string) = 0) return 1
  return 0
END    
GO
