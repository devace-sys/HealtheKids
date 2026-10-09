USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATES_HAVE_OVERLAP') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATES_HAVE_OVERLAP
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[DATES_HAVE_OVERLAP] (  
    @startA AS DATETIME
  , @endA   AS DATETIME
  , @startB AS DATETIME
  , @endB   AS DATETIME
  , @checkForNullInputs           as bit = 0
  , @valueToReturnIfInputsAreNull as bit = null
  , @removeTimeComponents         as bit = 0
) 

RETURNS BIT 
WITH SCHEMABINDING 
AS     
BEGIN    
  if (@checkForNullInputs = 1)
  begin
    if (@startA is null) return @valueToReturnIfInputsAreNull
    if (@endA   is null) return @valueToReturnIfInputsAreNull
    if (@startB is null) return @valueToReturnIfInputsAreNull
    if (@endB   is null) return @valueToReturnIfInputsAreNull
  end

  if (@removeTimeComponents = 1)
  begin
    set @startA = convert(date,@startA)
	set @endA   = convert(date,@endA)
	set @startB = convert(date,@startB)
	set @endB   = convert(date,@endB)
  end

  /* (StartA <= EndB) and (EndA >= StartB) */
  
  if ((@startA <= @endB) and (@endA >= @startB)) return 1
  return 0
  
END    
    
GO
