USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_USER_ROLES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_USER_ROLES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[APP_MAN_PAGES_USER_ROLES_VIEW] (
  @userID      BIGINT,    
  @userGroup   INT,    
  @userRank    INT,
  @appName     varchar(50),
  @term        varchar(256)
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * APP_MAN_PAGES_USER_ROLES_VIEW */
/**
 * Displays user data
 *
 * @param  clientID        ID of client or null for all clients
 * @param  roleID          user's username or null
 * @param  appName         user's email or null 
 * @return                 Table of user data
 ***************************************************************************/ 

select top (dbo.CONST_MAX_ROWS())
  t1.* 
from dbo.APP_MAN_PAGES_USER_ROLES_VIEW_CORE (@appName) as t1
where (
      (1=1)
  and ((@term is null) or (t1.name like '%' + isnull(@term,'') + '%'))
)
order by 
    t1.displayOrder
  , t1.name
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[APP_MAN_PAGES_USER_ROLES_VIEW] TO [webuser]
GO


