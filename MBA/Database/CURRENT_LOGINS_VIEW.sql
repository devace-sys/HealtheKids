USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CURRENT_LOGINS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CURRENT_LOGINS_VIEW
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CURRENT_LOGINS_VIEW] ( )
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * USERS_VIEW */
/**
 * Displays list of users currently logged in
 *
 * @return                 Table 
 ***************************************************************************/ 
    
with
cte_p1
as
(
  select 
    isnull(clc.CLIENT_NAME,'') as Client
  , u.UserName
  , m.LastName
  , m.FirstName
  , m.Email
  , r.RoleName
  , wbl.LoggedOn
  , ws.SessionCreated
  , DATEDIFF(minute,ws.SessionCreated,getdate())    as CreatedMinutesAgo
  , ws.SessionLastAccess
  , DATEDIFF(minute,ws.SessionLastAccess,getdate()) as LastAccessMinutesAgo
  , ws.SessionExpires
  , DATEDIFF(minute,getdate(),ws.SessionExpires)    as SessionExpiresInMinutes
  , ws.TokenExpires
  , DATEDIFF(minute,getdate(),ws.TokenExpires)      as TokenExpiresInMinutes
  , wbl.UserIP
  , wbl.UserAgent
  , ws.Token
  
  from      dbo.WebSessions     as ws
  join      dbo.Users           as u   on u.UserId  = ws.UserID
  join      dbo.Membership      as m   on m.UserId  = u.UserId
  join      dbo.UsersInRoles    as ur  on ur.UserId = m.UserId
  join      dbo.Roles           as r   on r.RoleId  = ur.RoleId
  join      dbo.WEB_BROWSER_LOG as wbl on wbl.Token = ws.Token

  left join SPEDMON.dbo.CLIENTS_Client as clc on clc.CLIENT_ID = m.District_ID
  
  where (
    (getdate() between ws.SessionCreated and ws.SessionExpires)
  )
)
,
cte_p2
as
(
  select 
    * 
  from cte_p1 
  where (
    (SessionExpiresInMinutes > 0) and (TokenExpiresInMinutes > 0)
  )
)
select top (dbo.CONST_MAX_ROWS())
  * 
from cte_p2
order by 
    Client
  , UserName
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CURRENT_LOGINS_VIEW] TO [webuser]
GO
