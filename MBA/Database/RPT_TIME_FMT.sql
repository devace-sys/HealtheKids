USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_TIME_FMT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_TIME_FMT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_TIME_FMT](@timein as time, @includeSeconds as bit) 
RETURNS VARCHAR(20) 
WITH SCHEMABINDING 
AS     
BEGIN    
  if (@timein         is null) return ''
  if (@includeSeconds is null) set @includeSeconds = 0
  
  declare @timeOut as varchar(20)
  declare @timeStr as varchar(20)
   
  set @timeStr = convert(varchar(20),convert(time(0),@timeIn),22)
  
  if (@includeSeconds = 0)  
    set @timeOut = left(@timeStr,5) + ' ' + right(@timeStr,2)
  else
    set @timeOut = @timeStr
    
  return @timeOut  

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_TIME_FMT] TO [webuser]
GO
