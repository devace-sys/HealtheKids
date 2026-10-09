USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_NOTIFICATIONS_ALL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_NOTIFICATIONS_ALL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_NOTIFICATIONS_ALL](  
    @userID              BIGINT    
  , @userGroup           INT    
  , @userRank            INT
  , @appName             varchar(50)
)

RETURNS TABLE 
AS
RETURN 
(
  select 
      cc.*
    , ur.*
  from
  (
    /* All active LEA clients where sendUsersEmailNotifications is set to true */
    select
        CLIENT_ID   as clientID
      , CLIENT_NAME as clientName 
    from SPEDMON.dbo.CLIENTS_Client as t1
    where ( 
         (t1.LEA                         = 1)  
     and (t1.sendUsersEmailNotifications = 1)
    )

    union all
    
	/* The pcal Pseudo client */

    select 
      clientID    = 0
    , clientName = 'Practi-Cal'

  ) as cc

  cross apply (
    select 
      t2.*
    from dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_NOTIFICATIONS (
      @userID
    , @userGroup
    , @userRank
    , @appName 
    , cc.clientID ) as t2
  ) as ur

)
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_NOTIFICATIONS_ALL] TO [webuser]
GO