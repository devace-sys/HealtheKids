USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PLACE_SOURCE_TYPE_MGMT_SCREEN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PLACE_SOURCE_TYPE_MGMT_SCREEN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_PLACE_SOURCE_TYPE_MGMT_SCREEN]() RETURNS bigint WITH SCHEMABINDING 
AS BEGIN RETURN 2 END    
GO
