USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_CHANGE_PASSWORD_PUBLIC') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_CHANGE_PASSWORD_PUBLIC
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_CHANGE_PASSWORD_PUBLIC]() RETURNS int WITH SCHEMABINDING AS 
BEGIN RETURN 3 END
GO
