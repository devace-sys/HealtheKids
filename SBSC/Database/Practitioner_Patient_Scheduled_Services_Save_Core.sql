USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Services_Save_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Practitioner_Patient_Scheduled_Services_Save_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Practitioner_Patient_Scheduled_Services_Save_Core] (
    @userID                    bigint
  , @userGroup                 bigint
  , @userRank                  bigint
  , @clientID                  bigint
  , @pracID                    bigint
  , @patID                     bigint
  , @caseloadGrpID			   bigint
  , @svcNamesListDataSourceID  int
  , @viaTeleHealth             bit
  , @nameID                    bigint  
  , @recurring                 bit
  , @practitionerPatientCaseloadExpectedServiceID bigint
  , @startDate                 date
  , @endDate                   date  
  , @startTime                 time(0)
  , @numMins                   int
  , @mon                       bit
  , @monStartTime              time(0)
  , @tue                       bit
  , @tueStartTime              time(0)
  , @wed                       bit
  , @wedStartTime              time(0)
  , @thu                       bit
  , @thuStartTime              time(0)
  , @fri                       bit
  , @friStartTime              time(0)
  , @notes                     varchar(max)
  , @editDelReason             varchar(7000)
  , @validateRec               bit
  , @saveType                  int
  , @recID                     bigint
  , @MsgNoRec                  varchar(1000)
  , @MsgNoEdit                 varchar(1000)
  , @MsgDupRec                 varchar(1000)
  , @MsgDataError              varchar(1000)
  , @MsgNotActive              varchar(1000)
  , @spDetails                 varchar(8000) OUTPUT
  , @recordID                  bigint        OUTPUT
)
AS
BEGIN

/***************************************************************************
 * Practitioner_Patient_Scheduled_Services_Save_Core */
/**
 ***************************************************************************/

SET NOCOUNT ON

declare @today                       as datetime     = getdate()
declare @patDob                      as date         = null
declare @groupID                     as bigint       = null
declare @planTypeID                  as int          = null
declare @isIEPOrIFSP                 as bit          = null
declare @billingProgramID            as tinyint      = null
declare @participatesInLEABOP        as bit          = null 
declare @participatesInCYBHI         as bit          = null
declare @participatesInRUHealth      as bit          = null
declare @participatesInLEABOPNonSpEd as bit          = null
declare @okToShowServicesForPlan     as bit          = 0
declare @savedGroupID                as bigint       = null
declare @altModalityNameID           as bigint       = null
declare @svcTypeID                   as int          = null
declare @svcSubType1ID               as int          = null
declare @svcNameID                   as bigint       = null
declare @whenSummary                 as varchar(512) = ''

BEGIN TRY

/*============================================================
 * Init output parameters and set initial values for vars
 *============================================================*/  

set @spDetails  = ''
set @recordID   = 0
set @today      = getdate()

/*============================================================
 * Verify required values have been passed.  If not exit.
 *============================================================*/  

if (@userGroup     IS NULL) RAISERROR ('userGroup is required',      11, 1)
if (@userID        IS NULL) RAISERROR ('user id is required',        11, 1)    
if (@userRank      IS NULL) RAISERROR ('userRank is required',       11, 1)    
if (@validateRec   IS NULL) RAISERROR ('Validate flag required',     11, 1)    
if (@saveType      IS NULL) RAISERROR ('Save type is required',      11, 1)    
if (@clientID      is null) RAISERROR ('Client id is required',      11, 1)
if (@pracID        is null) RAISERROR ('Prac id is required',        11, 1)
if (@patID         is null) RAISERROR ('Patient id is required',     11, 1)
if (@startDate     is null) RAISERROR ('Service date is required',   11, 1)
if (@recurring     is null) RAISERROR ('Recurring is required',      11, 1)
if (@nameID        is null) RAISERROR ('Service selection required', 11, 1)

/*============================================================
 * Set default values
 *============================================================*/  

if (@mon is null) set @mon = 0
if (@tue is null) set @tue = 0
if (@wed is null) set @wed = 0
if (@thu is null) set @thu = 0
if (@fri is null) set @fri = 0

if (@recurring = 0)
begin
  set @endDate = @startDate
end
else

/*============================================================
 * Lookup practitioner data and get group id.  
 * Exit if not found.
 *============================================================*/  

set @groupID = null

select top 1

    @groupID                     = gg.GROUP_ID
  , @participatesInLEABOP        = prp.participatesInLEABOP
  , @participatesInCYBHI         = prp.participatesInCYBHI
  , @participatesInRUHealth      = prp.participatesInRUHealth
  , @participatesInLEABOPNonSpEd = prp.participatesInLEABOPNonSpEd

from dbo.PRACTITIONER_Client       as prc
join dbo.PRACTITIONER_Practitioner as prp on  (prp.PRACTITIONER_ID = prc.PRACTITIONER_ID)
join dbo.PRACTITIONER_GROUPS       as pg  on  ((pg.PRACTITIONER_ID  = prp.PRACTITIONER_ID)
                                          and (pg.GROUP_TYPE in (1,2))
										  and (pg.ACTIVE = 1))
join dbo.GROUP_Group               as gg  on  ((gg.GROUP_ID = pg.GROUP_ID)
                                          and (gg.GROUP_TYPE in (1,2))
                                          and (gg.ACTIVE = 1))
where (
      (prc.CLIENT_ID       = @clientID)
  and (prc.PRACTITIONER_ID = @pracID)
)

if (@groupID is null)
begin
    RAISERROR ('Invalid practitioner',  11, 1)
end
  
/*============================================================
 * Lookup patient data and get date of birth.
 * Exit if not found.
 *============================================================*/  

select top 1  
  @patDob = pap.DATE_OF_BIRTH
from dbo.PATIENTS_Client  as pac
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pac.CLIENT_ID
where (
      (pac.CLIENT_ID = @clientID)
  and (pac.PATIENT_ID = @patID)
)

if (@patDob is null) RAISERROR ('Invalid patient', 11, 1)

/*============================================================
 * Lookup iep flag and billing program id 
 * Exit if not found
 *============================================================*/  

set @billingProgramID = null

select top 1 
    @isIEPOrIFSP      = t1.isIEPOrIFSP 
  , @billingProgramID = t1.billingProgramID
from dbo.CLAIM_Svc_Names_List_Data_Sources as t1
where 
  (t1.id = @svcNamesListDataSourceID)

if (@billingProgramID is null) RAISERROR ('Invalid service name list data source', 11, 1)

/*============================================================
 * Determine plan type
 * Exit if not found
 *============================================================*/  

set @planTypeID = null

select top 1 @planTypeID = dbo.DOS_DOB_IEP_BILLING_PROGRAM_TO_PLAN_TYPE (@startDate,@patDob,@isIEPOrIFSP,@billingProgramID)
if (@planTypeID is null) RAISERROR ('Invalid plan type', 11, 1)

/*============================================================
 * Determine if practitioner is authorized to select service
 * We will raise a warning later if this is not the case
 *============================================================*/  

set @okToShowServicesForPlan = 0
set @okToShowServicesForPlan = dbo.SERVICES_CAN_SHOW_FOR_PLAN_TYPE (@planTypeID,@participatesInLEABOP,@participatesInLEABOPNonSpEd,@participatesInCYBHI,@participatesInRUHealth)


/*============================================================
 * Lookup service data
 * Exit if not found
 *============================================================*/  

set @svcNameID = null

select top 1 
    @svcNameID         = svac.SERVICE_NAME_ID
  , @altModalityNameID = svac.SERVICE_NAME_ID_ALT_MODALITY
  , @svcTypeID         = svac.SERVICE_TYPE_ID
  , @svcSubType1ID     = svac.SERVICE_SUB_TYPE_1_ID
from dbo.SERVICES_VIEW_ALL_CORE (@clientID, @groupID, @planTypeID, null, @nameID, 1 ,1, @startDate, 1) as svac
where 
  (svac.SERVICE_NAME_LIST_DATA_SOURCE_ID = @svcNamesListDataSourceID)

if (@svcNameID is null) RAISERROR ('Service not found', 11, 1)



/*============================================================
 * Sanity checks for dates
 *============================================================*/  

/*-------------------------------    
 * Start date cannot precede
 * patients date of birth
 *------------------------------*/    

if (@startDate < @patDob)
begin
   RAISERROR ('Start date cannot be before patients date of birth',  11, 1)
end

/*-------------------------------    
 * End date cannot precede
 * patients date of birth
 *------------------------------*/    

if (@endDate is not null)
begin
 if (@endDate < @patDob)
 begin
   RAISERROR ('End date cannot be before patients date of birth',  11, 1)
 end
end

/*-------------------------------    
 * If this is a recurring service
 * start date cannot be after
 * end date
 *------------------------------*/    

if (@recurring = 1)
begin

  if ((@startDate is not null) and (@endDate is not null))
  begin
    if (@startDate > @endDate)  RAISERROR ('Start date cannot be after end date', 11, 1)
  end
end 

/*============================================================
 * Generate summary text
 *============================================================*/  

set @whenSummary = dbo.Practitioner_Patient_Scheduled_Service_Occurs_When_Summary ( 
      @recurring
	, @startDate
	, @startTime
    , @mon
	, @monStartTime
    , @tue
	, @tueStartTime
    , @wed
	, @wedStartTime
    , @thu
	, @thuStartTime
    , @fri
	, @friStartTime ) 

/*============================================================
 * Validation specific for editing a record
 *============================================================*/  

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN    
  
  /*-------------------------------    
   * If record id was not provided
   * exit   
   *------------------------------*/    

  if (@recID is null) RAISERROR ('Record id is required',  11, 1)
  
  /*-------------------------------    
   * Lookup existing record
   * Uses index 
   *------------------------------*/    
  
  set @recordID = 0
  
  select top 1 
      @recordID = isnull(ppss.id,0)
  from dbo.Practitioner_Patient_Scheduled_Services as ppss
  where (
        (ppss.clientID = @clientID)
	and (ppss.pracID   = @pracID)
    and (ppss.active   = 1)
	and (ppss.id       = @recID)
  )

  /*-------------------------------    
   * If record not found exit
   *------------------------------*/    
  
  if (@recordID = 0)
  begin
    RAISERROR (@msgNoRec,  11, 1)
  end

  /*-------------------------------    
   * If group id has changed
   * TODO:
   *------------------------------*/    
  
END

/*============================================================
 * If this is NOT a recurring service remove any expected
 * service relationship
 *============================================================*/  

if (@recurring = 0)
begin
  set @practitionerPatientCaseloadExpectedServiceID = null
end

/*============================================================
 * Validation mode only checks
 *============================================================*/  

if (@validateRec = 1)
begin

  /*-------------------------------    
   * Warn user if plan is not 
   * allowed
   *------------------------------*/    

  if (@okToShowServicesForPlan = 0) 
  begin
     set @spDetails = dbo.UPDATE_DETAILS(@spDetails, 'The service plan selected is currently/no longer not authorized for this practitioner', dbo.CONST_RET_WARN())
  end

  /*-------------------------------    
   * Check for redudant records
   * warn user if they exist
   *------------------------------*/    

  if exists (

    select top 1
      ppss.id
    from dbo.Practitioner_Patient_Scheduled_Services as ppss
    where (  
          (1=1)              
      and ((@recID is null) or (ppss.id != @recID)) /* Handles both new and edit cases */
      and (ppss.clientID                  = @clientID)
      and (ppss.pracID                    = @pracID)
      and (ppss.patID                     = @patID)
      and (ppss.startDate                 = @startDate)
      and (isnull(ppss.endDate,@today)    = isnull(@endDate,@today))
      and (ppss.svcNamesListDataSourceID  = @svcNamesListDataSourceID)
      and (ppss.viaTeleHealth             = @viaTeleHealth)
      and (ppss.nameID                    = @nameID)
      and (ppss.numMins                   = @numMins)
      and (ppss.mon                       = @mon)
      and (ppss.tue                       = @tue)
      and (ppss.wed                       = @wed)
      and (ppss.thu                       = @thu)
      and (ppss.fri                       = @fri)
	  and (ppss.caseloadGrpID			  = @caseloadGrpID)
      and (ppss.active                    = 1)	
    )
  )
  begin
    set @spDetails = dbo.UPDATE_DETAILS(@spDetails,'This schedule entry may be a duplicate',dbo.CONST_RET_DUP_RECORD())
  end

end /* Validation only checks*/

/*============================================================
 * Validation exit
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN  
  SET @recordID = 0 
  RETURN(0)    
END                          

/*============================================================
 * Save data
 *============================================================*/  

  /*-------------------------------    
   * New record
   *------------------------------*/    
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN        
    
    INSERT INTO dbo.Practitioner_Patient_Scheduled_Services
    (                   
	     practitionerPatientCaseloadExpectedServiceID
	   , clientID
	   , pracID
	   , groupID
	   , patID 
	   , caseloadGrpID
	   , svcNamesListDataSourceID  	   
	   , planTypeID
	   , billingProgramID
	   , isIEPOrIFSP        
	   , viaTeleHealth	   
	   , nameID 
	   , altModalityNameID
	   , svcTypeID
	   , svcSubType1ID
	   , recurring
	   , startDate
	   , endDate
	   , startTime
	   , numMins		          
	   , mon
	   , monStartTime
	   , tue
	   , tueStartTime
	   , wed
	   , wedStartTime
	   , thu
	   , thuStartTime
	   , fri
	   , friStartTime
	   , whenSummary
	   , notes	                    
	   , created
	   , createdBy
	   , active
    )    
    VALUES    
    (  
         @practitionerPatientCaseloadExpectedServiceID
	   , @clientID
	   , @pracID
	   , @groupID
	   , @patID 
	   , @caseloadGrpID
	   , @svcNamesListDataSourceID  	   
	   , @planTypeID	   
	   , @billingProgramID
	   , @isIEPOrIFSP        
	   , @viaTeleHealth	   
	   , @nameID 
	   , @altModalityNameID
	   , @svcTypeID
	   , @svcSubType1ID	   
	   , @recurring
	   , @startDate
	   , @endDate
	   , @startTime
	   , @numMins	
	   , @mon
	   , @monStartTime	   
	   , @tue
	   , @tueStartTime	   
	   , @wed
	   , @wedStartTime	   
	   , @thu
	   , @thuStartTime	   
	   , @fri
	   , @friStartTime
	   , @whenSummary
	   , @notes	   
	   , @today
       , @userID
	   , 1         
    )      
    
    set @recordID = SCOPE_IDENTITY()    

  END /* New */         
  
  /*-------------------------------    
   * Edit existing record    
   *------------------------------*/    

  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN          	                          	
	 update dbo.Practitioner_Patient_Scheduled_Services
     set 
	   
	     practitionerPatientCaseloadExpectedServiceID = @practitionerPatientCaseloadExpectedServiceID
	   
	   , svcNamesListDataSourceID  = @svcNamesListDataSourceID  
	   , planTypeID                = @planTypeID	   
	   , billingProgramID          = @billingProgramID
	   , isIEPOrIFSP               = @isIEPOrIFSP        
	   , viaTeleHealth             = @viaTeleHealth
	   , nameID                    = @nameID  
	   , altModalityNameID         = @altModalityNameID
	   , svcTypeID                 = @svcTypeID
	   , svcSubType1ID             = @svcSubType1ID
	   , recurring                 = @recurring 
	   , startDate                 = @startDate
	   , endDate                   = @endDate
	   , startTime                 = @startTime
	   , numMins	               = @numMins	
       , mon                       = @mon
	   , monStartTime              = @monStartTime
	   , tue                       = @tue
	   , tueStartTime              = @tueStartTime
	   , wed                       = @wed
	   , wedStartTime              = @wedStartTime
	   , thu                       = @thu
	   , thuStartTime              = @thuStartTime
	   , fri                       = @fri
	   , friStartTime              = @friStartTime
	   , whenSummary               = @whenSummary
	   , notes                     = @notes
	   , lastModified              = @today
       , lastModifiedBy            = @userID
     where 
	   (id = @recordID)
   end /* Edit */
   
   /*-------------------------------    
    * Unsupported or unknown     
    *------------------------------*/    

   else 
   begin
     RAISERROR ('Unknown save type', 11, 1)  
   end /* Unknown save type */

/*-------------------------------
 * If we reach this point
 * everything is OK, commit our
 * changes and exit
 *------------------------------*/

RETURN(0)
END TRY
BEGIN CATCH

  /*-------------------------------
   * If we end up here something
   * went wrong.  Return any
   * error messages to the caller
   *------------------------------*/

  -- Error or raise error with severity 11 to 19 will be caught here

  DECLARE @ErrorMessage  AS NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Practitioner_Patient_Scheduled_Services_Save_Core] TO [webuser]
GO
