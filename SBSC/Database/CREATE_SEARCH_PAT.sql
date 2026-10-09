USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CREATE_SEARCH_PAT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CREATE_SEARCH_PAT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CREATE_SEARCH_PAT] (@term varchar(100))    
returns varchar(100)  
WITH SCHEMABINDING   
    
/***************************************************************************    
 * CREATE_SEARCH_PAT */    
/**    
 * Creates a search pattern suitable for searching for values with a
 * like operator.
 * 
 * For example term = smi would become %smi%
 *    
 * @param   name            Name to look for   
 * @return  string or null
 ***************************************************************************/            
     
as           
begin    

/*-------------------------------    
 * If the name is null get out
 *------------------------------*/    
    
if (@term is null) return null
   
/*-------------------------------    
 * Trim name
 *------------------------------*/   
 
set @term = ltrim(rtrim(@term))
if (@term = '') return null

set @term = '%' + @term + '%'

return @term  

end    
    
GO
