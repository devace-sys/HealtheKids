USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DATE_IS_PAST') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DATE_IS_PAST
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[DATE_IS_PAST](@startDate DATETIME, @refDate DATETIME) 
RETURNS BIT 
WITH SCHEMABINDING 
AS     
BEGIN    
  IF @startDate IS NULL RETURN 0    
  IF @refDate IS NULL RETURN 0      
  DECLARE @age AS INT    
  SET @age = DATEDIFF(day,@startDate,@refDate)     
  IF @age < 0 RETURN 1    
  RETURN 0    
END    
GO
