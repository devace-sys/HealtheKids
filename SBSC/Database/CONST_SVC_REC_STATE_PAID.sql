USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SVC_REC_STATE_PAID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SVC_REC_STATE_PAID
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
/* rounding starts at 7 for applicable services */    
CREATE FUNCTION [dbo].[CONST_SVC_REC_STATE_PAID]() RETURNS smallint WITH SCHEMABINDING 
AS BEGIN RETURN 40 END    
GO
