USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES]() RETURNS CHAR(2) WITH SCHEMABINDING 
AS BEGIN RETURN 'E' END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES] TO [webuser]
GO