USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Web_App_Transfer') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Web_App_Transfer
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Web_App_Transfer]
      @Username                 nvarchar(256)
	, @Token                    varchar(100)
    , @AppName                  varchar(50)
    , @UserIP                   varchar(500)
    , @UserAgent                varchar(8000)
    , @MsgSubscriptionRequired  varchar(1000)  -- Message, Subscription required
	, @MsgSessionExpire         varchar(1000)
AS
BEGIN

/***************************************************************************
 * Web_App_Transfer */
/**
 * Validate user can transfer
 * Note: This takes the place of Web_Login in the middleware pipeline
 *
 * @return                 
 ***************************************************************************/ 
  
SET NOCOUNT ON;  

DECLARE @UserID            AS uniqueidentifier
DECLARE @RetCodeSubReq     AS int 
DECLARE @RetCodeSesExp     AS int


BEGIN TRY

set @RetCodeSubReq = dbo.CONST_RET_CODE_SUBSCRIPTION_REQUIRED()
set @RetCodeSesExp = dbo.CONST_RET_CODE_SESSION_EXPIRE()


 /*-------------------------------
  * Retrieve information about the
  * user with the given @UserName
  * and @AppName combo
  *------------------------------*/
set @userID  = null
   
select top 1  
	@UserID = udc.uid      
from dbo.USERS_DATA_CORE (@AppName, @Username, null, null, null) as udc
where (udc.active = 1)

/*-------------------------------
  * If there is no active user info
  * for the given username, appName
  * combo get out
  *------------------------------*/ 

IF (@UserID IS NULL) 
begin
     -- TODO: Add lookup for app data
    
	/*-------------------------------
     * Log that user tried.  We can
	 * possibly use this for marketing.
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
	    'Application Transfer Request - User Not Subscribed'
	   , getdate()
	   , @UserID
       , @UserIP
       , @UserAgent
       , @Token
       , null
	   , null
	   , null
	   , null
	 )
      
     /*-------------------------------
      * Throw appropriate exception
	  * to get out
      *------------------------------*/

     RAISERROR (@MsgSubscriptionRequired, @RetCodeSubReq , 1)
 
  end
  else
  begin

    set @userID = null

    /*-------------------------------
     * Retrieve information about the
     * user with the given @UserName
     * @AppName, and @token combo
     *------------------------------*/
   
   select top 1
	  @UserID = udc.uid      
   from dbo.USERS_DATA_CORE (@AppName, @Username, @token, null, null) as udc
   where (udc.active = 1)

   /*-------------------------------
    * Subscription good, token not
	* found 
    *------------------------------*/

   if (@userID is null)
   begin  
      
     
   /*-------------------------------
     * Log it
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
	    'Application Transfer Request - Token Not Found'
	   , getdate()
	   , @UserID
       , @UserIP
       , @UserAgent
       , @Token
       , null
	   , null
	   , null
	   , null
	 )

	/*-------------------------------
     * Get out
     *------------------------------*/

	 RAISERROR (@MsgSessionExpire, @RetCodeSesExp , 1)

   end

    /*-------------------------------
     * Log success
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
	    'Application Transfer Request - User Is Subscribed'
	   , getdate()
	   , @UserID
       , @UserIP
       , @UserAgent
       , @Token
       , null
	   , null
	   , null
	   , null
	)

end
  
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

GRANT EXECUTE ON  [dbo].[Web_App_Transfer] TO [webuser]
GO
