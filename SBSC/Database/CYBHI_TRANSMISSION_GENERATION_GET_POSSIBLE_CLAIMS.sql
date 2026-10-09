
use SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_TRANSMISSION_GENERATION_GET_POSSIBLE_CLAIMS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_TRANSMISSION_GENERATION_GET_POSSIBLE_CLAIMS
GO

/*---------------------------------------------------------------------------------------------------------*/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CYBHI_TRANSMISSION_GENERATION_GET_POSSIBLE_CLAIMS (
    @clientID            bigint  
  , @oldestDos           date
  , @latestDos           date 
)
RETURNS 
TABLE
AS
RETURN
(
  select
      src.svcRecID
    , src.claimID    
    , sr.siteID

  from dbo.CYBHI_CLAIMS                as clm
  join dbo.CLAIM_Procedures            as cp  on cp.PROCEDURE_ID = clm.procedureID
  join dbo.CYBHI_SERVICE_RECORD_CLAIMS as src on src.claimID     = clm.id
  join dbo.SERVICE_RECORDS             as sr  on sr.id           = src.svcRecID

  where (	  
		(clm.clientID = @clientID)    
    and (clm.dos between @oldestDOS and @latestDos)
	and (clm.txStatusCode  = 1)
	and (clm.numUnits      != 0)
	and (clm.amountClaimed != 0.00)	
	and (cp.PUT_IN_837     = 1)
	and (clm.active        = 1)
	--and (clm.claimingPracID is not null)
  )

)
GO
