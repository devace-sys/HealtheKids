/* TODO: Remove from install.sql and remove this file once this has been run in production */

USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_SPED_SERVICES_PAT_ABSENT_STATS_DETAILS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_SPED_SERVICES_PAT_ABSENT_STATS_DETAILS_VIEW_CORE
GO

