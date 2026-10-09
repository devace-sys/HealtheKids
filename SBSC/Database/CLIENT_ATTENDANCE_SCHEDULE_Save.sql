USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_SCHEDULE_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_ATTENDANCE_SCHEDULE_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLIENT_ATTENDANCE_SCHEDULE_Save]     
 (@userID            BIGINT,    
  @userGroup         INT,    
  @userRank          INT,    
  @clientID          BIGINT,
  @name              VARCHAR(500),
  @description       VARCHAR(1000), 
  @fiscalYearID      INT,
  @editDelReason     VARCHAR(7000),    
  @validateRec       BIT,    
  @saveType          INT,    
  @recID             BIGINT,    
  @MsgNoRec          VARCHAR(1000),    
  @MsgNoEdit         VARCHAR(1000), 
  @MsgDupRec         VARCHAR(1000),  
  @MsgNoClient       VARCHAR(1000),
  @MsgNoName         VARCHAR(1000),
  @MsgNoFYID         VARCHAR(1000),     
  @MsgDataError      VARCHAR(1000),
  @MsgNotActive      VARCHAR(1000),  
  @spDetails         VARCHAR(8000) OUTPUT,    
  @recordID          BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * CLIENT_ATTENDANCE_SCHEDULE_Save */    
/**    
 * Creates a new client attendance calendar
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   name            What does the client call this
 * @param   description     What do we call it
 * @param   fiscalYearID    What fiscal year is it for
 * @param   editDelReason   Reason for record edit or delete    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete    
 * @param   recID           Record id of existing patient record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgNoClient     Desired error message if a clientID is not found    
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    

DECLARE @today         AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen      AS BIT            -- Is a transaction open    
DECLARE @dupCount      AS INT            -- Duplicate counter used for validation    
DECLARE @updateState   AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @canEdit       AS BIT   
DECLARE @tempRecID     AS BIGINT         -- Used for determining if a rec exists    
DECLARE @tempName      AS VARCHAR(100)
DECLARE @auditRecID    AS BIGINT         

BEGIN TRY

/*============================================================
 * Init output parameters
 *============================================================*/  
    
SET @recordID   = 0    
SET @spDetails  = ''    

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    
    
/*============================================================
 * Init worker variables
 *============================================================*/  

SET @today  = GETDATE()    

/*============================================================
 * If this save operation is an edit verify that the record
 * being edited exists and it can be edited.
 *
 * Note: We do this first for efficiency purposes
 *============================================================*/   

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())     
BEGIN  
  
  /*-------------------------------    
   * Get out if the recid is not
   * provided
   *------------------------------*/   
   
  IF (@recID IS NULL) RAISERROR ('updateRecID is required', 11, 1)    

 /*-------------------------------    
  * Look for record that we want
  * to edit.  
  *------------------------------*/         
  
  SET @recordID = null    
  SET @canEdit  = 0   
  
  SELECT 
    @recordID = ID, 
    @canEdit  = Active 
  from 
    dbo.CLIENT_ATTENDANCE_SCHEDULE
  where 
    ID = @recID

  /*-------------------------------    
   * If it does not exist or can
   * not be edited, get out!
   *------------------------------*/ 
        
  IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)        
  IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1)  
         
END -- Edit
   
/*============================================================
 * Required validation of parameters provided and lookup 
 * supporting data for new records and edited records
 *============================================================*/   
 
/*-------------------------------    
 * Verify client id exists    
 *------------------------------*/    

IF (@clientID is null)  RAISERROR (@MsgNoClient, 11, 1)

SET @tempRecID = NULL    
SELECT @tempRecID = CLIENT_ID 
FROM CLIENTS_CLIENT 
WHERE CLIENT_ID = @clientID    

IF (@tempRecID is null) RAISERROR (@MsgNoClient, 11, 1)            

/*-------------------------------    
 * Verify name     
 *-------------------------------*/   
 
if (@name is null)                RAISERROR (@MsgNoName, 11, 1) 
if (len(ltrim(rtrim(@name))) = 0) RAISERROR (@MsgNoName, 11, 1) 

/*-------------------------------    
 * Verify fiscal year     
 *-------------------------------*/   
 
IF (@fiscalYearID is null) RAISERROR (@MsgNoFYID, 11, 1)            

SET @tempRecID = NULL    
SELECT @tempRecID = id
FROM CLIENT_ATTENDANCE_YEARS_VIEW(@userID,@userGroup,@userRank,null,null)
WHERE id = @fiscalYearID

IF (@tempRecID is null) RAISERROR (@MsgNoFYID, 11, 1)            

/*-------------------------------    
 * Look for duplicate records 
 * excluding the record specified
 * by recid    
 *------------------------------*/    

SET @dupCount = 0   
    
select 
  @dupCount = COUNT(id) 
from 
  dbo.CLIENT_ATTENDANCE_SCHEDULE
where
  ((@recID IS NULL) OR (ID != @recID)) 
  and (clientID     = @clientID)
  and (name         = @name)
  and (fiscalYearID = @fiscalYearID)
  and (Active = 1) 
   
/*-------------------------------    
 * If a duplicate record was 
 * found, get out!
 *------------------------------*/    
    
if (@dupCount > 0) RAISERROR (@MsgDupRec, 11, 1) 

/*============================================================
 * Advisement validation
 *
 * The purpose of this validation is to warn the user if
 * values are valid, but may not produce the desired results
 *
 * This is performed before the user confirms a record save.
 *
 * However we do not show these warnings during the record
 * save nor do we prevent the save.
 *============================================================*/ 

/*-------------------------------    
 * Validation    
 *------------------------------*/    
        
IF (@validateRec = 1) 
BEGIN
  SET @recordID = 0
  RETURN(0)    
END        

/*============================================================
 * Create or modify schedule records
 *============================================================*/     
    
BEGIN TRANSACTION    
    
SET @TranOpen = 1    

/*-------------------------------    
 * New record
 *------------------------------*/ 

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN    
    
  SET @updateState = dbo.CONST_REC_STATE_NEW()    
        
  INSERT INTO dbo.CLIENT_ATTENDANCE_SCHEDULE
    (clientID,
     name,
     description,
     fiscalYearID,
     created,
     createdBy,
     active)    
       
  VALUES     
    
    (@clientID, 
     @name,
     @description,
     @fiscalYearID,
     @today,
     @userID,
     1)      
    
  SET @recordID = SCOPE_IDENTITY()       
            
END  
 
/*-------------------------------    
 * Edit record
 *------------------------------*/     
  
ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN               
      
  SET @updateState = dbo.CONST_REC_STATE_MOD()     
                      
  UPDATE dbo.CLIENT_ATTENDANCE_SCHEDULE
  SET
    clientID          = @clientID, 
    name              = @name,
    description       = @description,
    fiscalYearID      = @fiscalYearID,
    lastUpdated       = @today,
    lastUpdatedBy     = @userID     
  WHERE 
    ID = @recordID
                
END 

/*-------------------------------    
 * Invalid save type
 *------------------------------*/  
    
ELSE     
BEGIN    
  RAISERROR ('Unknown save type', 11, 1)    
END            

/*============================================================
 * Create audit record
 *============================================================*/  

EXEC CLIENT_ATTENDANCE_SCHEDULE_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
       
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

GRANT EXECUTE ON  [dbo].[CLIENT_ATTENDANCE_SCHEDULE_Save] TO [webuser]
GO
