USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW_CORE] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @transMgmtID            BIGINT
 , @patID                  BIGINT
 , @active                 BIT    
 , @recID                  BIGINT )

RETURNS TABLE
AS
RETURN
(

  select 
    
      id                 = pap.PATIENT_ID
    , name               = trim(pap.LAST_NAME) + ', ' + trim(pap.FIRST_NAME)
    , transMgmtID        = tmv.ID
    , transMgmtAuthPatID = tmap.ID    
    , clientID           = tmv.clientID
    , clientName         = tmv.clientName
    , pracID             = tmv.pracID
    , pracName           = tmv.pracName
    , patID              = pap.PATIENT_ID
    , patName            = trim(pap.LAST_NAME) + ', ' + trim(pap.FIRST_NAME)
    , patDOB             = pap.DATE_OF_BIRTH    
    , patDOBStr          = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
    , sitePlaceID        = tmap.SITE_PLACE_ID
    , siteName           = tmpvc_s.name
    , siteAddress        = tmpvc_s.placeAddress
    , homePlaceID        = tmap.HOME_PLACE_ID    
    , homeName           = tmpvc_h.name
    , homeAddress        = tmpvc_h.placeAddress
    , setupClient        = tmv.setup
    , patSSID            = trim(isnull(pap.CSIS,N''))
  from dbo.TRANSPORTATION_MGMT_VIEW (  @userID
                                     , @userGroup
                                     , @userRank
                                     , @clientID
                                     , @active
                                     , @transMgmtID)  as tmv
                                                                     
  join  dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS   as tmap on  tmap.CLIENT_ID              = tmv.clientID
                                                              and tmap.TRANSPORTATION_MGMT_ID = tmv.id                                                                 
  join  dbo.PATIENTS_Patient                          as pap  on  pap.PATIENT_ID              = tmap.PATIENT_ID

  outer apply (
    select top 1 placeID, name, placeAddress from dbo.TRANSPORTATION_MGMT_PLACES_VIEW_CORE (@userID,@userGroup,@userRank,@clientID,@patID,null,@active,tmap.SITE_PLACE_ID,1) 
  ) as tmpvc_s 
  
  outer apply (
    select top 1 placeID, name, placeAddress from dbo.TRANSPORTATION_MGMT_PLACES_VIEW_CORE (@userID,@userGroup,@userRank,@clientID,@patID,null,@active,tmap.HOME_PLACE_ID,1)
  ) as tmpvc_h
  
  where (                 
         
         (tmap.ACTIVE    = @active)
    and  ((@patID is null) or (pap.PATIENT_ID  = @patID))
    and  ((@recID is null) or (tmap.ID         = @recID))
  )
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW_CORE] TO [webuser]
GO