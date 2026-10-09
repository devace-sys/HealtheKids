USE [users]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.WorkInProgressSavePoint_SaveOrReplace') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.WorkInProgressSavePoint_SaveOrReplace
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[WorkInProgressSavePoint_SaveOrReplace] (
    @userID          BIGINT
  , @userGroup       INT  
  , @userRank        INT 
  , @appName         varchar(50)
  , @requestResource varchar(256)
  , @savePointName   varchar(256)
  , @savedDataJSON   varchar(max)
  , @spDetails       VARCHAR(8000) OUTPUT
  , @saveType        INT           OUTPUT
  , @recordID        BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * WorkInProgressSavePoint_SaveOrReplace */    
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
   
/*============================================================
 * Variables and init
 *============================================================*/  

declare @today       as datetime
declare @tranOpen    as bit = 0

set @today     = getdate()
set @recordID  = 0
set @spDetails = ''
set @saveType  = 0
set @tranOpen  = 0

BEGIN TRY    
   
/*============================================================
 * Check required parameters
 *============================================================*/  

IF (@userID          IS NULL) RAISERROR ('userID is required',           11, 1)      
IF (@userGroup       IS NULL) RAISERROR ('userGroup is required',        11, 1)    
IF (@userRank        IS NULL) RAISERROR ('userRank is required',         11, 1) 
IF (@appName         IS NULL) RAISERROR ('appName is required',          11, 1)  
if (@requestResource IS NULL) RAISERROR ('request resource is required', 11, 1)  
if (@savePointName   IS NULL) RAISERROR ('save point name is required',  11, 1)  
if (@savedDataJSON   IS NULL) RAISERROR ('saved data json is required',  11, 1)  


/*============================================================
 * Assume this is a new record to start
 *============================================================*/  

set @saveType = dbo.CONST_SAVE_TYPE_NEW()

/*============================================================
 * See if a record exists 
 *
 * If a record does exist the save type will be changed to
 * edit
 *============================================================*/  

select top 1
     @recordID = isnull(t1.id,0)
from dbo.WorkInProgressSavePoints as t1

/* Optimized to use index on tbl*/

where (
      (t1.appName         = @appName)
  and (t1.userID          = @userId)
  and (t1.requestResource = @requestResource)
  and (t1.savePointName   = @savePointName)
)

if (@recordID != 0)
begin
  set @saveType = dbo.CONST_SAVE_TYPE_EDIT()
end

begin transaction
set @tranOpen = 1

/*============================================================
 * Record does not exist, create a new one
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  insert into dbo.WorkInProgressSavePoints (
      appName
    , userID 
    , requestResource
    , savePointName
	, savedDataJSON 
    , loggedOn
	, active
  )
  values ( 
      @appName
    , @userID 
    , @requestResource
    , @savePointName
	, @savedDataJSON
	, @today
	, 1
  )

  set @recordID = SCOPE_IDENTITY()

end

/*============================================================
 * Record does exist, edit the response
 *============================================================*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  update dbo.WorkInProgressSavePoints 
  set 
      savedDataJSON = @savedDataJSON
    , loggedOn      = @today
    , active         = 1
  /* Optimized to use clustered index on tbl*/

  where (id= @recordID)
  

end
else
begin
    RAISERROR ('save type not valid', 11, 1)   
end

commit transaction
set @tranOpen = 0

/*============================================================
 * All done
 *============================================================*/  

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

GRANT EXECUTE ON  [dbo].[WorkInProgressSavePoint_SaveOrReplace] TO [webuser]
GO