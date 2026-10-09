USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_VIEW_CONTENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_VIEW_CONTENT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

    
CREATE FUNCTION [dbo].[APP_MAN_PAGES_VIEW_CONTENT](  
     @userID         BIGINT    
   , @userGroup      INT    
   , @userRank       INT
   , @appName        varchar(50)
   , @userHasRead    bit
   , @refDate        datetime

   , @welcome_new_user  bit
   , @includeContent    bit

   , @recID          bigint
)

RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * APP_MAN_PAGES_VIEW_CONTENT */
/**
 * Displays user data
 *
 * @param  clientID        ID of client or null for all clients
 * @param  roleID          user's username or null
 * @param  appName         user's email or null 
 * @return                 Table of user data
 ***************************************************************************/ 
 

select top(dbo.CONST_MAX_ROWS()) 
  * 
from dbo.APP_MAN_PAGES_VIEW_CONTENT_CORE (  
   @userID           
 , @userGroup
 , @userRank 
 , @appName  
 , null
 , null
 , null
 , @userHasRead 
 , @refDate

 , @welcome_new_user
 , @includeContent

 , @recID )

order by title

)  

GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[APP_MAN_PAGES_VIEW_CONTENT] TO [webuser]
GO