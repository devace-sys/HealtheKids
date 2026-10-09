USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SERVICES_TMT_EXP_MINS_FROM_ENTRY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SERVICES_TMT_EXP_MINS_FROM_ENTRY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_SERVICES_TMT_EXP_MINS_FROM_ENTRY]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 1 END    
GO
