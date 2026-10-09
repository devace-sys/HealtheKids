USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOADS_PROCESSING_UPDATE_STATUS_MAN') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.FILE_UPLOADS_PROCESSING_UPDATE_STATUS_MAN
GO

