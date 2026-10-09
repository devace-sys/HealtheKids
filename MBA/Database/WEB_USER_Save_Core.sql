USE [users]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.WEB_USER_Save_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.WEB_USER_Save_Core
GO

