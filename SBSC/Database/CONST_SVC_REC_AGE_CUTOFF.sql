USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('CONST_SVC_REC_AGE_CUTOFF') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION CONST_SVC_REC_AGE_CUTOFF
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_SVC_REC_AGE_CUTOFF]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 7 END    
GO
