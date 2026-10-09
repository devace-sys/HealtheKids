USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA]'))
DROP VIEW [dbo].[GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA]
GO

CREATE VIEW [dbo].[GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA] 
AS 

/***************************************************************************    
 * GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA */    
/**    
 * 
 * @return table
 ***************************************************************************/     

select distinct
   scp.*
  ,scn.*
  ,gg.*
from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as scpng
join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES                   as scn   on scn.GROUP_SERVICE_CLASS_NAME_ID      = scpng.GROUP_SERVICE_CLASS_NAME_ID
join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS              as scp   on scp.GROUP_SERVICE_CLASS_PARTITION_ID = scpng.GROUP_SERVICE_CLASS_PARTITION_ID
join dbo.GROUP_Group                                       as gg    on gg.GROUP_ID                          = scpng.GROUP_ID


GO


