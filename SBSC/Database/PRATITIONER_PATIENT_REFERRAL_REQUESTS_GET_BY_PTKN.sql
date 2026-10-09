USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRATITIONER_PATIENT_REFERRAL_REQUESTS_GET_BY_PTKN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRATITIONER_PATIENT_REFERRAL_REQUESTS_GET_BY_PTKN
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRATITIONER_PATIENT_REFERRAL_REQUESTS_GET_BY_PTKN] (  
  @ptkn varchar(512)
) 
RETURNS TABLE
AS RETURN (  

select top 1
	ppr.*
    , referralID = ppr.id
	, clientName = clc.CLIENT_NAME
	, ptkn = ppr.publicToken
	, expirationDateStr								= dbo.RPT_DATE_FMT(ppr.expirationDate)
	, expirationTimeStr								= dbo.RPT_TIME_FMT(ppr.expirationTime,0) 
	, approvalRejectionDateStr						= dbo.RPT_DATE_FMT(ppr.approvalRejectionDate)
	, approvalRejectionTimeStr						= dbo.RPT_TIME_FMT(ppr.approvalRejectionTime,0)

from dbo.PRACTITIONER_PATIENT_REFERRALS  as ppr
left join dbo.PATIENTS_Patient           as pap		on  pap.PATIENT_ID = ppr.patID
join dbo.CLIENTS_Client                  as clc		on  clc.CLIENT_ID  = ppr.clientID
join users.dbo.USERS_ALL				 as usrs	on  usrs.userIDInt = ppr.referringByUserID
--LEFT JOIN dbo.PRACTITIONER_Practitioner  as prp		on  prp.PRACTITIONER_ID = ppr.pracID

where (
        (ppr.publicToken = @ptkn)
    and (ppr.active = 1)
)
 
)
GO
 

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRATITIONER_PATIENT_REFERRAL_REQUESTS_GET_BY_PTKN] TO [webuser]
GO
 
