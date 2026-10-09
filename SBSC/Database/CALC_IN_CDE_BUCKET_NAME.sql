USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_IN_CDE_BUCKET_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_IN_CDE_BUCKET_NAME
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CALC_IN_CDE_BUCKET_NAME (@inCDEBucketC bit, @inCDEBucketB bit, @inCDEBucketA bit) 
RETURNS varchar(10)
WITH SCHEMABINDING
AS     
BEGIN 
  if (@inCDEBucketC = 1) return 'C'
  if (@inCDEBucketB = 1) return 'B'
  if (@inCDEBucketA = 1) return 'A'
return ''
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_IN_CDE_BUCKET_NAME] TO [webuser]
GO