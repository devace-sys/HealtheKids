USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_INSURANCE_CARRIERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_INSURANCE_CARRIERS_VIEW
GO

CREATE FUNCTION [dbo].[PATIENT_INSURANCE_CARRIERS_VIEW] (
    @userID                 bigint    
  , @userGroup              int  
  , @userRank               int    
  , @clientID               bigint
  , @patID                  bigint
  , @planSupportedByCYBI    bit
  , @hasCarrierSelection    bit
  , @active                 bit
  , @recID                  bigint
) 
    
RETURNS TABLE 
AS RETURN (       
with
cte_p1
as
(
  select
  	    pic.id
	  , pic.clientID
      , pic.patID
	  , patName = pap.CONCAT_NAME
	  , dob     = pap.DATE_OF_BIRTH
	  , dobStr  = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
	  , ssid    = trim(isnull(pap.CSIS,N''))
      , pic.insuranceCarrierID 
      , insuranceCarrierName  = COALESCE (ic.[name], pic.[insCarrierNameStr], 'No name provided')
	  , pic.beneficiaryLastName
	  , pic.beneficiaryFirstName
	  , pic.beneficiaryID
      , pic.policyHolderName
      , pic.policyGroupID
      , pic.expiredOrInvalid
	  , pic.cybhiRegisteredWithTpa
	  , planSupportedByCYBI = convert(bit,isnull(ic.planSupportedByCYBHI,0))
      , hasCarrierSelection = convert(bit,(iif((ic.id is null),0,1)))
	  , pic.primaryCarrier

  from      dbo.PATIENT_INSURANCE_CARRIERS as pic
  join      dbo.PATIENTS_Patient           as pap on pap.PATIENT_ID = pic.patID
  left join dbo.INSURANCE_CARRIERS         as ic  on ic.id          = pic.insuranceCarrierID

  where (
        ((pic.clientID = @clientID) and ((@patID is null) or (pic.patID = @patID)) and (pic.id > 0)) /* Index: CLIENT_PAT_IDX*/
	and (pic.active   = 1)
    and ((ic.active = 1) or (ic.id IS NULL ))
  )
)
select 
  p1.* 
from cte_p1 as p1
where ( 
      (1=1)
  and ((@hasCarrierSelection is null) or (p1.hasCarrierSelection = @hasCarrierSelection))
  and ((@planSupportedByCYBI is null) or (p1.planSupportedByCYBI = @planSupportedByCYBI))
)


)

GO


GRANT SELECT ON  [dbo].[PATIENT_INSURANCE_CARRIERS_VIEW] TO [webuser]
GO

