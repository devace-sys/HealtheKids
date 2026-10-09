USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_CLAIM_PURPOSE_CORRECTION') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_CLAIM_PURPOSE_CORRECTION
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CONST_CLAIM_PURPOSE_CORRECTION]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 3 END    
GO
