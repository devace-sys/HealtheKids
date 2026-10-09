USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ORP_DOCUMENT_AUTHORIZATION_REQ_RSP_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ORP_DOCUMENT_AUTHORIZATION_REQ_RSP_SAVE
GO

