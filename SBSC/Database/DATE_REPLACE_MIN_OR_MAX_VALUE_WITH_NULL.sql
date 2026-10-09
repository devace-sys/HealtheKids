USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL (
    @valueIn datetime
  , @minYear int = 1988
  , @maxYear int = 2100
)
RETURNS DATETIME 
AS     
BEGIN    
  /* Check for null */

  if (@valueIn is null) return null
  
  /* Check common default values for "null" values for dates */
  
  if (@valueIn = dbo.CONST_MIN_DATETIME_1900_01_01())  return null
  if (@valueIn = dbo.CONST_MIN_DATETIME_GREGORIAN())   return null
  if (@valueIn = dbo.CONST_MIN_DATETIME())             return null
  if (@valueIn = dbo.CONST_MIN_DATETIME_TER())         return null
  if (@valueIn = dbo.CONST_MAX_DATETIME())             return null

  /* What is the smallest year allowed in @value before its considered a min/max */

  if (DATEPART(year,@valueIn) <= @minYear) return null /* Oldest reasonable possible date expected */
  
  /* What is the largest year allowed in @valueIn before its considered a min/max */
  
  if (DATEPART(year,@valueIn) >= @maxYear) return null 
  
  return @valueIn
END       
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXEC ON [dbo].[DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL] TO [webuser]
GO
