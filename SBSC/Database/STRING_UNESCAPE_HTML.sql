USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRING_UNESCAPE_HTML') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRING_UNESCAPE_HTML
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[STRING_UNESCAPE_HTML](  @escapedHTMLStrIn  varchar(max) = null ) 
RETURNS varchar(max) 
with schemabinding 
AS    
BEGIN    
  declare @htmlStrOut as varchar(max) = null

  set @htmlStrOut = trim(isnull(@escapedHTMLStrIn,''))
  
  if (@htmlStrOut = '') 
  begin
    return null
  end

  /* Basic 5 cases */
  
  set @htmlStrOut = REPLACE (@htmlStrOut,'&quot;' ,'"')
  set @htmlStrOut = REPLACE (@htmlStrOut,'&apos;' ,'''')
  set @htmlStrOut = REPLACE (@htmlStrOut,'&amp;'  ,'&')
  set @htmlStrOut = REPLACE (@htmlStrOut,'&lt;'   ,'<')
  set @htmlStrOut = REPLACE (@htmlStrOut,'&gt;'   ,'>')
  
  /* Space */
  
  set @htmlStrOut = REPLACE (@htmlStrOut,'&nbsp;',' ')  
  
  /* TODO: Add more cases as needed */

  return @htmlStrOut


     
END    
GO
