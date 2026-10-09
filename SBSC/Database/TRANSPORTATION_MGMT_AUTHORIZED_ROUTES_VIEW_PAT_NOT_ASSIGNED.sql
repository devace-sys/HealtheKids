USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_PAT_NOT_ASSIGNED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_PAT_NOT_ASSIGNED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_PAT_NOT_ASSIGNED] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @transMgmtID            BIGINT
 , @patID                  BIGINT )

RETURNS TABLE
AS
RETURN
(
  select top (dbo.CONST_MAX_ROWS())
    *
  from TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_CORE (  @userID
                                                        , @userGroup
                                                        , @userRank               
                                                        , @clientID               
                                                        , @transMgmtID            
                                                        , 1                 
                                                        , null  ) as tmarvc

  where (@patID not in (select patID from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_VIEW_CORE (  @userID            
																   , @userGroup         
																   , @userRank          
																   , @clientID          
																   , @transMgmtID       
																   , null             
																   , null
																   , null           
																   , 1            
																   , null ) as tmarmvc where tmarvc.id = tmarmvc.routeID))
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_PAT_NOT_ASSIGNED] TO [webuser]
GO