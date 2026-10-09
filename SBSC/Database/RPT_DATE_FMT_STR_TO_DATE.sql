USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_DATE_FMT_STR_TO_DATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_DATE_FMT_STR_TO_DATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_DATE_FMT_STR_TO_DATE](@value as varchar(50))
RETURNS date
WITH SCHEMABINDING 
AS     
BEGIN    
  set @value = trim(isnull(@value,''))
  if (@value = '') return null
  return convert(date,@value)
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_DATE_FMT_STR_TO_DATE] TO [webuser]
GO
