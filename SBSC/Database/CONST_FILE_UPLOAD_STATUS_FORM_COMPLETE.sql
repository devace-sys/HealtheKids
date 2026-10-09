USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_FILE_UPLOAD_STATUS_FORM_COMPLETE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_FILE_UPLOAD_STATUS_FORM_COMPLETE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_FILE_UPLOAD_STATUS_FORM_COMPLETE]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 120 END    
GO
