USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW] (
   @userID                 bigint
 , @userGroup              int
 , @userRank               int
 , @origPlaceID            varchar(255)  
 , @destPlaceID            varchar(255)
 , @placeID                varchar(255)
 , @clientID               bigint
 , @active                 bit
 , @recID                  bigint
 , @quickTripLookup        bit 
)

RETURNS 
TABLE
AS
RETURN
(

  select 
      id                 = ID
    , origPlaceID        = ORIG_PLACE_ID
    , destPlaceID        = DEST_PLACE_ID
    , distanceInMiles    = DISTANCE_MILES
    , distanceInMilesStr = convert(varchar,DISTANCE_MILES)
    , origAddress        = ORIG_ADDRESS
    , destAddress        = DEST_ADDRESS
    , lastUpdated        = LAST_UPDATED
    , active             = ACTIVE
    , clientID           = CLIENT_ID
    , currentAgeInDays   = CURRENT_AGE_IN_DAYS

  from TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW_CORE (@userID, @userGroup, @userRank, @origPlaceID, @destPlaceID, @placeID, @clientID, @active, @recID, @quickTripLookup)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW] TO [webuser]
GO