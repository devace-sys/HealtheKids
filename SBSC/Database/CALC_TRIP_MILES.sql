USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_TRIP_MILES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_TRIP_MILES
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CALC_TRIP_MILES](@tripStart DECIMAL(7,1), @tripEnd DECIMAL(7,1)) 
RETURNS DECIMAL(7,1) 
WITH SCHEMABINDING 
AS     
BEGIN    
      
  DECLARE @tripMiles AS DECIMAL(7,1)    
      
  IF @tripStart IS NULL SET @tripStart = 0    
  IF @tripEnd   IS NULL SET @tripEnd   = 0    
      
  IF @tripStart <= 0    SET @tripStart = 0    
  IF @tripEnd   <= 0    SET @tripEnd   = 0    
       
  SET @tripMiles = 0    
    
 /******************************************    
  * If tripEnd is supplied we consider this    
  * # of miles.  If tripStart and tripEnd    
  * are supplied we consider this mileage    
  * and # of miles is tripEnd - tripStart    
  *******************************************/    
      
  IF ((@tripStart = 0) AND (@tripEnd = 0))    
  BEGIN    
    SET @tripMiles = 0    
  END    
  ELSE IF ((@tripStart > 0) AND (@tripEnd = 0))       
  BEGIN    
    SET @tripMiles = 0    
  END    
  ELSE IF ((@tripStart = 0) AND (@tripEnd > 0))       
  BEGIN    
    SET @tripMiles = @tripEnd    
  END    
  ELSE IF ((@tripStart > 0) AND (@tripEnd > 0) AND (@tripStart <= @tripEnd))    
  BEGIN    
    SET @tripMiles = @tripEnd - @tripStart    
  END    
  ELSE    
  BEGIN    
    SET @tripMiles = 0    
  END    
  RETURN @tripMiles     
END    
    
GO
