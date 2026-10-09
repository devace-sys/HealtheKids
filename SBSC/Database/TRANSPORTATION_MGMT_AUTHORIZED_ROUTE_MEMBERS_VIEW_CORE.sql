USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_VIEW_CORE] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @transMgmtID            BIGINT
 , @patID                  BIGINT
 , @transMgmtAuthPatID     BIGINT
 , @routeID                BIGINT
 , @active                 BIT
 , @recID                  BIGINT ) 

RETURNS TABLE
AS
RETURN
(
  
with
cte_p1
as
(

  select 
  
      id                          = tmapv.id             
    , name                        = tmapv.name       
    , clientID                    = tmarv.clientID        
    , clientName                  = tmarv.clientName
    , routeID                     = tmarv.id
    , routeName                   = tmarv.name    
    
    , origName                    = isnull (tmpvc_o.name         ,'')
    , origAddress                 = isnull (tmpvc_o.placeAddress ,'')
    , origPlaceID                 = tmarm.ORIG_PLACE_ID
    
    , destName                    = isnull(tmpvc_d.name          ,'')
    , destAddress                 = isnull(tmpvc_d.placeAddress  ,'')
    , destPlaceID                 = tmarm.DEST_PLACE_ID
    
    , distanceMiles               = tmtc.DISTANCE_MILES
    , distanceMilesStr            = isnull(convert(varchar(52),tmtc.DISTANCE_MILES),'')
    , tripCalcID                  = tmtc.ID
    , mapsURL                     = tmtc.MAPS_URL
    , tripsCalcCurrentAuditID     = tmtc.CURRENT_AUDIT_ID
    , patID                       = tmapv.patID
    , patName                     = tmapv.patName
    , patDOB                      = tmapv.patDOB                 
    , patDOBStr                   = tmapv.patDOBStr
    
    , sitePlaceID                 = tmapv.sitePlaceID
    , siteName                    = tmapv.siteName
    , siteAddress                 = tmapv.siteAddress

    , homePlaceID                 = tmapv.homePlaceID
    , homeName                    = tmapv.homeName
    , homeAddress                 = tmapv.homeAddress    
    
    , transMgmtID                 = tmapv.transMgmtID
    , transMgmtAuthPatID          = tmapv.transMgmtAuthPatID  
    , transMgmtAuthRouteMemberID  = tmarm.ID
    , displayOrder                = isnull(tmarm.DISPLAY_ORDER, (tmarm.ID + 1000)) /* Use display order first, then order added with some space added */
    , weekDaysJSON                = tmarm.DAYS_OF_WEEK_SVC_PROVIDED_JSON
	, selectAmPm                  = tmarm.AM_PM_SELECTION

  from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_CORE (  @userID
                                                            , @userGroup
                                                            , @userRank
                                                            , @clientID
                                                            , @transMgmtID
                                                            , @active
                                                            , @routeID ) as tmarv  
                                                       
  
  join dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS as tmarm on tmarm.ROUTE_ID = tmarv.ID
    
  join dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW_CORE (  @userID
                                                              , @userGroup
                                                              , @userRank
                                                              , @clientID
                                                              , @transMgmtID
                                                              , @patID                                                         
                                                              , @active
                                                              , @transMgmtAuthPatID ) as tmapv on tmapv.patID = tmarm.PATIENT_ID
    
  
  outer apply (
    select top 1 placeID, name, placeAddress from dbo.TRANSPORTATION_MGMT_PLACES_VIEW_CORE (@userID,@userGroup,@userRank,@clientID,@patID,null,@active,tmarm.ORIG_PLACE_ID,1)
  ) as tmpvc_o 
  
  outer apply (
    select top 1 placeID, name, placeAddress from dbo.TRANSPORTATION_MGMT_PLACES_VIEW_CORE (@userID,@userGroup,@userRank,@clientID,@patID,null,@active,tmarm.DEST_PLACE_ID,1)
  ) as tmpvc_d

  outer apply (
    select top 1 
        ID
      , DISTANCE_MILES 
      , MAPS_URL
      , CURRENT_AUDIT_ID
    from dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS where ((ORIG_PLACE_ID = tmarm.ORIG_PLACE_ID) and (DEST_PLACE_ID = tmarm.DEST_PLACE_ID) and (ID = TRIP_CALC_ID))
  ) as tmtc
  
 where 
        (tmarm.CLIENT_ID = @clientID)
   and  (tmarm.ACTIVE    = @active)
   and ((@patID is null) or (tmarm.PATIENT_ID = @patID))
   and ((@recID is null) or (tmarm.ID = @recID))

) 
,

cte_p2
as
(
  select 
    * 
  , origToDestSummary = origName + ' | ' + destName + ' | ' + distanceMilesStr
  
  from cte_p1
)

select * from cte_p2


)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_VIEW_CORE] TO [webuser]
GO