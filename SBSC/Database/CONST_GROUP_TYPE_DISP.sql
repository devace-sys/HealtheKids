USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_GROUP_TYPE_DISP') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_GROUP_TYPE_DISP
GO
/*-------------------------------
 * Object Definition
 * "Old" Group Type
 * Note: This is depreciated
 * TODO: Refactor out
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CONST_GROUP_TYPE_DISP]() RETURNS int WITH SCHEMABINDING AS BEGIN RETURN 1 END    
GO
