USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CREATE_CONCAT_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CREATE_CONCAT_NAME
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CREATE_CONCAT_NAME] (@lname varchar(500), @fname varchar(500))    
returns varchar(500)  
WITH SCHEMABINDING   
    
/***************************************************************************    
 * CREATE_CONCAT_NAME */    
/**    
 * 
 * Creates a concatanated name of the form lname, fname
 *
 * @param   lname            Last name
 * @param   fname            First name
 * @return  string 
 ***************************************************************************/            
     
as           
begin    

declare @name as varchar(500)

/*-------------------------------    
 * Handle blanks and nulls in
 * name parts
 *------------------------------*/    

if (@lname is null) set @lname = ''
if (@fname is null) set @fname = ''

/*-------------------------------    
 * Trim name parts
 *------------------------------*/   

set @lname = ltrim(rtrim(@lname))
set @fname = ltrim(rtrim(@fname))

/*-------------------------------    
 * Build the name and include a 
 * , between the last and first
 * names if the last name is
 * not blank
 *------------------------------*/   

set @name = @lname
if (len(@name) > 0) set @name = @name + ', '
set @name = @name + @fname

/*-------------------------------    
 * Return the name
 *------------------------------*/   

return @name  

end    
    
GO
