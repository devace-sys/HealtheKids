USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_RET_CRIT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_RET_CRIT
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
/* Create new functions */    
    
CREATE FUNCTION [dbo].[CONST_RET_CRIT]() RETURNS int WITH SCHEMABINDING 
AS BEGIN RETURN 3 END    
GO
