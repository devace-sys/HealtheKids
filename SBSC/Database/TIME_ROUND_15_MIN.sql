USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TIME_ROUND_15_MIN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TIME_ROUND_15_MIN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[TIME_ROUND_15_MIN](@timeVal as time, @mode as smallint) RETURNS time(0)
AS 
BEGIN 
  
  /* https://mitch-wheat.blogspot.com.au/2011/02/tsql-round-to-nearest-15-minute.html */
  
  declare @timeIn  as time(0) = @timeVal
  declare @timeOut as time(0) = null
  
  --if (@timeIn is null) set @timeIn = getdate()
  if (@timeIn is null) return null
  
  if (@mode   is null) set @mode = 1
  
  /* Round to nearest 15 minute interval */
  
  if (@mode = 1) 
    set @timeOut = convert (time(0), (dateadd(n,((DATEDIFF(n, cast(0 as DateTime), @timeIn) + 7)/ 15) * 15, cast(0 as DateTime))))
  
  /* Round down to nearest 15 minute interval */

  if (@mode = 2) 
    set @timeOut = convert (time(0), dateadd(n,(DATEDIFF(n, cast(0 as DateTime), @timeIn)/ 15) * 15, cast(0 as DateTime)))
  
  return @timeOut
  
END    
GO
