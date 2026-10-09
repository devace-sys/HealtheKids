USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_CORE
GO

/*###########################################################################
 *#                                                                         #
 *#             !!!!!!!!!!!!!!!! NOTICE !!!!!!!!!!!!!!!!!!                  #
 *#                                                                         #
 *# The value of planType is NOT our standard values for planType           #
 *#                                                                         #
 *# In this context.....                                                    #
 *#                                                                         #
 *# 1 = IEP or IFSP, 2 = No Plan , 3 = Other                                #
 *#                                                                         #
 *# Everywhere else                                                         #
 *#                                                                         #
 *#  1 = IFSP, 2 = IEP, 3 = No Plan , 4 = CYBHI                             #
 *###########################################################################*/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_CORE] (
    @userID                       bigint
  , @userGroup                    bigint
  , @userRank                     bigint
  , @clientID                     bigint
  , @pracID                       bigint
  , @patID                        bigint  
  , @svcTrackingClass             int  

  , @spEdServiceCode              int     /* Used for svcTracking class 100 */

  , @orpDocID		              bigint  /* Used for svcTracking class 200 */
   
  , @svcNamesListDataSourceID     int      /* Used for svcTracking class 300 */
  , @viaTeleHealth                bit = 0  /* Used for svcTracking class 300 */
  , @nameID                       bigint   /* Used for svcTracking class 300 */	  
  , @startDate                    date
  , @endDate                      date
  , @spEdFreqCode                 int
  , @minsPerFreq                  int
  , @startDateAssigned            date
  , @minsPerFreqAssigned          int
  , @hasSvcDetails                bit = 0
  , @svcDetailsJSON               varchar(max)
  , @editDelReason                VARCHAR(7000)
  , @validateRec                  BIT
  , @saveType                     INT
  , @recID                        bigint
  , @MsgNoRec                     VARCHAR(1000)
  , @MsgNoEdit                    VARCHAR(1000)
  , @MsgDupRec                    VARCHAR(1000)
  , @MsgDataError                 VARCHAR(1000)
  , @MsgNotActive                 VARCHAR(1000)
  , @spDetails                    VARCHAR(8000) OUTPUT
  , @recordID                     BIGINT        OUTPUT
)
AS
BEGIN

/***************************************************************************
 * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_CORE */
/**
 ***************************************************************************/

SET NOCOUNT ON

declare @caseloadEntryID          as bigint   = null
declare @groupID                  as int      = null
declare @pracGrpSvcClsNameID      as bigint   = null
declare @today                    as datetime = getdate()
declare @updateState              as smallint
declare @minsDaily                as int       = 0
declare @minsAnn                  as int       = 0
declare @duplicateRecID           as bigint    = null
declare @clientIdOut              as bigint
declare @pracIdOut                as bigint
declare @patIdOut                 as bigint
declare @svcNameID                as bigint
declare @altModalityNameID        as bigint
declare @svcTypeID                as int
declare @planTypeID               as int
declare @patDob                   as date         = null
declare @isIEPOrIFSP              as bit          = null
declare @billingProgramID         as tinyint      = null

declare @planType        as int      = 1     /* For backwards compat*/
declare @expectedMinsInd as int              
declare @expectedMinsGrp as int
declare @daysOfWeekSvcProvidedJSON as varchar(max)

BEGIN TRY

/*-------------------------------
 * Init 
 *------------------------------*/

set @spDetails  = ''
set @recordID   = 0

/*-------------------------------
 * Defaults
 *------------------------------*/

if (@svcTrackingClass is null) set @svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED()
if (@svcDetailsJSON   is null) set @svcDetailsJSON   = '{}'
if (@svcDetailsJSON = '')      set @svcDetailsJSON   = '{}'

/*-------------------------------
 * Deprecated values
 *------------------------------*/

set @expectedMinsInd = null
set @expectedMinsGrp = null
set @daysOfWeekSvcProvidedJSON = '{"monInd":false,"tueInd":false,"wedInd":false,"thurInd":false,"friInd":false,"monGrp":false,"tueGrp":false,"wedGrp":false,"thurGrp":false,"friGrp":false}'

/*-------------------------------
 * Verify all parameters that
 * indicate what type of operation
 * to perform have been passed in
 * and any other parms that are
 * neccessary for proper operation
 *------------------------------*/

IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)
if (@clientID    iS NULL) RAISERROR ('Client id required',      11, 1)
if (@pracID      iS NULL) RAISERROR ('Prac id required',        11, 1)
if (@patID       iS NULL) RAISERROR ('Pat id required',         11, 1)

/*-------------------------------
 * Take care of virtual nulls
 *------------------------------*/

if (@orpDocID            in (0,-1))  set @orpDocID            = null
if (@spEdServiceCode     in (0,-1))  set @spEdServiceCode     = null
if (@spEdFreqCode        in (0,-1))  set @spEdFreqCode        = null
if (@minsPerFreq         in (0,-1))  set @minsPerFreq         = null
if (@minsPerFreqAssigned in (0,-1))  set @minsPerFreqAssigned = null

/*------------------------------
 * Determine caseload plan type
 * Note: For backwards compat
 * with caseload entry.
 *------------------------------*/

set @planType = 1

select top 1 
  @planType = stc.pracPatCaseloadExpSvcPlanType 
from dbo.PRACTITIONER_PATIENT_CASELOAD_SVC_TRACKING_CLASSES as stc
where 
  (stc.value = @svcTrackingClass)

/*-------------------------------
 * Additional required field
 * check for just SpEd svcs
 *------------------------------*/

if (@svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED())
begin

  if (@startDate           is null)    RAISERROR ('Must provide plan start date to track SpEd service',          11, 1)
  if (@endDate             is null)    RAISERROR ('Must provide plan end date to track SpEd service',            11, 1)
  if (@spEdFreqCode        is null)    RAISERROR ('Must provide plan frequency to track SpEd service',           11, 1)
  if (@minsPerFreq         is null)    RAISERROR ('Must provide duration to track SpEd service',                 11, 1)
  if (@startDateAssigned   is null)    RAISERROR ('Must provide start date responsible to track SpEd service',   11, 1) 
  if (@minsPerFreqAssigned is null)    RAISERROR ('Must provide duration responsible to track SpEd service',     11, 1)
  if (@minsPerFreq <= 0)               RAISERROR ('Must provide duration that is greater than 0 to track SpEd service',                 11, 1)
  if (@minsPerFreqAssigned <= 0)       RAISERROR ('Must provide duration responsible for that is greater than 0 to track SpEd service', 11, 1)

  /* Handle cases where start date assigned falls outside of the accepted range */

  if (@startDateAssigned not between @startDate and @endDate) set @startDateAssigned = @startDate

  /* Handle cases where mins per frequency assigned falls outside of the accepted range */

  if (@minsPerFreqAssigned > @minsPerFreq) set @minsPerFreqAssigned = @minsPerFreq
  
end

/*-------------------------------
 * Additional required field
 * check for just orders
 *------------------------------*/

else if (@svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED())
begin

  if (@minsPerFreq <= 0)  RAISERROR ('Must provide duration that is greater than 0', 11, 1)

  /* Start date and mins per frequency assigned is not supported at this time for this tracking class */

  set @startDateAssigned   = @startDate
  set @minsPerFreqAssigned = @minsPerFreq
 
end
else

/*-------------------------------
 * Additional fields checks
 * for service
 *------------------------------*/

begin
  
  if (@minsPerFreq <= 0)  RAISERROR ('Must provide duration that is greater than 0', 11, 1)

  /* Start date and mins per frequency assigned is not supported at this time for this tracking class */

  set @startDateAssigned   = @startDate
  set @minsPerFreqAssigned = @minsPerFreq

end

/*-------------------------------
 * Initial call to caseload
 * member save in validate mode
 * to get and check data
 *------------------------------*/

exec dbo.PRACTITIONER_CASELOAD_MEMBER_Save_Core
    @userID
  , @clientID
  , @pracID
  , @patID
  , @planType  
  , @spEdServiceCode
  , @orpDocID
  , @startDate
  , @endDate
  , @spEdFreqCode
  , @minsPerFreq
  , @expectedMinsInd
  , @expectedMinsGrp
  , @daysOfWeekSvcProvidedJSON
  , 0
  , 1 /* Validate */
  , @clientIdOut         output
  , @pracIdOut           output
  , @patIdOut            output
  , @groupID             output
  , @pracGrpSvcClsNameID output
  , @caseloadEntryID     output

/*============================================================
 * Additional field lookups for user provided svc tracking
 *============================================================*/  

if (@svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED())
begin
  
  /*-------------------------------
   * IEP flag & billing program id
   *------------------------------*/

  set @billingProgramID = null

  select top 1 
      @isIEPOrIFSP      = t1.isIEPOrIFSP 
    , @billingProgramID = t1.billingProgramID
  from dbo.CLAIM_Svc_Names_List_Data_Sources as t1
  where 
    (t1.id = @svcNamesListDataSourceID)

  /*-------------------------------
   * Patient date of birth
   *------------------------------*/

  select top 1 
    @patDob = pap.DATE_OF_BIRTH 
  from dbo.PATIENTS_Patient as pap 
  where 
    (pap.PATIENT_ID = @patIdOut)
  
  /*-------------------------------
   * Plan type id
   *------------------------------*/

  set @planTypeID = null
  select top 1 @planTypeID = dbo.DOS_DOB_IEP_BILLING_PROGRAM_TO_PLAN_TYPE (@startDate, @patDob, @isIEPOrIFSP, @billingProgramID)

  /*-------------------------------
   * Service name id
   * Alt modality name id
   * Service type id
   *------------------------------*/

  set @svcNameID = null

  select top 1 
      @svcNameID         = svac.SERVICE_NAME_ID
    , @altModalityNameID = svac.SERVICE_NAME_ID_ALT_MODALITY
    , @svcTypeID         = svac.SERVICE_TYPE_ID  
  from dbo.SERVICES_VIEW_ALL_CORE (@clientID, @groupID, @planTypeID, null, @nameID, 1 ,1, @startDate, 1) as svac
  where 
    (svac.SERVICE_NAME_LIST_DATA_SOURCE_ID = @svcNamesListDataSourceID)
	
end

/*============================================================
 * If this is a record edit 
 *============================================================*/  

if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  /* A record id should have been provided, if not get out*/

  if (@recID is null) RAISERROR('Record id expected',11,1)

  /* A caseload expected services entry should already exist.  If not exit. */

  set @recordID = 0

  select top 1
    @recordID = isnull(ppces.id,0)
  from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces
  where (
        (ppces.id              = @recID)
    and (ppces.caseloadEntryID = @caseloadEntryID)
    and (ppces.active          = 1)
  )

  if (@recordID = 0) RAISERROR ('Record cannot be edited', 11, 1)

end

/*============================================================
 * Duplicate check
 *============================================================*/  

set @duplicateRecID = null

/*-------------------------------
 * Duplicate check just for
 * SpEd services
 *------------------------------*/

if (@svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED())
begin
  select top 1
      @duplicateRecID = ppc.id
  from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces
  join dbo.PRACTITIONER_PATIENT_CASELOAD                   as ppc on ppc.id = ppces.caseloadEntryID
  where (
         (1=1)
    and  ((@recID IS NULL) or (ppces.id != @recID)) /* Skips record being edited */
    and  (ppc.clientID           = @clientID)
    and  (ppc.pracID             = @pracID)
    and  (ppc.patID              = @patID)
    and  (ppces.spEdServiceCode  = @spEdServiceCode)
	and  (ppces.startDate        = @startDate)
	and  (ppces.endDate          = @endDate)
	and  (ppces.spEdFreqCode     = @spEdFreqCode)
	and  (ppces.minsPerFreq      = @minsPerFreq)
    and  (ppces.svcTrackingClass = 100)
	and  (ppces.planType         = 1)
    and  (ppces.active           = 1)
  )

  if (@duplicateRecID is not null) RAISERROR ('You are already tracking a spEd service with the same CALPADS code, start date, end date, frequency, and duration for this patient', 11, 1)

end

/*-------------------------------
 * Duplicate check just for
 * orders
 *------------------------------*/

else if (@svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED())
begin
  select top 1
      @duplicateRecID = ppc.id
  from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces
  join dbo.PRACTITIONER_PATIENT_CASELOAD                   as ppc on ppc.id = ppces.caseloadEntryID
  where (
         (1=1)
    and  ((@recID IS NULL) or (ppces.id != @recID)) /* Skips record being edited */
    and  (ppc.clientID           = @clientID)
    and  (ppc.pracID             = @pracID)
    and  (ppc.patID              = @patID)
    and  (ppces.orpDocID         = @orpDocID)
    and  (ppces.svcTrackingClass = 200)
	and  (ppces.planType         = 2)
    and  (ppces.active           = 1)
  )

  if (@duplicateRecID is not null) RAISERROR ('You are already tracking this order for this patient', 11, 1)

end

/*-------------------------------
 * Duplicate check just for
 * user provided
 *------------------------------*/

else 
begin
  select top 1
      @duplicateRecID = ppc.id
  from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces
  join dbo.PRACTITIONER_PATIENT_CASELOAD                   as ppc on ppc.id = ppces.caseloadEntryID
  where (
         (1=1)
    and  ((@recID IS NULL) or (ppces.id != @recID)) /* Skips record being edited */
    and  (ppc.clientID                   = @clientID)
    and  (ppc.pracID                     = @pracID)
    and  (ppc.patID                      = @patID)
    and  (ppces.svcTrackingClass         = 300)
	and  (ppces.startDate                = @startDate)
	and  (ppces.endDate                  = @endDate)
	and  (ppces.spEdFreqCode             = @spEdFreqCode)
	and  (ppces.minsPerFreq              = @minsPerFreq)
	and  (ppces.svcNamesListDataSourceID = @svcNamesListDataSourceID)
	and  (ppces.nameID                   = @nameID)	
    and  (ppces.active                   = 1)
 )

 if (@duplicateRecID is not null) RAISERROR ('You are already tracking any treatments entered for this patient', 11, 1)

end

/*-------------------------------
 * Validation
 *------------------------------*/

IF (@validateRec = 1)
BEGIN
  SET @recordID = 0
  RETURN(0)
END

/*-------------------------------
 * Call to caseload
 * member save in commit mode
 * to get and check data
 *------------------------------*/

exec dbo.PRACTITIONER_CASELOAD_MEMBER_Save_Core
    @userID
  , @clientID
  , @pracID
  , @patID
  , @planType
  , @spEdServiceCode
  , @orpDocID
  , @startDate
  , @endDate
  , @spEdFreqCode
  , @minsPerFreq
  , @expectedMinsInd
  , @expectedMinsGrp
  , @daysOfWeekSvcProvidedJSON
  , 0
  , 0 /* validate */
  , @clientIdOut         output
  , @pracIdOut           output
  , @patIdOut            output
  , @groupID             output
  , @pracGrpSvcClsNameID output
  , @caseloadEntryID     output

/***************************************************************************
 *                 Manage caseload expected services data                  *
 ***************************************************************************/

/*-------------------------------
 * Add new
 *------------------------------*/

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  set @updateState = dbo.CONST_REC_STATE_NEW()

  insert into dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES (
      caseloadEntryID
	, clientID
    , pracID
    , patID
	, svcTrackingClass
	, planType
	, spEdServiceCode
	, orpDocID
	, startDate
	, endDate
	, spEdFreqCode
	, minsPerFreq
    , expectedMinsInd
	, expectedMinsGrp
	, daysOfWeekSvcProvidedJSON
    , created
    , createdBy
	, startDateAssigned
    , minsPerFreqAssigned
    , hasSvcDetails
    , svcDetailsJSON
	, svcNamesListDataSourceID  	   	   	
	, viaTeleHealth	 
	, includeAltModalityInTracking  
	, nameID 
	, altModalityNameID
	, svcTypeID
	, planTypeID
  )
  values (
      @caseloadEntryID
	, @clientID
	, @pracID
	, @patID
	, @svcTrackingClass
	, @planType
	, @spEdServiceCode
	, @orpDocID
	, @startDate
	, @endDate
	, @spEdFreqCode
	, @minsPerFreq
	, @expectedMinsInd
	, @expectedMinsGrp
	, @daysOfWeekSvcProvidedJSON
	, @today
	, @userID
    , @startDateAssigned
	, @minsPerFreqAssigned
    , @hasSvcDetails
    , @svcDetailsJSON
	, @svcNamesListDataSourceID  	   	   
	, @viaTeleHealth	 
	, 1
	, @svcNameID 
	, @altModalityNameID
	, @svcTypeID
	, @planTypeID
  )

  set @recordID = SCOPE_IDENTITY()

end

/*-------------------------------
 * Edit existing
 *------------------------------*/

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  set @updateState = dbo.CONST_REC_STATE_MOD()

  update dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES
  set
	   caseloadEntryID              = @caseloadEntryID
	 , svcTrackingClass             = @svcTrackingClass
	 , planType                     = @planType
	 , spEdServiceCode              = @spEdServiceCode
	 , orpDocID                     = @orpDocID
	 , startDate                    = @startDate
	 , endDate                      = @endDate
	 , spEdFreqCode                 = @spEdFreqCode
	 , minsPerFreq                  = @minsPerFreq
     , lastModified                 = @today
     , lastModifiedBy               = @userID
	 , startDateAssigned            = @startDateAssigned
	 , minsPerFreqAssigned          = @minsPerFreqAssigned
     , hasSvcDetails                = @hasSvcDetails 
     , svcDetailsJSON               = @svcDetailsJSON
	 , svcNamesListDataSourceID     = @svcNamesListDataSourceID   	   	   
	 , viaTeleHealth	            = @viaTeleHealth
	 , includeAltModalityInTracking = 1
	 , nameID                       = @svcNameID
	 , altModalityNameID            = @altModalityNameID
	 , svcTypeID                    = @svcTypeID
     , planTypeID                   = @planTypeID
   where ((id = @recordID))

 end
 ELSE
 BEGIN
   RAISERROR ('Unknown or unsupported save type', 11, 1)
 END

/*-------------------------------
 * If we reach this point
 * everything is OK.  Exit
 *------------------------------*/

RETURN(0)
END TRY
BEGIN CATCH

  /*-------------------------------
   * If we end up here something
   * went wrong.  Return any
   * error any error messages to
   * the caller
   *------------------------------*/


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

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_CORE] TO [webuser]
GO
