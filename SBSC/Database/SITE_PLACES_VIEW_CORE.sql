USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SITE_PLACES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SITE_PLACES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[SITE_PLACES_VIEW_CORE] (
    @userID       BIGINT    
  , @userGroup    INT
  , @userRank     INT
  , @clientID     BIGINT
  , @term         varchar(255)
  , @active       BIT  
  , @recID        BIGINT 
)

RETURNS TABLE
AS
RETURN
(  
   select

        id         = ss.SITE_ID
        
      , placeID    = dbo.BUILD_PLACE_ID_STRING (  dbo.CONST_PLACE_CLASS_CLIENT_SITE()
                                                , ss.SITE_CLIENT_ID
                                                , ss.SITE_ID
                                                , sa.SITE_ADDRESS_ID
												, 0 )
                                                
      , placeClass = dbo.CONST_PLACE_CLASS_CLIENT_SITE()

      , name         = ss.SITE_NAME
      , address1     = sa.ADDRESS_1
      , address2     = sa.ADDRESS_2
      , city         = sa.CITY
      , state        = sa.STATE
      , zip5         = sa.ZIP
      , zip4         = sa.ZIP_PLUS_FOUR
      , active       = ss.ACTIVE
      , placeAddress = dbo.BUILD_PLACE_ADDRESS_STRING (  sa.ADDRESS_1
                                                       , sa.ADDRESS_2
                                                       , sa.CITY
                                                       , sa.STATE
                                                       , sa.ZIP
                                                       , sa.ZIP_PLUS_FOUR
													   , 0 )
      
      , siteID       = ss.SITE_ID

    from      dbo.CLIENTS_Client   as cc
    join      dbo.SITES_Site       as ss on ss.SITE_CLIENT_ID = cc.CLIENT_ID
    join      dbo.SITES_ADDRESS    as sa on sa.SITE_ID   = ss.SITE_ID
    left join dbo.SITES_PSEUDONYMS as sp on sp.SITE_NAME = ss.SITE_NAME

    where (
          (1=1)
      and ((@clientID is null) or (cc.CLIENT_ID = @clientID))
      and ((@active   is null) or (ss.active    = @active))
      and ((@term is null)     or (ss.SITE_NAME like (isnull(@term,'') + '%')))
      and (sp.ID is null)
      and ((@recID is null)    or (ss.SITE_ID = @recID))
    )
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SITE_PLACES_VIEW_CORE] TO [webuser]
GO