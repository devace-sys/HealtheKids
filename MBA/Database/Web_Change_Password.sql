USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Web_Change_Password') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Web_Change_Password
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Web_Change_Password]
    @changeType                     smallint,       -- Type of password change
    @Username                       nvarchar(256),  -- Username 
    @Token                          varchar(100),   -- Token of requesting user
    @OldPassword                    nvarchar(128),  -- Old password
    @NewPassword                    nvarchar(128),  -- New password
    @AppName                        varchar(50),    -- Application name (from web.config)
    @validateRec                    bit,            -- Validate only  
    @MsgNotAllowed                  varchar(1000),  -- Message, Not allowed to do this
    @MsgPasswordNoMatch             varchar(1000),  -- Message Password does not match
    @MsgAccountNotFound             varchar(1000),  -- Message, Account not found
    @confirmEmail                   nvarchar(256) OUTPUT,
    @recordID                       BIGINT        OUTPUT 
AS
BEGIN

  SET NOCOUNT ON;  
  
  DECLARE @UserID      AS uniqueidentifier     -- User id for account to change password for
  DECLARE @Pwd         AS nvarchar(128)        -- Existing password on file  
  DECLARE @userGroup   AS INT                  -- 
  DECLARE @userRank    AS INT  
  DECLARE @IsLockedOut AS bit

  BEGIN TRY
  
    /*-------------------------------
     * Private (logged in)
     * password change request     
     * is from a user requesting their
     * own password be changed or an
     * admin requesting a password
     * change on behalf of a user.
     *------------------------------*/
     
    IF (@changeType = dbo.CONST_CHANGE_PASSWORD_USER())
    BEGIN
     
     /*-------------------------------
      * Retrieve information about
      * the user requesting the change
      * The user requesting the change
      * has to be logged in so we
      * use the supplied token.
      *------------------------------*/

      select top 1
      
	      @UserID            = ud.uid
        , @recordID          = ud.id         
		, @IsLockedOut       = ud.accountIsLockedOut
        , @Pwd               = ud.userPassword
        , @userGroup         = ud.userGroupID
        , @userRank          = ud.roleRank
        , @confirmEmail      = ud.email 
	    
	  from dbo.USERS_DATA_CORE (@AppName,null,@token,null,null) as ud
      
      /*-------------------------------
       * If we can't find data, get out
       *------------------------------*/
      
      IF (@UserID IS NULL) RAISERROR (@MsgNotAllowed , 11, 1) 
      
      /*-------------------------------
       * If change type is for user
       * requesting their own change
       * verify the old password
       * supplied matches the one we
       * have on file.  If it does
       * not warn the user.  If it
       * does go ahead and make the
       * change 
       *------------------------------*/

      IF (@Pwd <> dbo.HASH_PASSWORD(@OldPassword)) RAISERROR (@MsgPasswordNoMatch, 11, 1) 
        
      -- If we are validating get out
        
      IF (@validateRec = 1) RETURN (0)
        
      -- Otherwise we are clear to update the password
        
     /* Note: The value that we set initalPasswordChangeCompleted is always going to be true 
	  * for the following update. The value of initalPasswordChangeCompleted is initialy set to false when 
	  * the account is created and is used for account setup tasks. */

      UPDATE dbo.Membership 
      SET 
        dbo.Membership.Password                       = dbo.HASH_PASSWORD(@NewPassword),
        dbo.Membership.PasswordSalt                   = '', 
        dbo.Membership.passwordMustBeChanged          = 0,
        dbo.Membership.LastPasswordChangedDate        = GETDATE(),
		dbo.Membership.initialPasswordChangeCompleted = 1 
      WHERE dbo.Membership.UserId = @UserId
                         
    END
    
    /*-------------------------------
     * An admin is reseting a password
     * on behalf of a user
     *------------------------------*/

    ELSE IF (@changeType = dbo.CONST_CHANGE_PASSWORD_ADMIN())
    BEGIN
      PRINT 'TODO'
    END
    
    /*-------------------------------
     * Public (not logged in and 
     * therefore anonymous)
     * password change request
     *------------------------------*/    
     
    ELSE IF (@changeType = dbo.CONST_CHANGE_PASSWORD_PUBLIC())
    BEGIN
    
      /*-------------------------------
       * Retrieve information about
       * the user requesting the change
       * The user requesting the change
       * is not logged in 
       * (it could be anyone) so we
       * use the supplied email.
       *------------------------------*/      
      
      select top 1
      
	      @UserID            = ud.uid
        , @recordID          = ud.id         
		, @IsLockedOut       = ud.accountIsLockedOut
        , @Pwd               = ud.userPassword
        , @userGroup         = ud.userGroupID
        , @userRank          = ud.roleRank
        , @confirmEmail      = ud.email 
	  
	  from dbo.USERS_DATA_CORE (@AppName,@Username,null,null,null) as ud
	  	  
	  /*-------------------------------
       * If we can't find data, get out
       *------------------------------*/
      
      IF (@UserID IS NULL) RAISERROR (@MsgNotAllowed , 11, 1) 
       
       -- If we are validating get out
        
       IF (@validateRec = 1) RETURN (0)
       
      /*-------------------------------
       * Otherwise update the record
       * with the temp password passed
       * in and force a password change
       * on next login.
       *------------------------------*/

      UPDATE Membership 
        SET 
          dbo.Membership.Password                   = dbo.HASH_PASSWORD(@NewPassword), 
          dbo.Membership.PasswordSalt               = '',          
          dbo.Membership.passwordMustBeChanged      = 1,
          dbo.Membership.IsLockedOut                = 0,
          dbo.Membership.FailedPasswordAttemptCount = 0,
          dbo.Membership.LastPasswordChangedDate    = GETDATE()  
        WHERE Membership.UserId = @UserId
    
    END

    /*-------------------------------
     * Unknown change type
     *------------------------------*/
     
    ELSE
    BEGIN
      RAISERROR ('Unknown change type', 11, 1)      
    END

    /*-------------------------------
     * All done
     *------------------------------*/

    RETURN (0)
  END TRY
  BEGIN CATCH
     -- Roll back any transactions
    IF @@TRANCOUNT > 0 ROLLBACK
    -- Error or raise error with severity 11 to 19 will be caught here
    DECLARE @ErrorMessage NVARCHAR(4000)
    DECLARE @ErrorSeverity INT
    DECLARE @ErrorState INT
    SELECT  @ErrorMessage  = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState    = ERROR_STATE()
    -- Reraise the error so it returns back to the server
    RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)
  END CATCH
END
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT EXECUTE ON  [dbo].[Web_Change_Password] TO [webuser]
GO
