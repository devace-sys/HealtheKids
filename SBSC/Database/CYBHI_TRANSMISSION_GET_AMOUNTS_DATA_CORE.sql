use SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_TRANSMISSION_GET_AMOUNTS_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_TRANSMISSION_GET_AMOUNTS_DATA_CORE
GO

/*---------------------------------------------------------------------------------------------------------*/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CYBHI_TRANSMISSION_GET_AMOUNTS_DATA_CORE (
    @transmissionID  bigint    /* Required */
  , @claimHeld       bit   = 0 /* Required*/
)
RETURNS 
TABLE
AS
RETURN
(

with
cte_p1
as
(
  /* Get details for transmission id and claim held flag */
  
  select 
      txID = cct.id
    , src.svcRecID
    , src.claimID
    , clms.amountClaimed 

  from dbo.CYBHI_CLAIM_TRANSMISSIONS       as cct
  join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as cctc on cctc.transmissionID = cct.id
  join dbo.CYBHI_SERVICE_RECORD_CLAIMS     as src  on src.claimID         = cctc.claimID
  join dbo.CYBHI_CLAIMS                    as clms on clms.id             = src.claimID
  where (
        (cct.id         = @transmissionID)
    and (cctc.claimHeld = @claimHeld)
  )
)
,

cte_p2
as
(
  
  /* Get total number of claim lines and sum of amount claimed */
  
  select 
      p1.txID
    , p1.svcRecID
    , numClaimLines = count(p1.claimID)
    , amountClaimed = sum(p1.amountClaimed)
  from cte_p1 as p1
  group by
      p1.txID
    , p1.svcRecID
)
,
cte_p3
as
(
  /* Get total number of svcRecs and sum of amount claimed */

  select 
      p2.txID
    , numSvcRecs    = count(p2.svcRecID)
    , numClaimLines = sum(p2.numClaimLines)
    , amountClaimed = sum(p2.amountClaimed) 
  from cte_p2 as p2
  group by 
    p2.txID
)

/* Output */

select 
    id        = @transmissionID
  , claimHeld = @claimHeld
  , p3.numSvcRecs
  , p3.numClaimLines
  , p3.amountClaimed
from cte_p3                        as p3
)

GO
