USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Web_Validate') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Web_Validate
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Web_Validate]
    @Token                   varchar(100),  -- Server generated token
    @AppName                 varchar(50),   -- Application name (from web.config)
    @UserIP                  varchar(500),  -- User IP address
    @UserAgent               varchar(8000), -- User agent string
    @RulSessionExpiresInMins int,           -- Business rule, in minutes
    @MsgAccountLocked        varchar(1000), -- Message Account locked
    @MsgSessionExpire        varchar(1000)  -- Message, Session expiration
AS
BEGIN

/***************************************************************************
 * WEB_VALIDATE */
/**
 * Validate session.
 *
 * @param   Token                    Security token
 * @param   AppName                  Application name (from web.config)
 * @param   RulSessionExpiresInMins  Business rule, Innactivity expiration 
 *                                   (in minutes)
 * @param   MsgAccountLocked         Message, If account locked
 * @param   MsgSessionExpire         Message, If session has expired
 *                                   due to inactivity
 * @return                 
 ***************************************************************************/ 
  
SET NOCOUNT ON;  

DECLARE @UserID            AS uniqueidentifier
DECLARE @IsLockedOut       AS bit
DECLARE @RoleName          AS nvarchar(256)
DECLARE @ThisSession       AS datetime
DECLARE @SessionCreated    AS datetime
DECLARE @SessionLastAccess as datetime
DECLARE @SessionExpires    AS datetime
DECLARE @TokenExpires      AS datetime
DECLARE @SessionMin        AS int
DECLARE @TokenHour         AS int
DECLARE @RetCodeSesExp     AS int
DECLARE @LogID             AS bigint

BEGIN TRY

 /*-------------------------------
  * Get the current date/time and
  * return code to use to indicate
  * session expiration
  *------------------------------*/  
  
  SET @ThisSession   = GETDATE()
  SET @RetCodeSesExp = dbo.CONST_RET_CODE_SESSION_EXPIRE() 
  
 /*-------------------------------
  * Retrieve session data for
  * given token (if any)
  *------------------------------*/  
 
  select top 1
  
      @UserID            = udc.uid
    , @SessionCreated    = udc.sessionCreated
    , @SessionLastAccess = udc.sessionLastAccess
	, @SessionExpires    = udc.sessionExpires 
    , @TokenExpires      = udc.sessionTokenExpires
    , @IsLockedOut       = udc.accountIsLockedOut
    , @RoleName          = udc.roleName         
  
  from dbo.USERS_DATA_CORE (@AppName,null,@Token,null,null) as udc
  
 /*-------------------------------
  * If there is no session record
  * let the user know and exit
  *------------------------------*/ 

  IF (@UserID IS NULL) 
  begin

    insert into dbo.WEB_SESSION_LOG (
	    [Action]
	  , LoggedOn
	  , UserID
	  , UserIP 
	  , UserAgent
	  , Token
      , SessionCreated
	  , SessionLastAccess
	  , SessionExpiresOn
      , TokenExpiresOn
      )
	  values (
	      'Session Validate - No Session Record Found'
	     , @ThisSession 
	     , @UserID
         , @UserIP
         , @UserAgent
         , @Token
         , @SessionCreated
	     , @SessionLastAccess
	     , @SessionExpires	    
	     , @TokenExpires 
	  )

      RAISERROR (@MsgSessionExpire, @RetCodeSesExp , 1)
  end


 /*-------------------------------
  * If the account has been locked
  * or otherwise changed to a state
  * where access is now denied
  * let the user know and exit
  *------------------------------*/ 

  IF (@IsLockedOut = 1)                 RAISERROR (@MsgAccountLocked, 11, 1) /* Was a 13 */
  IF (LOWER(@RoleName) = 'deactivated') RAISERROR (@MsgAccountLocked, 11, 1)   
 
 /*-------------------------------
  * If the session has expired
  * due to the session reaching
  * its maximum time allowed before
  * the user has to relogin
  * log the user out and let the
  * user know.
  *------------------------------*/ 
  
  SET @TokenHour = DATEDIFF(HH,@ThisSession,@TokenExpires)
  IF (@TokenHour <=0)
  BEGIN

    insert into dbo.WEB_SESSION_LOG (
	      [Action]
	    , LoggedOn
	    , UserID
	    , UserIP 
	    , UserAgent
	    , Token
        , SessionCreated
	    , SessionLastAccess
	    , SessionExpiresOn
        , TokenExpiresOn
	    , DateDiffCalcResult
      )
  	  values (
	      'Session Validate - Token Has Expired'
	     , @ThisSession 
	     , @UserID
         , @UserIP
         , @UserAgent
         , @Token
         , @SessionCreated
	     , @SessionLastAccess
	     , @SessionExpires	    
	     , @TokenExpires 
	     , @TokenHour
	  )

      EXEC Web_Logout @Token
      RAISERROR (@MsgSessionExpire, @RetCodeSesExp, 1)   
  END
  
 /*-------------------------------
  * If the session has expired
  * due to the amount of inactivity
  * reaching the maximum time allowed
  * log the user out and let the
  * user know.
  *------------------------------*/ 
   
  SET @SessionMin = DATEDIFF(MI,@ThisSession,@SessionExpires)
  IF (@SessionMin <=0)
  BEGIN
    insert into dbo.WEB_SESSION_LOG (
	      [Action]
	    , LoggedOn
	    , UserID
	    , UserIP 
	    , UserAgent
	    , Token
        , SessionCreated
	    , SessionLastAccess
	    , SessionExpiresOn
        , TokenExpiresOn
	    , DateDiffCalcResult
      )
  	  values (
	      'Session Validate - Session Has Expired'
	     , @ThisSession 
	     , @UserID
         , @UserIP
         , @UserAgent
         , @Token
         , @SessionCreated
	     , @SessionLastAccess
	     , @SessionExpires	    
	     , @TokenExpires 
	     , @SessionMin
	  )

    EXEC Web_Logout @Token
    RAISERROR (@MsgSessionExpire, @RetCodeSesExp , 1)   
  END


   
/*-------------------------------
 * Refresh the session
 * data
 *------------------------------*/ 
  
SET @SessionExpires = DATEADD(MI,@RulSessionExpiresInMins,@ThisSession)

UPDATE dbo.WebSessions 
SET SessionLastAccess = @ThisSession, 
  SessionExpires    = @SessionExpires 
WHERE (Token = @Token) 

 insert into dbo.WEB_SESSION_LOG (
	      [Action]
	    , LoggedOn
	    , UserID
	    , UserIP 
	    , UserAgent
	    , Token
        , SessionCreated
	    , SessionLastAccess
	    , SessionExpiresOn
        , TokenExpiresOn	   
		, DateDiffCalcResult
      )
  	  values (
	      'Session Validate - OK'
	     , @ThisSession 
	     , @UserID
         , @UserIP
         , @UserAgent
         , @Token
         , @SessionCreated
	     , @ThisSession
	     , @SessionExpires	    
	     , @TokenExpires 
	     , @RulSessionExpiresInMins
	  )  
/*-------------------------------
 * All done!
 *------------------------------*/
  
RETURN (0)
END TRY
BEGIN CATCH
  -- Error or raise error with severity 11 to 19 will be caught here
  DECLARE @ErrorMessage NVARCHAR(4000)
  DECLARE @ErrorSeverity INT
  DECLARE @ErrorState INT
  SELECT  @ErrorMessage = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState = ERROR_STATE()
  -- Reraise the error so it returns back to the server
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
END CATCH
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Web_Validate] TO [webuser]
GO
