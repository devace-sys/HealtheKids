USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_RET_CODE_PASSWORD_LOCK') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_RET_CODE_PASSWORD_LOCK
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_RET_CODE_PASSWORD_LOCK]() RETURNS int WITH SCHEMABINDING AS
BEGIN RETURN 14 END
GO
