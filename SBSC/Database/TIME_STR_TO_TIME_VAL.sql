USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TIME_STR_TO_TIME_VAL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TIME_STR_TO_TIME_VAL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[TIME_STR_TO_TIME_VAL](@timeStr as varchar(50)) 
RETURNS time(0) 
WITH SCHEMABINDING
AS     
BEGIN    
  declare @timeOut as time(0) = null  
  if (@timeStr is null) return null
  set @timeStr = ltrim(rtrim(@timeStr))
  if (@timeStr = '') return null
  if (isdate(@timeStr) = 1)
    set @timeOut = convert(time(0),@timeStr)
  else
    return null
  return @timeOut  
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TIME_STR_TO_TIME_VAL] TO [webuser]
GO
