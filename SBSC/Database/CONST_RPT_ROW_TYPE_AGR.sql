USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_RPT_ROW_TYPE_AGR') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_RPT_ROW_TYPE_AGR
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_RPT_ROW_TYPE_AGR]() RETURNS smallint WITH SCHEMABINDING 
AS BEGIN RETURN 2 END    
GO
