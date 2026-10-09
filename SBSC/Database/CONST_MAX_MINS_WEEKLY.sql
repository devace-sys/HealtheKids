USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MAX_MINS_WEEKLY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MAX_MINS_WEEKLY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_MAX_MINS_WEEKLY]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 9800 END    
GO
