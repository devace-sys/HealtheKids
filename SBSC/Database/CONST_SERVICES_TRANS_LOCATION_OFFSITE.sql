USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_SERVICES_TRANS_LOCATION_OFFSITE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_SERVICES_TRANS_LOCATION_OFFSITE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_SERVICES_TRANS_LOCATION_OFFSITE]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 3 END    
GO
