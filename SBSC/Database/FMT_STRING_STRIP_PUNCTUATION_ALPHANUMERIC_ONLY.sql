use spedmon
go

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FMT_STRING_STRIP_PUNCTUATION_ALPHANUMERIC_ONLY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FMT_STRING_STRIP_PUNCTUATION_ALPHANUMERIC_ONLY
GO

-- general purpose utility function: strips out punctuation and whitespace from a string.
-- can optionally strip out numeric characters or leave them in place

CREATE FUNCTION [dbo].[FMT_STRING_STRIP_PUNCTUATION_ALPHANUMERIC_ONLY](
    @strIn          as varchar(max) = null
  , @includeNumeric as bit          = 1
) 
RETURNS varchar(max)

as begin

if (@strIn is null) return @strIn
declare  @len as int = LEN (@strIn);
if (@len = 0) return @strIn

declare @outStr as varchar(max) = ''

declare @iter_i as int = 1;
declare @char_i as char;
declare @ptrn   as varchar(50) = '[A-Za-z]'
if (@includeNumeric = 1) set @ptrn = '[A-Za-z0-9]'

while (@iter_i <= @len)
begin
  SELECT @char_i = SUBSTRING( @strIn ,  @iter_i ,  1 )
  SELECT  @outStr = @outStr + @char_i WHERE (@char_i like @ptrn)
  SET @iter_i += 1;
end

RETURN @outStr

END    

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[FMT_STRING_STRIP_PUNCTUATION_ALPHANUMERIC_ONLY] TO [webuser]
GO