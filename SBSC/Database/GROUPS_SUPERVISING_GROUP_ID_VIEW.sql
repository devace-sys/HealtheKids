USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUPS_SUPERVISING_GROUP_ID_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUPS_SUPERVISING_GROUP_ID_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
	 
CREATE FUNCTION [dbo].[GROUPS_SUPERVISING_GROUP_ID_VIEW] (@groupID bigint)
 
RETURNS TABLE 
AS RETURN (

/***************************************************************************    
 * GROUPS_SUPERVISING_GROUP_ID_VIEW() */    
/**    
 * Returns list of groups supervising @groupID
 *
 * @param groupID  Supervised group ID
 *
 ***************************************************************************/      

select 
   SUPERVISING_GROUP_ID   as [GROUP_ID]
 , SUPERVISING_GROUP_NAME as [GROUP_NAME] 
from dbo.GROUPS_SUPERVISED_SUPERVISING_VIEW_CORE() 
where (SUPERVISED_GROUP_ID = @groupID)
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[GROUPS_SUPERVISING_GROUP_ID_VIEW] TO [webuser]
GO
