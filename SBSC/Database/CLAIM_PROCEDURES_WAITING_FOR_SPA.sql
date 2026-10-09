USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CLAIM_PROCEDURES_WAITING_FOR_SPA]'))
DROP VIEW [dbo].[CLAIM_PROCEDURES_WAITING_FOR_SPA]
GO

USE [SPEDMON]
GO

CREATE VIEW [dbo].[CLAIM_PROCEDURES_WAITING_FOR_SPA] 
AS 
(

/***************************************************************************    
 * CLAIM_PROCEDURES_WAITING_FOR_SPA */    
/**    
 *
 * @return table
 ***************************************************************************/     

select distinct 
  cp.*

from dbo.CLAIM_Allowed_Procedures as cap
join dbo.CLAIM_Procedures         as cp on cp.PROCEDURE_ID = cap.PROCEDURE_ID

where (
      (cp.SERVICE_TYPE_ID between 1 and 4)
  and (cp.PROCEDURE_CODE like 'Q%')
  and (cp.Active     = 1)
  and (cp.PUT_IN_837 = 0)
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_PROCEDURES_WAITING_FOR_SPA] TO [webuser]
GO
