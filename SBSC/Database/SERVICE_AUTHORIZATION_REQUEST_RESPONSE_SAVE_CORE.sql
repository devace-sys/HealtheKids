USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE_CORE](
    @userID                    BIGINT    
  , @userGroup                 INT  
  , @userRank                  INT 
  , @clientID                  BIGINT
  , @requestID                 BIGINT
  , @responseCode              BIGINT
  , @effectiveDate             DATE
  , @svcAuthRequestMsgUrlBase          varchar(512)
  , @svcAuthRequestPaperUploadUrlBase  varchar(512)
  , @pwdMinLen                 INT  
  , @editDelReason             VARCHAR(7000)
  , @validateRec               BIT
  , @saveType                  INT
  , @recID                     BIGINT
  , @MsgNoRec                  VARCHAR(1000)
  , @MsgNoEdit                 VARCHAR(1000)
  , @MsgDupRec                 VARCHAR(1000)
  , @MsgDataError              VARCHAR(1000)
  , @MsgNotActive              VARCHAR(1000)
  , @recordID                  BIGINT        OUTPUT
  , @jsonData                  varchar(max)  OUTPUT
  , @spDetails                 VARCHAR(8000) OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE_CORE */    
/**    
 * @returns spDetails       Validation or error details    
 * @returns saveType        1 = New record created, 2 = Existing record edited
 * @returns recordID        New record id or record id of user record that    
 *                          was modified  
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
declare @today                               as  datetime  
declare @prevRequestID                       as  bigint      = null
declare @nextRequestID                       as  bigint      = null
declare @responseCodeData                    as  varchar(max)
declare @userNeedsToDownloadRequest          as  bit
declare @userNeedsToDownloadRequestID        as  bigint
declare @userNeedsToDownloadRequestDialogTitle   as varchar(1000)
declare @userNeedsToDownloadRequestDialogContent as varchar(8000)

declare @requestDeclinedMessageTitleTemplate as  varchar(1000)
declare @requestDeclinedMessageBodyTemplate  as  varchar(8000)

declare @newUserAccountData as NEW_USER_ACCOUNT_DATA
declare @messages           as NOTIFICATION_MESSAGE_DATA

declare @responseCodeValueFlag as bit = null

BEGIN TRY    


/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',       11, 1)  
IF (@userID        IS NULL) RAISERROR ('user id is required',         11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',        11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',      11, 1)    
IF (@saveType      IS NULL) RAISERROR ('Save type is required',       11, 1)    
if (@requestID     is null) RAISERROR ('Request ID is required',      11, 1)  
if (@responseCode  is null) RAISERROR ('Response code is required',   11, 1)  

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  
    
SET @recordID   = 0    
SET @spDetails  = ''    
SET @today      = GETDATE()    
set @responseCodeData = '{}'
set @userNeedsToDownloadRequest    = 0
set @userNeedsToDownloadRequestID  = 0

/*============================================================
 * Init json data that will be returned
 *===========================================================*/  

exec dbo.SERVICE_AUTHORIZATION_GENERATE_REQUEST_OR_RESPONSE_RETURN_JSON_DATA
    1 
  , null
  , null
  , null
  , null
  , @newUserAccountData
  , @messages          
  , @jsonData OUTPUT


/*============================================================
 * Is user allowed to respond to this request and if so what
 * should be done in the case of an accept response.
 *===========================================================*/  

declare @userCanRespond                    as bit    = null
declare @entryRulesID                      as bigint = null
declare @nextReqSvcAuthFromSelectionID     as bigint = null
declare @responseAttestStatementID         as bigint = null
declare @personRoleCode                    as bigint  = null
declare @generatePermanentRecordOnApproved as bit = null

select top 1
   @userCanRespond                      = sardc.viewingUserCanCurrentlyAccessResponseForm  
  , @nextReqSvcAuthFromSelectionID       = sarer.nextReqSvcAuthFromSelectionID
  , @prevRequestID                       = sardc.prevRequestID
  , @requestDeclinedMessageTitleTemplate = sarer.requestDeclinedMessageTitleTemplate
  , @requestDeclinedMessageBodyTemplate  = sarer.requestDeclinedMessageBodyTemplate
  , @responseAttestStatementID           = sardc.responseAttestStatementID 
  , @personRoleCode                      = sardc.personRoleCode  
  , @generatePermanentRecordOnApproved   = sarer.generatePermanentRecordOnApproved

from dbo.SERVICE_AUTHORIZATION_REQUESTS_DATA_CORE (  @userID
                                                   , @userGroup
												   , @userRank
												   , @clientID
												   , null
												   , null
												   , null
												   , null
												   , null
												   , @requestID) as sardc

join dbo.SERVICE_AUTHORIZATION_REQUEST_ENTRY_RULES as sarer on sarer.id = sardc.svcAuthorizationRequestEntryRulesID

if (@userCanRespond is null) or (@userCanRespond = 0)
  RAISERROR ('You are not authorized to respond to this request or the request is no longer open or active.', 11, 1)  

/*============================================================
 * Find response code and its meta data
 *===========================================================*/  

declare @responseCodeID        as bigint = null
declare @responseCodeName      as varchar(512) = null
declare @effectiveDateRequired as bit = null
declare @notesRequired         as bit = null

select top 1 

   @responseCodeID        = sarrc.id
 , @responseCodeName      = sarrc.name 
 , @effectiveDateRequired = sarrc.effectiveDateRequired
 , @notesRequired         = sarrc.notesRequired

from dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_CODES as sarrc

where ((sarrc.code = @responseCode) and (sarrc.validUserResponse = 1))

if (@responseCodeID is null) RAISERROR ('Invalid response code', 11, 1)  

/*============================================================
 * Determine if response code is valid and if any additional
 * data needed to be provided with it
 *===========================================================*/  

if ((@effectiveDateRequired = 1) and (@effectiveDate is null))                 RAISERROR ('Please provide the authorization effective date', 11, 1)
if ((@notesRequired         = 1) and ((trim(isnull(@editDelReason,''))) = '')) RAISERROR ('Please provide notes', 11, 1)  

/*============================================================
 * Determine if we should close the request
 *===========================================================*/  

declare @closed as bit = 0 
if (@responseCode = 3000) set @closed = 1

/*============================================================
 * Set status confirm date defaults
 *===========================================================*/  

declare @statusConfirmEffDate as date 
declare @statusConfirmExpDate as date

set @statusConfirmEffDate = isnull(@effectiveDate,@today)
set @statusConfirmExpDate = @statusConfirmEffDate

/*============================================================
 * Save data
 *===========================================================*/  

/*-------------------------------
 * Save Response
 *------------------------------*/

insert into dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSES (
	requestID 
  , userID 
  , createdOn
  , responseCode
  , effectiveDate
  , responseNotes
  , responseAttestStatementID
  , personRoleCode
)
values (
    @requestID 
  , @userID
  , @today
  , @responseCode  
  , @effectiveDate
  , @editDelReason
  , @responseAttestStatementID /* Value attested to... this will either be the captured value or the current value depending on the person responding */
  , @personRoleCode            /* Role code of who is responding */
)

set @recordID = SCOPE_IDENTITY()


/*-------------------------------
 * Update request record
 *------------------------------*/
 
update dbo.SERVICE_AUTHORIZATION_REQUESTS
set    
    lastModified        = @today
  , lastModifiedBy      = @userID
  , currentResponseCode = @responseCode
  , currentResponseID   = @recordID
  , closed              = @closed

where (id = @requestID)

/*-------------------------------
 * Update status log
 *------------------------------*/

exec dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS @requestID, @today, @userID, 2000, @responseCodeData

set @responseCodeValueFlag = null

/*============================================================
 * If response was accept : 
 *
 * - Send notices (if required) (TODO: Implement if needed)
 * - Perform forwarding actions (if any)
 * - Perform data updates (TODO: Implement)
 *===========================================================*/  

if (@responseCode = 3000) 
begin
  
  set @responseCodeValueFlag = 1

  /*-------------------------------
   * Change expiration date
   * for confirm status to 
   * Date Effective + 1 year
   *------------------------------*/
  
  set @statusConfirmExpDate = dateadd(year,1,@statusConfirmEffDate)

  /*-------------------------------
   * Forwarding actions
   *------------------------------*/

  if (@nextReqSvcAuthFromSelectionID is not null)
  begin

    /* New paper request*/

    declare @fwdReqSvcAuthMethodSelectionID as bigint        = 20
    
	declare @nextRequestJsonData            as varchar(max)  = null
    declare @nextRequestSpDetails           as VARCHAR(8000) = null

    exec dbo.SERVICE_AUTHORIZATION_REQUEST_FORWARD_SAVE_CORE 
        @userID  
      , @userGroup 
      , @userRank 
      , @today
	  , @requestID 
      , @nextReqSvcAuthFromSelectionID
      , @fwdReqSvcAuthMethodSelectionID 
      , @svcAuthRequestMsgUrlBase   
	  , @svcAuthRequestPaperUploadUrlBase
      , @pwdMinLen  
      , @editDelReason 
      , @validateRec  
      , @MsgNoRec  
      , @MsgNoEdit 
      , @MsgDupRec 
	  , @MsgDataError
      , @MsgNotActive 
      , @nextRequestID         OUTPUT
      , @nextRequestJsonData   OUTPUT
      , @nextRequestSpDetails  OUTPUT

	/* Extract data from nextRequestJSON data here */

    set @userNeedsToDownloadRequest    = 0
    set @userNeedsToDownloadRequestID  = 0	  
	set @userNeedsToDownloadRequestDialogTitle = ''
	set @userNeedsToDownloadRequestDialogContent = ''
	
	select 
	  @userNeedsToDownloadRequest              = userNeedsToDownloadRequest
    , @userNeedsToDownloadRequestID            = userNeedsToDownloadRequestID
	, @userNeedsToDownloadRequestDialogTitle   = userNeedsToDownloadRequestDialogTitle
	, @userNeedsToDownloadRequestDialogContent = userNeedsToDownloadRequestDialogContent 
    from OPENJSON ( @nextRequestJsonData )
    with (
        userNeedsToDownloadRequest  bit
      , userNeedsToDownloadRequestID  bigint
	  , userNeedsToDownloadRequestDialogTitle varchar(1000)
	  , userNeedsToDownloadRequestDialogContent varchar(8000)
    )

	insert into @messages
	select *
	from OPENJSON ( @nextRequestJsonData, '$.messages')	
    with (
       fromUserID          bigint
     , fromUserName        nvarchar(256)
     , fromEmail           nvarchar(256)
     , forUserID           bigint
     , forUserName         nvarchar(256)
     , forEmail            nvarchar(256)
     , msgTitle            varchar(1000)
     , msgBody             varchar(max)
     , msgIsHTML           bit
   )

   insert into @newUserAccountData
   select *
   from OPENJSON ( @nextRequestJsonData, '$.accounts')	
   with (
	     userName         nvarchar(256)
      ,  firstName        nvarchar(128)
      ,  lastName         nvarchar(128)
      ,  email            nvarchar(256)
      ,  phone            nvarchar(14)  
      ,  pwd              varchar(255)
      ,  districtOrClientName       varchar(1000)
      ,  helpOrQuestionsContactInfo varchar(max)
      ,  msgTemplateTitle           varchar(1000)
      ,  msgTemplateBody            varchar(max)
   )

  end

  /*-------------------------------
   * Mark for file upload  
   * generation actions
   *------------------------------*/

  if (@generatePermanentRecordOnApproved = 1)
  begin
    insert into dbo.SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORDS ( 
      requestID   
    , systemWillGenerateFileUpload
    , fileUploadPending
    , uploadID
    , created 
    , createdBy  /* Needs to be userID of who saved response */
    , lastModified
    , lastModifiedBy
    , active
  ) 
  values (
    @requestID
    ,1
    ,1
    ,null
    ,@today
    ,@userID /* Needs to be userID of who saved response */
    ,null
    ,null
    ,1)
  
  end

end

/*============================================================
 * If response was decline :
 *
 * - Followup notices
 * - Followup actions (if needed)
 * - Perform data updates (TODO: Implement)
 *===========================================================*/  

if (@responseCode = 4000)
begin

  set @responseCodeValueFlag = 0

  /*-------------------------------
   * Followup notice to district
   * contact/rendering prac
   * (rdp)
   *------------------------------*/

  insert into @messages
  select top 1
      fromUserID   = 0
    , fromUserName = ''
    , fromEmail    = ''
    , forUserID    = u.userrid
    , forUserName  = u.UserName
    , forEmail     = m.Email
    , msgTitle     = 'A Service Authorization Request Was Declined'
    , msgBody      = '<p>Hello,</p>'
    +'<p>We are informing you that an authorization request was recently declined by either a parent or ORP professional.</p>'
    +'<p>Please log in to '
    + '<a href="'+ @svcAuthRequestMsgUrlBase + u.userName + '">www.SpEdCare.com</a>'
    + ' and review Request ID : ' + convert(varchar(50),@requestID)
    +' to see who declined the request and the explanation for the decision.</p>'
    + '<p>This is an automatically generated email.  Please do not reply to it.<p>'
    +'<hr/>'
    +'<p>'
    +'CONFIDENTIALITY: This communication and any documents, files, or previous e-mail messages attached to it constitute an electronic communication within the scope of the Electronic Communication Privacy Act, 18 USCA 2510. This communication may contain non-public, confidential, or legally privileged information intended for the sole use of the designated recipient(s). The unlawful interception, use or disclosure of such information is strictly prohibited under 18 USCA 2511 and any applicable laws. If you are not the intended recipient of this communication, you are hereby notified to destroy all copies of this e-mail message and to contact the sender.'
    +'</p>'
    , convert(bit,1) /* IsHTML */
  
  from dbo.SERVICE_AUTHORIZATION_REQUEST_AUTHORIZED_USERS  as au
  join users.dbo.Users                                     as u on u.userrid = au.userID
  join users.dbo.Membership                                as m on m.UserId  = u.UserId

  where (
        (au.requestID = @requestID)
    and (au.serviceAuthorizationPersonRoleCode = 40) 
    and (@responseCode = 4000) 
  )

  /*-------------------------------
   * Followup actions
   * TODO: Implement if needed
   *------------------------------*/

  /*-------------------------------
   * Update status log
   *------------------------------*/

  exec dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS @requestID, @today, @userID, 2200, @responseCodeData

end


/*============================================================
 * Save confirmation status (if applicable)
 *
 * Note:
 *
 * SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE 
 * will determine if the status should be saved or not
 *============================================================*/  

declare @statusConfirmationRuleIDApplied          bigint  
declare @createDirectAuthorizationRequestResponse bit     
declare @confirmStatusRecordID                    as bigint
declare @confirmStatusResponseCode                as bigint
declare @patID                                    as bigint   
declare @pracID                                   as bigint   
declare @orpPracID                                as bigint   
declare @svcStartDate                             as date     
declare @reqSvcAuthFromSelectionID                as bigint   
declare @svcAuthorizationRequestTypeID            as bigint   
declare @referencedEntityID                       as bigint   
declare @orpDocID                                 as bigint   

/*============================================================
 * Retrieve additional data about the request
 *============================================================*/  

select top 1
    @patID                         = sar.patID
  , @pracID                        = sar.pracID
  , @orpPracID                     = sar.orpPracID
  , @svcStartDate                  = sar.svcStartDate 
  , @reqSvcAuthFromSelectionID     = sar.reqSvcAuthFromSelectionID
  , @svcAuthorizationRequestTypeID = sar.svcAuthorizationRequestTypeID
  , @referencedEntityID            = sar.referencedEntityID
  , @orpDocID                      = sar.orpDocID
  , @clientID                      = sar.clientID -- In cases where client id was not available
from dbo.SERVICE_AUTHORIZATION_REQUESTS as sar
where
  (sar.id = @requestID)

/*============================================================
 * Retrieve confirm status code that matches auth request
 * response code
 *============================================================*/  

select top 1 
  @confirmStatusResponseCode = t1.code 
from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_RESPONSE_CODES as t1
where t1.serviceAuthorizationRequestResponseCode = @responseCode

/*============================================================
 * Manage confirmation data
 *============================================================*/  

exec dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_MANAGE_DATA_CORE 
    @clientID
  , @patID
  , @pracID
  , @orpPracID
  , @statusConfirmEffDate
  , @statusConfirmExpDate
  , @confirmStatusResponseCode
  , @reqSvcAuthFromSelectionID
  , @svcAuthorizationRequestTypeID
  , @referencedEntityID
  , @orpDocID
  , @requestID /*@serviceAuthorizationRequestID*/
  , 15        /*@entrySourceCode */
  , @today
  , @userID
  , @statusConfirmationRuleIDApplied          OUTPUT
  , @createDirectAuthorizationRequestResponse OUTPUT /* Should NEVER be 1 in this context */
  , @confirmStatusRecordID                    OUTPUT
   
/*============================================================
 * Manage data updates for specific request types
 *===========================================================*/  

if (@svcAuthorizationRequestTypeID = 3)
begin

  declare @updateState          as smallint
  declare @patientAuditRecordID as bigint     

  set @updateState   = dbo.CONST_REC_STATE_MOD()
  
  UPDATE pp
  SET 
      pp.parentConsentMCAL              = @responseCodeValueFlag
    , pp.parentConsentMCALEffectiveDate = @effectiveDate
    , pp.LAST_UPDATED                   = @today
    , pp.userID                         = @userID
    , pp.[state]                        = @updateState

  from [dbo].[PATIENTS_Client] as pc
  join [dbo].PATIENTS_Patient  as pp on pp.PATIENT_ID = pc.PATIENT_ID
  where (
           (pc.CLIENT_ID  = @clientID)
       and (pp.PATIENT_ID = @patID)
  )
  
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
  
  EXEC PATIENT_Audit @patID, @today, @userID, 2, @updateState, 'From service authorization request response for parental consent for MCAL billing', @patientAuditRecordID output

end


/*============================================================
 * Closing actions
 *===========================================================*/  

if (@closed = 1)
begin
  
  /*-------------------------------
   * If the request is now closed
   * update status log again
   *------------------------------*/

  exec dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS @requestID, @today, @userID, 9999, null

end


/*============================================================
 * Serialize data
 * for passing back in our return parameter.
 *===========================================================*/   

exec dbo.SERVICE_AUTHORIZATION_GENERATE_REQUEST_OR_RESPONSE_RETURN_JSON_DATA
    0 
  , @userNeedsToDownloadRequest
  , @userNeedsToDownloadRequestID
  , @userNeedsToDownloadRequestDialogTitle
  , @userNeedsToDownloadRequestDialogContent
  , @newUserAccountData
  , @messages          
  , @jsonData OUTPUT


/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
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
      
     
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
     
  -- SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_RESPONSE_SAVE_CORE] TO [webuser]
GO
