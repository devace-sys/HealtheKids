USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_UNESCAPE_JSON') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_UNESCAPE_JSON
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

 CREATE FUNCTION [dbo].[STRING_UNESCAPE_JSON](  @escapedJSONStrIn   nvarchar(max) = null
                                              , @stripFirstLastChar bit = 0) 
RETURNS nvarchar(max) 
with schemabinding 
AS    
BEGIN    
  declare @jsonStrOut    as nvarchar(max) = null
  declare @jsonStrOutLen as int           = 0

  set @jsonStrOut = trim(isnull(@escapedJSONStrIn,N''))
  set @jsonStrOutLen = len(@jsonStrOut)
  
  if (@jsonStrOutLen = 0) 
  begin
    return null
  end

  set @jsonStrOut = replace(@jsonStrOut,N'\"',N'"') --Quotation mark (") 	\"
  set @jsonStrOut = replace(@jsonStrOut,N'\\',N'\') -- Reverse solidus (\) 	\\
  set @jsonStrOut = replace(@jsonStrOut,N'\/',N'/') -- Solidus (/) 	\/
  
  if (@stripFirstLastChar = 1)
  begin
    set @jsonStrOutLen = len(@jsonStrOut)
    if (@jsonStrOutLen >= 3)
	begin  
	  set @jsonStrOut = SUBSTRING(@jsonStrOut,2,(len(@jsonStrOut)-1))
    end
  end
  
  return @jsonStrOut

/*TODO :Implement these if needed*/
/*
Backspace 	\b
Form feed 	\f
New line 	\n
Carriage return 	\r
Horizontal tab 	\t
Return Types
Control character 	Encoded sequence
CHAR(0) 	\u0000
CHAR(1) 	\u0001
... 	...
CHAR(31) 	\u001f
*/

     
END    
GO
