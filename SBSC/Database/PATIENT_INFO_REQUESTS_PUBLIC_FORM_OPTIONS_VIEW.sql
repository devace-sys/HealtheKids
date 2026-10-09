USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS ( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
DROP FUNCTION dbo.PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS_VIEW] (
      @userID              BIGINT
    , @userGroup           INT
    , @userRank            INT
    , @clientID            BIGINT
    , @active              BIT
) 
RETURNS TABLE

/***************************************************************************
 * PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS_VIEW */
/**
 ***************************************************************************/
AS RETURN
(
	select 
	
	insuranceInfoRequestMessageBodyContentEN,
	insuranceInfoRequestMessageBodyContentES
	 
	from dbo.PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS 
	 
	where (clientID = @clientID)
)
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[PATIENT_INFO_REQUESTS_PUBLIC_FORM_OPTIONS_VIEW] TO [webuser]
GO
