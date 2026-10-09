USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_PLACES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_PLACES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_PLACES_VIEW_CORE] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @patID                  BIGINT
 , @term                   varchar(255)
 , @active                 BIT
 , @placeID                varchar(255)
 , @quickPlaceIdLookup     bit 
)

RETURNS @rows table (
     placeID      varchar(255)
   , placeClass   bigint
   , name         nvarchar(1000)
   , address1     nvarchar(max)
   , address2     nvarchar(max)
   , city         nvarchar(max)
   , state        nvarchar(max)
   , zip5         nvarchar(10)
   , zip4         nvarchar(8)
   , active       bit
   , placeAddress varchar(2500)
   , id           bigint
   UNIQUE CLUSTERED (placeID)
)
AS
BEGIN
  
  if ((@quickPlaceIdLookup = 1) and (@placeID is null)) return
  
  declare @placeClass as bigint = null
  
  declare @placeIDParts as table ( 
     id    int    
   , recid bigint 
  )
  
  if (@placeID is not null)
  begin      
    insert into @placeIDParts
    select * from dbo.PARSE_PLACE_ID_STRING (@placeID)   
    select top 1 @placeClass = recid from @placeIDParts where id = 1  
  end
    
  if (@placeClass = dbo.CONST_PLACE_CLASS_CLIENT_SITE())
  begin
    declare @siteID as bigint = null
    select top 1 @siteID = recid from @placeIDParts where (id = 3)
    insert into @rows    
    select top 1
        placeID                  
      , placeClass
      , name
      , address1
      , address2
      , city
      , state
      , zip5
      , zip4
      , active
      , placeAddress 
      , id 

    from dbo.SITE_PLACES_VIEW_CORE (  @userID
                                    , @userGroup
                                    , @userRank
                                    , @clientID  
                                    , @term                               
                                    , @active
                                    , null ) as ss    
    where (ss.id = @siteID)   
  end
  
  else if (@placeClass = dbo.CONST_PLACE_CLASS_PATIENT_ADDRESS())
  begin
    declare @patPlaceID as bigint = null
    select top 1 @patPlaceID= recid from @placeIDParts where (id = 4)
    insert into @rows    
    select top 1
        placeID 
      , placeClass 
      , name
      , address1
      , address2
      , city    
      , state   
      , zip5    
      , zip4    
      , active  
      , placeAddress
      , id
    
    from dbo.PATIENT_PLACES_VIEW_CORE (  @userID
                                       , @userGroup
                                       , @userRank
                                       , @clientID
                                       , @patID
                                       , @term
                                       , @active
                                       , null ) as pp
    where (pp.id = @patPlaceID)
  
  end
  else
  begin
  
    insert into @rows
    
    select  
        placeID 
      , placeClass 
      , name
      , address1
      , address2
      , city    
      , state   
      , zip5    
      , zip4    
      , active  
      , placeAddress
      , id
    
    from dbo.PATIENT_PLACES_VIEW_CORE (  @userID
                                       , @userGroup
                                       , @userRank
                                       , @clientID
                                       , @patID
                                       , @term
                                       , @active
                                       , null ) as pp

    union

    select 

        placeID                  
      , placeClass
      , name
      , address1
      , address2
      , city
      , state
      , zip5
      , zip4
      , active
      , placeAddress 
      , id 

    from dbo.SITE_PLACES_VIEW_CORE (  @userID
                                    , @userGroup
                                    , @userRank
                                    , @clientID  
                                    , @term                               
                                    , @active
                                    , null ) as ss    

  end

  return 

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_PLACES_VIEW_CORE] TO [webuser]
GO