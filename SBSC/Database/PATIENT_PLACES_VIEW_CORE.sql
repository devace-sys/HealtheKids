USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PLACES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PLACES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[PATIENT_PLACES_VIEW_CORE] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @patID                  BIGINT
 , @term                   varchar(255)
 , @active                 BIT
 , @recID                  BIGINT
 
)

RETURNS TABLE
AS
RETURN
(  

  select
  
      id           = ppp.ID 
    , placeID      = dbo.BUILD_PLACE_ID_STRING  (   dbo.CONST_PLACE_CLASS_PATIENT_ADDRESS()
                                                  , cc.CLIENT_ID
                                                  , pap.PATIENT_ID 
                                                  , ppp.id
												  , 0 )

    , placeClass   =  dbo.CONST_PLACE_CLASS_PATIENT_ADDRESS()
    , clientID     = cc.CLIENT_ID
    , clientName   = cc.CLIENT_NAME
    , patID        = pap.PATIENT_ID     
    , patName      = pap.CONCAT_NAME
    , name         = ppp.NAME
    , address1     = ppp.ADDRESS_1
    , address2     = ppp.ADDRESS_2
    , city         = ppp.CITY
    , state        = ppp.STATE
    , zip5         = ppp.ZIP_5
    , zip4         = ppp.ZIP_4
    , active       = ppp.ACTIVE
    , placeAddress = dbo.BUILD_PLACE_ADDRESS_STRING (    ppp.ADDRESS_1
                                                       , ppp.ADDRESS_2
                                                       , ppp.CITY
                                                       , ppp.STATE
                                                       , ppp.ZIP_5
                                                       , ppp.ZIP_4
													   , 0 )
      
    
    from dbo.CLIENTS_Client   as cc
    join dbo.PATIENTS_Client  as pc   on pc.CLIENT_ID     = cc.CLIENT_ID
    join dbo.PATIENTS_Patient as pap  on pap.PATIENT_ID   = pc.PATIENT_ID
    join dbo.PATIENT_PLACES   as ppp  on ppp.PATIENT_ID   = pap.PATIENT_ID
  
    where (
            (1=1)
        and ((@clientID is null) or (cc.CLIENT_ID   = @clientID))
        and ((@patID    is null) or (pap.PATIENT_ID = @patID))        
        and ((@active   is null) or (ppp.ACTIVE     = 1))
        and ((@recID    is null) or (ppp.ID         = @recID))
        and ((@term     is null) or (ppp.NAME like (isnull(@term,'') + '%')))
    )

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PLACES_VIEW_CORE] TO [webuser]
GO