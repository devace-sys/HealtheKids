USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_TIME_UNIT_MIN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_TIME_UNIT_MIN
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
/* 1 unit is 15 minutes */    
CREATE FUNCTION [dbo].[CONST_TIME_UNIT_MIN]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 15 END    
GO
