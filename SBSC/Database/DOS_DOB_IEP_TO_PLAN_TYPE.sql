USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DOS_DOB_IEP_TO_PLAN_TYPE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DOS_DOB_IEP_TO_PLAN_TYPE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[DOS_DOB_IEP_TO_PLAN_TYPE](@dos DATETIME, @dob DATETIME, @iep BIT) RETURNS INT AS     
BEGIN    
  DECLARE @age AS INT    
  SET @age = dbo.CALC_AGE(@dob,@dos)    
  RETURN dbo.AGE_IEP_TO_PLAN_TYPE(@age,@iep)    
END    
GO
