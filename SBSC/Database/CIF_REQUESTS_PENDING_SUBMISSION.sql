USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CIF_REQUESTS_PENDING_SUBMISSION]'))
DROP VIEW [dbo].[CIF_REQUESTS_PENDING_SUBMISSION]
GO

CREATE VIEW [dbo].[CIF_REQUESTS_PENDING_SUBMISSION] 
AS 

/***************************************************************************    
 * CIF_REQUESTS_PENDING_SUBMISSION */    
/**    
 * 
 * @return table
 ***************************************************************************/     

select 
    sac.clientID
  , sac.claimID
  , sac.ccn
  , sac.amountToPayBack
  , sac.dos
  , sac.proxyClaim
  , sac.childClaimsCsv

from dbo.CIF_REQUESTS_CLAIMS_VOID_SUBMISSIONS as sac

where ( sac.submitted = 0)
   
GO


