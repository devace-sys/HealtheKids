USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_IN_CDE_BUCKET_A') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_IN_CDE_BUCKET_A
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CALC_IN_CDE_BUCKET_A (@pctExpectedApplicable int) 
RETURNS BIT
WITH SCHEMABINDING
AS     
BEGIN 
  /*If percentage is 95 or higher*/
  if (@pctExpectedApplicable is null) return null
  return convert(bit,(iif((@pctExpectedApplicable >= 95),1,0)))
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_IN_CDE_BUCKET_A] TO [webuser]
GO