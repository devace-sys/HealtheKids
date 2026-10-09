USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_AGE_IN_DAYS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_AGE_IN_DAYS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_AGE_IN_DAYS](@startDate DATETIME, @refDate DATETIME) RETURNS INT 
AS     
BEGIN    
     
  DECLARE @age AS INT       
    
  IF @startDate IS NULL RETURN NULL
  IF @refDate   IS NULL SET @refDate = GETDATE()    
    
  SET @age = datediff(day, dbo.DATE_ONLY(@startDate), 
                           dbo.DATE_ONLY(@refDate))
      
  RETURN @age    
      
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_AGE_IN_DAYS] TO [webuser]
GO