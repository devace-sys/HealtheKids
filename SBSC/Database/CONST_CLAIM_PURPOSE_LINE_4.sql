USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_CLAIM_PURPOSE_LINE_4') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_CLAIM_PURPOSE_LINE_4
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_CLAIM_PURPOSE_LINE_4]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 4 END    
GO
