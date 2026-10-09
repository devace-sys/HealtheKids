USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONERS_SUPERVISED_BY_GROUP_ID_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONERS_SUPERVISED_BY_GROUP_ID_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
	 
CREATE FUNCTION [dbo].[PRACTITIONERS_SUPERVISED_BY_GROUP_ID_VIEW] (
    @clientID bigint
  , @groupID  bigint
)
RETURNS TABLE 
AS 
RETURN (
 
/***************************************************************************    
 * PRACTITIONERS_SUPERVISED_BY_GROUP_ID_VIEW */    
/**    
 * Returns list of active practitioners supervised by a groupID within clientID
 *
 * @param clientID  Client ID
 * @param groupID   Supervisors group ID
 * 
 ***************************************************************************/      

select 
   vgs.*
  ,pp.*
  ,u.UserName
from      dbo.GROUPS_SUPERVISED_BY_GROUP_ID_VIEW (@groupID) as vgs
join      dbo.PRACTITIONER_GROUPS                           as pg on pg.GROUP_ID        = vgs.GROUP_ID
join      dbo.PRACTITIONER_Client                           as pc on pc.PRACTITIONER_ID = pg.PRACTITIONER_ID
join      dbo.PRACTITIONER_PRACTITIONER                     as pp on pp.PRACTITIONER_ID = pc.PRACTITIONER_ID
left join users.dbo.Users                                   as u  on u.userrid           = pp.UserID
where   
      (pc.CLIENT_ID = @clientID)
  and (pp.ACTIVE    = 1)
  
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONERS_SUPERVISED_BY_GROUP_ID_VIEW] TO [webuser]
GO
