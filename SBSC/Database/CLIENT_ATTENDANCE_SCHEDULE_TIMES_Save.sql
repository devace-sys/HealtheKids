USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_SCHEDULE_TIMES_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_ATTENDANCE_SCHEDULE_TIMES_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CLIENT_ATTENDANCE_SCHEDULE_TIMES_Save]     
 (@userID                     BIGINT,    
  @userGroup                  INT,    
  @userRank                   INT,    
  @clientID                   BIGINT,
  @fiscalYearID               INT,
  @clientAttendanceScheduleID BIGINT,
  @attendanceDayTypeID        BIGINT,
  @attendanceTimeStart        TIME(0),
  @attendanceTimeEnd          TIME(0),
  @period0TimeStart           TIME(0),
  @period0TimeEnd             TIME(0),
  @period1TimeStart           TIME(0),
  @period1TimeEnd             TIME(0),
  @period2TimeStart           TIME(0),
  @period2TimeEnd             TIME(0),
  @period3TimeStart           TIME(0),
  @period3TimeEnd             TIME(0),
  @period4TimeStart           TIME(0),
  @period4TimeEnd             TIME(0),
  @period5TimeStart           TIME(0),
  @period5TimeEnd             TIME(0),
  @period6TimeStart           TIME(0),
  @period6TimeEnd             TIME(0),
  @period7TimeStart           TIME(0),
  @period7TimeEnd             TIME(0),
  @period8TimeStart           TIME(0),
  @period8TimeEnd             TIME(0),
  @period9TimeStart           TIME(0),
  @period9TimeEnd             TIME(0),
  @period10TimeStart          TIME(0),
  @period10TimeEnd            TIME(0),
  @editDelReason              VARCHAR(7000),    
  @validateRec                BIT,    
  @saveType                   INT,    
  @recID                      BIGINT,    
  @MsgNoRec                   VARCHAR(1000),    
  @MsgNoEdit                  VARCHAR(1000), 
  @MsgDupRec                  VARCHAR(1000),  
  @MsgNoClient                VARCHAR(1000),
  @MsgNoSch                   VARCHAR(1000),  
  @MsgNoTimes                 VARCHAR(1000),    
  @MsgDupTimes                VARCHAR(1000),
  @MsgOutOrderTimes           VARCHAR(1000),
  @MsgOutRangeTimes           VARCHAR(1000),
  @MsgPeriodsOverlap          VARCHAR(1000),
  @MsgInvalidStartPeriod      VARCHAR(1000),
  @MsgInvDayType              VARCHAR(1000), 
  @MsgDataError               VARCHAR(1000),
  @MsgNotActive               VARCHAR(1000),  
  @spDetails                  VARCHAR(8000) OUTPUT,    
  @recordID                   BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * CLIENT_ATTENDANCE_SCHEDULE_Times_Save */    
/**    
 * Creates a new client attendance schedule times slot
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
DECLARE @count         AS INT
DECLARE @periodStart   AS TIME(0)
DECLARE @periodEnd     AS TIME(0)
DECLARE @id            AS INT

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
    dbo.CLIENT_ATTENDANCE_SCHEDULE_TIMES
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

IF (@clientID is null) RAISERROR (@MsgNoClient, 11, 1)

SET @tempRecID = NULL    
SELECT @tempRecID = CLIENT_ID 
FROM CLIENTS_CLIENT 
WHERE CLIENT_ID = @clientID    

IF (@tempRecID is null) RAISERROR (@MsgNoClient, 11, 1)            


/*-------------------------------    
 * Verify schedule exits    
 *-------------------------------*/   

SET @tempRecID = NULL    
IF (@clientAttendanceScheduleID is null) RAISERROR (@MsgNoSch, 11, 1)

SELECT
  @tempRecID = id 
FROM 
  dbo.CLIENT_ATTENDANCE_SCHEDULE
WHERE 
      id       = @clientAttendanceScheduleID 
  and clientID = @clientID
  
IF (@tempRecID is null) RAISERROR (@MsgNoSch, 11, 1)            

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

declare @periods table (
        ID          int Identity primary key,
		PeriodStart	time(0),
		PeriodEnd   time(0)
	)	
	
Insert into @periods values (@period0TimeStart, @period0TimeEnd)	
Insert into @periods values (@period1TimeStart, @period1TimeEnd)	
Insert into @periods values (@period2TimeStart, @period2TimeEnd)	
Insert into @periods values (@period3TimeStart, @period3TimeEnd)	
Insert into @periods values (@period4TimeStart, @period4TimeEnd)	
Insert into @periods values (@period5TimeStart, @period5TimeEnd)	
Insert into @periods values (@period6TimeStart, @period6TimeEnd)	
Insert into @periods values (@period7TimeStart, @period7TimeEnd)	
Insert into @periods values (@period8TimeStart, @period8TimeEnd)	
Insert into @periods values (@period9TimeStart, @period9TimeEnd)	
Insert into @periods values (@period10TimeStart,@period10TimeEnd)

select @count = COUNT(*),@id = 1 from @periods

/*-------------------------------    
 * Verify start and end times    
 *-------------------------------*/   
 
if ((@attendanceTimeStart is not null) or (@attendanceTimeEnd is not null)) 
begin
   if (@attendanceTimeStart is null) or (@attendanceTimeEnd is null) RAISERROR (@MsgDupTimes, 11, 1) 
   if (@attendanceTimeStart = @attendanceTimeEnd) RAISERROR (@MsgDupTimes,      11, 1) 
   if (@attendanceTimeStart > @attendanceTimeEnd) RAISERROR (@MsgOutOrderTimes, 11, 1)
   if (@attendanceTimeStart <= '6:00')            RAISERROR (@MsgOutRangeTimes, 11, 1)
   if (@attendanceTimeEnd   >= '17:00')           RAISERROR (@MsgOutRangeTimes, 11, 1)
end
else if not exists(select 1 from @periods where PeriodStart is not null and PeriodEnd is not null)
         RAISERROR (@MsgNoTimes, 11, 1)
else
begin

/*---------------------------------------------------    
  * set the attendance timings from the given periods if not provided.
  * start time of first period will be attendance start time
  * and end time of last period will be attendance end time   
  *--------------------------------------------------*/

select @id = MIN(id) from @periods where PeriodStart is not null and PeriodEnd is not null

select @attendanceTimeStart = PeriodStart from @periods where ID = @id

if (@id not in (1,2))  
   SET @spDetails = dbo.UPDATE_DETAILS(@spDetails, @MsgInvalidStartPeriod, dbo.CONST_RET_WARN()) 

select @id = MAX(id) from @periods where PeriodStart is not null and PeriodEnd is not null

select @attendanceTimeEnd = PeriodEnd from @periods where ID = @id

/*-------------------------------------------    
 * Verify if start and end times of each period   
 *-------------------------------------------*/ 
	while @id <= @count
	begin

		select @periodStart = PeriodStart, @periodEnd = PeriodEnd from @periods where ID = @id
		if (@periodStart is null and @periodEnd is null) 
		begin
		   set @id = @id +1
		   continue
		end
		
		if (@periodStart is not null and @periodEnd is null)     RAISERROR (@MsgNoTimes, 11, 1)
		if (@periodStart is null     and @periodEnd is not null) RAISERROR (@MsgNoTimes, 11, 1)
		
		if (@periodStart = @periodEnd)           RAISERROR (@MsgDupTimes,      11, 1) 
		if (@periodStart > @periodEnd)           RAISERROR (@MsgOutOrderTimes, 11, 1)
		if (@periodStart < @attendanceTimeStart) RAISERROR (@MsgOutRangeTimes, 11, 1)
		if (@periodEnd   > @attendanceTimeEnd)   RAISERROR (@MsgOutRangeTimes, 11, 1)      
		
		/*-------------------------------    
		 * Verify if periods are overlapping.
		 *-------------------------------*/ 
	       
		if exists (select 1 from @periods where ID != @id and 		   
				  ((@periodStart > PeriodStart and @periodStart < PeriodEnd) or
				   (@periodEnd   > PeriodStart and @periodEnd   < PeriodEnd)))
		   RAISERROR (@MsgPeriodsOverlap, 11, 1)           
	       
		/*---------------------------------------------------    
		 * Verify if periods are in ascending order for example 
		 * period 2 should not start before period 1       
		 *--------------------------------------------------*/    
	    
		if exists (select 1 from @periods where ID < @id and (@periodStart <= PeriodStart or @periodEnd <= PeriodEnd))
		   RAISERROR (@MsgOutOrderTimes , 11, 1)   
		set @id = @id + 1

     end
 
 end
	
/*-------------------------------    
 * Look for duplicate records 
 * excluding the record specified
 * by recid    
 *------------------------------*/    

SET @dupCount = 0   
    
select 
  @dupCount = COUNT(id) 
from 
  dbo.CLIENT_ATTENDANCE_SCHEDULE_TIMES
where
  ((@recID IS NULL) OR (ID != @recID)) 
  and (clientID            = @clientID)
  and (scheduleID          = @clientAttendanceScheduleID)
  and (attendanceDayTypeID = @attendanceDayTypeID)
  and (Active              = 1) 
   
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
        
  INSERT INTO dbo.CLIENT_ATTENDANCE_SCHEDULE_TIMES
  
    (clientID,
     scheduleID,
     attendanceDayTypeID,
     attendanceTimeStart,
     attendanceTimeEnd,
     period0TimeStart,
     period0TimeEnd,
     period1TimeStart,
     period1TimeEnd,
     period2TimeStart,
     period2TimeEnd,
     period3TimeStart,
     period3TimeEnd,
     period4TimeStart,
     period4TimeEnd,
     period5TimeStart,
     period5TimeEnd,
     period6TimeStart,
     period6TimeEnd,
     period7TimeStart,
     period7TimeEnd,
     period8TimeStart,
     period8TimeEnd,
     period9TimeStart,
     period9TimeEnd,
     period10TimeStart,
     period10TimeEnd,
     created,
     createdBy,
     active)    
       
  VALUES     
    
    (@clientID, 
     @clientAttendanceScheduleID,
     @attendanceDayTypeID,
     @attendanceTimeStart,
     @attendanceTimeEnd,
     @period0TimeStart,         
	 @period0TimeEnd,          
	 @period1TimeStart,           
	 @period1TimeEnd,             
	 @period2TimeStart,           
	 @period2TimeEnd,             
	 @period3TimeStart,           
	 @period3TimeEnd,             
	 @period4TimeStart,           
	 @period4TimeEnd,             
	 @period5TimeStart,           
	 @period5TimeEnd,             
	 @period6TimeStart,           
	 @period6TimeEnd,             
	 @period7TimeStart,           
	 @period7TimeEnd,             
	 @period8TimeStart,           
	 @period8TimeEnd,             
	 @period9TimeStart,           
	 @period9TimeEnd,             
	 @period10TimeStart,          
	 @period10TimeEnd,
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
                      
  UPDATE dbo.CLIENT_ATTENDANCE_SCHEDULE_TIMES
  SET
     attendanceTimeStart = @attendanceTimeStart,
     attendanceTimeEnd   = @attendanceTimeEnd,
     period0TimeStart 	 = @period0TimeStart,         
     period0TimeEnd 	 = @period0TimeEnd,          
     period1TimeStart 	 = @period1TimeStart,           
     period1TimeEnd 	 = @period1TimeEnd,             
     period2TimeStart 	 = @period2TimeStart,           
     period2TimeEnd 	 = @period2TimeEnd,             
     period3TimeStart 	 = @period3TimeStart,           
     period3TimeEnd 	 = @period3TimeEnd,             
     period4TimeStart 	 = @period4TimeStart,           
     period4TimeEnd 	 = @period4TimeEnd,             
     period5TimeStart 	 = @period5TimeStart,           
     period5TimeEnd 	 = @period5TimeEnd,             
     period6TimeStart 	 = @period6TimeStart,           
     period6TimeEnd 	 = @period6TimeEnd,             
     period7TimeStart 	 = @period7TimeStart,           
     period7TimeEnd 	 = @period7TimeEnd,             
     period8TimeStart 	 = @period8TimeStart,           
     period8TimeEnd 	 = @period8TimeEnd,             
     period9TimeStart 	 = @period9TimeStart,           
     period9TimeEnd 	 = @period9TimeEnd,             
     period10TimeStart 	 = @period10TimeStart,          
     period10TimeEnd 	 = @period10TimeEnd,
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
 * Create audit record
 *============================================================*/  

EXEC CLIENT_ATTENDANCE_SCHEDULE_TIMES_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
       
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

GRANT EXECUTE ON  [dbo].[CLIENT_ATTENDANCE_SCHEDULE_TIMES_Save] TO [webuser]
GO
