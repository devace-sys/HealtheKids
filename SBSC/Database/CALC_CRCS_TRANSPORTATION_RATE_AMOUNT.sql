USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_CRCS_TRANSPORTATION_RATE_AMOUNT](@clientID BIGINT, @fiscalYearID BIGINT) RETURNS DECIMAL(5,2) 
AS     
BEGIN    
     
  DECLARE @rateAmt AS FLOAT       
    
  SELECT @rateAmt = case 
						when ctvd.vehicleRateType = 1 then 0 /* itemized */
						when ctvd.vehicleRateType = 2 then ( /* standardized */
							case
								when (isnull(ctvd.numVehiclesInFleet, 0) != 0
								  and isnull(ctvd.numSpeciallyAdapted, 0) != 0) then (
									cast(ctvd.numSpeciallyAdapted as float) / cast(ctvd.numVehiclesInFleet as float)
								  )
								else 0
							end
						)
						else 0
					end
	from dbo.CRCS_TRANSPORTATION_VEHICLE_DATA as ctvd
	where (ctvd.clientID = @clientID) and (ctvd.fiscalYearID = @fiscalYearID)  
      
  RETURN cast(@rateAmt as decimal(5,2))    
      
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_CRCS_TRANSPORTATION_RATE_AMOUNT] TO [webuser]
GO