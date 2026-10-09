USE SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_TRANSMISSION_LIST_VIEW_CLIENT_TRANSPORTATION') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_TRANSMISSION_LIST_VIEW_CLIENT_TRANSPORTATION
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].CLAIMS_TRANSMISSION_LIST_VIEW_CLIENT_TRANSPORTATION
(
	@generationID		as bigint
	,@clientID			as bigint
	,@patientID			as bigint
	,@claimID			as bigint
	,@oldestDOS			AS date
	,@newestDOS			as date
	,@oldestEntry		as date
	,@newestEntry		as date
	--,@transmissionDate	AS datetime	

)
RETURNS table as


RETURN
(

	with 
	transportation_procedures as
	(
		select distinct cpt.PROCEDURE_ID 
			from dbo.SERVICES_VIEW_ALL_CORE(null,null,null,dbo.CONST_SERVICES_transport(),null,null,null,null,null) as vac
			inner join dbo.CLAIM_PROCEDURES_TRANSMITTABLE()															as cpt 
				on vac.PROCEDURE_ID = cpt.procedure_id
		where vac.PROCEDURE_CODE_IS_Q = 0
	),

	tcm_procedures as /* This CTE is deprecated and is not used in this fn() */
	(
		select distinct cpt.PROCEDURE_ID from dbo.SERVICES_VIEW_ALL_CORE(null,null,null,dbo.CONST_SERVICES_TCM(),null,null,null,null,null) as vac
		inner join dbo.CLAIM_PROCEDURES_TRANSMITTABLE() as cpt on vac.PROCEDURE_ID = cpt.procedure_id
		where vac.PROCEDURE_CODE_IS_Q = 0
	),

	core_claims as
	(

		/* Get our core list of claims in this generation */
		select ClaimID from TRANSMISSION_GENERATION_RELEASEABLE_CLAIMS(@generationID)	as tglcu
		--where tglcu.generationID = @generationID
	),

	transportClaimsToCheck as
	(
		/* Filter core claims list down to only the ones that are transportation & are for patients w/ BICS */
		select rctrn.*, pp.bic
		from
		core_claims as ccs
		inner join dbo.CLAIM_Claim rctrn
		on ccs.ClaimID = rctrn.CLAIM_ID

		and rctrn.PROCEDURE_ID in (select * from transportation_procedures) 
		inner join dbo.PATIENTS_Patient pp on rctrn.PATIENT_ID = pp.PATIENT_ID
		/* TODO: We currently don't check archived BICs */
		and BIC <> ''
		and BIC is not null
	)

	,transportationClaimSlotSet as
	(
		/* Condense the set of transport claims down into a set of 'service slots' */
		select distinct client_ID, SERVICE_DATE, BIC 
		from transportClaimsToCheck
	)

	, matchingClaimSet as
	(
		/* Get the list of claims that -might- match to transportation */
		select 
			 claim_id
			,client_ID
			,SERVICE_DATE 
			,bic

		FROM dbo.CLAIMS_TRANSMISSION_LIST_HOLD_CLIENT_TRANSPORTATION_MATCHABLES(@generationID, @oldestDOS) as ctm
		where ctm.SERVICE_DATE in (SELECT SERVICE_DATE from transportationClaimSlotSet)
	)
	
	,matchingClaimSlotSet as
	(
		/* Condense the matching claims into 'service slots' - we include a matching claimID for verification purposes */
		select 
			 client_id
			,service_date
			,bic
			,MAX(claim_id)		as firstMatClm
		from matchingClaimSet		as mcs
		group by
		client_ID
		, SERVICE_DATE 
		, bic
	)

	,slotMatchCheck as
	(
		/* Compare transportation slots to matching claim slots */
		select tcss.*, mcss.firstMatClm		as matchingClaim
		from transportationClaimSlotSet			as tcss
		inner join matchingClaimSlotSet			as mcss
		on tcss.client_id = mcss.client_id
			and tcss.service_date = mcss.SERVICE_DATE
			and mcss.bic = tcss.bic
	)
	/* TODO: Slotmatch only returns valid matches - update query code below */
	,transClaimIDforSlot as
	(
		/* For the transportation slots that match to matching claim slots, identify the transportation claims that are part of that slot and one claim they match to */
	
		select 
			 trnClaims.claim_id		as transClaim
			,matchingClaim 
		from transportClaimsToCheck					as trnClaims
		left outer join
		slotMatchCheck								as smc
		on
			trnClaims.client_id = smc.client_ID
			and trnClaims.SERVICE_DATE = smc.service_date 
			and trnClaims.BIC = smc.BIC
	)
	
	/* Final Output: A transportation claim and a claim for a matching serice */
	
	select tcs.transClaim, tcs.matchingClaim
	from transClaimIDforSlot						as tcs
)


GO