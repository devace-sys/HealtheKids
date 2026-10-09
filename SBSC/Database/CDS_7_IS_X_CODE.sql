USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CDS_7_IS_X_CODE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CDS_7_IS_X_CODE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CDS_7_IS_X_CODE] (@cds7 as nchar(7))     
RETURNS bit
WITH SCHEMABINDING 
AS 
BEGIN
  if (left(trim(lower(isnull(@cds7,N''))),1) = N'x') return 1
  return 0
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[CDS_7_IS_X_CODE] TO [webuser]
GO

