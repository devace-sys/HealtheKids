USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 /*-------------------------------
 * NOTE: This is for cleanup purposes
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save_Batch_Caseload_For_Dos_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Save_Batch_Caseload_For_Dos_Save
GO