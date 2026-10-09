
use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_APPLY_PROXY_HOLDS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_APPLY_PROXY_HOLDS
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_APPLY_PROXY_HOLDS
(
	 @generationID as bigint
	,@predictProxies bit
)

AS
BEGIN

/******************************************
 *
 *			TRANSMISSION_GENERATION_APPLY_PROXY_HOLDS
 *
 *	Checks proxy holds for a generation.
 *	@predictProxies determines how the check occurs:
 *		0: Assumes this is part of an actual
 *			transmission and that hold-release 
 *			sprocs have already run previously
 *			- only holds claims where HOLD = 1
 *		
 *		1: Attempts to predict which claims 
 *			would be released.
 *	
 ******************************************/

declare @generationDate as datetime
declare @transmissionDate datetime 
declare @oldestDOS date 
declare @clientID bigint
 
 select 
	 @generationDate = tg.dateCreated 
	,@transmissionDate = tg.dateCreated
	,@oldestDOS = tg.oldestDOS
	,@clientID = tg.claimID
 from dbo.TRANSMISSION_GENERATIONS											as tg 
 where tg.id = @generationID


if @predictProxies = 1 
BEGIN
		--raiserror ('Patch this to fix dependency issue',15,1)
		exec dbo.TRANSMISSION_GENERATION_APPLY_PROXY_HOLD_LOOPS @generationID
END
ELSE
	BEGIN
	
		/* Get our core list of minimally transmissable claims for proxy check */
			
		declare @proxyWorkspace table (claimID bigint, hold bit, reason varchar(max)
			UNIQUE CLUSTERED (claimID))
			

		insert into @proxyWorkspace(claimID)
		select distinct ClaimID from 
		TRANSMISSION_GENERATION_RELEASEABLE_CLAIMS(@generationID) tgrc
		inner join CLAIM_Claim as cc 
			on tgrc.ClaimID = cc.CLAIM_ID
			and cc.IS_PROXY <> 1 /* proxies are never holdable - they always transmit */ 
			and cc.HOLD = 1

		;with core_claims as
	(
		/* Get our core list of minimally transmissable claims for proxy check */
		select claimID from @proxyWorkspace where hold is null
	)

	, claims as
	(
		select cc.claim_id, cc.client_id, cc.patient_id, cc.procedure_id, cc.SERVICE_DATE 
		from core_claims													as ccs
		inner join dbo.claim_claim											as cc 
			on cc.claim_id = ccs.claimID
	)

	 insert into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD(GenerationID, ClaimID, holdReason)
		select @generationID, CLAIM_ID, 'Claim held for Proxy'
			from claims													as cc
		
	--option(recompile)
		
	END

END
GO