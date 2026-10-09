USE [users]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.WorkInProgressSavePoint_Delete') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.WorkInProgressSavePoint_Delete
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[WorkInProgressSavePoint_Delete] (
    @userID          BIGINT
  , @userGroup       INT
  , @userRank        INT
  , @appName         varchar(50)
  , @requestResource varchar(256)
  , @savePointName   varchar(256)
  , @editDelReason   VARCHAR(7000)
  , @validateRec     bit    
  , @recID           bigint
  , @MsgNoRec        VARCHAR(1000)
  , @MsgNoEdit       VARCHAR(1000) 
  , @spDetails       VARCHAR(8000) OUTPUT    
  , @recordID        BIGINT        OUTPUT
)  
AS    
BEGIN    
   
/***************************************************************************    
 * WorkInProgressSavePoint_Delete */    
/**    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
/*============================================================
 * Variables and init
 *============================================================*/  

declare @tranOpen    as bit = 0
declare @today       as datetime = getdate()

set @recordID  = 0
set @spDetails = ''
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
if (@recID           IS NULL) RAISERROR ('rec id is required',           11, 1)  


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
  and (t1.id              = @recID)
  and (t1.active          = 1)
)

/*============================================================
 * If none exists then there is nothing to do
 *============================================================*/  

if (@recordID = 0) return(0)

/*============================================================
 * If validating exit
 *============================================================*/  

if (@validateRec = 1) return (0)

/*============================================================
 * Otherwise we physically delete the row
 *============================================================*/  

begin transaction
set @tranOpen = 1

update dbo.WorkInProgressSavePoints 
set 
  active   = 0
, loggedOn = @today
where 
  (id = @recordID)

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

GRANT EXECUTE ON  [dbo].[WorkInProgressSavePoint_Delete] TO [webuser]
GO