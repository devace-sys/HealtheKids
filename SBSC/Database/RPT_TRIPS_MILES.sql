USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_TRIPS_MILES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_TRIPS_MILES
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_TRIPS_MILES] ( @svcType    INT,    
                                         @trip1Start DECIMAL(7,1), @trip1End DECIMAL(7,1),     
                                         @trip2Start DECIMAL(7,1), @trip2End DECIMAL(7,1),    
                                         @trip3Start DECIMAL(7,1), @trip3End DECIMAL(7,1),    
                                         @trip4Start DECIMAL(7,1), @trip4End DECIMAL(7,1))     
                                         RETURNS VARCHAR(20) AS     
BEGIN    
      
  /* Get out if the service type is not transportation */    
  IF (@svcType <> dbo.CONST_SERVICES_TRANSPORT()) RETURN '0/0'    
  DECLARE @numMiles AS DECIMAL(7,1)    
  DECLARE @numTrips AS SMALLINT    
  DECLARE @tripsMiles AS VARCHAR(20)    
      
  SET @numMiles = dbo.CALC_TOTAL_MILES_8(@trip1Start,@trip1End,@trip2Start,@trip2End,@trip3Start,@trip3End,@trip4Start,@trip4End)    
  SET @numTrips = dbo.CALC_TOTAL_TRIPS_8(@trip1Start,@trip1End,@trip2Start,@trip2End,@trip3Start,@trip3End,@trip4Start,@trip4End)    
  SET @tripsMiles = CONVERT(VARCHAR(1),@numTrips) + '/' + CONVERT(VARCHAR(11),CAST(@numMiles AS INT))    
  RETURN @tripsMiles    
END    
GO
