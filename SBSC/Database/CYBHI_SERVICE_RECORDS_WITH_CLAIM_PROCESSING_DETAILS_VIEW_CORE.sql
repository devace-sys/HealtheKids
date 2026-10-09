use SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW_CORE (
    @clientID             bigint  
  , @groupID              bigint
  , @pracID               bigint
  , @patID                bigint
  , @nameID               bigint
  , @startDOS             datetime
  , @endDOS               datetime 
  , @paid                 bit
  , @processingRemarkCode smallint
  , @lastHoldCode         smallint
)
RETURNS 
TABLE
AS
RETURN
(

with
cte_base
as
(
  select top 1     
      earliestDOS   = coalesce(clc.cybhiTPAApprovedOn, convert(datetime,'7/1/2022'))
    , latestDOS     = convert(datetime,'12/31/9999')
    , zeroAmount    = convert(money,   0.00)
	, trueBit       = convert(bit,1)
	, falseBit      = convert(bit,0)
    , todayDateTime = getdate()
  from dbo.CLIENTS_Client as clc
	where 
	  (clc.CLIENT_ID = @clientID)
)
,
cte_p1
as
(
  select top 1 
      startDOS = isnull(@startDOS, b.earliestDOS)
    , endDOS   = isnull(@endDOS,   b.latestDOS)
	, b.zeroAmount
	, b.trueBit
	, b.falseBit
	, b.todayDateTime
  from cte_base as b
)
,

cte_p2
as
(
 select      
    p1.*
  , sr2.*         
 from cte_p1 as p1
 
 cross apply (
 
   select 	 
        svcRecID = sr1.id	
	  , clientID = sr1.clientID
	  , sr1.patID
	  , sr1.dos
	  , sr1.groupID
	  , sr1.nameID	
	  , sr1.pracID	  
	  , sr1.numMins
	  , sr1.patAbsent
	  , sr1.pracAbsent
	  , sr1.pracGrpSvcClsNameID
	  , sr1.siteID
	  , billableSvc = iif ((sr1.svcType in (1,2,4)),p1.trueBit,p1.falseBit)
      , svcAbsent   = iif ((sr1.patAbsent = 1) or (sr1.pracAbsent = 1),p1.trueBit,p1.falseBit)
	  , svcRecState = sr1.[state]	
	        
	from dbo.SERVICE_RECORDS as sr1
    
	where (      
	  /* This part of predicate uses index */
	     ((sr1.clientID = @clientID)
      and ((@patID is null) or (sr1.patID = @patID))
      and (sr1.dos between p1.startDOS and p1.endDOS)
      and ((@groupID is null) or (sr1.groupID = @groupID))
      and (sr1.planType = 4)
      and (sr1.nameID is not null)
      and (sr1.id is not null))
	  and ((@pracID is null) or (sr1.pracID = @pracID))
      and ((@nameID is null) or (sr1.nameID = @nameID))
	  and (sr1.state not in (99,199))
    )
  ) as sr2
)
,
cte_p3
as
(
  select 
       p2.* 
     , amountClaimed         = isnull(clm.amountClaimed,p2.zeroAmount)
	 , numOfTx               = isnull(tx2.numOfTx,0)
	 , numOfRx               = isnull(rx2.numOfRx,0)
     , amountPaid            = isnull(rx2.totAmountPaid,p2.zeroAmount)

  from cte_p2 as p2
	
  outer apply (
     select 	  
	    amountClaimed = sum(cc.amountClaimed)	
	from dbo.CYBHI_SERVICE_RECORD_CLAIMS as csrc1
	join dbo.CYBHI_CLAIMS                as cc on cc.id = csrc1.claimID	
	where 
	      (csrc1.svcRecID = p2.svcRecID)
	  and (cc.active = 1)
	group by 
	  csrc1.svcRecID
  ) as clm

   
  /* tx */

  outer apply (
	  
	  select 
	    numOfTx = count(tx1.txID)
	  from 
	  (
	    select distinct
	        svcRecID = p2.svcRecID
		  , txID     = cct.id			      
		from dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as cctc
	    join dbo.CYBHI_CLAIM_TRANSMISSIONS       as cct on cct.id = cctc.transmissionID
	    where ( 
	          (cctc.svcRecID  = p2.svcRecID)
	      and ((cctc.claimHeld = 0) and (cctc.active = 1))
	  	  and (cct.active = 1)		  
	    )
	  ) as tx1
	  group by 
	    tx1.svcRecID
	 ) as tx2
	
    
   /* This will be sum of postings */

   outer apply (    
      select 
          numOfRx       = count(sra1.id)
	    , totAmountPaid = sum(sra1.amountPaid)
	  from dbo.CYBHI_CLAIM_POSTING_SERVICE_RECORD_ADJUDICATION as sra1
      where 
	    (sra1.svcRecID = p2.svcRecID)
	  group by 
	    sra1.svcRecID
   ) as rx2
)
,
cte_p4
as
(
  select 
      p3.*
	, belowThresholdToTx       = iif(((p3.svcAbsent = 0) and (p3.billableSvc = 1) and (p3.amountClaimed = 0)),  p3.trueBit,p3.falseBit)
    , canAttemptTx             = iif(((p3.svcAbsent = 0) and (p3.billableSvc = 1) and (p3.amountClaimed > 0)),  p3.trueBit,p3.falseBit)	
	, svcClaimHeld             = isnull(lastHold.svcClaimHeld,p3.falseBit)
	, lastHoldCode             = isnull(lastHold.holdCode,-1)
	, lastHoldClaimingPracID   = isnull(lastHold.holdClaimingPracID,-1)
	, lastHoldSiteID           = isnull(lastHold.holdSiteID,-1)
    , waitingForFirstTxAttempt = iif(((p3.numOfTx = 0) and (p3.numOfRx = 0) and (lastHold.holdCode is null)),p3.trueBit,p3.falseBit)
    , waitingForAdjudication   = iif(((p3.numOfTx > 0) and (p3.numOfRx < p3.numOfTx)),p3.trueBit,p3.falseBit)
	, adjudicationCompleted    = iif(((p3.numOfTx > 0) and (p3.numOfRx = p3.numOfTx)),p3.trueBit,p3.falseBit)
	, adjudicationDisputedOrAdjusted = iif(((p3.numOfTx > 0) and (p3.numOfRx > p3.numOfTx)),p3.trueBit,p3.falseBit)
    , paid                           = convert(bit,(iif((p3.amountPaid > 0),p3.trueBit,p3.falseBit)))
  
  from cte_p3 as p3

  /* This will be the latest tx set where claim is held - does not apply if tx occurred */

  outer apply (
	select top 1 	      
	     svcClaimHeld = p3.trueBit 
	   , cctc1.holdCode		  	   					
	   , holdClaimingPracID = clms.claimingPracID
	   , holdSiteID         = cctc1.siteID
	from dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as cctc1	  
	join dbo.CYBHI_CLAIM_TRANSMISSIONS       as cct1 on cct1.id = cctc1.transmissionID
	join dbo.CYBHI_CLAIMS                    as clms on clms.id = cctc1.claimID
	where ( 
	        (p3.numOfTx = 0)                                /* Only include if we have no tx for this svc */
		and	(cctc1.svcRecID = p3.svcRecID)                  /* Uses index*/
	    and ((cctc1.claimHeld = 1) and (cctc1.active = 1))  /* Only include held and active (not rolled back)*/
		and (cct1.active = 1)                               /* Only include tx not rolled back*/		
		and (clms.active = 1)
	)
	order by 
	  cctc1.id desc /* Latest case */
  ) as lastHold
)
,
cte_p5
as
(
    select
	  p4.* 	

	, processingRemarkCode = convert(smallint, (case 		

		when (p4.svcAbsent                =  1) then 100  /* Not Claimable - Absent */
	    when (p4.belowThresholdToTx       =  1) then 200  /* Not Claimable - Minutes Below Threshold */
	    when (p4.billableSvc              =  0) then 300  /* Not Claimable - Non CYBHI Service */
      	when (p4.waitingForFirstTxAttempt =  1) then 400  /* Claimable - Waiting for Compliance Check */

		when (p4.svcClaimHeld = 1) then 
		    case 
		      when p4.lastHoldCode not in (600,900) then 500 /* Held for compliance deficiency */
			  when p4.lastHoldCode in (600,900)     then 600 /* Held for next tx*/
			  else 500 
			end
		when (p4.waitingForAdjudication = 1) then 700 /* Submitted awaiting adjudication */
		when (p4.adjudicationCompleted  = 1) then     /* Adjudicated */
		  case 
		    when p4.paid = 0 then 800  /* Not paid */
		    when p4.paid = 1 then 900  /* Paid */
		  end
		when (p4.adjudicationDisputedOrAdjusted = 1) then 
		  case 
		    when p4.paid = 0 then 1000 /* Not paid */
			when p4.paid = 1 then 1100 /* Paid */
		end

		else -1
	 end))
from cte_p4 as p4
)
select 
      p5.* 	
	, processingRemark = case 		
        when (p5.processingRemarkCode = 100) then 'Not Claimable - Absent'
		when (p5.processingRemarkCode = 200) then 'Not Claimable - Minutes Below Threshold'
		when (p5.processingRemarkCode = 300) then 'Not Claimable - Non CYBHI Service'
		when (p5.processingRemarkCode = 400) then 'Claimable - Waiting for Compliance Check'
		when (p5.processingRemarkCode = 500) then 'Claimable - When Compliance Hold Corrected : '    + isnull(chc.holdReason,'')
		when (p5.processingRemarkCode = 600) then 'Claimable - Waiting for Next Batch Submission : ' + isnull(chc.holdReason,'')
		when (p5.processingRemarkCode = 700) then 'Claim Submitted - Waiting for Adjudication'
		when (p5.processingRemarkCode = 800) then 'Claim Adjudicated - Not Paid'
		when (p5.processingRemarkCode = 900) then 'Claim Adjudicated - Paid'
		when (p5.processingRemarkCode = 1000) then 'Claim Adjudication Adjusted Or Disputed - Not Paid'
		when (p5.processingRemarkCode = 1100) then 'Claim Adjudication Adjusted Or Disputed - Paid'
		when (p5.processingRemarkCode = -1)  then 'Not Determined Yet'
		else ''
	  end
from cte_p5 as p5
left join dbo.CYBHI_CLAIM_HOLD_CODES    as chc  on chc.holdCode         = p5.lastHoldCode
where ( 
      (1=1)
  and ((@paid is null)                 or (p5.paid = @paid))
  and ((@processingRemarkCode is null) or (p5.processingRemarkCode = @processingRemarkCode))
  and ((@lastHoldCode is null)         or (p5.lastHoldCode = @lastHoldCode))
)
)

GO


  -- NOTE: This GRANT SELECT might still need to be here
--GRANT SELECT ON  [dbo].[CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW_CORE] TO [webuser]
--GO

