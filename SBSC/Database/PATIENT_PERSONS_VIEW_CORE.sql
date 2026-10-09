USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PERSONS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PERSONS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[PATIENT_PERSONS_VIEW_CORE] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @patientID              BIGINT
 , @CLASS_ID_1             bigint
 , @CLASS_ID_2             bigint
 , @active                 BIT
 , @recID                  BIGINT
 , @userIDIntAssociation   BIGINT
 
)

RETURNS TABLE
AS
RETURN
(  
  select  
      id           = ppp.ID 	  
    , clientID     = cc.CLIENT_ID
    , clientName   = cc.CLIENT_NAME
    , patientID    = pap.PATIENT_ID     
    , patientName  = pap.CONCAT_NAME
    , personID     = pep.ID    
    , classID1     = pc1.ID
    , className1   = pc1.[NAME]
    , classID2     = pc2.ID
    , className2   = pc2.[NAME]
    , [name]       = pep.FIRST_NAME
                   + ' '
                   + pep.LAST_NAME
    , firstName    = pep.FIRST_NAME
    , lastName     = pep.LAST_NAME
    , middleName   = pep.MIDDLE_NAME
    , email        = pep.EMAIL
    , phone        = pep.PHONE
    , fax          = pep.FAX	
    , address1     = pep.ADDRESS_1
    , address2     = pep.ADDRESS_2
    , city         = pep.CITY
    , [state]      = pep.[STATE]
    , zip5         = pep.ZIP_5
    , zip4         = pep.ZIP_4    
    , additionalData1 = pep.ADDITIONAL_DATA_1
    , additionalData2 = pep.ADDITIONAL_DATA_2
    , active          = ppp.ACTIVE
    
    , placeAddress = dbo.BUILD_PLACE_ADDRESS_STRING (   pep.ADDRESS_1
                                                       , pep.ADDRESS_2
                                                       , pep.CITY
                                                       , pep.[STATE]
                                                       , pep.ZIP_5
                                                       , pep.ZIP_4
													   , 0 )

    , relationshipWithPatientLabel = pc1.[NAME] + ' - ' + pc2.[NAME]	
	, userIDInt = ppp.USER_ID_INT
	, userIDUid = ppp.USER_ID_UID
    
	from dbo.CLIENTS_Client   as cc
    join dbo.PATIENTS_Client  as pc   on  pc.CLIENT_ID     = cc.CLIENT_ID
    join dbo.PATIENTS_Patient as pap  on  pap.PATIENT_ID   = pc.PATIENT_ID
    join dbo.PATIENTS_PERSON  as ppp  on  ppp.CLIENT_ID    = pc.CLIENT_ID
	                                  and ppp.PATIENT_ID   = pap.PATIENT_ID
    join dbo.PERSONS_PERSON   as pep  on  pep.ID           = ppp.PERSON_ID
    join dbo.PERSONS_CLASS    as pc1  on  pc1.ID           = pep.CLASS_ID_1
    join dbo.PERSONS_CLASS    as pc2  on  pc2.ID           = pep.CLASS_ID_2
    
    where (
            (1=1)
        
		and ((@userIDIntAssociation is null) or (ppp.USER_ID_INT = @userIDIntAssociation)) /* For parent guardian optimization */

		and ((@clientID   is null) or (cc.CLIENT_ID   = @clientID))
        and ((@patientID  is null) or (pap.PATIENT_ID = @patientID)) 
        and ((@CLASS_ID_1 is null) or (pep.CLASS_ID_1 = @CLASS_ID_1))
        and ((@CLASS_ID_2 is null) or (pep.CLASS_ID_2 = @CLASS_ID_2))
        and ((@active     is null) or (ppp.ACTIVE     = @active))		
        and ((@recID      is null) or (ppp.ID         = @recID))       
		
    )

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PERSONS_VIEW_CORE] TO [webuser]
GO