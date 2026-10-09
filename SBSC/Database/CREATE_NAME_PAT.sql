USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CREATE_NAME_PAT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CREATE_NAME_PAT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CREATE_NAME_PAT] (@name varchar(100))    
returns varchar(100)  
WITH SCHEMABINDING   
    
/***************************************************************************    
 * CREATE_NAME_PAT */    
/**    
 * Creates a search pattern suitable for searching for names with a
 * like operator.
 * 
 * For example name = smi would become smi%
 *    
 * @param   name            Name to look for   
 * @return  string or null
 ***************************************************************************/            
     
as           
begin    

/*-------------------------------    
 * If the name is null get out
 *------------------------------*/    
    
if (@name is null) return null
   
/*-------------------------------    
 * Trim name
 *------------------------------*/   
 
set @name = ltrim(rtrim(@name))
if (@name = '') return null

set @name = @name + '%'

return @name  
end    
    
GO
