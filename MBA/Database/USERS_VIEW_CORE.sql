USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.USERS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[USERS_VIEW_CORE] (
    @userID      bigint
  , @userGroup   int
  , @userRank    int
  , @appName     varchar(50)
  , @username    nvarchar(256)
  , @token       varchar(100) 
  , @uid         uniqueidentifier
  , @id          bigint
)

RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * USERS_VIEW_CORE */
/**
 * Displays user data
 *
 * @param  appName         Application name
 * @return                 Table of user data
 ***************************************************************************/ 

   select    
      udc.* 
	, canEdit = dbo.INT_HAS_VALUE(ce.id) 
    , mp.numUnreadManPages    
	, aard.allAssignedRolesDataJSON     
   from dbo.USERS_DATA_CORE (@appName, @username, @token, @uid, @id) as udc
   
   /* Can calling user edit this user record? */

   outer apply (
	  select top 1
	    rrd.id
      from dbo.Users          as u
	  join dbo.UsersInRoles   as ur on  ur.UserId    = u.UserId
	  join dbo.RoleToRoleData as rrd on rrd.Role1Uid = ur.RoleId	  
	  where ((u.userrid = @userID) and (rrd.Role2Uid = udc.roleUID) and (rrd.Role1CanAddEditDelRole2 = 1))
   ) as ce

   /* How many unread announcements does the user record have? */

   cross apply (
      select 
        COUNT(pageID) as numUnreadManPages    
    from
    (
      select 
          pageID
        , numOfTimes 
      from dbo.APP_MAN_PAGES_USER_RESPONSE_VIEW_STATS_SUMMARY_CORE (@appName, udc.id, 3, getdate(), null)
      where (numOfTimes = 0)
    ) as t1
   ) as mp

   /* Keep fields in synch with MBA.UserAssignedRole */

   outer apply (
     select 
	   allAssignedRolesDataJSON = convert(varchar(max),(
	     select 
           roleID             = rd.id       
	     , roleUID            = uir.RoleId
         , roleRank           = rd.rank
		 , roleName           = r.RoleName
         , roleNameLowered    = r.LoweredRoleName
         , roleShortName      = rd.shortName
         , userGroupID        = rd.userGroup
		 , userGroupName      = ug.groupName
		 , userGroupRank      = ug.groupRank
		 , appName            = rd.appName
      from dbo.UsersInRoles as uir
      join dbo.Roles        as r  on r.RoleId  = uir.RoleId
      join dbo.RoleData     as rd on rd.RoleId = r.RoleId
      join dbo.UserGroup    as ug on ug.id = rd.userGroup
	  where (uir.UserId = udc.uid)
      FOR JSON PATH, ROOT('roles')
     )
    )
) as aard

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[USERS_VIEW_CORE] TO [webuser]
GO