use SPEDMON 
GO

/*---------------------------------------------------------------------------------------------------------*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_TRANSMISSION_GENERATION_APPLY_HOLDS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_APPLY_HOLDS
GO

/*---------------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_APPLY_HOLDS (  
    @transmissionID bigint       
  , @holdForDays    int
  , @todayDateOnly  datetime
  , @holdCount      int output
  , @releaseCount   int output
)
AS
BEGIN

set nocount on

set @holdCount    = 0
set @releaseCount = 0

/*--------------------------------------------------------------------------*/
/* Billing Provider Holds */
/* 1xx */
/*--------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Applying holds for billing provider'

/* Client - Submit Claims = No */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 105
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id        = t1.id
join dbo.CLIENTS_Client                                                as clc on clc.CLIENT_ID = t1.clientID
where 
  (clc.cybhiSubmitClaims = 0)
option(recompile)

/* Site has incomplete name or address data */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 120

from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id    = t1.id
join dbo.CYBHI_TRANSMISSION_GENERATION_GET_SITES (@transmissionID)     as ss  on ss.siteID = ctc.siteID
where (
      (ss.internalSite = 0) 
  and (ss.dataComplete = 0) 
)
option(recompile)

/* Site is not approved by TPA */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 130

from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id    = t1.id
join dbo.CYBHI_TRANSMISSION_GENERATION_GET_SITES (@transmissionID)     as ss  on ss.siteID = ctc.siteID
where (
      (ss.internalSite = 0) 
  and (ss.dataComplete = 1)
  and (ss.siteApproved = 0) 
)
option(recompile)

/*--------------------------------------------------------------------------*/
/* Patient Holds */
/* Part 1 of 2 */
/* 5xx */
/*--------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Applying holds for patients'

/* Patient - Submit claims = No  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 505
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PATIENTS_Patient                                              as pap on pap.PATIENT_ID = t1.patID
where (
  (pap.cybhiSubmitClaims = 0)
)
option(recompile)

/* Patient - Missing or incomplete address */

;with
cte_p1
as
(
  select 
      ctcID     = ctc.id
    , ppID      = isnull(pp2.ID,-1)
    , ppAddress = trim(isnull(pp2.ADDRESS_1,''))
	, ppCity    = trim(isnull(pp2.CITY     ,''))
	, ppState   = trim(isnull(pp2.[STATE]  ,''))
	, ppZip5    = trim(isnull(pp2.ZIP_5    ,''))
  from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
  join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
  outer apply (
    select top 1 
	    pp1.ID
	  , pp1.ADDRESS_1
	  , pp1.CITY
	  , pp1.[STATE]
	  , pp1.ZIP_5	
    from dbo.PATIENT_PLACES as pp1
    where (
          (pp1.PATIENT_ID         = t1.patID)
      and (pp1.PATIENT_PLACE_TYPE = 1)
      and (pp1.ACTIVE             = 1)
    ) 
    order by 
      pp1.ID desc
  ) as pp2
)
,
cte_p2
as
(
  select 
     p1.ctcID
   , holdForMissingOrIncompleteAddress = case 
       when p1.ppID      = -1 then 1
       when p1.ppAddress = '' then 1
	   when p1.ppCity    = '' then 1
	   when p1.ppState   = '' then 1
	   when p1.ppZip5    = '' then 1
	   else 0
	 end
from cte_p1 as p1
)

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 510
from cte_p2                              as p2
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as ctc on ctc.id = p2.ctcID
where 
  (p2.holdForMissingOrIncompleteAddress = 1)
option(recompile)

/* Patient - No insurance or insurance not supported by cybhi */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 520
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
where (
    (ctc.patInsuranceCarrierID = -1)
)
option(recompile)

/* Patient - No insurance member id */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 525
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
where (
        (ctc.patInsuranceMemberID = '')
	--and (ctc.useTpaIdAsInsuranceMemberID = 0)
)
option(recompile)

/* Patient - Unknown or No FEPA consent */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 530
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PATIENTS_Patient                                              as pap on pap.PATIENT_ID = t1.patID
where (
    (isnull(pap.ferpaConsent,0) = 0)  
)
option(recompile)

/* Patient - Not approved by TPA */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 550
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PATIENTS_Patient                                              as pap on pap.PATIENT_ID = t1.patID
where (
      (t1.useTpaIdAsInsuranceMemberID = 1)
  and (pap.cybhiTpaApproved           = 0)
)
option(recompile)

/* Patient - No TPA ID  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 560
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PATIENTS_Patient                                              as pap on pap.PATIENT_ID = t1.patID
where (
      (t1.useTpaIdAsInsuranceMemberID = 1)
  and (pap.cybhiTpaApproved           = 1)
  and (trim(isnull(pap.cybhiTpaID,'')) = '')
)
option(recompile)

/* Patient - DOS outside TPA enrollment  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 570
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PATIENTS_Patient                                              as pap on pap.PATIENT_ID = t1.patID
where (
      (t1.useTpaIdAsInsuranceMemberID  = 1)
  and (pap.cybhiTpaApproved            = 1)
  and (trim(isnull(pap.cybhiTpaID,'')) = '')
  and (t1.dos not between pap.cybhiTpaEnrollmentStartDate and pap.cybhiTpaEnrollmentEndDate)
)
option(recompile)

/* Patient - Aged out of program as of DOS */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 580
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PATIENTS_Patient                                              as pap on pap.PATIENT_ID = t1.patID
where (
  (datediff(year,pap.DATE_OF_BIRTH, t1.dos) >= 26)
)
option(recompile)

/*--------------------------------------------------------------------------*/
/* Rendering Provider Holds */
/* 2xx */
/*--------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Applying holds for rendering providers'

/* Rendering Practitioner - Discipline currently not permitted to tx */

/*
update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 200
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.renderingPracID
join dbo.PRACTITIONER_GROUPS                                           as pgd on  ((pgd.PRACTITIONER_ID = t1.renderingPracID) and (pgd.GROUP_TYPE in (1,2)))																			  
where (  pgd.GROUP_ID  in (
  282	/*Community Health Worker*/
, 289	/*Certified Wellness Coach */
))
option(recompile)
*/

/* Rendering Practitioner - Submit claims = No  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 205
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.renderingPracID
where (  
    (prp.cybhiSubmitClaims = 0)  
)
option(recompile)

/* Rendering Practitioner - No NPI  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 210
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.renderingPracID
where (  
    (trim(isnull(prp.npiNumber,'')) = '')  
)
option(recompile)

/* Rendering Practitioner - Not Approved by TPA */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 250
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.renderingPracID
where (
  (prp.cybhiTpaApproved = 0)
)
option(recompile)

/* Rendering Practitioner - No TPA ID  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 260
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.renderingPracID
where (  
      (prp.cybhiTpaApproved = 1)
  and (prp.cybhiTpaID is null)
)
option(recompile)

/* Rendering Practitioner - ACES screen provided but no ACES Cert */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 270
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.renderingPracID
join dbo.CLAIM_Procedures                                              as cp on cp.PROCEDURE_ID = t1.procedureID
where (  
      (cp.PROCEDURE_CODE in (N'G9919',N'G9920'))
  and (prp.acesCertCompletedOn is null)  
)
option(recompile)

/*--------------------------------------------------------------------------*/
/* ORP Provider Holds */
/* 3xx */
/*--------------------------------------------------------------------------*/

/* Orp Practitioner - No orp provider determined  
 * Note: This hold is CRITICAL for the rest of the tx logic to work.  Do not remove it!!!!
 */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 300
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
where 
  (t1.orpPracID is null)
option(recompile)

/* ORP Practitioner - Submit claims = No  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 305
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.orpPracID
where (  
    (prp.cybhiSubmitClaims = 0)  
)
option(recompile)

/* ORP Practitioner - No NPI  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 310
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.orpPracID
where (  
    (trim(isnull(prp.npiNumber,'')) = '')  
)
option(recompile)

/* ORP Practitioner - Not approved by TPA */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 350
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.orpPracID
where (
  (prp.cybhiTpaApproved = 0)
)
option(recompile)

/* ORP Practitioner - No TPA ID  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 360
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.orpPracID
where (  
      (prp.cybhiTpaApproved = 1)
  and (prp.cybhiTpaID is null)
)
option(recompile)

/* ORP Practitioner - ACES Screen Provided, No ACES Cert */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 370
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.orpPracID
join dbo.CLAIM_Procedures                                              as cp  on cp.PROCEDURE_ID     = t1.procedureID
where (  
      (cp.PROCEDURE_CODE in (N'G9919',N'G9920'))
  and (prp.acesCertCompletedOn is null)  
)
option(recompile)


/*--------------------------------------------------------------------------*/
/* Claiming Provider Holds */
/* 4xx */
/*--------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Applying holds for claiming providers'

/* Claiming Practitioner - No claiming provider determined  
 * Note: This hold is CRITICAL for the rest of the tx logic to work.  Do not remove it!!!!
 */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 400
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
where 
  (t1.claimingPracID is null)
option(recompile)

/* Claiming Practitioner - Submit claims = No  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 405
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.claimingPracID
where (  
    (prp.cybhiSubmitClaims = 0)  
)
option(recompile)

/* Claiming Practitioner - No NPI  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 410
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.claimingPracID
where (  
    (trim(isnull(prp.npiNumber,'')) = '')  
)
option(recompile)

/* Claiming Practitioner - Not approved by TPA */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 450
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.claimingPracID
where (
  (prp.cybhiTpaApproved = 0)
)
option(recompile)

/* Claiming Practitioner - No TPA ID  */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 460
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.claimingPracID
where (  
      (prp.cybhiTpaApproved = 1)
  and (prp.cybhiTpaID is null)
)
option(recompile)

/* Claiming Practitioner - ACES Screen Provided, No ACES Cert */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 470
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PRACTITIONER_Practitioner                                     as prp on prp.PRACTITIONER_ID = t1.claimingPracID
join dbo.CLAIM_Procedures                                              as cp  on cp.PROCEDURE_ID     = t1.procedureID
where (  
      (cp.PROCEDURE_CODE in (N'G9919',N'G9920'))
  and (prp.acesCertCompletedOn is null)  
)
option(recompile)

/*--------------------------------------------------------------------------*/
/* Patient Holds */
/* Part 2 of 2 */
/* 5xx */
/*--------------------------------------------------------------------------*/

/* Patient - TPA Enrollment State is 9 = Accepted But Info Sent To TPA By Mistake */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 540
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.PATIENTS_Patient                                              as pap on pap.PATIENT_ID = t1.patID
where (
      (t1.useTpaIdAsInsuranceMemberID = 1)
  and (pap.cybhiTpaApproved           = 1)  
  and (pap.cybhiTpaEnrollmentState    = 9)
)
option(recompile)


/*--------------------------------------------------------------------------*/
/* Quality Holds */
/* 6xx */
/*--------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Applying quality holds'

/* Claim was entered recently and the number of hold days has not passed yet.  This hold is to ensure
 * that practitioners have a chance to correct mistakes before transmission.
 */

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 600
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
where (
       (@holdForDays > 0) /* If hold for days is 0 (or less... although this should not apply) dont apply this hold */
   and (datediff(day,t1.created, @todayDateOnly) <= @holdForDays)
   /* TODO: Add use or lose logic */
)
option(recompile)

/*--------------------------------------------------------------------------*/
/* Payer Holds */
/* 8xxx */
/*--------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Applying payer holds'

/* Do not transmit procedures with codes starting with G */

/*update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 8000
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS                               as ctc on ctc.id = t1.id
join dbo.CLAIM_Procedures                                              as cp on cp.PROCEDURE_ID = t1.procedureID
where (  
  (cp.PROCEDURE_CODE like (N'G%'))
)
*/

/*--------------------------------------------------------------------------*/
/* Transmission Limit Holds */
/* 9xxx */
/*--------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Applying tx limit holds'

/* 9000 Not enough space in transmission, generate another  */

declare @overFlowStats as table (
   id     bigint
  ,svcCtr int
unique clustered (id)
)

insert into @overFlowStats (id, svcCtr)
select   
   t1.id
 , svcCtr = DENSE_RANK() over (partition by t1.patID order by t1.dos asc, t1.svcRecID)
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1
option(recompile)

delete from @overFlowStats where svcCtr < 100 option(recompile)

update ctc 
set
    ctc.claimHeld = 1
  , ctc.holdCode  = 9000
from @overFlowStats as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as ctc on ctc.id = t1.id
option(recompile)

exec dbo.PRINT_STATUS_MESSAGE 'Getting total holds and releases'

select @holdCount    = count(t1.id) from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 1) as t1 option(recompile)
select @releaseCount = count(t1.id) from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as t1 option(recompile)

return(0)

END
GO
