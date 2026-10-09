USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PATIENT_PLACE_TYPE_HOME_PRIMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PATIENT_PLACE_TYPE_HOME_PRIMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_PATIENT_PLACE_TYPE_HOME_PRIMARY]() RETURNS bigint WITH SCHEMABINDING 
AS BEGIN RETURN 1 END    
GO
