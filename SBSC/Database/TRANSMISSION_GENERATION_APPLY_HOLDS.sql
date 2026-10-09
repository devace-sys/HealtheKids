/*##################################################################################################*/
/* BUCKET ROUTINE */
/*##################################################################################################*/

use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_APPLY_HOLDS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_APPLY_HOLDS
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_APPLY_HOLDS (
    @generationID   as bigint
  , @predictProxies as bit
  , @heldClaimCount as bigint output
)
AS
BEGIN


SET NOCOUNT ON


declare @claimSource as bigint 



declare @msgStr as varchar(512) = ''

set @heldClaimCount = 0

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Starting'

select top 1 
    @claimSource    = tg.claimSource
from dbo.TRANSMISSION_GENERATIONS as tg
where (tg.id = @generationID)

if (@claimSource = 3)
begin
  
  exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - No hold checks performed for CIF voids'
  set @heldClaimCount = 0
  exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Complete'
  return
end

/******************************************
 *
 *		Given a specific generation, sequentially apply 
 *		a series of holds to the claims in that generation.
 *
 *		Holds should be applied in the 
 *		order of cheapest to most expensive;
 * 		
 *		This reduces the set of claims that 
 *		need to be processed by the more expensive 
 *		hold processes.
 *		
 *		A hold is applied by:
 *			* looking at the set of claims that 
 *			  have not been processed for that generation
 *			 (see TRANSMISSION_GENERATION_LIST_CLAIMS_UNPROCESSED)
 *			 
 *			* Determining which claims in that set should be held
 *			
 *			* Inserting those claims into TRANSMISSION_GENERATION_LIST_CLAIMS_HELD
 *				with an appropriate hold message 
 *				
 *			* Running TRANSMISSION_GENERATION_CLEAN_HELD_CLAIMS for the current generation
 *				this removes those held held claims from the list of claims that need to be processed
 *				
 *	
 ******************************************/
 
  declare 
 @clientID  AS int,
 @patientID as bigint,
 @claimID as bigint,
 @oldestDOS AS date,
 @newestDOS as date,
 @oldestEntry as date,
 @newestEntry as date
 ,@generationDate as date
 ,@today datetime
 
 set @today = GETDATE()
 
declare @rmtsStartsOn as date
set @rmtsStartsOn = dbo.CONST_RMTS_PARTICIPATION_REQUIRED_START_DATE()
declare @dSupStartsOn as date
set @dSupStartsOn = dbo.CONST_DIRECT_SUPERVISION_REQUIRED_START_DATE()

declare @nonImpliedParentConsentClients as table (
  CLIENT_ID bigint
)

insert into @nonImpliedParentConsentClients
select CLIENT_ID 
from dbo.CLIENTS_Client 
where (parentConsentAgreement = 0)

 select top 1
	 @clientID = tg.clientID 
	,@patientID = tg.patientID
	,@claimID = tg.claimID
	,@oldestDOS =  tg.oldestDOS
	,@newestDOS = tg.newestDOS
	,@oldestEntry = tg.oldestEntry
	,@newestEntry = tg.newestEntry
	,@generationDate = tg.dateCreated
from dbo.TRANSMISSION_GENERATIONS			as tg 
where tg.id = @generationID
 
  
 /* Apply holds to claims in generation */
 
 create table #gen_claims_procWkSheet (claimID bigint, hold bit, reason nvarchar(300))
 create clustered index claimIdx on #gen_claims_procWkSheet (claimID);
 
 insert into dbo.#gen_claims_procWkSheet (claimID)
 select ClaimID from TRANSMISSION_GENERATION_LIST_CLAIMS
 where GenerationID = @generationID
 
 /**** BEGIN QUICK HOLDS ****/
 
 /* Start by applying quick holds */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Zero Unit Claims'

update dbo.#gen_claims_procWkSheet
	set  hold = 1
		,reason =  'Claim is for zero units'
where claimID in
(
select pws.claimID
from dbo.#gen_claims_procWkSheet		as pws	
inner join dbo.CLAIM_Claim				as cc 
     on cc.CLAIM_ID = pws.ClaimID
     and cc.SERVICE_UNITS = 0
 where pws.hold is null
)

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Patient Flagged NOSUBMIT'

update dbo.#gen_claims_procWkSheet
	set  hold = 1
		,reason =  'Patient record flagged to not submit claims'
where claimID in
(
	select pws.claimID
	from dbo.#gen_claims_procWkSheet								as pws
	inner join dbo.CLAIM_Claim									as cc 
		 on cc.CLAIM_ID = pws.ClaimID
	inner join dbo.PATIENTS_Patient								as pp
		 on pp.PATIENT_ID = cc.PATIENT_ID		
		and (
		     (SUBMIT_CLAIMS = 0) 
		  /* If the record is explicitly flagged NOT TRUE (Null or false) */
		  or ((SUBMIT_CLAIMS is null) 
		     and (cc.CLIENT_ID in (select CLIENT_ID from @nonImpliedParentConsentClients)))
		 ) 
	where pws.hold is null
)
		
exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Patient Flagged NOPARENTCONSENT'

--declare @parentConsentThreshold datetime = '20161121'

update dbo.#gen_claims_procWkSheet
	set  hold = 1
		,reason =  'Patient Record does not indicate Medi-Cal Consent by parents'

-- NESTED subquery; this WHERE clause contains a SELECT which contains a lengthy WHERE clause itself;
-- pay attention to parens and syntax
where claimID in
(

  select 
    pws.claimID
  from dbo.#gen_claims_procWkSheet		 as pws
  inner join dbo.CLAIM_Claim			 as cc  on cc.CLAIM_ID   = pws.ClaimID
  inner join dbo.PATIENTS_Patient		 as pp  on pp.PATIENT_ID = cc.PATIENT_ID
  inner join dbo.SERVICE_RECORD_CLAIMS   as src on src.claimID   = cc.CLAIM_ID
  inner join dbo.SERVICE_RECORDS         as sr  on sr.id         = src.svcRecID

  where

  ( -- opening WHERE of inner query


    /* Parent consent flag is either a explicit no or implied no */
    (

      /* Consent is explicitly forbidden */
      ( 
        isnull(pp.parentConsentMCAL, 1) 
         = 0
      )

      or
      (
      /* Client does not give implied consent */

        (pp.parentConsentMCAL is null)
        and 
        (
          CLIENT_ID IN
          ( SELECT CLIENT_ID FROM @nonImpliedParentConsentClients )
        )

      )
    )

	  /* Parental consent only applies to IEP/IFSP services.
	  *
	  * See : https://www.dhcs.ca.gov/provgovpart/Documents/ACLSS/LEA%20BOP/FAQs/FAQ_Parental_Con_Update_March_2018.pdf
	  *
	  * Q3. Do LEAs need to obtain consent from parents for providing non-IEP services?
	  * A. No. LEAs do not have to obtain parental consent to bill Medi-Cal before providing non- IEP/IFSP
	  * services to Medi-Cal eligible students, since this consent is provided during the Medi-Cal application process.
	  * However, students with services covered under IDEA (under an IEP) do require parental consent, since IDEA created
	  * a statutory requirement to obtain parental permission before billing a Medicaid program.
	  */

    and (sr.isIFSPorIEP = 1)

    /* Not already held */

    and (pws.hold is null)

  )
  -- CLOSING WHERE; closing inner subquery


)  -- CLOSING WHERE of UPDATE
	
exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Client Does Not Claim For NonIEP (NoPlan) Services'

;with noplanProcedures as
(
	select distinct vac.PROCEDURE_ID 
	from dbo.SERVICES_VIEW_ALL_CORE(null,null,3,null,null,null,null,null,null) vac
		inner join dbo.CLAIM_PROCEDURES_TRANSMITTABLE()		as cpt 
			on vac.PROCEDURE_ID = cpt.procedure_id
	where vac.PROCEDURE_CODE_IS_Q = 0
)	

update dbo.#gen_claims_procWkSheet
	set  hold = 1
		,reason =  'Service is NoPlan and Client does not claim Non-IEP services'
where claimID in
(
	select claimID
	from dbo.#gen_claims_procWkSheet								as pws
	inner join dbo.CLAIM_Claim cc on pws.ClaimID= cc.CLAIM_ID
	inner join noplanProcedures										as noplan_procs
		 on noplan_procs.PROCEDURE_ID = cc.PROCEDURE_ID

	inner join dbo.CLIENTS_Client cli
		 on cli.client_ID = cc.CLIENT_ID
		 and (isnull(cli.claimnoplan,0) = 0)
   and pws.hold is null
)

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Client Does Not Claim For Overlapping CYBHI Services'

;with leaBopNonIEPMentalHealthProcedures as
(
  select distinct 
	  vac.PROCEDURE_ID
  from dbo.SERVICES_VIEW_ALL_CORE (null,null,3,null,null,null,null,null,null) as vac
  join CLAIM_PROCEDURES_TRANSMITTABLE()                                       as cpt on cpt.PROCEDURE_ID = vac.PROCEDURE_ID
  where (
	      (vac.GROUP_SERVICE_CLASS_NAME_ID  = 2)
	  and (vac.PROCEDURE_BILLING_PROGRAM_ID = 1)
  )
)	

update dbo.#gen_claims_procWkSheet
	set   hold   = 1
		, reason = 'Client participates in CYBHI and this LEA BOP service overlaps with CYBHI'
where claimID in
(
	select 
	  claimID
	from dbo.#gen_claims_procWkSheet	    as pws
	join dbo.CLAIM_Claim                    as cc           on cc.CLAIM_ID               = pws.ClaimID
	join leaBopNonIEPMentalHealthProcedures	as noplan_procs on noplan_procs.PROCEDURE_ID = cc.PROCEDURE_ID
	join dbo.CLIENTS_Client                 as cli          on ((cli.client_ID = cc.CLIENT_ID) 
	                                                             and (cli.cybhi = 1)
																 and (cli.cybhiDoNotClaimOverappingLEABopSvcs = 1))
    where 
      (pws.hold is null)
)

/* Entry-window holds */

/* Each client has a defined length of days before which an entered claim can be transmitted 
	(this allows the practitioners at that client to correct their work before it's locked for transmit)
	SBSC input staff are not subject to this hold.
*/

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Num Days To Hold For Client Entered Work'


declare @clientDayHoldLengths table (clientID bigint PRIMARY KEY, holdInterval int,calcHoldEntryDate date)
declare @SBSCStaffUsers table (numerUserID bigint PRIMARY KEY)

/* TODO: Once clients have data values for hold length, change the constants here to that reference */
insert into @clientDayHoldLengths (clientID, holdInterval, calcHoldEntryDate)
select	 CLIENT_ID
		,[numDaysToHoldClientEnteredClaims]
		,DATEADD(day, (-1*[numDaysToHoldClientEnteredClaims]), CONVERT(DATE,@today))  /* TODO: Use the generation creation datetime for this mebbe? */
from dbo.CLIENTS_Client as cc

/* Temp cache table to reduce join lookup */
insert into @SBSCStaffUsers (numerUserID)
	select u.userrid 
	from Users.dbo.Users as u
	inner join Users.dbo.Membership as m 
		on u.UserId = m.UserId
		and m.SBSC_Employee = 1

;with claimData as
(
	select	 cc.CLAIM_ID
			,cc.ENTRY_DATE
			,cc.SERVICE_DATE
			,cc.CLIENT_ID
			,cc.USER_ID 
			
			from  dbo.#gen_claims_procWkSheet					as pws
		inner join dbo.CLAIM_Claim								as cc
			on pws.claimID = cc.CLAIM_ID
	where pws.hold is null
)

,entryUserFlags as
(
	select 
		 case when cc.ENTRY_DATE >= hel.calcHoldEntryDate	then 1 else 0 end	as [InEntryDateWindow]
		,case when hel.holdInterval = 0						then 1 else 0 end	as [ZeroDayInterval]
		,case when staff.numerUserID is not null			then 1 else 0 end	as [IsSbscStaff]
		,CLAIM_ID
		,SERVICE_DATE
	 from 
		claimData as cc
		inner join @clientDayHoldLengths	as hel 
			on cc.CLIENT_ID = hel.clientID
		left outer join @SBSCStaffUsers		as staff 
			on cc.USER_ID = staff.numerUserID
)

,StaffSvcDateUoLFlags as
(
	select 
		case when isnull(UoL,0) = 1 then 1 else 0 end as WillBeLostIfHeld
		,IsSbscStaff
		,InEntryDateWindow
		,[ZeroDayInterval]
		,CLAIM_ID

	from 
		entryUserFlags						as euf
		outer apply
		(
			select dbo.CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM(euf.Service_date, @today) as UoL
			where euf.InEntryDateWindow = 1
		)										as subOrLose
)
update dbo.#gen_claims_procWkSheet
	set  hold = 1
		,reason =  'Service falls within the hold period for the client' /* TODO: Include start of hold period for this client in note ? */
where claimID in
(
	select 
	CLAIM_ID
	from StaffSvcDateUoLFlags
	where 
								/* HOLD IF:										*/
		WillBeLostIfHeld = 0	/* We won't be losing it this time				*/
	and IsSbscStaff = 0			/* The user isn't one of ours					*/
	and (
		InEntryDateWindow = 1	/* The claim is within the date range to hold	*/
		or
		ZeroDayInterval = 1		/* Or there is no interval hold for the client	*/
		)
)
	

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Procedures Clients Do Not Want To Submit In Date Range'

 /* Client holds for procedures in date ranges */

/* BEGIN CLIENT-PROCEDURE HOLDS */


/* TODO: This query might be putting out duplicate hold entries? */
;with claims as
(
	select claimID
	from dbo.#gen_claims_procWkSheet								as pws
	where pws.hold is null
)

,client_procedure_filter as
(
	select c.ClaimID, cc.CLIENT_ID, cc.PROCEDURE_ID, cc.ENTRY_DATE, cc.SERVICE_DATE 
	from claims						as c
	inner join dbo.CLAIM_Claim		as cc 
		on c.ClaimID = cc.CLAIM_ID
	where 
		cc.CLIENT_ID in (select CLIENT_ID from dbo.TRANSMISSION_HOLDS_CLIENT_PROCEDURE)
	and cc.PROCEDURE_ID in (select PROCEDURE_ID from dbo.TRANSMISSION_HOLDS_CLIENT_PROCEDURE)
)

,client_procedure_holds as
(
	select cpf.ClaimID, cpf.CLIENT_ID, cpf.PROCEDURE_ID, thcp.ID as THCP_ID
	from client_procedure_filter							as cpf

inner join dbo.TRANSMISSION_HOLDS_CLIENT_PROCEDURE			as thcp
	on thcp.CLIENT_ID = cpf.CLIENT_ID
	and thcp.PROCEDURE_ID = cpf.PROCEDURE_ID
	and 
	(
		(
			thcp.HOLD_BY_ENTRY_DATE = 1
			and (cpf.ENTRY_DATE >= thcp.ENTRY_HOLD_START or thcp.ENTRY_HOLD_START is null)
			and (cpf.ENTRY_DATE < dateadd(day,1,thcp.ENTRY_HOLD_END) or thcp.ENTRY_HOLD_END is null)
		)
	or (
			thcp.HOLD_BY_SERVICE_DATE = 1
			and (cpf.SERVICE_DATE >= thcp.DOS_HOLD_START or thcp.DOS_HOLD_START is null)
			and (cpf.SERVICE_DATE < dateadd(day,1,thcp.DOS_HOLD_END) or thcp.DOS_HOLD_END is null)
		)
	)
)

,data_breakdown_1 as
(
select 
/******************************************************/
	case when 
		thcp.HOLD_BY_ENTRY_DATE = 1 and ENTRY_HOLD_START is null and ENTRY_HOLD_END is null
		then 1 else 0 end as allEntDates
	
	,case when thcp.HOLD_BY_ENTRY_DATE = 1 and ENTRY_HOLD_START is null and ENTRY_HOLD_END is not null
		then 1 else 0 end as allEntBefore
		
	,case when thcp.HOLD_BY_ENTRY_DATE = 1 and ENTRY_HOLD_START is not null and ENTRY_HOLD_END is null
		then 1 else 0 end as allEntAfter
		
	,case when thcp.HOLD_BY_ENTRY_DATE = 1 and ENTRY_HOLD_START is not null and ENTRY_HOLD_END is not null
		then 1 else 0 end as entRange		
		
/*******************************************************/		
		
	,case when thcp.HOLD_BY_SERVICE_DATE = 1 and DOS_HOLD_START is null and DOS_HOLD_END is null
		then 1 else 0 end as allDOSDates
	
	,case when thcp.HOLD_BY_SERVICE_DATE = 1 and DOS_HOLD_START is null and DOS_HOLD_END is not null
		then 1 else 0 end as allDOSBefore
		
	,case when thcp.HOLD_BY_SERVICE_DATE = 1 and DOS_HOLD_START is not null and DOS_HOLD_END is null
		then 1 else 0 end as allDOSAfter
		
	,case when thcp.HOLD_BY_SERVICE_DATE = 1 and DOS_HOLD_START is not null and DOS_HOLD_END is not null
		then 1 else 0 end as dosRange	
	
,ClaimID
,thcp.*

 from client_procedure_holds							as cph
 inner join dbo.TRANSMISSION_HOLDS_CLIENT_PROCEDURE		as thcp
	on thcp.ID = cph.THCP_ID
)

, data_breakdown_2 as
(
select 
 case when allEntDates = 1 then 'All Entry Dates' else null end																							as aed
,case when allEntBefore = 1 then 'All Entries Before ' + convert(nvarchar(10), ENTRY_HOLD_END,102) else null end										as aeb
,case when allEntAfter = 1 then 'All Entries After ' + convert(nvarchar(10), ENTRY_HOLD_START,102) else null end										as aea
,case when entRange = 1 then 'Entered Between: ' + convert(nvarchar(10), ENTRY_HOLD_START,102) + ' - ' + convert(nvarchar(10), ENTRY_HOLD_END,102) end	as eb

,case when allDOSDates = 1 then 'All Service Dates' else null end																						as asd
,case when allDOSBefore = 1 then 'All Services Before ' + convert(nvarchar(10), DOS_HOLD_END,102) else null end											as asb
,case when allDOSAfter = 1 then 'All Services After ' + convert(nvarchar(10), DOS_HOLD_START,102) else null end											as asa
,case when dosRange = 1 then 'Services Between: ' + convert(nvarchar(10), DOS_HOLD_START,102) + ' - ' + convert(nvarchar(10), DOS_HOLD_END,102) end		as sb

, data_breakdown_1.PROCEDURE_ID
, data_breakdown_1.CLIENT_ID
, data_breakdown_1.claimID

 from data_breakdown_1
)

update dbo.#gen_claims_procWkSheet
	set hold = 1, 
		reason =  
		  'Client '
		+ convert(nvarchar(10), client_id) 
		+ ' is not allowed to transmit procedure ' 
		+ convert(nvarchar(10), procedure_id) 
		+ ' for date range(s): '
		+ ISNULL(COALESCE(aed,aeb,aea,eb),'') 
		+ ' '
		+ ISNULL(COALESCE(asd,asb,asa,sb),'')
from dbo.#gen_claims_procWkSheet		as pws
inner join data_breakdown_2									as db2
	on db2.ClaimID = pws.ClaimID
	
where 1=1
and pws.hold is null


--/* END CLIENT-PROCEDURE HOLDS */
 
exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - TCM Hold For Entire Client'

 declare @tcmProcs table (PROCEDURE_ID bigint)
 
 insert into @tcmProcs (PROCEDURE_ID)
 	select distinct cpt.PROCEDURE_ID 
 	from dbo.SERVICES_VIEW_ALL_CORE(null,null,null,dbo.CONST_SERVICES_TCM(),null,null,null,null,null)	as vac
	inner join dbo.CLAIM_PROCEDURES_TRANSMITTABLE()														as cpt 
		on vac.PROCEDURE_ID = cpt.procedure_id
	where vac.PROCEDURE_CODE_IS_Q = 0
	
 /* No TCM on this date for this client */
  
update dbo.#gen_claims_procWkSheet
set 
    hold = 1
  , reason = 'Client does not support TCM on the claiming DOS'
where claimID in (
    select 
	  pws.claimID 
	from dbo.#gen_claims_procWkSheet	as pws
	inner join dbo.CLAIM_Claim			as cc  on cc.CLAIM_ID     = pws.ClaimID
	inner join @tcmProcs			    as tpt on cc.PROCEDURE_ID = tpt.PROCEDURE_ID
	cross apply (
	  select top 1 
	    tfhv1.claimTCM 
	  from dbo.CLAIM_TCM_FLAG_HISTORY_VIEW ( 1, @clientID ) as tfhv1
      where (
            (cc.ENTRY_DATE between tfhv1.entryStartDate and tfhv1.entryEndDate)
        and (cc.SERVICE_DATE >= tfhv1.effectiveDate)
	  )
	) as tfhv2

	where ((pws.hold is null) and (tfhv2.claimTCM = 0))
)
 
/* Don't transmit TCM for this practitioner */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - TCM Hold For Given Practitioner'

update dbo.#gen_claims_procWkSheet
set 
   hold    = 1
 , reason = 'Practitioner is flagged to not bill TCM on the date of service'
where claimID in
(
  
  select 
    pws.claimID
  from dbo.#gen_claims_procWkSheet		   as pws
  inner join dbo.CLAIM_Claim			   as cc  on cc.CLAIM_ID        = pws.ClaimID
  inner join  @tcmProcs				       as tpt on cc.PROCEDURE_ID    = tpt.procedure_id
  inner join dbo.PRACTITIONER_Practitioner as pp  on cc.PRACTITIONER_ID = pp.PRACTITIONER_ID
  cross apply ( 
    select top 1 
	  tfhv1.claimTCM 
    from dbo.CLAIM_TCM_FLAG_HISTORY_VIEW ( 2, cc.PRACTITIONER_ID) as tfhv1
    where (
          (cc.ENTRY_DATE between tfhv1.entryStartDate and tfhv1.entryEndDate)
      and (cc.SERVICE_DATE >= tfhv1.effectiveDate)
    )
  ) as tfhv2    
  where ((pws.hold is null) and (tfhv2.claimTCM = 0))
)

 /* Hold all this practitioner's work */
 
exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Practitioner Flagged as NOSUBMIT'

 
 update dbo.#gen_claims_procWkSheet
	set hold = 1, reason = 'Practitioner is flagged as DO NOT SUBMIT for the period including the service date' 
	where claimID in
	(
		select pws.claimID
		from dbo.#gen_claims_procWkSheet					as pws
		inner join dbo.CLAIM_Claim										as cc
			on cc.CLAIM_ID = pws.ClaimID
		inner join dbo.PRACTITIONER_Practitioner						as pp
			 on cc.PRACTITIONER_ID = pp.PRACTITIONER_ID
			 and pp.SUBMIT_CLAIMS = 0
		where pws.hold is null
    )

/* Common hold data for RMTS and Supervision */

declare @commonClaimHoldData as table (
   ClaimID bigint
 , HoldData varchar(max)
unique clustered (ClaimID)
)

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Getting Common Claim Hold Data for RMTS and Supervision'
 
insert into @commonClaimHoldData
select 
   pws.ClaimID
 , HoldData = dbo.HOLD_CLAIM_GET_COMMON_CLAIM_DATA(pws.ClaimID)
from dbo.#gen_claims_procWkSheet as pws 
where (pws.hold is null)

/* RMTS Participation hold commmon */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Getting All Possible RMTS Participants'
 
declare @rmtsParticipantsPossibleCsvStr as varchar(max)
 
 select 
   @rmtsParticipantsPossibleCsvStr = STRING_AGG (convert(varchar(max), ppvc.id),',')  
 from dbo.RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE(@clientID) as ppvc


exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - RMTS Participation Holds'
 
 /* RMTS Participation hold */

 update pws1 
 set 
     pws1.hold   = 1
   , pws1.reason = rmts2.REASON
 from dbo.#gen_claims_procWkSheet as pws1
 join @commonClaimHoldData as cchd on cchd.ClaimID = pws1.ClaimID
 cross apply (
   select top 1       
	 rmts1.REASON 
   from dbo.RMTS_HOLD_CLAIM(@clientID,@rmtsStartsOn,@rmtsParticipantsPossibleCsvStr,cchd.HoldData) as rmts1 
   where (rmts1.HOLD = 1)
  ) as rmts2
  where (pws1.hold is null)

 /* Supervision */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Practitioner Direct Supervision Holds'

update pws1 
 set 
     pws1.hold   = 1
   , pws1.reason = dsup2.REASON
 from dbo.#gen_claims_procWkSheet as pws1
 join @commonClaimHoldData        as cchd on cchd.ClaimID = pws1.ClaimID
 cross apply (
   select top 1        
	 dsup1.REASON 
   from dbo.PRAC_DIRECT_SUPERVISION_HOLD_CLAIM (@dSupStartsOn,cchd.HoldData) as dsup1 
   where (dsup1.HOLD = 1)
  ) as dsup2
  where (pws1.hold is null)

/* CPR Certification required */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Practitioner CPR Certification Required'

update pws1 
 set 
     pws1.hold   = 1
   , pws1.reason = dsup2.REASON
 from dbo.#gen_claims_procWkSheet as pws1
 join @commonClaimHoldData        as cchd on cchd.ClaimID = pws1.ClaimID
 cross apply (
   select top 1        
	 dsup1.REASON 
   from dbo.PRAC_CPR_CERT_REQUIRED_HOLD_CLAIM (cchd.HoldData) as dsup1 
   where (dsup1.HOLD = 1)
  ) as dsup2
  where (pws1.hold is null)

/* ACES Certification required */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - ACES Certification Required'

update pws1 
 set 
     pws1.hold   = 1
   , pws1.reason = dsup2.REASON
 from dbo.#gen_claims_procWkSheet as pws1
 join @commonClaimHoldData        as cchd on cchd.ClaimID = pws1.ClaimID
 cross apply (
   select top 1        
	 dsup1.REASON 
   from dbo.PRAC_ACES_CERT_REQUIRED_HOLD_CLAIM (cchd.HoldData) as dsup1 
   where (dsup1.HOLD = 1)
  ) as dsup2
  where (pws1.hold is null)

 /* Unfinished batches */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Unfinished Input Batches'

 update dbo.#gen_claims_procWkSheet
	set hold = 1, reason = holdreason
	from
	(
	select pws.claimID, 'The batch this service was in (ref '+ ibsr.reference +') has not been marked as Finished Work (200)'  as holdreason
	from dbo.#gen_claims_procWkSheet								as pws
	left outer join dbo.SERVICE_RECORD_CLAIMS						as src
		on pws.ClaimID = src.claimID
	left outer join dbo.SERVICE_RECORDS								as sr 
		 on src.svcRecID = sr.id 
	left outer join dbo.INPUT_BATCHES_SERVICE_RECORDS				as ibsr
		on sr.id = ibsr.svcRecID
	left outer join dbo.INPUT_BATCHES								as ib
		on ib.id = ibsr.inputbatchid
		and ib.current_status_code <> 200 /* Finished Work */
	where ib.id is not null	 
	and pws.hold is null
	) batchHold
	where batchHold.claimID = #gen_claims_procWkSheet.claimID
	
 /**** END QUICK HOLDS ****/


 /* Journal or service record approval */
 
exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Waiting for Journal or Service Record Approval'
 
 update dbo.#gen_claims_procWkSheet
	set 
	  hold = 1
	, reason = 'Waiting for journal or service record approval' 
	where claimID in
	(
       select 
         src.claimID  
       from dbo.CLAIMS_TO_HOLD_VIEW_CORE(@clientID,@oldestDOS,@newestDOS) as ch
       join dbo.SERVICE_RECORD_CLAIMS                          as src on src.svcRecID = ch.svcRecID
       where (
         (ch.waitingForPracSupApproval = 1) 
        or (ch.waitingForJournal = 1)
       )
     )

 /* Non ORP compliant treatment services */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - ORP Compliance'
 
 update dbo.#gen_claims_procWkSheet
     set 
	  hold = 1
	, reason = 'Claim is not ORP compliant' 
	where claimID in
	(
       select 
         src.claimID  
       from dbo.CLAIMS_TO_HOLD_VIEW_CORE(@clientID,@oldestDOS,@newestDOS) as ch
       join dbo.SERVICE_RECORD_CLAIMS                          as src on src.svcRecID = ch.svcRecID
       where (
         (ch.waitingForValidOrp = 1)         
       )
     )

/* Secondary check for ORP compliance.  This checks if the orpPracId associated with the claim
   has a valid NPI, etc.  This is meant to catch claims that were originally OK when entered
   or updated by the automatch routine, but have since had their associated orp either removed
   or the orp npi data has changed. */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Revalidate ORP Compliance'
 
 update dbo.#gen_claims_procWkSheet
 set 
      hold = 1
    , reason = 'Claim is not ORP compliant' 
 where claimID in
 (
   select 
     CLAIM_ID as claimID
   from dbo.CLAIMS_NOT_SUBMITTED_CURRENT_ORP_STATUS_VIEW (@clientID,@oldestDOS,0)
 )

/* Speech treatments with no covering PBS */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Speech Covering PBS Compliance'


  update dbo.#gen_claims_procWkSheet
   set 
	  hold = 1
	, reason = 'Speech claim does not have a covering PBS in SpEdCare' 
  where claimID in
  ( 
    select           
      cc.CLAIM_ID as claimID      
    from dbo.#gen_claims_procWkSheet as pws 
    join dbo.CLAIM_Claim             as cc  on cc.CLAIM_ID = pws.claimID
    join dbo.CLAIM_Procedures        as cp  on cp.PROCEDURE_ID = cc.PROCEDURE_ID
    join dbo.GROUP_GROUP             as gg  on gg.GROUP_ID = cc.GROUP_ID

    outer apply (
      select top 1
        pbsd.ID 
      from dbo.CLIENT_PBS_DOCUMENTATION as pbsd
      where (             
             (pbsd.CLIENT_ID                        = cc.CLIENT_ID)
         and (pbsd.GROUP_SERVICE_CLASS_PARTITION_ID = 5)
         and (pbsd.GROUP_SERVICE_CLASS_NAME_ID      = 9)
         and (convert(date,cc.SERVICE_DATE) between pbsd.START_DATE and pbsd.END_DATE)
         and (pbsd.ACTIVE = 1)         
      )
    ) as pbs
    where (          
          (cp.SERVICE_TYPE_ID = dbo.CONST_SERVICES_TREATMENT())
      and (gg.GROUP_BASE = 'Speech')
      and (pws.hold is null)
      and (pbs.ID is null)
    )
)


/* transportation holds */
--------print 'Applying transportation holds'

--------   insert into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD(GenerationID, ClaimID, holdReason)
--------	select @generationID, tglcu.claimID, 'No Covering Service for transportation claim'
--------	from dbo.#gen_claims_procWkSheet as tglcu
--------	  inner join dbo.CLAIMS_TRANSMISSION_LIST_VIEW_CLIENT_TRANSPORTATION(@generationID, @clientID, @patientID, @claimID, @oldestDOS, @newestDOS, @oldestEntry, @newestEntry)	as vct
--------		on vct.transClaim = tglcu.ClaimID
--------		and vct.matchingClaim is null
--------		where 1=1 
--------			and tglcu.hold is null
--------option(recompile)

--------exec dbo.TRANSMISSION_GENERATION_CLEAN_HELD_CLAIMS @generationID

 
 declare @transportationProcs table (procedureID bigint)
 
 declare @coreTransportClaims table (claimID bigint, clientID bigint, serviceDate datetime, BIC nvarchar(14) )
 
 declare @coreTransportClaimSlots table (clientID bigint, serviceDate datetime, BIC nvarchar(14), 
			UNIQUE NONCLUSTERED ([clientID], [serviceDate], [BIC])  )
 
 declare @transportationClients table (transClientID bigint, matchClientID bigint)
 
 declare @matchableClaims table (claimID bigint, clientID bigint, serviceDate datetime, BIC nvarchar(14) )
 
  declare @matchableClaimSlots table (clientID bigint, serviceDate datetime, BIC nvarchar(14), firstMatchingClaimID bigint,
			UNIQUE NONCLUSTERED ([clientID], [serviceDate], [BIC])  )
 
declare @transClaimsManApproved as table (
  CLAIM_ID bigint
  UNIQUE CLUSTERED (CLAIM_ID)
) 

/* 
 * Retrieve transportation claims that have been manually approved
 * by the client that are not held and have not been transmitted yet.  
 * This list is used to override the matching service
 */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Finding Transportation Services That Have Been Manually Approved By Client'

insert into @transClaimsManApproved (CLAIM_ID)
select 
  CLAIM_ID 
from dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEW_VIEW_PENDING_CLAIMS_CORE (@clientID,@oldestDOS)


exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Getting Transportation Procedure Data'

/* Get transportation procedures */

insert into @transportationProcs (procedureID)
 
select distinct cpt.PROCEDURE_ID 
	from dbo.SERVICES_VIEW_ALL_CORE(null,null,null,dbo.CONST_SERVICES_transport(),null,null,null,null,null) as vac
	inner join dbo.CLAIM_PROCEDURES_TRANSMITTABLE()															as cpt 
		on vac.PROCEDURE_ID = cpt.procedure_id
where vac.PROCEDURE_CODE_IS_Q = 0


exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Getting Transportation Claims To Check'

 ;with transportClaimsToCheck as
 (
	select claim.*, pp.BIC 
	from #gen_claims_procWkSheet pws
	inner join dbo.CLAIM_Claim as claim
	on pws.claimID = claim.CLAIM_ID
	inner join @transportationProcs as tp
		on claim.PROCEDURE_ID = tp.procedureID
	inner join dbo.PATIENTS_Patient as pp 
		on claim.PATIENT_ID = pp.PATIENT_ID
		/* TODO: We currently don't check archived BICs */
		and BIC <> ''
		and BIC is not null
	where pws.hold is null
)
 insert into @coreTransportClaims (claimID, clientID, serviceDate, BIC)
 select cc.CLAIM_ID, cc.CLIENT_ID, cc.SERVICE_DATE, cc.BIC
 from transportClaimsToCheck as cc
 
exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Transportation Matching'

insert into @coreTransportClaimSlots (clientID, serviceDate, BIC )
		select distinct clientID, serviceDate, BIC 
		from @coreTransportClaims
 
 
 insert into @transportationClients (transClientID, matchClientID)
 	select TRANSPORT_CLIENT_ID,  MATCHING_CLIENT_ID from
		(
			/* Trivial case: Every client matches to itself */
			select 
				 cc.CLIENT_ID as TRANSPORT_CLIENT_ID
				,cc.CLIENT_ID as MATCHING_CLIENT_ID 
			from dbo.CLIENTS_Client							as cc
			union 
			/* Cross-client match case */
			select 
				 TRANSPORT_CLIENT_ID
				,MATCHING_CLIENT_ID 
			from dbo.Claim_Client_Match_Permit
		) validMatches
	where validMatches.TRANSPORT_CLIENT_ID in
	(select distinct clientID from @coreTransportClaimSlots)
 
 
	insert into @matchableClaims (claimID, clientID, serviceDate, BIC)
 		/* Get the list of claims that -might- match to transportation */
		select 
			 claim_id, client_ID, SERVICE_DATE, BIC

		from dbo.CLAIMS_TRANSMISSION_LIST_CORE_CLAIM_SET(null ,null, null, @oldestDOS, @newestDOS, null, null,1 ) mClms
			inner join claim_claim cc 
				on cc.claim_id = mclms.ClaimID
			inner join dbo.PATIENTS_Patient as pp 
				on cc.PATIENT_ID = pp.PATIENT_ID
		where 1=1
			and cc.Procedure_ID not in (select procedureid from @transportationProcs)
			and cc.SERVICE_DATE in (select serviceDate from @coreTransportClaimSlots)
			and cc.CLIENT_ID in (select matchClientID from @transportationClients)	   
	 


insert into @matchableClaimSlots (clientID, serviceDate, BIC, firstMatchingClaimID )
		select 
			 clientID
			,serviceDate
			,bic
			,MAX(claimID)		as firstMatClm
		from @matchableClaims		as mcs
		group by
		clientID
		, serviceDate 
		, bic
		
		/* transportation holds */

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Transportation Holds For Claims Without Matching Services'
	
	;with transportMatchData as
	(
	select ctc.clientID, ctc.serviceDate, ctc.BIC, ctc.claimID as transportClaimID, mcss.firstMatchingClaimID		as matchingClaim
	from @coreTransportClaimSlots			as tcss
	
	inner join @transportationClients  as tc
		on tcss.clientID = tc.transClientID 

	inner join @matchableClaimSlots			as mcss
	on 1=1
		and tc.matchClientID = mcss.clientID	
		and tcss.serviceDate = mcss.serviceDate
		and mcss.bic = tcss.bic		
		
	right outer join @coreTransportClaims as ctc
		on ctc.BIC = tcss.BIC
		and ctc.serviceDate = tcss.serviceDate
		and ctc.clientID = tcss.clientID
		
	)
	,claimTransportMatchIDs as
	(
	select transportClaimID, tmd.matchingClaim from transportMatchData as tmd
	)

	/* Flag transport claims as held if... */

	update dbo.#gen_claims_procWkSheet
	
	set 
	    hold   = 1
	  , reason = 'No Covering Service for transportation claim'
	
	from dbo.#gen_claims_procWkSheet    as pws
	inner join claimTransportMatchIDs	as ctmi on  ctmi.transportClaimID = pws.ClaimID
		                                        /* No matching service */
												and ctmi.matchingClaim is null		
		                                        /* Not held for another reason */
												and pws.hold is null		
		                                        /* Not in the list of manually approved by client */
												and pws.ClaimID not in (
												  select ClaimID = 0 /* Ensures we always have a set of something to test */
												  union all
												  select top 1 
		                                            tcma.CLAIM_ID as ClaimID 
		                                          from @transClaimsManApproved as tcma 		  
		                                          where(tcma.CLAIM_ID = pws.ClaimID)
												 )
			
/* Start applying proxy holds */
	
	/* Dump hold results from our worktable into our main held list */
	
exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Record What Claims Are Held'

	insert into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD (GenerationID, ClaimID, holdReason, GenListClaimID)
	select @generationID, pws.claimID, pws.reason, lc.id
	from dbo.#gen_claims_procWkSheet pws
	inner join dbo.TRANSMISSION_GENERATION_LIST_CLAIMS as lc
		on lc.ClaimID = pws.claimID
		and lc.GenerationID = @generationID
	where hold = 1

	/* Clean up temp table now that we've pushed data */
	drop table dbo.#gen_claims_procWkSheet
		
	
exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Find and Record What Claims Are Held Back By Proxy Routine'

 /* Finally apply proxy holds
 
    EAW Note: 
    
    dbo.TRANSMISSION_GENERATION_APPLY_PROXY_HOLDS   
    appears to insert records into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD    
    to track what is held for proxy    
    TRANSMISSION_GENERATION_CLIENT_837 -> TRANSMISSION_GENERATION_CLIENT_CLAIM_INIT    
    is where the actual hold/release and proxy claim generation occur
 
  */

exec dbo.TRANSMISSION_GENERATION_APPLY_PROXY_HOLDS @generationID,@predictProxies

exec dbo.PRINT_STATUS_MESSAGE 'Apply holds for claims that will not fix in transmission'
 
exec dbo.TRANSMISSION_GENERATION_APPLY_TX_SIZE_LIMIT_HOLDS @generationID

exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Get Held Claim Count'

select 
  @heldClaimCount = count(ch.ClaimID)
from dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD as ch
where 
  (ch.GenerationID = @generationID)

set @msgStr = 'Bucket Hold Routine - Held Claim Count : ' + convert(varchar(256),@heldClaimCount)

exec dbo.PRINT_STATUS_MESSAGE @msgStr
exec dbo.PRINT_STATUS_MESSAGE 'Bucket Hold Routine - Complete'

END
GO