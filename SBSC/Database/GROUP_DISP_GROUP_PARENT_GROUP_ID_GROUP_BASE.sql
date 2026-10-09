USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GROUP_DISP_GROUP_PARENT_GROUP_ID_GROUP_BASE]'))
DROP VIEW [dbo].[GROUP_DISP_GROUP_PARENT_GROUP_ID_GROUP_BASE]
GO

CREATE VIEW [dbo].[GROUP_DISP_GROUP_PARENT_GROUP_ID_GROUP_BASE] 
AS 

/***************************************************************************    
 * GROUP_DISP_GROUP_PARENT_GROUP_ID_GROUP_BASE */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

select distinct
    GROUP_PARENT_GROUP_BASE_ID  = DENSE_RANK() over (order by cgg.PARENT_GROUP_ID ,cgg.GROUP_BASE)
  , PARENT_GROUP_ID             = cgg.PARENT_GROUP_ID  
  , GROUP_BASE                  = cgg.GROUP_BASE
  
from dbo.GROUP_Group as pgg 
join dbo.GROUP_Group as cgg on cgg.PARENT_GROUP_ID = pgg.GROUP_ID
where (
      (pgg.GROUP_TYPE = 5)
  and (pgg.PARENT_GROUP_ID is null)
  and (cgg.GROUP_TYPE in (1,2))
  and (cgg.GROUP_BASE is not null)
)

GO


