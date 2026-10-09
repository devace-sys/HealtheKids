USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_GET_PREVIOUS_WEEKDAY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_GET_PREVIOUS_WEEKDAY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[DATE_GET_PREVIOUS_WEEKDAY] (
   @refDate datetime
 , @weekDay int /* 1= Monday to 7=Sunday */
) 
RETURNS DATETIME
WITH SCHEMABINDING 
 AS     
BEGIN    
  if (@weekDay not between 1 and 7) return null
  set @refDate = isnull(@refDate,getdate())
  /* Calculation with respect to @@DateFirst courtesey of https://stackoverflow.com/a/37965196 */
  return DATEADD(dd, ((DATEPART(dw,@refDate) + @@DateFirst - @weekDay + 13) % 7) * -1, @refDate)
end    
GO
