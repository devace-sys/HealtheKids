USE [users]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.UserPreferences_SaveOrReplace') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.UserPreferences_SaveOrReplace
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[UserPreferences_SaveOrReplace]
 (@userID          BIGINT,    
  @userGroup       INT,    
  @userRank        INT, 
  @appDomain       varchar(1000),
  @appName         varchar(50),    /* Application name (from web.config)*/
  @usrid           BIGINT,
  @selector        varchar(8000),
  @selectorType    varchar(50),
  @noun            varchar(1000),
  @verb            varchar(1000),
  @name            varchar(1000),
  @value           varchar(MAX),
  @spDetails       VARCHAR(8000) OUTPUT,
  @saveType        INT           OUTPUT,
  @recordID        BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * UserPreferences_SaveOrReplace */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   userID          The userID of who is requesting the new user account  
 * @param   userGroup       That users group    
 * @param   userRank        That user rank
 * @param   appDomain       Application domain (can be same as appName)
 * @param   appName         Application name (from web.config)
 * @param   usrid           Preference is for this user id
 * @param   selector        Scope of application of this preference.  Selectors 
 *                          could be CSS selectors, or names of end points.
 * @param   selectorType    Type of selector used.  Must set this properly.  CSS, END_POINT
 * @param   noun            Object name
 * @param   verb            Object method
 * @param   name            Method argument name
 * @param   value           Method argument value
 * @returns spDetails       Validation or error details    
 * @returns saveType        1 = New record created, 2 = Existing record edited
 * @returns recordID        New record id or record id of user record that    
 *                          was modified  
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @today            AS DATETIME         -- Current date/time stamp    
DECLARE @tranOpen         AS BIT              -- Is a transaction open    
DECLARE @usriduid         AS uniqueidentifier -- UID version of usrid
DECLARE @tempRecID        AS BIGINT
DECLARE @tempMsg          AS VARCHAR(1000)

BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters   
 *------------------------------*/    

SET @spDetails  = ''    
SET @saveType   = 0
set @recordID   = 0

/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today = GETDATE()    

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
IF (@appDomain    IS NULL) RAISERROR ('appDomain is required',     11, 1)  
IF (@appName      IS NULL) RAISERROR ('appName is required',       11, 1)  
IF (@usrid        IS NULL) RAISERROR ('usrid is required',         11, 1)  
IF (@selector     IS NULL) RAISERROR ('selector is required',      11, 1)  
IF (@selectorType IS NULL) RAISERROR ('selector type is required', 11, 1)  
IF (@noun         IS NULL) RAISERROR ('noun is required',        11, 1)  
IF (@verb         IS NULL) RAISERROR ('verb is required',        11, 1)  
IF (@name         IS NULL) RAISERROR ('name is required',        11, 1)  
IF (@value        IS NULL) RAISERROR ('value is required',       11, 1)  

/*-------------------------------    
 * Lookup uid    
 *------------------------------*/  

set @tempRecID = null

select top 1
  @usriduid  = UserId,
  @tempRecID = userrid
from dbo.users 
where [userrid] = @usrid

/*-------------------------------    
 * If user is not found
 * get out
 *------------------------------*/ 

if (@tempRecID is null)
begin
 SET @tempMsg = dbo.CONST_MSG_USER_NOT_FOUND() 
 RAISERROR (@tempMsg, 11, 1)  
end 
 
/*-------------------------------    
 * See if this record already
 * exists
 *------------------------------*/ 

set @tempRecID = null

select top 1 @tempRecID = id
from dbo.UsersPreferences
where    
      (appDomain    = @appDomain)
  and (appName      = @appName)
  and (UserId       = @usriduid) 
  and (usrid        = @usrid) 
  and (selector     = @selector)
  and (selectorType = @selectorType)
  and (noun     = @noun)
  and (verb     = @verb)
  and (name     = @name)
      
/*-------------------------------    
 * Determine if we save a new
 * record or replace an existing
 * record
 *------------------------------*/ 

if (@tempRecID is null)
begin
  set @saveType = dbo.CONST_SAVE_TYPE_NEW()
  set @recordID = null
end
else 
begin
  set @saveType = dbo.CONST_SAVE_TYPE_EDIT()
  set @recordID = @tempRecID
end

          
/*-------------------------------    
 * Save a new record or replace
 * an existing record
 *------------------------------*/    
   
BEGIN TRANSACTION    

SET @TranOpen = 1    
      
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN    

  /*-------------------------------    
   * Create new user preference
   *------------------------------*/  
     
  INSERT INTO dbo.UsersPreferences
  (
    appDomain,
    appName,
    UserId,
    usrid,  
    selector,
    selectorType,
    noun,
    verb,
    name,
    value,
    created,
    createdBy,
    lastModified,
    lastModifiedBy 
  )  
  VALUES
  ( 
    @appDomain,
    @appName,
    @usriduid,
    @usrid,
    @selector,
    @selectorType,
    @noun,
    @verb,
    @name,
    @value,
    @today,
    @userID,
    @today,
    @userID
  )  
    
  set @recordID = SCOPE_IDENTITY()    

END
ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT()) 
BEGIN
  
  /*-------------------------------    
   * Replace existing value
   *------------------------------*/  

  UPDATE dbo.UsersPreferences
  SET 
    value          = @value,
    lastModified   = @today,
    lastModifiedBy = @userID 
  WHERE id = @recordID

END
ELSE
BEGIN
  RAISERROR ('Unknown save type', 11, 1)  
END

COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    

END TRY    
BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
     
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
     
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
     
   -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[UserPreferences_SaveOrReplace] TO [webuser]
GO