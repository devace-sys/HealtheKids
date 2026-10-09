USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_CALENDAR_DATES_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_ATTENDANCE_CALENDAR_DATES_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLIENT_ATTENDANCE_CALENDAR_DATES_Save]     
 (@userID                     BIGINT,    
  @userGroup                  INT,    
  @userRank                   INT,    
  @clientID                   BIGINT,
  @fiscalYearID               INT,
  @clientAttendanceCalendarID BIGINT,
  @attendanceDayTypeID        BIGINT,
  @datesStr                   VARCHAR(8000),
  @editDelReason              VARCHAR(7000),    
  @validateRec                BIT,    
  @saveType                   INT,    
  @recID                      BIGINT,    
  @MsgNoRec                   VARCHAR(1000),    
  @MsgNoEdit                  VARCHAR(1000), 
  @MsgDupRec                  VARCHAR(1000),  
  @MsgNoClient                VARCHAR(1000),
  @MsgNoCal                   VARCHAR(1000),     
  @MsgNoDates                 VARCHAR(1000),
  @MsgTooManyDates            VARCHAR(1000),
  @MsgInvDates                VARCHAR(1000),
  @MsgDupDates                VARCHAR(1000),
  @MsgOutRangeDates           VARCHAR(1000),
  @MsgOverlapDates            VARCHAR(1000),
  @MsgInvDayType              VARCHAR(1000),
  @MsgDataError               VARCHAR(1000),
  @MsgNotActive               VARCHAR(1000),  
  @spDetails                  VARCHAR(8000) OUTPUT,    
  @recordID                   BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * CLIENT_ATTENDANCE_CALENDAR_DATES_Save */    
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
DECLARE @numDates      AS INT   
DECLARE @calStartDate  AS DATETIME
DECLARE @calEndDate    AS DATETIME
DECLARE @datesVal      AS TABLE([id] int, [date] datetime)  

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

SET @today = GETDATE()    

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
    dbo.CLIENT_ATTENDANCE_CALENDAR_DATES
  where 
    ID = @recID

  /*-------------------------------    
   * If it does not exist or can
   * not be edited, get out!
   *------------------------------*/ 
        
  IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)        
  IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1)  
         
END -- Edit
ELSE
BEGIN
  SET @recID = null
END

/*============================================================
 * Required validation of parameters provided and lookup 
 * supporting data for new records and edited records
 *============================================================*/   
 
/*-------------------------------    
 * Verify client id exists    
 *------------------------------*/    

SET @tempRecID = NULL    
IF (@clientID is null) RAISERROR (@MsgNoClient, 11, 1)

SELECT 
  @tempRecID = CLIENT_ID
FROM
  CLIENTS_CLIENT 
WHERE 
  CLIENT_ID = @clientID    

IF (@tempRecID is null) RAISERROR (@MsgNoClient, 11, 1)            

/*-------------------------------    
 * Verify calendar exits    
 *-------------------------------*/   

SET @tempRecID = NULL    
IF (@clientAttendanceCalendarID is null) RAISERROR (@MsgNoCal, 11, 1)

SELECT
  @tempRecID    = id,
  @calStartDate = StartDate,
  @calEndDate   = EndDate
FROM 
  CLIENT_ATTENDANCE_CALENDAR_VIEW(@userID,@userGroup,@userRank,@clientID,null,null,null)
WHERE 
   id = @clientAttendanceCalendarID 
  
IF (@tempRecID is null) RAISERROR (@MsgNoCal, 11, 1)            

/*-------------------------------    
 * Verify attendance day type   
 *-------------------------------*/   
 
SET @tempRecID = NULL  
IF (@attendanceDayTypeID is null) RAISERROR (@MsgInvDayType, 11, 1)            

SELECT 
  @tempRecID = id
FROM 
  dbo.CLIENT_ATTENDANCE_DAY_TYPES
WHERE 
  id = @attendanceDayTypeID

IF (@tempRecID is null) RAISERROR (@MsgInvDayType, 11, 1)            

/*-------------------------------    
 * Verify dates data
 *-------------------------------*/   
 
IF @datesStr is null RAISERROR (@MsgNoDates, 11, 1) 

/* Parse datesStr into a dates table */

BEGIN TRY
  INSERT INTO @datesVal
  SELECT [id],[date] FROM dbo.MULTI_DATE_PARSE(@datesStr,',')
END TRY
BEGIN CATCH
  RAISERROR (@MsgInvDates, 11, 1) 
END CATCH

/* Count the resulting rows */

SELECT @numDates = COUNT(id) FROM @datesVal

/* Not enough */

IF (@numDates = 0) RAISERROR (@MsgNoDates,      11, 1) 

/* Too many */

IF (@numDates > 365) RAISERROR (@MsgTooManyDates, 11, 1) 

/* Check for duplicate dates in this set of rows */

SET @dupCount = 0
SELECT @dupCount = COUNT([id]) FROM @datesVal GROUP BY [date] HAVING COUNT([id]) > 1
IF (@dupCount > 0) RAISERROR (@MsgDupDates, 11, 1) 

/* Check to see if the dates are out of the calendar date range*/

SET @dupCount = 0
SELECT @dupCount = COUNT([id]) FROM @datesVal WHERE [date] between @calStartDate and @calEndDate
if (@dupCount != @numDates) RAISERROR (@MsgOutRangeDates, 11, 1) 

/*-------------------------------    
 * Look for duplicate records 
 * (by day type)
 * excluding the record specified
 * by recid    
 *------------------------------*/    

SET @dupCount = 0   
  
select 
  @dupCount = COUNT(id) 
from 
  dbo.CLIENT_ATTENDANCE_CALENDAR_DATES
where
  ((@recID IS NULL) OR (ID != @recID)) 
  and (clientID            = @clientID)
  and (calendarID          = @clientAttendanceCalendarID)
  and (attendanceDayTypeID = @attendanceDayTypeID)
  and (Active              = 1) 
   
/*-------------------------------    
 * If a duplicate record was 
 * found, get out!
 *------------------------------*/    
    
if (@dupCount > 0) RAISERROR (@MsgDupRec, 11, 1) 

/*-------------------------------    
 * Look for overlapping date use 
 *-------------------------------*/   
 
SET @dupCount = 0   

select 
  @dupCount = COUNT(acd.id)
from dbo.CLIENT_ATTENDANCE_CALENDAR_DATES  as acd
join CLIENT_ATTENDANCE_CALENDAR_DATES_DAYS as acdd on acdd.calendarDatesID = acd.id
join @datesVal                             as acdn on acdn.date            = acdd.attendanceDay
where 
  ((@recID IS NULL) OR (acd.id != @recID))     and 
  acd.calendarID = @clientAttendanceCalendarID and
  acd.active = 1

/*-------------------------------    
 * If a overlapping record was 
 * found, get out!
 *------------------------------*/    
    
if (@dupCount > 0) RAISERROR (@MsgOverlapDates, 11, 1) 


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
 * Create or modify assignment records
 *============================================================*/     
    
BEGIN TRANSACTION    
    
SET @TranOpen = 1    

/*-------------------------------    
 * New record
 *------------------------------*/ 

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN    
    
  SET @updateState = dbo.CONST_REC_STATE_NEW()    
        
  INSERT INTO dbo.CLIENT_ATTENDANCE_CALENDAR_DATES

    (clientID,
     calendarID,
     attendanceDayTypeID,
     datesStr,
     created,
     createdBy,
     active)    
       
  VALUES     
    
    (@clientID, 
     @clientAttendanceCalendarID,
     @attendanceDayTypeID,
     @datesStr,
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
                      
  UPDATE dbo.CLIENT_ATTENDANCE_CALENDAR_DATES
  SET
    datesStr            = @datesStr,
    lastUpdated         = @today,
    lastUpdatedBy       = @userID     
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
 * Clear out old date details
 *============================================================*/  

DELETE
CLIENT_ATTENDANCE_CALENDAR_DATES_DAYS
WHERE calendarDatesID = @recordID

/*============================================================
 * Insert date details
 *============================================================*/  

INSERT INTO CLIENT_ATTENDANCE_CALENDAR_DATES_DAYS (calendarDatesID, attendanceDay)
SELECT 
  @recordID as [calendarDatesID], 
  [date]    as [attendanceDay] 
FROM @datesVal

/*============================================================
 * Create audit record
 *============================================================*/  

EXEC CLIENT_ATTENDANCE_CALENDAR_DATES_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
       
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

GRANT EXECUTE ON  [dbo].[CLIENT_ATTENDANCE_CALENDAR_DATES_Save] TO [webuser]
GO
