USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_REMOVE_CHARS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_REMOVE_CHARS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * STRING_REMOVE_CHARS */    
/**    
 * @return               string
 ***************************************************************************/   

CREATE FUNCTION [dbo].[STRING_REMOVE_CHARS] (    
    @value           varchar(max)  = null
  , @charsToRemove   varchar(256)  = null /* String containing chars with no spaces between */
  , @replacementChar varchar(1)    = null /* Internal replacement char that is used to replace then remove */
) 
RETURNS varchar(max)
WITH SCHEMABINDING
AS     
BEGIN    
  if (@value         is null) return @value
  if (@charsToRemove is null) return @value
  if (@replacementChar is null) set @replacementChar = char(9)    
  return replace(translate(@value,@charsToRemove,replicate(@replacementChar,len(@charsToRemove))),@replacementChar,'')
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[STRING_REMOVE_CHARS] TO [webuser]
GO