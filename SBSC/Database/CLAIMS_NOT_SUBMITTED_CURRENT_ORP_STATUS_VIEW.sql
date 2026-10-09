USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_NOT_SUBMITTED_CURRENT_ORP_STATUS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_NOT_SUBMITTED_CURRENT_ORP_STATUS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIMS_NOT_SUBMITTED_CURRENT_ORP_STATUS_VIEW] (
    @clientID     bigint
  , @oldestDOS    date
  , @orpCompliant bit 
)     

RETURNS TABLE 
AS RETURN (      

select
  CLAIM_ID
from
(
  select   
      cc.CLAIM_ID 
    , ORP_COMPLIANT = dbo.IS_ORP_COMPLIANT (  1
                                            , dbo.IS_VALID_NPI(orp.npiNumber)
                                            , orp.isValidMcalOrp )  
  from dbo.CLIENTS_Client                  as clc
  join dbo.CLAIM_Claim                     as cc  on  (cc.CLIENT_ID = clc.CLIENT_ID)
                                                  and (cc.SERVICE_DATE >= dbo.CONST_ORP_DOCUMENTATION_FOR_TREATMENT_REQUIRED_START_DATE())
                                                  and (cc.SERVICE_DATE >= @oldestDOS)
                                                  and (cc.STATUS = '1')                                                  
  join      dbo.CLAIM_Procedures           as cp  on cp.PROCEDURE_ID = cc.PROCEDURE_ID
  left join dbo.PRACTITIONER_Practitioner  as orp on orp.PRACTITIONER_ID = cc.ORP_PRACTITIONER_ID

  where (
        (clc.CLIENT_ID = @clientID)
    and (cp.SERVICE_TYPE_ID = 2)
  )
) as q1
where 
  (ORP_COMPLIANT = @orpCompliant)

)  
GO
