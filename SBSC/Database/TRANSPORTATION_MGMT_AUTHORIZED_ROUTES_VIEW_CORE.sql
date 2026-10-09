USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_CORE] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @transMgmtID            BIGINT
 , @active                 BIT
 , @recID                  BIGINT )

RETURNS TABLE
AS
RETURN
(
  select  
      id               = tmar.id
    , name             = tmar.NAME
    , busNumber        = tmar.BUS_NUMBER           
    , origName         = isnull (tmpvc_o.name         ,'')
    , origAddress      = isnull (tmpvc_o.placeAddress ,'')
    , origPlaceID      = tmar.ORIG_PLACE_ID    
    , destName         = isnull(tmpvc_d.name          ,'')
    , destAddress      = isnull(tmpvc_d.placeAddress  ,'')
    , destPlaceID      = tmar.DEST_PLACE_ID    
    , distanceMiles    = tmar.DISTANCE_MILES
    , distanceMilesStr = isnull(convert(varchar(52),tmar.DISTANCE_MILES),'Unknown')        
    , transMgmtID      = tmv.ID
    , clientID         = tmv.clientID
    , clientName       = tmv.clientName
    , pracID           = tmv.pracID
    , pracName         = tmv.pracName
    , setupClient      = tmv.setup
	, busDriverID      = tmar.BUS_DRIVER_ID
	, busDriverName    = dbo.CREATE_CONCAT_NAME(tmbd.lastName, tmbd.firstName)
        
  from dbo.TRANSPORTATION_MGMT_VIEW (  @userID
                                     , @userGroup
                                     , @userRank
                                     , @clientID
                                     , @active
                                     , @transMgmtID)  as tmv
                                      
  join dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES      as tmar on  tmar.CLIENT_ID              = tmv.clientID
                                                              and tmar.TRANSPORTATION_MGMT_ID = tmv.id
  left join dbo.TRANSPORTATION_MGMT_BUS_DRIVERS       as tmbd on tmbd.id = tmar.BUS_DRIVER_ID
                                                                
  outer apply (
    select top 1 placeID, name, placeAddress from dbo.TRANSPORTATION_MGMT_PLACES_VIEW_CORE (@userID,@userGroup,@userRank,@clientID,null,null,@active,tmar.ORIG_PLACE_ID,1)
  ) as tmpvc_o 
  
  outer apply (
    select top 1 placeID, name, placeAddress from dbo.TRANSPORTATION_MGMT_PLACES_VIEW_CORE (@userID,@userGroup,@userRank,@clientID,null,null,@active,tmar.DEST_PLACE_ID,1)
  ) as tmpvc_d

  where ( 
        (tmar.CLIENT_ID = @clientID)
    and ((@active is null) or (tmar.ACTIVE = @active))
    and ((@recID is null)  or (tmar.id = @recID))
  )
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_CORE] TO [webuser]
GO