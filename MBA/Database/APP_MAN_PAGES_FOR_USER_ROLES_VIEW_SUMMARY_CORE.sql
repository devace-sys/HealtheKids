USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_FOR_USER_ROLES_VIEW_SUMMARY_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_FOR_USER_ROLES_VIEW_SUMMARY_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[APP_MAN_PAGES_FOR_USER_ROLES_VIEW_SUMMARY_CORE] ( @appName varchar(50) )

RETURNS 

@recs table (
    pageID           bigint
  , userRoleIdsStr   varchar(max)
  , userRoleNamesStr varchar(max)
    -- TODO: idk yet if this UDF will require a param for clientID
unique clustered (pageID)
)

as
begin

declare @baseData as table (
    pageId       bigint
  , userRoleId   bigint
  , userRoleName varchar(256)  
  unique clustered (pageId, userRoleID, userRoleName)
)

insert into @baseData (
    pageId
  , userRoleId
  , userRoleName
)
select   
    mpur.pageId                as pageId
  , mpur.appManPageUserRoleID  as userRoleId
  , rd.[name]                  as userRoleName  
from dbo.AppManPagesForUserRoles as mpur
join dbo.AppManPagesUserRoles    as rd on rd.id = mpur.appManPageUserRoleID

insert into @recs (
    pageID    
  , userRoleIdsStr
  , userRoleNamesStr
)
select 
    pageId 
  , urv.userRoleIdsStr
  , urn.userRoleNamesStr
from @baseData as t1 

cross apply (      
  select [userRoleIdsStr] = stuff((select N',' + userRoleIdStr from (
    select convert(varchar(50),userRoleId) as userRoleIdStr from @baseData as t2 
    where (t2.pageId = t1.pageId)
  ) as q1
  for xml path(''),type).value('text()[1]','nvarchar(max)'),1,1,N'')
) as urv

cross apply (      
  select [userRoleNamesStr] = stuff((select N'|' + userRoleNameStr from (
    select userRoleName as userRoleNameStr from @baseData as t2 
    where (t2.pageId = t1.pageId)
  ) as q1
  for xml path(''),type).value('text()[1]','nvarchar(max)'),1,1,N'')
) as urn

group by  
    t1.pageId
  , urv.userRoleIdsStr
  , urn.userRoleNamesStr

return
end
go