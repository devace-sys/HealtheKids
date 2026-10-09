USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_PATS_VIEW_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_PATS_VIEW_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_PATS_VIEW_DATA_CORE] (
    @clientID  bigint  
)

RETURNS TABLE

/***************************************************************************    
 * CYBHI_PATS_VIEW_DATA_CORE */    
/**    
 * We determine who CYBHI patients are based on if there are service
 * records entered for them
 ***************************************************************************/            

AS RETURN (
  with
  cte_p1
  as
  (
  select top 1 startDOS = convert(datetime, '7/1/2022')  /* Note: We are using a date 2 years older than 7/1/2024 because we started offering the ability to record CYBHI related services prior to the official earliest claimable date */
  )
  select 
      p1.startDOS 
    , sr2.*
  from cte_p1 as p1
  cross apply (
  select 
	  sr1.clientID
	, sr1.patID
	, earliestDOS = min(sr1.dos)
    , numSvcRecs  = count(sr1.id)
  from dbo.SERVICE_RECORDS as sr1
  where (
	/* Uses index */
	     ((sr1.clientID = @clientID)
	and (sr1.patID is not null)
	and (sr1.dos >= p1.startDOS)
	and (sr1.groupID is not null)
	and (sr1.planType = 4)
	and (sr1.nameID is not null)
	and (sr1.id is not null))
	and (sr1.state not in (99,199))
  )
  group by
	  sr1.clientID
	, sr1.patID
  ) as sr2
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CYBHI_PATS_VIEW_DATA_CORE] TO [webuser]
GO