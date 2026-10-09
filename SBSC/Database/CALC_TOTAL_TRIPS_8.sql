USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_TOTAL_TRIPS_8') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_TOTAL_TRIPS_8
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CALC_TOTAL_TRIPS_8](@trip1Start DECIMAL(7,1), @trip1End DECIMAL(7,1),     
                                           @trip2Start DECIMAL(7,1), @trip2End DECIMAL(7,1),    
                                           @trip3Start DECIMAL(7,1), @trip3End DECIMAL(7,1),    
                                           @trip4Start DECIMAL(7,1), @trip4End DECIMAL(7,1)) RETURNS SMALLINT AS     
BEGIN    
      
  DECLARE @trip1Miles AS DECIMAL(7,1)    
  DECLARE @trip2Miles AS DECIMAL(7,1)    
  DECLARE @trip3Miles AS DECIMAL(7,1)    
  DECLARE @trip4Miles AS DECIMAL(7,1)    
      
  SET @trip1Miles = dbo.CALC_TRIP_MILES(@trip1Start, @trip1End)    
  SET @trip2Miles = dbo.CALC_TRIP_MILES(@trip2Start, @trip2End)    
  SET @trip3Miles = dbo.CALC_TRIP_MILES(@trip3Start, @trip3End)    
  SET @trip4Miles = dbo.CALC_TRIP_MILES(@trip4Start, @trip4End)    
      
  RETURN dbo.CALC_TOTAL_TRIPS_4(@trip1Miles,@trip2Miles,@trip3Miles,@trip4Miles)    
      
END    
    
GO
