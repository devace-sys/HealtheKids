

use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_APPLY_PROXY_HOLD_LOOPS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_APPLY_PROXY_HOLD_LOOPS
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_APPLY_PROXY_HOLD_LOOPS
(
	 @generationID as bigint
)

AS
BEGIN

/******************************************
 *
 *			SPROCNAME
 *
 *	Given a generation, get a list of all the clients in generation.
 *	Iterate through that list of clients:
 *		Get a list of the claims in this generation for that client
 *		Get data about proxy hold and release information (via DBF)
 *		Condense claim and proxy data into service slots and cross-compare
 *		Predict which claims would be held and which released
 *		Based on that prediction, mark claims as held or not in the generation
 *	
 ******************************************/
	 
declare @generationDate as datetime
declare @transmissionDate datetime 
declare @oldestDOS date 
declare @newestDOS date
declare @clientID bigint
declare @today as datetime

print 'Cache generation values...'
select 
 @generationDate = tg.dateCreated 
,@transmissionDate = tg.dateCreated
,@oldestDOS = tg.oldestDOS
,@newestDOS = isnull(tg.newestDOS,@today)
,@clientID = tg.claimID
from dbo.TRANSMISSION_GENERATIONS tg where tg.id = @generationID


print 'Prepping tables for iterations...'
declare @releaseViewCore table(clientID bigint, patID bigint, procID1 bigint, procID2 bigint, dos date, Sendable bit)
declare @journalHoldViewCore table(svcRecID bigint, waitSupervisor bit, waitJournal bit)
declare @clients table (idx bigint identity(1,1), clientID bigint)

/* Get our core list of minimally transmissable claims for proxy check */
	
declare @proxyWorkspace table (claimID bigint, hold bit, reason varchar(max)
	UNIQUE CLUSTERED (claimID))
	
insert into @proxyWorkspace(claimID)
select distinct ClaimID 
from TRANSMISSION_GENERATION_RELEASEABLE_CLAIMS(@generationID) tgrc



print 'Getting client list...'
;with core_claims as
(
	/* Get our core list of minimally transmissable claims for proxy check */
	select claimid from @proxyWorkspace where hold is null
)


,claims as
(
	select cc.claim_id, cc.client_id, cc.patient_id, cc.procedure_id, cc.SERVICE_DATE 
	from core_claims					as ccs
	inner join dbo.claim_claim				as cc 
		on cc.claim_id = ccs.claimID
		and cc.IS_PROXY <> 1 /* proxies are never holdable - they always transmit */ 
		and cc.HOLD = 1
)
insert into @clients (clientID)
	select distinct client_id from claims
	order by CLIENT_ID
	
declare @index bigint = 1
declare @maxIndex bigint
select @maxIndex = MAX(idx) from @clients
declare @clientPointer bigint

while @index <= @maxIndex
BEGIN
select @clientPointer = clientID from @clients where idx = @index
print 'Working client ID:'
print @clientPointer

print 'CLAIMS_TO_RELEASE_VIEW_CORE'
;with core_claims as
(
/* Get our core list of minimally transmissable claims for proxy check */
	select cc.* from (select claimid from @proxyWorkspace where hold is null) tglc
	inner join CLAIM_Claim as cc
		on cc.CLAIM_ID = tglc.claimID
	where cc.CLIENT_ID = @clientPointer
)

insert into @releaseViewCore
	select crvc.clientID, crvc.patID, crvc.procID1,crvc.procID2, crvc.dos, crvc.Sendable 
	from dbo.CLAIMS_TO_RELEASE_VIEW_CORE(@clientPointer, @oldestDOS,@newestDOS,@today)			as crvc
	where exists 
	(
		select 1 from core_claims as cc 
		where crvc.dos = cc.service_date 
			and crvc.patID = cc.patient_ID
	)
option(recompile)	

print 'CLAIMS_TO_HOLD_VIEW_CORE'
;with core_claims as
(
/* Get our core list of minimally transmissable claims */
	select cc.* from (select claimid from @proxyWorkspace where hold is null) tglc
	inner join CLAIM_Claim as cc
		on cc.CLAIM_ID = tglc.claimID
		
	where cc.CLIENT_ID = @clientPointer
)
insert into @journalHoldViewCore
	select distinct
	svcRecID, waitingForPracSupApproval, waitingForJournal
	from dbo.CLAIMS_TO_HOLD_VIEW_CORE (@clientPointer, @oldestDOS, @newestDOS)	as hvc 
	where 
	(
		(hvc.waitingForPracSupApproval          = 1)
		or	  
		(hvc.waitingForJournal					= 1)
	)
	and exists 
	(
		select 1 
		from core_claims					as cc 
		inner join dbo.SERVICE_RECORD_CLAIMS	as src 
			on cc.CLAIM_ID = src.claimID 
			and src.svcRecID = hvc.svcRecID
	)


print 'Holding for Proxy'
;with core_claims as
(
/* Get our core list of minimally transmissable claims for proxy check */
	select cc.* from (select claimid from @proxyWorkspace where hold is null) tglc
	inner join CLAIM_Claim as cc
		on cc.CLAIM_ID = tglc.claimID
		
	where cc.CLIENT_ID = @clientPointer
)
, claims as
(
	select cc.claim_id, cc.client_id, cc.patient_id, cc.procedure_id, cc.SERVICE_DATE 
	from core_claims															as ccs
	inner join dbo.claim_claim													as cc 
		on cc.claim_id = ccs.claim_ID
		and cc.IS_PROXY <> 1 /* proxies are never holdable - they always transmit */ 
		and cc.HOLD = 1
)

update @proxyWorkspace
	set hold = 1, reason = 'Claim held for Proxy'
where claimID in
(	
	select cc.CLAIM_ID
	from claims													as cc
	left outer join @releaseViewCore							as rvc
		ON rvc.clientID = cc.CLIENT_ID
		AND rvc.patID = cc.PATIENT_ID
		and 
		(
			ISNULL(rvc.procID1,0) = cc.PROCEDURE_ID 
			OR 
			ISNULL(rvc.procID2,0) = cc.PROCEDURE_ID
		)
		and rvc.dos = cc.SERVICE_DATE
	where (rvc.Sendable = 0 or rvc.Sendable is null) /* Hold anything not explicitly flagged as sendable */
	and cc.CLIENT_ID = @clientPointer
)


update @proxyWorkspace
	set hold = 1, reason = 'Waiting for Service Journal'
where claimID in
(	select tglcu.claimid  from
 (select claimid from @proxyWorkspace where hold is null)		as tglcu
	inner join dbo.SERVICE_RECORD_CLAIMS							as src
		on tglcu.ClaimID = src.claimID
	where src.svcRecID in 
	(
		select distinct
		svcRecID
		from dbo.CLAIMS_TO_HOLD_VIEW_CORE (@clientPointer, @oldestDOS,@newestDOS) 
		where (waitingForJournal = 1)
	)
)


print 'Supervisor Approval Hold'
update @proxyWorkspace
	set hold = 1, reason = 'Waiting for Practitioner Supervisor Approval'

where claimID in
(

		select tglcu.claimID from
		(select claimid from @proxyWorkspace where hold is null)		as tglcu
inner join dbo.SERVICE_RECORD_CLAIMS						as src
	on tglcu.ClaimID = src.claimID
where src.SvcRecID in 
(
	select distinct
	svcRecID
	from dbo.CLAIMS_TO_HOLD_VIEW_CORE (@clientPointer, @oldestDOS,@newestDOS) 
	where (waitingForPracSupApproval          = 1)
)
)



/* End journal/supervision */

/* Cleanup for next iteration */
print 'loop cleanup'
delete from @releaseViewCore
delete from @journalHoldViewCore

set @index= @index +1

END /* Loop */

/* Push proxy updates as insert into holds */

insert into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD(GenerationID, ClaimID, holdReason)
select @generationID, claimID, reason from @proxyWorkspace where hold = 1

END

GO