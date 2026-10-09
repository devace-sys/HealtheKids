USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_TIME_FMT_HH_MM_SS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_TIME_FMT_HH_MM_SS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_TIME_FMT_HH_MM_SS](@timein as time, @includeSeconds as bit) 
RETURNS VARCHAR(20) 
WITH SCHEMABINDING 
AS     
BEGIN    
  
  declare @strOut as varchar(20)

  if (@timein         is null) return ''
  if (@includeSeconds is null) set @includeSeconds = 0
  set @strOut = convert(varchar,@timein,108)
  if (@includeSeconds = 0) set @strOut = left(@strOut,5) -- xx:xx
  return @strOut
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_TIME_FMT_HH_MM_SS] TO [webuser]
GO
