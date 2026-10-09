/* TODO: This is depcacated.  Remove.  */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLEAN_PATIENT_CASELOAD_AND_GROUP_DATA') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLEAN_PATIENT_CASELOAD_AND_GROUP_DATA
GO

