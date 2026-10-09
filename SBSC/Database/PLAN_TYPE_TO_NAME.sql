USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_TYPE_TO_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PLAN_TYPE_TO_NAME
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[PLAN_TYPE_TO_NAME](@plan_type INT) RETURNS nvarchar(50) AS    
BEGIN    
  DECLARE @plan_name AS NVARCHAR(50)    
  SELECT @plan_name = CASE     
    WHEN @plan_type = dbo.CONST_PLAN_IFSP()      THEN N'IFSP'    
    WHEN @plan_type = dbo.CONST_PLAN_IEP()       THEN N'IEP'    
    WHEN @plan_type = dbo.CONST_PLAN_NONE()      THEN N'None'     
	WHEN @plan_type = dbo.CONST_PLAN_CYBHI()     THEN N'CYBHI'
    WHEN @plan_type = dbo.CONST_PLAN_RU_HEALTH() THEN N'RU Health'
  END    
  RETURN @plan_name     
END    
GO
