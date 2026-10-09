USE [users]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USERS_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.USERS_SAVE_CORE
GO


IF EXISTS (select * from sys.table_types where name = 'NEW_USER_ACCOUNT_DATA')
BEGIN
  DROP TYPE NEW_USER_ACCOUNT_DATA
END
GO

/*-------------------------------
 * New user account data
 * Keep in synch with the
 * following :
 *
 * SQL Table Types
 * - Users.NEW_USER_ACCOUNT_DATA
 * - Spedmon.NEW_USER_ACCOUNT_DATA
 *
 * C# Classes
 * - MBA.NewUserAccount
 *------------------------------*/

CREATE TYPE NEW_USER_ACCOUNT_DATA AS TABLE
(
     userName         nvarchar(256)
  ,  firstName        nvarchar(128)
  ,  lastName         nvarchar(128)
  ,  email            nvarchar(256)
  ,  phone            nvarchar(14)
  ,  pwd              varchar(255)
  ,  districtOrClientName varchar(1000)
  ,  helpOrQuestionsContactInfo varchar(max)
  ,  msgTemplateTitle varchar(1000)
  ,  msgTemplateBody  varchar(max)
)
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[USERS_SAVE_CORE] (
    @userID          BIGINT
  , @userGroup       INT
  , @userRank        INT
  , @appName         varchar(50)
  , @selpaCode         bigint
  , @clientID        bigint
  , @personID        bigint
  , @roleID          bigint
  , @username        NVARCHAR(256)
  , @pwdMinLen       int
  , @firstname       NVARCHAR(128)
  , @lastname        NVARCHAR(128)
  , @email           NVARCHAR(256)
  , @phone           NVARCHAR(14)
  , @receiveEmailNotifications bit
  , @recID           INT
  , @editDelReason   VARCHAR(7000)
  , @validateRec     BIT
  , @saveType        INT
  , @MsgNotActive    VARCHAR(1000)
  , @MsgDupRec       VARCHAR(1000)
  , @MsgNoRec        VARCHAR(1000)
  , @MsgNoEdit       VARCHAR(1000)
  , @MsgDataError    VARCHAR(1000)
  , @recordID        BIGINT        OUTPUT
  , @jsonData        varchar(max)  OUTPUT
  , @spDetails       VARCHAR(8000) OUTPUT

)
AS
BEGIN

/***************************************************************************
 * USERS_SAVE_CORE */
/**
 * Creates a new or edits existing user account record
 * and manages any associated records.
 *
 * Note: This sproc is not stand along.  It should be called from other
 * sprocs within a transaction block.
 *
 * @param   userID          The userID of who is requesting the new user account
 * @param   userGroup       That users group
 * @param   userRank        That user rank
 * @param   appName         Application name (from web.config)
 * @param   clientID        New users clientID (if any)
 * @param   associateWithID Associate with external entity id
 * @param   roleID          roleId of user
 * @param   username        New users username
 * @param   password        New users password
 * @param   firstname       New users first name
 * @param   lastname        New users last name
 * @param   email           New users email
 * @param   phone           New users phone number
 * @param   recID           Record id of existing USER record to edit
 * @param   validateRec     1 = Performs data integrity validation tasks
 *                              Perform advisory validation tasks that can
 *                              only be conducted by referencing data from the
 *                              database and then exits WITHOUT saving the record
 *                          0 = Peform data integrity validation tasks and
 *                              if these tasks succeed peforms the desired
 *                              operation (saveType) on the record and exits
 * @param   saveType        Type of operation to perform
 *                          1 = New, 2 = Edit, 3 = Delete
 * @param   MsgNoRec        Desired error message if a recID is not found
 * @param   MsgNoEdit       Desired error message if a record cannot be edited
 * @param   MsgDupRec       Desired error message for duplicate detection
 * @param   MsgNoClient     Desired error message if a clientID is not found
 * @param   MsgDataError    Desired error message for data errors
 * @returns spDetails       Validation or error details
 * @returns recordID        New record id or record id of user record that
 *                          was changed or deleted
 ***************************************************************************/

SET NOCOUNT ON

declare @password                    as NVARCHAR(128) = N''
DECLARE @today                       as DATETIME       -- Current date/time stamp
DECLARE @minDateTime                 as DATETIME       -- Min. value for date/time
DECLARE @dupCount                    as INT            -- Duplicate counter used for validation
DECLARE @updateState                 as SMALLINT       -- Indicates what state the record is left in
DECLARE @auditRecID                  as BIGINT         -- Audit record id
DECLARE @valPass                     as BIT
DECLARE @canEdit                     as BIT
DECLARE @isActive                    as BIT
DECLARE @isLocked                    as BIT
DECLARE @tempRecID                   as INT            -- Used for determining if a rec exists
DECLARE @loweredUserName             as NVARCHAR(100)
DECLARE @userIDUid                   as uniqueidentifier
DECLARE @roleIDUid                   as uniqueidentifier
DECLARE @isSBSC                      as bit
declare @reqClientIDAssc             as bit
declare @reqPracIDAssc               as bit
declare @reqPrtGrdIDAssc             as bit
declare @reqPatIDAssc                as bit
declare @reqSelpaAsc                 as bit
declare @ascSelpaWithAcct            as bit
declare @ascClientWithAcct           as bit
declare @ascPracWithAcct             as bit
declare @ascPrtGrdWithAcct           as bit
declare @ascPatWithAcct              as bit
declare @canHaveMultiClientPracAsc   as bit
declare @canHaveMultiClientPrtGrdAsc as bit
declare @canHaveMultiClientPatAsc    as bit
declare @pracID                      as bigint
declare @spDet                       as varchar(8000)
declare @userGrpID                   as bigint
declare @districtID                  as bigint

declare @pracMustHaveEmploymentRelationshipWithClient   as bit
declare @pracCannotHaveEmploymentRelationshipWithClient as bit
declare @msgTemplateTitle as varchar(1000)
declare @msgTemplateBody  as varchar(max)

declare @newUserAccountData as NEW_USER_ACCOUNT_DATA

declare @currentRoleUID                      as uniqueidentifier
declare @currentRoleID                       as bigint
declare @currentRoleCanChangeToDifferentRole as bit = 0

BEGIN TRY

/*============================================================
 * Init
 *============================================================*/

set @recordID    = 0
set @spDetails   = ''
set @jsonData    = ''
set @today       = GETDATE()
set @minDateTime = dbo.CONST_MIN_DATETIME()
set @isActive    = 1
set @isLocked    = 0

/*============================================================
 * Verify parameters required for proper functioning of this
 * procedure have been passed in
 *============================================================*/

IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)
IF (@username    IS NULL) RAISERROR ('userName is required',    11, 1)
IF (@firstname   IS NULL) RAISERROR ('First Name is required',  11, 1)
IF (@lastname    IS NULL) RAISERROR ('Last Name is required',   11, 1)
IF (@appName     IS NULL) RAISERROR ('App name is required',    11, 1)
IF (@roleID      IS NULL) RAISERROR ('roleID is required',      11, 1)

if (isnull(@pwdMinLen,0) <= 0) RAISERROR ('valid min password length is required',  11, 1)

/*============================================================
 * Clean up entity parameters
 *============================================================*/

IF (@clientID is not null)
  IF (@clientID <= 0)
    set @clientID = null

IF (@personID is not null)
  IF (@personID <= 0)
    set @personID = null

IF (@selpaCode is not null)
  IF (@selpaCode <= 0)
    set @selpaCode = null

/*============================================================
 * Clean up name
 *============================================================*/

set @lastname  = trim(replace (@lastname,  N'''', N'`'))
set @firstname = trim(replace (@firstname, N'''', N'`'))

/*============================================================
 * Pre edit check
 *============================================================*/

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN

  /*-------------------------------
   * Was a record id passed
   *------------------------------*/

  IF (@recID IS NULL) RAISERROR ('user record id is required', 11, 1)

  /*-------------------------------
   * Does the record exist and if
   * so can it be edited
   *------------------------------*/

  SET @recordID = NULL

  select top 1

      @recordID       = t1.id
    , @canEdit        = t1.canEdit
    , @isActive       = t1.active
    , @isLocked       = t1.accountIsLockedOut
    , @userIdUid      = t1.[uid]
    , @userGrpID      = t1.userGroupID   
    , @currentRoleUID = t1.roleUID  
	, @currentRoleID  = t1.roleID

  from dbo.USERS_VIEW_CORE (@userID, @userGroup, @userRank, @appName,null,null,null,@recID) as t1
    
  if @recordID is null RAISERROR (@MsgNoRec,  11, 1)
  if @canEdit  = 0     RAISERROR (@MsgNoEdit, 11, 1)
  if @isActive = 0     SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,'This user has been previously deactivated.',dbo.CONST_RET_WARN())

  /*-------------------------------
   * Can current role be changed
   *------------------------------*/

  select top 1
 
	 @currentRoleCanChangeToDifferentRole = t1.canChangeToDifferentRole
  
  from dbo.ROLES_VIEW_CORE (@userID, @userGroup, @userRank, @appName, null, @currentRoleID) as t1

  /*-------------------------------
   * If role cannot be changed
   *
   * Note: This is a new rule check
   * and we may need to modifiy this
   * logic or remove it if we have
   * problems
   *------------------------------*/

  if (@currentRoleCanChangeToDifferentRole = 0)
  begin
    if (@roleID != @currentRoleID)
	begin
	  RAISERROR ('Users current role cannot be changed to different role', 11, 1)
	end
  end

END

/*============================================================
 * Generate values
 *============================================================*/

set @loweredUserName = lower(@username)

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
begin
  set @password  = dbo.GENERATE_PASSWORD(@pwdMinLen)
end

/*============================================================
 * Lookup role data associated with role id and also verify
 * that the calling user can add this role.  If no records are
 * returned, the calling user does not have permission to
 * add the new user for the given role.
 *============================================================*/

select top 1
    @roleIDUid                   = t1.IdUid
  , @isSBSC                      = t1.isSBSC
  , @reqClientIDAssc             = t1.reqClientIDAssc
  , @reqPracIDAssc               = t1.reqPracIDAssc
  , @reqPrtGrdIDAssc             = t1.reqPrtGrdIDAscc
  , @reqPatIDAssc                = t1.reqPatIDAscc
  , @ascClientWithAcct           = t1.ascClientWithAcct
  , @ascPracWithAcct             = t1.ascPracWithAcct
  , @ascPrtGrdWithAcct           = t1.ascPrtGrdWithAcct
  , @ascPatWithAcct              = t1.ascPatWithAcct
  , @canHaveMultiClientPracAsc   = t1.canHaveMultiClientPracAsc
  , @canHaveMultiClientPrtGrdAsc = t1.canHaveMultiClientPrtGrdAsc
  , @canHaveMultiClientPatAsc    = t1.canHaveMultiClientPatAsc

  , @pracMustHaveEmploymentRelationshipWithClient   = t1.pracMustHaveEmploymentRelationshipWithClient
  , @pracCannotHaveEmploymentRelationshipWithClient = t1.pracCannotHaveEmploymentRelationshipWithClient
  , @msgTemplateTitle                               = t1.newAccountMessageTemplateTitle
  , @msgTemplateBody                                = t1.newAccountMessageTemplateBody
  , @reqSelpaAsc                                    = t1.reqSelpaAsc
  , @ascSelpaWithAcct                               = t1.ascSelpaWithAcct

from dbo.ROLES_VIEW_CORE (@userID, @userGroup, @userRank, @appName, null, @roleID) as t1
where 
  (t1.canEdit = 1)

/*============================================================
 * If no record was found then either the role is invalid
 * or the calling user cannot add or edit users with this role
 *============================================================*/

IF (@roleIDUid IS NULL) RAISERROR ('You cannot add or edit this user', 11, 1)

/*============================================================
 * Verify that the supporting data for the given role has
 * been provided and the combination of values provided are
 * valid
 *============================================================*/

if ((@reqSelpaAsc     = 1) and (isnull(@selpaCode,0) = 0))    RAISERROR ('A SELPA must be associated with this role',           11, 1)

if ((@reqSelpaAsc     = 0) and (isnull(@selpaCode,0) != 0))   set @selpaCode = null /* Ignore selpa code*/

if ((@reqClientIDAssc = 1) and (isnull(@clientID,0) = 0))   RAISERROR ('A client must be associated with this role',          11, 1)
if ((@reqClientIDAssc = 0) and (isnull(@clientID,0) != 0))  RAISERROR ('A client can not be associated with this role',       11, 1)

if ((@reqPracIDAssc   = 1) and (isnull(@personID,0) = 0))   RAISERROR ('A practitioner must be associated with this role',    11, 1)
if ((@reqPrtGrdIDAssc = 1) and (isnull(@personID,0) = 0))   RAISERROR ('A parent/guardian must be associated with this role', 11, 1)
if ((@reqPatIDAssc    = 1) and (isnull(@personID,0) = 0))   RAISERROR ('A patient must be associated with this role',         11, 1)

if ((@reqPracIDAssc = 0) and (@reqPrtGrdIDAssc = 0) and (@reqPatIDAssc = 0) and (isnull(@personID,0) != 0))
  RAISERROR ('A practitioner, parent/guardian, or patient can not be associated with this role', 11, 1)

/*============================================================
 * The client id is required for proper association of
 * person records (practitioners, parent/guardians) but
 * only certain roles require that the client ID be associated
 * with the user account (districtID).
 *============================================================*/

set @districtID = null
if (@ascClientWithAcct = 1)
begin
  set @districtID = @clientID
end

/*============================================================
 * Search for duplicate records excluding the record specified
 * by recid.  Duplicate records will have the same user name
 *============================================================*/

set @dupCount = 0

select
   @dupCount = COUNT(udc.id)
 from dbo.USERS_DATA_CORE (@appName,@username,null,null,null) as udc
 where (
       (1=1)
   and ((@recID IS NULL) OR (udc.id != @recID))
 )

IF (@dupCount > 0) RAISERROR (@MsgDupRec, 11, 1)

/*============================================================
 * If we are NOT validating then perform record operations
 * that involve the user database tables
 *============================================================*/

IF (@validateRec = 0)
BEGIN

/*-------------------------------
 * Create new user account
 *------------------------------*/

IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
BEGIN

  /*-------------------------------
   * Create new user record
   *------------------------------*/

  SET @updateState = dbo.CONST_REC_STATE_NEW()

  INSERT INTO dbo.Users
  (
    UserName,
    LoweredUserName,
    LastActivityDate
  )
  VALUES
  (
    @username,
    @loweredUserName,
    @minDateTime
  )

  /*-------------------------------
   * Retrieve unique identifiers
   * Note: We need the uid not the
   * int value of the record id
   * for proper record association
   *------------------------------*/

  set    @recordID  = SCOPE_IDENTITY()
  select @userIDUID = userid from dbo.users where userrid = @recordID

  /*-------------------------------
   * Save users role
   *------------------------------*/

  INSERT INTO dbo.UsersInRoles
  (
    UserId,
    RoleId
  )
  VALUES
  (
    @userIDUid,
    @roleIDUid
  )

  /*-------------------------------
   * Save users membership
   *
   * Note:
   *
   * The mustChange password
   * flag is set for all new
   * accounts
   *
   * The password passsed in should
   * be a temporary password
   *
   * The membership table
   * does not permit null values
   * for undefined datetime
   * fields and we cannot change
   * this constraint right now so
   * so we provide the minimum value
   * of datetime as a substitute
   *------------------------------*/

  /* Note: The value that we set initalPasswordChangeCompleted is always going to be false
   * for the following update. The value of initalPasswordChangeCompleted is initialy set to false when 
   * the account is created and is used for account setup tasks. */

  INSERT INTO dbo.Membership
  (
    UserId,
    Password,
    PasswordFormat,
    PasswordSalt,
    CreateDate,
    LastLoginDate,
    LastPasswordChangedDate,
    LastLockoutDate,
    FailedPasswordAttemptCount,
    FailedPasswordAttemptWindowStart,
    FailedPasswordAnswerAttemptCount,
    FailedPasswordAnswerAttemptWindowStart,
    Email,
    FirstName,
    LastName,
    District_ID,
    Site_ID,
    PhoneNumber,
    IsLockedOut,
    IsApproved,
    Pending,
    SBSC_Employee,
    passwordMustBeChanged,
    sendUserEmailNotifications,
	SELPA_CODE,
	initialPasswordChangeCompleted
  )
  VALUES
  (
    @userIDUid,
    dbo.HASH_PASSWORD(@password),
    1,
    '',
    @today,
    @minDateTime,
    @minDateTime,
    @minDateTime,
    0,
    0,
    0,
    0,
    @email,
    @firstname,
    @lastname,
    @districtID,
    0,
    @phone,
    0,
    1,
    0,
    @isSBSC,
    1,
    @receiveEmailNotifications,
	@selpaCode,
	0 /* New account.  Initial password change is not completed*/
  )

  insert into @newUserAccountData (
      userName
    , firstName
    , lastName
    , email
    , phone
    , pwd
	, msgTemplateTitle
    , msgTemplateBody )
  values (
      @username
    , @firstname
    , @lastname
    , @email
    , @phone
    , @password
    , @msgTemplateTitle
    , @msgTemplateBody

	 )

  set @jsonData = (select * from @newUserAccountData FOR JSON AUTO, ROOT('accounts'), INCLUDE_NULL_VALUES)

END

/*-------------------------------
 * Modify existing user account
 *------------------------------*/

ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
BEGIN

  SET @updateState = dbo.CONST_REC_STATE_MOD()

  /*-------------------------------
   * Update users
   *------------------------------*/

  UPDATE dbo.Users
  SET UserName         = @username,
      LoweredUserName  = @loweredUserName,
      LastActivityDate = @today
  WHERE 
    (UserId = @userIDUid)

  /*-------------------------------
   * Update membership
   *
   * Note: We don't modifiy the
   * password
   *------------------------------*/

  UPDATE dbo.Membership
  SET
      Email                      = @email,
      LoweredEmail               = LOWER(@email),
      FirstName                  = @firstname,
      LastName                   = @lastname,
      District_ID                = @districtID,
      PhoneNumber                = @phone,
      SBSC_Employee              = @isSBSC,
      sendUserEmailNotifications = @receiveEmailNotifications,
	  SELPA_CODE                 = @selpaCode
   where 
     (UserId = @userIDUid)

   /*-------------------------------
    * Update role 
    *------------------------------*/

   UPDATE dbo.UsersInRoles
   SET   
     RoleId = @roleIDUid
   WHERE 
	 (UserId = @userIDUid)

END
ELSE
BEGIN
  RAISERROR ('Unknown save type', 11, 1)
END

/*-------------------------------
 * Create audit record
 *------------------------------*/

EXEC dbo.Web_Users_Audit @recordID, @today, @recID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT


END

/*============================================================
 * Depeding on the validation mode either validate or perform
 * record operations on the SPEDMON database tables
 *
 * Note: Each routine called is responsible for returning
 * validation data or performing record operations
 *
 * Also the roles that are associated with these various
 * persons are currently set to not allow changes to other
 * roles once the user is assigned the role.  This is to 
 * avoid modification of say a practitioner record that has
 * an id of 1 and changing a patient person record with the
 * same client id and also an id of 1.
 *============================================================*/

/*-------------------------------
 * Call prac rec assignment
 *
 * Note: This routine handles
 * clean up of previously valid
 * records in the case of changes
 * and will not assign accounts
 * if not required
 *------------------------------*/
 
exec SPEDMON.dbo.PRACTITIONERS_ASSIGN_USER_CORE
      @userID
    , @userGroup
    , @userRank
    , @clientID
    , @personID
    , @userIDUid
    , @recordID /* userIDInt */
    , @ascClientWithAcct
    , @ascPracWithAcct
    , @canHaveMultiClientPracAsc
    , @pracMustHaveEmploymentRelationshipWithClient
    , @pracCannotHaveEmploymentRelationshipWithClient
    , @validateRec

/*-------------------------------
 * Call patient person assignment
 *
 * Note: This routine handles
 * clean up of previously valid
 * records in the case of changes
 * and will not assign accounts
 * if not required
 *------------------------------*/

exec SPEDMON.dbo.PATIENT_PERSON_ASSIGN_USER_CORE
      @userID
    , @userGroup
    , @userRank
	, @clientID
    , @personID
    , @userIDUID
    , @recordID /* userIDInt */
	, @ascClientWithAcct
	, @ascPrtGrdWithAcct
    , @canHaveMultiClientPrtGrdAsc
    , @validateRec

/*-------------------------------
 * Call pat rec assignment
 *
 * Note: This routine handles
 * clean up of previously valid
 * records in the case of changes
 * and will not assign accounts
 * if not required
 *------------------------------*/

exec SPEDMON.dbo.PATIENTS_ASSIGN_USER_CORE
      @userID
    , @userGroup
    , @userRank
    , @clientID
    , @personID
    , @userIDUid
    , @recordID /* userIDInt */
    , @ascClientWithAcct
    , @ascPatWithAcct
    , @canHaveMultiClientPatAsc
    , @validateRec

/*-------------------------------
 * Populate user quick links
 *------------------------------*/

 -- first we remove any existing quick links data

 DELETE FROM dbo.usersPreferences
 WHERE (usrid = @recordID)
 and (noun = 'Quick Links')

 INSERT INTO dbo.usersPreferences(appDomain, appName, UserId, usrid, selector, selectorType, noun, verb, name, value, created, createdBy, lastModified, lastModifiedBy)

 SELECT appDomain      = @appName
 	  , appName        = @appName
 	  , UserId  	   = @userIdUid
 	  , usrid		   = @recordID
 	  , selector	   = 'home.aspx'
 	  , selectorType   = 'END_POINT'
 	  , noun		   = 'Quick Links'
 	  , verb		   = 'viewSel'
 	  , name		   = 'source'
 	  , value		   = CASE
						 WHEN (JSON_VALUE(rd.defaultQuickLinks, '$.hasSubRoles') = 1)
						 THEN isnull(JSON_QUERY(rd.defaultQuickLinks, '$.quickLinkIdSets."' + isnull(convert(varchar(max),ua.pracDispGroupID), 'default') + '"')
								 , JSON_QUERY(rd.defaultQuickLinks, '$.quickLinkIdSets.default'))

						 ELSE JSON_QUERY(rd.defaultQuickLinks, '$.quickLinkIdSets.default')
						 END
 	  , created		   = @today
 	  , createdBy	   = @userID
 	  , lastModified   = @today
 	  , lastModifiedBy = @userID

 FROM dbo.users_all as ua
 cross apply  dbo.RoleData AS rd
 WHERE ((ua.id = @recordID)
 and (rd.RoleId = ua.roleUID)
 and (ua.appName = @appName))

/*-------------------------------
 * If we reach this point
 * everything is OK
 *------------------------------*/

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


  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

-- GRANT EXECUTE ON TYPE::TelecommParticipantDetails TO [webuser]
 -- seems we were randomly adding the execute statement for this type here...
 -- even though this table type isn't actuallu used in this sproc.
 -- Let's put it in TELECOMM_SESSION_SAVE_CORE.sql, instead

GRANT EXECUTE ON  [dbo].[USERS_SAVE_CORE] TO [webuser]


GO
