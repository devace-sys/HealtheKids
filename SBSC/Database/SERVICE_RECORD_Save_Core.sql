USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Save_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Save_Core] (
  @userID         BIGINT,    
  @userGroup      INT,    
  @userRank       INT,
  @generateClaims BIT,
  @entryType      INT,    
  @reference     VARCHAR(500),           
  @batchNum      NCHAR(10),    
  @papClmNum     NCHAR(35),    
  @dos           DATETIME,    
  @clientID      INT,     
  @pracID        INT,    
  @patID         INT,    
  @isIFSPorIEP   BIT,      
  @nameID        INT,  
  
  @hasOrpDocID   BIT,
  @orpDocID      BIGINT,
  @orpNPI        varchar(50),
  
  @hasSvcDetailFlags BIT,
  @svcDetFlag1       BIT,
  @svcDetFlag2       BIT,
  @svcDetFlag3       BIT,
  @svcDetFlag4       BIT,

  @startTime     TIME(0),
  @numMin        INT,    
  @trip1Start    DECIMAL(7,1),    
  @trip1End      DECIMAL(7,1),    
  @trip2Start    DECIMAL(7,1),    
  @trip2End      DECIMAL(7,1),    
  @trip3Start    DECIMAL(7,1),    
  @trip3End      DECIMAL(7,1),    
  @trip4Start    DECIMAL(7,1),    
  @trip4End      DECIMAL(7,1),
  @patAbsent     BIT,
  @pracAbsent    BIT,
  @makeupSession BIT,  
  @attendanceSelectionID int,
  @notes                            VARCHAR(max),
  @svcNotesFormBuilderQuestionsJSON varchar(max),
  @svcNotesFormBuilderAnswersJSON   varchar(max),
  @patientGoalProgressJSON          varchar(max),
  @hasPatientGoalTrackingData       bit,
  @billingProgramID                 tinyint = 1 /* Default to LEA BOP*/,
  @hasFillablePdfSelections  bit          = 0,
  @fillablePdfSelectionsJSON varchar(max) = '[]',
  @fillablePdfAnswersJSON    varchar(max) = '[]',
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
 * SERVICE_RECORD_SAVE_Core */    
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
 * @param   validateRec     Indicated record is being validated but not saved
 *                          1 = Performs data integrity validation tasks    
 *                              Perform advisory validation tasks that can    
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
    
declare @today          as datetime   -- Current date/time stamp
declare @tranOpen       as bit        -- Is a transaction open    
declare @updateState    as smallint   -- Indicates what state the record is left in    
declare @auditRecID     as BIGINT         -- Audit record id    
declare @recUserID      as BIGINT    
declare @entityID       as bigint
declare @detailMsg      AS VARCHAR(1000)

declare @tempRecID          as bigint
declare @canEdit            as bit    

declare @inputBatchID       as BIGINT
declare @inputBatchClientID as BIGINT
declare @inputBatchParentID as BIGINT

DECLARE @dupCount                 AS INT   -- Duplicate counter used for validation   
declare @validateUnits            as bit
DECLARE @recordClaim              AS BIT   -- Do we record a claim?
declare @claimGenerationDeferred  as BIT   -- Do we defer

declare @groupID                     as int  -- Practitoner group id (what discipline group)  
declare @participatesInLEABOP        as bit
declare @participatesInCYBHI         as bit
declare @participatesInRUHealth      as bit
declare @participatesInLEABOPNonSpEd as bit
declare @okToShowServicesForPlan     as bit
declare @planTypeName                as varchar(256)

declare @grpIDParent         as int
declare @pracGrpSvcClsNameID as bigint   -- Group family

declare @dob            as date       -- Patient's DOB
declare @patName        as varchar(150) = ''
declare @siteID         as int        -- Site ID (site that patient belongs to)    
declare @planType       as int        -- IFSP, IEP, etc    

declare @validSvcSel      as bit      -- Is valid service selection from screen
declare @svcType          as int
declare @svcSubType1      as int
declare @minsReq          as bit
declare @milesReq         as bit
declare @svcDetFlagsReq   as bit
declare @minUnits         as int
declare @maxUnits         as int
declare @nameIDAliasRecID as int        -- Service name ID alias record id
declare @procIsQQCode     as bit        -- Procedure is a permanent custom non billiable

DECLARE @numMiles     AS DECIMAL(7,1)    
DECLARE @numTrips     AS SMALLINT    
declare @totMinsDOS   as int

declare @orpRequired    as bit         = null
declare @orpPracID      as bigint      = null
declare @isValidMcalORP as bit         = null
declare @orpPracNPI     as varchar(50) = null
declare @viaTelehealth  as bit         = 0
declare @altNameID      as int         = null

BEGIN TRY    
   
/*============================================================
 * Init output parameters
 *============================================================*/  

SET @recordID   = 0    
SET @spDetails  = ''    
    
/*============================================================
 * Verify incoming parameters that are essential for proper op
 * Proper op = Branching logic will fail if these are not
 *             provided
 *============================================================*/  
    
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',            11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',             11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',           11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',            11, 1)    
IF (@nameID      IS NULL) RAISERROR ('Service selection required',       11, 1)
IF (@clientID    IS NULL) RAISERROR ('Client selection required',        11, 1)
IF (@pracID      IS NULL) RAISERROR ('Practitioner selection required',  11, 1)
IF (@dos         IS NULL) RAISERROR ('Service date required',            11, 1)

/*============================================================
 * Init worker variables
 *============================================================*/  
    
set @today                   = GETDATE()    
set @TranOpen                = 0    
set @numMiles                = 0    
set @numTrips                = 0    
set @detailMsg               = ''
set @recordClaim             = 1
set @validateUnits           = 1
set @claimGenerationDeferred = 0

/*============================================================
 * Set default
 *============================================================*/  

set @generateClaims             = isnull(@generateClaims,1)
set	@hasPatientGoalTrackingData = isnull(@hasPatientGoalTrackingData,0)
 
/*============================================================
 * EDIT CHECK
 *
 * If this save operation is an edit verify that the record
 * being edited exists AND that it can be edited.
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())     
begin    
      
  /*-------------------------------    
   * Get out if the recid is not
   * provided
   *------------------------------*/      

  if (@recID IS NULL) 
    RAISERROR ('updateRecID is required', 11, 1)   
  
  /*-------------------------------    
   * If the entry type IS from
   * a source that prevets the
   * edit rules then do not perform
   * the edit checks
   *------------------------------*/      

  if (@entryType in (256))
  begin
    set @canEdit  = 1
	set @recordID = @recID
  end

  /*-------------------------------    
   * Otherwise proceed with normal
   * edit check
   *------------------------------*/      

  else
  begin
  /*-------------------------------    
   * Look for record that we want
   * to edit.  
   *------------------------------*/      
     
  set @recordID = null    
  set @canEdit  = 0    
      
  select top 1
      @recordID = q0.svcRecID
    , @canEdit  = case q0.svcRecEditID 
        when -1 then 0
        else         1
      end 
  from (
    select top 1 
        sr.id as svcRecID
      , svcRecEditID = isnull(sre.id,-1) 
    from      dbo.SERVICE_RECORDS as sr
    left join dbo.SERVICE_RECORDS_VIEW_EDITABLE(  null
                                                , @userID
                                                , @userGroup
                                                , @userRank
                                                ,1) as sre on sre.id = sr.id
    where (
           (sr.id = @recID) 
      and ((sr.clientID is null) or (sr.clientID = @clientID))
    )
  ) as q0

   
  /*-------------------------------    
   * If record was not found then
   * get out.
   *------------------------------*/      

  if (@recordID is null) 
    RAISERROR (@MsgNoRec,  11, 1)         

  /*-------------------------------    
   * If record can no longer be
   * edited then get out.
   *------------------------------*/      
  
  if (@canEdit = 0)      
    RAISERROR (@MsgNoEdit, 11, 1)    
  
  end /* Not in prevetted entry */
        
end /* Edit check */   
    
/*============================================================
 * REFERENCE DOCUMENT CHECK
 *
 * If this is an SBSC user perform reference document lookup
 * EXCEPT if the entry is from the service record import
 * screen.
 *============================================================*/  

if (@userGroup = dbo.CONST_USER_GROUP_SBS()) 
begin

  /* If the entry type is not the service record import */

  if (@entryType != 116) 
  begin

    set @inputBatchID       = null
    set @inputBatchClientID = null
    set @inputBatchParentID = null
  
    select top 1 
        @inputBatchID       = ib.id 
      , @inputBatchClientID = ib.ClientID
      , @inputBatchParentID = ib.ParentBatchID
    from dbo.INPUT_BATCHES as ib 
    where 
      (ib.File_Name = @reference + '.pdf')
  
    if (@inputBatchID is null) 
      RAISERROR ('Reference document file not found in Input Batches', 11, 1)    
    
    if (@inputBatchClientID != @clientID)
      RAISERROR ('Client ID mismatch between reference file and service record', 11, 1)    

  end /* Ref doc check */
end /* Pcal user */

/*============================================================
 * Clean up optional parameters and provide default values
 *============================================================*/  
     
IF @numMin     IS NULL SET @numMin     = 0   
IF @startTime  IS NULL SET @startTime = null
IF @trip1Start IS NULL SET @trip1Start = 0    
IF @trip1End   IS NULL SET @trip1End   = 0    
IF @trip2Start IS NULL SET @trip2Start = 0    
IF @trip2End   IS NULL SET @trip2End   = 0    
IF @trip3Start IS NULL SET @trip3Start = 0    
IF @trip3End   IS NULL SET @trip3End   = 0    
IF @trip4Start IS NULL SET @trip4Start = 0    
IF @trip4End   IS NULL SET @trip4End   = 0    
IF @batchNum   IS NULL SET @batchNum  = ''    
IF @papClmNum  IS NULL SET @papClmNum = ''    

IF @patAbsent     IS NULL SET @patAbsent     = 0
If @pracAbsent    IS NULL SET @pracAbsent    = 0
IF @makeupSession IS NULL SET @makeupSession = 0

/*============================================================
 * Retrieve and validate patient data
 *============================================================*/ 
 
set @dob = null

select top 1
    @dob     = pp.DATE_OF_BIRTH
  , @patName = convert(varchar(150),(isnull(pp.LAST_NAME,'') + ' ' + isnull(pp.FIRST_NAME,N'')))
from dbo.PATIENTS_Client  as pc
join dbo.PATIENTS_Patient as pp on pp.PATIENT_ID = pc.PATIENT_ID
where (
       (pc.CLIENT_ID  = @clientID) 
   and (pc.PATIENT_ID = @patID) 
   and (pp.PATIENT_ID = @patID)
)

/*-------------------------------    
 * Patient must exist and have a
 * date of birth
 *------------------------------*/    

IF (@dob IS NULL) 
  RAISERROR ('Patient and client are not associated or patient does not have a DOB', 11, 1)     

/*============================================================
 * Update messages to reference patient name
 *============================================================*/ 

set @MsgFutureDOS    = @patName + ' - Date of service cannot be in the future'
set @MsgPatDOBGteDOS = @patName + ' - ' + @MsgPatDOBGteDOS
set @msgMinReq       = @patName + ' - ' + @msgMinReq
set @MsgMinDef       = @patName + ' - ' + @MsgMinDef
set @msgDupRec       = @patName + ' - ' + 'A duplicate or equivalent service record has been recorded already by you or someone else.'
set @MsgMilReq       = @patName + ' - ' + @msgMilReq

/*============================================================
 * Validate date of service (DOS)
 *============================================================*/ 

if ((DATEDIFF(day,@dos,@today)) < 0) 
begin 
  RAISERROR (@MsgFutureDOS, 11, 1)  
end
  
/*-------------------------------    
 * Date of birth cannot be on or
 * after the date of service
 *------------------------------*/    
  
if ((DATEDIFF(day,@dob,@dos)) <= 0)
begin 
  RAISERROR (@MsgPatDOBGteDOS, 11, 1)     
end

/*============================================================
 * Retrieve and validate practitioner data
 *============================================================*/ 

set @groupID  = null

select top 1  

    @groupID                     = gg.GROUP_ID
  , @participatesInLEABOP        = pp.participatesInLEABOP
  , @participatesInCYBHI         = pp.participatesInCYBHI
  , @participatesInRUHealth      = pp.participatesInRUHealth
  , @participatesInLEABOPNonSpEd = pp.participatesInLEABOPNonSpEd

from dbo.PRACTITIONER_Client       as pc
join dbo.PRACTITIONER_Practitioner as pp on  pp.PRACTITIONER_ID = pc.PRACTITIONER_ID
join dbo.PRACTITIONER_GROUPS       as pg on  pg.PRACTITIONER_ID = pp.PRACTITIONER_ID
                                         and pg.GROUP_TYPE in (1,2)
join dbo.GROUP_Group               as gg on  gg.GROUP_ID = pg.GROUP_ID
                                         and gg.GROUP_TYPE in (1,2)
where (
      (pc.CLIENT_ID       = @clientID) 
  and (pc.PRACTITIONER_ID = @pracID) 
  and (pp.PRACTITIONER_ID = @pracID)
)

/*-------------------------------    
 * Practitioner must exist and
 * have an allied disp group 
 *------------------------------*/    

if (@groupID is null) 
  RAISERROR ('Practitioner and client are not associated or practitioner does not have an allied discipline group', 11, 1)

/*============================================================
 * Retrieve group family (using common grouping partition)
 *============================================================*/ 

select top 1
  @pracGrpSvcClsNameID = png.GROUP_SERVICE_CLASS_NAME_ID 
from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png
where (
      (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
  and (png.GROUP_SERVICE_CLASS_NAME_ID is not null) /* For index */
  and (png.GROUP_ID = @groupID)
)

  
/*-------------------------------    
 * Retrieve patients site as of    
 * the date of service.   
 * Store it for later use. 
 *------------------------------*/    
       
set @siteID = dbo.PAT_SITE_ON_DOS(@dos,@clientID,@patID)     

/*-------------------------------    
 * Determine patients plan type
 * Store it for later use. 
 *------------------------------*/    

set @planType = dbo.DOS_DOB_IEP_BILLING_PROGRAM_TO_PLAN_TYPE (@dos,@dob,@isIFSPorIEP,@billingProgramID)

/*============================================================
 * Validate service selection 
 *============================================================*/ 

set @validSvcSel      = null
set @nameIDAliasRecID = null
set @procIsQQCode     = 0

select top 1 

    @validSvcSel      = isnull (sva.PROCEDURE_IS_SERVICE_SELECTION, 0)
  , @svcType          = sva.SERVICE_TYPE_ID
  , @svcSubType1      = sva.SERVICE_SUB_TYPE_1_ID
  , @nameIDAliasRecID = sva.SERVICE_NAME_ALIAS_RECORD_ID
  , @procIsQQCode     = sva.PROCEDURE_CODE_IS_QQ
  , @minUnits         = sva.PROCEDURE_MIN_UNITS
  , @maxUnits         = sva.PROCEDURE_MAX_UNITS
  , @minsReq          = sva.SERVICE_ENTRY_MINUTES_REQUIRED
  , @milesReq         = sva.SERVICE_ENTRY_MILES_REQUIRED
  , @svcDetFlagsReq   = sva.SERVICE_ENTRY_SVC_DETAIL_FLAGS_REQUIRED
  , @viaTelehealth    = sva.SERVICE_IS_VIA_TELEHEALTH
  , @altNameID        = sva.SERVICE_NAME_ID_ALT_MODALITY
  , @planTypeName     = sva.SERVICE_PLAN_TYPE
from dbo.SERVICES_VIEW_ALL_CORE (
  
    @clientID
  , @groupID
  , @planType /* Plan type */
  , null
  , @nameID   /* Service selected */
  , 1         /* In allowed procs */
  , 1         /* Active procs only */
  , @dos      /* Effective for given DOS*/
  , 1         /* Selection only*/
) as sva

IF (@validSvcSel is null) 
begin
  set @detailMsg = @patName + ' - Service selection not found'
  RAISERROR (@detailMsg, 11, 1)      
end

IF (@validSvcSel = 0)     
begin
  set @detailMsg = @patName + ' - Invalid service selection'
  RAISERROR (@detailMsg, 11, 1)        
end

/*============================================================
 * Determine if prac can record for this type of plan
 * Note: Will raise advisement vaidation later if this is not
 * the case.
 *============================================================*/ 

set @okToShowServicesForPlan = dbo.SERVICES_CAN_SHOW_FOR_PLAN_TYPE (@planType,@participatesInLEABOP,@participatesInLEABOPNonSpEd,@participatesInCYBHI, @participatesInRUHealth)
 
/*============================================================
 * Validate absent flags passed for invalid combos
 *============================================================*/ 

if not exists (select * from dbo.SERVICE_RECORD_ATTENDANCE_FLAGS_TO_SELECTION_ID_AND_NAME (  @patAbsent, @pracAbsent, @makeupSession))
begin
  RAISERROR ('Invalid combination of attendance flags', 11, 1)
end

/*============================================================
 * Lookup value for attendance selection based on attendance
 * flags if the value is not provided.  This is for backwards
 * compatibility with service record sources that do not pass
 * or use the attendance selection but only pass attendance
 * flags.
 *============================================================*/ 

if (@attendanceSelectionID IS NULL)
begin
  select top 1 
    @attendanceSelectionID = sras.id 
  from dbo.SERVICE_RECORD_ATTENDANCE_SELECTIONS as sras
  where  (
        (sras.makeupSession                = @makeupSession)
    and (sras.pracAbsent                   = @pracAbsent)
    and (sras.patAbsent                    = @patAbsent)
    and (sras.attendanceFlagsSelectionXref = 1)
  )
end

/*============================================================
 * Set exceptions for recording claims
 *============================================================*/ 

/*-------------------------------    
 * If billing program is 
 * CYBHI (TODO: This is temp
 * remove when we can claim)
 *------------------------------*/    

/*if (@billingProgramID = 2)
begin
  set @generateClaims = 0
end
*/

/*-------------------------------    
 * If billing program is 
 * RU HEalth (TODO: This is temp
 * remove when we can claim)
 *------------------------------*/    

if (@billingProgramID = 3)
begin
  set @generateClaims = 0
end

/*-------------------------------    
 * If generate claims flag is
 * false
 *------------------------------*/    

if (@generateClaims = 0)
begin
  set @recordClaim    = 0 
  set @validateUnits  = 0
  set @minsReq        = 0
  set @milesReq       = 0
  set @svcDetFlagsReq = 0
end

/*-------------------------------    
 * Patient is absent
 *------------------------------*/    

if (@patAbsent = 1)
begin
  set @recordClaim    = 0 
  set @validateUnits  = 0
  set @minsReq        = 0
  set @milesReq       = 0
  set @svcDetFlagsReq = 0
end

/*-------------------------------    
 * Practitioner is absent
 *------------------------------*/    

if (@pracAbsent = 1)
begin
  set @recordClaim    = 0 
  set @validateUnits  = 0
  set @minsReq        = 0
  set @milesReq       = 0
  set @svcDetFlagsReq = 0
end

/*-------------------------------    
 * If the procedure is a QQ code
 * this is a permanent non-billable
 * custom procedure and we do not
 * want to create a claim record.
 *------------------------------*/  

if (@procIsQQCode = 1)
begin
  set @recordClaim = 0
end

/*============================================================
 * RMTS moment reporting
 * Check to see if time has been passed
 * TODO: Refactor this to use meta data approach we are using
 * for minutes or miles required.
 *============================================================*/ 

if ((@svcType = 5) and (@svcSubType1 = 5001))
begin
  set @detailMsg = @patName + ' - Time entry is required for RMTS moment reporting'
  if (@startTime is null) RAISERROR (@detailMsg, 11, 1)
end

/*============================================================
 * Unit validation
 *============================================================*/  

if (@validateUnits = 1)
begin
  
  /*-------------------------------    
   * Minutes
   *------------------------------*/    

  if (@minsReq = 1)
  begin 
  
    if (@numMin <= 0) 
      RAISERROR (@msgMinReq, 11, 1)

  end

  /*-------------------------------    
   * Miles
   *------------------------------*/    

  if (@milesReq = 1)
  begin

    set @numTrips = dbo.CALC_TOTAL_TRIPS_8(@trip1Start,@trip1End,@trip2Start,@trip2End,@trip3Start,@trip3End,@trip4Start,@trip4End)    
    set @numMiles = dbo.CALC_TOTAL_MILES_8(@trip1Start,@trip1End,@trip2Start,@trip2End,@trip3Start,@trip3End,@trip4Start,@trip4End)    
        
    if (@numTrips = 0) 
	begin
      RAISERROR (@msgMilReq, 11, 1)    
	end

  end
  
  /*-------------------------------    
   * Service detail flags
   *------------------------------*/    

  if (@svcDetFlagsReq = 1)
  begin
    if ((@svcDetFlag1 is null) or (@svcDetFlag2 is null) or (@svcDetFlag3 is null) or (@svcDetFlag4 is null))
	begin
      set @detailMsg = @patName + ' - Please answer ALL of the YES/NO questions regarding this service'
	  RAISERROR (@detailMsg, 11, 1)    
    end
  end

end /* Validate units */

/*============================================================
 * Get ORP Data if applicable
 *============================================================*/  

select top 1  

   @orpRequired     = OrpRequired 
  ,@orpPracID       = PracID
  ,@orpPracNPI      = NpiNumber
  ,@isValidMcalORP  = IsValidMcalOrp
  ,@orpDocID        = OrpDocumentID
  
from dbo.GET_ORP_PRAC_NPI_DATA (   @procIsQQCode
                                 , @svcType
                                 , @dos
                                 , @clientID
                                 , @groupID 
                                 , @orpDocID
                                 , @patID
								 , @billingProgramID ) 

/*============================================================
 * Enforce the selection of an order or prescription if 
 * the service:
 *
 * -> requires an ORP document (treatments after 7/1/2018)
 * -> will have claims recorded (patient not absent, etc.)
 * -> is provided by a practitioner (rendering practitioner) in
 *    the health services group family as the family is 
 *    defined for ORP groups
 * -> is from a screen where treatments are recorded for 
 *    a single patient
 *============================================================*/  

if ((@orpRequired = 1) and (@recordClaim  = 1))
begin

  /* Get ORP service class name ID from rendering practitioners group id. */

  declare @rdrGroupSvcClassNameID as bigint 
  set @rdrGroupSvcClassNameID = dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_GROUP_ID(@groupID)
   
  /* If rendering practitioner group is classified as health services and no order/prescription
     has been selected and this is not a screen that we have made an exception for
     then get out. */
   
  if ((@rdrGroupSvcClassNameID = 3) and (@orpDocID is null) and (@entryType not in (5,11,20,50,64)))
  begin     
    set @detailMsg = @patName + ' - The selection of an order or prescription is required'
    RAISERROR (@detailMsg, 11, 1)
  end         
end
 
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

if (@validateRec = 1)    
begin    
   
   

   if (@okToShowServicesForPlan = 0)
   begin
     declare @planSelectionMsg as varchar(512) = ''
	 set @planSelectionMsg =   @patName + ' - You have selected ' + @planTypeName + ' as the service plan.  This plan is currently/no longer not authorized for this practitioner.'

     set @spDetails = dbo.UPDATE_DETAILS(@spDetails, @planSelectionMsg, dbo.CONST_RET_WARN())     
   end

  /*============================================================
   * Warn user about selecting absent option
   *============================================================*/ 

  if (@attendanceSelectionID != 0) /* Not a regular session */
  begin    

	/* Get selection name */

    declare @attendanceSelectionName as varchar(256) = ''
	declare @attendanceSelectionMsg  as varchar(512) = ''

    select top 1 
      @attendanceSelectionName = isnull(sras.[name],'') 
    from dbo.SERVICE_RECORD_ATTENDANCE_SELECTIONS as sras
    where 
      (sras.id = @attendanceSelectionID)
    
	set @attendanceSelectionMsg =  @patName + ' - You have selected ' + @attendanceSelectionName + ' as the attendance option.'

	set @spDetails = dbo.UPDATE_DETAILS(@spDetails, @attendanceSelectionMsg, dbo.CONST_RET_WARN())     
  
  end

  /*-------------------------------    
   * Duplicate record check
   *------------------------------*/      

  set @dupCount = 0    
  
  /*
  select 
    @dupCount = COUNT(id)
  from
    dbo.SERVICE_RECORDS
  where    
    (1=1)                        AND    
    ((@recID IS NULL)            OR    
    (id != @recID))              AND     
    (svcType     = @svcType)     AND     
    (dos         = @dos)         AND     
    (clientID    = @clientID)    AND     
    (patID       = @patID)       AND
    (isIFSPorIEP = @isIFSPorIEP) AND     
    (nameID      = @nameID)      AND     
    (state      != dbo.CONST_SVC_REC_STATE_DEL()) AND
    (state      != dbo.CONST_SVC_REC_STATE_CIF()) 
	*/
	
    select 
	  @dupCount = count(srvrec.id) 
	from dbo.SERVICE_RECORD_VIEW_REDUNDANT_ENTRIES_CORE (
	    @clientID 
	  , @patID
      , @pracGrpSvcClsNameID
	  , @svcType
	  , @nameID
	  , @altNameID
	  , @dos
	  , @startTime
	  , @recID ) as srvrec

  /*-------------------------------    
   * Additional checks
   * for transportation to refine
   * and possible redefine dup
   * count.
   *
   * Note: Since ALL transportation
   * is held and possibly proxied
   * since 11/21/2015 we need to
   * peform this additional dup
   * check.
   *------------------------------*/    
   
  if ((@svcType = dbo.CONST_SERVICES_TRANSPORT()) and (@dupCount > 0 ))    
  begin  
    
    select
      @dupCount = count(id)
    from
    (
      select
       id,       
       /* Sum # of slot issues */
       [NumIssues] = trip1Issue + trip2Issue + trip3Issue + trip4Issue
      from
      (
        select 
         id,       
         /* A trip "slot" will have a duplicate issue if the slot for trip already Recorded and trip being
           submitted both have miles (miles > 0) */      
         [trip1Issue] = case
           when (trip1MilesRecordedHasMiles = 0) and (trip1MilesSubmittedHasMiles = 0) then 0
           when (trip1MilesRecordedHasMiles = 1) and (trip1MilesSubmittedHasMiles = 0) then 0
           when (trip1MilesRecordedHasMiles = 0) and (trip1MilesSubmittedHasMiles = 1) then 0
           when (trip1MilesRecordedHasMiles = 1) and (trip1MilesSubmittedHasMiles = 1) then 1
         end,

         [trip2Issue] = case
           when (trip2MilesRecordedHasMiles = 0) and (trip2MilesSubmittedHasMiles = 0) then 0
           when (trip2MilesRecordedHasMiles = 1) and (trip2MilesSubmittedHasMiles = 0) then 0
           when (trip2MilesRecordedHasMiles = 0) and (trip2MilesSubmittedHasMiles = 1) then 0
           when (trip2MilesRecordedHasMiles = 1) and (trip2MilesSubmittedHasMiles = 1) then 1
         end,

         [trip3Issue] = case
           when (trip3MilesRecordedHasMiles = 0) and (trip3MilesSubmittedHasMiles = 0) then 0
           when (trip3MilesRecordedHasMiles = 1) and (trip3MilesSubmittedHasMiles = 0) then 0
           when (trip3MilesRecordedHasMiles = 0) and (trip3MilesSubmittedHasMiles = 1) then 0
           when (trip3MilesRecordedHasMiles = 1) and (trip3MilesSubmittedHasMiles = 1) then 1
         end,

       [trip4Issue] = case
          when (trip4MilesRecordedHasMiles = 0) and (trip4MilesSubmittedHasMiles = 0) then 0
          when (trip4MilesRecordedHasMiles = 1) and (trip4MilesSubmittedHasMiles = 0) then 0
          when (trip4MilesRecordedHasMiles = 0) and (trip4MilesSubmittedHasMiles = 1) then 0
          when (trip4MilesRecordedHasMiles = 1) and (trip4MilesSubmittedHasMiles = 1) then 1
        end
      from
      (    
        select  
    
          id,
        
          /* Determine if trip "slots" recorded already and trip "slots" submitted have miles */
        
          [trip1MilesRecordedHasMiles]  = case when trip1MilesRecorded  > 0  then 1 else 0 end,
          [trip1MilesSubmittedHasMiles] = case when trip1MilesSubmitted > 0  then 1 else 0 end,  
        
          [trip2MilesRecordedHasMiles]  = case when trip2MilesRecorded  > 0  then 1 else 0 end,
          [trip2MilesSubmittedHasMiles] = case when trip2MilesSubmitted > 0  then 1 else 0 end,
        
          [trip3MilesRecordedHasMiles]  = case when trip3MilesRecorded  > 0  then 1 else 0 end,
          [trip3MilesSubmittedHasMiles] = case when trip3MilesSubmitted > 0  then 1 else 0 end,
        
          [trip4MilesRecordedHasMiles]  = case when trip4MilesRecorded  > 0  then 1 else 0 end,
          [trip4MilesSubmittedHasMiles] = case when trip4MilesSubmitted > 0  then 1 else 0 end    
        from
        (
          select
    
            id,

            /* Calculate total miles recorded in each trip "slot" for records already recorded and this submission */

            [trip1MilesRecorded]  = dbo.CALC_TRIP_MILES(trip1Start,  trip1End),
            [trip1MilesSubmitted] = dbo.CALC_TRIP_MILES(@trip1Start, @trip1End),

            [trip2MilesRecorded]  = dbo.CALC_TRIP_MILES(trip2Start,  trip2End),
            [trip2MilesSubmitted] = dbo.CALC_TRIP_MILES(@trip2Start, @trip2End),

            [trip3MilesRecorded]  = dbo.CALC_TRIP_MILES(trip3Start,  trip3End),
            [trip3MilesSubmitted] = dbo.CALC_TRIP_MILES(@trip3Start, @trip3End),

            [trip4MilesRecorded]  = dbo.CALC_TRIP_MILES(trip4Start,  trip4End),
            [trip4MilesSubmitted] = dbo.CALC_TRIP_MILES(@trip4Start, @trip4End)

          from dbo.SERVICE_RECORDS as srt1
          where
            (1=1)                        and
            ((@recID IS NULL)            or   
            (srt1.id != @recID))         and
            (srt1.svcType     = dbo.CONST_SERVICES_TRANSPORT()) AND     
            (srt1.dos         = @dos)         AND     
            (srt1.clientID    = @clientID)    AND     
            (srt1.patID       = @patID)       AND
            (srt1.isIFSPorIEP = @isIFSPorIEP) AND     
            (srt1.nameID      = @nameID)      AND           
            (srt1.[state]    != dbo.CONST_SVC_REC_STATE_DEL()) AND
            (srt1.[state]    != dbo.CONST_SVC_REC_STATE_CIF())
          ) as srt2
        ) as srt3
      ) as srt4
    ) as srt5
    where (numIssues > 0)
  end
  
  /*-------------------------------    
   * Let user know if there are dups
   *------------------------------*/ 
   
  if (@dupCount > 0) 
  begin
  	set @detailMsg = @msgDupRec + ' (' + CONVERT(VARCHAR(10),@dupCount) + 'x)'
    set @spDetails = dbo.UPDATE_DETAILS(@spDetails,@detailMsg,dbo.CONST_RET_DUP_RECORD())
  end
          
  /*-------------------------------    
   * Perform additional unit 
   * validation
   *------------------------------*/
  
  if (@validateUnits = 1)
  begin
  
    /*-------------------------------    
     * All NON MILE based services
     *------------------------------*/
    
    if (@svcType <> dbo.CONST_SERVICES_TRANSPORT())    
    begin 
      
      /*-------------------------------    
       * If the max number of units
       * for a claim is not 1 then
       * we need a minimum number of
       * minutes
       *------------------------------*/     

      if (@maxUnits <> 1)     
        if (@numMin < dbo.CONST_MIN_RND()) 
          set @spDetails = dbo.UPDATE_DETAILS(@spDetails,@MsgMinDef,dbo.CONST_RET_WARN())                            
      
      /*-------------------------------    
       * If the service requires 
       * minutes
       *------------------------------*/  

      if (@minsReq = 1)
      begin

        /*-------------------------------    
         * Get rendering pracs disp group
         * parent.  We use this to determine
         * max minute warnings.
         *------------------------------*/  
        
        set @grpIDParent = dbo.GROUP_FIND_PARENT(@groupID)
        
        /*-------------------------------    
         * Warnings for JUST health aides 
         *------------------------------*/  
     
        if (@grpIDParent = dbo.CONST_PARENT_GROUP_ID_HEALTH_AID())
        begin
     
          /*-------------------------------    
           * Warn if the number of minutes
           * for this service exceeds
           * 8 hours.
           *------------------------------*/  
       
          if (@numMin > dbo.CONST_MAX_SVC_MIN_HA())
          begin
            set @detailMsg = @patName + ' - ' + dbo.STRING_CREATE(dbo.CONST_MSG_SVC_MAX_MINS_REACHED(),'8',NULL,NULL)
            set @spDetails = dbo.UPDATE_DETAILS(@spDetails, @detailMsg, dbo.CONST_RET_WARN())          
          end
     
        end  /* JUST HA */
        else

        /*-------------------------------    
         * Warnings for everyone BUT
         * health aides
         *------------------------------*/  
        
        begin

          /*-------------------------------    
           * Warn if the number of minutes
           * for this service exceeds
           * 2 hours.
           *------------------------------*/  
       
          if (@numMin > dbo.CONST_MAX_SVC_MIN())
          begin
            set @detailMsg = @patName + ' - ' + dbo.STRING_CREATE(dbo.CONST_MSG_SVC_MAX_MINS_REACHED(),'2',NULL,NULL)
            set @spDetails = dbo.UPDATE_DETAILS(@spDetails, @detailMsg, dbo.CONST_RET_WARN())          
          end
        
          /*-------------------------------    
           * Compute cummulative # of minutes
           * recorded for this practitioner
           * on this date of service
           * including the # of minutes
           * just entered.  
           *
           * In the case of
           * edits we exclude the record
           * being edited from the
           * calculation.
           *------------------------------*/  
     
          set @totMinsDOS = 0
     
          select
            @totMinsDOS = sum(t1.numMins)
          from
            dbo.SERVICE_RECORDS as t1
          where (
                
				/* Uses index [CLIENT_PRAC_PAT_DOS_CREATED_ID_W_EXTRA_COLS] */
               
			    ((t1.clientID = @clientID)			
            and (t1.pracID    = @pracID)          
			and (t1.patID     = @patID)
			and (t1.dos       = @dos)
			and (t1.created is not null)
			and (t1.userID  is not null)
            and (t1.id      is not null))

            and ((@recID is null) or (t1.id != @recID))
			and (t1.[state] not in (99,199))            		
          )                
          set @totMinsDOS = @totMinsDOS + @numMin
     
          /*-------------------------------    
           * If the number of minutes
           * exceeds the daily limit for
           * the given dos warn the user
           *------------------------------*/
           
          if (@totMinsDOS > dbo.CONST_MAX_DAILY_PRAC_MIN())        
          begin
            set @detailMsg = @patName + ' - ' + dbo.STRING_CREATE(dbo.CONST_MSG_PRAC_MAX_DAILY_MINS_REACHED(), dbo.RPT_DATE_FMT(@dos),NULL,NULL)
            set @spDetails = dbo.UPDATE_DETAILS(@spDetails, @detailMsg, dbo.CONST_RET_WARN())          
          end
      
        end /* All EXCEPT HA */
        
      end /* Minutes required */
    
    end /* Non transportation */

    /*-------------------------------    
     * All Mile based services
     *------------------------------*/  

    else
    begin
      
      /*-----------------------------    
       * Generate warnings if any of 
       * the trips exceed 75 miles
       *------------------------------*/  
      
      if ((dbo.CALC_TRIP_MILES(@trip1Start, @trip1End) > dbo.CONST_MAX_TRIP_ONE_WAY_MILES()) OR
          (dbo.CALC_TRIP_MILES(@trip2Start, @trip2End) > dbo.CONST_MAX_TRIP_ONE_WAY_MILES()) OR
          (dbo.CALC_TRIP_MILES(@trip3Start, @trip3End) > dbo.CONST_MAX_TRIP_ONE_WAY_MILES()) OR
          (dbo.CALC_TRIP_MILES(@trip4Start, @trip4End) > dbo.CONST_MAX_TRIP_ONE_WAY_MILES()))
      begin
	    set @detailMsg = @patName + ' - ' + dbo.CONST_MSG_ONE_WAY_TRIP_MILES_EXCEEDED()
        set @spDetails = dbo.UPDATE_DETAILS(@spDetails, @detailMsg, dbo.CONST_RET_WARN())  
      end
    
    end -- Mile based svc
  
  end -- Unit validation
  
  /*-------------------------------    
   * Since we are providing 
   * advisement validation, get out    
   *------------------------------*/    
   
  return (0)  
 
end -- Advise validate
      
declare @fbdRecID as bigint = null
	   
/*============================================================
 * Create new service record and additional records based on
 * who is recording 
 *============================================================*/     

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
begin    

  /*-------------------------------    
   * Set appropriate update state
   *------------------------------*/    

  set @updateState = dbo.CONST_SVC_REC_STATE_NEW()    
  
  /*-------------------------------    
   * Create new service record
   *------------------------------*/    

  insert into dbo.SERVICE_RECORDS (
    userID,     
    reference,     
    svcType,     
    dos,     
    clientID,     
    siteID,     
    pracID,
    groupID,     
    patID,     
    isIFSPorIEP,     
    planType,     
    nameID, 
    orpRequired,
    orpPracID,
    orpPracNPI,
    orpValidMcalOrp,    
    hasOrpDocID,
    orpDocID,
    
    hasSvcDetFlags,
    svcDetFlag1,
    svcDetFlag2,
    svcDetFlag3,
    svcDetFlag4,
    nameIDAliasID,
    startTime,     
    numMins,     
    trip1Start,     
    trip1End,     
    trip2Start,     
    trip2End,     
    trip3Start,     
    trip3End,     
    trip4Start,     
    trip4End,
    patAbsent,     
	pracAbsent,
	makeupSession,
	attendanceSelectionID,
    created,     
    lastmodified,     
    notes,     
    state,
    claimGenerationDeferred,
    entryType,
	svcSubType1,
	pracGrpSvcClsNameID,
	generateClaimsForThisSvcRec,
	viaTelehealth,
	hasPatientGoalTrackingData,
	billingProgramID  
  )
  values (
    @UserID,     
    @reference,     
    @svcType ,     
    @dos,     
    @clientID,     
    @siteID,     
    @pracID,    
    @groupID,     
    @patID,     
    @isIFSPorIEP,     
    @planType,     
    @nameID,
    @orpRequired,
    @orpPracID,
    @orpPracNPI,
    @isValidMcalORP,  
    @hasOrpDocID,
    @orpDocID,        
    @hasSvcDetailFlags,
    @svcDetFlag1,
    @svcDetFlag2,
    @svcDetFlag3,
    @svcDetFlag4,
    @nameIDAliasRecID,     
    @startTime,
    @numMin,     
    @Trip1Start,     
    @Trip1End,     
    @Trip2Start,     
    @Trip2End, 
    @Trip3Start,     
    @Trip3End,     
    @Trip4Start,     
    @Trip4End, 
    @patAbsent,    
	@pracAbsent,
	@makeupSession,
	@attendanceSelectionID,
    @today,     
    @today,     
    @notes,     
    @updateState,
    @claimGenerationDeferred,
    @entryType,
	@svcSubType1,
	@pracGrpSvcClsNameID,
	@recordClaim,
	@viaTelehealth,
	@hasPatientGoalTrackingData,
	@billingProgramID
  )   
  
  /*-------------------------------    
   * Get new service record id
   *------------------------------*/    

  set @recordID = SCOPE_IDENTITY()    
  

  /*-------------------------------    
   * Additonal record keeping 
   * SPECIFIC to new service
   * records FOR CLIENTS only
   *------------------------------*/    

  if (@userGroup = dbo.CONST_USER_GROUP_CLIENT())
  begin
    
    /*-------------------------------    
     * Create new service record 
     * review/approval record if
     * applicable.  Applicable test
     * is performed inside sproc 
     * called
     *------------------------------*/        
 
    exec SERVICE_RECORDS_APPROVAL_CREATE_NEW_FROM_SERVICE_RECORD @userID, 
                                                                 @userGroup, 
                                                                 @userRank, 
                                                                 @clientID,
                                                                 @recordClaim,
                                                                 @groupID,
                                                                 @recordID,
                                                                 @entryType, 
                                                                 @saveType, 
                                                                 @validateRec 

  
    /*-------------------------------    
     * Create new formatted note
     * record if applicable.  
     * Applicable test is performed 
     * inside sproc called
     *------------------------------*/        

    exec SVCNOTES_CREATE_NOTE_FROM_SERVICE_RECORD @userID, 
                                                  @userGroup, 
                                                  @userRank, 
                                                  @recordID,
                                                  @entryType, 
                                                  @saveType, 
                                                  @validateRec 

    /*-------------------------------    
     * Enforce null values for no
     * patient progress goals
     *------------------------------*/        

   if ( trim(isnull(@patientGoalProgressJSON,'')) = '') set @patientGoalProgressJSON = null

   /*-------------------------------    
    * Create new record to hold
    * form builder data 
	*
    * NOTE: We are using this just
	* for client entered service note
	* questions and answers but we can
	* add additional columns to this
	* to track other data
    *------------------------------*/  
  
   insert into dbo.SERVICE_RECORDS_FORM_BUILDER_DATA (
      svcRecID
	, svcNotesFormBuilderQuestionsJSON
	, svcNotesFormBuilderAnswersJSON
	, patientGoalProgressJSON
    , svcNotesFormBuilderTextSaved
    , patientGoalProgressTextSaved
	, svcNotesPrivateFormBuilderTextSaved
	, hasFillablePdfSelections 
    , fillablePdfSelectionsJSON
    , fillablePdfAnswersJSON   
  )
  values (
      @recordID
	, @svcNotesFormBuilderQuestionsJSON
	, @svcNotesFormBuilderAnswersJSON
	, @patientGoalProgressJSON
	, dbo.FORM_BUILDER_JSON_QA_DATA_TO_TEXT (  @svcNotesFormBuilderQuestionsJSON
	                                          , @svcNotesFormBuilderAnswersJSON
											  , 1
											  , 0
											  , 1
											  , 0 
											  , 1
											  , 0)
    , dbo.PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON_TO_TEXT (@patientGoalProgressJSON)
	, dbo.FORM_BUILDER_JSON_QA_DATA_TO_TEXT (  @svcNotesFormBuilderQuestionsJSON
	                                          , @svcNotesFormBuilderAnswersJSON
											  , 1
											  , 0
											  , 1
											  , 0 
											  , 1
											  , 1)
    , @hasFillablePdfSelections        
    , @fillablePdfSelectionsJSON 
    , @fillablePdfAnswersJSON    
  )
  
  end /* Client additional recs*/
end /* New */    

/*-------------------------------    
 * Edit service record    
 *------------------------------*/    

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
begin    
           
   declare @noteID      as bigint
   declare @prevSvcType as int
   
   /*============================================================
    * Get the noteID of the formatted note associated with this
    * service record (if any) and get the previous service type
    * of this service record.
    *============================================================*/    

   select  top 1 @noteID      = svcNoteID from dbo.SvcNote_SvcRec  where svcRecID  = @recordID
   select  top 1 @prevSvcType = svcType   from dbo.SERVICE_RECORDS where id        = @recordID
   

   /*============================================================
    * Update the service record
    *============================================================*/     
    
   SET @updateState = dbo.CONST_SVC_REC_STATE_MOD()        
      
   update dbo.SERVICE_RECORDS     
   set     
     reference       = @reference,    
     svcType         = @svcType,     
     dos             = @dos,     
     clientID        = @clientID,    
     siteID          = @siteID,      
     pracID          = @pracID,
     groupID         = @groupID,    
     patID           = @patID,     
     isIFSPorIEP     = @isIFSPorIEP,     
     planType        = @planType,    
     nameID          = @nameID,     

     orpRequired     = @orpRequired,
     orpPracID       = @orpPracID,
     orpPracNPI      = @orpPracNPI,
     orpValidMcalOrp = @isValidMcalORP,
     hasOrpDocID     = @hasOrpDocID,
     orpDocID        = @orpDocID,
     
     hasSvcDetFlags  = @hasSvcDetailFlags,
     svcDetFlag1     = @svcDetFlag1,
     svcDetFlag2     = @svcDetFlag2,
     svcDetFlag3     = @svcDetFlag3,
     svcDetFlag4     = @svcDetFlag4,
     nameIDAliasID   = @nameIDAliasRecID,
     startTime       = @startTime,      
     numMins         = @numMin,     
     trip1Start      = @trip1Start,     
     trip1End        = @trip1End,     
     trip2Start      = @trip2Start,     
     trip2End        = @trip2End,     
     trip3Start      = @trip3Start,    
     trip3End        = @trip3End,     
     trip4Start      = @trip4Start,    
     trip4End        = @trip4End, 
     patAbsent       = @patAbsent,    
	 pracAbsent      = @pracAbsent,
	 makeupSession   = @makeupSession,
	 attendanceSelectionID = @attendanceSelectionID,
     notes           = @notes,      
     lastmodified    = @today,    
     state           = @updateState,
     claimGenerationDeferred      = @claimGenerationDeferred,
	 svcSubType1                  = @svcSubType1,
	 pracGrpSvcClsNameID          = @pracGrpSvcClsNameID,
	 generateClaimsForThisSvcRec  = @recordClaim,
	 viaTelehealth                = @viaTelehealth,
	 hasPatientGoalTrackingData   = @hasPatientGoalTrackingData,
     billingProgramID             = @billingProgramID
   where (id = @recordID)    
      
   /*============================================================
    * Replace approval record if neccessary
    *============================================================*/    
   
   if (@userGroup = dbo.CONST_USER_GROUP_CLIENT())
   begin
   
     exec SERVICE_RECORDS_APPROVAL_DELETE_EXISTING_RELATED_TO_SERVICE_RECORD @userID, 
                                                                             @userGroup, 
                                                                             @userRank,
                                                                             @recordID
     
     exec SERVICE_RECORDS_APPROVAL_CREATE_NEW_FROM_SERVICE_RECORD @userID, 
                                                                  @userGroup, 
                                                                  @userRank, 
                                                                  @clientID,
                                                                  @recordClaim,
                                                                  @groupID,
                                                                  @recordID,
                                                                  @entryType, 
                                                                  @saveType, 
                                                                  @validateRec 
   end
   
   /*============================================================
    * If the service type changes AND a formatted note exists we
    * need to permanentely delete (purge) the old note and create
    * a new one for the user to fill out
    *============================================================*/    
    
   if ((@svcType != @prevSvcType) and (@noteID is not null) and (@userGroup = dbo.CONST_USER_GROUP_CLIENT()))  
   begin
   
     /*============================================================
      * Delete the old note permanently (purge)
      *============================================================*/    

     exec SVCNOTES_DELETE_NOTE @userID, @userGroup, @userRank, @noteID, @today, 1
   
     /*============================================================
      * Create new guided note if applicable
      * Note: If applicable is determined inside the sproc
      *============================================================*/    

     exec SVCNOTES_CREATE_NOTE_FROM_SERVICE_RECORD @userID, 
                                                   @userGroup, 
                                                   @userRank, 
                                                   @recordID,
                                                   @entryType, 
                                                   @saveType, 
                                                   @validateRec 

  
   end

   /*-------------------------------    
    * Manage form builder data 
	*
    * NOTE: We are using this just
	* for client entered service note
	* questions and answers but we can
	* add additional columns to this
	* to track other data
    *------------------------------*/  

   if (@userGroup = dbo.CONST_USER_GROUP_CLIENT())  
   begin
     
	 select top 1  
	    @fbdRecID                         =  srfbd.id
	 from dbo.SERVICE_RECORDS_FORM_BUILDER_DATA as srfbd
	 where (srfbd.svcRecID = @recordID)
	 
	 /* Only edit existing data */

	 if (@fbdRecID is not null)
	 begin
	   /* Then edit */
       update dbo.SERVICE_RECORDS_FORM_BUILDER_DATA 
       set 
          svcNotesFormBuilderQuestionsJSON = @svcNotesFormBuilderQuestionsJSON
	    , svcNotesFormBuilderAnswersJSON   = @svcNotesFormBuilderAnswersJSON
		, patientGoalProgressJSON          = @patientGoalProgressJSON
        , svcNotesFormBuilderTextSaved     = dbo.FORM_BUILDER_JSON_QA_DATA_TO_TEXT (  @svcNotesFormBuilderQuestionsJSON
	                                                                              , @svcNotesFormBuilderAnswersJSON
											                                      , 1
											                                      , 0
											                                      , 1
											                                      , 0 
																	              , 1
																				  , 0)
        , patientGoalProgressTextSaved = dbo.PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON_TO_TEXT (@patientGoalProgressJSON)
		, svcNotesPrivateFormBuilderTextSaved = dbo.FORM_BUILDER_JSON_QA_DATA_TO_TEXT (  @svcNotesFormBuilderQuestionsJSON
	                                                                              , @svcNotesFormBuilderAnswersJSON
											                                      , 1
											                                      , 0
											                                      , 1
											                                      , 0 
																	              , 1
																				  , 1)
	     , hasFillablePdfSelections  = @hasFillablePdfSelections            
         , fillablePdfSelectionsJSON = @fillablePdfSelectionsJSON 
         , fillablePdfAnswersJSON    = @fillablePdfAnswersJSON      
	   where (svcRecID = @recordID)
	 end
	 
   end
end /* Edit */    

else     

/*-------------------------------    
 * Invalid save type
 *------------------------------*/    

begin    
  RAISERROR ('Unknown save type', 11, 1)    
end  

/*============================================================
 * Create or recreate svcrecord <-> input batch cross 
 * reference record if appropriate
 *============================================================*/  

if (@userGroup = dbo.CONST_USER_GROUP_SBS())
begin
   
  /* If the entry type is not the service record import */

  if (@entryType != 116) 
  begin

    /*-------------------------------    
     * Remove any existing records
     * so we don't create duplicates
     * and if any of the fields
     * change, we can easily maintain
     * those by just saving the latest
     *------------------------------*/ 
  
    delete dbo.INPUT_BATCHES_SERVICE_RECORDS where (svcRecID = @recordID)
 
    /*-------------------------------    
     * Create new record
     *------------------------------*/ 

    insert into dbo.INPUT_BATCHES_SERVICE_RECORDS (
        clientID
      , reference
      , inputBatchParentID
      , inputBatchID
      , svcRecID
      , createdOn )
    
    values (
    
       @clientID
     , @reference
     , @inputBatchParentID
     , @inputBatchID
     , @recordID
     , @today )
  end /* Manage Service Record <-> Input Batch Relationship */
end /* PCAL User */

/*============================================================
 * Create new or manage existing claim records (if any)
 *============================================================*/    
  
exec dbo.SERVICE_RECORD_MANAGE_CLAIMS_CORE @recordID, @saveType, @today, @batchNum, @papClmNum, @updateState, @recordClaim

/*============================================================
 * Create new or manage existing patient goal progress
 * records (if any)
 * Note: The procedure will handle who can record data, etc
 *============================================================*/    
 
exec dbo.SERVICE_RECORD_MANAGE_PATIENT_GOALS_PROGRESS_CORE 
     @userGroup
   , @saveType
   , @validateRec
   , @fbdRecID
   , @clientID
   , @patID
   , @pracID 
   , @userID 
   , @dos    
   , @startTime 
   , @recordID
   , @today 
   , @hasPatientGoalTrackingData
   , @patientGoalProgressJSON 
   
/*============================================================
 * Create or manage service record review assignments
 * for CYBHI ORP (type 20) and internal (type 30)
 * supervision relationships
 *============================================================*/

exec dbo.SERVICE_RECORD_REVIEWS_RECORDS_MANAGE_CORE
     @userID
   , @userGroup
   , @userRank
   , @clientID
   , @pracID
   , @dos
   , @billingProgramID
   , @recordID
   , @saveType
   , @validateRec

/*============================================================
 * Create audit record
 *============================================================*/    
          
exec dbo.SERVICE_RECORD_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
       
/*============================================================
 * All done, commit changes and get out
 *============================================================*/    
    
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
            
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage 
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Save_Core] TO [webuser]
GO
