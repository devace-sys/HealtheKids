USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_SAVE
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_SAVE]     
 (@userID             BIGINT,    
  @userGroup          INT,    
  @userRank           INT,    
  @clientID           BIGINT, 
  @patID              BIGINT, 
  @effectiveDate      DATE,
  @diagnosis          VARCHAR(8000),
  @mdOrders           VARCHAR(8000),
  @serviceDescription VARCHAR(8000),
  @expectedOutcomes   VARCHAR(8000),
  @allowMultipleOrders      BIT,
  @orderContextFieldName    VARCHAR(200),
  @formBuilderQuestionsJSON VARCHAR(max),
  @formBuilderAnswersJSON   VARCHAR(max),
  @iep                      bit,
  @frequency     			int,
  @projectedMinutes			int,
  @planStartDate			date,
  @planEndDate				date,
  @siteAide                 bit,
  @busAide                  bit,
  @pracIDsStr               varchar(8000),
  @detailsTrainingPracsJSON varchar(max),
  @detailsTrainingPracs ServiceJournalPractitionerTrainingDetails readonly,
  @orpPracID          BIGINT,
  @orpAuthSvcDate DATE,
  @orpAuthExpDate DATE,
  @svcAuthStatusConfirmRespCode BIGINT,
  @editDelReason      VARCHAR(7000),    
  @validateRec        BIT,    
  @saveType           INT,    
  @recID              BIGINT,
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
 * SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_SAVE */    
/**    
 * Creates or edits new service journal for the day
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

DECLARE @today               AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen            AS BIT            -- Is a transaction open   

declare @groupServiceClassPartID as bigint
declare @groupServiceClassNameID as bigint
declare @orpDocStdNameID         as bigint

-- varaibles related to audit table 

DECLARE @auditDataBeforeJSON As nvarchar(max)
	  , @auditDataAfterJSON  As nvarchar(max)
	  , @auditRecID          As Bigint


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
    
set @recordID   = 0    
set @spDetails  = ''    
set @today      = GETDATE()    
set @auditDataBeforeJSON = ''

set @groupServiceClassPartID = 5
set @groupServiceClassNameID = 3
set @orpDocStdNameID = null

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',   11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',     11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',   11, 1)    

/*-------------------------------
  * Get default service name sel
  * record
  *------------------------------*/ 
 
select top 1 
    @orpDocStdNameID = ssn.ID 
from dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES as ssn
where (
       (ssn.GROUP_SERVICE_CLASS_PARTITION_ID = @groupServiceClassPartID)  
  and (ssn.META_DFLT_SEL_FOR = 'PAT-PFL-AM')
)

if (isnull(@formBuilderQuestionsJSON, '') != '')
begin
	Select top 1 
		@serviceDescription = t1.[values]
	from dbo.FORM_BUILDER_COMBINE_QA_JSON_DATA (@formBuilderQuestionsJSON, @formBuilderAnswersJSON,1,0,1,0,0,0) as t1
	where t1.name='serviceDescription'
     
	Select top 1 
		@expectedOutcomes = t1.[values]
	from dbo.FORM_BUILDER_COMBINE_QA_JSON_DATA (@formBuilderQuestionsJSON, @formBuilderAnswersJSON,1,0,1,0,0,0) as t1
	where t1.name='expectedOutcomes'
		   
end


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
 * Determine if there are duplicate records
 *============================================================*/  

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

/*============================================================
 * Verify incoming parameters that are essential for edits
 *============================================================*/  
if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN

  /*-------------------------------
   * Record id is required
   *------------------------------*/ 

  IF (@recID IS NULL) RAISERROR ('Record id is required',   11, 1)
    
end


/*============================================================
 * Validation
 *============================================================*/  

IF (@validateRec = 1) 
BEGIN
  RETURN(0)    
END        

BEGIN TRANSACTION
SET @TranOpen = 1
  
/*============================================================
 * New
 *===========================================================*/   

if (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin
  
  /*-------------------------------
   * Delete duplicates 
   * (we warn user on 
   * save order/profile
   * screen this will happen)
   *------------------------------*/ 

  if (@hasDups = 1)
  begin
   
	while (@curIdx <= @maxIdx)
	begin
	    
	  select top 1 
	    @recIDToDelete = dr.id 
	  from @duplicateRecords as dr where (dr.idx = @curIdx)

	  exec dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_DELETE_CORE 
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
   * Create cross reference record
   *------------------------------*/ 

  declare @orpDocID as bigint = null            
  insert into dbo.ORP_DOCUMENTS (ORP_DOCUMENT_TYPE_ID) values (3)
  set @orpDocID = SCOPE_IDENTITY()
  
  /*-------------------------------
   * Create new record
   *------------------------------*/ 

  insert into dbo.SvcJournal_Service_Descriptions (
      clientID
    , patID
    , effectiveDate
    , diagnosis
    , mdOrders
    , serviceDescription
    , expectedOutcomes
    , iep
	, frequency     		
	, projectedMinutes			
    , planStartDate			
    , planEndDate				
    , siteAide
    , busAide
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
    , @diagnosis
    , @mdOrders
    , @serviceDescription
    , @expectedOutcomes
    , @iep
	, @frequency     		
	, @projectedMinutes			
    , @planStartDate			
    , @planEndDate	
    , @siteAide
    , @busAide
    , @pracIDsStr
    , @detailsTrainingPracsJSON
    , @orpPracID
    , 1
    , @today
    , @userID  
    , @orpDocID
    , 5
    , 3
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

/*============================================================
 * Editing existing
 *===========================================================*/   

else if (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
begin


  -- audit data
  set @auditDataBeforeJSON = (
    select top 1 t1.* from dbo.SvcJournal_Service_Descriptions as t1 where (t1.id = @recID)  
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
  )

  set @orpDocID = null
  
  select top 1  
    @orpDocID = t1.ORP_DOCUMENT_ID
  from dbo.SvcJournal_Service_Descriptions as t1  
  where ((id = @recID) and (clientID = @clientID))

  update 
    dbo.SvcJournal_Service_Descriptions 
  set 
      effectiveDate            = @effectiveDate
    , diagnosis                = @diagnosis    
    , mdOrders                 = @mdOrders
    , serviceDescription       = @serviceDescription
    , expectedOutcomes         = @expectedOutcomes
    , iep                      = @iep
	, frequency     		   = @frequency     	
	, projectedMinutes		   = @projectedMinutes	
    , planStartDate			   = @planStartDate		
    , planEndDate			   = @planEndDate		
    , siteAide                 = @siteAide
    , busAide                  = @busAide
    , pracIDsStr               = @pracIDsStr
    , detailsTrainingPracsJSON = @detailsTrainingPracsJSON
    , orpPracID                = @orpPracID    
    , lastModified             = @today
    , lastModifiedBy           = @userID
	, formBuilderQuestionsJSON = @formBuilderQuestionsJSON
	, formBuilderAnswersJSON   = @formBuilderAnswersJSON
	, allowMultipleOrders  	   = @allowMultipleOrders  
	, orderContextFieldName	   = @orderContextFieldName
  
  where 
    ((id = @recID) and (clientID = @clientID))
  
  set @recordID = @recID

end

else
begin
  RAISERROR ('Unsupported save type', 11, 1)
end


/*============================================================
 * Save new or replace existing training details
 *============================================================*/  

delete dbo.SvcJournal_Service_Descriptions_Prac_Training_Details where (serviceDescriptionID = @recordID)

insert into dbo.SvcJournal_Service_Descriptions_Prac_Training_Details
select 
    serviceDescriptionID = @recordID 
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
  , @orpAuthExpDate /* Expiration date */
  , @svcAuthStatusConfirmRespCode
  , 20        /*@reqSvcAuthFromSelectionID*/
  , 2         /*@svcAuthorizationRequestTypeID*/
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
    , 2          /* @svcAuthorizationRequestTypeID (Patient Profile) */
    , @recordID  /* @referencedEntityID (Patient profile (svcdesc) ID) */
    
	, @serviceDescription
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
 * we exclude them here
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

set @auditDataAfterJSON = (    
select top 1 t1.* from dbo.SvcJournal_Service_Descriptions as t1 where (t1.id = @auditRecID)  
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES)

exec dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_Audit_Save 
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


GRANT EXECUTE ON  [dbo].[SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_SAVE] TO [webuser]
GO
