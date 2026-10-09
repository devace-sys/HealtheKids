USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_SUB') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_SUB
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STRING_SUB] (@pattern     varchar(8000),     
                                    @inputString varchar(8000),
                                    @trimInput   bit,
                                    @trimOutput  bit)    
returns varchar(8000)    
with schemabinding 
    
/***************************************************************************    
 * STRING_SUB */    
/**    
 * Locates pattern in input string and returns the substring to the left of
 * the pattern.
 *    
 * @param   pattern         Pattern to use    
 * @param   inputString     String to search 
 * @param   trimInput       Remove leading/trailing spaces from inputString   
 * @param   trimInput       Remove leading/trailing spaces from output
 * @return  string or null
 ***************************************************************************/            
     
as           
begin    

declare @idx  as int   
declare @out  as varchar(8000)

/*-------------------------------    
 * If the pattern or input string
 * are null get out    
 *------------------------------*/    
    
if (@pattern     is null) return null
if (@inputstring is null) return null
   
/*-------------------------------    
 * Trim input string if requested
 *------------------------------*/   
 
if (@trimInput = 1) set @inputString = ltrim(rtrim(@inputString))

/*-------------------------------    
 * Locate pattern in input string    
 *------------------------------*/    
    
set @idx = 0    
set @idx = (charindex(@pattern,@inputString) -1)

/*-------------------------------    
 * If it is not found get out
 *------------------------------*/    
 
if @idx < 0 return null

/*-------------------------------    
 * Retrieve substring left of
 * pattern
 *------------------------------*/    

set @out = left(@inputString,@idx)

/*-------------------------------    
 * Trim output string if requested
 *------------------------------*/   

if (@trimOutput = 1) set @out = ltrim(rtrim(@out))

return @out    
end    
    
GO
