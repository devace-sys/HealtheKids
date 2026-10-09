USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_CALENDAR_DELETE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_ATTENDANCE_CALENDAR_DELETE


GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[CLIENT_ATTENDANCE_CALENDAR_DELETE]    
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,
  @clientID      INT,  
  @recID         INT,    
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000),    
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN    
   
/***************************************************************************    
 * CLIENT_ATTENDANCE_CALENDAR_DELETE */    
/**    
 * Deletes (hides) an existing client attendence calender record    
 * and manages any associated records.    
 *    
 * @param   userID          The userid of who saved the record    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT deleting the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   recID           Record id of existng Patient to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message for edit/delete service record    
 *                          operations when record is not found    
 * @param   MsgNoEdit       Desired error message for edit/delete service record    
 *                          operations if the service record cannot be edited or    
 *                          deleted    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @TranOpen      AS BIT    
DECLARE @today         AS DATETIME          -- Current date/time stamp    
DECLARE @auditRecID    AS BIGINT            -- Audit record id    
DECLARE @saveType      AS INT    
DECLARE @updateState   AS INT    
DECLARE @rowCnt        AS INT    
DECLARE @maxRows       AS INT    
DECLARE @childRecID    AS INT   
DECLARE @childRecIDOut AS INT
    
BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @saveType   = dbo.CONST_SAVE_TYPE_DELETE()    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@recID       IS NULL) RAISERROR ('updateRecID is required', 11, 1)    
   
/*-------------------------------    
 * If we are just validating    
 * get out now    
 *------------------------------*/    
     
IF (@validateRec = 1) RETURN(0)    
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  /*-------------------------------    
   * "Delete" existing entity    
   * record    
   *------------------------------*/    
     
  SET @updateState = dbo.CONST_SVC_REC_STATE_DEL()    
  
  UPDATE CLIENT_ATTENDANCE_CALENDAR
  SET
  
    active         = 0,
    LastUpdated    = @today,
    LastUpdatedBy  = @userID

  WHERE (id = @recID)
    
 /*-------------------------------    
  * Deactivate all child records
  *------------------------------*/  
  
  declare @childRecs table (rownum int IDENTITY (1, 1) Primary key NOT NULL , id int)

  insert into @childRecs
    select id from dbo.CLIENT_ATTENDANCE_CALENDAR_DATES 
      where calendarID = @recID
    
  select @rowCnt = 1
  select @maxRows = count(*) from @childRecs

  while @rowCnt <= @maxRows
  begin
    select @childRecID = id from @childRecs where rownum = @rowCnt
    exec CLIENT_ATTENDANCE_CALENDAR_DATES_DELETE @userID, @userGroup,@userRank, 'Parent record has been deactivated', @validateRec, @clientID, @childRecID, @MsgNoRec, @MsgNoEdit, @spDetails OUTPUT, @childRecIDOut OUTPUT
    select @rowCnt = @rowCnt + 1
  end

 /*-------------------------------    
  * Create audit record
  *------------------------------*/    
   
 EXEC CLIENT_ATTENDANCE_CALENDAR_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
         
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
     
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
   
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLIENT_ATTENDANCE_CALENDAR_DELETE] TO [webuser]
GO
