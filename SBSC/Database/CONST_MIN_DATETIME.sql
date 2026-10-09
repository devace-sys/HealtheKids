USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MIN_DATETIME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MIN_DATETIME
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[CONST_MIN_DATETIME]() RETURNS DATETIME WITH SCHEMABINDING  
AS     
BEGIN     
-- http://www.megasolutions.net/Sqlserver/DATETIME-Min-value-constant-36165.aspx    
RETURN CONVERT(DATETIME,0)    
END    
GO
