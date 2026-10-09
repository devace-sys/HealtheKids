USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MSG_USER_NOT_FOUND') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MSG_USER_NOT_FOUND
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_MSG_USER_NOT_FOUND]() 
RETURNS VARCHAR(1000) WITH SCHEMABINDING 
AS 
BEGIN 
RETURN 'User record not found'
END    
GO