USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[WEB_BROWSER_STATS_DETAIL_SUMMARY]'))
DROP VIEW [dbo].[WEB_BROWSER_STATS_DETAIL_SUMMARY]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE VIEW [dbo].[WEB_BROWSER_STATS_DETAIL_SUMMARY] AS

with 

/*============================================================
 * Summmarize output of WEB_BROWSER_STATS view
 * and limit to just users who logged in successfully
 *============================================================*/
 
cte_browser_stats_summary_data
as
(
  select        
  
    UserID,
    UserAgent,
    BrowserName,
    OSName,      
    min(LoggedOn) as [FirstLogin], /* First login with OS + Browser */
    max(LoggedOn) as [LastLogin]   /* Last login with OS + Browser  */
  
  from WEB_BROWSER_STATS

  where 
    UserID is not null /* Limit to just succesfull logins */

  group by
  
    UserID,
    UserAgent,
    BrowserName,
    OSName    
)
,


/*============================================================
 * Link summary of WEB_BROWSER_STATS view
 * to user data
 *============================================================*/
 
cte_browser_stats_summary_data_with_user_data
as
(
  select
    bs.OSName,      
    bs.BrowserName, 
    c.CLIENT_NAME,
    bs.UserAgent,
    isnull(m.LastName,'')    as LastName,
    isnull(m.FirstName,'')   as FirstName,    
    r.RoleName,
    m.Email,
    bs.FirstLogin,
    bs.LastLogin,
    rd.userGroup,
    bs.UserID,
    rd.RoleId,
    m.District_ID

from cte_browser_stats_summary_data   as bs
join Users                            as u  on u.UserId  = bs.UserID
join Membership                       as m  on m.UserId  = u.UserId
join UsersInRoles                     as ur on ur.UserId = u.UserId
join Roles                            as r  on r.RoleId  = ur.RoleId
join RoleData                         as rd on rd.RoleId = r.RoleId
left join SPEDMON.dbo.CLIENTS_Client  as c  on c.CLIENT_ID = m.District_ID
)
,

/*============================================================
 * Take summary of WEB_BROWSER_STATS view and user data
 * and add user class
 *============================================================*/
 
cte_browser_stats_summary_data_with_user_data_and_user_class
as
(
select 
  *, 
  [UserClass] = case
    when  (userGroup = dbo.CONST_USER_GROUP_CLIENT())                                                       then 'Client'
    when ((userGroup = dbo.CONST_USER_GROUP_SBS()) and (RoleId =  '405121DE-2699-493C-968D-FC87E3F2DDEF'))  then 'A&I'
    when ((userGroup = dbo.CONST_USER_GROUP_SBS()) and (RoleId != '405121DE-2699-493C-968D-FC87E3F2DDEF'))  then 'SBSC'
  end
  from cte_browser_stats_summary_data_with_user_data
)

/*============================================================
 * Final output
 *============================================================*/

select

  UserClass                    as [User Class],
  CLIENT_NAME                  as [Client Name],
  LastName + ', ' + FirstName  as [User Name],
  RoleName                     as [User Role],
  Email                        as [User Email],
  OSName                       as [OS Name],
  BrowserName                  as [Browser Name],
  FirstLogin                   as [First Login],
  LastLogin                    as [Last Login],
  UserAgent                    as [UserAgentStr],
  UserID                       as [UserID],
  RoleID                       as [UserRoleID],
  District_ID                  as [ClientID]

from cte_browser_stats_summary_data_with_user_data_and_user_class


GO
