USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.USERS_VIEW
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[USERS_VIEW] (
  @userID      BIGINT,    
  @userGroup   INT,    
  @userRank    INT,
  @recID       INT,
  @clientID    int,
  @roleID      int,
  @appName     varchar(50),
  @Username    nvarchar(256),
  @email       nvarchar(256),
  @token       VARCHAR(100),
  @lname       NVARCHAR(50),    
  @fname       NVARCHAR(50),
  @active      BIT,
  @canEdit     BIT)

RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * USERS_VIEW */
/**
 * Displays user data
 *
 * @param  clientID        ID of client or null for all clients
 * @param  userName        user's username or null
 * @param  email           user's email or null 
 * @param  token           Security token or null
 * @param  lname           All or part of users last name    
 * @param  fname           All or part of users first name    
 * @param  active          If user is active
 * @param  canEdit         If user can be edited by userID 
 * @return                 Table of user data
 ***************************************************************************/ 
    
SELECT 
  uvc.*

from dbo.USERS_VIEW_CORE (  @userID
                          , @userGroup
						  , @userRank
						  , @appName
						  , @Username
						  , @token
						  , null
						  , @recID ) as uvc

where
      (1=1)
   and  ((@clientID  IS null) or (uvc.clientID = @clientID))
   and  ((@roleID    IS null) or (uvc.roleID   = @roleID))
   and  ((@active    IS NULL) OR (uvc.active   = @active))
   and  ((@email     IS NULL) OR (uvc.email    = @Email))
   and 	((@canEdit IS NULL) OR (uvc.canEdit = @canEdit))
   and  ((@lname   IS NULL) OR (uvc.lastName  like ((@lname+'%'))))
   and  ((@fname   IS NULL) OR (uvc.firstName like ((@fname+'%'))))    
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[USERS_VIEW] TO [webuser]
GO
