USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_IN_CDE_BUCKET_C') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_IN_CDE_BUCKET_C
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CALC_IN_CDE_BUCKET_C (@pctExpectedApplicable int) 
RETURNS BIT
WITH SCHEMABINDING
AS     
BEGIN 
  /*If percentage is less than 90 */
  if (@pctExpectedApplicable is null) return null
  return convert(bit,(iif((@pctExpectedApplicable < 90),1,0)))
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_IN_CDE_BUCKET_C] TO [webuser]
GO