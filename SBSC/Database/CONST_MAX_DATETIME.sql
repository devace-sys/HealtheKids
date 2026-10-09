USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MAX_DATETIME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MAX_DATETIME
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[CONST_MAX_DATETIME]() RETURNS DATETIME WITH SCHEMABINDING  
AS     
BEGIN     
-- http://sqlserverplanet.com/tsql/max-date-value
RETURN CONVERT(DATETIME,'9999-12-31 23:59:59.997')
END    
GO
