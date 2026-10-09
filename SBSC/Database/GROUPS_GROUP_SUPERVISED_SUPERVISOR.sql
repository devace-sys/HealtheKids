USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GROUPS_GROUP_SUPERVISED_SUPERVISOR]'))
DROP VIEW [dbo].[GROUPS_GROUP_SUPERVISED_SUPERVISOR]
GO

USE [SPEDMON]
GO

CREATE VIEW [dbo].[GROUPS_GROUP_SUPERVISED_SUPERVISOR] 
AS 
(

/***************************************************************************    
 * GROUPS_GROUP_SUPERVISED_SUPERVISOR */    
/**    
 * Replaces a former table of the same name
 * Optimized to use index: GRP_GRP_SUP_SUP
 * @return table
 ***************************************************************************/     

select 
    SERVICE_TYPE = 2 
  , ggdss.SUPERVISED_GROUP_ID
  , ggdss.SUPERVISING_GROUP_ID
from [dbo].[GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR] as ggdss
where ( 
    (ggdss.approveServiceRecords = 1)
and (ggdss.ACTIVE = 1)
)

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[GROUPS_GROUP_SUPERVISED_SUPERVISOR] TO [webuser]
GO
