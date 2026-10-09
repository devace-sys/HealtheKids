USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_REMOVE_EXTRA_SPACES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_REMOVE_EXTRA_SPACES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * STRING_REMOVE_EXTRA_SPACES
/**/    
 * Removes extra spaces from start, end, and middle of @value
 *  
 * Basic approach courtesey of Neil Knight https://stackoverflow.com/a/2455869
 * And the concept of using non printable characters as the replacement chars
 * courtesey of richardtallent (in comments for Neil Knights post)
 ***************************************************************************/   

CREATE FUNCTION [dbo].[STRING_REMOVE_EXTRA_SPACES] (    
  @value varchar(max)
) 
RETURNS varchar(max)
WITH SCHEMABINDING
AS     
BEGIN    
  set @value = trim(isnull(@value,''))
  return replace(replace(replace(@value,' ',char(17) + char(18)),char(18) + char(17),''),char(17) + char(18),' ')
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[STRING_REMOVE_EXTRA_SPACES] TO [webuser]
GO