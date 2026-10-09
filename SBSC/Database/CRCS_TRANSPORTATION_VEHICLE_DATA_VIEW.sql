USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_TRANSPORTATION_VEHICLE_DATA_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_TRANSPORTATION_VEHICLE_DATA_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CRCS_TRANSPORTATION_VEHICLE_DATA_VIEW] (
	@userID	          BIGINT
  , @userGroup        INT  
  , @userRank         INT 
  , @clientID         BigInt
  , @fiscalYearID     BigInt
)    

RETURNS TABLE

AS RETURN (
   
	select
		ctvd.*
	from dbo.CRCS_TRANSPORTATION_VEHICLE_DATA as ctvd
	where (
		(ctvd.clientID      = @clientID)
	and (ctvd.fiscalYearID  = @fiscalYearID)
	and (ctvd.active        = 1)
	)
)
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_TRANSPORTATION_VEHICLE_DATA_VIEW] TO [webuser]
GO  
