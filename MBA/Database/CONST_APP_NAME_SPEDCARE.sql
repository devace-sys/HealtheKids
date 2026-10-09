USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_APP_NAME_SPEDCARE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_APP_NAME_SPEDCARE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_APP_NAME_SPEDCARE]() RETURNS varchar(50) WITH SCHEMABINDING
AS BEGIN RETURN 'spedcare' END    
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CONST_APP_NAME_SPEDCARE] TO [webuser]
GO
