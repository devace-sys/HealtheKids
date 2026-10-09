USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Web_Login') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Web_Login
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Web_Login]
    @Username                       nvarchar(256),  -- Username
    @Password                       nvarchar(128),  -- Password
    @Token                          varchar(100),   -- Server generated token
    @UserIP                         varchar(500),
    @UserAgent                      varchar(8000),
    @AppName                        varchar(50),    -- Application name (from web.config)
    @NumPwdAttemptsAllowed          int,            -- Business rule, num of pwd attempts allowed
    @RulSessionExpiresInMins        int,            -- Business rule, in minutes
    @RulTokenExpiresInHours         int,            -- Business rule, in hours
    @RulPasswordExpires             bit,            -- Business rule
    @RulPasswordExpiresInDays       int,            -- Business rule, in days
    @MsgAccountLocked               varchar(1000),  -- Message, Account locked
    @MsgAccountNotFound             varchar(1000)   -- Message, Account not found
AS
BEGIN

/***************************************************************************
 * WEB_LOGIN */
/**
 * Logs user in.  Throws exceptions if 
 *
 * @param   Username                 Users username (usually their email)
 * @param   Password                 Users password
 * @param   Token                    Server generated security token (for session)
 * @param   AppName                  Application name (from web.config)
 * @param   NumPwdAttemptsAllowed    Business rule, num of pwd attempts allowed
 * @param   RulSessionExpiresInMins  Business rule, Innactivity expiration (in minutes)
 * @param   RulTokenExpiresInHours   Business rule, Session expires overall (in hours)
 * @param   MsgAccountLocked         Message, If account locked
 * @param   MsgAccountNotFound       Message, If account not found
 * @return                 
 ***************************************************************************/ 

  SET NOCOUNT ON;  
  
  DECLARE @UserID                AS uniqueidentifier
  DECLARE @Pwd                   AS nvarchar(128)
  DECLARE @IsLockedOut           AS bit
  DECLARE @NumFailedPwd          AS int
  DECLARE @RoleName              AS nvarchar(256)
  DECLARE @ThisLogin             AS datetime
  DECLARE @LastLogin             AS datetime
  DECLARE @SessionExpires        AS datetime
  DECLARE @TokenExpires          AS datetime
  DECLARE @PasswordAge           AS INT
  DECLARE @PasswordMustBeChanged AS BIT  
  DECLARE @RetCodePwdLocked      AS INT
  DECLARE @confirmEmail          AS nvarchar(256)

  BEGIN TRY
    
    /*-------------------------------
     * Get the current date/time and
     * compute expiration times for
     * session and token expiration.
     *------------------------------*/

    SET @ThisLogin        = GETDATE()
    SET @SessionExpires   = DATEADD(MI, @RulSessionExpiresInMins, @ThisLogin)
    SET @TokenExpires     = DATEADD(HH, @RulTokenExpiresInHours,  @ThisLogin)
    SET @RetCodePwdLocked = dbo.CONST_RET_CODE_PASSWORD_LOCK()  
    
    /*-------------------------------
     * Retrieve information about the
     * user with the given @UserName
     *------------------------------*/
   
    select top 1
	
	    @UserID                = udc.uid
      , @Pwd                   = udc.userPassword
      , @IsLockedOut           = udc.accountIsLockedOut
      , @NumFailedPwd          = udc.failedPasswordAttemptCount
      , @RoleName              = udc.roleName
      , @LastLogin             = udc.lastLoginDate
      , @confirmEmail          = udc.email
      , @PasswordAge           = udc.passwordAgeInDays
      , @PasswordMustBeChanged = udc.passwordMustBeChanged  
    
	from dbo.USERS_DATA_CORE(@AppName,@Username,null,null,null) as udc

    where (
	      (udc.userName = @Username)
	  and (udc.active = 1)
    )

    /*-------------------------------
     * Insert new web browser log
     *------------------------------*/
    
    INSERT INTO dbo.WEB_BROWSER_LOG 
      (LoggedOn,
       UserID,
       UserIP,
       UserAgent,
       Token)
     VALUES 
       (@ThisLogin,
        @UserID,
        @UserIP,
        @UserAgent,
        @Token)
           
    /*-------------------------------
     * If the user account is not 
     * found or it has been locked
     * out, let the user know and 
     * exit
     *------------------------------*/
    
    IF (@UserID IS NULL)                  RAISERROR (@MsgAccountNotFound, 11, 1)            
    IF (@IsLockedOut = 1)                 RAISERROR (@MsgAccountLocked, 11, 1)
    IF (LOWER(@RoleName) = 'deactivated') RAISERROR (@MsgAccountLocked, 11, 1)   

    /*-------------------------------
     * If the user account has been 
     * found but the password supplied
     * does not match the one we have
     * on file.
     *------------------------------*/
    
    IF (@Pwd <> dbo.HASH_PASSWORD(@Password))
    BEGIN
      
      /*-------------------------------
       * Increment the retry counter
       *------------------------------*/
      
      SET @NumFailedPwd = @NumFailedPwd + 1 
      UPDATE dbo.Membership SET dbo.Membership.FailedPasswordAttemptCount = @NumFailedPwd WHERE dbo.Membership.UserId = @UserId

      /*-------------------------------
       * If the number of retrys exceeds
       * our limit lock the account and
       * let the user know its locked
       *------------------------------*/
      
      IF (@NumFailedPwd > @NumPwdAttemptsAllowed)
      BEGIN
        UPDATE dbo.Membership 
        SET 
          dbo.Membership.IsLockedOut     = 1,
          dbo.Membership.LastLockoutDate = GETDATE()
        WHERE dbo.Membership.UserId = @UserId

        -- Note: Error is raised with a special return code and we are returning the users
        -- email as the message
        
        RAISERROR (@confirmEmail, @RetCodePwdLocked, 1)

      END

      /*-------------------------------
       * Otherwise let the user know
       * they have a bad password
       * Note: We use the same message
       * here that we do for account
       * not found for security purposes.
       *------------------------------*/
      
      RAISERROR (@MsgAccountNotFound, 11, 1)
      
    END

    /*-------------------------------
     * If we reach this point we
     * have a valid username/password
     * combination and the account
     * is not locked.
     * 
     * If we are enforcing password
     * expiration, check to see if
     * if the password has expired.
     *
     * If it has set the appropriate
     * flag.
     *------------------------------*/
     
    if (@RulPasswordExpires = 1) AND (@PasswordAge >= @RulPasswordExpiresInDays) SET @PasswordMustBeChanged = 1
            

	/*-------------------------------
     * Proceed with logging the user
     * in
     *------------------------------*/

    BEGIN TRANSACTION        
      
      /*-------------------------------
       * Update membership table
       * with new last login time
       * and also clear the failed 
       * password attempt counter.
       *------------------------------*/
      
      UPDATE dbo.Membership 
      SET    
        dbo.Membership.FailedPasswordAttemptCount = 0, 
        dbo.Membership.LastLoginDate              = @ThisLogin, 
        dbo.Membership.passwordMustBeChanged      = @PasswordMustBeChanged
	  WHERE
        dbo.Membership.UserId = @UserId
      
      /*-------------------------------
       * Update web sessions table 
       * by removing old session record
       * (if any) and creating a new
       * session record with the 
       * new security token and
       * other session data.
       *------------------------------*/
     

    /*-------------------------------
     * Log login success
     *------------------------------*/

	insert into dbo.WEB_SESSION_LOG (
	    [Action]
	  , LoggedOn
	  , UserID
	  , Token
      , SessionCreated
	  , SessionLastAccess
	  , SessionExpiresOn
      , TokenExpiresOn
    )
    select 
          [Action]    = 'Login - Previous Session Data'
        , [LoggedOn]  =  @ThisLogin
        , ws.UserID   
        , ws.Token   
        , ws.SessionCreated
        , ws.SessionLastAccess
        , ws.SessionExpires
        , ws.TokenExpires
      from dbo.WebSessions as ws 
      where (ws.UserID = @UserID)

      DELETE FROM dbo.WebSessions WHERE UserID = @UserID
      INSERT INTO dbo.WebSessions (UserID,Token,SessionCreated,SessionLastAccess,SessionExpires,TokenExpires) VALUES (@UserID,@Token,@ThisLogin,@ThisLogin,@SessionExpires,@TokenExpires)      
            
    /*-------------------------------
     * Log login success
     *------------------------------*/

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
	    'Login - Success'
	   , @ThisLogin
	   , @UserID
       , @UserIP
       , @UserAgent
       , @Token
       , @ThisLogin
	   , @ThisLogin
	   , @SessionExpires
	   , @TokenExpires
	)

      /*-------------------------------
       * All done!
       *------------------------------*/
       
      COMMIT TRANSACTION
      RETURN (0)
   END TRY
   BEGIN CATCH
    -- Roll back any transactions
    IF @@TRANCOUNT > 0 ROLLBACK
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
GRANT EXECUTE ON  [dbo].[Web_Login] TO [webuser]
GO
