USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_USER_RANK_MIN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_USER_RANK_MIN
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_USER_RANK_MIN]() RETURNS int WITH SCHEMABINDING AS
BEGIN RETURN 1 END

GO
/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CONST_USER_RANK_MIN] TO [webuser]
GO
