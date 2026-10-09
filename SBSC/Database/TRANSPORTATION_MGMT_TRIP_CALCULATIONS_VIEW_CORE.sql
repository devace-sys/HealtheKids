USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW_CORE] (
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

RETURNS @rows table (
     ID                  bigint
   , ORIG_PLACE_ID       varchar(255)
   , DEST_PLACE_ID       varchar(255)
   , DISTANCE_MILES      decimal(7,1)
   , ORIG_ADDRESS        varchar(255)
   , DEST_ADDRESS        varchar(255)
   , LAST_UPDATED        datetime   
   , ACTIVE              bit
   , CLIENT_ID           bigint
   , MAPS_URL            nvarchar(4000)
   , CURRENT_AUDIT_ID    bigint
   , CURRENT_AGE_IN_DAYS int 
 UNIQUE CLUSTERED (ORIG_PLACE_ID, DEST_PLACE_ID, ID)
)
AS
BEGIN
  declare @today as datetime
  set @today = getdate()
  
  if (@quickTripLookup = 1)
  begin
    insert into @rows
    select top 1
      * ,CURRENT_AGE_IN_DAYS = DATEDIFF(day,LAST_UPDATED,@today)    
    from dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS
    where (
              (ORIG_PLACE_ID = @origPlaceID)
          and (DEST_PLACE_ID = @destPlaceID)
    )
    return
  end
  
  insert into @rows
  select 
    *, CURRENT_AGE_IN_DAYS = DATEDIFF(day,LAST_UPDATED,@today)    
  from dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS
  where (
        (1=1)
    and ((@placeID     is null) or ((ORIG_PLACE_ID = @placeID) or (DEST_PLACE_ID = @placeID))) 
    and ((@clientID    is null) or (CLIENT_ID     = @clientID))
    and ((@recID       is null) or (ID            = @recID))
    and ((@active      is null) or (ACTIVE        = @active))
  )
  return
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW_CORE] TO [webuser]
GO