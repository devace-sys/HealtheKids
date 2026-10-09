USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CONST_STANDARD_BUDGET_TARGET_PER_PATIENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CONST_STANDARD_BUDGET_TARGET_PER_PATIENT
GO
/*-------------------------------
 * Object Definition
 * "Old" Group Type
 * Note: This is depreciated
 * TODO: Refactor out
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CONST_STANDARD_BUDGET_TARGET_PER_PATIENT]() RETURNS int WITH SCHEMABINDING AS BEGIN RETURN 500 END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT execute ON  [dbo].[CONST_STANDARD_BUDGET_TARGET_PER_PATIENT] TO [webuser]
GO
 
