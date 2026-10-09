USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES](  
     @userID              BIGINT    
   , @userGroup           INT    
   , @userRank            INT
   , @appName             varchar(50)
   , @clientID            bigint 
   , @userNotifiedByEmail bit
   , @userHasSeen         bit
   , @userWillReadLater   bit
   , @userHasRead         bit
   , @pageID              bigint
)
RETURNS TABLE
AS
RETURN
(
  select top (dbo.CONST_MAX_ROWS())
    * 
  from dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_CORE (  
     @userID   
   , @userGroup
   , @userRank
   , @appName
   , @clientID
   , @userNotifiedByEmail
   , @userHasSeen
   , @userWillReadLater
   , @userHasRead
   , @pageID )
 order by rowOrder
)

GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES] TO [webuser]
GO