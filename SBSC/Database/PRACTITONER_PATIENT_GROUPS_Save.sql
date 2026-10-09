USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITONER_PATIENT_GROUPS_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITONER_PATIENT_GROUPS_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PRACTITONER_PATIENT_GROUPS_Save] 
    
 (@userID        BIGINT,    
  @userGroup     INT,    
  @userRank      INT,    
  @clientID      INT,    
  @pracID        INT,

  @name          VARCHAR(500),
  @description   VARCHAR(1000),    
  
  @startDate     DATETIME,
  @startTime     TIME,
  @numMins       INT,
  
  @grpMtg2       BIT,
  @grpMtg3       BIT,
  @grpMtg4       BIT,
  @grpMtg5       BIT,
  @grpMtg6       BIT,
  
  @patIDsStr     VARCHAR(8000),
  @tmtEffDate    DATETIME,

  @editDelReason VARCHAR(7000),    
  @validateRec   BIT,    
  @saveType      INT,    
  @recID         INT,    
  @MsgNoRec      VARCHAR(1000),    
  @MsgNoEdit     VARCHAR(1000), 
  @MsgDupRec     VARCHAR(1000),     
  @MsgDataError  VARCHAR(1000),
  @MsgNotActive  VARCHAR(1000),     
  @spDetails     VARCHAR(8000) OUTPUT,    
  @recordID      BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * PRACTITONER_PATIENT_GROUPS_Save  */    
/**    
 * Creates a new treatment group record or edits an existing one
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   pracID          Practitioner id
 * @param   patID           Patient id
 * @param   startDate       Relationship start
 * @param   endDate         Relationship end
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
 * @param   MsgNoSite       Desired error message if a siteID is not found     
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    

DECLARE @TranOpen            AS BIT  
DECLARE @tempRecID           AS BIGINT           -- Used for determining if a rec exists    
DECLARE @tempActive          AS BIT
DECLARE @reactivate          AS BIT
DECLARE @reactivateID        AS BIGINT
DECLARE @startDateInUse      AS BIT
DECLARE @recCount            AS INT
DECLARE @tempSvcStartDate    as DATETIME
DECLARE @tempSvcEndDate      as DATETIME
DECLARE @tempRecCount        as INT
DECLARE @testDate1           as DATETIME 
DECLARE @testDate2           as DATETIME 
DECLARE @editSvcSchRec       as INT
DECLARE @today               as DATETIME
DECLARE @updateState         AS SMALLINT         -- Indicates what state the record is left in    
DECLARE @pracPatSvcSchRecID  AS BIGINT
DECLARE @pracPatDatesRecID   AS BIGINT
DECLARE @auditRecID          AS BIGINT
DECLARE @tempTmpTmtSchStr    AS VARCHAR(1000)
DECLARE @hasTmtSch           AS BIT
DECLARE @hasEffDate          AS BIT

declare @dupOrCheckRecID as int     = null
declare @recCountCheck1  as int     = 0
declare @recCountCheck2  as int     = 0
declare @patientIDs      as TABLE (id int, recid bigint)

BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @spDetails  = ''    
SET @recordID = NULL 
SET @today    = GETDATE()

/*============================================================
 * Verify parameters required for proper operation
 *============================================================*/ 

IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)      
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)    
                                  
/*============================================================
 * Verify client, practitioner, and patient ids
 *============================================================*/ 

/*-------------------------------    
 * Make sure the client is valid
 *------------------------------*/   
 
set          @dupOrCheckRecID = -1
select       @dupOrCheckRecID = isnull(clc.CLIENT_ID,-1)
from CLIENTS_Client as clc
where clc.CLIENT_ID = @clientID

/*-------------------------------    
 * We do this by comparing record
 * ids (passed vs found)
 *------------------------------*/  

if (@dupOrCheckRecID != @clientID)
begin
  RAISERROR ('Invalid client id', 11, 1) 
end


/*-------------------------------    
 * Parse incoming patient ids
 *------------------------------*/   
       
insert into @patientIDs select * from dbo.MULTI_RECORD_ID_PARSE(@patIDsStr,',')

/*-------------------------------    
 * Get a count.  If the count is
 * 0 get out!
 *------------------------------*/   

set    @recCountCheck1 = 0
select @recCountCheck1 = COUNT(id) from @patientIDs 

if (@recCountCheck1 = 0)
begin
  RAISERROR ('Patient ids are required', 11, 1) 
end

/*-------------------------------    
 * Look for duplicate ids.  If
 * any are found, get out!
 *------------------------------*/   

set          @dupOrCheckRecID = null
select top 1 @dupOrCheckRecID = recid from @patientIDs group by recid having COUNT(id) > 1

if (@dupOrCheckRecID is not null)
begin
   RAISERROR ('One or more patients are duplicate', 11, 1) 
end

/*-------------------------------    
 * Make sure the client and 
 * patient ids are valid and the
 * association between client and
 * patient are valid
 *------------------------------*/   

set    @recCountCheck2 = 0
select @recCountCheck2 = count(pid.id) 
from @patientIDs                     as pid
join CLIENTS_Client                  as clc on  clc.CLIENT_ID  = @clientID
join PATIENTS_Client                 as pac on  pac.CLIENT_ID  = clc.CLIENT_ID
join PATIENTS_Patient                as pap on  pap.PATIENT_ID = pac.PATIENT_ID
where (pap.PATIENT_ID = pid.recid)

/*-------------------------------    
 * We do this by comparing rec
 * counts
 *------------------------------*/   

if (@recCountCheck1 != @recCountCheck2)
begin
  RAISERROR ('One or more patients are invalid', 11, 1) 
end

/*-------------------------------    
 * Make sure the practitioner and
 * client ids are valid and the
 * association between client and
 * practitioner is valid
 *------------------------------*/   
 
set          @dupOrCheckRecID = -1
select       @dupOrCheckRecID = isnull(prp.PRACTITIONER_ID,-1)
from PRACTITIONER_Practitioner       as prp
join PRACTITIONER_Client             as prc on  prc.PRACTITIONER_ID = prp.PRACTITIONER_ID
join CLIENTS_Client                  as clc on  clc.CLIENT_ID       = prc.CLIENT_ID
where (prp.PRACTITIONER_ID = @pracID) and (prc.CLIENT_ID = @clientID)

/*-------------------------------    
 * We do this by comparing record
 * ids (passed vs found)
 *------------------------------*/  

if (@dupOrCheckRecID != @pracID) RAISERROR ('Invalid practitioner', 11, 1)

/*-------------------------------    
 * We can only have 2-8 patients
 *------------------------------*/  

if (@recCountCheck1 < 2) RAISERROR ('Please enter at least 2 but no more than 8 patients', 11, 1) 
if (@recCountCheck1 > 8) RAISERROR ('Please enter at least 2 but no more than 8 patients', 11, 1) 

/*-------------------------------    
 * Look for groups that have the
 * same name 
 *------------------------------*/  

set @dupOrCheckRecID = 0

select @dupOrCheckRecID = count(id) 
from PRACTITIONER_PATIENT_TREATMENT_GROUPS
where 
  (1=1) 
  and ((@recID IS NULL) OR (id != @recID))
  and clientID = @clientID
  and pracID   = @pracID
  and name     = @name

if (@dupOrCheckRecID > 0) RAISERROR (@MsgDupRec, 11, 1) 

/*-------------------------------    
 * If this is a new record
 *------------------------------*/  

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN   
   /* Effective date and start date are the same for new records */ 
    SET @tmtEffDate = @startDate
END
ELSE
BEGIN

  /*-------------------------------    
   * Make sure that the effective
   * date does not pre-date the
   * start date or any of the
   * effective dates already used
   *------------------------------*/ 

  if ((DATEDIFF(DAY,@startDate,@tmtEffDate)) < 0) 
    RAISERROR ('The effective date cannot predate the start date', 11, 1) 

  set @dupOrCheckRecID = 0

  select 
    @dupOrCheckRecId = COUNT(id) 
  from PRACTITIONER_PATIENT_TREATMENT_GROUP_SERVICE_SCHEDULE
  where 
        treatmentGroupID = @recID
    and (effectiveDate >= @tmtEffDate)
  
  if (@dupOrCheckRecID > 0)  
    RAISERROR ('The effective date cannot predate previous effective dates', 11, 1) 

END


/*============================================================
 * Advisement validation
 *============================================================*/         

IF (@validateRec = 1) 
BEGIN
  SET @recordID = 0
  RETURN(0)    
END        

/*============================================================
 * Create or modifiy records 
 *============================================================*/   
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
        
  /*==============================    
   * New Record
   *==============================*/    
  
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN   
      
    SET @updateState = dbo.CONST_REC_STATE_NEW()
    
    /* Effective date and start date are the same for new records */
    
    SET @tmtEffDate = @startDate
    
    INSERT INTO PRACTITIONER_PATIENT_TREATMENT_GROUPS
    
      (clientID, 
       pracID, 
       name,
       description,
       startDate,
       endDate, 
       curSvcSchID,
       created,
       createdBy,
       lastUpdated,
       lastUpdatedBy,
       active)    
    VALUES        
      (@clientID, 
       @pracID, 
       @name,
       @description,
       @startDate,
       null,
       0,
       @today,          
       @userID,
       null,
       null,
       1)
 
   SET @recordID = SCOPE_IDENTITY()
                                  
 END       
  
 /*==============================    
  * Edit Record
  *==============================*/ 
 
 ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
 BEGIN    
   
   /*-------------------------------    
    * Update main record
    *------------------------------*/  
      
    SET @recordID    = @recID
    SET @updateState = dbo.CONST_REC_STATE_MOD()

    UPDATE PRACTITIONER_PATIENT_TREATMENT_GROUPS
    SET clientID      = @clientID, 
        pracID        = @pracID, 
        name          = @name,
        description   = @description,
        --startDate     = @startDate,
        lastUpdated   = @today,
        lastUpdatedBy = @userID
    WHERE id = @recordID             
 END
 ELSE
 BEGIN
   RAISERROR ('Unknown or unsupported save type', 11, 1)             
 END
 
  /*-------------------------------    
   * Create new service schedule
   * We do this for both new and
   * edits
   *------------------------------*/ 
   
   INSERT INTO PRACTITIONER_PATIENT_TREATMENT_GROUP_SERVICE_SCHEDULE    
     (treatmentGroupID,     
      effectiveDate,
      startTime,      
      numMins,      
      grpMtg1,      
      grpMtg2,
      grpMtg3,
      grpMtg4,
      grpMtg5,
      grpMtg6,
      grpMtg7,     
      patIDsStr)
      
    VALUES
    
      (@recordID,       
       @tmtEffDate,
       @startTime,
       @numMins,       
       0,
       @grpMtg2,
       @grpMtg3,
       @grpMtg4,
       @grpMtg5,
       @grpMtg6,
       0,              
       @patIDsStr)
          
   set @pracPatSvcSchRecID = SCOPE_IDENTITY()
   
   UPDATE PRACTITIONER_PATIENT_TREATMENT_GROUPS
   SET curSvcSchID = @pracPatSvcSchRecID
   WHERE id = @recordID
         
 /*-------------------------------    
  * Create audit record    
  *------------------------------*/    
       
 EXEC PRACTITIONER_PATIENT_GROUP_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
 
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

GRANT EXECUTE ON  [dbo].[PRACTITONER_PATIENT_GROUPS_Save] TO [webuser]
GO
