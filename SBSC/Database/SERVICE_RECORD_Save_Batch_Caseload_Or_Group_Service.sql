USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save_Batch_Caseload_Or_Group_Service') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Save_Batch_Caseload_Or_Group_Service
GO

IF EXISTS (SELECT * FROM sys.table_types WHERE name = 'SvcDetailsPatientCaseloadOrGroup')
DROP TYPE SvcDetailsPatientCaseloadOrGroup
GO

/*-------------------------------
 * Object Definitions
 *------------------------------*/

CREATE TYPE SvcDetailsPatientCaseloadOrGroup AS TABLE
(
  patID      int,            
  patName    varchar(500),   /* Label */
  --startTime  time(0),
  startTime  varchar(50),
  numMins    int,
  patPresent BIT,
  patAbsent  BIT,
  notes      VARCHAR(7000)                      
)
GO


CREATE PROCEDURE [dbo].[SERVICE_RECORD_Save_Batch_Caseload_Or_Group_Service]     
 (@userID          BIGINT,    
  @userGroup       INT,    
  @userRank        INT,    
  @reference       VARCHAR(500),           
  @clientID        BIGINT,     
  @pracID          BIGINT,
  @entireCaseload  BIT,      
  @groupID         BIGINT,      
  @isIFSPorIEP     BIT,
  @dos             DATETIME,
  @serviceTypeID   INT,
  @serviceProcCode VARCHAR(100),
  @serviceNameID   INT,
  @svcdetails      SvcDetailsPatientCaseloadOrGroup READONLY,
  @editDelReason   VARCHAR(7000),    
  @validateRec     BIT,    
  @saveType        INT,    
  @recID           BIGINT,    
  @msgDupRec       VARCHAR(1000),    
  @msgInvCombo     VARCHAR(1000),    
  @MsgNoRec        VARCHAR(1000),     
  @MsgNoEdit       VARCHAR(1000),     
  @MsgDataError    VARCHAR(1000),    
  @MsgMinReq       VARCHAR(1000),    
  @MsgMinDef       VARCHAR(1000),     
  @MsgMilReq       VARCHAR(1000),    
  @MsgPatElg       VARCHAR(1000),
  @MsgPatDOBGteDOS VARCHAR(1000),
  @MsgNotActive    VARCHAR(1000),
  @MsgPatAbsent    VARCHAR(1000),
  @MsgFutureDOS    VARCHAR(1000),
  @spDetails       VARCHAR(8000) OUTPUT,    
  @recordID        BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_Save_Batch_Caseload_Or_Group_Service */    
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
 * @param   svcDetails      Service record(s) details
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
      
DECLARE @tranOpen      AS BIT            -- Is a transaction open    

DECLARE @trip1Start    AS DECIMAL(7,1)
DECLARE @trip1End      AS DECIMAL(7,1)
DECLARE @trip2Start    AS DECIMAL(7,1)
DECLARE @trip2End      AS DECIMAL(7,1)
DECLARE @trip3Start    AS DECIMAL(7,1)
DECLARE @trip3End      AS DECIMAL(7,1)
DECLARE @trip4Start    AS DECIMAL(7,1)
DECLARE @trip4End      AS DECIMAL(7,1)
           
DECLARE @recVals       AS TABLE([id]            int IDENTITY(1,1), 
                                [patID]         int, 
                                [startTime]     TIME(0),
                                [numMins]       int, 
                                [patPresent]    bit,
                                [patAbsent]     bit,
                                [notes]         varchar(7000))
                                  
DECLARE @currentID               AS INT
DECLARE @numRecs                 AS INT
DECLARE @numRecsPresent          AS INT
DECLARE @numRecsAbsent           AS INT
DECLARE @numRecsPresentAbsent    AS INT
DECLARE @spDetailsTemp           AS VARCHAR(8000)

DECLARE @retry         AS INT             -- Deadlock retry counter

SET @retry = 5

WHILE (@retry > 0)
BEGIN 

BEGIN TRY    

/*-------------------------------    
 * Create unique batch ID
 *------------------------------*/

DECLARE @batchID       AS UNIQUEIDENTIFIER = null
DECLARE @batchIDRecID  AS BIGINT           = null

exec SERVICE_RECORD_BATCH_ID_Create 
  @userID, @userGroup, @userRank, @saveType, @validateRec, @batchIDRecID OUTPUT , @batchID OUTPUT  
  
/*-------------------------------    
 * Init our details return
 *------------------------------*/
 
SET @spDetails = ''

/*-------------------------------    
 * Check to see if multidate is
 * allowed for the save type 
 *------------------------------*/
   
IF (@saveType <> dbo.CONST_SAVE_TYPE_NEW())  
  RAISERROR ('Batch entry is only allowed for new records', 11, 1) 
   
/*-------------------------------    
 * Extract rec values and generate
 * incrementing row #s
 *------------------------------*/

INSERT INTO @recVals
  select 
    patID, 
    startTime = dbo.TIME_STR_TO_TIME_VAL(startTime),    
    numMins, 
    patPresent,
    patAbsent, 
    notes 
  from @svcdetails

/*-------------------------------    
 * Get number of recs
 * Exit with an error if there
 * are none as there is nothing
 * to do.
 *------------------------------*/

set @numRecs = 0
SELECT @numRecs = COUNT(id) FROM @recVals
IF (@numRecs = 0) 
  RAISERROR ('There are no patient rows.', 11, 1) 

/*-------------------------------    
 * Count number of present 
 *------------------------------*/

set @numRecsPresent = 0
SELECT @numRecsPresent = COUNT(id) FROM @recVals where patPresent = 1

/*-------------------------------    
 * Count number of absent
 *------------------------------*/

set @numRecsAbsent = 0
SELECT @numRecsAbsent = COUNT(id) FROM @recVals where patAbsent = 1

/*-------------------------------    
 * If NONE of the rows have been
 * marked present or absent there
 * is nothing to do.
 * Let the user know and get out.
 *------------------------------*/

if (@numRecsPresent = 0) and (@numRecsAbsent = 0)
  RAISERROR ('No patient rows have present or absent marked.', 11, 1) 

/*-------------------------------    
 * If ANY of the rows have both
 * present and absent marked
 * this is invalid data.
 * Let user know and get out
 *------------------------------*/

set @numRecsPresentAbsent = 0
SELECT @numRecsPresentAbsent = COUNT(id) FROM @recVals where ((patPresent = 1) and (patAbsent = 1))
if (@numRecsPresentAbsent > 0)
  RAISERROR ('There are patients on this screen for whom you checked BOTH present AND absent. Please check one or the other.', 11, 1) 


if (@validateRec = 1)
begin
  
  /*-------------------------------    
   * If all of the rows that are
   * marked were marked as absent
   * let user know and get out
   *------------------------------*/

  declare @msgAllAbsent as varchar(1000)
  set @msgAllAbsent = 'You did not check ANYONE present. Please check ALL the patients you DID SERVE as being present.'
  
  if ((@numRecsAbsent > 0) and (@numRecsPresent = 0))
  begin
    set @spDetails = dbo.UPDATE_DETAILS(@spDetails, @msgAllAbsent, dbo.CONST_RET_WARN())  
    RETURN(0)  
  end
    
  /*-------------------------------    
   * If some of the rows dont have
   * present or absent marked
   * let user know and get out
   *------------------------------*/
  
  declare @msgSomeNoMark as varchar(1000)
  set @msgSomeNoMark = 'There are patients on this screen for whom you did not check EITHER present or absent. Please make sure you have checked ALL of the patients you DID SERVE as being present AND SCHEDULED PATIENTS NOT SERVED as being absent.'
  
  if ((@numRecsPresent + @numRecsAbsent) != @numRecs)
  begin
    set @spDetails = dbo.UPDATE_DETAILS(@spDetails, @msgSomeNoMark, dbo.CONST_RET_WARN())  
  end
  
end

/*-------------------------------    
 * Find practitioner disp group
 *------------------------------*/  

DECLARE @pracGroupID AS BIGINT = null

select top 1 

  @pracGroupID = prg.GROUP_ID

from dbo.PRACTITIONER_Client       as prc 
join dbo.PRACTITIONER_Practitioner as prp on  prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
join dbo.PRACTITIONER_GROUPS       as prg  on prg.PRACTITIONER_ID  = prp.PRACTITIONER_ID
                                              and prg.GROUP_TYPE in (1,2)
where 
        prc.CLIENT_ID         = @clientID 
    and prc.PRACTITIONER_ID   = @pracID
    and prp.PRACTITIONER_ID   = @pracID

if (@pracGroupID is null)
  RAISERROR ('Could not find practitioner discipline group', 11, 1) 

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
 * Create service record(s)
 *------------------------------*/

set @currentID = 1

while (@currentID <= @numRecs)                        
begin

  DECLARE @patID         AS INT
  DECLARE @DOB           AS DATETIME
  DECLARE @planType      as int
  declare @startTime     as TIME(0)
  DECLARE @numMin        AS INT
  DECLARE @patPresent    AS BIT
  DECLARE @patAbsent     AS BIT
  DECLARE @notes         AS VARCHAR(7000)
  DECLARE @nameID        AS INT

  /*-------------------------------    
   * Get values
   *------------------------------*/  
  
  select 
    @currentID  = id, 
    @patID      = patID,
    @startTime  = startTime,
    @numMin     = numMins,
    @patPresent = patPresent,
    @patAbsent  = patAbsent,
    @notes      = notes
  from @recVals where id = @currentID
    
  /*-------------------------------    
   * Get date of birth
   *------------------------------*/  

  set @dob = null
  
  select top 1 

    @dob = DATE_OF_BIRTH 

  from dbo.PATIENTS_Client  as pac 
  join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pac.PATIENT_ID
  
  where 
        pac.CLIENT_ID  = @clientID
    and pac.PATIENT_ID = @patID
    and pap.PATIENT_ID = @patID 

  set @planType = dbo.DOS_DOB_IEP_TO_PLAN_TYPE (@dos, @dob,@isIFSPorIEP)
  
  /*-------------------------------    
   * Determine name ID
   *------------------------------*/  
  
  set @nameID = null
  
  select top 1
    
    @nameID = sva.SERVICE_NAME_ID     

  from dbo.SERVICES_VIEW_ALL_CORE ( @clientID
                                   ,@pracGroupID
                                   ,@planType
                                   ,@serviceTypeID
                                   ,@serviceNameID
                                   ,1
                                   ,1
                                   ,@dos
                                   ,1) as sva
  
     
  if (@nameID is null)
    RAISERROR ('Service not found', 11, 1) 

  /*-------------------------------    
   * Determine if we can/should
   * record the service.
   *------------------------------*/  

  declare @recSvcRec as bit = 1
  if ((@patPresent = 0) and (@patAbsent = 0)) set @recSvcRec = 0
  
  if ((@patPresent = 1) and (@patAbsent = 1)) 
  begin
    set @recSvcRec = 0
  end
  
  /*-------------------------------    
   * Create service record with
   * dos value (all other parms 
   * are the same as passed in)
   *------------------------------*/  

  SET @spDetailsTemp = ''
  
  if (@recSvcRec = 1)
  begin
  
  
  
  EXEC dbo.SERVICE_RECORD_Save_Core
    @userID,    
    @userGroup,    
    @userRank,
	1 /* Claimable */,
    5,    
    @reference,           
    null,    
    null,    
    @dos,    
    @clientID,     
    @pracID,    
    @patID,    
    @isIFSPorIEP,    
    @nameID,
    0,    /* hasORP Doc ID*/
    null, /* ORP Doc ID */
    null, /* ORP Npi */
    0,
    null,
    null,
    null,
    null,    
    @startTime,
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
	0,
	0,
	null, /* @attendanceSelectionID*/
    @notes,    
	null,
	null,
	null,
	0, /* Goal tracking */
	1, /* Billing program id (TODO: Add this parm) */
	0,    /* Has fillable pdf (TODO: Add these 3 parms) */
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
  
  end
   
  set @currentID = @currentID + 1            
  set @spDetails = @spDetails + ltrim(rtrim(@spDetailsTemp))
        
end 

/*-------------------------------    
 * Return the number of records
 * created as the recordID
 *------------------------------*/  

SET @recordID = @numRecs

/*-------------------------------    
 * If this was an actual save
 * or edit commit the transaction
 *------------------------------*/  

IF (@TranOpen = 1) COMMIT TRANSACTION    

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

GRANT EXECUTE ON TYPE::SvcDetailsPatientCaseloadOrGroup TO [webuser]
GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Save_Batch_Caseload_Or_Group_Service] TO [webuser]
GO
