USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_RPT_ROW_TYPE_DETAIL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_RPT_ROW_TYPE_DETAIL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CONST_RPT_ROW_TYPE_DETAIL]() RETURNS smallint WITH SCHEMABINDING 
AS BEGIN RETURN 1 END    
GO
