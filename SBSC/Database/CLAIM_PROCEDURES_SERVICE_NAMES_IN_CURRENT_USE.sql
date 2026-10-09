USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CLAIM_PROCEDURES_SERVICE_NAMES_IN_CURRENT_USE]'))
DROP VIEW [dbo].[CLAIM_PROCEDURES_SERVICE_NAMES_IN_CURRENT_USE]
GO

CREATE VIEW [dbo].[CLAIM_PROCEDURES_SERVICE_NAMES_IN_CURRENT_USE] 
AS 

/***************************************************************************    
 * CLAIM_PROCEDURES_SERVICE_NAMES_IN_CURRENT_USE */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

select distinct 
    nameID = iep.IEP_IFSP_NAME_ID
  , [name] = iep.[NAME]
  , iep = convert(bit,1)
from dbo.GROUP_Group              as gg
join dbo.CLAIM_Allowed_Procedures as cap on cap.GROUP_ID    = gg.GROUP_ID
join dbo.CLAIM_Procedures         as cp  on cp.PROCEDURE_ID = cap.PROCEDURE_ID
join dbo.CLAIM_IEPandIFSPNames    as iep on iep.IEP_IFSP_NAME_ID = cp.IEP_IFSP_NAME
where (  
      (gg.GROUP_TYPE in (1,2))
  and (gg.ACTIVE = 1)
  and (cp.IEP_IFSP_NAME is not null)
  and (cp.NO_PLAN_NAME is null)
  and (cp.Active = 1)
)

union all

select distinct
    nameID = np.NO_PLAN_NAME_ID
  , [name] = np.[NAME]
  , iep    = convert(bit,0)
from dbo.GROUP_Group              as gg
join dbo.CLAIM_Allowed_Procedures as cap on cap.GROUP_ID       = gg.GROUP_ID
join dbo.CLAIM_Procedures         as cp  on cp.PROCEDURE_ID    = cap.PROCEDURE_ID
join dbo.CLAIM_NoPlanNames        as np  on np.NO_PLAN_NAME_ID = cp.NO_PLAN_NAME
where  (
      (gg.GROUP_TYPE in (1,2))
  and (gg.ACTIVE = 1)
  and (cp.IEP_IFSP_NAME is null)
  and (cp.NO_PLAN_NAME is not null)
  and (cp.Active = 1)
)

GO


