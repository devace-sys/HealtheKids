USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_SAVE] (
  @userID                   BIGINT,    
  @userGroup                INT,    
  @userRank                 INT,    
  @clientID                 BIGINT, 
  @patID                    BIGINT, 
  @effectiveDate            DATE,
  @endDate                  DATE,
  @svcName                  VARCHAR(1000),
  @orpDocStdNameID          bigint,
  @svcDesc                  VARCHAR(8000),
  @noteCrit1                VARCHAR(2000),
  @noteCrit2                VARCHAR(2000),
  @noteCrit3                VARCHAR(2000),
  @noteCrit4                VARCHAR(2000),
  @noteCrit5                VARCHAR(2000),
  @noteCrit6                VARCHAR(2000),
  @noteCrit7                VARCHAR(2000),
  @noteCrit8                VARCHAR(2000),
  @noteCrit9                VARCHAR(2000),
  @noteCrit10               VARCHAR(2000),
  @allowMultipleOrders      BIT,
  @orderContextFieldName    VARCHAR(200),
  @formBuilderQuestionsJSON VARCHAR(max),
  @formBuilderAnswersJSON   VARCHAR(max),
  @noteObsvCmnt             VARCHAR(2000),  
  @iep                      bit,
  @frequency     			int,
  @projectedMinutes			int,
  @planStartDate			date,
  @planEndDate				date,
  @dailyFreq                int,
  @pracIDsStr               varchar(8000),
  @detailsTrainingPracsJSON varchar(max),
  @detailsTrainingPracs ServiceJournalPractitionerTrainingDetails readonly,
  @orpPracID                    BIGINT,
  @groupServiceClassNameID      BIGINT,
  @orpAuthSvcDate               DATE,
  @orpAuthExpDate               DATE,
  @svcAuthStatusConfirmRespCode BIGINT,
  @editDelReason                VARCHAR(7000),    
  @validateRec                 BIT,    
  @saveType                    INT,    
  @recID                       BIGINT,
  @MsgNoRec           VARCHAR(1000),    
  @MsgNoEdit          VARCHAR(1000), 
  @MsgDupRec          VARCHAR(1000),   
  @MsgDataError       VARCHAR(1000),
  @MsgNotActive       VARCHAR(1000),     
  @spDetails          VARCHAR(8000) OUTPUT,    
  @recordID           BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_SAVE */    
/**    
 * Creates or edits prescribed order
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientID        Client id    
 * @param   patID           Patient id
 * @param   dos             Service date
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
 * @param   MsgDataError    Desired error message for data errors    
 * @returns spDetails       Validation or error details    
 * @returns recordID        New record id or record id of service record that    
 *                          was changed or deleted     
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Variables
 *============================================================*/  

declare @today               as datetime      
declare @tranOpen            as bit           
declare @existingRecForDate  as bigint 
declare @auditDataBeforeJSON as nvarchar(max)
declare @auditDataAfterJSON  as nvarchar(max)
declare @auditRecID          as bigint

declare @duplicateRecords as table (
    idx bigint identity(1,1)
  , id  bigint
)

declare @recIDToDelete   as bigint = 0
declare @recIDDeleted    as bigint = 0
declare @spDetailsDelete as varchar(8000) = ''
declare @hasDups         as bit   = 0
declare @minIdx          as bigint = 0
declare @maxIdx          as bigint = 0
declare @curIdx          as bigint = 0


BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()  
set @tranOpen   = 0  
SET @auditDataBeforeJSON = ''

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    

/*============================================================
 * See if the clientID and patID combo is valid
 *============================================================*/  

if not exists (
  select top 1 
    numOf = 1 
  from dbo.CLIENTS_Client   as cc 
  join dbo.PATIENTS_Client  as pc on pc.CLIENT_ID  = cc.CLIENT_ID
  join dbo.PATIENTS_Patient as pp on pp.PATIENT_ID = pc.PATIENT_ID
  where (
        (cc.CLIENT_ID  = @clientID) 
    and (pp.PATIENT_ID = @patID)
  )
)
begin
  RAISERROR ('Invalid client or patient id', 11, 1)
end

/*============================================================
 * Check if effective date and end date are compatible
 *============================================================*/  

if (@endDate is not null)
begin
  if (@effectiveDate > @endDate)
  begin
    RAISERROR ('End date must be on or before start date', 11, 1)
  end
end

/*============================================================
 * Attempt to autoselect appropriate value 
 *============================================================*/  
    
if (@groupServiceClassNameID is null)
begin

  select top 1

    @groupServiceClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID

  from dbo.PRACTITIONER_Practitioner                         as prp
  join dbo.PRACTITIONER_GROUPS                               as prg on prg.PRACTITIONER_ID = prp.PRACTITIONER_ID
  join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on png.GROUP_ID = prg.GROUP_ID
                                                                  
  where ( 
         (prp.UserID = @userID)
     and (png.GROUP_SERVICE_CLASS_PARTITION_ID = 5)
  )

end

/*============================================================
 * Find any duplicate records
 *============================================================*/  

set @hasDups = 0

insert into @duplicateRecords (id)
select 
    id = oddc.REFERENCE_ID
from dbo.SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_EXISTING_FOR_CLIENT_GROUP_SVC_CLASS_PAT_STD_SEL_NAME (
    @userID
  , @userGroup
  , @userRank
  , @clientID
  , @groupServiceClassNameID      
  , @patID          
  , @orpDocStdNameID
  , 1) as oddc

select 
    @minIdx =  min(dr.idx)
  , @maxIdx  = max(dr.idx) 
from @duplicateRecords as dr

set @curIdx = isnull(@minIdx,0)
if (@curIdx > 0) set @hasDups = 1

/*###########################################################################
  # Validation
  ###########################################################################*/  

IF (@validateRec = 1) 
BEGIN

  set @recordID = 0 
  RETURN(0)    
END        

BEGIN TRANSACTION
SET @TranOpen = 1

declare @orpDocID as bigint = null

/*###########################################################################
  # Create New
  ###########################################################################*/  

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin

  /*============================================================
   * Delete duplicates (we warn user on save order/profile
   * screen this will happen)
   *===========================================================*/   

  if (@hasDups = 1)
  begin
   
	while (@curIdx <= @maxIdx)
	begin
	    
	  select top 1 
	    @recIDToDelete = dr.id 
	  from @duplicateRecords as dr where (dr.idx = @curIdx)

	  exec dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_DELETE_CORE 
          @userID
        , @userGroup
        , @userRank 
        , @editDelReason 
        , @validateRec
        , @clientID   
        , @recIDToDelete
        , @MsgNoRec 
        , @MsgNoEdit 
        , @spDetailsDelete OUTPUT
        , @recIDDeleted    OUTPUT

      set @curIdx = @curIdx + 1
   
    end
  end

  /*-------------------------------
   * Populate old svcName with
   * selection for backwards
   * comp.
   *
   * TODO: Remove when old svcName
   * has been refactored out
   *------------------------------*/ 

  select top 1 @svcName = NAME from dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES where (ID = @orpDocStdNameID)

  /*-------------------------------
   * Create cross reference record
   *------------------------------*/ 
  
  insert into dbo.ORP_DOCUMENTS (ORP_DOCUMENT_TYPE_ID) values (2)
  set @orpDocID = SCOPE_IDENTITY()
  
  insert into dbo.SvcJournal_Prescribed_Orders (
      clientID
    , patID
    , effectiveDate
    , endDate
    , svcName
    , svcDesc
    , noteCrit1
    , noteCrit2
    , noteCrit3
    , noteCrit4
	, noteCrit5
	, noteCrit6
	, noteCrit7
	, noteCrit8
	, noteCrit9
	, noteCrit10
    , noteObsvCmnt
    , iep
	, frequency     	
	, projectedMinutes	
	, planStartDate	
	, planEndDate		
    , dailyFreq
    , pracIDsStr
    , detailsTrainingPracsJSON
    , orpPracID
    , active
    , created
    , createdBy
    , ORP_DOCUMENT_ID
    , GROUP_SERVICE_CLASS_PARTITION_ID
    , GROUP_SERVICE_CLASS_NAME_ID
	, formBuilderQuestionsJSON
	, formBuilderAnswersJSON
	, allowMultipleOrders  
	, orderContextFieldName
  ) 
  values (
      @clientID
    , @patID
    , @effectiveDate
    , @endDate
    , @svcName
    , @svcDesc
    , @noteCrit1
    , @noteCrit2
    , @noteCrit3
    , @noteCrit4
	, @noteCrit5
	, @noteCrit6
	, @noteCrit7
	, @noteCrit8
	, @noteCrit9
	, @noteCrit10
    , @noteObsvCmnt
    , @iep
	, @frequency     	
	, @projectedMinutes	
	, @planStartDate	
	, @planEndDate		
    , @dailyFreq
    , @pracIDsStr
    , @detailsTrainingPracsJSON
    , @orpPracID
    , 1    
    , @today
    , @userID
    , @orpDocID
    , 5
    , @groupServiceClassNameID
	, @formBuilderQuestionsJSON
	, @formBuilderAnswersJSON  
	, @allowMultipleOrders  
	, @orderContextFieldName
  )
  
  set @recordID = SCOPE_IDENTITY()
  
  /*-------------------------------
   * Update newly created cross
   * reference record
   *------------------------------*/ 

  update dbo.ORP_DOCUMENTS 
  set 
      REFERENCE_ID                            = @recordID 
    , ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID = @orpDocStdNameID
  where (ID = @orpDocID)

end


/*###########################################################################
  # Edit Existing
  ###########################################################################*/  

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin

  -- audit data
  set @auditDataBeforeJSON = (		
	select top 1 t1.* from dbo.SvcJournal_Prescribed_Orders as t1 where t1.id = @recID
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES 
  ) 

  set @orpDocID = null
  
  select top 1
    @orpDocID = ORP_DOCUMENT_ID
  from dbo.SvcJournal_Prescribed_Orders   
  where ((id = @recID) and (clientID = @clientID))
    
  update dbo.ORP_DOCUMENTS 
  set   
    ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID = @orpDocStdNameID
  where (ID = @orpDocID)
  
  update dbo.SvcJournal_Prescribed_Orders 
  set  
      effectiveDate                = @effectiveDate
	, endDate                      = @endDate
	, svcName                      = @svcName
	, svcDesc                      = @svcDesc
	, noteCrit1                    = @noteCrit1
	, noteCrit2                    = @noteCrit2
	, noteCrit3                    = @noteCrit3
	, noteCrit4                    = @noteCrit4
	, noteCrit5                    = @noteCrit5
	, noteCrit6                    = @noteCrit6
	, noteCrit7                    = @noteCrit7
	, noteCrit8                    = @noteCrit8
	, noteCrit9                    = @noteCrit9
	, noteCrit10                   = @noteCrit10
	, noteObsvCmnt                 = @noteObsvCmnt
	, iep                          = @iep
	, frequency     			   = @frequency     	
	, projectedMinutes			   = @projectedMinutes	
	, planStartDate				   = @planStartDate	
	, planEndDate				   = @planEndDate		
	, dailyFreq                    = @dailyFreq
	, pracIDsStr                   = @pracIDsStr
    , detailsTrainingPracsJSON     = @detailsTrainingPracsJSON
    , orpPracID                    = @orpPracID
    , GROUP_SERVICE_CLASS_NAME_ID  = @groupServiceClassNameID
    , lastModified                 = @today
    , lastModifiedBy               = @userID
	, formBuilderQuestionsJSON     = @formBuilderQuestionsJSON
	, formBuilderAnswersJSON       = @formBuilderAnswersJSON
	, allowMultipleOrders  	       = @allowMultipleOrders  
	, orderContextFieldName	       = @orderContextFieldName
  where ((id = @recID) and (clientID = @clientID))
  
  set @recordID = @recID
      
end

/*============================================================
 * Save new or replace existing training details
 *============================================================*/  

delete dbo.SvcJournal_Prescribed_Orders_Prac_Training_Details where (prescribedOrderID = @recordID)

insert into dbo.SvcJournal_Prescribed_Orders_Prac_Training_Details
select 
    prescribedOrderID = @recordID 
  , pracID               = pracID
  , trainingDateTxt      = trainingDate   
  , trainingDateVal      = case when (trainingDate is not null) then convert(date,trainingDate) else null end
 
from @detailsTrainingPracs
  
/*============================================================
 * Save confirmation status (if applicable)
 *
 * (this is for both save new and edit)
 * 
 * Note:
 *
 * SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE 
 * will determine if the status should be saved or not
 *============================================================*/  

declare @statusConfirmationRuleIDApplied          bigint  
declare @createDirectAuthorizationRequestResponse bit     
declare @confirmStatusRecordID                    as bigint

exec dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE 
    @clientID
  , @patID
  , null /*@pracID */
  , @orpPracID
  , @orpAuthSvcDate
  , @orpAuthExpDate  /* Expiration date */
  , @svcAuthStatusConfirmRespCode
  , 20        /*@reqSvcAuthFromSelectionID*/
  , 1         /*@svcAuthorizationRequestTypeID*/
  , @recordID /*@referencedEntityID*/
  , @orpDocID
  , null      /*@serviceAuthorizationRequestID*/
  , 30        /*@entrySourceCode */
  , @today
  , @userID
  , @statusConfirmationRuleIDApplied          OUTPUT
  , @createDirectAuthorizationRequestResponse OUTPUT /* Should only be 1 if management of data is being passed to svc auth request system*/
  , @confirmStatusRecordID                    OUTPUT

/*============================================================
 * If a direct authorization request has been requested
 * then do so.
 *
 * Note: No auth status record has been created
 * yet since that will be the responsibility of the 
 * service authorization request/response system.
 *============================================================*/  

if (@createDirectAuthorizationRequestResponse = 1)
begin

  set @spDetails = ''
  declare @directAuthRecordID as bigint = null

  exec dbo.SERVICE_AUTHORIZATION_DIRECT_AUTHORIZE_SAVE_CORE 
      @userID
    , @userGroup
    , @userRank
    , @clientID
    , null /*@pracID (Direct auth sproc will attempt to find @pracID based on @userID */
    , @patID
    , @orpPracID
    , @orpAuthSvcDate
    , 1          /* @svcAuthorizationRequestTypeID (Orders) */
    , @recordID  /* @referencedEntityID (Order ID) */
    
	, @svcDesc
	, @formBuilderQuestionsJSON
	, @formBuilderAnswersJSON

	, @editDelReason 
    , @validateRec 
    , @MsgNoRec 
    , @MsgNoEdit
    , @MsgDupRec
    , @MsgDataError
    , @MsgNotActive  
    , @directAuthRecordID   OUTPUT
    , @spDetails            OUTPUT 
end

/*============================================================
 * If a approval is recorded then cancel any pending eauthorize
 * requests for this orp doc id
 *
 * Note: Direct auth process should do this for itself so
 *  we exclude them here
 *============================================================*/
 
exec dbo.SERVICE_AUTHORIZATION_REQUEST_CANCEL_PENDING_IF_ORP_APPROVED_OUTSIDE_OF_SAR_CORE
  @userID               
, @userGroup            
, @userRank             
, @clientID             
, @patID                
, @orpDocID             
, @createDirectAuthorizationRequestResponse
, @svcAuthStatusConfirmRespCode
, @validateRec
, @MsgNoRec   
, @MsgNoEdit 


/*-------------------------------
* Populate Audit History
*------------------------------*/

set @auditRecID = @recordID
if (@saveType = 2)
begin
	set @auditRecID = @recID
end

set @auditDataAfterJSON =(
  select top 1 t1.* from dbo.SvcJournal_Prescribed_Orders as t1 where t1.id = @auditRecID
  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES 
) 

exec dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_Audit_Save 
      @userID  					             
	, @userGroup				          
	, @userRank					           
	, @auditRecID					              
	, @saveType      			           
	, @auditDataBeforeJSON	   
	, @auditDataAfterJSON 						      

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


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_PRESCRIBED_ORDER_SAVE] TO [webuser]
GO
