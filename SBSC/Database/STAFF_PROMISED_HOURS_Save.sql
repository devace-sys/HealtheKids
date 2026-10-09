USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STAFF_PROMISED_HOURS_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.STAFF_PROMISED_HOURS_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[STAFF_PROMISED_HOURS_Save]    
 (@staffID         int,
  @weekStart       datetime,
  @day             datetime,
  @shift1Start     time,
  @shift1End       time,
  @shift2Start     time,
  @shift2End       time,
  @shift3Start     time,
  @shift3End       time,  
  @note            NVARCHAR(MAX),
  @totalHrs        VARCHAR(5),
  @editDelReason   VARCHAR(7000),    
  @validateRec     BIT,    
  @saveType        INT,    
  @recID           INT,    
  @MsgNotActive    VARCHAR(1000),
  @MsgNoRec        VARCHAR(1000),    
  @MsgNoEdit       VARCHAR(1000),
  @MsgDupRec       VARCHAR(1000),    
  @MsgDataError    VARCHAR(1000),    
  @recordID        BIGINT        OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * STAFF_PROMISED_HOURS_SAVE */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   staffID         
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
 * @param   recID           Record id of existing client record to edit or    
 *                          delete.    
 * @param   MsgNoRec        Desired error message if a recID is not found    
 * @param   MsgNoEdit       Desired error message if a record cannot be edited    
 * @param   MsgNoFullEdit   Desired error message if a record can only be partially edited
 * @param   MsgDupRec       Desired error message for duplicate detection    
 * @param   MsgNoClient     Desired error message if a clientID is not found 
 * @param   MsgNoGroup      Desired error message if a groupID is not found    
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of STAFF_PROMISED_HOURS record that    
 *                          was changed or deleted    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @today              AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen           AS BIT            -- Is a transaction open    
DECLARE @dupCount           AS INT            -- Duplicate counter used for validation    
DECLARE @updateState        AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @canEdit            AS BIT            -- If the record is inactive it cannot be edited
DECLARE @isActive           AS BIT            -- Is this record active?
DECLARE @noFullEdit         AS BIT
DECLARE @tempRecID          AS INT            -- Used for determining if a rec exists  
DECLARE @auditRecID         AS BIGINT         -- Audit record id    
DECLARE @totalHours         as FLOAT   
DECLARE @TOTALMIN           AS FLOAT       
DECLARE @promised           AS FLOAT

BEGIN TRY    
   
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
   
SET @recordID   = 0    
SET @totalHours = 0   
SET @TOTALMIN   = 0
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   

IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)    
IF (@staffID     IS NULL) RAISERROR ('staffID is required',    11, 1) 

IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))    
  RAISERROR ('updateRecID is required', 11, 1)
  
IF ((@weekStart IS NULL))    
  RAISERROR ('Date of start of the week is required! ', 11, 1)   
  
IF (DATEPART(weekday,@weekStart) != 1)
  RAISERROR ('Invalid date for week start! ', 11, 1)   
  
declare @message as varchar(max)
set @message = 'Invalid Data! Make sure the shift timings are not overlaping!'  
                
if (@shift1Start is null) and (@shift2Start is not null) and (@shift3Start is not null)
       select @shift1Start = @shift2Start, @shift2Start = @shift3Start, @shift1End = @shift2End, 
              @shift2End = @shift3End,@shift3Start = null,@shift3End = null
if (@shift1Start is null) and (@shift2Start is null) and (@shift3Start is not null)
       select @shift1Start = @shift3Start,  @shift1End = @shift3End, @shift3Start = null,@shift3End = null
if (@shift1Start is null) and (@shift2Start is not null) and (@shift3Start is null)
       select @shift1Start = @shift2Start,  @shift1End = @shift2End, @shift2Start = null,@shift2End = null  
if (@shift1Start is not null) and (@shift2Start is null) and (@shift3Start is not null)
       select @shift2Start = @shift3Start,  @shift2End = @shift3End, @shift3Start = null,@shift3End = null  

declare @tempshiftstart time(0),@tempshiftend time(0)  
if (@shift1Start > @shift3Start)
       select @tempshiftstart = @shift1Start,@tempshiftend = @shift1End,@shift1Start = @shift3Start,
              @shift1End = @shift3End,@shift3Start = @tempshiftstart,@shift3End = @tempshiftend
                   
if (@shift1Start > @shift2Start)
       select @tempshiftstart = @shift1Start,@tempshiftend = @shift1End,@shift1Start = @shift2Start,
              @shift1End = @shift2End,@shift2Start = @tempshiftstart,@shift2End = @tempshiftend
              
if (@shift2Start > @shift3Start)
       select @tempshiftstart = @shift2Start,@tempshiftend = @shift2End,@shift2Start = @shift3Start,
              @shift2End = @shift3End,@shift3Start = @tempshiftstart,@shift3End = @tempshiftend                          
                
  
if (@shift1Start is not null and @shift1End is null) or (@shift1Start is null and @shift1End is not null) or (@shift1Start >= @shift1End)
  RAISERROR (@message, 11, 1)  
else if (DATEDIFF(HH,@shift1Start,@shift1End) >=0) 
         SET @TOTALMIN = @TOTALMIN + DATEDIFF(MINUTE,@shift1Start,@shift1End)  

if ((@shift2Start is not null and @shift2End is null) or (@shift2Start is null and @shift2End is not null)
    or (@shift2Start >= @shift2End) or (@shift2Start between @shift1Start and @shift1End))
  RAISERROR (@message, 11, 1)  
else if (DATEDIFF(HH,@shift2Start,@shift2End) >=0) 
         SET @TOTALMIN = @TOTALMIN + DATEDIFF(MINUTE,@shift2Start,@shift2End) 
         
if ((@shift3Start is not null and @shift3End is null) or (@shift3Start is null and @shift3End is not null) 
    or (@shift3Start >= @shift3End) or (@shift3Start between @shift2Start and @shift2End))
  RAISERROR (@message, 11, 1)  
else if (DATEDIFF(HH,@shift3Start,@shift3End) >=0) 
         SET @TOTALMIN = @TOTALMIN + DATEDIFF(MINUTE,@shift3Start,@shift3End) 
 
IF (@TOTALMIN = 0)
  set @totalHours = convert(float,@totalHrs)
ELSE
  set @totalHours = @TOTALMIN/60
   
/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today      = GETDATE()   
SET @isActive   = 1  

/*-------------------------------    
 * If this is an edit
 * perform edit sanity checks
 *------------------------------*/ 

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN  
  
  SET @recordID   = NULL    
  SET @canEdit    = 1 /* Note: No current restrictions on edit */
  
  -- calculate the total hours for the day
  
  /*-------------------------------    
   * Does the record exist and if    
   * so can it be edited    
   *------------------------------*/
     
  SELECT    
    @recordID = ID   
  FROM dbo.STAFF_PROMISED_HOURS where id = @recID
    
  /*-------------------------------    
   * If the record does not exist
   * or it cannot be edited  
   * exit and let the user know   
   *------------------------------*/

  IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)        
  IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1) 
  
END    
        
/*-------------------------------    
 * Validation    
 *------------------------------*/    
   
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW()) 
--  OR (@saveType = dbo.CONST_SAVE_TYPE_EDIT())))    
BEGIN          
  
  /*-------------------------------    
   * Advisement validation   
   * Advisement does not prohibit
   * a record save. 
   *------------------------------*/    
   
  --IF (@validateRec = 1)    
  --BEGIN    
       
    /*-------------------------------    
     * Look for duplicate    
     * records excluding the record    
     * specified by recid    
     *------------------------------*/    
       
    SET @dupCount = 0    
     
    /*-------------------------------    
     * duplicate checking    
     *------------------------------*/    
       
    SELECT 
      @dupCount = COUNT(ib.id) 
    FROM     
     dbo.STAFF_PROMISED_HOURS  AS ib
    WHERE 
      STAFF_ID = @staffID and WEEKSTART_DATE = @weekStart AND DAY = @day    
   
    IF @dupCount > 0    
    BEGIN    
      SET @msgDupRec = dbo.STRING_CREATE(@msgDupRec, CONVERT(VARCHAR(10),@dupCount), NULL, NULL)   
       RAISERROR ('Record already exists for the day', 11, 1) 
    END    
     
    /*-------------------------------    
     * If we are editing and the
     * record we are editing is not    
     * active warn the user
     *------------------------------*/    

    --IF ((@isActive = 0) AND (@saveType = dbo.CONST_SAVE_TYPE_EDIT())) 
   
    /*-------------------------------    
     * If we are providing advisement    
     * validation exit now    
     *------------------------------*/    
         
  --  RETURN(0)         

  --END    
END 
   
/*-------------------------------    
 * Create or modify our    
 * practitioner record    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  /*-------------------------------    
   * New client record
   *------------------------------*/    
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN    
   
    SET @updateState = dbo.CONST_REC_STATE_NEW()    
    if @today < @weekStart set @promised = @totalHours
    /*-------------------------------    
     * dbo.STAFF_PROMISED_HOURS
     *------------------------------*/    
  
    INSERT INTO dbo.STAFF_PROMISED_HOURS
    (  
      STAFF_ID,
      WEEKSTART_DATE,
      DAY,
      SHIFT1_START,
      SHIFT1_END,
      SHIFT2_START,
      SHIFT2_END,
      SHIFT3_START,
      SHIFT3_END,
      TOTAL_HOURS,
      NOTE,
      LAST_UPDATED,
      PROMISED_HOURS     
    )    
    VALUES    
    (  
     @staffID,
     @weekStart,
     @day,
     @shift1Start,
     @shift1End, 
     @shift2Start,
     @shift2End, 
     @shift3Start,
     @shift3End,
     @totalHours,
     @note,
     @today,
     @promised
    )      
    
    SET @recordID = SCOPE_IDENTITY()  
    
    /*-------------------------------    
    * dbo.STAFF_PROMISED_HOURS_AUDIT_LOG
    *------------------------------*/    
    
   --INSERT INTO dbo.STAFF_PROMISED_HOURS_AUDIT_LOG
   --(
       
   --)  
   --VALUES
   --(  
    
   --)   
  
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/    
     
     SET @updateState = dbo.CONST_REC_STATE_MOD()   
     
    /*---------------------------------------------   
     * lock PROMISED_HOURS after saturday midnight
     *------------------------------------------*/
     if @today < @weekStart set @promised = @totalHours
     else 
        select @promised = PROMISED_HOURS from dbo.STAFF_PROMISED_HOURS
        where STAFF_ID = @staffID and WEEKSTART_DATE = @weekStart and DAY = @day
    
     UPDATE dbo.STAFF_PROMISED_HOURS
     SET 
      SHIFT1_START   = @shift1Start,
      SHIFT1_END     = @shift1End,
      SHIFT2_START   = @shift2Start,
      SHIFT2_END     = @shift2End,
      SHIFT3_START   = @shift3Start,
      SHIFT3_END     = @shift3End,
      TOTAL_HOURS    = @totalHours,
      NOTE           = @note,
      LAST_UPDATED   = @today,
      PROMISED_HOURS = @promised
     WHERE (id = @recID)
     
   /*-------------------------------    
    * dbo.STAFF_PROMISED_HOURS_AUDIT_LOG
    *------------------------------*/    
    
   --INSERT INTO dbo.STAFF_PROMISED_HOURS_AUDIT_LOG
   --(
       
   --)  
   --VALUES
   --(  
    
   --)    
        
  END    
  ELSE    
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
   
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
   
      
       
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

GRANT EXECUTE ON  [dbo].[STAFF_PROMISED_HOURS_Save] TO [webuser]
GO
 
