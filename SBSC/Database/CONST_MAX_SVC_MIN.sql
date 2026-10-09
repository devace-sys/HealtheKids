USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_MAX_SVC_MIN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_MAX_SVC_MIN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Max daily minutes for most services with minutes is 120 minutes */    

CREATE FUNCTION [dbo].[CONST_MAX_SVC_MIN]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 120 END    
GO
