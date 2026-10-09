USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SERVICES_TRANSPORT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SERVICES_TRANSPORT
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[CONST_SERVICES_TRANSPORT]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 3 END    
GO
