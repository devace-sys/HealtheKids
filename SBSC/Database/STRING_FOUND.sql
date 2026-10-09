USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_FOUND') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_FOUND
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STRING_FOUND](@pattern     varchar(8000),     
                                     @inputString varchar(8000))    
returns bit    
    
/***************************************************************************    
 * STRING_FOUND */    
/**    
 * Locates pattern in input string and indicates if it was found    
 *    
 * @param  pattern         Pattern to use    
 * @param  inputString     String to search    
 * @return                 1 if pattern was found    
 *                         0 if pattern was not found    
 ***************************************************************************/            
     
as           
begin    
    
declare @idx   as int    
declare @found as bit    
set @idx  = 0    
set @found = 0    
set @idx = isnull(dbo.STRING_FIND(@pattern,@inputString),0)     
if @idx > 0     
  set @found = 1    
else    
  set @found = 0    
return @found    
    
end    
GO
