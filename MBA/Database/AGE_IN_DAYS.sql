USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.AGE_IN_DAYS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.AGE_IN_DAYS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[AGE_IN_DAYS](@startDate DATETIME, @refDate DATETIME) 
RETURNS INT
WITH SCHEMABINDING 
AS     
BEGIN    
  
  DECLARE @age AS INT    
    
  IF @refDate   IS NULL SET @refDate = GETDATE()    
  IF @startDate IS NULL RETURN null      

  SET @age = 0
  SET @age = DATEDIFF(day,@startDate,@refDate)     
  
  RETURN @age
END    
GO
