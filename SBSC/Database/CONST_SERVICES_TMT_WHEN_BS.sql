USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SERVICES_TMT_WHEN_BS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SERVICES_TMT_WHEN_BS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_SERVICES_TMT_WHEN_BS]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 1 END    
GO
