USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_SUPERVISORS_VIEW_CURRENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_TO_APPROVE_BY_PRAC_SUPERVISORS_VIEW_CURRENT
GO

/* TODO: Remove when cleanup complete */