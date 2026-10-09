USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_PLACES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_PLACES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_PLACES_VIEW] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @patID                  BIGINT
 , @term                   varchar(255)
 , @active                 BIT
 , @placeID                varchar(255)
 , @quickPlaceIdLookup     bit )

RETURNS TABLE
AS
RETURN
(  
  select top (dbo.CONST_MAX_ROWS())
    * 
  from dbo.TRANSPORTATION_MGMT_PLACES_VIEW_CORE(  @userID
                                                , @userGroup
                                                , @userRank
                                                , @clientID
                                                , @patID
                                                , @term
                                                , @active
                                                , @placeID
                                                , @quickPlaceIdLookup)
  order by 
  
    placeClass desc
  , name asc

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_PLACES_VIEW] TO [webuser]
GO