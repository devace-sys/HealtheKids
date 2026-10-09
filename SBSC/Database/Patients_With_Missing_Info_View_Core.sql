USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_With_Missing_Info_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_With_Missing_Info_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Patients_With_Missing_Info_View_Core] (    
    @clientID                                 bigint  = -1
  , @patID                                    bigint  = null
  , @source                                   tinyint = 0
  , @missingInsuranceInfo                     bit     = null
  , @missingAddressInfo                       bit     = null
  , @missingOrNoFerpaConsent                  bit     = null
  , @missingPGEmails                          bit     = null
  , @missingMcalParentConsent                 bit     = null
  , @hasCurrentInfoRequest                    bit     = null
  , @hasCurrentInfoRequestWaitingForReview    bit     = null
  , @hasPreviousInfoRequestThatRequiredReview bit     = null
  , @limitToPatsWithMissingInfo               bit     = 1
)  

RETURNS TABLE

 /***************************************************************************    
  * Patients_With_Missing_Info_View_Core */    
 /**    
  * Returns set of patients that have missing info
  *    
  ***************************************************************************/     

AS RETURN (
with
cte_base
as
(
  select top 1 
    q1.*
  from 
  (
    select 
        clientID = isnull(@clientID,-1)
	  , [source] = isnull(@source,0)
    where 
      (@source in (0,1)) 
  ) as q1
  where 
    (q1.clientID > 0)
)
,
cte_p0
as
(
  /* source = 0 : Entire population */
  
  select 
    s0.* 
  from cte_base as b
  cross apply 
  (  
    select 
        id         = pc.PATIENT_ID
	  , clientID   = pc.CLIENT_ID
      , patID      = pc.PATIENT_ID 
      , numSvcRecs = null /* Not applicable */
	from dbo.PATIENTS_Client    as pc
    join dbo.PATIENTS_Patient   as pap  on pap.PATIENT_ID = pc.PATIENT_ID
    where (
          (1=1)
 	  and (b.[source]   = 0)
	  and (pc.CLIENT_ID = b.clientID)
      and ((@patID is null) or (pap.PATIENT_ID = @patID))
      and (pap.ACTIVE   = N'Y')      
    )
  ) as s0
  where 
    (b.[source] = 0) 
  
  union
  
  /* source = 1 : Just CYBHI pats */
  
  select 
    s1.* 
  from cte_base as b
  
  /* TODO: Add a @patID param to CYBHI_PATS_VIEW_DATA_CORE */
  
  cross apply (
    select 
        id = cpvdc.patID
	  , cpvdc.clientID
      , cpvdc.patID
	  , cpvdc.numSvcRecs 
    from dbo.CYBHI_PATS_VIEW_DATA_CORE (b.clientID) as cpvdc  
    where (
	      (1=1)
	  and (b.[source] = 1)
	  and ((@patID is null) or (cpvdc.patID = @patID))
	)
  ) as s1
  where 
   (b.[source] = 1)
)
,
cte_p1
as
(
  select 
      p0.* 
    , pic4.*
    , pp4.*
	, pg3.*

    , hasPatInsuranceCarrierRec = convert(bit,(iif(pic4.patInsuranceCarrierID is null,0,1)))
    , hasPatPlaceHomeRec        = convert(bit,(iif(pp4.patPlaceID is null,0,1)))
    , hasPGEmails               = convert(bit,(iif((pg3.patPerIDs is null),0,1)))   
	, hasFerpaConsent           = convert(bit,(isnull(pap.ferpaConsent,0)))
	, hasParentConsentMCAL      = convert(bit,(isnull(pap.parentConsentMCAL,0)))
	, hasIFSPorIEP              = convert(bit,(iif(pi2.id is null,0,1)))
	, impliedConsent            = isnull(clc.parentConsentAgreement,0)

    , hasParentConsentMCALWithRespectToImpliedConsent  = (isnull(pap.parentConsentMCAL
	                                                        , isnull(clc.parentConsentAgreement,1)))


  from cte_p0               as p0
  join dbo.CLIENTS_Client   as clc on clc.CLIENT_ID  = p0.clientID
  join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = p0.patID

  outer apply (
    select top 1 
      pi1.id
    from dbo.PATIENTS_IEP as pi1
    where ( 
           (pi1.PATIENT_ID = pap.PATIENT_ID)
       and (pi1.IEP_IFSP_NONE != N'None')
    )
  ) as pi2

  /* Get first complete insurance rec we can find */

  outer apply (
    select top 1
      pic3.*
    from
    (
      select 
          pic2.*
  	    , hasCompleteInsuranceInfo = convert(bit,(
           case        
             when pic2.patInsuranceCarrierID is null  then 0
			 when pic2.beneficiaryID             = '' then 0
			 when pic2.beneficiaryLastName       = '' then 0
	         when pic2.beneficiaryFirstName      = '' then 0
	         when pic2.carrierCode               = '' then 0
	         when pic2.policyHolderName          = '' then 0
	         when pic2.carrierCode               = '' then 0
			 when pic2.carrierCode               = 'PCAL-DSF-UNSP-1' then 0  /* We need to confirm */
			 else 1
	       end))
      from
      (
        select 
            beneficiaryID        = trim(isnull(pic1.beneficiaryID,''))
	      , beneficiaryLastName  = trim(isnull(pic1.beneficiaryLastName,''))
          , beneficiaryFirstName = trim(isnull(pic1.beneficiaryFirstName,''))
	      , carrierCode          = trim(isnull(ic.carrierCode,''))
	      , policyHolderName     = trim(isnull(pic1.policyHolderName,''))
	      , policyGroupID        = trim(isnull(pic1.policyGroupID,''))
          , planSupportedByCYBHI = isnull(ic.planSupportedByCYBHI,0)
	      , patInsuranceCarrierID = pic1.id

        from dbo.PATIENT_INSURANCE_CARRIERS as pic1  
        join dbo.INSURANCE_CARRIERS         as ic on ic.id = pic1.insuranceCarrierID

        where (
              ((pic1.clientID = p0.clientID) and (pic1.patID = p0.patID) and (pic1.id > 0)) /* Index: CLIENT_PAT_IDX*/
          and (pic1.active   = 1)
        )
      ) as pic2
    ) as pic3
    order by 
      pic3.patInsuranceCarrierID desc
  ) as pic4

  /* Get first complete patient place home rec we can find */

  outer apply (

    select top 1 
      pp3.*
    from
    (
      select 
          hasCompleteAddressInfo = convert(bit,(
            case       
	          when pp2.address1           = '' then 0
	          when pp2.city               = '' then 0
	          when pp2.[state]            = '' then 0
	          when pp2.zip5               = '' then 0
	          else 1
	      end))
        , pp2.*
      from
      (
        /* Keep in synch with homeplace id get logic in C:\SBSC\Spedmon\Database\TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE_CORE.sql */

		select top 1
	        address1 = trim(isnull(pp1.ADDRESS_1,''))
	      , city     = trim(isnull(pp1.CITY,''))
	      , [state]  = trim(isnull(pp1.[STATE],''))
	      , zip5     = trim(isnull(pp1.ZIP_5,''))
	      , patPlaceID = pp1.ID    
		 
        from dbo.PATIENT_PLACES as pp1
        where (
              (pp1.CLIENT_ID          = p0.clientID)
	      and (pp1.PATIENT_ID         = p0.patID)
          and (pp1.PATIENT_PLACE_TYPE = 1) /* Keep in synch with CONST_PATIENT_PLACE_TYPE_HOME_PRIMARY*/
          and (pp1.ACTIVE             = 1)
        )
		order by 
		  pp1.id         desc
		, pp1.START_DATE desc
      ) as pp2
    ) as pp3
    
	where 
      (pp3.hasCompleteAddressInfo = 1)
    order by 
       pp3.patPlaceID desc
  ) as pp4

  /* Get pg rec ids for pgs that have email addresses */
  
  outer apply (
    select 
      patPerIDs = string_agg(convert(varchar(max),pg2.ID),',')
    from
    (
      select 
          pg1.EMAIL
        , ID = max(pg1.ID)
      from
      (
        select 
            ppp.ID
          , EMAIL = trim(isnull(pep.EMAIL,''))
        from dbo.PATIENTS_PERSON as ppp 
        join dbo.PERSONS_PERSON  as pep on pep.ID = ppp.PERSON_ID
        where (
              ((ppp.CLIENT_ID = p0.clientID) and (ppp.PATIENT_ID = p0.patID))
          and (ppp.ACTIVE     =  1)
          and (pep.CLASS_ID_1 =  1)
	      and (pep.ACTIVE     =  1)    	    
        )
      ) as pg1
      where 
	    (pg1.EMAIL != '')
	  group by
        pg1.EMAIL
    ) as pg2
  ) as pg3

where 
  (pap.deceased = 0) /* Exclude anyone who has died */

)
,
cte_p2
as
(
 select 
       p1.*
	
	  /* Note: missingInfo is used to determine if a patient should be included if we want to show
	   * only patients with missing info */
	
	, missingInfo = convert(bit, (case 	      
		  when p1.hasPatInsuranceCarrierRec = 0 then 1
		  when p1.hasCompleteInsuranceInfo  = 0 then 1
	      when p1.hasPatPlaceHomeRec        = 0 then 1
	      when p1.hasFerpaConsent           = 0 then 1		  
	    else 0 
	  end))
    from cte_p1 as p1
)
,
cte_p3
as
(
  select 
      p2.*

    , missingMcalParentConsent = convert(bit,(iif(((p2.hasIFSPorIEP = 1) and (p2.hasParentConsentMCALWithRespectToImpliedConsent = 0)),1,0)))
	, missingInsuranceInfo     = convert(bit,(iif((p2.hasCompleteInsuranceInfo  = 1), 0,1)))
    , missingAddressInfo       = convert(bit,(iif((p2.hasPatPlaceHomeRec        = 1), 0,1)))
	, missingFerpaConsent      = convert(bit,(iif((p2.hasFerpaConsent           = 1), 0,1)))
	, missingPGEmails          = convert(bit,(iif((p2.hasPGEmails               = 1), 0,1)))
	
	, hasCurrentInfoRequest                     = convert(bit,(iif((pirrCurr.id is null),0,1)))      
    , currentInfoRequestID                      = pirrCurr.id 
    , hasCurrentInfoRequestWaitingForReview     = convert(bit,(isnull(pirrCurr.waitingForReview,0)))
	
	, hasPreviousInfoRequestThatRequiredReview  = convert(bit,(iif((pirrPrevRR.id is null),0,1)))
    , prevInfoRequestThatRequiredReviewID       = pirrPrevRR.id
  
    , okToDisplay = convert(bit,case when (@limitToPatsWithMissingInfo = 0) 
	                     then 1 
	                     else 
					       case when (p2.missingInfo = 1) then 1 else 0 end 
						 end )
  from cte_p2 as p2
  
  /* Current request (if any) */

  outer apply (  
    select top 1
	    pirr1.id	 
	  , waitingForReview = iif (((pirr1.responseReceived = 1) and (pirr1.reviewRequired = 1) and (pirr1.reviewed = 0) and (pirr1.completed = 0)), 1, 0)
	from  dbo.PATIENT_INFO_REQUESTS_RESPONSES as pirr1	    
	where (
          (pirr1.clientID  = p2.clientID)
      and (pirr1.patID     = p2.patID)
	  and (pirr1.completed = 0)
	  and (pirr1.active    = 1)
	)
	order by 
	  pirr1.id desc
  ) as pirrCurr

  /* Prev request that req review */

  outer apply (
      select top 1
	    pirr1.id	         	
	  from  dbo.PATIENT_INFO_REQUESTS_RESPONSES as pirr1	            
	  where (
            (pirr1.clientID       = p2.clientID)
        and (pirr1.patID          = p2.patID)
	    and (pirr1.canceled       = 0)	  	  
	    and (pirr1.completed      = 1)
	    and (pirr1.expired        = 0)
		and (pirr1.reviewRequired = 1)
		and (pirr1.reviewed       = 1)	  
	    and (pirr1.active         = 1)
	  )
  ) as pirrPrevRR

  /* Limit to patients with missing info */
  
  
)
select 
  p3.*  
from cte_p3 as p3
where (
      (1=1)
  and (p3.okToDisplay = 1)
  and ((@missingInsuranceInfo     is null)    or (p3.missingInsuranceInfo     = @missingInsuranceInfo))
  and ((@missingAddressInfo       is null)    or (p3.missingAddressInfo       = @missingAddressInfo))
  and ((@missingOrNoFerpaConsent  is null)    or (p3.missingFerpaConsent      = @missingOrNoFerpaConsent))
  and ((@missingPGEmails          is null)    or (p3.missingPGEmails          = @missingPGEmails))
  and ((@missingMcalParentConsent is null)    or (p3.missingMcalParentConsent = @missingMcalParentConsent))
  and ((@hasCurrentInfoRequest    is null)    or (p3.hasCurrentInfoRequest    = @hasCurrentInfoRequest))
  and ((@hasCurrentInfoRequestWaitingForReview    is null) or (p3.hasCurrentInfoRequestWaitingForReview    = @hasCurrentInfoRequestWaitingForReview))
  and ((@hasPreviousInfoRequestThatRequiredReview is null) or (p3.hasPreviousInfoRequestThatRequiredReview = @hasPreviousInfoRequestThatRequiredReview))
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patients_With_Missing_Info_View_Core] TO [webuser]
GO

  