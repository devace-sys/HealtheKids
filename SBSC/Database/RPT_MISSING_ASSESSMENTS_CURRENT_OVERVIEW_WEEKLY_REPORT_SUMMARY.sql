/* TODO: Remove when this has run everywhere it needs to run */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_MISSING_ASSESSMENTS_CURRENT_OVERVIEW_WEEKLY_REPORT_SUMMARY') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_MISSING_ASSESSMENTS_CURRENT_OVERVIEW_WEEKLY_REPORT_SUMMARY
GO

