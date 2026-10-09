USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_DATE_FMT_YYYY_MM_DD') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_DATE_FMT_YYYY_MM_DD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_DATE_FMT_YYYY_MM_DD] (@dateValueIn as datetime) 
RETURNS VARCHAR(50) 
WITH SCHEMABINDING 
AS     
BEGIN    
  
  if (@dateValueIn is null) return ''  
  return convert(varchar, @dateValueIn, 23)
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_DATE_FMT_YYYY_MM_DD] TO [webuser]
GO
