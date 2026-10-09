USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SVC_REC_STATE_HOLD') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SVC_REC_STATE_HOLD
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[CONST_SVC_REC_STATE_HOLD]() RETURNS smallint WITH SCHEMABINDING 
AS BEGIN RETURN 15 END    
GO
