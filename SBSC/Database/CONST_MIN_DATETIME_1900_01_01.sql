USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MIN_DATETIME_1900_01_01') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MIN_DATETIME_1900_01_01
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[CONST_MIN_DATETIME_1900_01_01]() RETURNS DATETIME WITH SCHEMABINDING  
AS     
BEGIN     
RETURN CONVERT(DATETIME,'1/1/1900')    
END    
GO
