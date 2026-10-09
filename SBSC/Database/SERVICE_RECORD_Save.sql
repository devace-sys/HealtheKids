USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Save]     
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @reference     VARCHAR(500),           
  @batchNum      NCHAR(10),    
  @papClmNum     NCHAR(35),  
  @isMultiDos    BIT,  
  @dos           datetime,
  @dosMulti      varchar(1000),    
  @clientID      INT,     
  @pracID        INT,    
  @patID         INT,    
  @isIFSPorIEP   BIT,    
  @nameID        INT,
  
  @hasOrpDocID   BIT,
  @orpDocID      BIGINT,

  @hasSvcDetailFlags BIT,
  @svcDetFlag1       BIT,
  @svcDetFlag2       BIT,
  @svcDetFlag3       BIT,
  @svcDetFlag4       BIT,
  
  @startTime         varchar(50),
  @numMin            INT,    
  
  @trip1Start    DECIMAL(7,1),    
  @trip1End      DECIMAL(7,1),    
  @trip2Start    DECIMAL(7,1),    
  @trip2End      DECIMAL(7,1),    
  @trip3Start    DECIMAL(7,1),    
  @trip3End      DECIMAL(7,1),    
  @trip4Start    DECIMAL(7,1),    
  @trip4End      DECIMAL(7,1),

  @attendanceStatus     int,      
  
  @notes         VARCHAR(7000),    
  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,    
  @saveType      INT,    
  @recID         BIGINT,    
  @msgDupRec          VARCHAR(1000),    
  @msgInvCombo        VARCHAR(1000),    
  @MsgNoRec           VARCHAR(1000),     
  @MsgNoEdit          VARCHAR(1000),     
  @MsgDataError       VARCHAR(1000),    
  @MsgMinReq          VARCHAR(1000),    
  @MsgMinDef          VARCHAR(1000),     
  @MsgMilReq          VARCHAR(1000),    
  @MsgPatElg          VARCHAR(1000),
  @MsgPatDOBGteDOS    VARCHAR(1000),
  @MsgNotActive       VARCHAR(1000),
  @MsgPatAbsent       VARCHAR(1000), 
  @MsgFutureDOS       VARCHAR(1000),    
  @spDetails          VARCHAR(8000) OUTPUT,    
  @recordID           BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_SAVE */    
/**    
 * Creates a new, edits existing, or deletes (hides) existing service record    
 * and manages any associated claim records.    
 *    
 * @param   userID          The userid of who saved the record    
 * @param   reference       Note field indicating the source of the service    
 *                          record.  For example a document number.    
 * @param   batchNum        Deprecated.  Used for documentation in underlying claim recs.    
 * @param   papClmNum       Deprecated.  Used for documentation in underlying claim recs.    
 * @param   dos             Date of service.    
 * @param   clientID        Client's record id    
 * @param   pracID          Practitioner's record id    
 * @param   patID           Patient's record id    
 * @param   isIFSPorIEP     1 = service record is part of an IFSP or IEP    
 *                          0 = service record is not part of an IFSP or IEP    
 * @param   nameID          Service's (service provided) record id    
 * @param   numMin          For time based services the number of minutes     
 *                          needed to provided the service    
 * @param   trip1Start      For mile based services the odometer reading    
 *                          at the start of the trip    
 * @param   trip1End        For mile based services the odometer reading    
 *                          at the end of the trip OR the total # miles for    
 *                          the trip    
 * @param   trip2Start      For mile based services the odometer reading    
 *                          at the start of the trip    
 * @param   trip2End        For mile based services the odometer reading    
 *                          at the end of the trip OR the total # miles for    
 *                          the trip    
 * @param   trip3Start      For mile based services the odometer reading    
 *                          at the start of the trip    
 * @param   trip3End        For mile based services the odometer reading    
 *                          at the end of the trip OR the total # miles for    
 *                          the trip    
 * @param   trip4Start      For mile based services the odometer reading    
 *                          at the start of the trip    
 * @param   trip4End        For mile based services the odometer reading    
 *                          at the end of the trip OR the total # miles for    
 *                          the trip
 * @param   patAbsent       Indicates patient was absent.  
 *                          1 = Service record will be saved but no claims
 *                              will be generated
 *                          0 = Regular save   
 * @param   notes           Free form text note for the service record    
 * @param   validateRec     1 = Performs data integrity validation tasks    
                                Perform advisory validation tasks that can    
 *                              only be conducted by referencing data from the    
 *                              database and then exits WITHOUT saving the record    
 *                          0 = Peform data integrity validation tasks and    
 *                              if these tasks succeed peforms the desired    
 *                              operation (saveType) on the record and exits    
 * @param   saveType        Type of operation to perform    
 *                          1 = New, 2 = Edit, 3 = Delete    
 * @param   recID           Record id of existng service record to edit or    
 *                          delete.    
 * @param   msgDupRec       Desired error message for duplicate records    
 * @param   msgInvCombo     Desired error message for invalid client, prac, and    
 *                          patient id combinations    
 * @param   MsgNoRec        Desired error message for edit/delete service record    
 *                          operations when record is not found    
 * @param   MsgNoEdit       Desired error message for edit/delete service record    
 *                          operations if the service record cannot be edited or     
 *                          deleted     
 * @param   MsgDataError    Desired error message for data errors    
 * @param   MsgMinReq       Desired error messages for time based service records    
 *                          that require minutes, but numMins is 0    
 * @param   MsgMinDef       Desired error message for time based service records    
 *                          that require minute and at least 7 minutes to generate    
 *                          a claim record.    
 * @param   MsgMilReq       Desired error message for mile bases service records    
 *                          where mileage was not provided    
 *
 * @param   MsgPatElg       Desired non eligible message (NE)     
 * @param   MsgPatDOBGteDOS Desired error message if Patient DOB >= SvcRec DOS
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
  
DECLARE @tranOpen     AS BIT            -- Is a transaction open    
DECLARE @dosVal       AS DATETIME
DECLARE @dosVals      AS TABLE([id] int, [date] datetime)  
DECLARE @currentID    AS INT
DECLARE @numDates     AS INT
DECLARE @spDetailsTemp AS VARCHAR(8000)
DECLARE @numDupDates  AS INT
DECLARE @retry        AS INT             -- Deadlock retry counter
declare @startTimeVal as time(0)

declare @patAbsent     as bit
declare @pracAbsent    as bit 
declare @makeupSession as bit

SET @retry = 5

WHILE (@retry > 0)
BEGIN 

BEGIN TRY    

/*-------------------------------    
 * Init our details return
 *------------------------------*/
 
SET @spDetails = ''

/*-------------------------------    
 * Get attenance status flags
 * from selection
 *------------------------------*/

select top 1
    @patAbsent     = t1.patAbsent
  , @pracAbsent    = t1.pracAbsent
  , @makeUpSession = t1.makeupSession

from dbo.SERVICE_RECORD_ATTENDANCE_SELECTION_ID_TO_FLAGS (@attendanceStatus) as t1
    
/*-------------------------------    
 * Assume single date mode.
 *------------------------------*/

IF @isMultiDos IS NULL SET @isMultiDos = 0

/*-------------------------------    
 * Setup DOS table appropriately
 *------------------------------*/

IF (@isMultiDos = 0)

/*-------------------------------    
 * Single date.
 *------------------------------*/

BEGIN 
  INSERT INTO @dosVals VALUES (1, @dos)
  SET @numDates = 1

END
ELSE

/*-------------------------------    
 * One or more dates
 *------------------------------*/

BEGIN

  /*-------------------------------    
   * Check to see if multidate is
   * allowed for the save type and
   * user group
   *------------------------------*/
   
   IF (@saveType  <> dbo.CONST_SAVE_TYPE_NEW())  RAISERROR ('Multiple DOS entry is only allowed for new records', 11, 1) 
   IF (@userGroup <> dbo.CONST_USER_GROUP_SBS()) RAISERROR ('Multiple DOS entry is only allowed for SBSC users', 11, 1) 
   
  /*-------------------------------    
   * Multiple dates
   *------------------------------*/
 
  INSERT INTO @dosVals
  SELECT [id],[date] FROM dbo.MULTI_DATE_PARSE(@dosMulti,',')

  /*-------------------------------    
   * Get number of dates
   * Exit with an error if there
   * are none.
   *------------------------------*/

  SELECT @numDates = COUNT(id) FROM @dosVals
  IF (@numDates = 0) RAISERROR ('One or more dates are required', 11, 1) 
  
  /*-------------------------------    
   * Check for duplicate dates
   * Exit with an error if there
   * are dups.
   *------------------------------*/

  SET @numDupDates = 0
  SELECT @numDupDates = COUNT([id]) FROM @dosVals GROUP BY [date] HAVING COUNT([id]) > 1
  IF (@numDupDates > 0) RAISERROR ('Duplicate dates are not allowed', 11, 1) 
  
END


/*-------------------------------    
 * Convert start time
 *------------------------------*/  

set @startTimeVal = dbo.TIME_STR_TO_TIME_VAL(@startTime)

/*-------------------------------    
 * If this is an actual save
 * or edit begin a transaction
 *------------------------------*/  

IF (@validateRec = 0)
BEGIN
  BEGIN TRANSACTION    
  SET @TranOpen  = 1      
END
ELSE
  SET @TranOpen = 0  

/*-------------------------------    
 * Create unique batch ID
 *------------------------------*/

DECLARE @batchID       AS UNIQUEIDENTIFIER = null
DECLARE @batchIDRecID  AS BIGINT           = null

exec SERVICE_RECORD_BATCH_ID_Create 
  @userID, @userGroup, @userRank, @saveType, @validateRec, @batchIDRecID OUTPUT , @batchID OUTPUT  

/*-------------------------------    
 * Create service record(s)
 *------------------------------*/

set @currentID = 1

while (@currentID <= @numDates)                        
begin

  /*-------------------------------    
   * Get dos value
   *------------------------------*/  
  
  select @currentID = id, @dosVal = date from @dosVals where id = @currentID
  
  /*-------------------------------    
   * Create service record with
   * dos value (all other parms 
   * are the same as passed in)
   *------------------------------*/  

  EXEC dbo.SERVICE_RECORD_Save_Core
    @userID,    
    @userGroup,    
    @userRank,
	1, /* Gen claims */
    0,     
    @reference,           
    @batchNum,    
    @papClmNum,    
    @dosVal,    
    @clientID,     
    @pracID,    
    @patID,    
    @isIFSPorIEP,    
    @nameID,

    @hasOrpDocID,
    @orpDocID,
    null,
    
    @hasSvcDetailFlags,
    @svcDetFlag1,
    @svcDetFlag2,
    @svcDetFlag3,
    @svcDetFlag4,
    @startTimeVal,
    @numMin,    
    @trip1Start,    
    @trip1End,    
    @trip2Start,    
    @trip2End,    
    @trip3Start,    
    @trip3End,    
    @trip4Start,    
    @trip4End,
    @patAbsent,    
    @pracAbsent, 
    @makeupSession, 
	@attendanceStatus, /* @attendanceSelectionID*/
    @notes,  
	null,
	null, 
	null,
	0, /* Goal track */
	1, /* Billing program id (TODO: Add this parm) */
	0, /* Has fillable pdf*/
	'[]', /* Fillable pdf selections */
	'[]', /* Fillable pdf answers*/
    @editDelReason,    
    @validateRec,    
    @saveType,    
    @recID,    
    @msgDupRec,    
    @msgInvCombo,    
    @MsgNoRec,     
    @MsgNoEdit,     
    @MsgDataError,    
    @MsgMinReq,    
    @MsgMinDef,     
    @MsgMilReq,    
    @MsgPatElg,
    @MsgPatDOBGteDOS,
    @MsgNotActive, 
    @MsgPatAbsent,
    @MsgFutureDOS,
    @spDetailsTemp OUTPUT,    
    @recordID      OUTPUT      

   /*-------------------------------    
    * Assign unique batch ID
    *------------------------------*/

   DECLARE @batchIDAssRecID  AS BIGINT = null

   exec SERVICE_RECORD_BATCH_ID_Assign
    @userID, @userGroup, @userRank, @saveType, @validateRec, @batchID, @currentID, @recordID, @batchIDAssRecID OUTPUT 
    
   set @currentID = @currentID + 1
   set @spDetails = @spDetails + ltrim(rtrim(@spDetailsTemp))

end 

/*-------------------------------    
 * If this was a multidate save
 * return the number of records
 * created as the recordID
 *------------------------------*/  

IF (@isMultiDos = 1) SET @recordID = @numDates

/*-------------------------------    
 * If this was an actual save
 * or edit commit the transaction
 *------------------------------*/  

IF (@TranOpen  = 1) COMMIT TRANSACTION    

/*-------------------------------    
 * Reset our transaction flag and
 * retry counter
 *------------------------------*/  

SET @TranOpen = 0    
SET @retry    = 0
RETURN(0)    

END TRY    

/*-------------------------------    
 * If we end up here something    
 * went wrong
 *------------------------------*/    

BEGIN CATCH    
  
  -- Error or raise error with severity 11 to 19 will be caught here    
    
  /*-------------------------------    
   * Cancel any pending    
   * transactions  
   *------------------------------*/    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  /*-------------------------------    
   * Identify error
   *------------------------------*/    
  
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage 
      
  /*-------------------------------    
   * If the error is a deadlock 
   * retry until retrys are exhausted
   *------------------------------*/    
  
  IF (ERROR_NUMBER() = 1205)
     SET @retry = @retry - 1;
  ELSE
    SET @retry = -1;
  
  /*-------------------------------    
   * Return the error message to
   * the caller.  This includes
   * deadlocks that have been 
   * unresolved after retrying.
   *------------------------------*/    
 
  IF (@retry < 0) RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END -- while

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Save] TO [webuser]
GO
