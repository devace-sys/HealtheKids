USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_VALUE_OR_REPLACEMENT_IF_GT_LT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_VALUE_OR_REPLACEMENT_IF_GT_LT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[DATE_VALUE_OR_REPLACEMENT_IF_GT_LT](
    @value            as date
  , @replacementValue as date
  , @gtlt             as int) 
RETURNS DATE 
WITH SCHEMABINDING
AS     
BEGIN    
  if (@value is null)            return null
  if (@replacementValue is null) return null
  if (@gtlt not in (-1,1))       return null

  if (@gtlt = 1)
  begin
    if (@value > @replacementValue) return @replacementValue
	return @value
  end
  else if (@gtlt = -1)
  begin
    if (@value < @replacementValue) return @replacementValue
	return @value
  end
  else 
  begin
    return null
  end
  return null
END    
    
GO
