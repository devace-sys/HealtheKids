USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_FIND') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_FIND
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STRING_FIND] (@pattern     varchar(8000),     
                                     @inputString varchar(8000))    
returns int
with schemabinding     
    
/***************************************************************************    
 * STRING_FIND */    
/**    
 * Locates pattern in input string and returns its starting position or 0    
 *    
 * @param  pattern         Pattern to use    
 * @param  inputString     String to search    
 * @return                 > 0 if pattern was found    
 *                         0 if pattern was not found    
 *                         null if there was a problem    
 ***************************************************************************/            
     
as           
begin    
    
/*-------------------------------    
 * If the pattern is null get out    
 *------------------------------*/    
    
declare @tempPattern     as varchar(8000)    
declare @tempInputString as varchar(8000)    
declare @idx             as int    
    
if @pattern     is null return null    
if @inputString is null return null    
    
/*-------------------------------    
 * Clean up inputs    
 *------------------------------*/    
    
set @tempPattern     = lower(ltrim(rtrim(@pattern)))    
set @tempInputString = lower(ltrim(rtrim(@inputstring)))    
    
/*-------------------------------    
 * If any of the inputs are empty    
 * get out    
 *------------------------------*/    
    
if len(@tempPattern)     = 0 return null    
if len(@tempInputString) = 0 return null    
    
/*-------------------------------    
 * Locate pattern in input string    
 *------------------------------*/    
    
set @idx = 0    
set @idx = charindex(@pattern,@inputString)    
return @idx    
    
end    
    
GO
