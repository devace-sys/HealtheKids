USE Users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PERSONS_SOURCE_USERS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PERSONS_SOURCE_USERS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_PERSONS_SOURCE_USERS]() RETURNS int WITH SCHEMABINDING
AS BEGIN RETURN 2 END    
GO
