USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_TRANSMISSION_LIST_VIEW_HOLDS') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_TRANSMISSION_LIST_VIEW_HOLDS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].CLAIMS_TRANSMISSION_LIST_VIEW_HOLDS

(@clientID  AS int,
 @oldestDOS AS date,
 @newestDOS as date,
 @transmissionDate AS datetime)
 
RETURNS @coreClaimSet table (ClaimID bigint PRIMARY KEY, doHold bit, holdReason varchar(max), UNIQUE(ClaimID,doHold)) AS 

/* TODO: I think this is deprecated now that we're using generations. Check dependencies, etc etc */


/* FOR FUTURE DEVS: NOT ALL TRANSMITTABLE CLAIMS HAVE SERVICE RECORDS */
/* SEE PROXIED CLAIMS ISSUES FROM 5/16-5/17 */
BEGIN


declare @transport_proc_table table (proc_id bigint)
insert into @transport_proc_table (proc_id)
	select distinct proc_id from dbo.SERVICES_VIEW_ALL() where svc_type = dbo.CONST_SERVICES_TRANSPORT()

declare @tcm_proc_table table (proc_id bigint)
insert into @tcm_proc_table (proc_id)
	select distinct proc_id from dbo.SERVICES_VIEW_ALL() where svc_type = dbo.CONST_SERVICES_TCM()

declare @noplan_proc_table table (proc_id bigint)
insert into @noplan_proc_table
	select distinct proc_id from dbo.SERVICES_VIEW_ALL() where plan_type = dbo.CONST_PLAN_NONE()


declare @trnrundate date = convert(date,@transmissionDate)

/* Get our core list of minimally transmissable claims */

insert into @coreClaimSet
select distinct cc.CLAIM_ID as ClaimID, 
          null as doHold,
          null as holdReason

from dbo.CLAIM_Claim cc
inner join dbo.CLAIM_Procedures prc
     on cc.procedure_id = prc.PROCEDURE_ID
     and PUT_IN_837 = 1

inner join dbo.CLIENTS_Client cli
     on ((@clientID is null)OR @clientID = cli.CLIENT_ID)
     AND cc.CLIENT_ID = cli.CLIENT_ID
     and cli.CLIENT_ID <> 112 /* SpEdCare USD */
     and cli.LEA = 1
     
inner join dbo.PATIENTS_Patient pp
     on cc.PATIENT_ID = pp.PATIENT_ID
          and LEN(pp.bic) = 14
          
where cc.SERVICE_DATE between @oldestDOS and @newestDOS 
and cc.STATUS = 1



/*********/
/* HOLDS */
/*********/

/* Zero-unit claims */

update @coreClaimSet
set doHold = 1, holdReason = 'Claim is for zero units'
from @coreClaimSet joinCore
inner join dbo.CLAIM_Claim cc 
     on cc.CLAIM_ID = joinCore.ClaimID
     and cc.SERVICE_UNITS = 0
where doHold is null

/* Patients to not transmit */

update @coreClaimSet
set doHold = 1, holdReason = 'Patient record flagged to not submit claims'
from @coreClaimSet joinCore
inner join dbo.CLAIM_Claim cc 
     on cc.CLAIM_ID = joinCore.ClaimID
inner join dbo.PATIENTS_Patient pp
     on pp.PATIENT_ID = cc.PATIENT_ID
where doHold is null
	and (SUBMIT_CLAIMS = 0 or (SUBMIT_CLAIMS is null and CLIENT_ID = 234))
	

/* Patient MediCal Consent by parent */

update @coreClaimSet
set doHold = 1, holdReason = 'Patient Record does not indicate Medi-Cal Consent by parents'
from @coreClaimSet joinCore
inner join dbo.CLAIM_Claim cc 
     on cc.CLAIM_ID = joinCore.ClaimID
inner join dbo.PATIENTS_Patient pp
     on pp.PATIENT_ID = cc.PATIENT_ID

where doHold is null
AND
/* Hold only applies to patients created after a certain date */
	pp.date_created >= '20161121'
	AND
	(
		/* Consent is explicitly forbidden */
		isnull(pp.parentConsentMCAL, 1) = 0
		OR
		(
			pp.parentConsentMCAL is null
			and
			CLIENT_ID in (234) /* Ventura is currently The Client Who Cares abt Consent */ 
		)
	)
	
/* Client doesn't claim for NoPlan services */
update @coreClaimSet
set doHold = 1, holdReason = 'Service is NoPlan and Client does not claim Non-IEP services'
from @coreClaimSet joinCore
inner join dbo.CLAIM_Claim cc on joinCore.ClaimID= cc.CLAIM_ID
inner join @noplan_proc_table noplan_procs
     on noplan_procs.proc_id = cc.PROCEDURE_ID
     
inner join dbo.CLIENTS_Client cli
     on cli.client_ID = cc.CLIENT_ID
     and (isnull(cli.claimnoplan,0) = 0)
where doHold is null

/* Client holds for procedures in date ranges */

/* BEGIN CLIENT-PROCEDURE HOLDS */



;with client_procedure_holds as
(
	select joinCore.ClaimID, cc.CLIENT_ID, cc.PROCEDURE_ID, thcp.ID as THCP_ID
	
	from @coreClaimSet joinCore
inner join dbo.CLAIM_Claim cc 
     on cc.CLAIM_ID = joinCore.ClaimID
inner join dbo.TRANSMISSION_HOLDS_CLIENT_PROCEDURE thcp
	on thcp.CLIENT_ID = cc.CLIENT_ID
	and thcp.PROCEDURE_ID = cc.PROCEDURE_ID
	and 
	(
		(
			thcp.HOLD_BY_ENTRY_DATE = 1
			and (cc.ENTRY_DATE >= thcp.ENTRY_HOLD_START or thcp.ENTRY_HOLD_START is null)
			and (cc.ENTRY_DATE < dateadd(day,1,thcp.ENTRY_HOLD_END) or thcp.ENTRY_HOLD_END is null)
		)
	or (
			thcp.HOLD_BY_SERVICE_DATE = 1
			and (cc.SERVICE_DATE >= thcp.DOS_HOLD_START or thcp.DOS_HOLD_START is null)
			and (cc.SERVICE_DATE < dateadd(day,1,thcp.DOS_HOLD_END) or thcp.DOS_HOLD_END is null)
		)
	)
		
where doHold is null
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

 from client_procedure_holds cph
 inner join dbo.TRANSMISSION_HOLDS_CLIENT_PROCEDURE thcp
	on thcp.ID = cph.THCP_ID
)

, data_breakdown_2 as
(
select 
 case when allEntDates = 1 then 'All Entry Dates' else null end as aed
,case when allEntBefore = 1 then 'All Entries Before ' + convert(nvarchar(10), ENTRY_HOLD_END,102) else null end aeb
,case when allEntAfter = 1 then 'All Entries After ' + convert(nvarchar(10), ENTRY_HOLD_START,102) else null end aea
,case when entRange = 1 then 'Entered Between: ' + convert(nvarchar(10), ENTRY_HOLD_START,102) + ' - ' + convert(nvarchar(10), ENTRY_HOLD_END,102) end eb

,case when allDOSDates = 1 then 'All Service Dates' else null end asd
,case when allDOSBefore = 1 then 'All Services Before ' + convert(nvarchar(10), DOS_HOLD_END,102) else null end asb
,case when allDOSAfter = 1 then 'All Services After ' + convert(nvarchar(10), DOS_HOLD_START,102) else null end asa
,case when dosRange = 1 then 'Services Between: ' + convert(nvarchar(10), DOS_HOLD_START,102) + ' - ' + convert(nvarchar(10), DOS_HOLD_END,102) end sb

, data_breakdown_1.*

 from data_breakdown_1
)

update @coreClaimSet
set doHold = 1, 
	holdReason = 
		  'Client '
		+ convert(nvarchar(10), client_id) 
		+ ' is not allowed to transmit procedure ' 
		+ convert(nvarchar(10), procedure_id) 
		+ ' for date range(s): '
		+ ISNULL(COALESCE(aed,aeb,aea,eb),'') 
		+ ' '
		+ ISNULL(COALESCE(asd,asb,asa,sb),'')
from @coreClaimSet joinCore
inner join data_breakdown_2 db2
	on db2.ClaimID = joinCore.ClaimID


/* END CLIENT-PROCEDURE HOLDS */


/* TCM Holds */
/* BEGIN TCM HOLDS */

declare @tcm_approval_periods table (CLIENT_ID bigint, ApprovedForPeriod bit, PeriodStart datetime, PeriodEnd datetime)
; with cte as (select 1 as col)

, auditGapCTE as

(
select cal1.id
, (SELECT TOP 1 ID FROM dbo.CLIENTS_AUDIT_LOG NEXTcal
     WHERE 
     cal1.recID = NEXTcal.recID
AND cal1.loggedOn <= NEXTcal.loggedOn
AND cal1.id <> NEXTcal.id

and ((cal1.recID = @clientID) or (@clientID is null))
ORDER BY NEXTcal.id) AS nextEDIT

from dbo.CLIENTS_AUDIT_LOG cal1
)

,tcmChangeData as
(
select 

start.recID
,start.loggedOn                       as startlog
,start.claim_TCM                  as startTCMflag
,start.claim_TCMEffectiveDate     as startEffDate

,finish.loggedOn                  as finlog
,finish.claim_TCM                 as finTCMflag
,finish.claim_TCMEffectiveDate    as finEffDate

, case
     when start.claim_TCM is null and finish.claim_TCM is null
     then 1 else 0 end as TCM_NullThisPeriod
     
     ,case when 
          (start.claim_TCM is null and finish.claim_TCM is not null)
          or start.claim_TCM <> finish.claim_TCM
          then 1 else 0 end as TCMChanged
     

from auditGapCTE agc
inner join dbo.CLIENTS_AUDIT_LOG start
     on agc.id = start.id
inner join dbo.CLIENTS_AUDIT_LOG finish 
     on agc.nextEDIT = finish.id
     and start.recID = finish.recID
)
,
TCMApprovalInflections as
(
select 
tcmChangeData.recID as clientID,
tcmChangeData.tcmchanged as TCMChangedFlag,
case
     when tcmChangeData.TCMChanged = 1 and finTCMflag = 1
     then 1 else 0 end as TCM_Approved_StartPoint

,case
     when tcmChangeData.TCMChanged = 1 and finTCMflag = 0
     then 1 else 0 end as TCM_Disapproved_StartPoint
     
,finEffDate as startPointDateEffective

from tcmChangeData

where TCMChanged = 1
)

,TCMApprovalPeriods as
(
select * ,

(
     select top 1 startPointDateEffective 
     from TCMApprovalInflections nextInflect
     where (
              (thisInflect.TCM_Approved_StartPoint <> nextInflect.TCM_Approved_StartPoint)
              OR
              (thisInflect.TCM_Disapproved_StartPoint <> nextInflect.TCM_Disapproved_StartPoint)
              )
              and thisInflect.clientID = nextInflect.clientID
              and thisInflect.startPointDateEffective < nextInflect.startPointDateEffective
              order by nextinflect.startPointDateEffective asc
)    as endPointDateEffective

from
TCMApprovalInflections thisInflect
)

,tcmApprovalPenult as
(
select cc.CLIENT_ID, cc.CLAIM_TCM as currentTCMstatus
,tcmApp.TCMChangedFlag, tcmApp.TCM_Approved_StartPoint, tcmApp.TCM_Disapproved_StartPoint, tcmApp.startPointDateEffective, tcmApp.endPointDateEffective
from 

dbo.CLIENTS_Client cc

left outer join TCMApprovalPeriods tcmApp on cc.CLIENT_ID = tcmApp.clientID
)

,tcmApprovalFinal as
(

/* use a set of unions to aggregate multiple result sets */

/* Case 1: If the client record as of transmission time has no approval or disapproval recorded, I'm assuming that's an OK to transmit */
select 
CLIENT_ID
, 1 as ApprovedForPeriod
, null as PeriodStart
, null as PeriodEnd
from tcmApprovalPenult
where tcmApprovalPenult.currentTCMstatus is null

/* Case 2: If the client HAS a recorded answer on TCM, but it's not recorded in audit - assume the answer is a blanket approve/disapprove for all tcm */
UNION

select 
CLIENT_ID
, currentTCMstatus as ApprovedForPeriod
, null as PeriodStart
, null as PeriodEnd
from tcmApprovalPenult
where 
     tcmApprovalPenult.currentTCMstatus is not null
     and TCMChangedFlag is null
     
/* Case 3: if we have information in the audit history re: tcm changes, we want to display the distinct periods for that */
UNION

select 
CLIENT_ID
, case
     when (TCM_Approved_StartPoint = 1 and TCM_Disapproved_StartPoint = 0) then 1
     when (TCM_Approved_StartPoint = 0 and TCM_Disapproved_StartPoint = 1) then 0
  end
as ApprovedForPeriod
, startPointDateEffective as PeriodStart
, endPointDateEffective as PeriodEnd
from tcmApprovalPenult
where 
     tcmApprovalPenult.currentTCMstatus is not null
     and ISNULL(TCMChangedFlag,0) =1
)
insert into @tcm_approval_periods
select * from tcmApprovalFinal

/* Hold ALL TCM for Ventura COE */

update @coreClaimSet
set dohold = 1, holdReason = 'TCM For VCOE is not to be transmitted or billed until further notice (See Sandy & Chuck''s email to accounting on 3/24/2017'
from @coreClaimSet joinCore
inner join dbo.CLAIM_Claim cc
	on cc.CLAIM_ID = joinCore.ClaimID
inner join @tcm_proc_table tpt
	on cc.PROCEDURE_ID= tpt.proc_id
where cc.CLIENT_ID = 234

/* No TCM on this date for this client */

update @coreClaimSet
set doHold = 1, holdReason = 'Client does not support TCM on the claiming DOS'

from @coreClaimSet joinCore
inner join dbo.CLAIM_Claim cc
	on cc.CLAIM_ID = joinCore.ClaimID
inner join @tcm_proc_table tpt
	on cc.PROCEDURE_ID= tpt.proc_id
left outer join @tcm_approval_periods tap	/* Identify which approved period matches to claim */
              on
                   tap.CLIENT_ID = cc.CLIENT_ID
                   and tap.ApprovedForPeriod = 1
                   and(
                        (tap.PeriodStart is null and tap.PeriodEnd is null) /* blanket approval */
                        or
                        (tap.PeriodStart <= cc.SERVICE_DATE and tap.PeriodEnd is null) /* open-ended approval */
                        or
                        (tap.PeriodStart <= cc.SERVICE_DATE and tap.PeriodEnd >= cc.SERVICE_DATE) /* approval w/in defined window */
                   )
where doHold is null
		and tap.CLIENT_ID is null	/* we're only interested in the cases where we couldn't match TCM to a period */

/* Don't transmit TCM for this prac */

update @coreClaimSet
set doHold = 1, holdReason = 'Practitioner is flagged to not bill TCM on the date of service'

from @coreClaimSet joinCore
inner join dbo.CLAIM_Claim cc
	on cc.CLAIM_ID = joinCore.ClaimID
inner join @tcm_proc_table tpt
	on cc.PROCEDURE_ID= tpt.proc_id
inner join dbo.PRACTITIONER_Practitioner pp
     on cc.PRACTITIONER_ID = pp.PRACTITIONER_ID
	 and (
		(pp.CLAIM_TCM = 0 and pp.claim_TCMEffectiveDate <= cc.SERVICE_DATE)
		or
		((pp.CLAIM_TCM = 1 and pp.claim_TCMEffectiveDate >= cc.SERVICE_DATE))
	 )
where doHold is null

/* END TCM HOLD */


/* Hold all this practitioner's work */
update @coreClaimSet
set doHold = 1, holdReason = 'Practitioner is flagged as DO NOT SUBMIT for the period including the service date'

from @coreClaimSet joinCore
inner join dbo.CLAIM_Claim cc
	on cc.CLAIM_ID = joinCore.ClaimID
inner join dbo.PRACTITIONER_Practitioner pp
     on cc.PRACTITIONER_ID = pp.PRACTITIONER_ID
	 and pp.SUBMIT_CLAIMS = 0
where doHold is null


/* Hold if we put in the work from a batch, and that batch has not been reviewed and marked as finished work */

/* we have to join to service record for this info */
update @coreClaimSet
set doHold = 1, holdReason = 'The batch this service was in (ref '+ ibsr.reference +') has not been marked as Finished Work (200)'

from @coreClaimSet joinCore
left outer join dbo.SERVICE_RECORD_CLAIMS src
	on joinCore.ClaimID = src.claimID
left outer join dbo.SERVICE_RECORDS sr 
     on src.svcRecID = sr.id 
left outer join dbo.INPUT_BATCHES_SERVICE_RECORDS ibsr
	on sr.id = ibsr.svcRecID
left outer join dbo.INPUT_BATCHES ib
	on ib.id = ibsr.inputbatchid
	and ib.current_status_code <> 200 /* Finished Work */
where doHold is null
and ib.id is not null

/* So, let's be gross and iterate through clients to work with transmission */
/* This improves query speeds for doing things like transportation */

declare @clientIndex table (idx bigint identity (1,1) , clientID bigint)
insert into @clientIndex 
select distinct cli.CLIENT_ID from @coreClaimSet ccs
inner join dbo.CLAIM_Claim cc on ccs.ClaimID = cc.CLAIM_ID
inner join dbo.CLIENTS_Client cli on cli.CLIENT_ID  = cc.CLIENT_ID

declare @indexPos bigint = 1
declare @maxindex bigint = (select MAX(idx) from @clientIndex)

declare @currentClientID bigint

while @indexPos <= @maxindex
BEGIN

set @currentClientID = (select clientid from @clientIndex where idx = @indexPos)

/* Client-by-Client: No covering service for transportation */
; with matchingClaimSet as
(
	select possMatch.* from dbo.CLAIM_Claim possMatch
	inner join dbo.CLAIM_Procedures possMatchProc
		on possMatch.PROCEDURE_ID = possMatchProc.PROCEDURE_ID
		and possMatchProc.PUT_IN_837 = 1
	where possMatch.SERVICE_DATE >= @oldestDOS
		and possMatch.PROCEDURE_ID not in (
			select * from @transport_proc_table 
			union 
			select * from @tcm_proc_table)
	and possMatch.CLIENT_ID in
	(
		select @currentClientID
		UNION
		select ccmp.MATCHING_CLIENT_ID from 
		dbo.Claim_Client_Match_Permit ccmp where @currentClientID = ccmp.TRANSPORT_CLIENT_ID
	)
)
update @coreClaimSet
set doHold = 1, holdReason = 'No Covering Service for transportation claim - Client ' + CONVERT(varchar(80), @currentClientID)

from @coreClaimSet core
inner join dbo.CLAIM_Claim rctrn
	on core.ClaimID = rctrn.CLAIM_ID
	and rctrn.PROCEDURE_ID in (select * from @transport_proc_table )
--	and rctrn.CLIENT_ID = @currentClientID
--left outer join
--(
--select core.ClaimID as transClaim, matchClaim.CLAIM_ID as matchingClaim
--from @coreClaimSet core
--inner join CLAIM_Claim transClaim 
--     on core.ClaimID = transClaim.CLAIM_ID
--     and transClaim.PROCEDURE_ID in (select * from @transport_proc_table )
--     and transClaim.CLIENT_ID = @currentClientID
--left outer join Claim_Client_Match_Permit ccmp
--     on ccmp.TRANSPORT_CLIENT_ID = transClaim.CLIENT_ID
--inner join PATIENTS_Patient transPat 
--     on transClaim.PATIENT_ID = transPat.PATIENT_ID
--inner join PATIENTS_Patient matchPat 
--     on transPat.BIC = matchPat.BIC
--inner join matchingClaimSet matchClaim 
--     on matchClaim.PATIENT_ID = matchPat.PATIENT_ID
--     and matchClaim.CLAIM_ID <> transClaim.CLAIM_ID
--     and matchClaim.SERVICE_DATE = transClaim.SERVICE_DATE
     
--) transMatchingData on core.ClaimID = transMatchingData.transClaim

--where transMatchingData.transClaim is null
--and doHold is null
--option(recompile)

/* trivial change - get rid of this whenevs */


/* Client-by-Client: Claim held for proxy */
declare @proxy_data_hold table (clientID bigint, patID bigint, procID1 bigint,procID2 bigint, dos date, Sendable bit)
insert into @proxy_data_hold
select crvc.clientID, crvc.patID, crvc.procID1,crvc.procID2, crvc.dos, crvc.Sendable from dbo.CLAIMS_TO_RELEASE_VIEW_CORE(@currentClientID, @oldestDOS, @newestDOS, @trnRunDate) crvc 


update @coreClaimSet
set doHold = 1, holdReason = 'Claim held for Proxy'

from @coreClaimSet core
inner join dbo.CLAIM_Claim cc 
	on core.ClaimID = cc.CLAIM_ID
	and cc.IS_PROXY <> 1 /* proxies are never holdable - they always transmit */ 
	and cc.HOLD = 1
	
left outer join @proxy_data_hold pdh /* match the record to a service slot */
	ON pdh.clientID = cc.CLIENT_ID
     AND pdh.patID = cc.PATIENT_ID
     and (ISNULL(pdh.procID1,0) = cc.PROCEDURE_ID OR ISNULL(pdh.procID2,0) = cc.PROCEDURE_ID)
     and pdh.dos = cc.SERVICE_DATE

where doHold is null
	 and ISNULL(pdh.Sendable,0) = 0 /* Hold anything not explicitly flagged as sendable */

update @coreClaimSet 
set doHold = 1, holdReason = 'Waiting for Service Journal'
from @coreClaimSet ccs
inner join dbo.SERVICE_RECORD_CLAIMS src
	on ccs.ClaimID = src.claimID
where src.svcRecID in (
	select distinct
	svcRecID
	from dbo.CLAIMS_TO_HOLD_VIEW_CORE (@currentClientID, @oldestDOS, @newestDOS) 
	where (waitingForJournal         = 1)
) and doHold is null


update @coreClaimSet 
set doHold = 1, holdReason = 'Waiting for Practitioner Supervisor Approval'
from @coreClaimSet ccs
inner join dbo.SERVICE_RECORD_CLAIMS src
	on ccs.ClaimID = src.claimID
where src.SvcRecID in (
	select distinct
	svcRecID
	from dbo.CLAIMS_TO_HOLD_VIEW_CORE (@currentClientID, @oldestDOS, @newestDOS) 
	where (waitingForPracSupApproval          = 1)
) and doHold is null



/* Increment to next client */
set @indexPos = @indexPos+1
END



/* Make sure we're putting out usable true-false values */

update @coreClaimSet
set doHold = 0
where doHold is null

return

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_TRANSMISSION_LIST_VIEW_HOLDS] TO [webuser]
GO
  