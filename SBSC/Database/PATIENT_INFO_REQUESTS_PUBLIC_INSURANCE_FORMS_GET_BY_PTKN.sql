USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS_GET_BY_PTKN') 
      AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
begin 
  DROP FUNCTION dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS_GET_BY_PTKN;
end
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS_GET_BY_PTKN] (
  @ptkn VARCHAR(512)
) 
RETURNS TABLE
AS RETURN (
  select top 1 
	   pirpif.id
     , clientID            = clc.CLIENT_ID
	 , clientName          = clc.CLIENT_NAME
     , clientLogoFileData  = clc.clientlogofiledata
	 , pirpif.publicToken
  from dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS as pirpif
  join dbo.CLIENTS_Client                               as clc  on  clc.CLIENT_ID  = pirpif.clientID
  
  where (
        (pirpif.publicToken      = @ptkn)
    and (pirpif.active           = 1)
  )
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS_GET_BY_PTKN] TO [webuser];
GO
