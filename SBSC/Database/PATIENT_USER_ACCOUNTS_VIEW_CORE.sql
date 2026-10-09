USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_USER_ACCOUNTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_USER_ACCOUNTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[PATIENT_USER_ACCOUNTS_VIEW_CORE] (
   @userID                 bigint
 , @userGroup              int
 , @userRank               int
 , @clientID               bigint
 , @patID                  bigint
 , @active                 bit
 , @recID                  bigint
 , @userIDIntAssociation   bigint 
)

RETURNS TABLE
AS
RETURN
(  

with
cte_p1
as
(
  select  
      id           = pua.id 	  
    , clientID     = pua.clientID
    , clientName   = clc.CLIENT_NAME
    , patID        = pua.patID
    , patName      = pap.CONCAT_NAME   
    , firstName    = trim(pap.FIRST_NAME)
    , lastName     = trim(pap.LAST_NAME)
    , middleName   = trim(pap.MIDDLE_NAME)
    , active       = pua.active
	, pap.preferredContactMethodCode
	, userIDInt = pua.userIDInt
	, userIDUid = pua.userIDUid
    
  from dbo.PATIENTS_USER_ACCOUNTS as pua
  join dbo.PATIENTS_Client        as pc   on  pc.CLIENT_ID     = pua.clientID and pc.PATIENT_ID = pua.patID
  join dbo.CLIENTS_Client         as clc  on  clc.CLIENT_ID    = pua.clientID
  join dbo.PATIENTS_Patient       as pap  on  pap.PATIENT_ID   = pc.PATIENT_ID
   
   
  where (
        (1=1)        
    and ((@userIDIntAssociation is null) or (pua.userIDInt = @userIDIntAssociation)) /* For patient user account optimization */
    and ((@clientID   is null) or (pua.clientID   = @clientID))
    and ((@patID      is null) or (pua.patID      = @patID))         
    and ((@recID      is null) or (pua.ID         = @recID))		
  )
)
,
cte_p2
as
(
  select 
      p1.* 
    , preferredContactMethodName = isnull(mc.[name],'')
	, [name]                     = p1.firstName + N' ' + p1.lastName
	, email                      = isnull(pat_email.Email,'')
    , phone                      = isnull(pat_phone.Phone,'')
    , fax                        = ''	
    , patientHomePlaceID         = isnull(pp2.ID,0)
    , patientHomePlaceName       = isnull(pp2.[NAME],'')  
    , street1                    = isnull(pp2.ADDRESS_1,'')
    , street2                    = isnull(pp2.ADDRESS_2,'')
    , city                       = isnull(pp2.CITY,'')
    , [state]                    = isnull(pp2.[STATE],'')
    , zip5                       = isnull(pp2.ZIP_5,'')
    , zip4                       = isnull(pp2.ZIP_4,'')

  from cte_p1                     as p1
  left join dbo.CONTACT_METHODS   as mc	 on mc.code = p1.preferredContactMethodCode

  outer apply (
	  SELECT top 1 
	    pat_e.[Email] 
	  FROM dbo.[PATIENTS_Email] as pat_e 
	  WHERE 
	        pat_e.[PATIENT_ID] = p1.patID 
		AND pat_e.ACTIVE = 1
  ) as pat_email

  outer apply (
	SELECT top 1 
	  pat_ph.[Phone] 
	FROM dbo.[PATIENTS_Phone] as pat_ph 
	WHERE 
	      pat_ph.[PATIENT_ID] = p1.patID 
	  AND pat_ph.ACTIVE = 1
  ) as pat_phone
   
  /* Get patient home address */  
  /* Keep in synch with homeplace id get logic in C:\SBSC\Spedmon\Database\TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE_CORE.sql */

  outer apply (
    select top 1 
        pp1.ID
	  , pp1.NAME
	  , pp1.ADDRESS_1
	  , pp1.ADDRESS_2
	  , pp1.CITY
	  , pp1.STATE
	  , pp1.ZIP_5
	  , pp1.ZIP_4	
    from dbo.PATIENT_PLACES as pp1
    where (
          ((pp1.PATIENT_ID = p1.patID) and (pp1.id is not null)) /* Index */
      and (pp1.PATIENT_PLACE_TYPE = 1)
      and (pp1.ACTIVE             = 1)
    )
    order by 
      pp1.id         desc
	, pp1.START_DATE desc
  ) as pp2
)
select 
   p2.* 
 , placeAddress = dbo.BUILD_PLACE_ADDRESS_STRING (   p2.street1
                                                    , p2.street2
                                                    , p2.city
                                                    , p2.[state]
                                                    , p2.zip5
                                                    , p2.zip4
													, 0 )
from cte_p2 as p2

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_USER_ACCOUNTS_VIEW_CORE] TO [webuser]
GO