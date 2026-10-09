USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_KIOSK') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISITS_CHECK_IN_FROM_KIOSK
GO
