USE SPEDMON
GO



/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE_CORE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE_CORE] (
    @userID                 BIGINT
  , @userGroup              INT  
  , @userRank               INT   
  , @clientID				BIGINT   
  , @clientComplianceItemID BIGINT
  , @notes                  NVARCHAR(max)
  , @isComplete				BIT


  , @dateCompleted			DATETIME

  , @dueDate                            DATE
  , @dashboardDate                      DATE

  , @editDueDateAllClients              BIT
  , @editDashboardDateAllClients              BIT

  , @taskName                           varchar(256)

  , @editDelReason          VARCHAR(7000)
  , @validateRec            BIT
  , @saveType               INT
  , @recID                  BIGINT
  , @MsgNoRec               VARCHAR(1000)
  , @MsgNoEdit              VARCHAR(1000)
  , @MsgDupRec              VARCHAR(1000)
  , @MsgDataError           VARCHAR(1000)
  , @MsgNotActive           VARCHAR(1000)
  , @spDetails              VARCHAR(8000) OUTPUT
  , @recordID               BIGINT        OUTPUT )    
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
    
IF (@userGroup              IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID                 IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank               IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec            IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType               IS NULL) RAISERROR ('Save type is required',   11, 1)   
IF (@clientID			    IS NULL) RAISERROR ('client ID is required',    11, 1) 
IF (@clientComplianceItemID IS NULL) RAISERROR ('client compliance item ID is required'  ,   11, 1) 


 declare  @clientSpecificTaskDueDate                 DATE  = null  ,
          @clientSpecificTaskDashboardDate           DATE  = null

/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END


if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

    /* initialize logic for client specific / nonspecific value entries */
    if ( @editDueDateAllClients = 0
         )  -- client-specific
    begin
      SET  @clientSpecificTaskDueDate = @dueDate ;
      SET  @dueDate = null ;
    END
    ELSE IF ( @editDueDateAllClients = 1
               )  -- non-client-specific
    BEGIN
      /* if we are saving a new non-client-specific due date, then all existing client-specific due
       dates must necessarily be blanked out */

      update dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS
      set        
          clientSpecificTaskDueDate       =  null
          --clientSpecificTaskDashboardDate =  null
          where clientComplianceItemID  = @clientComplianceItemID

      /* if we submitting a non-client-specific due date, persist it in the appropriate table */
      UPDATE  CLIENT_COMPLIANCE_ITEMS
      SET
          dueDate         = @dueDate
        , lastModified    = @today
        , lastModifiedBy  = @userID
      WHERE
         dueDate != @dueDate
         AND
         id = @clientComplianceItemID
        
    END

    if ( @editDashboardDateAllClients = 0 ) 
    begin

      SET  @clientSpecificTaskDashboardDate = @dashboardDate ;
      SET  @dashboardDate = null ;

    END
    ELSE if ( @editDashboardDateAllClients = 1 ) 
    BEGIN

      /* if we are saving a new non-client-specific dashboard date, then all existing client-specific due
       dates must necessarily be blanked out */

      update dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS
      set        
          clientSpecificTaskDashboardDate      =  null
          where clientComplianceItemID  = @clientComplianceItemID

      /* if we submitting a non-client-specific dashboard date, persist it in the appropriate table */
      UPDATE  CLIENT_COMPLIANCE_ITEMS
      SET
          dateToShowOnDashboard        = @dashboardDate
        , lastModified                 = @today
        , lastModifiedBy               = @userID
      WHERE
         dateToShowOnDashboard         != @dashboardDate
         AND
         id = @clientComplianceItemID

    END

    /* enable task name editing; per-row or per-client name editing not supported */
    declare @fetchedTaskId bigint;
    SELECT
      @fetchedTaskId = taskID
    FROM CLIENT_COMPLIANCE_ITEMS
    WHERE id = @clientComplianceItemID

    UPDATE  [CLIENT_COMPLIANCE_TASKS]
    SET
         [name]                       = @taskName
       , lastModified                 = @today
       , lastModifiedBy               = @userID
    WHERE
         @taskName  IS NOT NULL
       AND
         id = @fetchedTaskId
       AND
         [name] != @taskName

END

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())

/*============================================================
 * Create new
 *===========================================================*/   

begin
  -- duplication check
  IF (exists (select top 1 id from dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS where clientID = @clientID and clientComplianceItemID = @clientComplianceItemID)) RAISERROR (@MsgDupRec, 11, 1) 

  /*-------------------------------
   * Create Client Contact
   * record.

   *  (client contact??  bad comment I think)
   *------------------------------*/ 

  insert into dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS (  
      clientID
	, clientComplianceItemID
	, notes
	, isComplete
	, dateCompleted

   , clientSpecificTaskDueDate
   , clientSpecificTaskDashboardDate 

    , created 
    , createdBy
  ) 
  values (
      @clientID
	, @clientComplianceItemID
	, @notes
	, @isComplete
	, @dateCompleted


   ,  @clientSpecificTaskDueDate
   ,  @clientSpecificTaskDashboardDate 

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

  update dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS
  set        
	  clientID				  = @clientID
    , clientComplianceItemID  = @clientComplianceItemID
	, notes                   = @notes
	, isComplete			  = @isComplete
	, dateCompleted			  = @dateCompleted


    , clientSpecificTaskDueDate       =  @clientSpecificTaskDueDate
    , clientSpecificTaskDashboardDate =  @clientSpecificTaskDashboardDate

	, lastModified			  = @today
    , lastModifiedBy		  = @userID
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

GRANT EXECUTE ON  [dbo].[CLIENT_COMPLIANCE_CLIENT_ITEM_SAVE_CORE] TO [webuser]
GO
