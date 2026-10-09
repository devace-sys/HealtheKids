USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_FILE_UPLOAD_STATUS_DATA_FORM_CANCEL_OR_RESET') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_FILE_UPLOAD_STATUS_DATA_FORM_CANCEL_OR_RESET
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_FILE_UPLOAD_STATUS_DATA_FORM_CANCEL_OR_RESET]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 110 END    
GO
