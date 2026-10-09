USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUPS_SUPERVISED_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUPS_SUPERVISED_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
	 
CREATE FUNCTION [dbo].[GROUPS_SUPERVISED_VIEW] ()
 
RETURNS TABLE 
AS RETURN (

/***************************************************************************    
 * GROUPS_SUPERVISED_VIEW */    
/**    
 * Returns complete list of groups who are supervised by other groups
 *
 ***************************************************************************/      

select distinct 
    SUPERVISED_GROUP_ID   as GROUP_ID
  , SUPERVISED_GROUP_NAME as GROUP_NAME 
from dbo.GROUPS_SUPERVISED_SUPERVISING_VIEW_CORE()

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[GROUPS_SUPERVISED_VIEW] TO [webuser]
GO
