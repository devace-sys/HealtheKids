USE SPEDMON
GO
 
/* ################################### This routine is depreciated TODO: Remove when no longer needed for sanity/comparision checks #####################*/

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_WITH_RESPECT_TO_PLAN_DATES_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_WITH_RESPECT_TO_PLAN_DATES_VIEW_DATA_CORE
GO
 
