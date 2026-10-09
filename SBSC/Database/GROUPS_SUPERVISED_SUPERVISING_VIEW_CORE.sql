USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUPS_SUPERVISED_SUPERVISING_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUPS_SUPERVISED_SUPERVISING_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
	 
CREATE FUNCTION [dbo].[GROUPS_SUPERVISED_SUPERVISING_VIEW_CORE] ()

RETURNS TABLE 
AS 
RETURN (
 
/***************************************************************************    
 * GROUPS_SUPERVISED_SUPERVISING_VIEW_CORE */    
/**    
 * Returns relationships between supervised groups and supervising groups
 * 
 ***************************************************************************/      

select distinct
    ggss.*
  , ggsd.GROUP_NAME                         as [SUPERVISED_GROUP_NAME]
  , ggsg.GROUP_NAME                         as [SUPERVISING_GROUP_NAME]
from dbo.GROUPS_GROUP_SUPERVISED_SUPERVISOR as ggss
join dbo.GROUP_Group                        as ggsd on ggsd.GROUP_ID = ggss.SUPERVISED_GROUP_ID
join dbo.GROUP_Group                        as ggsg on ggsg.GROUP_ID = ggss.SUPERVISING_GROUP_ID

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[GROUPS_SUPERVISED_SUPERVISING_VIEW_CORE] TO [webuser]
GO
