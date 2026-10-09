USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_CLAIM_STATUS_SUB_REJECT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_CLAIM_STATUS_SUB_REJECT
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
/* rounding starts at 7 for applicable services */    
CREATE FUNCTION [dbo].[CONST_CLAIM_STATUS_SUB_REJECT]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 4 END    
GO
