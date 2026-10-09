USE [SPEDMON]
GO

DROP FUNCTION IF EXISTS [dbo].[CLAIM_RETROACTIVE_FOR_SPA_POTENTIAL_REIMBURSE_SUMS]
GO


CREATE FUNCTION [dbo].[CLAIM_RETROACTIVE_FOR_SPA_POTENTIAL_REIMBURSE_SUMS]
(    
   @forSpaID   as bigint
 , @clientID   as bigint
 , @fyID       as bigint
)
       

RETURNS TABLE
AS
RETURN(

SELECT 
    ISNULL([N], 0) as [N]
  , ISNULL([Y],0)  as [Y]
  , ISNULL([?],0)  as [U]
FROM
(
 
 select 
  authorizedYNU
, sum(estReimburse) as totEstReimburse 
from dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SERVICE_RECORD_CLAIMS_POSSIBLE_VIEW_CORE (@forSpaID, @clientID, @fyID)
group by 
  authorizedYNU

 /*select 
    totEstReimburse as money_on_the_table
  , authorizedYNU as [Disposition Status] 
  from dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW (null, null, null, 1, @clientID, null, null)
  */
) datasrc
PIVOT
(
SUM(totEstReimburse)
FOR [authorizedYNU] IN ([N], [Y], [?])
) pvt

)

GO

GRANT SELECT ON dbo.CLAIM_RETROACTIVE_FOR_SPA_POTENTIAL_REIMBURSE_SUMS TO webuser
GO