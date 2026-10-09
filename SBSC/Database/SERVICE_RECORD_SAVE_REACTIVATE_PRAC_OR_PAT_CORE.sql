USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 * TODO: Remove this file once
 * cleanup is done.
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_SAVE_REACTIVATE_PRAC_OR_PAT_CORE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_SAVE_REACTIVATE_PRAC_OR_PAT_CORE
GO


