USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_AGE_CURRENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_AGE_CURRENT
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[CALC_AGE_CURRENT](@startDate DATETIME) RETURNS INT AS     
BEGIN    
  IF @startDate IS NULL RETURN 0    
  DECLARE @refDate AS DATETIME    
  SET @refDate = GETDATE()    
  RETURN dbo.CALC_AGE(@startDate,@refDate)    
END  
GO
