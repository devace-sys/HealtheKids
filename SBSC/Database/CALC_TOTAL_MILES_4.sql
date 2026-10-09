USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_TOTAL_MILES_4') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_TOTAL_MILES_4
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CALC_TOTAL_MILES_4](@trip1miles DECIMAL(7,1), @trip2miles DECIMAL(7,1), @trip3miles DECIMAL(7,1), @trip4miles DECIMAL(7,1)) RETURNS DECIMAL(7,1) AS     
BEGIN    
      
  DECLARE @numMilesAct AS DECIMAL(7,1)    
  DECLARE @numMilesRnd AS DECIMAL(7,1)    
      
  IF @trip1Miles  IS NULL SET @trip1Miles = 0    
  IF @trip2Miles  IS NULL SET @trip2Miles = 0    
  IF @trip3Miles  IS NULL SET @trip3Miles = 0    
  IF @trip4Miles  IS NULL SET @trip4Miles = 0    
      
  IF @trip1Miles <= 0 SET @trip1Miles = 0    
  IF @trip2Miles <= 0 SET @trip2Miles = 0    
  IF @trip3Miles <= 0 SET @trip3Miles = 0    
  IF @trip4Miles <= 0 SET @trip4Miles = 0    
      
  SET @numMilesAct = @trip1Miles + @trip2Miles + @trip3Miles + @trip4Miles    
  SET @numMilesRnd = ROUND(@numMilesAct,0)    
      
  RETURN @numMilesRnd     
END    
    
GO
