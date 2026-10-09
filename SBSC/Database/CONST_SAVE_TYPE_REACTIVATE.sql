USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SAVE_TYPE_REACTIVATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SAVE_TYPE_REACTIVATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_SAVE_TYPE_REACTIVATE]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 6 END    
GO
