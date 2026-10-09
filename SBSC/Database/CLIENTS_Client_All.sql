USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client_All]'))
DROP VIEW [dbo].[CLIENTS_Client_All]
GO

USE [SPEDMON]
GO

CREATE VIEW [dbo].[CLIENTS_Client_All] 
AS 
(

/***************************************************************************    
 * CLIENTS_Client_All */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

select 
    cc.CLIENT_ID
  , cc.CLIENT_NAME
  , cc.CLIENT_CDS
  , CLIENT_NPI = cc.NPI
  , cr.REP_ID
  , REP_NAME = case when isnull(cr.REP_NAME,'') = '' then 'No Rep in SpEdCare' else cr.REP_NAME end
  , cr.REP_EMAIL
  , cr.REP_PHONE
  , cr.REP_USER_ID
  , cr.REP_USER_ROLE_NAME
  , COMPANY_NAME = comp.name
  , cc.APPROVED_837
  , cc.APPROVED_835
  , cc.TCM_RATE 
  , cc.LEA
  , LEA_RECOVERY_BUDGET             = cc.LEARecoveryBudget
  , HOLD_CLIENT_WORK_FOR_DAYS       = cc.numDaysToHoldClientEnteredClaims
  , CLIENT_CLAIM_TCM                = cc.CLAIM_TCM
  , CLIENT_CLAIM_NO_PLAN            = cc.claimNoPlan
  , CLIENT_PARENT_CONSENT_AGREEMENT = cc.parentConsentAgreement
  , LAST_TRANSMISSION_GENERATION_ID = tg.id
  , LAST_TRANSMISSION_DATETIME      = tg.dateCreated

from dbo.CLIENTS_Client as cc

outer apply (
  select top 1     
      REP_ID             = ccr.id
    , REP_USER_ID        = ccr.user_id
    , REP_NAME           = ltrim(rtrim(ltrim(rtrim(isnull(ccr.first_name,''))) + ' ' + ltrim(rtrim(isnull(ccr.last_name,'')))))     
    , REP_EMAIL          = m.Email  
    , REP_PHONE          = m.PhoneNumber
    , REP_USER_ROLE_NAME = r.RoleName
  
  from       dbo.CLIENTS_Client_Reps as ccr
  join users.dbo.Users               as u   on u.userrid = ccr.user_id
  join users.dbo.Membership          as m   on m.UserId  = u.UserId
  join users.dbo.UsersInRoles        as ur  on ur.UserId = m.UserId
  join users.dbo.Roles               as r   on r.RoleId  = ur.RoleId
  join users.dbo.RoleData            as rd  on rd.RoleId = r.RoleId  

  where 
    (ccr.id = cc.ClientRepIDLEACurrent)
) as cr

outer apply (
  select top 1 
      t1.dateCreated
    , t1.id 
  from dbo.TRANSMISSION_GENERATIONS as t1
  where (t1.clientID = cc.CLIENT_ID) 
  order by 
      t1.dateCreated desc
    , t1.id          desc
) as tg

outer apply (
  select top 1 name from dbo.COMPANIES as t1
  where t1.id =  cc.OwnedByCompanyID_LEA  
) as comp

where (
  (cc.CLIENT_ID != 112) 
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENTS_Client_All] TO [webuser]
GO
