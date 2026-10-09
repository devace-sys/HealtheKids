USE users
GO

/* The flaw is that the ranking function is non deterministic as it will produce different ids
  as soon as new roles are added.  What we need is a table with an identify column that can be used
  to produce the values needed */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_USER_ROLES_VIEW_CORE_OLD') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_USER_ROLES_VIEW_CORE_OLD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[APP_MAN_PAGES_USER_ROLES_VIEW_CORE_OLD]( 
  @appName varchar(50) 
    
)
RETURNS @recs
table (
    id                             bigint
  , appName                        varchar(50)
  , displayOrder                   int
  , name                           varchar(512)
  , roleUserGroupID                bigint
  , roleUserRoleID                 bigint
  , roleUserRoleUID                uniqueidentifier
  , roleUserRank                   bigint
  , appEntID1                      bigint
  , appEntID2                      bigint

  unique clustered (
    id 
  )
)
AS
begin 


/***************************************************************************
 * APP_MAN_PAGES_USER_ROLES_VIEW_CORE_OLD */
/**
 * Displays user data
 *
 * @param  clientID        ID of client or null for all clients
 * @param  roleID          user's username or null
 * @param  appName         user's email or null 
 * @return                 Table of user data
 ***************************************************************************/ 

declare @recsData as table (
    appName                        varchar(50)
  , displayOrder                   int
  , name                           varchar(512)
  , roleUserGroupID                bigint
  , roleUserRoleID                 bigint
  , roleUserRoleUID                uniqueidentifier
  , roleUserRank                   bigint
  , appEntID1                      bigint
  , appEntID2                      bigint
)

/* All Users */

insert into @recsData (
    appName
  , displayOrder
  , name 
  , roleUserGroupID
  , roleUserRoleID 
  , roleUserRoleUID
  , roleUserRank 
  , appEntID1 
  , appEntID2
)
values ( 
    @appName
  , 1
  , 'All - Users'
  , null
  , null
  , null
  , null
  , null
  , null )

/* All User Groups */

insert into @recsData (
    appName
  , displayOrder
  , name 
  , roleUserGroupID
  , roleUserRoleID 
  , roleUserRoleUID
  , roleUserRank 
  , appEntID1 
  , appEntID2
)
select 
    ug.appName
  , 2
  , 'All - ' + groupName + ' Users'
  , id 
  , null
  , null
  , null
  , null
  , null
from dbo.UserGroup as ug
where (appName = @appName)

/* All User Groups User Roles */

insert into @recsData (
    appName
  , displayOrder
  , name 
  , roleUserGroupID
  , roleUserRoleID 
  , roleUserRoleUID
  , roleUserRank 
  , appEntID1 
  , appEntID2
)
select 
    ug.appName
  , 3
  , ug.groupName + ' Users - ' + r.RoleName
  , ug.id
  , rd.id
  , rd.roleId
  , rd.rank
  , null
  , null 

from dbo.UserGroup as ug 
join dbo.RoleData  as rd on  rd.appName   = ug.appName
                         and rd.userGroup = ug.id
join dbo.Roles     as r  on  r.RoleId     = rd.RoleId
where (ug.appName = @appName)

/* App specific */

/* SpedCare */

declare @appEntID1 as bigint

if (@appName = dbo.CONST_APP_NAME_SPEDCARE())
begin
   
   set @appEntID1 = 3 /* partition 3 */

  insert into @recsData (
    appName
  , displayOrder
  , name 
  , roleUserGroupID
  , roleUserRoleID 
  , roleUserRoleUID
  , roleUserRank 
  , appEntID1 
  , appEntID2
  )
  select distinct
      dbo.CONST_APP_NAME_SPEDCARE()
    , 4
    , 'Client Users - Provider -- ' + n.GROUP_SERVICE_CLASS_NAME
    , dbo.CONST_USER_GROUP_CLIENT()
    , 7
    , dbo.CONST_ROLE_PROVIDER()
    , 1
    , p.GROUP_SERVICE_CLASS_PARTITION_ID
    , n.GROUP_SERVICE_CLASS_NAME_ID

from Spedmon.dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS              as p
join Spedmon.dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on png.GROUP_SERVICE_CLASS_PARTITION_ID = p.GROUP_SERVICE_CLASS_PARTITION_ID
join Spedmon.dbo.GROUP_GROUP_SERVICE_CLASS_NAMES                   as n   on n.GROUP_SERVICE_CLASS_NAME_ID        = png.GROUP_SERVICE_CLASS_NAME_ID
where 
  (p.GROUP_SERVICE_CLASS_PARTITION_ID = @appEntID1)


end


insert into @recs
select 
  id = dense_rank ( ) over ( 
    order by 
      appName
    , isnull (rd.roleUserGroupID, 0)
    , isnull (rd.roleUserRoleID,  0)
    , isnull (rd.appEntID1,       0)
    , isnull (rd.appEntID2,       0)
  )  
  , rd.* 
   
from @recsData as rd

return

end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[APP_MAN_PAGES_USER_ROLES_VIEW_CORE_OLD] TO [webuser]
GO



