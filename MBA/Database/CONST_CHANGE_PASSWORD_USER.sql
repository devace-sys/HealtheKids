USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_CHANGE_PASSWORD_USER') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_CHANGE_PASSWORD_USER
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_CHANGE_PASSWORD_USER]() RETURNS int WITH SCHEMABINDING AS 
BEGIN RETURN 1 END
GO
