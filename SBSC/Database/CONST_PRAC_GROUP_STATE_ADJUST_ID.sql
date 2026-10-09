USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_PRAC_GROUP_STATE_ADJUST_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_PRAC_GROUP_STATE_ADJUST_ID
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[CONST_PRAC_GROUP_STATE_ADJUST_ID]() RETURNS smallint WITH SCHEMABINDING 
AS BEGIN RETURN 152 END    
GO
