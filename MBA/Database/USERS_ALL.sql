USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[USERS_ALL]'))
DROP VIEW [dbo].[USERS_ALL]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE VIEW [dbo].[USERS_ALL] 
AS

/*============================================================
 * Basic
 *============================================================*/ 

with
cte_p1
as
(
  select 
      [id]                         = u.userrid
    , userIDInt                    = u.userrid
    , [uid]                        = u.UserId
    , [userName]                   = u.UserName
	, [userPassword]               = m.Password
    , [lastName]                   = m.LastName
    , [firstName]                  = m.FirstName
	, [name]                       = m.FirstName + N' ' + m.LastName
    , [phone]                      = m.PhoneNumber
    , [email]                      = m.Email
	, [sendUserEmailNotifications] = m.sendUserEmailNotifications
	, [accountCreatedOn]           = m.CreateDate
	, [accountIsLockedOut]         = m.IsLockedOut
	, [lastLoginDate]              = m.LastLoginDate
	, [failedPasswordAttemptCount] = m.FailedPasswordAttemptCount
	, [passwordMustBeChanged]      = isnull(m.passwordMustBeChanged,0)
	, [passwordLastChanged]        = m.LastPasswordChangedDate
    , [roleID]                     = rd.id
    , [roleUID]                    = r.RoleId
    , [roleRank]                   = rd.rank
    , [roleName]                   = r.RoleName
    , [roleNameLowered]            = r.LoweredRoleName  
    , [userGroupID]                = rd.userGroup
    , [userGroupName]              = ug.groupName
    , [userGroupRank]              = ug.groupRank
    , [appName]                    = ug.appName
    , [clientID]                   = isnull(m.District_ID,0)
    , [pcalStaff]                  = m.SBSC_Employee
	, [implicitDataAccess]         = rd.implicitDataAccess
	, [startingPage]               = rd.startingPage
	, [selpaCode]                  = iif(  /* If user account requires selpa code association*/ 
	                                       ((rd.reqSelpaAsc = 1) and (rd.ascSelpaWithAcct = 1))
	                                       /* Use user account associated selpa code */
										   , m.SELPA_CODE 
										   /* Otherwise if user account requires a client id association */
										   , (iif ( ((rd.reqClientAsc = 1) and (rd.ascClientWithAcct = 1)) 
										   /* Use selpa associated with client*/
										   , (select top 1 isnull(clc.SELPACode,0) from SPEDMON.dbo.CLIENTS_Client as clc where (clc.CLIENT_ID = m.District_ID))
										   /* Otherwise use 0 */
										  , 0 )))
	, m.[initialPasswordChangeCompleted]

  from dbo.Users        as u
  join dbo.Membership   as m  on m.UserId   = u.UserId
  join dbo.UsersInRoles as ur on ur.UserId  = u.UserId
  join dbo.Roles        as r  on r.RoleId   = ur.RoleId
  join dbo.RoleData     as rd on rd.RoleId  = ur.RoleId
  join dbo.UserGroup    as ug on ug.id      = rd.userGroup
)
,
cte_p2
as
(
  select 
      p1.*
	, [token]               = ws.Token
	, [sessionToken]        = ws.Token
	, [sessionCreated]      = ws.SessionCreated
	, [sessionLastAccess]   = ws.SessionLastAccess
	, [sessionExpires]      = ws.SessionExpires
	, [sessionTokenExpires] = ws.TokenExpires
  from      cte_p1          as p1
  left join dbo.WebSessions as ws on ws.UserID = p1.uid
)
,
cte_p3
as
(
  select 
      p2.*
    , [clientName]                    = clc.CLIENT_NAME
	, [clientRepUserId]               = ccr.user_id  
	, teleCommTeleHealthAccessGranted = convert(bit,iif((pcalStaff = 1),1,isnull(clc.teleCommTeleHealthAccessGranted,0)))
	, teleCommTeleIEPAccessGranted    = convert(bit,iif((pcalStaff = 1),1,isnull(clc.teleCommTeleIEPAccessGranted,0))) 
	, selpaName                       = slp.[name]
	, cybhiConsortiumBilling          = isnull (clc.cybhiConsortiumBilling,     0)
	, cybhiConsortiumLeadClientID     = isnull (clc.cybhiConsortiumLeadClientID,0)
  from      cte_p2                          as p2
  left join SPEDMON.dbo.CLIENTS_Client      as clc on clc.CLIENT_ID = p2.clientID
  left join SPEDMON.dbo.CLIENTS_Client_Reps as ccr on ccr.id        = clc.ClientRepIDLEACurrent
  left join SPEDMON.dbo.SELPAS              as slp on slp.code      = p2.selpaCode                 
)
,
cte_p4
as
(
  select 
      p3.* 
	  
	  /* Lead client is denoted as having consortium billing = 1 and lead client selection as null or 0 */
	  /* Keep lead client identification logic in synch with C:\SBSC\Spedmon\Database\CYBHI_CONSORTIUM_MEMBERS_VIEW.sql */

	, cybhiConsortiumBillingIsLead = convert(bit,(iif (((p3.cybhiConsortiumBilling = 1) and (p3.cybhiConsortiumLeadClientID = 0)),1,0)))
    , crm.*

  from cte_p3 as p3
  
  outer apply (

    select top 1
  
      isnull(m.FirstName,  N'') as clientRepFirstName
    , isnull(m.LastName,   N'') as clientRepLastName
    , isnull(m.Email,      N'') as clientRepEmail
    , isnull(m.PhoneNumber,N'') as clientRepPhone
  
    from dbo.Users       as u
    join dbo.Membership  as m on m.UserId = u.UserID
  
    where 
      (u.userrid = p3.clientRepUserId)
  ) as crm
)
,
cte_p5
as
(
  /* TODO: Test joining to the prac client table to see if we can lift the restriction on
     p4.userGroupID = 1 */
  select 
      p4.* 
    , [pracID]                  = prp.PRACTITIONER_ID
    , [pracName]                = prp.CONCAT_NAME
    , [pracDispGroupID]         = pgd.GROUP_ID
    , [pracDispGroupName]       = ggd.GROUP_NAME
    , [pracReptGroupID]         = ggr.GROUP_ID
    , [pracReptGroupName]       = ggr.GROUP_NAME
    , [pracGroupSvcClassNameID] = png.GROUP_SERVICE_CLASS_NAME_ID
    , [pracGroupSvcClassName]   = scn.GROUP_SERVICE_CLASS_NAME
    , [pracIsDeptHead]          = isnull(prp.deptHead,0)
    , [pracIsDeptHeadThatCanViewEntirePracFamInDeptReviewReports] = prp.[deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports]
  from      cte_p4                                as p4
  left join SPEDMON.dbo.PRACTITIONER_Practitioner as prp on  prp.PRAC_ASP_ID = p4.uid  
                                                         and p4.userGroupID = 1 /* Limit to client group*/

  left join SPEDMON.dbo.PRACTITIONER_GROUPS       as pgd  on  pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID
                                                          and pgd.GROUP_TYPE      IN (1,2)
  left join SPEDMON.dbo.GROUP_Group               as ggd  on  ggd.GROUP_ID = pgd.GROUP_ID
  
  left join SPEDMON.dbo.PRACTITIONER_GROUPS       as pgr  on  pgr.PRACTITIONER_ID = prp.PRACTITIONER_ID
                                                          and pgr.GROUP_TYPE      IN (3,5)
  left join SPEDMON.dbo.GROUP_Group               as ggr  on  ggr.GROUP_ID = pgr.GROUP_ID

  left join SPEDMON.dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on png.GROUP_SERVICE_CLASS_PARTITION_ID = 100
                                                                                 and png.GROUP_ID = ggd.GROUP_ID
																				 and png.GROUP_SERVICE_CLASS_NAME_ID is not null
  
  left join SPEDMON.dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as scn on scn.GROUP_SERVICE_CLASS_NAME_ID = png.GROUP_SERVICE_CLASS_NAME_ID
)

select 
  p5.* 
from cte_p5 as p5

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[USERS_ALL] TO [webuser]
GO