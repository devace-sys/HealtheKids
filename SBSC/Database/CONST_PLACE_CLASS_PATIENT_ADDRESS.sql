USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PLACE_CLASS_PATIENT_ADDRESS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PLACE_CLASS_PATIENT_ADDRESS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_PLACE_CLASS_PATIENT_ADDRESS]() RETURNS bigint WITH SCHEMABINDING 
AS BEGIN RETURN 200 END    
GO
