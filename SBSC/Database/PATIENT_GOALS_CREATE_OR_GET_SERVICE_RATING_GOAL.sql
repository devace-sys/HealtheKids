USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_GOALS_CREATE_OR_GET_SERVICE_RATING_GOAL') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_GOALS_CREATE_OR_GET_SERVICE_RATING_GOAL
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PATIENT_GOALS_CREATE_OR_GET_SERVICE_RATING_GOAL] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT      
  , @clientID            BIGINT
  , @groupSvcClassNameID BIGINT
  , @patID               BIGINT
  , @svcName             VARCHAR(1000)  
/*  , @MsgNoRec            VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @MsgDupRec           VARCHAR(1000)
  , @MsgDataError        VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)
  */
  , @saveType            INT           OUTPUT
  , @spDetails           VARCHAR(8000) OUTPUT
  , @recordID            BIGINT        OUTPUT )    
AS    
BEGIN     
    
/***************************************************************************    
 * PATIENT_GOALS_CREATE_OR_GET_SERVICE_RATING_GOAL */    
/**    
 * Creates new or edits existing
 *    
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/

DECLARE @today              AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen           AS BIT            -- Is a transaction open

BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID  = 0    
SET @spDetails = ''    
SET @today     = GETDATE()    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    

/*============================================================
 * See if the clientID and patID combo is valid
 *============================================================*/  

if not exists (
  select top 1 
    numOf = 1 
  from dbo.CLIENTS_Client   as cc 
  join dbo.PATIENTS_Client  as pc on pc.CLIENT_ID  = cc.CLIENT_ID
  join dbo.PATIENTS_Patient as pp on pp.PATIENT_ID = pc.PATIENT_ID
  where (
        (cc.CLIENT_ID  = @clientID) 
    and (pp.PATIENT_ID = @patID)
  )
)
begin
  RAISERROR ('Invalid client or patient id', 11, 1)
end


/*============================================================
 * See if the group family is valid
 *============================================================*/  

if not exists (
  select top 1 
    numOf = 1 
  from dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as scn
  where scn.GROUP_SERVICE_CLASS_NAME_ID = @groupSvcClassNameID
)
begin
  RAISERROR ('Invalid practitioner discipline group family', 11, 1)
end

set @svcName = 'Session Ratings for ' + @svcName

/*============================================================
 * Find
 *===========================================================*/   

select top 1
  @recordID = isnull(pg.id,0)
from dbo.PATIENT_GOALS as pg
where (
      (pg.clientID            = @clientID)
  and (pg.patID               = @patID)
  and (pg.groupSvcClassNameID = @groupSvcClassNameID)
  and (pg.[name]              = @svcName)
  and (pg.active              = 1)
  and (pg.goalTypeID          = 10000)
)

/*============================================================
 * Set save type
 *============================================================*/  

if (@recordID = 0)
begin
  set @saveType = dbo.CONST_SAVE_TYPE_NEW()
end
else
begin
  set @saveType = dbo.CONST_SAVE_TYPE_EDIT()
end


/*============================================================
 * Existing record, get out
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin
  RETURN(0)    
end

BEGIN TRANSACTION
SET @TranOpen = 1

/*============================================================
 * Create new
 *===========================================================*/   

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin
  
  insert into dbo.PATIENT_GOALS (  
      clientID
    , groupSvcClassNameID
	, patID
	, [name]
    , goalMet
	, created 
    , createdBy	    
    , active    
	, goalTypeID 
  ) 
  values (
      @clientID
	, @groupSvcClassNameID
	, @patID
	, @svcName
	, 0
    , @today
    , @userID
	, 1    
	, 10000
  )
  
  set @recordID = SCOPE_IDENTITY()

end

/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

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
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PATIENT_GOALS_CREATE_OR_GET_SERVICE_RATING_GOAL] TO [webuser]
GO
