USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_USER_ROLES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_USER_ROLES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[APP_MAN_PAGES_USER_ROLES_VIEW_CORE] ( 
  @appName varchar(50)     
)
RETURNS 
table 
as
return
(

select 
    t1.id    
  , t1.appName
  , t1.displayOrder
  , t1.[name] 
  , t1.roleUserGroupID 
  , t1.roleUserRoleID  
  , t1.roleUserRoleUID 
  , t1.roleUserRank
  , t1.appEntID1
  , t1.appEntID2
  , t1.appEntID3  
from dbo.AppManPagesUserRoles as t1
where ( 
      (t1.appName = @appName)
  and (t1.active = 1)
)

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[APP_MAN_PAGES_USER_ROLES_VIEW_CORE] TO [webuser]
GO



