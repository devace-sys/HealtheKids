USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE
GO

/* TODO: Remove when all systems have been updated */