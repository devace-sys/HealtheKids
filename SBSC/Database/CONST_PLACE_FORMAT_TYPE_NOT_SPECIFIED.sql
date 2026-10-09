USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PLACE_FORMAT_TYPE_NOT_SPECIFIED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PLACE_FORMAT_TYPE_NOT_SPECIFIED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_PLACE_FORMAT_TYPE_NOT_SPECIFIED]() RETURNS bigint WITH SCHEMABINDING 
AS BEGIN RETURN 1000 END    
GO
