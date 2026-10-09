USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP]() RETURNS varchar(256) WITH SCHEMABINDING 
AS BEGIN RETURN 'TOTPOP' END    
GO
