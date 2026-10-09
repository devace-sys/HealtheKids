USE SPEDMON
GO

/*
 * THIS ROUTINE CONTAINS EXPANSION HOOKS FOR E-AUTHORIZE
 * Add additional code if needed to support new request types
 */

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_SAVE_CORE
GO

/*-------------------------------
 * Create
 *------------------------------*/

CREATE PROCEDURE [dbo].[SERVICE_AUTHORIZATION_REQUEST_SAVE_CORE] (
    @userID                            BIGINT
  , @userGroup                         INT
  , @userRank                          INT
  , @clientID                          BIGINT
  , @districtContactUserID             BIGINT
  , @patID                             BIGINT
  , @svcAuthorizationEntrySourceID     bigint
  , @svcAuthorizationEntryPurposeID    bigint
  , @svcAuthorizationRequestTypeID     BIGINT
  , @referencedEntityID                BIGINT
  , @svcDescription                    VARCHAR (8000)
  , @formBuilderQuestionsJSON          VARCHAR(max)
  , @formBuilderAnswersJSON            VARCHAR(max)
  , @reqSvcAuthFromSelectionID         BIGINT
  , @reqSvcAuthMethodSelectionID       BIGINT
  , @prtGrd1PersonID                   BIGINT
  , @prtGrd2PersonID                   BIGINT
  , @orpPracID                         BIGINT
  , @selectedFileList                  VARCHAR(max)
  , @pwdMinLen                         INT
  , @svcAuthRequestMsgUrlBase          varchar(512)
  , @svcAuthRequestPaperUploadUrlBase  varchar(512)
  , @editDelReason                     VARCHAR(7000)
  , @validateRec                       BIT
  , @saveType                          INT
  , @recID                             BIGINT
  , @MsgNoRec                          VARCHAR(1000)
  , @MsgNoEdit                         VARCHAR(1000)
  , @MsgDupRec                         VARCHAR(1000)
  , @MsgDataError                      VARCHAR(1000)
  , @MsgNotActive                      VARCHAR(1000)
  , @recordID                          BIGINT        OUTPUT
  , @jsonData                          varchar(max)  OUTPUT
  , @spDetails                         VARCHAR(8000) OUTPUT )
AS
BEGIN

/***************************************************************************
 * SERVICE_AUTHORIZATION_REQUEST_SAVE_CORE */
/**
 * Creates new or edits existing
 *
 * @param   userID          The userid of who saved the record
 * @param   userGroup       Users group
 * @param   userRank        User rank
 * @param   clientID        Client id
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

declare @today                               as datetime       
declare @idCheck                             as bit     = null
declare @svcAuthorizationEntryRulesID        as bigint  = null
declare @referencedEntityIDRequired          as bit     = null
declare @svcSelectionTypeID                  as  bigint         /* 1 = ORP Document Standard Service Name */
declare @svcSelectionNameID                  as  bigint
declare @svcName                             as  varchar(1000) = ''
declare @svcStartDate                        as  date        = null

declare @referencedEntityGroupSvcClassNameID as  bigint      = null
declare @referencedEntityFileClass           as  bigint      = null
declare @referencedEntityFileNameSpace       as varchar(500) = null
declare @referencedEntityFileSource          as varchar(500) = null

declare @hasFileIncludes                        as  bit
declare @fileClassInclude                       as  bigint
declare @fileNameSpaceInclude                   as  varchar(500)
declare @fileSourceInclude                      as  varchar(500)
declare @filesToIncludeUseClientIdDataParameter as  bit
declare @filesToIncludeUsePracIdDataParameter   as  bit
declare @filesToIncludeUsePatIdDataParameter    as  bit
declare @filesToIncludeUploadIds                as varchar(max) = ''
declare @filesToIncludeUploadNames              as varchar(max) = ''

declare @refEntityPatID                    as bigint        = -1
declare @prtGrdRequired                    as bit = 0
declare @orpRequired                       as bit = 0
declare @emailRequired                     as bit = 0
declare @userAccountRequired               as bit = 0
declare @placeAddressRequired              as bit = 0
declare @rdpAndORPCanBeSame                as bit = 0
declare @automaticApprovalResponse         as bit = 0
declare @rdpAndOrpMustBeTheSame            as bit = 0
declare @saveSvcAuthStatConf               as bit = 0
declare @districtContactMustBePractitioner as bit = 0;

declare @prtGrdProvided                    as bit = 0
declare @prtGrd1Provided                   as bit = 0
declare @prtGrd1FirstName                  as nvarchar(128)
declare @prtGrd1LastName                   as nvarchar(128)
declare @prtGrd1Email                      as varchar(255) = ''
declare @prtGrd1Phone                      as varchar(255)
declare @prtGrd1PlaceAddress               as varchar(2000)
declare @prtGrd1UserIdInt                  as bigint

declare @prtGrd2Provided                   as bit = 0
declare @prtGrd2FirstName                  as nvarchar(128)
declare @prtGrd2LastName                   as nvarchar(128)
declare @prtGrd2Email                      as varchar(255) = ''
declare @prtGrd2Phone                      as varchar(255)
declare @prtGrd2PlaceAddress               as varchar(2000)
declare @prtGrd2UserIdInt                  as bigint

declare @orpProvided                    as bit = 0
declare @orpPracFirstName               as nvarchar(128)
declare @orpPracLastName                as nvarchar(128)
declare @orpPracEmail                   as nvarchar(50)
declare @orpPracPhone                   as nvarchar(14)
declare @orpPracPlaceAddress            as varchar(2500)
declare @orpPracUserIdInt               as bigint

declare @orpPracEmployeeRelationshipID  as bigint
declare @orpDocID                       as bigint

declare @pracID                         as bigint
declare @pracName                       as varchar(256)
declare @pracEmail                      as nvarchar(50) = N''
declare @pracPhone                      as nvarchar(14) = N''
declare @pracUserIdInt                  as bigint
declare @pracEmployeeRelationshipID     as bigint

declare @duConEmail                     as nvarchar(256)  
declare @duConPhone                     as nvarchar(14)
declare @duConName                      as nvarchar(257)


declare @pracAndORPAreSame             as bit = 0

declare @helpOrQuestionContactInfo      as varchar(1000) = ''
declare @clientName                     as varchar(1000)

declare @raUserName                     as nvarchar(256)
declare @raFirstName                    as nvarchar(128)
declare @raLastName                     as nvarchar(128)
declare @raEmail                        as varchar(255) = ''

declare @prevSvcDescription             as varchar(8000)
--declare @formBuilderQuestionsJSON       as varchar(max)
declare @prevFormBuilderAnswersJSON     as varchar(max)
declare @prevOrpPracID                  as bigint
declare @updateReferencedEntity         as bit = 0
declare @referencedEntityChanges        as varchar(max)
declare @expectedOutcomes               as varchar(8000)

declare @userNeedsToDownloadRequest              as bit
declare @userNeedsToDownloadRequestID            as bigint
declare @userNeedsToDownloadRequestDialogTitle   as varchar(1000)
declare @userNeedsToDownloadRequestDialogContent as varchar(8000)

declare @returnPaperFormMessageTitleTemplate as varchar(1000)
declare @returnPaperFormMessageBodyTemplate  as varchar(8000)

declare @returnPaperFormDialogTitleTemplate as varchar(1000)
declare @returnPaperFormDialogBodyTemplate  as varchar(8000)

declare @minIdx as bigint
declare @maxIdx as bigint
declare @curIdx as bigint

declare @dupCount                       as int = 0

declare @orpAttestStatementID as bigint = null
declare @pg1AttestStatementID as bigint = null
declare @pg2AttestStatementID as bigint = null

declare @delSpDetails  as VARCHAR(8000) = null
declare @delRecordID   as bigint = null

declare @dupRecords as table (
   idx bigint identity(1,1)
  ,id  bigint
)

declare @userAccountsToSetup as table (
    idx             bigint identity(1,1)
  , personID        bigint
  , userName        nvarchar(256)
  , roleID          bigint
  , serviceAuthorizationPersonRoleCode bigint
  , firstName       nvarchar(128)
  , lastName        nvarchar(128)
  , email           nvarchar(256)
  , phone           nvarchar(14)
  , dupMsg          varchar(1000)
)

declare @pracRecsToUpdate as table (
    PRACTITIONER_ID bigint
  , USER_ID_INT bigint
  , USER_ID_UID uniqueidentifier
)

declare @authorizedUsers as table (
    userID                             bigint
  , serviceAuthorizationPersonRoleCode bigint
  , responseRequired                   bit
)

/*============================================================
 * Care Plan Authorization Variables
 *===========================================================*/

DECLARE @carePlanParticipantUserIDs as table ( -- will hold user IDs of plan participants who need to authorize plan
	  idx    bigint identity(1,1)
	, userID bigint
)

declare @newUserAccountData               as NEW_USER_ACCOUNT_DATA
declare @messages                         as NOTIFICATION_MESSAGE_DATA

BEGIN TRY

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/

SET @recordID   = 0
SET @spDetails  = ''
SET @today      = GETDATE()
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
 * Verify incoming parameters that are essential for proper op
 *============================================================*/

IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',       11, 1)
IF (@userID        IS NULL) RAISERROR ('user id is required',         11, 1)
IF (@userRank      IS NULL) RAISERROR ('userRank is required',        11, 1)
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',      11, 1)
IF (@saveType      IS NULL) RAISERROR ('Save type is required',       11, 1)

if (@clientID                       is null) RAISERROR ('Client ID is required',                      11, 1)
if (@patID                          is null) RAISERROR ('Patient ID is required',                     11, 1)
if (@districtContactUserID          is null) RAISERROR ('Please select a district contact',           11, 1)
if (@svcAuthorizationEntrySourceID  is null) RAISERROR ('Authorization entry source id is required',  11, 1)
if (@svcAuthorizationEntryPurposeID is null) RAISERROR ('Authorization entry purpose id is required', 11, 1)
if (@svcAuthorizationRequestTypeID  is null) RAISERROR ('Authorization request type is required',     11, 1)
if (@reqSvcAuthFromSelectionID      is null) RAISERROR ('Authorization from who id is required',      11, 1)
if (@reqSvcAuthMethodSelectionID    is null) RAISERROR ('Authorization method id is required',        11, 1)
if (@saveType != dbo.CONST_SAVE_TYPE_NEW())  RAISERROR ('Save type not suppported', 11, 1)

/*============================================================
 * Validate request entry options
 *============================================================*/

set @svcAuthorizationEntryRulesID = null

select top 1

    @svcAuthorizationEntryRulesID        = sarer.id
  , @referencedEntityIDRequired          = sarer.referencedEntityRequired
  , @prtGrdRequired                      = sarer.prtGrdSelectionRequired
  , @orpRequired                         = sarer.orpSelectionRequired
  , @emailRequired                       = sarer.emailRequired
  , @placeAddressRequired                = sarer.placeAddressRequired
  , @userAccountRequired                 = sarer.userAccountRequired
  , @userNeedsToDownloadRequest          = convert(bit,(case when sarer.reqSvcAuthMethodSelectionID = 20 then 1 else 0 end))
  , @returnPaperFormMessageTitleTemplate = sarer.returnPaperFormMessageTitleTemplate
  , @returnPaperFormMessageBodyTemplate  = sarer.returnPaperFormMessageBodyTemplate
  , @returnPaperFormDialogTitleTemplate  = sarer.returnPaperFormDialogTitleTemplate
  , @returnPaperFormDialogBodyTemplate   = sarer.returnPaperFormDialogBodyTemplate
  , @rdpAndORPCanBeSame                  = sarer.rdpAndORPCanBeSame
  , @automaticApprovalResponse           = sarer.automaticApprovalResponse
  , @rdpAndOrpMustBeTheSame              = sarer.rdpAndOrpMustBeTheSame
  , @saveSvcAuthStatConf                 = sarer.saveSvcAuthStatConf
  , @districtContactMustBePractitioner = sarer.districtContactMustBePractitioner

from dbo.SERVICE_AUTHORIZATION_REQUEST_ENTRY_RULES as sarer

where (
        (sarer.reqSvcAuthEntrySourceID       = @svcAuthorizationEntrySourceID)
    and (sarer.reqSvcAuthEntryPurposeID      = @svcAuthorizationEntryPurposeID)
    and (sarer.reqSvcAuthMethodSelectionID   = @reqSvcAuthMethodSelectionID)
    and (sarer.svcAuthorizationRequestTypeID = @svcAuthorizationRequestTypeID)
    and (sarer.reqSvcAuthFromSelectionID     = @reqSvcAuthFromSelectionID)
	and (sarer.active                        = 1)
)

if (@svcAuthorizationEntryRulesID is null) RAISERROR ('This type of service authorization request is invalid or not supported', 11, 1)  

/*============================================================
 * Validate patient id
 *============================================================*/

set @idCheck = null

select top 1

    @idCheck    = pap.PATIENT_ID
  , @clientName = trim(isnull(clc.CLIENT_NAME,N''))

from dbo.CLIENTS_Client   as clc
join dbo.PATIENTS_Client  as pac on pac.CLIENT_ID  = clc.CLIENT_ID
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pac.PATIENT_ID

where (
      (clc.CLIENT_ID   = @clientID)
  and (pac.CLIENT_ID   = @clientID)
  and (pac.PATIENT_ID  = @patID)
  and (pap.PATIENT_ID  = @patID)
)

if (@idCheck is null) RAISERROR ('Patient not found', 11, 1)

/*============================================================
 * Validate district contact
 * District contact must always be a user
 *============================================================*/
 
set @idCheck = null
set @pracID  = null

select top 1 
    @idCheck    = ua.id
  , @duConName  = trim(isnull(ua.name, N''))
  , @duConEmail = trim(isnull(ua.email,N''))
  , @duConPhone = trim(isnull(ua.phone,N''))
  , @pracID     = ua.pracID
from [users].dbo.[USERS_ALL] as ua
where ( 
      (ua.id          = @districtContactUserID)
  and (ua.clientID    = @clientID) 
  and (ua.appName     = users.dbo.CONST_APP_NAME_SPEDCARE())
  and (ua.userGroupID = 1) /* Limit to district contacts only */
)


if (@idCheck is null) RAISERROR ('District contact not found or user is not associated with district', 11, 1)
if (@duConEmail = '') RAISERROR ('District contact must have an email address', 11, 1)
  
/*============================================================
 * Further validation of district contact in cases where
 * the district contact must be a particular type of user
 *============================================================*/

if (@districtContactMustBePractitioner = 1)
begin

  if (@pracID is null) RAISERROR ('District contact must be a practitioner', 11, 1)

  set @idCheck = null

  select top 1 
      @idCheck                    = prp.PRACTITIONER_ID 
    , @pracEmployeeRelationshipID = prp.employeeRelationshipID
	, @pracUserIdInt              = prp.UserID

  from dbo.PRACTITIONER_Practitioner as prp
  where 
    (prp.PRACTITIONER_ID = @pracID)

  if (@idCheck is null) RAISERROR ('District contact must be a practitioner and the practitioner record was not found', 11, 1)

  if (@pracEmployeeRelationshipID not in (10,20))
  RAISERROR ('The practitioner selected as the district contact must have an employment relationship with the district.  The record for this practitioner in SpEdCare indicates there is NO employment relationship with the district.', 11, 1)

end

/*============================================================
 * Create contact string for new account and notification
 * emails.
 *============================================================*/

set @helpOrQuestionContactInfo = @duConName
                                 + ' <a href="mailto:'
								 + @duConEmail
								 + '">'
								 + @duConEmail
								 + '</a>'
								 + ' '
								 + isnull(@duConPhone,'')

/*============================================================
 * Make sure dup parent/guardians are not selected
 *============================================================*/

if ((@prtGrd1PersonID is not null) and (@prtGrd2PersonID is not null))
begin
  if (@prtGrd1PersonID = @prtGrd2PersonID)
  begin
    RAISERROR ('Parent guardian selections cannot be the same', 11, 1)
  end
end

/*============================================================
 * Check if the district contact (rdp) and orp can be the
 * same.  This only applies to requests where the district
 * contact has to be a practitioner 
 *============================================================*/

if (@districtContactMustBePractitioner = 1)
begin

  if (@orpPracID is not null)
  begin
    if (@orpPracID = @pracID)
    begin
      set @pracAndORPAreSame = 1
	  if (@rdpAndORPCanBeSame = 0) RAISERROR ('District contact and ORP selections cannot be the same.', 11, 1)
    end
    else
    begin
      set @pracAndORPAreSame = 0
	  if (@rdpAndOrpMustBeTheSame = 1) RAISERROR ('District contact and ORP selection must be the same.', 11, 1)
    end
  end
end

/*============================================================
 * Validate referenced entity and get related data
 * if a referenced entitiy is required (at present this is
 * all cases)
 *============================================================*/

if (@referencedEntityIDRequired = 1)
begin

  if (@referencedEntityID is null) RAISERROR ('Reference record id required', 11, 1)

  set @idCheck = null

  select
      @idCheck                                = t1.referencedEntityID
	, @referencedEntityGroupSvcClassNameID    = t1.groupSvcClassNameID
    , @referencedEntityFileClass              = t1.fileClass
    , @referencedEntityFileNameSpace          = t1.fileNameSpace
    , @referencedEntityFileSource             = t1.fileSource
    , @refEntityPatID                         = t1.patID
    , @svcSelectionTypeID                     = t1.svcSelectionTypeID
    , @svcSelectionNameID                     = t1.svcSelectionNameID
	, @svcName                                = t1.svcName
	, @svcStartDate                           = t1.svcStartDate
    , @prevSvcDescription                     = isnull(t1.svcDescription,'')
	, @prevFormBuilderAnswersJSON             = isnull(t1.formBuilderAnswersJSON, '')
	--, @formBuilderQuestionsJSON               = t1.formBuilderQuestionsJSON
    , @prevOrpPracID                          = isnull(t1.orpPracID,-1)
    , @orpDocID                               = t1.orpDocID
  
    , @hasFileIncludes                        = t1.hasFileIncludes                      
    , @fileClassInclude                       = t1.fileClassInclude                       
    , @fileNameSpaceInclude                   = t1.fileNameSpaceInclude                  
    , @fileSourceInclude                      = t1.fileSourceInclude                    
    , @filesToIncludeUseClientIdDataParameter = t1.filesToIncludeUseClientIdDataParameter 
    , @filesToIncludeUsePracIdDataParameter   = t1.filesToIncludeUsePracIdDataParameter
    , @filesToIncludeUsePatIdDataParameter    = t1.filesToIncludeUsePatIdDataParameter    

  from dbo.SERVICE_AUTHORIZATION_REQUEST_GET_RELATED_DATA_REFERENCED_ENTITY_AND_FILE_CLASS_DETAIL (
      @userID
    , @userGroup
    , @userRank
    , @clientID
    , @svcAuthorizationRequestTypeID
    , @referencedEntityID ) as t1

  if (@idCheck is null)          RAISERROR ('Referenced record not found', 11, 1)
  if (@refEntityPatID != @patID) RAISERROR ('Referenced record patient id does not match request patient id', 11, 1)
 
 /*-------------------------------
   * Order/Prescription or
   * Patient Profile
   *------------------------------*/
  
  if (@svcAuthorizationRequestTypeID in (1,2)) /* Expansion hook:  Add request types here if needed */
  begin

	/* Use existing service description / form data in direct authorization cases */

	if( (@automaticApprovalResponse = 1) and (@svcDescription is null))
	begin
	  set @svcDescription = @prevSvcDescription
	end
	
	/* Determine if the referenced entity need to be updated? */

	if ((CHECKSUM(@prevSvcDescription) != CHECKSUM(@svcDescription)) or (@prevOrpPracID != @orpPracID))
    begin
      set @updateReferencedEntity = 1
    end
	else
	begin
	  set @updateReferencedEntity = 0
	end

   if( (@automaticApprovalResponse = 1) and (@formBuilderAnswersJSON is null))
	begin
	  set @formBuilderAnswersJSON = @prevFormBuilderAnswersJSON
	end

	if ((CHECKSUM(@prevFormBuilderAnswersJSON) != CHECKSUM(@formBuilderAnswersJSON)) or (@prevOrpPracID != @orpPracID))
    begin
      set @updateReferencedEntity = 1
    end
	else
	begin
	  set @updateReferencedEntity = 0
	end
  end
  /*else if  .. */
  /* Expansion hook:  Add request types here if needed */

end

/*============================================================
 * Validate parent guardian(s) IF parent/guardians are
 * required as part of this request
 *============================================================*/

if (@prtGrdRequired = 1)
begin

  set @prtGrdProvided = 0

  /*-------------------------------
   * Patient/guardian 1
   *------------------------------*/

  if (@prtGrd1PersonID is not null)
  begin

    set @prtGrdProvided  = 1
	set @prtGrd1Provided = 1

    set @idCheck = null

    select top 1
	    @idCheck             = id
	  , @prtGrd1FirstName    = firstName
	  , @prtGrd1LastName     = lastName
	  , @prtGrd1Email        = trim(isnull(email,''))
	  , @prtGrd1Phone        = phone
	  , @prtGrd1PlaceAddress = placeAddress
	  , @prtGrd1UserIdInt    = userIDInt

     from dbo.PATIENT_PERSONS_VIEW_CORE (  @userID
                                         , @userGroup
                                         , @userRank
                                         , @clientID
                                         , @patID
                                         , 1
                                         , null
                                         , 1
                                         , @prtGrd1PersonID
										 , null)

    if (@idCheck is null) RAISERROR ('Parent/guardian 1 was not found or is not related to patient', 11, 1)

	if ((@emailRequired = 1) and (@prtGrd1Email = ''))
	  RAISERROR ('Please provide an email for parent/guardian 1', 11, 1)

  end

  /*-------------------------------
   * Patient/guardian 2
   *------------------------------*/

  if (@prtGrd2PersonID is not null)
  begin

    set @prtGrdProvided = 1
	set @prtGrd2Provided = 1

    set @idCheck = null

	select top 1

	    @idCheck             = id
	  , @prtGrd2FirstName    = firstName
	  , @prtGrd2LastName     = lastName
	  , @prtGrd2Email        = trim(isnull(email,''))
	  , @prtGrd2Phone        = phone
	  , @prtGrd2PlaceAddress = placeAddress
	  , @prtGrd2UserIdInt    = userIDInt

    from dbo.PATIENT_PERSONS_VIEW_CORE (  @userID
                                        , @userGroup
                                        , @userRank
                                        , @clientID
                                        , @patID
                                        , 1
                                        , null
                                        , 1
                                        , @prtGrd2PersonID
										, null)

	if (@idCheck is null) RAISERROR ('Parent/guardian 2 was not found or is not related to patient', 11, 1)

	if ((@emailRequired = 1) and (@prtGrd2Email = ''))
	  RAISERROR ('Please provide an email address for parent/guardian 2', 11, 1)

  end

  if (@prtGrdProvided = 0)
  begin
     RAISERROR ('Please select at least one parent or guardian', 11, 1)
  end
end

/*============================================================
 * Validate orp professional IF the orp professional is
 * required as part of this request
 *============================================================*/

if (@orpRequired = 1)
begin

   if (@orpPracID is null)
   begin
     RAISERROR ('Please select an ORP professional', 11, 1)
   end
   else
   begin

	  set @orpProvided = 1
      set @idCheck     = null

      select top 1

	     @idCheck                       = pp.PRACTITIONER_ID
       , @orpPracFirstName              = pp.FIRST_NAME
       , @orpPracLastName               = pp.LAST_NAME
	   , @orpPracEmail                  = trim(isnull(pp.EMAIL,N''))
       , @orpPracPhone                  = trim(isnull(pp.PHONE_NUMBER,N''))
       , @orpPracPlaceAddress           = dbo.BUILD_PLACE_ADDRESS_STRING (pp.street1, pp.street2, pp.city, pp.usState, pp.zip5, pp.zip4, 0)
	   , @orpPracUserIdInt              = pp.UserID
	   , @orpPracEmployeeRelationshipID = employeeRelationshipID

      from dbo.PRACTITIONER_Practitioner as pp
      where (pp.PRACTITIONER_ID = @orpPracID)

	  if (@idCheck is null) RAISERROR ('ORP professional not found', 11, 1)

	  if ((@emailRequired = 1) and (@orpPracEmail= N''))
	    RAISERROR ('Please provide an email address for the ORP professional', 11, 1)

	  /* This is a district ORP without a user account.  Exit */

	  if ((@orpPracEmployeeRelationshipID in (10,20)) and (@userAccountRequired = 1) and (@orpPracUserIdInt is null))
	    RAISERROR ('The ORP professional record in SpEdCare indicates that the practitioner has an employment relationship with the district but no SpEdCare user account.  Please request or create a SpEdCare account for this practitioner.', 11, 1)

	  /* This is a third party orp with no account association.  Since its a third party
	     check if they have an account already setup with another client.
		 If they do have an account flag the practioner record for update when we are saving changes. */

	  if ((@orpPracEmployeeRelationshipID = 30) and (@userAccountRequired = 1) and (@orpPracUserIdInt is null))
	  begin

       declare @orpPracUserIdUID as uniqueidentifier

	    select top 1
            @orpPracUserIdInt = u.userrid
		  , @orpPracUserIdUID = u.UserId

        from Users.dbo.Users        as u
        join Users.dbo.Membership   as m  on m.UserId  = u.UserId
        join Users.dbo.UsersInRoles as ur on ur.UserId = m.UserId
        join Users.dbo.Roles        as r  on r.RoleId  = ur.RoleId
        join Users.dbo.RoleData     as rd on rd.RoleId = r.RoleId

        where (
              (u.UserName   = @orpPracEmail)
          and (rd.userGroup = 3)
          and (rd.id = 11)
        )

		/* Third party orp has an existing account.  Mark the practitioner record for update. */

		if (@orpPracUserIdInt is not null)
		begin
		  insert into @pracRecsToUpdate values (@orpPracID, @orpPracUserIdInt, @orpPracUserIdUID)
		end

	  end
   end
end


/*============================================================
 * Get request author info
 *============================================================*/

select top 1
    @raUserName   = u.UserName
  , @raFirstName  = trim(isnull(m.FirstName,N''))
  , @raLastName   = trim(isnull(m.LastName,N''))
  , @raEmail      = trim(isnull(m.Email,N''))
from Users.dbo.Users        as u
join Users.dbo.Membership   as m  on m.UserId  = u.UserId
where (u.userrid = @userID)

/*============================================================
 * Reject self authorization requests from practitioners who
 * are not qualified
 *============================================================*/
  
/*-------------------------------
 * Order/Prescription or
 * Patient Profile
 *------------------------------*/
 
if (
      (@referencedEntityIDRequired = 1)
  and (@districtContactMustBePractitioner = 1)
  and (@svcAuthorizationRequestTypeID in (1,2)) /* Expansion hook:  Add request types here if needed */
  and (@orpRequired               = 1)
  and (@rdpAndORPCanBeSame        = 1)
  and (@rdpAndOrpMustBeTheSame    = 1)
  and (@automaticApprovalResponse = 1)
  and (@pracID    is not null)
  and (@orpPracID is not null)
)
begin
  if (dbo.PRACTITIONER_IS_POTENTIAL_ORP_FOR_GROUP_SERVICE_CLASS_NAME_ID (  @clientID
                                                                          , @orpPracID
																		  , @referencedEntityGroupSvcClassNameID) = 0)
  begin
    RAISERROR ('The ORP selected is not qualified to review an authorization request for this type of service', 11, 1)
  end
end
/*else if ...*/
/* Expansion hook:  Add request types here if needed */

/*============================================================
 * Add user ids to provide access to at least the district
 * contact if the district contact is not already a district
 * admin or pcal staff member,  since these types of users
 * have access already granted.  This leaves only cases 
 * where the district contact MUST be a practitioner.
 *
 * Note: We handle request author access later on 
 *============================================================*/

if not exists (select top 1 userrid from dbo.SERVICE_AUTHORIZATION_REQUESTS_IMPLIED_USERS_DATA_CORE(@districtContactUserID, @clientID))
begin

  
  if (@districtContactMustBePractitioner = 1)
  begin
    if (@pracAndORPAreSame = 0)
    begin

      /* District contact (RDP) and ORP are not same  */

      insert into @authorizedUsers values (@pracUserIdInt  ,40, 0)

    end
    else
    begin

      /*
       * District contact (RDP) and ORP are the same
       * Note: We check if the RDP and ORP can be the same earlier and exit if they cannot
       */

      insert into @authorizedUsers values (   @pracUserIdInt
                                            , 100, /* Combined rdp/ord person role code */
		    							        1 )   /* Response required is set to 1 */
    end
  end
end

/*============================================================
 * Setup new user account data (if neccessary)
 * otherwise add existing accounts to authorized user
 * depending on persons role
 *============================================================*/

if (@userAccountRequired = 1)
begin

  if (@prtGrdRequired = 1)
  begin

	/*-------------------------------
     * Patient/guardian 1
     *------------------------------*/

	if (@prtGrd1Provided = 1)
	begin
	  if (@prtGrd1UserIdInt is null)
	  begin
	    insert into @userAccountsToSetup values (@prtGrd1PersonID, @prtGrd1Email,12,10,@prtGrd1FirstName, @prtGrd1LastName, @prtGrd1Email, @prtGrd1Phone,'Username in use already')
	  end
	  else
	  begin
	    insert into @authorizedUsers values (@prtGrd1UserIdInt,10,1)
	  end
	end

	/*-------------------------------
     * Patient/guardian 2
     *------------------------------*/

	if (@prtGrd2Provided = 1)
	begin

	  if (@prtGrd2UserIdInt is null)
	  begin
        insert into @userAccountsToSetup values (@prtGrd2PersonID, @prtGrd2Email,12, 20, @prtGrd2FirstName, @prtGrd2LastName, @prtGrd2Email, @prtGrd2Phone,'Username in use already')
	  end
	  else
	  begin
	    insert into @authorizedUsers values (@prtGrd2UserIdInt,20,1)
	  end
	end
  end

  /*-------------------------------
   * Third party orp professional
   *------------------------------*/

  if ((@orpRequired = 1) and (@orpProvided = 1))
  begin

	/*
	 * No account found either with this or other client
	 */

	if (@orpPracUserIdInt is null)
	begin

	  /* Only non employment relationship with client (third party)
	   * ORPs that have employement relationship with the client
	   * are permitted to have an account setup here
	   */

	  if (@orpPracEmployeeRelationshipID = 30)
	  begin
	    insert into @userAccountsToSetup values (@orpPracID, @orpPracEmail,11, 30, @orpPracFirstName, @orpPracLastName, @orpPracEmail, @orpPracPhone, 'Username in use already')
	  end
	end
	else
	begin
      if (@pracAndORPAreSame = 0)
	  begin
	    insert into @authorizedUsers values (@orpPracUserIdInt,30,1)
	  end
	end
  end

  /*-------------------------------
   * Prevalidate account data
   *------------------------------*/

  if exists (select email from @userAccountsToSetup as t1 group by t1.email having count(idx) > 1)
  begin
    RAISERROR ('Each person involved in this authorization request must have a unique email address', 11, 1)
  end

end


/*============================================================
 * Check for duplicate requests
 *
 * Note: This is authorization request type specific logic
 * A dup check must be implemented for each request type
 *===========================================================*/

set @dupCount = 0

if (@referencedEntityIDRequired = 1)
begin
    insert into @dupRecords
	  select
        id
      from dbo.SERVICE_AUTHORIZATION_REQUESTS
      where (
            (clientID                                = @clientID)
        and (patID                                   = @patID)
        and (svcAuthorizationRequestTypeID           = @svcAuthorizationRequestTypeID)
        and (referencedEntityID                      = @referencedEntityID)
        and (currentResponseCode                     = 2000) /* Pending*/
        and (closed                                  = 0)
        and (active                                  = 1)
		and (svcAuthorizationRequestEntryPurposeID   = @svcAuthorizationEntryPurposeID)
		and (reqSvcAuthFromSelectionID               = @reqSvcAuthFromSelectionID)
		and (reqSvcAuthMethodSelectionID             = @reqSvcAuthMethodSelectionID)
     )
  
end

select @dupCount = count(id) from @dupRecords

/*============================================================
 * Get current attest statement ids for persons who are supposed
 * to respond
 *============================================================*/

select top 1
   @pg1AttestStatementID  = prrat.responseAttestStatementID 
from dbo.SERVICE_AUTHORIZATION_PERSON_ROLE_CODES                         as saprc
join dbo.SERVICE_AUTHORIZATION_PERSON_REQUEST_RESPONSE_ATTEST_STATEMENTS as prrat on prrat.personRoleCode = saprc.code
where ( 
    (saprc.code = 10)
and (prrat.svcAuthorizationRequestTypeID = @svcAuthorizationRequestTypeID)
and (prrat.active = 1)
)

select top 1
  @pg2AttestStatementID  = prrat.responseAttestStatementID 
from dbo.SERVICE_AUTHORIZATION_PERSON_ROLE_CODES                         as saprc
join dbo.SERVICE_AUTHORIZATION_PERSON_REQUEST_RESPONSE_ATTEST_STATEMENTS as prrat on prrat.personRoleCode = saprc.code
where (
    (saprc.code = 20)
and (prrat.svcAuthorizationRequestTypeID = @svcAuthorizationRequestTypeID)
and (prrat.active = 1)
)

select top 1
  @orpAttestStatementID  = prrat.responseAttestStatementID 
from dbo.SERVICE_AUTHORIZATION_PERSON_ROLE_CODES                         as saprc
join dbo.SERVICE_AUTHORIZATION_PERSON_REQUEST_RESPONSE_ATTEST_STATEMENTS as prrat on prrat.personRoleCode = saprc.code
where (
    (saprc.code = 30)
and (prrat.svcAuthorizationRequestTypeID = @svcAuthorizationRequestTypeID)
and (prrat.active = 1)
)


/*============================================================
 * Validation Only Exit
 *============================================================*/

IF (@validateRec = 1)
BEGIN
  SET @recordID = 0
  RETURN(0)
END

/*============================================================
 * If we have duplicate requests, cancel them
 *============================================================*/

if (@dupCount > 0)
begin

  set @minIdx = null
  set @maxIdx = null
  set @curIdx = null
  select @minIdx = min(idx) from @dupRecords
  select @maxIdx = max(idx) from @dupRecords

  set @curIdx = @minIdx

  while (@curIdx <= @maxIdx)
  begin
    declare @requestID as bigint

	select top 1 @requestID = id from @dupRecords where idx = @curIdx

	set @delSpDetails  = ''
    set @delRecordID   = @requestID

	exec dbo.SERVICE_AUTHORIZATION_REQUEST_DELETE_CORE  @userID
	                                                  , @userGroup
													  , @userRank
													  ,'Canceling pending duplicate request'
													  , @validateRec
													  , @requestID
													  , @MsgNoRec
													  , @MsgNoEdit
													  , @delSpDetails OUTPUT
													  , @delRecordID  OUTPUT

	set @curIdx = @curIdx + 1
  end
end


/*============================================================
 * Update practitioner records with user account data if
 * neccessary.  This only applies to third party pracs who
 * do not have an employement relationship with the client
 * and @pracRecsToUpdate should only contain those types of
 * records.
 *===========================================================*/

if (@userAccountRequired = 1)
begin

  update prp
  set
      prp.UserID      = pru.USER_ID_INT
    , prp.PRAC_ASP_ID = pru.USER_ID_UID
  from dbo.PRACTITIONER_Practitioner as prp
  join @pracRecsToUpdate             as pru on pru.PRACTITIONER_ID = prp.PRACTITIONER_ID

end

/*============================================================
 * Create request
 *===========================================================*/

insert into dbo.SERVICE_AUTHORIZATION_REQUESTS (
	clientID
  , pracID
  , patID
  , svcAuthorizationRequestTypeID
  , referencedEntityID
  , groupSvcClassNameID
  , fileClass
  , fileNameSpace
  , fileSource
  , svcSelectionTypeID
  , svcSelectionNameID
  , svcName
  , svcDescription
  , formBuilderQuestionsJSON
  , formBuilderAnswersJSON
  , svcStartDate
  , reqSvcAuthFromSelectionID
  , reqSvcAuthMethodSelectionID
  , prtGrd1PersonID
  , prtGrd2PersonID
  , orpPracID
  , closed
  , created
  , createdBy
  , currentResponseCode
  , currentResponseID
  , active
  , svcAuthorizationRequestEntrySourceID
  , svcAuthorizationRequestEntryPurposeID
  , svcAuthorizationRequestEntryRulesID
  , pg1AttestStatementID
  , pg2AttestStatementID
  , orpAttestStatementID
  , orpDocID
  , districtContactUserID
  , hasFileIncludes
  , fileClassInclude
  , fileNameSpaceInclude
  , fileSourceInclude 
  , filesToIncludeUseClientIdDataParameter
  , filesToIncludeUsePracIdDataParameter 
  , filesToIncludeUsePatIdDataParameter 
  , filesToIncludeUploadIds  
  , filesToIncludeUploadNames
)

values (
	@clientID
  , @pracID
  , @patID
  , @svcAuthorizationRequestTypeID
  , @referencedEntityID
  , @referencedEntityGroupSvcClassNameID
  , @referencedEntityFileClass
  , @referencedEntityFileNameSpace
  , @referencedEntityFileSource
  , @svcSelectionTypeID
  , @svcSelectionNameID
  , @svcName
  , @svcDescription
  , @formBuilderQuestionsJSON
  , @formBuilderAnswersJSON
  , @svcStartDate
  , @reqSvcAuthFromSelectionID
  , @reqSvcAuthMethodSelectionID
  , @prtGrd1PersonID
  , @prtGrd2PersonID
  , @orpPracID
  , 0 /* Not closed */
  , @today
  , @userID
  , 2000 /* Response required */
  , null /* No current response id */
  , 1    /* Active*/
  , @svcAuthorizationEntrySourceID
  , @svcAuthorizationEntryPurposeID
  , @svcAuthorizationEntryRulesID
  , @pg1AttestStatementID
  , @pg2AttestStatementID
  , @orpAttestStatementID
  , @orpDocID
  , @districtContactUserID
  , @hasFileIncludes
  , @fileClassInclude
  , @fileNameSpaceInclude
  , @fileSourceInclude 
  , @filesToIncludeUseClientIdDataParameter
  , @filesToIncludeUsePracIdDataParameter 
  , @filesToIncludeUsePatIdDataParameter 
  , @filesToIncludeUploadIds  
  , @filesToIncludeUploadNames  )

set @recordID = SCOPE_IDENTITY()

/*============================================================
 * If file includes are supported
 *============================================================*/

if (@hasFileIncludes = 1)
begin

  exec dbo.SERVICE_AUTHORIZATION_REQUEST_MANAGE_INCLUDED_FILES_CORE @recordID, @selectedFileList,@userID, @today
 
end

/*============================================================
 * Save confirmation status as PENDING (if applicable)
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
  , @pracID
  , @orpPracID
  , @today
  , @today /* Expiration date */
  , 200  /* Pending */
  , @reqSvcAuthFromSelectionID
  , @svcAuthorizationRequestTypeID
  , @referencedEntityID
  , @orpDocID
  , @recordID /*@serviceAuthorizationRequestID*/
  , 15        /*@entrySourceCode */
  , @today
  , @userID
  , @statusConfirmationRuleIDApplied          OUTPUT
  , @createDirectAuthorizationRequestResponse OUTPUT /* Should NEVER be 1 in this context */
  , @confirmStatusRecordID                    OUTPUT

/*-------------------------------
 * Generate product key for
 * use on printed requests
 *------------------------------*/

 update dbo.SERVICE_AUTHORIZATION_REQUESTS
   set productKey = dbo.GENERATE_PRODUCT_KEY (@recordID,'SAR',2,5,2,1)
 where ID = @recordID

if (@userNeedstoDownloadRequest = 1) set @userNeedstoDownloadRequestID = @recordID

/*-------------------------------
 * Update status log
 *------------------------------*/

exec dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS @recordID, @today, @userID, 100, null

/*============================================================
 * Update reference entity if entity is required and
 * update is needed
 *
 * Note: This is done here because we need the
 * newly generated request id for the status log
 *===========================================================*/

if ((@referencedEntityIDRequired = 1) and (@updateReferencedEntity = 1))
begin

  /*-------------------------------
   * Order
   *------------------------------*/

  if (@svcAuthorizationRequestTypeID = 1)
  begin

	update dbo.SvcJournal_Prescribed_Orders
	 set
	    svcDesc                   = @svcDescription
	  , formBuilderQuestionsJSON  = @formBuilderQuestionsJSON
	  , formBuilderAnswersJSON    = @formBuilderAnswersJSON
	  , orpPracID                 = @orpPracID
	  , lastModified              = @today
	  , lastModifiedBy            = @userID
	where (id = @referencedEntityID)

  end

  /*-------------------------------
   * Patient Profile
   *------------------------------*/

  else if (@svcAuthorizationRequestTypeID = 2)
  begin

    select 
		@expectedOutcomes = sjsd.expectedOutcomes
	from dbo.SvcJournal_Service_Descriptions as sjsd
	where (id = @referencedEntityID)

    if (isnull(@formBuilderQuestionsJSON, '') != '')
	begin
		select top 1 
			@svcDescription = t1.[values]
		from dbo.FORM_BUILDER_COMBINE_QA_JSON_DATA (@formBuilderQuestionsJSON, @formBuilderAnswersJSON,1,0,1,0,0,0) as t1
		where t1.name='serviceDescription'
     

		select top 1 
			@expectedOutcomes = t1.[values]
		from dbo.FORM_BUILDER_COMBINE_QA_JSON_DATA (@formBuilderQuestionsJSON, @formBuilderAnswersJSON,1,0,1,0,0,0) as t1
		where t1.name='expectedOutcomes'

		   
	end

	update dbo.SvcJournal_Service_Descriptions
	set
	    mdOrders                 = @svcDescription
	  , serviceDescription       = @svcDescription
	  , expectedOutcomes         = @expectedOutcomes
	  , formBuilderQuestionsJSON = @formBuilderQuestionsJSON
	  , formBuilderAnswersJSON   = @formBuilderAnswersJSON	
	  , orpPracID      = @orpPracID
	  , lastModified   = @today
	  , lastModifiedBy = @userID
	where (id = @referencedEntityID)

  end

  /*else if ...*/
  /* Expansion hook:  Add request types here if needed */
   
  /*-------------------------------
   * Status context data
   *------------------------------*/
  
  if ((@svcAuthorizationRequestTypeID in (1,2)))
  begin
    set @referencedEntityChanges = (
      select top 1 * from (
        select
		     prevSvcDescription         = @prevSvcDescription
           , newSvcDescription          = @svcDescription
	       , prevOrpPracID              = @prevOrpPracID
	       , newOrpPracID               = @orpPracID
		   , prevFormBuilderAnswersJSON = @prevFormBuilderAnswersJSON
		   , formBuilderAnswersJSON     = @formBuilderAnswersJSON
        ) q1
      FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES)


  end
  /*else if ...*/
  /* Expansion hook:  Add request types here if needed */

  /*-------------------------------
   * Update status log
   *------------------------------*/

  exec dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS @recordID, @today, @userID, 200, @referencedEntityChanges

end

/*============================================================
 * Setup user accounts if neccessary (same for all save types)
 * Note: This is done here because we need the
 * newly generated request id for the status log
 *============================================================*/

set @minIdx = null
set @maxIdx = null
set @curIdx = null
select @minIdx = min(idx) from @userAccountsToSetup
select @maxIdx = max(idx) from @userAccountsToSetup
set @curIdx = @minIdx


while (@curIdx <= @maxIdx)
begin


  declare @newUserPersonID              as bigint         = null
  declare @newUserName                  as nvarchar(256)  = null
  declare @newUserRoleID                as bigint         = null
  declare @newUserSvcAuthPersonRoleCode as bigint         = null
  declare @newUserFirstName             as nvarchar(128)  = null
  declare @newUserLastName              as nvarchar(128)  = null
  declare @newUserEmail                 as nvarchar(256)  = null
  declare @newUserPhone                 as nvarchar(14)   = null
  declare @dupAcctMsg                   as varchar(1000)  = null
  declare @newUserID                    as bigint         = null
  declare @newUserAccountJSONData       as varchar(max)   = null

  select top 1

      @newUserPersonID              = t1.personID
    , @newUserRoleID                = t1.roleID
	, @newUserSvcAuthPersonRoleCode = t1.serviceAuthorizationPersonRoleCode
    , @newUserName                  = t1.userName
    , @newUserFirstName = t1.firstName
    , @newUserLastName  = t1.lastName
	, @newUserEmail     = t1.email
	, @newUserPhone     = t1.phone
	, @dupAcctMsg       = t1.dupMsg
  from @userAccountsToSetup as t1
  where (t1.idx = @curIdx)

  exec users.dbo.USERS_SAVE_CORE
      @userID
    , @userGroup
    , @userRank
    , 'spedcare'
	, null  /* @selpaID         bigint*/
    , @clientID
    , @newUserPersonID
    , @newUserRoleID
    , @newUserName
    , @pwdMinLen
    , @newUserFirstName
	, @newUserLastName
    , @newUserEmail
    , @newUserPhone
    , 1    /* Receive email notifications */
    , null /* Rec id */
    , ''   /* Edit del reason */
    , 0    /* Validate */
    , 1    /* Save type */
    , @MsgNotActive
    , @dupAcctMsg
    , @MsgNoRec
    , @MsgNoEdit
    , @MsgDataError
    , @newUserID              OUTPUT
    , @newUserAccountJSONData OUTPUT
    , @spDetails              OUTPUT

  /*-------------------------------
   * Update status log
   *------------------------------*/

  exec dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS @recordID, @today, @userID, 300, @newUserAccountJSONData

  /*-------------------------------
   * Add user id for access
   *------------------------------*/

  insert into @authorizedUsers values (@newUserID,@newUserSvcAuthPersonRoleCode,1)

  /*-------------------------------
   * Accumulate new accounts data (if any)
   * for passing back in our return parameter.
   * We will use this data to email the users
   * their account info.
   *------------------------------*/

  insert into @newUserAccountData
  select *
  from OPENJSON ( @newUserAccountJSONData, '$.accounts' )
  with (
      userName         nvarchar(256)
    , firstName        nvarchar(128)
    , lastName         nvarchar(128)
    , email            nvarchar(256)
    , phone            nvarchar(14)
    , pwd              varchar(255)
	, districtOrClientName varchar(1000)
    , helpOrQuestionsContactInfo varchar(max)
    , msgTemplateTitle varchar(1000)
    , msgTemplateBody  varchar(max)
  )


  set @curIdx = @curIdx + 1

end

/* Account setup does not provide districtOrClient name
 * or helpOrQuestionsContactInfo.  We provide them here.
 */

update @newUserAccountData
set
  districtOrClientName       = @clientName
, helpOrQuestionsContactInfo = @helpOrQuestionContactInfo


/*============================================================
 * Add request author to assigned users if the author
 *
 * - does not already exist in the assigned users
 * - is not already a district admin or pcal staff member
 *
 * Since these types of users have access already granted
 *===========================================================*/

if not exists (select top 1 userrid from dbo.SERVICE_AUTHORIZATION_REQUESTS_IMPLIED_USERS_DATA_CORE(@userID,@clientID))
begin
  if not exists (select top 1 au.userID from @authorizedUsers as au where userID = @userID)
  begin
    insert into @authorizedUsers values (@userID, 50, 0)
  end
end

/*============================================================
 * Assign authorized users
 * Note: This is done here because we need the
 * newly generated request id for the status log
 *===========================================================*/

/*-------------------------------
 * Assign
 *------------------------------*/

insert into dbo.SERVICE_AUTHORIZATION_REQUEST_AUTHORIZED_USERS
select
    requestID                          = @recordID
  , userID                             = au.userID
  , serviceAuthorizationPersonRoleCode = au.serviceAuthorizationPersonRoleCode
  , responseRequired                   = au.responseRequired
  , prrat.responseAttestStatementID
from @authorizedUsers                              as au
join dbo.SERVICE_AUTHORIZATION_PERSON_ROLE_CODES   as saprc on saprc.code = au.serviceAuthorizationPersonRoleCode
join dbo.SERVICE_AUTHORIZATION_PERSON_REQUEST_RESPONSE_ATTEST_STATEMENTS as prrat on prrat.personRoleCode = saprc.code
where
(
      (prrat.svcAuthorizationRequestTypeID = @svcAuthorizationRequestTypeID)
  and (prrat.active = 1)
)

/*-------------------------------
 * Update status log
 *------------------------------*/

exec dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS @recordID, @today, @userID, 400, @jsonData


/*============================================================
 * Guard against nulls in message parms that are not taken
 * care of in earlier parts of this sproc
 *
 * Note: The parm concat will create a null if any of the 
 * parms are null.  This will result in a message that 
 * has just empty strings put into the placeholders.
 *===========================================================*/

set @svcAuthRequestMsgUrlBase = trim(isnull(@svcAuthRequestMsgUrlBase,''))

/*============================================================
 * Retrieve respondants accounts data
 * for passing back in our return parameter.
 *
 * We will use this data to email the respondants
 * a notice that they have requests to review.
 *
 * Internal ORPS will also get a notice via SpEdCare when they login.
 *===========================================================*/

/*
1= District Name
2= Orp or Parent/Guardian Name
3= District Contact
4= Link
*/

insert into @messages
select
    fromUserID   = 0
  , fromUserName = ''
  , fromEmail    = ''
  , forUserID    = u.userrid
  , forUserName  = u.UserName
  , forEmail     = m.Email
  , msgTitle     = 'Service Authorization Request from ' + @clientName + ' via SpEdCare'
  , msgBody      = dbo.STRING_CREATE  (  saprc.requestMessageBodyTemplate
                                       ,          @clientName
					                     + '|' +  trim(convert(varchar,isnull(m.FirstName,N'')))
						                 + '|' +  trim(@helpOrQuestionContactInfo)
						                 + '|' +  @svcAuthRequestMsgUrlBase + trim(convert(varchar,isnull(u.UserName,'')))
                                       , '|'
                                       , 1 )
   , msgIsHTML = convert(bit,1) /* IsHTML */

from @authorizedUsers                            as au

join dbo.SERVICE_AUTHORIZATION_PERSON_ROLE_CODES as saprc on saprc.code = au.serviceAuthorizationPersonRoleCode

join users.dbo.Users                             as u     on u.userrid = au.userID
join users.dbo.Membership                        as m     on m.UserId = u.UserId
join users.dbo.UsersInRoles                      as ur    on ur.UserId = m.UserId
join users.dbo.Roles                             as r     on r.RoleID = ur.RoleID
join users.dbo.RoleData                          as rd    on rd.RoleID = r.RoleId

where (      (au.responseRequired = 1)
	    and (@automaticApprovalResponse = 0) /* Automatic approval is not going to happen. */
)


/*============================================================
 * If this service request requires we download it (paper)
 * then email the request author
 *===========================================================*/

if (@userNeedsToDownloadRequest = 1)
begin

/*
  1 = Request Author First Name
  2 = District Name
  3 = District Contact
  4 = Upload Link

*/

  insert into @messages
  select
      fromUserID   = 0
    , fromUserName = ''
    , fromEmail    = ''
    , forUserID    = @userID
    , forUserName  = @raUserName
    , forEmail     = @raEmail
    , msgTitle     = 'Service Authorization Request from ' + @clientName + ' via SpEdCare'
    , msgBody      = dbo.STRING_CREATE  ( @returnPaperFormMessageBodyTemplate
                                          ,        @raFirstName
					                       + '|' + @clientName
										   + '|' + @svcAuthRequestPaperUploadUrlBase
                                         , '|'
                                       , 1 )
    , msgIsHTML = convert(bit,1) /* IsHTML */

   set  @userNeedsToDownloadRequestDialogTitle = @returnPaperFormDialogTitleTemplate
   set  @userNeedsToDownloadRequestDialogContent = dbo.STRING_CREATE  ( @returnPaperFormDialogBodyTemplate
                                          ,        @raFirstName
					                       + '|' + @clientName
										   + '|' + @svcAuthRequestPaperUploadUrlBase
                                         , '|'
                                       , 1 )
end

/*============================================================
 * Save messages prepared for diagnostic reasons and if they
 * are needed for reporting
 * Note: This is new as of 6/15/2021 and data has NOT been
 * backfilled.
 *===========================================================*/

insert into dbo.SERVICE_AUTHORIZATION_REQUEST_MESSAGES
select 
   requestID = @recordID
  ,msgs.*
from @messages as msgs

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
 * All done
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

GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_SAVE_CORE] TO [webuser]
GO
