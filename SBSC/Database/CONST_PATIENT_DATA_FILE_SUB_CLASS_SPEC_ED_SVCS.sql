USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS]() RETURNS varchar(256) WITH SCHEMABINDING 
AS BEGIN RETURN 'SpEdPOP' END    
GO
