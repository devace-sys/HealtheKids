USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_Save_Inline') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORD_Save_Inline
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SERVICE_RECORD_Save_Inline] (
    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    
  , @reference     VARCHAR(500)           
  , @dos           datetime
  , @clientID      INT
  , @pracID        INT    
  , @patID         INT    
  , @svcNamesListDataSourceID SMALLINT
  , @nameID        INT
  --,@hasOrpDocID   BIT
  --,@orpDocID      BIGINT
  , @hasSvcDetailFlags BIT
  , @svcDetFlag1       BIT
  , @svcDetFlag2       BIT
  , @svcDetFlag3       BIT
  , @svcDetFlag4       BIT
  , @startTime         varchar(50)
  , @numMin            INT 
 --, @trip1Start    DECIMAL(7,1)    
 --, @trip1End      DECIMAL(7,1)    
 --, @trip2Start    DECIMAL(7,1)    
 --, @trip2End      DECIMAL(7,1)    
 --, @trip3Start    DECIMAL(7,1)    
 --, @trip3End      DECIMAL(7,1)    
 --, @trip4Start    DECIMAL(7,1)    
  --, @trip4End      DECIMAL(7,1)
  , @attendanceStatus     int
  , @notes         VARCHAR(max)
  , @editDelReason VARCHAR(7000)
  , @svcNotesFormBuilderQuestionsJSON varchar(max)
  , @svcNotesFormBuilderAnswersJSON   varchar(max)
  , @patientGoalProgressJSON          varchar(max)
  , @hasPatientGoalTrackingData       bit
  , @hasFillablePdfSelections         bit 
  , @fillablePdfSelectionsJSON        varchar(max)
  , @fillablePdfAnswersJSON           varchar(max)
  , @validateRec   BIT
  , @saveType      INT  
  , @recID         BIGINT    
  , @msgDupRec          VARCHAR(1000)    
  , @msgInvCombo        VARCHAR(1000)    
  , @MsgNoRec           VARCHAR(1000)     
  , @MsgNoEdit          VARCHAR(1000)     
  , @MsgDataError       VARCHAR(1000)    
  , @MsgMinReq          VARCHAR(1000)    
  , @MsgMinDef          VARCHAR(1000)     
  , @MsgMilReq          VARCHAR(1000)    
  , @MsgPatElg          VARCHAR(1000)
  , @MsgPatDOBGteDOS    VARCHAR(1000)
  , @MsgNotActive       VARCHAR(1000)
  , @MsgPatAbsent       VARCHAR(1000) 
  , @MsgFutureDOS       VARCHAR(1000)    
  , @spDetails          VARCHAR(8000) OUTPUT
  , @recordID           BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SERVICE_RECORD_SAVE_Inline */    
/**    
 * Creates a new, edits existing, or deletes (hides) existing service record    
 * and manages any associated claim records.    
 ***************************************************************************/         
     
SET NOCOUNT ON    
      
declare @currClaimsData as table (
       IDX                       int identity(1,1)
     , CLAIM_NUM                 int
     , PROCEDURE_ID              bigint
     , PROCEDURE_PROC_MOD_COMBO  varchar(100)
     , PROC_CODE                 nchar(10)
	 , MOD_1                     nchar(10)
	 , MOD_2                     nchar(10)
     , MOD_3                     nchar(10)
     , MOD_4                     nchar(10)
	 , NUM_UNITS                 int
     , CLAIM_ID                  bigint
	 , HAS_PROXY                 bit
	 , REFERENCE_CLAIM_ID_1      bigint	 
)

declare @newClaimsData as table (
       IDX                       int identity(1,1)
     , CLAIM_NUM                 int
     , PROCEDURE_ID              bigint
     , PROCEDURE_PROC_MOD_COMBO  varchar(100)
	 , PROC_CODE                 nchar(10)
	 , MOD_1                     nchar(10)
	 , MOD_2                     nchar(10)
     , MOD_3                     nchar(10)
     , MOD_4                     nchar(10)
     , NUM_UNITS                 int
)

declare @claimsDataCompare as table (
     CLAIM_NUM                 int
   , SAME_PROC_MOD_COMBO       bit
)

declare @today             as datetime
declare @numClaimsExisting as int
declare @numClaimsNew      as int
declare @numUnitsExisting  as int
declare @numUnitsNew       as int 

/* New (or edited fields) */

declare @batchID          as UNIQUEIDENTIFIER = null
declare @batchIDRecID     as BIGINT           = null

/* Derived fields for new or edit */

declare @startTimeVal     as time(0)
declare @patAbsent        as bit
declare @pracAbsent       as bit 
declare @makeupSession    as bit
declare @isIFSPorIEP      as bit
declare @billingProgramID as tinyint
  
/* Rules data for fields passed in */

declare @validSvcSel     as bit
declare @minsReq         as bit
declare @procIsQQCode    as bit 
declare @svcType         as int 
declare @svcSubType1     as int
declare @viaTelehealth   as bit
declare @svcNameID       as int

/* Existing service record */

declare @srClientID         as bigint
declare @srPracID           as bigint
declare @srSvcTypeID        as int
declare @srEntryType        as int
declare @srHasOrpDocID      as bit
declare @srOrpDocID         as bigint
declare @srGroupID          as bigint
declare @srDOS              as datetime
declare @srNameID           as bigint
declare @srPlanType         as bigint
declare @srIsIep            as bit
declare @srPatAbsent        as bit
declare @srPracAbsent       as bit
declare @srAttendanceStatus as int
declare @srState            as int
declare @srNumMins          as int
declare @srHasSvcDetFlags   as bit
declare @srSvcDetFlag1      as bit
declare @srSvcDetFlag2      as bit
declare @srSvcDetFlag3      as bit
declare @srSvcDetFlag4      as bit
declare @srUserID           as bigint
declare @userIsPcalStaff    as bit
declare @srUserIsPcalStaff   as bit
declare @srBillingProgramID as tinyint

/* Rules data for existing record  */

declare @srValidSvcSel     as bit
declare @srMinsReq         as bit
declare @srSvcType         as int 
declare @srSvcSubType1     as int
declare @srViaTelehealth   as bit
declare @srSvcNameID       as int
declare @srProcIsQQCode    as bit

/* Control fields */

declare @tranOpen                 as bit            -- Is a transaction open    
declare @okToCallSaveCore         as bit
declare @canStillEdit             as bit
declare @cifClaims                as bit
declare @createReplacementSvcRec  as bit
declare @keepCheckingEdit         as bit
declare @okToSpotEditExisting     as bit
declare @userClientID             as bigint
declare @userPracID               as bigint
declare @okForUserToEdit          as bit


/* CIF general category fields */

declare @selectionChanges              as varchar(4000) = ''
declare @dosOrAttendanceChanged        as bit = 0
declare @svcSelectionOrModalityChanged as bit = 0
declare @numOfClaimsChanged            as bit = 0
declare @numOfUnitsChanged             as bit = 0

/* Archive data fields */

declare @srJsonData as varchar(max)

/*#########################################################################################################
  #                                        INIT CONTROL FIELDS
  #########################################################################################################*/

set @today                     = getdate()
set @spDetails                 = ''
set @recordID                  = 0
set @okToCallSaveCore          = 0
set @canStillEdit              = 0
set @createReplacementSvcRec   = 0
set @cifClaims                 = 0
set @keepCheckingEdit          = 0
set @okToSpotEditExisting      = 0
set @okForUserToEdit           = 0

BEGIN TRY    


/*#########################################################################################################
  #                                           COMMON PREP 
  #########################################################################################################*/

/*============================================================
 * Various conversions and decoding
 *============================================================*/  

/* Start time */

set @startTimeVal = dbo.TIME_STR_TO_TIME_VAL(@startTime)

/* Attendance flags */

select top 1
    @patAbsent     = t1.patAbsent
  , @pracAbsent    = t1.pracAbsent
  , @makeUpSession = t1.makeupSession
from dbo.SERVICE_RECORD_ATTENDANCE_SELECTION_ID_TO_FLAGS (@attendanceStatus) as t1

/*============================================================
 * Lookup patient date of birth
 *============================================================*/ 

declare @dob as datetime
select top 1 @dob = pap.DATE_OF_BIRTH from dbo.PATIENTS_Patient as pap where (pap.PATIENT_ID = @patID)

/*============================================================
 * Get IEP/IFSP flag and billing program id from 
 * service name list data source id
 *============================================================*/ 

select top 1 
    @isIFSPorIEP      = snlds.isIEPOrIFSP
  , @billingProgramID = snlds.billingProgramID
from dbo.CLAIM_Svc_Names_List_Data_Sources as snlds
where
  (snlds.id = @svcNamesListDataSourceID)

/*============================================================
 * Determine plan type
 *============================================================*/ 

declare @planType as int
set @planType = dbo.DOS_DOB_IEP_BILLING_PROGRAM_TO_PLAN_TYPE (@dos,@dob,@isIFSPorIEP,@billingProgramID)

/*============================================================
 * Lookup practitioner current group
 *============================================================*/
  
declare @groupID as int
select top 1 @groupID = pg.GROUP_ID from dbo.PRACTITIONER_GROUPS as pg 
where (pg.PRACTITIONER_ID = @pracID and pg.GROUP_TYPE in (1,2))

/*============================================================
 * Validate service selection passed in
 *============================================================*/ 

select top 1 

    @validSvcSel      = isnull (sva.PROCEDURE_IS_SERVICE_SELECTION, 0)
  , @svcType          = sva.SERVICE_TYPE_ID
  , @svcSubType1      = isnull(sva.SERVICE_SUB_TYPE_1_ID,-1) /* Set to known value for nulls so compares dont fail */
  , @procIsQQCode     = sva.PROCEDURE_CODE_IS_QQ
  , @minsReq          = sva.SERVICE_ENTRY_MINUTES_REQUIRED
  , @viaTelehealth    = sva.SERVICE_IS_VIA_TELEHEALTH
  
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

if ((@validSvcSel is null) or (@validSvcSel = 0))
begin
  RAISERROR ('Invalid service selection', 11, 1) 
end

/*#########################################################################################################
  #                                       PREP FOR - NEW 
  #########################################################################################################*/

if (@saveType  = dbo.CONST_SAVE_TYPE_NEW())
begin
  
  set @okToCallSaveCore          = 1  
  set @canStillEdit              = 0
  set @createReplacementSvcRec   = 0  
  set @cifClaims                 = 0
  set @keepCheckingEdit          = 0
  set @okToSpotEditExisting      = 0

  /* TODO: We are using the following fields that are meant for edit to create a new. 
   * We need to add support for passing these values in for new recs, etc.
   * This will mean adding supporting changes up the stack inclucing the manage svc recs
   * screen and the future inline scheduled services record.
   * Full support for orp docs for new records will be limited until this is done.
   */
  
  set @srHasOrpDocID = 0
  set @srOrpDocID    = null

  if (@svcType = dbo.CONST_SERVICES_TRANSPORT()) 
  begin
    RAISERROR ('Creating new transportation services on this screen are not supported.', 11, 1)  
  end
end /* NEW */

/*#########################################################################################################
  #                                      PREP FOR - EDIT
  #########################################################################################################*/

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

/*============================================================
 * Init control variables
 *============================================================*/ 

set @okToCallSaveCore          = 0
set @canStillEdit              = 0
set @createReplacementSvcRec   = 0
set @cifClaims                 = 0
set @keepCheckingEdit          = 0
set @okToSpotEditExisting      = 0

/*============================================================
 * Lookup current service record data
 *============================================================*/ 

set @recordID = null

select top 1 
    @recordID           = sr.id 
  , @srEntryType        = sr.entryType
  , @srSvcTypeID        = sr.svcType
  , @srHasOrpDocID      = sr.hasOrpDocID
  , @srOrpDocID         = sr.orpDocID
  , @srGroupID          = sr.groupID
  , @srDOS              = sr.dos
  , @srNameID           = sr.nameID
  , @srPlanType         = sr.planType
  , @srIsIEP            = sr.isIFSPorIEP
  , @srPatAbsent        = sr.patAbsent
  , @srPracAbsent       = sr.pracAbsent
  , @srAttendanceStatus = sr.attendanceSelectionID
  , @srState            = sr.state
  , @srNumMins          = sr.numMins
  , @srHasSvcDetFlags   = sr.hasSvcDetFlags
  , @srSvcDetFlag1      = sr.svcDetFlag1
  , @srSvcDetFlag2      = sr.svcDetFlag2
  , @srSvcDetFlag3      = sr.svcDetFlag3
  , @srSvcDetFlag4      = sr.svcDetFlag4
  , @srClientID         = sr.clientID
  , @srUserID           = sr.userID
  , @srPracID           = sr.pracID
  , @srClientID         = sr.clientID
  , @srBillingProgramID = sr.billingProgramID

from dbo.SERVICE_RECORDS as sr

where (
      (sr.id       = @recID)
  and (sr.clientID = @clientID)
  and (sr.pracID   = @pracID)
  and (sr.patID    = @patID)
)
 
/*============================================================
 * If we cant find the record exit
 * Note: changes to client, prac and pat are NOT allowed in
 * this procedure so if those have been changed the record
 * will not be found
 *============================================================*/ 

if (@recordID is null)
begin
  RAISERROR ('Service record not found or it cannot be edited', 11, 1) 
end

/*============================================================
 * Look up info on the user who is calling this routine
 *============================================================*/ 

select top 1 
   @userClientID  = ua.clientID 
 , @userPracID    = ua.pracID 
 , @userIsPcalStaff = ua.pcalStaff
from users.dbo.USERS_ALL as ua 
where ((ua.id = @userID) and (ua.appName = 'spedcare'))

/*============================================================
 * Look up info on the user who entered the service
 *============================================================*/ 

select top 1 
  @srUserIsPcalStaff = ua.pcalStaff
from users.dbo.USERS_ALL as ua 
where ((ua.id = @srUserID) and (ua.appName = 'spedcare'))

/*============================================================
 * Determine if the user can edit the service
 *============================================================*/ 

set @okForUserToEdit = 0

/* User who entered record can edit */

if ((@okForUserToEdit = 0) and (@userID = @srUserID)) set @okForUserToEdit = 1

/* If the user is the practitioner who is the rendering practioner associated with the service record, they can edit
 * unless the record was entered by pcal then they can't edit */

if (     (@okForUserToEdit = 0) 
     and (@userPracID = @srPracID) 
	 and (@srUserIsPcalStaff = 0)
	) 
begin
  set @okForUserToEdit = 1
end

/*============================================================
 * Exit if the service record edit is not allowed
 *============================================================*/ 

if (@okForUserToEdit = 0)
begin
  if ((@srUserIsPcalStaff = 1) and (@userIsPcalStaff = 0))
  begin
    RAISERROR ('This service record was entered by Practi-Cal and cannot be edited by this user', 11, 1) 
  end

  RAISERROR ('This service record cannot be edited by this user', 11, 1) 

end

/*============================================================
 * Exit if we cant process certain service records
 *============================================================*/ 

if (@srEntryType in (10,11)) 
  RAISERROR ('Editing services that were created in a service journal are not supported on this screen yet', 11, 1) 

if (@srSvcTypeID = dbo.CONST_SERVICES_TRANSPORT()) 
  RAISERROR ('Editing transportation services on this screen are not supported yet', 11, 1) 

if (@srState = 99)  
  RAISERROR ('Service can no longer be edited because it has been deleted',        11, 1) 

if (@srState = 199) 
  RAISERROR ('Service can no longer be edited because it has been marked for CIF', 11, 1) 

/*============================================================
 * Determine if service can be edited through normal procedures
 *============================================================*/ 

if (dbo.SERVICE_STATE_TO_CAN_STILL_EDIT_FLAG(@srState) = 1)
begin
  set @okToCallSaveCore         = 1
  set @canStillEdit             = 1
  set @createReplacementSvcRec  = 0
  set @cifClaims                = 0
  set @keepCheckingEdit         = 0
  set @okToSpotEditExisting     = 0
end

/*============================================================
 * If the service cannot be edited through the normal procedure
 * and its a service that is in the normal claims sent state
 * then we will fall through to additional checks 
 *============================================================*/ 

if (@canStillEdit = 0)
begin 

  set @okToCallSaveCore        = 0
  set @canStillEdit            = 0
  set @createReplacementSvcRec = 0
  set @cifClaims               = 0
  set @keepCheckingEdit        = 1
  set @okToSpotEditExisting    = 0

  /* Service is in a state that can never be edited.... it might also be an old hebs port, etc */
  if (@srState != 20) 
    RAISERROR ('This service cannot be edited', 11, 1) 

  /* Billing program id has changed.  This is a complex CIF process.
   * We will prevent this edit from happening now.  TODO: Figure out
   * CIF process for this particular case.
   */

  if (@srBillingProgramID != @billingProgramID)
  begin
    RAISERROR ('The billing program can not be changed after the service has been billed.', 11, 1) 
  end

  /* Temp blocking of CYBHI service editing after transmission */
  /* TODO: We need to implement CYBHI specific rules further down in this routine */

  if (@srBillingProgramID = 2)
  begin
    RAISERROR ('CYBHI services can not be edited after they have been billed.', 11, 1)   
  end

end

end /* Edit*/

/*#########################################################################################################
  #                                    OTHER SAVE TYPES                                                   #
  #########################################################################################################*/

else 
begin
  RAISERROR ('Only edits are supported on this screen', 11, 1) 
end /* Other save types */



/*#########################################################################################################
  #                                     EDIT AFTER CLAIMS SENT                                            #
  #                                                                                                       #
  # NOTE: IT IS VERY VERY IMPORTANT TO KEEP THE ORDER OF THE VARIOUS CHECKS WHERE WE ARE TESTING          #
  #       @keepCheckingEdit AS IS.  DO NOT CHANGE THE ORDER OF THESE TESTS !!!!!!!!!!!!!!                 #
  #########################################################################################################*/

if (    (@saveType         = dbo.CONST_SAVE_TYPE_EDIT()) 
    and (@canStillEdit     = 0) 
	and (@keepCheckingEdit = 1) 
	and (@okToCallSaveCore = 0)
)
begin

/*============================================================
 * Init control variables
 *============================================================*/ 

set @keepCheckingEdit              = 1
set @createReplacementSvcRec       = 0
set @okToCallSaveCore              = 0
set @cifClaims                     = 0
set @okToSpotEditExisting          = 0

/*============================================================
 * Init CIF general category flags
 *============================================================*/ 

set @dosOrAttendanceChanged        = 0
set @svcSelectionOrModalityChanged = 0
set @numOfClaimsChanged            = 0
set @numOfUnitsChanged             = 0

/*============================================================
 * Get current claim data 
 *============================================================*/ 

insert into @currClaimsData
select 
    CLAIM_NUM                = clm.LINE_NUMBER
  , PROCEDURE_ID             = clm.PROCEDURE_ID
  , PROCEDURE_PROC_MOD_COMBO = dbo.RPT_PROC_MOD_COMBO(cp.PROCEDURE_CODE, cp.PROCEDURE_MODIFIER_1, cp.PROCEDURE_MODIFIER_2, cp.PROCEDURE_MODIFIER_3, cp.PROCEDURE_MODIFIER_4)
  , PROC_CODE                = cp.PROCEDURE_CODE
  , MOD_1                    = cp.PROCEDURE_MODIFIER_1     
  , MOD_2                    = cp.PROCEDURE_MODIFIER_2     
  , MOD_3                    = cp.PROCEDURE_MODIFIER_3     
  , MOD_4                    = cp.PROCEDURE_MODIFIER_4     
  , NUM_UNITS                = clm.SERVICE_UNITS
  , clm.CLAIM_ID
  , HAS_PROXY                = isnull(clm.HAS_PROXY,0)
  , clm.REFERENCE_CLAIM_ID_1

from dbo.SERVICE_RECORD_CLAIMS as src
join dbo.CLAIM_Claim           as clm on clm.CLAIM_ID    = src.claimID
join dbo.CLAIM_Procedures      as cp  on cp.PROCEDURE_ID = clm.PROCEDURE_ID
where (src.svcRecID = @recID)

/*============================================================
 * Get new possible claims
 *============================================================*/ 

insert into @newClaimsData
select 
     cd.CLAIM_NUM
   , cd.PROCEDURE_ID
   , cd.PROCEDURE_PROC_MOD_COMBO
   , PROC_CODE = cp.PROCEDURE_CODE
   , MOD_1     = cp.PROCEDURE_MODIFIER_1     
   , MOD_2     = cp.PROCEDURE_MODIFIER_2     
   , MOD_3     = cp.PROCEDURE_MODIFIER_3     
   , MOD_4     = cp.PROCEDURE_MODIFIER_4     
   , cd.NUM_UNITS

from dbo.SERVICE_DATA_TO_CLAIMS_DATA ( @clientID
                                     , @groupID
									 , @planType
									 , @dos
									 , @nameID
									 , @svcDetFlag1
									 , @svcDetFlag2
									 , @svcDetFlag3
									 , @svcDetFlag4
									 , @numMin
									 , 0    /* Put in trip/miles later*/
									 , 0
									 , @billingProgramID ) as cd

join dbo.CLAIM_Procedures as cp on cp.PROCEDURE_ID = cd.PROCEDURE_ID

/*============================================================
 * Get existing service rules
 *============================================================*/ 

select top 1 

    @srValidSvcSel      = isnull (sva.PROCEDURE_IS_SERVICE_SELECTION, 0)
  , @srSvcType          = sva.SERVICE_TYPE_ID
  , @srSvcSubType1      = isnull(sva.SERVICE_SUB_TYPE_1_ID,-1) /* Set to known value for nulls so compares dont fail*/
  , @srProcIsQQCode     = sva.PROCEDURE_CODE_IS_QQ
  , @srMinsReq          = sva.SERVICE_ENTRY_MINUTES_REQUIRED
  , @srViaTelehealth    = sva.SERVICE_IS_VIA_TELEHEALTH

from dbo.SERVICES_VIEW_ALL_CORE (  
    @clientID
  , @groupID
  , @srPlanType /* Plan type */
  , null
  , @srNameID   /* Service selected */
  , 1         /* In allowed procs */
  , 1         /* Active procs only */
  , @dos      /* Effective for given DOS*/
  , 1         /* Selection only*/
) as sva

/*============================================================
 * If patient absent has changed from then we have to cif
 *============================================================*/ 

if ((@keepCheckingEdit = 1) and ((@srPatAbsent = 0) and (@patAbsent = 1)))
begin
  set @keepCheckingEdit         = 0
  set @createReplacementSvcRec  = 1
  set @cifClaims                = 1
  set @dosOrAttendanceChanged   = 1
  set @okToCallSaveCore         = 1
  set @okToSpotEditExisting     = 0
  set @editDelReason = 'Patient attendance changed from present to absent'
end

/*============================================================
 * If practitioner attendance changed then we have to cif
 *============================================================*/ 

if ((@keepCheckingEdit = 1) and ((@srPracAbsent = 0) and (@pracAbsent = 1)))
begin
  set @keepCheckingEdit         = 0
  set @createReplacementSvcRec  = 1
  set @cifClaims                = 1
  set @dosOrAttendanceChanged   = 1
  set @okToCallSaveCore         = 1
  set @okToSpotEditExisting     = 0
  set @editDelReason            = 'Practitioner attendance changed from present to absent'
end

/*============================================================
 * If date of service has changed then we have to cif
 *============================================================*/ 

if ((@keepCheckingEdit = 1) and (datediff (day, convert(date,@srDos), convert(date,@dos)) != 0))
begin
  set @keepCheckingEdit         = 0
  set @createReplacementSvcRec  = 1
  set @cifClaims                = 1
  set @dosOrAttendanceChanged   = 1
  set @okToCallSaveCore         = 1
  set @okToSpotEditExisting     = 0
  set @editDelReason            = 'Date of service has changed'
end

/*============================================================
 * Check if service selection changed - Pass 1
 * Compare selection data 
 * We will use this later
 *============================================================*/

set @selectionChanges = ''

if (@keepCheckingEdit = 1) 
begin
     if (@srIsIep          != @isIFSPorIEP)       set @selectionChanges = @selectionChanges + ' - Is IEP.'
     if (@srPlanType       != @planType)          set @selectionChanges = @selectionChanges + ' - Plan type.'
	 if (@srNameID         != @nameID)            set @selectionChanges = @selectionChanges + ' - Selection.'
     if (@srSvcType        != @svcType)           set @selectionChanges = @selectionChanges + ' - Service type.'
     if (@srSvcSubType1    != @svcSubType1)       set @selectionChanges = @selectionChanges + ' - Service sub type 1.'
     if (@srViaTelehealth  != @viaTelehealth)     set @selectionChanges = @selectionChanges + ' - Via telehealth.'
     if (@srHasSvcDetFlags != @hasSvcDetailFlags) set @selectionChanges = @selectionChanges + ' - Has svc detail flags.'
     if (@srSvcDetFlag1    != @svcDetFlag1)       set @selectionChanges = @selectionChanges + ' - Svc detail flag 1.'
     if (@srSvcDetFlag2    != @svcDetFlag2)       set @selectionChanges = @selectionChanges + ' - Svc detail flag 2.'
     if (@srSvcDetFlag3    != @svcDetFlag3)       set @selectionChanges = @selectionChanges + ' - Svc detail flag 3.'
     if (@srSvcDetFlag4    != @svcDetFlag4)       set @selectionChanges = @selectionChanges + ' - Svc detail flag 4.'     
end

/*============================================================
 * Check if service selection changed - Pass 2
 *
 * Compare claim procedures. 
 *
 * If the claim procedures have changed then we have to cif
 *============================================================*/

if (@keepCheckingEdit = 1) 
begin

  insert into @claimsDataCompare (
      CLAIM_NUM
    , SAME_PROC_MOD_COMBO
  )
  select 
      ccd.CLAIM_NUM
    , SAME_PROC_MOD_COMBO = dbo.CLAIM_PROCEDURE_COMPARE (  ccd.PROC_CODE, ccd.MOD_1, ccd.MOD_2, ccd.MOD_3, ccd.MOD_4  
                                                         , ncd.PROC_CODE, ncd.MOD_1, ncd.MOD_2, ncd.MOD_3, ncd.MOD_4)
  from @currClaimsData as ccd
  join @newClaimsData  as ncd on ncd.CLAIM_NUM = ccd.CLAIM_NUM
  
  if exists (select cdc.CLAIM_NUM from @claimsDataCompare as cdc where cdc.SAME_PROC_MOD_COMBO = 0)
  begin    
	 set @keepCheckingEdit              = 0
     set @createReplacementSvcRec       = 1
     set @cifClaims                     = 1
     set @svcSelectionOrModalityChanged = 1
     set @okToCallSaveCore              = 1
     set @okToSpotEditExisting          = 0
     set @editDelReason                 = 'Service selection or modality has changed.  Changes in following values: ' + @selectionChanges
  end 
end


/*============================================================
 * Check if service selection changed - Pass 3
 *
 * There are cases where selection changes result in no claims
 * (non billable selections or not enough units to claim)
 *
 * If this happens we have to cif
 *============================================================*/

if (@keepCheckingEdit = 1) 
begin
  if (len(@selectionChanges) > 0)
  begin
  
    set @numClaimsExisting = 0
	set @numClaimsNew      = 0
    select @numClaimsExisting = count(ccd.idx) from @currClaimsData as ccd where ccd.NUM_UNITS = 0
    select @numClaimsNew      = count(ncd.idx) from @newClaimsData  as ncd 
  
    if ((@numClaimsExisting > 0) and (@numClaimsNew = 0))
	begin
	  set @keepCheckingEdit              = 0
      set @createReplacementSvcRec       = 1
      set @cifClaims                     = 1
      set @svcSelectionOrModalityChanged = 1
      set @okToCallSaveCore              = 1
      set @okToSpotEditExisting          = 0
      set @editDelReason                 = 'Service selection or modality has changed.  Changes in following values: ' + @selectionChanges
	end
  end
end

/*============================================================
  * Get claim count of non 0 unit claims
  * if there is a difference we have to CIF
  *============================================================*/

if (@keepCheckingEdit = 1)
begin
  
  set @numClaimsExisting = 0
  set @numClaimsNew      = 0

  select @numClaimsExisting = count(ccd.idx) from @currClaimsData as ccd where ccd.NUM_UNITS = 0
  select @numClaimsNew      = count(ncd.idx) from @newClaimsData as ncd where ncd.NUM_UNITS = 0

  if (@numClaimsExisting != @numClaimsNew)
  begin
     set @keepCheckingEdit         = 0
     set @createReplacementSvcRec  = 1
     set @cifClaims                = 1
	 set @numOfClaimsChanged       = 1
     set @okToCallSaveCore         = 1
     set @okToSpotEditExisting     = 0
     set @editDelReason            = 'Number of claims has changed'
   end
end

/*============================================================
 * If the number of minutes has not changed
 * and nothing major has changed about the sevice selection 
 * and the claim count has not changed then we can edit the 
 * existing service record
 *============================================================*/

if ((@keepCheckingEdit = 1) and (@srNumMins = @numMin))
begin
     set @keepCheckingEdit         = 0
     set @createReplacementSvcRec  = 0
     set @cifClaims                = 0
     set @okToCallSaveCore         = 0
     set @okToSpotEditExisting     = 1
     set @editDelReason            = 'Number of minutes has changed'
end
 
/*============================================================
 * If the number of minutes has changed
 * but the both the existing and new do not require minutes
 * and nothing major has changed about the sevice selection 
 * and the claim count has not changed then we can edit the 
 * existing service record
 *============================================================*/
 
if (
      (@keepCheckingEdit = 1) 
  and (@srNumMins != @numMin) 
  and (@srMinsReq = 0) 
  and (@minsReq = 0) 
  and (@numClaimsExisting = @numClaimsNew)
)
begin
   set @keepCheckingEdit         = 0
   set @createReplacementSvcRec  = 0
   set @cifClaims                = 0
   set @okToCallSaveCore         = 0
   set @okToSpotEditExisting     = 1
   set @editDelReason            = 'Service does not require minutes and minutes or start time have changed'
end

/*============================================================
  * If the number of minutes has changed
  * and both the existing and new require minutes and the
  * num of claims is still the same
  * check to see if the num of units would change
  *============================================================*/

if ((@keepCheckingEdit = 1) and (@srNumMins != @numMin) and ((@srMinsReq = 1) and (@minsReq = 1)))
begin
  select @numUnitsExisting = sum(ccd.NUM_UNITS) from @currClaimsData as ccd where ccd.NUM_UNITS = 0
  select @numUnitsNew      = sum(ncd.NUM_UNITS) from @newClaimsData  as ncd where ncd.NUM_UNITS = 0

  if (@numUnitsExisting != @numUnitsNew)
  begin
     set @keepCheckingEdit         = 0
     set @createReplacementSvcRec  = 1
     set @cifClaims                = 1
	 set @numOfUnitsChanged        = 1
	 set @okToCallSaveCore         = 1
     set @okToSpotEditExisting     = 0
     set @editDelReason            = 'Number of minutes has changed and number of units has changed as a result'
   end
   else
   begin
     set @keepCheckingEdit         = 0
     set @createReplacementSvcRec  = 0
     set @cifClaims                = 0
     set @okToCallSaveCore         = 0
     set @okToSpotEditExisting     = 1
     set @editDelReason            = 'Number of minutes has changed but the change did not change number of units'
   end
end


/* TODO: Add additional checks here */

/*============================================================
  * If we reach this point there is nothing more that can be
  * done
  *============================================================*/

if (@keepCheckingEdit = 1)
begin
  RAISERROR ('This service can not be edited', 11, 1) 
end


end /* Can no longer edit*/   

/*#########################################################################################################
  #                                                                                                       #
  #                                       DATABASE RECORD OPS                                             #
  #                                                                                                       #
  #########################################################################################################*/

declare @updateState  as smallint    
declare @auditRecID   as bigint
declare @cifRecID     as bigint
declare @cifSpDetails as varchar(8000)
declare @cifRequestID as bigint
declare @fbdRecID     as bigint

BEGIN TRANSACTION    
SET @TranOpen  = 1 

/*#########################################################################################################
  #                             WE CAN SPOT EDIT THE EXISTING                                             #
  #########################################################################################################*/

if (@okToSpotEditExisting = 1)
begin

/*============================================================
 * Update the service record
 *============================================================*/     

update sr
set 
    sr.numMins               = @numMin
  , sr.startTime             = @startTimeVal
  , sr.notes                 = @notes
  , sr.lastmodified          = @today
  , sr.attendanceSelectionID = @attendanceStatus  /* Note: If status selection changed but it did not change the base attendance flags we can update with the new selection */

from dbo.SERVICE_RECORDS as sr
where (sr.id = @recordID)

/* Get form builder data */

select top 1  
    @fbdRecID                         =  srfbd.id
from dbo.SERVICE_RECORDS_FORM_BUILDER_DATA as srfbd
where (srfbd.svcRecID = @recordID)
	 
/* Only edit existing data */

if (@fbdRecID is not null)
begin
  
  /*-------------------------------    
   * Enforce null values for no
   * patient progress goals
   *------------------------------*/        

  if ( trim(isnull(@patientGoalProgressJSON,'')) = '') set @patientGoalProgressJSON = null

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
    , patientGoalProgressTextSaved    = dbo.PATIENT_GOALS_PROGRESS_PARSE_SERVICE_RECORD_JSON_TO_TEXT (@patientGoalProgressJSON)
	, svcNotesPrivateFormBuilderTextSaved     = dbo.FORM_BUILDER_JSON_QA_DATA_TO_TEXT (  @svcNotesFormBuilderQuestionsJSON
	                                                                              , @svcNotesFormBuilderAnswersJSON
											                                      , 1
											                                      , 0
											                                      , 1
											                                      , 0 
																	              , 1
																				  , 1)

   ,  hasFillablePdfSelections  = @hasFillablePdfSelections  
   ,  fillablePdfSelectionsJSON = @fillablePdfSelectionsJSON
   ,  fillablePdfAnswersJSON    = @fillablePdfAnswersJSON

  where (svcRecID = @recordID)

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
     , @startTimeVal 
     , @recordID
     , @today 
	 , @hasPatientGoalTrackingData
     , @patientGoalProgressJSON 

end /* Edit existing form builder data */

set @updateState = dbo.CONST_SVC_REC_STATE_MOD()       

/*============================================================
 * Create audit record
 *============================================================*/    
          
exec dbo.SERVICE_RECORD_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     

set @okToCallSaveCore          = 0
set @createReplacementSvcRec   = 0
set @cifClaims                 = 0

end /* Spot edit */

/*#########################################################################################################
  #                                              CIF                                                      #
  #########################################################################################################*/

if (@cifClaims = 1)
begin
  
  /* Get original service record data for archive purposes */

  set @srJsonData = convert (  varchar(max)
                           ,(select sr.* from dbo.SERVICE_RECORDS as sr 
						     where sr.id = @recordID FOR JSON AUTO, INCLUDE_NULL_VALUES)
						  )  
  set @cifSpDetails = ''
  
  /* Call existing CIF initiate logic */
  
  exec dbo.SERVICE_RECORD_INITIATE_CIF_Core @userID,@userGroup,@userRank,@editDelReason,0,@clientID,@recordID, @today,@spDetails output, @cifRecID output
  
  /* The table CLAIMS_LIST_DO_NOT_RESUBMIT is updated with new claims */

  insert into dbo.CIF_REQUESTS (
      clientID
	, svcRecID
	, saveTypeID
	, reason	
	, svcRecData
	, createdOn
	, createdBy
	, dosOrAttendanceChanged  
	, svcSelectionOrModalityChanged
	, numOfClaimsChanged
	, numOfUnitsChanged
   )
   values ( 
       @clientID
     , @recordID
     , dbo.CONST_SAVE_TYPE_EDIT()
	 , @editDelReason
     , @srJsonData
     , @today
     , @userID
	 , @dosOrAttendanceChanged
     , @svcSelectionOrModalityChanged
     , @numOfClaimsChanged 
     , @numOfUnitsChanged
	) 

   set @cifRequestID = SCOPE_IDENTITY()
   
   insert into dbo.CIF_REQUESTS_CLAIMS (     
        cifRequestID
	  , svcRecID
	  , claimID )
   select  
       cifRequestID = @cifRequestID
	  , src.svcRecID
	  , src.claimID
   from dbo.SERVICE_RECORD_CLAIMS as src
   where (src.svcRecID = @recordID)

  /* Add additional calls here*/
end

/*#########################################################################################################
  #                                CREATE REPLACEMENT SVC REC                                             #
  #########################################################################################################*/

if (@createReplacementSvcRec = 1)
begin
 
 set @saveType = dbo.CONST_SAVE_TYPE_NEW() /* Switch save type to new */
 set @okToCallSaveCore = 1

end

/*#########################################################################################################
  #                                        CALL SAVE CORE                                                 #
  #########################################################################################################*/

if (@okToCallSaveCore = 1) 
begin
  
  -- @isIFSPorIEP
  -- @billingProgramID tinyint
-- @svcNamesListDataSourceID


/*-------------------------------    
 * Create unique batch ID
 *------------------------------*/

exec SERVICE_RECORD_BATCH_ID_Create 
  @userID, @userGroup, @userRank, @saveType, @validateRec, @batchIDRecID OUTPUT , @batchID OUTPUT  

/*-------------------------------    
 * Call save sproc
 *------------------------------*/
 
EXEC dbo.SERVICE_RECORD_Save_Core
      @userID   
    , @userGroup    
    , @userRank
	, 1 /* Gen claims */
    , 256 /* From manage screen via save inline */    
    , @reference           
    , ''   
    , ''   
    , @dos
    , @clientID     
    , @pracID    
    , @patID
    , @isIFSPorIEP    
    , @nameID
    , @srHasOrpDocID
    , @srOrpDocID
    , null    
    , @hasSvcDetailFlags
    , @svcDetFlag1
    , @svcDetFlag2
    , @svcDetFlag3
    , @svcDetFlag4
    , @startTimeVal
    , @numMin    
    , 0 -- @trip1Start   
    , 0 -- @trip1End   
    , 0 -- @trip2Start    
    , 0 -- @trip2End   
    , 0 -- @trip3Start    
    , 0 -- @trip3End   
    , 0  --@trip4Start    
    , 0 --@trip4End
    , @patAbsent    
    , @pracAbsent
    , @makeupSession 
	, @attendanceStatus
    , @notes
	, @svcNotesFormBuilderQuestionsJSON
    , @svcNotesFormBuilderAnswersJSON
	, @patientGoalProgressJSON
	, @hasPatientGoalTrackingData
    , @billingProgramID
	, @hasFillablePdfSelections
    , @fillablePdfSelectionsJSON
	, @fillablePdfAnswersJSON
	, @editDelReason    
    , @validateRec    
    , @saveType    
    , @recID 
    , @msgDupRec   
    , @msgInvCombo    
    , @MsgNoRec     
    , @MsgNoEdit   
    , @MsgDataError    
    , @MsgMinReq    
    , @MsgMinDef     
    , @MsgMilReq    
    , @MsgPatElg
    , @MsgPatDOBGteDOS
    , @MsgNotActive 
    , @MsgPatAbsent
    , @MsgFutureDOS
    , @spDetails     OUTPUT    
    , @recordID      OUTPUT      

/*-------------------------------    
 * Assign unique batch ID
 *------------------------------*/

DECLARE @batchIDAssRecID  AS BIGINT = null

exec SERVICE_RECORD_BATCH_ID_Assign
    @userID, @userGroup, @userRank, @saveType, @validateRec, @batchID, 1, @recordID, @batchIDAssRecID OUTPUT 

/*-------------------------------    
 * Update CIF data if needed
 *------------------------------*/

if (@cifClaims = 1) and (@createReplacementSvcRec = 1)
begin

  /* Get replacement service record data */

  set @srJsonData = convert (  varchar(max)
                           ,(select sr.* from dbo.SERVICE_RECORDS as sr 
						     where sr.id = @recordID FOR JSON AUTO, INCLUDE_NULL_VALUES)
						  )  

  /* Update CIF request data */

  update dbo.CIF_REQUESTS
    set 
	  svcRecDataReplacement = @srJsonData
	, replacementSvcRecID   = @recordID
  where (id = @cifRequestID)


end


end
    
/*-------------------------------    
 * If this was an actual save
 * or edit commit the transaction
 *------------------------------*/  

IF (@TranOpen  = 1) COMMIT TRANSACTION    

/*-------------------------------    
 * And we are done
 *------------------------------*/  

SET @TranOpen = 0    
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
   * Return the error message to
   * the caller. 
   *------------------------------*/    
 
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    

END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[SERVICE_RECORD_Save_Inline] TO [webuser]
GO
