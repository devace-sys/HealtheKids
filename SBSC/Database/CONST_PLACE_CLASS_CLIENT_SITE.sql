USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PLACE_CLASS_CLIENT_SITE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PLACE_CLASS_CLIENT_SITE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_PLACE_CLASS_CLIENT_SITE]() RETURNS bigint WITH SCHEMABINDING 
AS BEGIN RETURN 100 END    
GO
