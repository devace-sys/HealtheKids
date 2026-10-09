/* TODO: Remove when sure not needed.  This was replaced with CYBHI_SERVICE_RECORDS_WITH_CLAIM_PROCESSING_DETAILS_VIEW_CORE */

use SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_CLAIMS_PAID_BY_SERVICE_RECORD_DETAILS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_CLAIMS_PAID_BY_SERVICE_RECORD_DETAILS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CYBHI_CLAIMS_PAID_BY_SERVICE_RECORD_DETAILS_VIEW_CORE (
    @clientID           bigint  
  , @groupID            bigint
  , @pracID             bigint
  , @patID              bigint
  , @startDOS           datetime
  , @endDOS             datetime 
  , @startDOW           date
  , @endDOW             date
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
      earliestDOS   = convert(datetime,'7/1/2022')
    , earliestDOW   = convert(date,    '7/1/2022')
    , latestDOS     = convert(datetime,'12/31/9999')
    , latestDOW     = convert(date,    '12/31/9999')	
    , zeroAmount    = convert(money,   0.00)
	, trueBit       = convert(bit,1)
	, falseBit      = convert(bit,0)
    , todayDateTime = getdate()
)
,
cte_p1
as
(
  select top 1 
      startDOS = isnull(@startDOS, b.earliestDOS)
    , endDOS   = isnull(@endDOS,   b.latestDOS)
	, startDOW = isnull(@startDOW, b.earliestDOW)
	, endDOW   = isnull(@endDOW,   b.latestDOW) 
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
        sr1.clientID
	  , sr1.patID
	  , sr1.dos
	  , sr1.groupID
	  , sr1.nameID	
	  , svcRecID = sr1.id	
	  , sr1.pracID
	  , sr1.numMins
	  , svcRecState          = sr1.[state]
	  , svcClaimsSentToTPA   = iif((sr1.[state] = 20),p1.trueBit,p1.falseBit)
	  , amountClaimed        = isnull(csrc2.amountClaimed,p1.zeroAmount)
      , lastHoldCode         = cctLastHold.holdCode
	  , lastHoldDateTime     = cctLastHold.holdDateTime
	  , transmissionID       = cctLastNoHold.id
	  , dateTimeTransmitted  = cctLastNoHold.created
	
	from dbo.SERVICE_RECORDS as sr1
    
	outer apply (
	  select 
	    amountClaimed = sum(cc.amountClaimed)		
	  from dbo.CYBHI_SERVICE_RECORD_CLAIMS as csrc1
	  join dbo.CYBHI_CLAIMS                as cc on cc.id = csrc1.claimID
	  where 
	    (csrc1.svcRecID = sr1.id)
	  group by 
	    csrc1.svcRecID
	) as csrc2

	outer apply (
	  select top 1 
	      cct1.id
		, cct1.created				
	  from dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as cctc1
	  join dbo.CYBHI_CLAIM_TRANSMISSIONS       as cct1 on cct1.id = cctc1.transmissionID
	  where ( 
	        (cctc1.svcRecID  = sr1.id)
	    and (cctc1.claimHeld = 0)
	    and (cctc1.active    = 1)
		and (cct1.active     = 1)	
	  )
	  order by 
	    cctc1.id desc
	) as cctLastNoHold

    outer apply (
	  select top 1 	      
		  cctc1.holdCode	   
	    , holdDateTime = cct1.created
	  from dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as cctc1	  
	  join dbo.CYBHI_CLAIM_TRANSMISSIONS       as cct1 on cct1.id = cctc1.transmissionID
	  where ( 
	        (cctc1.svcRecID  = sr1.id)
	    and (cctc1.claimHeld = 1)	    
	    and (cctc1.active    = 1)
		and (cct1.active     = 1)
	  )
	  order by 
	    cctc1.id desc
	) as cctLastHold

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
	, sra2.dateAdjudicated
	, sra2.postingID
    , svcClaimsAdjudicated = isnull(sra2.svcClaimsAdjudicated,p2.falseBit)
	, amountPaid           = isnull(sra2.amountPaid,p2.zeroAmount)	
    
  from cte_p2 as p2
  outer apply (    
    select 
        sra1.amountPaid
	  , postingID       = ccp2.id
	  , dateAdjudicated = ccp2.checkDate	   
      , svcClaimsAdjudicated = p2.trueBit    
	from dbo.CYBHI_CLAIM_POSTING_SERVICE_RECORD_ADJUDICATION as sra1
    cross apply (
      select 
        ccp1.id
	  , ccp1.checkDate
      from dbo.CYBHI_CLAIM_POSTINGS as ccp1 
      where (
            (ccp1.id = sra1.postingID)
        and (ccp1.checkDate between p2.startDOW and p2.endDOW)
      )
    ) as ccp2
    where 
      (sra1.svcRecID = p2.svcRecID)  
  ) as sra2
)
select 
    p3.clientID
  , p3.groupID
  , p3.pracID
  , p3.patID
  , p3.svcRecID
  , dos = convert(date,p3.dos)
  , p3.nameID
  , p3.numMins
  , p3.amountClaimed
  , p3.amountPaid
  , p3.dateAdjudicated
  , p3.postingID
  , p3.svcRecState
  , lastHoldCode     = iif((p3.svcClaimsSentToTPA = 0), p3.lastHoldCode,     null)
  , lastHoldDateTime = iif((p3.svcClaimsSentToTPA = 0), p3.lastHoldDateTime, null)
  , p3.svcClaimsSentToTPA
  , p3.svcClaimsAdjudicated
  , p3.transmissionID
  , p3.dateTimeTransmitted
  , p3.startDOS
  , p3.endDOS
  , p3.startDOW
  , p3.endDOW
  , generatedOn = p3.todayDateTime
from cte_p3 as p3
)
GO
