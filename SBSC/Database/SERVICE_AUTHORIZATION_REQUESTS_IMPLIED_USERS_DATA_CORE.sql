USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUESTS_IMPLIED_USERS_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUESTS_IMPLIED_USERS_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUESTS_IMPLIED_USERS_DATA_CORE] (
    @userID                            BIGINT
  , @clientID                          BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SERVICE_AUTHORIZATION_REQUESTS_IMPLIED_USERS_DATA_CORE */    
 /**    
  * Retuns a list of users that have implied access to service authorization
  * requests
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

select top 1

    iudc.userrid
  , saprc.isRdp
  , saprc.isPg
  , saprc.isOrp
  , saprc.isRa
  , saprc.isLEAAdmin
  , saprc.isPCALStaff
  , sarras.responseAttestStatement
  , saprc.canAccessSupportingFiles
  , responseAttestStatementID = sarras.id
  , personRoleCode = saprc.code
from dbo.SERVICE_AUTHORIZATION_PERSON_ROLE_CODES                  as saprc
join dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_ATTEST_STATEMENTS as sarras on sarras.id = saprc.responseAttestStatementID

cross apply (

  select top 1
    u.userrid
  from users.dbo.Users        as u
  join users.dbo.Membership   as m  on m.UserId  = u.UserId
  join users.dbo.UsersInRoles as ur on ur.UserId = m.UserId
  join users.dbo.Roles        as r  on r.RoleId  = ur.RoleId
  join users.dbo.RoleData     as rd on rd.RoleId = r.RoleId

  where ( 
         (u.userrid     = @userID)
     and (m.District_ID = @clientID)
     and (ur.RoleId in ( '763CCE66-8E74-4A8C-BD9D-3397DA78D839'
                        ,'7CEB023D-4D25-40CF-B64E-E6FCE4960B26'))
  )
) as iudc

where ((saprc.code = 1000) and (saprc.explicitAccess = 0))

union

select top 1

    iudp.userrid
  , saprc.isRdp
  , saprc.isPg
  , saprc.isOrp
  , saprc.isRa
  , saprc.isLEAAdmin
  , saprc.isPCALStaff
  , sarras.responseAttestStatement
  , saprc.canAccessSupportingFiles
  , responseAttestStatementID = sarras.id
  , personRoleCode = saprc.code
from dbo.SERVICE_AUTHORIZATION_PERSON_ROLE_CODES                  as saprc
join dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_ATTEST_STATEMENTS as sarras on sarras.id = saprc.responseAttestStatementID

cross apply (

  select top 1
    u.userrid
  from users.dbo.Users        as u
  join users.dbo.Membership   as m  on m.UserId = u.UserId
  join users.dbo.UsersInRoles as ur on ur.UserId = m.UserId
  join users.dbo.Roles        as r  on r.RoleId  = ur.RoleId
  join users.dbo.RoleData     as rd on rd.RoleId = r.RoleId

  where ( 
        (u.userrid = @userID)
    and (m.SBSC_Employee = 1)
    and (rd.userGroup    = 2)
  )
) as iudp

where ((saprc.code = 2000) and (saprc.explicitAccess = 0))

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_AUTHORIZATION_REQUESTS_IMPLIED_USERS_DATA_CORE] TO [webuser]
GO  
