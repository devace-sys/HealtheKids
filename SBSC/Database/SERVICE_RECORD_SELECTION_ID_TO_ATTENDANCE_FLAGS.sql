USE SPEDMON
GO

/*-------------------------------
 * TODO: Remove once run
 * this is for cleanup only
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_SELECTION_ID_TO_ATTENDANCE_FLAGS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_SELECTION_ID_TO_ATTENDANCE_FLAGS
GO


GO