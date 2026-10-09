USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_AGE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_AGE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[CALC_AGE](@startDate DATETIME, @refDate DATETIME) RETURNS INT 
WITH SCHEMABINDING
AS     
BEGIN    
     
  DECLARE @age AS INT    
    
  /*-------------------------------    
   * Age calculation method based    
   * on a solution posted on    
   * http://www.sqlhacks.com/Dates/Person-Age    
   * This solution takes care of    
   * the DATEDIFF() year calculation    
   * issues and also takes care of    
   * leap year cases.    
   *------------------------------*/    
  
  IF @startDate IS NULL RETURN 0    
  IF @refDate   IS NULL RETURN 0    
    
  IF (DATEADD(YEAR, DATEDIFF (YEAR, @startDate, @refDate), @startDate) > @refDate)    
    SET @age = DATEDIFF(YEAR, @startDate, @refDate) - 1    
  ELSE    
    SET @age = DATEDIFF(YEAR, @startDate, @refDate)    
      
  RETURN @age    
      
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_AGE] TO [webuser]
GO