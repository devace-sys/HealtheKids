USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_USER_ROLES_FOR_USER_ID_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_USER_ROLES_FOR_USER_ID_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[APP_MAN_PAGES_USER_ROLES_FOR_USER_ID_VIEW_CORE] ( 
    @appName   varchar(50)    
  , @userID    bigint   
)

RETURNS @recs
table (
    id                             bigint
  , appName                        varchar(50)
  , displayOrder                   int
  , [name]                         varchar(512)
  , roleUserGroupID                bigint
  , roleUserRoleID                 bigint
  , roleUserRoleUID                uniqueidentifier
  , roleUserRank                   bigint
  , appEntID1                      bigint
  , appEntID2                      bigint
  , appEntID3                      bigint
  , userID                         bigint
  , userUID                        uniqueidentifier
  unique clustered (id)
)
AS
begin 


/***************************************************************************
 * APP_MAN_PAGES_USER_ROLES_FOR_USER_ID_VIEW_CORE */
/**
 * Returns man page user roles that are associated with the given userID
 *
 * @param  clientID        ID of client or null for all clients
 * @param  roleID          user's username or null
 * @param  appName         user's email or null 
 * @return                 Table of user data
 ***************************************************************************/ 

declare @userUID        as uniqueidentifier
declare @userGroupID    as int
declare @userRoleID     as bigint
declare @userRoleUID    as uniqueidentifier
declare @districtID     as bigint

/*###########################################################################
  # Retrieve additional data about given user
  ###########################################################################*/  

select top 1

    @userUID     = u.UserId 
  , @userGroupID = rd.userGroup
  , @userRoleID  = rd.id
  , @userRoleUID = rd.RoleID
  , @districtID  = m.District_ID

from dbo.Users        as u
join dbo.Membership   as m  on m.UserId  = u.UserId
join dbo.UsersInRoles as ur on ur.UserId = u.UserId
join dbo.RoleData     as rd on rd.RoleId = ur.RoleId 
join dbo.UserGroup    as ug on ug.id     = rd.userGroup 

where ((u.userrid = @userID) and (rd.appName = @appName) and (ug.appName = @appName))

/*###########################################################################
  # Exit early if user is not found
  ###########################################################################*/  

if (@userUID is null) return

/*###########################################################################
  # User man page role data for man pages to be seen by all users
  ###########################################################################*/  

insert into @recs (
    id            
  , appName
  , displayOrder
  , name   
  , roleUserGroupID
  , roleUserRoleID 
  , roleUserRoleUID
  , roleUserRank   
  , appEntID1 
  , appEntID2 
  , appEntID3 
  , userID 
  , userUID
)
select top 1 
    t1.id            
  , t1.appName
  , t1.displayOrder
  , t1.name   
  , t1.roleUserGroupID
  , t1.roleUserRoleID 
  , t1.roleUserRoleUID
  , t1.roleUserRank   
  , t1.appEntID1 
  , t1.appEntID2 
  , t1.appEntID3
  , userID  = @userID
  , userUID = @userUID  
from dbo.AppManPagesUserRoles as t1
where (
      (t1.appName         = @appName)
  and (t1.roleUserGroupID is null)
  and (t1.roleUserRoleID  is null)
  and (t1.appEntID1       is null)
  and (t1.appEntID2       is null)
  and (t1.appEntID3       is null)
  and (t1.active          = 1)
)

/*###########################################################################
  # User man page role data for man pages to be seen by all users in a
  # specific user group 
  ###########################################################################*/  

insert into @recs (
    id            
  , appName
  , displayOrder
  , name   
  , roleUserGroupID
  , roleUserRoleID 
  , roleUserRoleUID
  , roleUserRank   
  , appEntID1 
  , appEntID2 
  , appEntID3 
  , userID 
  , userUID
)
select top 1 
    t1.id            
  , t1.appName
  , t1.displayOrder
  , t1.name   
  , t1.roleUserGroupID
  , t1.roleUserRoleID 
  , t1.roleUserRoleUID
  , t1.roleUserRank   
  , t1.appEntID1 
  , t1.appEntID2 
  , t1.appEntID3 
  , userID  = @userID
  , userUID = @userUID  

from dbo.AppManPagesUserRoles as t1
where (
      (t1.appName         = @appName)
  and (t1.roleUserGroupID = @userGroupID)
  and (t1.roleUserRoleID  is null)
  and (t1.appEntID1       is null)
  and (t1.appEntID2       is null)
  and (t1.appEntID3       is null)
  and (t1.active          = 1)
)

/*###########################################################################
  # User man page role data for man pages to be seen by all users in a
  # specific user group and specific user role
  ###########################################################################*/  

insert into @recs (
    id            
  , appName
  , displayOrder
  , name   
  , roleUserGroupID
  , roleUserRoleID 
  , roleUserRoleUID
  , roleUserRank   
  , appEntID1 
  , appEntID2 
  , appEntID3 
  , userID 
  , userUID
)
select top 1 
    t1.id            
  , t1.appName
  , t1.displayOrder
  , t1.name   
  , t1.roleUserGroupID
  , t1.roleUserRoleID 
  , t1.roleUserRoleUID
  , t1.roleUserRank   
  , t1.appEntID1 
  , t1.appEntID2 
  , t1.appEntID3 
  , userID  = @userID
  , userUID = @userUID  

from dbo.AppManPagesUserRoles as t1
where (
      (t1.appName         = @appName)
  and (t1.roleUserGroupID = @userGroupID)
  and (t1.roleUserRoleID  = @userRoleID)
  and (t1.appEntID1       is null)
  and (t1.appEntID2       is null)
  and (t1.appEntID3       is null)
  and (t1.active          = 1)
)

/*###########################################################################
  # Application specific 
  ###########################################################################*/  

if (@appName = dbo.CONST_APP_NAME_SPEDCARE())
begin

  /*---------------------------------------------------------------------------
    - SpEdCare - Provider/Practitioner Specific
    ---------------------------------------------------------------------------*/  

  if (@userRoleUID = dbo.CONST_ROLE_PROVIDER())
  begin
    
	/*---------------------------------------------------------------------------
      - Get practitioner data for user
      ---------------------------------------------------------------------------*/  

    declare @pracID          as bigint
    declare @groupID         as bigint
    declare @svcClassNameID  as bigint
	declare @svcClassPartID  as bigint = 3

	select top 1
    
	    @pracID         = pp.PRACTITIONER_ID 
      , @groupID        = pg.GROUP_ID
	  , @svcClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID
	
	from SPEDMON.dbo.CLIENTS_Client            as cc
    join SPEDMON.dbo.PRACTITIONER_Client       as pc on pc.CLIENT_ID        = cc.CLIENT_ID
    join SPEDMON.dbo.PRACTITIONER_Practitioner as pp on pp.PRACTITIONER_ID  = pc.PRACTITIONER_ID
	join SPEDMON.dbo.PRACTITIONER_GROUPS       as pg on (pg.PRACTITIONER_ID = pp.PRACTITIONER_ID and pg.GROUP_TYPE in (1,2))
	
	join SPEDMON.dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on (png.GROUP_SERVICE_CLASS_PARTITION_ID =  @svcClassPartID /* partition 3 */
	                                                                          and png.GROUP_ID = pg.GROUP_ID
																			  and png.GROUP_SERVICE_CLASS_NAME_ID is not null)
	where (
          (cc.CLIENT_ID   = @districtID)
      and (pp.UserID      = @userID)
    )
       
	/*---------------------------------------------------------------------------
      - In specific provider group family
      ---------------------------------------------------------------------------*/  

    insert into @recs (
        id            
      , appName
      , displayOrder
      , name   
      , roleUserGroupID
      , roleUserRoleID 
      , roleUserRoleUID
      , roleUserRank   
      , appEntID1 
      , appEntID2 
      , appEntID3 
      , userID 
      , userUID
	)
	select top 1
        t1.id            
      , t1.appName
      , t1.displayOrder
      , t1.name   
      , t1.roleUserGroupID
      , t1.roleUserRoleID 
      , t1.roleUserRoleUID
      , t1.roleUserRank   
      , t1.appEntID1 
      , t1.appEntID2 
      , t1.appEntID3 
      , userID  = @userID
      , userUID = @userUID  

     from dbo.AppManPagesUserRoles as t1
	 where (
            (t1.appName         = @appName)
        and (t1.roleUserGroupID = @userGroupID)
        and (t1.roleUserRoleID  = @userRoleID)
        and (t1.appEntID1       = @svcClassPartID)
        and (t1.appEntID2       = @svcClassNameID)
        and (t1.appEntID3       is null)
		and (t1.appEntID4       is null) /* for future use*/
		and (t1.active          = 1)
     )
     
	 /*---------------------------------------------------------------------------
      - In specific provider group family and discipline group in that family
      ---------------------------------------------------------------------------*/  

	 insert into @recs (
        id            
      , appName
      , displayOrder
      , name   
      , roleUserGroupID
      , roleUserRoleID 
      , roleUserRoleUID
      , roleUserRank   
      , appEntID1 
      , appEntID2 
      , appEntID3 
      , userID 
      , userUID
	)
	select top 1
        t1.id            
      , t1.appName
      , t1.displayOrder
      , t1.name   
      , t1.roleUserGroupID
      , t1.roleUserRoleID 
      , t1.roleUserRoleUID
      , t1.roleUserRank   
      , t1.appEntID1 
      , t1.appEntID2 
      , t1.appEntID3 
      , userID  = @userID
      , userUID = @userUID  
	  from dbo.AppManPagesUserRoles as t1
      where (
            (t1.appName         = @appName)
        and (t1.roleUserGroupID = @userGroupID)
        and (t1.roleUserRoleID  = @userRoleID)
        and (t1.appEntID1       = @svcClassPartID)
        and (t1.appEntID2       = @svcClassNameID)
		and (t1.appEntID3       = @groupID)
		and (t1.appEntID4 is null) /* for future use*/
        and (t1.active          = 1)
	  )
  end

end

/*###########################################################################
  # Return data
  ###########################################################################*/  


return

end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[APP_MAN_PAGES_USER_ROLES_FOR_USER_ID_VIEW_CORE] TO [webuser]
GO



