USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_IS_IN_FY_QTR') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_IS_IN_FY_QTR
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[DATE_IS_IN_FY_QTR] (@dateIn DATETIME, @fyStartMonth INT, @qtrIn INT, @fyIn VARCHAR(9)) 
RETURNS BIT 
AS
BEGIN
    
/*-------------------------------
 * Check Inputs
 *------------------------------*/

if (@qtrIn is null) return null
if (@fyIn is null) return null
if (@qtrIn < 0) or (@qtrIn > 4) return null

declare @itIs as bit
set @itIs = 0

select 
   @itIs = case (count(number)) when 1 then 1 else 0 end 
from 
  DATE_IN_WHAT_FY(@dateIn,@fyStartMonth) 
where 
  (year12 = @fyIn and [quarter] = @qtrIn)
  
return @itIs

end 
GO
