USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ROLES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ROLES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[ROLES_VIEW_CORE] (
     @userID      bigint
   , @userGroup   int
   , @userRank    int  
   , @appName     varchar(50)
   , @roleIdUid   uniqueidentifier
   , @roleId      bigint
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * ROLES_VIEW_CORE */
/**
 * Displays role data
 *
 * @param  appName         Application name
 * @param  userGroup       User group assigned to roles
                           1 = Client
                           2 = SBSC
 * @param  roleIdUid       Unique identifier for role (returns 1 role)
 * @param  roleIdInt       Integer identifier for role (returns 1 role)
 * @return                 Table of role data
 ***************************************************************************/ 
  
select
     r.RoleId            as IdUid
   , rd.id               as IdInt
   , rd.id               as id
   , r.RoleName          as name
   , r.LoweredRoleName
   , rd.shortName
   , rd.userGroup
   , rd.appName
   , rd.rank
   , ug.groupRank
   , compositeRank   = dbo.INT_CONCAT(ug.groupRank,rd.rank)
   , isSBSC          = convert(bit,(case rd.userGroup when (dbo.CONST_USER_GROUP_SBS()) then 1 else 0 end))
   , rd.reqSelpaAsc
   , reqClientIDAssc = rd.reqClientAsc
   , reqPracIDAssc   = rd.reqPracAsc   
   , reqPrtGrdIDAscc = rd.reqPrtGrdAsc     
   , reqPatIDAscc    = rd.reqPatAsc

   , rd.ascSelpaWithAcct
   , rd.ascClientWithAcct
   , rd.ascPracWithAcct
   , rd.ascPrtGrdWithAcct
   , rd.ascPatWithAcct
   
   , reqSelpaAscStr       = dbo.RPT_BIT_TO_YN(rd.reqSelpaAsc)
   , reqClientIDAsscStr   = dbo.RPT_BIT_TO_YN(rd.reqClientAsc)
   , reqPracIDAsscStr     = dbo.RPT_BIT_TO_YN(rd.reqPracAsc)   
   , reqPrtGrdIDAsccStr   = dbo.RPT_BIT_TO_YN(rd.reqPrtGrdAsc)
   , reqPatIDAsccStr      = dbo.RPT_BIT_TO_YN(rd.reqPatAsc)

   , ascSelpaWithAcctStr  = dbo.RPT_BIT_TO_YN(rd.ascSelpaWithAcct)
   , ascClientWithAcctStr = dbo.RPT_BIT_TO_YN(rd.ascClientWithAcct)
   , ascPracWithAcctStr   = dbo.RPT_BIT_TO_YN(rd.ascPracWithAcct)
   , ascPrtGrdWithAcctStr = dbo.RPT_BIT_TO_YN(rd.ascPrtGrdWithAcct)
   , ascPatWithAcctStr    = dbo.RPT_BIT_TO_YN(rd.ascPatWithAcct)

   , rd.canHaveMultiClientPracAsc
   , rd.canHaveMultiClientPrtGrdAsc
   , rd.canHaveMultiClientPatAsc

   , rd.pracMustHaveEmploymentRelationshipWithClient
   , rd.pracCannotHaveEmploymentRelationshipWithClient
   , rd.implicitDataAccess
   , rd.newAccountMessageTemplateTitle
   , rd.newAccountMessageTemplateBody
   , rd.startingPage
   , canEdit   = dbo.INT_HAS_VALUE(ce.id)
   , rd.display
   , rd.canChangeToDifferentRole

from  dbo.Roles     as r
join  dbo.RoleData  as rd on rd.RoleId = r.RoleId
join  dbo.UserGroup as ug on ug.id     = rd.userGroup

outer apply (
	  select top 1
	    rrd.id
      from dbo.Users          as u
	  join dbo.UsersInRoles   as ur on  ur.UserId    = u.UserId
	  join dbo.RoleToRoleData as rrd on rrd.Role1Uid = ur.RoleId	  
	  where ((u.userrid = @userID) and (rrd.Role2Uid = r.RoleId) and (rrd.Role1CanAddEditDelRole2 = 1))
) as ce

where (
       (1=1)
  and ((@appName   is null) or (rd.appName   = @appName))
  and ((@roleIdUid is null) or (r.RoleId     = @roleIdUid)) 
  and ((@roleId    is null) or (rd.id        = @roleId))
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[ROLES_VIEW_CORE] TO [webuser]
GO
