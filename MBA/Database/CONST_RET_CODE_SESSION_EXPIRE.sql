USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_RET_CODE_SESSION_EXPIRE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_RET_CODE_SESSION_EXPIRE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_RET_CODE_SESSION_EXPIRE]() RETURNS int WITH SCHEMABINDING AS
BEGIN RETURN 12 END
GO
