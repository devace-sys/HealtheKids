USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_DATE_FMT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_DATE_FMT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_DATE_FMT](@datetimein as datetime) 
RETURNS VARCHAR(50) 
WITH SCHEMABINDING 
AS     
BEGIN    
  
  if (@datetimein is null) return ''
  
  declare @dateout as varchar(50)      
  set @dateout = convert(varchar(2),datepart(month,@datetimein)) + '/' +    
  convert(varchar(2),datepart(day, @datetimein)) + '/' +    
  convert(varchar(4),datepart(year,@datetimein))    
  return @dateout    
END  
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT EXECUTE ON  [dbo].[RPT_DATE_FMT] TO [webuser]
GO
