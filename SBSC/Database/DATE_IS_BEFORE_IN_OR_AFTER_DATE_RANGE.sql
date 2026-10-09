USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_IS_BEFORE_IN_OR_AFTER_DATE_RANGE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_IS_BEFORE_IN_OR_AFTER_DATE_RANGE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[DATE_IS_BEFORE_IN_OR_AFTER_DATE_RANGE] (
    @startDate DATE
  , @endDate   DATE
  , @refDate   DATE )
 
RETURNS SMALLINT /* -1 After range (Past), 0 = In Range (current), 1= Before range (future) */
WITH SCHEMABINDING 
AS     
BEGIN    
  if (@refDate   is null)    return null
  if (@startDate is null)    return null
  if (@endDate   is null)    return null
  if (@startDate > @endDate) return null
  
  if ((@refDate < @startDate) and (@refDate < @endDate)) return 1  /* Before date range.  Date range represents future. */
  if ((@refDate > @startDate) and (@refDate > @endDate)) return -1 /* After date range.  Date range represents past.  */
  if ((@refDate between @startDate and @endDate))        return 0  /* Within (in) date range.*/
  return null
END    
GO
