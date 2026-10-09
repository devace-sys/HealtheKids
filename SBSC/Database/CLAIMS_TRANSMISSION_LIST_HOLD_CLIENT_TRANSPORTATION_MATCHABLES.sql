
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_TRANSMISSION_LIST_HOLD_CLIENT_TRANSPORTATION_MATCHABLES') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_TRANSMISSION_LIST_HOLD_CLIENT_TRANSPORTATION_MATCHABLES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].CLAIMS_TRANSMISSION_LIST_HOLD_CLIENT_TRANSPORTATION_MATCHABLES
(
	 @generationID		as bigint
	,@oldestDOS			AS date
)
RETURNS table as

/******************************************************************************
*	CLAIMS_TRANSMISSION_LIST_HOLD_CLIENT_TRANSPORTATION_MATCHABLES
*
*	For a given generation and oldest DOS, get a list of claims
*	that are valid transportation matches (transmittable, not transportation, etc)
*
*	TODO: Can we get @oldestDOS value from the generation record?
*/
RETURN
(
	with 
	transportation_procedures as
	(
		select distinct cpt.PROCEDURE_ID 
		from dbo.SERVICES_VIEW_ALL_CORE(null,null,null,dbo.CONST_SERVICES_transport(),null,null,null,null,null)	as vac
			inner join dbo.CLAIM_PROCEDURES_TRANSMITTABLE()														as cpt 
				on vac.PROCEDURE_ID = cpt.procedure_id
		where vac.PROCEDURE_CODE_IS_Q = 0 /* TODO: bump this Q-code filter into CLAIM_PROCEDURES_TRANSMITTABLE? */
	),

	transportClaimsToCheck as
	(
		/* Identify the transport claims in our generation */
		select rctrn.*, pp.bic
		from
		dbo.TRANSMISSION_GENERATION_LIST_CLAIMS					as tglcu
			inner join dbo.CLAIM_Claim													as rctrn
				 on tglcu.ClaimID = rctrn.CLAIM_ID
				and rctrn.PROCEDURE_ID in (select * from transportation_procedures) 
			inner join dbo.PATIENTS_Patient												as pp 
				 on rctrn.PATIENT_ID = pp.PATIENT_ID
				and BIC <> ''
				and BIC is not null
		where 
		tglcu.generationID = @generationID
	)

	,clientsWithTransportClaims as
	(
		/* Identify which clients in this generation have transport claims */
		select distinct client_id from transportClaimsToCheck
	)
	,clientIDMatches as
	(
		/* Some clients match their transportation to claims in other clients. */ 
		/* This identifies those specific relationships (stored in Claim_Client_Match_Permit) */
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
		where (
			(validmatches.TRANSPORT_CLIENT_ID in (select client_id from clientsWithTransportClaims))
		)
	)

	,matchableClaims as
	(
		/* Get a list of all minimally transmittable claims */
		select 
			mClms.*
		from dbo.CLAIMS_TRANSMISSION_LIST_CORE_CLAIM_SET(null ,null, null, @oldestDOS, null, null, null,1 ) mClms
			inner join claim_claim cc on cc.claim_id = mclms.ClaimID
		where cc.Procedure_ID not in (select procedure_id from transportation_procedures)
		/* Make sure that the claims we're picking are for clients that will match to transportation client claims*/
		and cc.Client_ID in (	select matching_client_id from clientIDMatches	)
		
		/* TODO: To clean up the main query, filter this down to: */
			/* Claims for the matching clients */
			

		/* TODO: This doesn't handle cases where a patient has multiple BICs */
	)
	

	

	/* Final output: */
	/* List of all matchable claims and match data */
	select distinct
		/* Column aliases here are because we want to change internals but not exterior names for downstream functionality */ 
		 possclaimmatch.claim_id
		,possClaimMatch.client_ID
		,possclaimmatch.patient_ID
		,possclaimmatch.SERVICE_DATE
		,pp.BIC 
	from 
		matchableClaims														as mc
			inner join	dbo.CLAIM_Claim										as possClaimMatch
				on mc.ClaimID = possClaimMatch.claim_id
			inner join clientIDMatches										as cim
				on cim.MATCHING_CLIENT_ID = possClaimMatch.CLIENT_ID
			inner join dbo.patients_client									as pc 
				on cim.MATCHING_CLIENT_ID = pc.client_id
			inner join dbo.CLAIM_Procedures									as possMatchProc
				 on possClaimMatch.PROCEDURE_ID = possMatchProc.PROCEDURE_ID
				and possMatchProc.PROCEDURE_ID not in (select procedure_id from transportation_procedures)
			inner join dbo.patients_patient									as pp 
				/* The patient record for the matching claim must have a BIC */
				 on possClaimMatch.patient_id = pp.patient_id
				and pp.BIC <> ''
				and pp.BIC is not null
				and pc.patient_id = pp.patient_id

	where 
		possClaimMatch.SERVICE_DATE >= @oldestDOS /* TODO: Is this a duplication of effort, since matchableClaims already filters by oldestDOS? */
		/* Filter down to only the claims that might actually match to the transportation: */ 
			/* DOS exists in transportation claims */ 
			/* BIC exists in transportation claims */
		and EXISTS (select 1 from transportClaimsToCheck tcc where possClaimMatch.SERVICE_DATE = tcc.SERVICE_DATE)
		and EXISTS (select 1 from transportClaimsToCheck tcc where pp.BIC = tcc.BIC)
)

GO