USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW_CORE] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @transMgmtID            BIGINT
 , @patID                  BIGINT
 , @sheetBatchID           BIGINT
 , @sheetCode              VARCHAR(512)
 , @routeID                BIGINT
 , @sheetID                BIGINT
 , @active                 BIT
 , @recID                  BIGINT ) 

RETURNS TABLE
AS
RETURN
(
  

select 
    id                          = tmarm.id             
  , name                        = ltrim(rtrim(pp.LAST_NAME)) + ', ' + ltrim(rtrim(pp.FIRST_NAME))
  , clientID                    = tmarv.clientID        
  , clientName                  = tmarv.clientName
  , sheetID                     = tmarv.sheetID
  , sheetBatchID                = tmarv.sheetBatchID
  , sheetCode                   = tmarv.sheetCode
  , routeID                     = tmarv.routeID
  , routeName                   = tmarv.name        
  , origName                    = tmarm.ORIG_NAME
  , origAddress                 = tmarm.ORIG_ADDRESS
  , origPlaceID                 = tmarm.ORIG_PLACE_ID    
  , destName                    = tmarm.DEST_NAME
  , destAddress                 = tmarm.DEST_ADDRESS
  , destPlaceID                 = tmarm.DEST_PLACE_ID    
  , distanceMiles               = tmarm.DISTANCE_MILES
  , distanceMilesStr            = isnull(convert(varchar(52),tmarm.DISTANCE_MILES),'')        
  , patID                       = tmarm.PATIENT_ID
  , patName                     = ltrim(rtrim(pp.LAST_NAME)) + ', ' + ltrim(rtrim(pp.FIRST_NAME))
  , patDOB                      = pp.DATE_OF_BIRTH
  , patDOBStr                   = dbo.RPT_DATE_FMT(pp.DATE_OF_BIRTH)
  , transMgmtID                 = tmarm.TRANSPORTATION_MGMT_ID
  , transMgmtAuthPatID          = tmarm.TRANSPORTATION_MGMT_AUTH_PAT_ID
  , transMgmtAuthRouteMemberID  = tmarm.MEMBER_ID   
  , displayOrder                = isnull(tmarm.DISPLAY_ORDER, (tmarm.MEMBER_ID + 1000)) /* Use display order first, then order added with some space added */ 
  , scheduledForMon             = convert(bit, JSON_VALUE(tmarm.DAYS_OF_WEEK_SVC_PROVIDED_JSON,'$.mon'))
  , scheduledForTue             = convert(bit, JSON_VALUE(tmarm.DAYS_OF_WEEK_SVC_PROVIDED_JSON,'$.tue'))
  , scheduledForWed             = convert(bit, JSON_VALUE(tmarm.DAYS_OF_WEEK_SVC_PROVIDED_JSON,'$.wed'))
  , scheduledForThur            = convert(bit, JSON_VALUE(tmarm.DAYS_OF_WEEK_SVC_PROVIDED_JSON,'$.thur'))
  , scheduledForFri             = convert(bit, JSON_VALUE(tmarm.DAYS_OF_WEEK_SVC_PROVIDED_JSON,'$.fri'))
  , weekDaysJSON                = tmarm.DAYS_OF_WEEK_SVC_PROVIDED_JSON

from dbo.TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW_CORE (  @userID
                                                     , @userGroup
                                                     , @userRank
                                                     , @clientID
                                                     , @transMgmtID
                                                     , @sheetBatchID
                                                     , @sheetCode
                                                     , @routeID
                                                     , @active
                                                     , @sheetID ) as tmarv  
                                                       
join dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS as tmarm on tmarm.ROUTE_SHEET_ID = tmarv.ID
join dbo.PATIENTS_PATIENT                        as pp    on pp.PATIENT_ID        = tmarm.PATIENT_ID
    
where ( 
        (tmarm.CLIENT_ID = @clientID)
   and  (tmarm.ACTIVE    = @active)
   and ((@patID is null) or (tmarm.PATIENT_ID = @patID))
   and ((@recID is null) or (tmarm.ID         = @recID))
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW_CORE] TO [webuser]
GO