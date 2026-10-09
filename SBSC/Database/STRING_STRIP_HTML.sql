USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_STRIP_HTML') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_STRIP_HTML
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Based on https://blog.sqlauthority.com/2007/06/16/sql-server-udf-user-defined-function-to-strip-html-parse-html-no-regular-expression/ */

CREATE FUNCTION [dbo].[STRING_STRIP_HTML] (
  @HTMLText VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
  DECLARE @Start  INT
  DECLARE @End    INT
  DECLARE @Length INT

  SET @Start  = CHARINDEX('<',@HTMLText) 
  SET @End    = CHARINDEX('>',@HTMLText,CHARINDEX('<',@HTMLText)) 
  SET @Length = (@End - @Start) + 1 
  
  WHILE ((@Start > 0) AND (@End > 0) AND (@Length > 0))
  BEGIN
    SET @HTMLText = STUFF (@HTMLText,@Start,@Length,'')
    SET @Start    = CHARINDEX('<',@HTMLText) 
    SET @End      = CHARINDEX('>',@HTMLText,CHARINDEX('<',@HTMLText))
    SET @Length   = (@End - @Start) + 1
  END
  
  set @HTMLText = dbo.STRING_UNESCAPE_HTML (@HTMLText)
  
  return TRIM(@HTMLText)
END

GO
