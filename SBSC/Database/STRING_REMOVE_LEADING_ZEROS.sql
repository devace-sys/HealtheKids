USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_REMOVE_LEADING_ZEROS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_REMOVE_LEADING_ZEROS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * STRING_REMOVE_LEADING_ZEROS */    
/**    
 * Removes leading zeros and spaces from @value
 * Based on code from https://stackoverflow.com/a/92363
 ***************************************************************************/   

CREATE FUNCTION [dbo].[STRING_REMOVE_LEADING_ZEROS] (    
  @value nvarchar(255)
) 
RETURNS nvarchar(255)
WITH SCHEMABINDING
AS     
BEGIN    

  -- https://stackoverflow.com/a/92363
  -- https://blog.sqlauthority.com/2012/11/22/sql-server-removing-leading-zeros-from-column-in-table-part-2/
  
  RETURN SUBSTRING (@value, PATINDEX('%[^0 ]%', @value + ' '), 255)
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[STRING_REMOVE_LEADING_ZEROS] TO [webuser]
GO