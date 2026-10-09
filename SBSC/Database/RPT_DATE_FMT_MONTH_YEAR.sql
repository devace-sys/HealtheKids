USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_DATE_FMT_MONTH_YEAR') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_DATE_FMT_MONTH_YEAR
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_DATE_FMT_MONTH_YEAR](@datetimein as datetime,@useCrLF bit = 0) 
RETURNS VARCHAR(50) 
WITH SCHEMABINDING 
AS     
BEGIN    
  
  if (@datetimein is null) return ''
  declare @sep as varchar(10) = ' '
  if (@useCrLF = 1) set @sep = char(13)+char(10)
  declare @dateout as varchar(50)      
  set @dateout = datename(month, @datetimein) + @sep + datename(year, @datetimein)    
  return @dateout    
END  
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT EXECUTE ON  [dbo].[RPT_DATE_FMT_MONTH_YEAR] TO [webuser]
GO
