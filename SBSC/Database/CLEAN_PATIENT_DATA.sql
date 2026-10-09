USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLEAN_PATIENT_DATA') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLEAN_PATIENT_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLEAN_PATIENT_DATA]
AS
BEGIN   
  RAISERROR ('Cleaning patient data', 0, 1) WITH NOWAIT
  EXEC dbo.CLEAN_PATIENT_DATA_NAMES
  EXEC dbo.CLEAN_PATIENT_DATA_CSIS_SSID
  EXEC dbo.CLEAN_PATIENT_DHCS_NAMES
  RETURN(0)
END 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLEAN_PATIENT_DATA] TO [webuser]
GO
