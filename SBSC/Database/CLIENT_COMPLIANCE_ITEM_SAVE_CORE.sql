USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_COMPLIANCE_ITEM_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_COMPLIANCE_ITEM_SAVE_CORE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLIENT_COMPLIANCE_ITEM_SAVE_CORE] (
    @userID                BIGINT
  , @userGroup             INT  
  , @userRank              INT      
  , @taskID				   BIGINT
  , @dueDate			   DATE
  , @dateToShowOnDashboard DATE
  , @editDelReason         VARCHAR(7000)
  , @validateRec           BIT
  , @saveType              INT
  , @recID                 BIGINT
  , @MsgNoRec              VARCHAR(1000)
  , @MsgNoEdit             VARCHAR(1000)
  , @MsgDupRec             VARCHAR(1000)
  , @MsgDataError          VARCHAR(1000)
  , @MsgNotActive          VARCHAR(1000)
  , @spDetails             VARCHAR(8000) OUTPUT
  , @recordID              BIGINT        OUTPUT )    
AS    
BEGIN     

SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/

DECLARE @today              AS DATETIME       -- Current date/time stamp    

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
    
IF (@userGroup             IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID                IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank              IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec           IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType              IS NULL) RAISERROR ('Save type is required',   11, 1)   
IF (@taskID				   IS NULL) RAISERROR ('taskID is required'   ,   11, 1) 
IF (@dueDate			   IS NULL) RAISERROR ('dueDate is required'  ,   11, 1) 
IF (@dateToShowOnDashboard IS NULL) RAISERROR ('dateToShowOnDashboard is required',   11, 1) 

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END


-- NOTE: uncomment if we wish to enable dup checking by fiscal year

/*
declare @fyID int;
SELECT
  @fyID = cfy.[ID]
FROM  [dbo].[COMPANY_FISCAL_YEARS] cfy
WHERE  cfy.FY_START <= cast( @dueDate as date)
  AND  cfy.FY_END   >= cast( @dueDate as date)
*/    

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())

/*============================================================
 * Create new
 *===========================================================*/   

begin
  -- duplication check
  IF (exists
   (
     select top 1 cc_i.id
     from dbo.CLIENT_COMPLIANCE_ITEMS cc_i
     
     
   -- NOTE: uncomment if we wish to enable dup checking by fiscal year

   /*
     JOIN  [dbo].[COMPANY_FISCAL_YEARS] cfy
        ON  cfy.FY_START <= cast( cc_i.dueDate as date)
       AND  cfy.FY_END   >= cast( cc_i.dueDate as date)
   */

     where cc_i.taskID = @taskID

      -- AND cfy.ID      = @fyID

       AND CAST( cc_i.dueDate as date )  =  @dueDate

       AND cc_i.[active] = 1   -- we need to be able to reinsert after deleting
     
     )

  ) RAISERROR (@MsgDupRec,   11, 1) 
    -- was refusing to save the same task again for the following year; fixed

  /*-------------------------------
   * Create Client Contact
   * record.
   *------------------------------*/ 

  insert into dbo.CLIENT_COMPLIANCE_ITEMS (  
      taskID
	, dueDate
	, dateToShowOnDashboard
    , created 
    , createdBy
  ) 
  values (
      @taskID
	, @dueDate
	, @dateToShowOnDashboard
    , @today
    , @userID
  )
  
  set @recordID = SCOPE_IDENTITY()

end

/*============================================================
 * Edit existing
 *===========================================================*/   

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  update dbo.CLIENT_COMPLIANCE_ITEMS
  set        
	  taskID				 = @taskID
    , dueDate				 = @dueDate
    , dateToShowOnDashboard  = @dateToShowOnDashboard
    , lastModified			 = @today
    , lastModifiedBy		 = @userID
  where ([id] = @recID)
  
  set @recordID = @recID

end
   
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

GRANT EXECUTE ON  [dbo].[CLIENT_COMPLIANCE_ITEM_SAVE_CORE] TO [webuser]
GO
