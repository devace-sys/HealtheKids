USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TIME_HH_MM_ONLY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TIME_HH_MM_ONLY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[TIME_HH_MM_ONLY](@value as time(0)) 
RETURNS time(0) 
WITH SCHEMABINDING
AS     
BEGIN 

if (@value is null) return null

declare @valueOut as time(0)   
declare @hh       as int = datepart (hour,   @value)
declare @mm       as int = datepart (minute, @value)

set @valueOut = timefromparts(@hh,@mm,0,0,0)

return @valueOut
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TIME_HH_MM_ONLY] TO [webuser]
GO
