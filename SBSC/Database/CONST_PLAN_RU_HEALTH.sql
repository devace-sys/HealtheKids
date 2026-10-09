USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PLAN_RU_HEALTH') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PLAN_RU_HEALTH
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_PLAN_RU_HEALTH]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 5 END    
GO
