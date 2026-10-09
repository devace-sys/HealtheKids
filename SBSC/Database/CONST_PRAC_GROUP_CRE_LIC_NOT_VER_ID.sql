USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PRAC_GROUP_CRE_LIC_NOT_VER_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PRAC_GROUP_CRE_LIC_NOT_VER_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_PRAC_GROUP_CRE_LIC_NOT_VER_ID]() RETURNS smallint WITH SCHEMABINDING 
AS BEGIN RETURN 154 END    
GO
