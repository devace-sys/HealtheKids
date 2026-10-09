USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_TO_AUTO_GENERATE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_INFO_REQUESTS_RESPONSES_TO_AUTO_GENERATE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_INFO_REQUESTS_RESPONSES_TO_AUTO_GENERATE_VIEW] (    
    @clientID  bigint  = -1
  , @source    tinyint = 0
)  

RETURNS TABLE

 /***************************************************************************    
  * PATIENT_INFO_REQUESTS_RESPONSES_NEEDED_VIEW */    
 /**    
  * Returns set of patients that need a info request response
  *    
  ***************************************************************************/     

AS RETURN (
with
cte_base
as
(
  select 
      clientID = isnull(@clientID,-1)
	, [source] = isnull(@source,0)
  where 
    (@source in (0,1))
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
        clientID = pc.CLIENT_ID
      , patID    = pc.PATIENT_ID 
    from dbo.PATIENTS_Client    as pc
    join dbo.PATIENTS_Patient   as pap  on pap.PATIENT_ID = pc.PATIENT_ID
    where (
          (b.[source] = 0)
	  and (pc.CLIENT_ID = b.clientID)
      and (pap.ACTIVE = N'Y')      
    )
  ) as s0
  where 
    (b.[source] = 0) 
  
  union
  
  /* source = 1 : Just CYBHI pats */
  
  select 
    s1.* 
  from cte_base as b

  cross apply (
    select 
        cpvdc.clientID
      , cpvdc.patID 
    from dbo.CYBHI_PATS_VIEW_DATA_CORE (b.clientID) as cpvdc  
    where 
	  (b.[source] = 1)
  ) as s1
  where 
   (b.[source] = 1)
)
,
cte_p1
as
(
  select 
      p0.clientID
    , p0.patID 
    , hasCompleteInsuranceInfo = isnull(pic4.hasCompleteInsuranceInfo,0)  
  from cte_p0 as p0

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
             when pic2.beneficiaryLastName       = '' then 0
	         when pic2.beneficiaryFirstName      = '' then 0
	         when pic2.beneficiaryID             = '' then 0
	         when pic2.carrierCode               = '' then 0
	         when pic2.policyHolderName          = '' then 0
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
)
,
cte_p2
as
(
  select 
      p1.*
    , pg3.patPerIDs
    , hasPGEmails = convert(bit,(iif((pg3.patPerIDs is null),0,1)))
  from cte_p1 as p1
  
  /* Get pg rec ids for pgs that have email addresses */
  
  cross apply (
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
          , pep.EMAIL    	
        from dbo.PATIENTS_PERSON as ppp 
        join dbo.PERSONS_PERSON  as pep on pep.ID = ppp.PERSON_ID
        where (
              ((ppp.CLIENT_ID = p1.clientID) and (ppp.PATIENT_ID = p1.patID))
          and (ppp.ACTIVE = 1)
          and (pep.CLASS_ID_1 = 1)
	      and (pep.ACTIVE     = 1)    
	      and (pep.EMAIL != '')
        )
      ) as pg1
      group by
        pg1.EMAIL
    ) as pg2
  ) as pg3
  where 
    (p1.hasCompleteInsuranceInfo = 0)
)
,
cte_p3
as
(
  select 
      p2.* 
	, hasCurrentRequest = convert(bit,(iif((pirr2.id is null),0,1)))      
  from cte_p2 as p2

  /* Get any current active requests */

  outer apply (
    select top 1
	  pirr1.id	         	
	from dbo.PATIENT_INFO_REQUESTS_RESPONSES as pirr1	            
	where (
            (pirr1.clientID       = p2.clientID)
        and (pirr1.patID          = p2.patID)
	    and (pirr1.completed      = 0)
	    and (pirr1.active         = 1)
	  )
  ) as pirr2
  where 
    (p2.hasPGEmails = 1)
)

select 
    p3.clientID
  , p3.patID
  , p3.patPerIDs
from cte_p3 as p3
where
  (p3.hasCurrentRequest = 0)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_INFO_REQUESTS_RESPONSES_TO_AUTO_GENERATE_VIEW] TO [webuser]
GO

  