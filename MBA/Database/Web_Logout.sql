USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Web_Logout') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Web_Logout
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Web_Logout]
    @Token varchar(100)   -- Server generated token
AS
BEGIN

/***************************************************************************
 * WEB_LOGOUT */
/**
 * Logs user out that has given security token.  Logging a user out
 * only requires that we remove their session record.
 *
 * @param  token           Security token
 * @return                 
 ***************************************************************************/ 
 
  SET NOCOUNT ON;  

  
  insert into dbo.WEB_SESSION_LOG (
	      [Action]
	    , LoggedOn
	    , Token
      )
  	  values (
	      'Logout'
	     , getdate()
         , @Token
	  )

  DELETE WebSessions WHERE Token = @Token
  RETURN (0)
END
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT EXECUTE ON  [dbo].[Web_Logout] TO [webuser]
GO
