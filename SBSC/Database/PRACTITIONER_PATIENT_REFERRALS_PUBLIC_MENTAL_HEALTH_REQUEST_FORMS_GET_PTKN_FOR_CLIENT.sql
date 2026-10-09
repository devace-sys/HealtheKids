USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORMS_GET_PTKN_FOR_CLIENT') 
      AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
begin 
  DROP FUNCTION dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORMS_GET_PTKN_FOR_CLIENT;
end
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORMS_GET_PTKN_FOR_CLIENT] (
  @clientID bigint  
) 
RETURNS 
TABLE
AS RETURN (
  select top 1 
	   pirpif.id
     , clientID            = clc.CLIENT_ID
	 , clientName          = clc.CLIENT_NAME
     , clientLogoFileData  = clc.clientlogofiledata
	 , pirpif.publicToken
  from dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_REFERRAL_FORMS as pirpif
  join dbo.CLIENTS_Client                               as clc  on clc.CLIENT_ID = pirpif.clientID
  
  where (
        (pirpif.clientID = @clientID)
    and (pirpif.active   = 1)
  )
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORMS_GET_PTKN_FOR_CLIENT] TO [webuser];
GO
