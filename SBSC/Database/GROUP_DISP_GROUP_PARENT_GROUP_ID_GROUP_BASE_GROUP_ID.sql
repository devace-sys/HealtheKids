USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GROUP_DISP_GROUP_PARENT_GROUP_ID_GROUP_BASE_GROUP_ID]'))
DROP VIEW [dbo].[GROUP_DISP_GROUP_PARENT_GROUP_ID_GROUP_BASE_GROUP_ID]
GO

CREATE VIEW [dbo].[GROUP_DISP_GROUP_PARENT_GROUP_ID_GROUP_BASE_GROUP_ID] 
AS 

/***************************************************************************    
 * GROUP_DISP_GROUP_PARENT_GROUP_ID_GROUP_BASE_GROUP_ID */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

select distinct 
    gpgb.GROUP_PARENT_GROUP_BASE_ID
  , gg.GROUP_ID
from dbo.GROUP_DISP_GROUP_PARENT_GROUP_ID_GROUP_BASE as gpgb
join dbo.GROUP_Group as gg on gg.PARENT_GROUP_ID = gpgb.PARENT_GROUP_ID
                           and gg.GROUP_BASE     = gpgb.GROUP_BASE


GO


