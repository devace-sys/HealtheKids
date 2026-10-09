USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONERS_ASSIGN_USER') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONERS_ASSIGN_USER
GO

/* TODO: Remove when this has gone to production */
