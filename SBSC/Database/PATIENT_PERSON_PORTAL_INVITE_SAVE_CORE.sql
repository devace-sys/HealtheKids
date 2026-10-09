USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PERSON_PORTAL_INVITE_SAVE_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PERSON_PORTAL_INVITE_SAVE_CORE
GO

CREATE PROCEDURE [dbo].[PATIENT_PERSON_PORTAL_INVITE_SAVE_CORE]
(
      @userID          BIGINT
    , @userGroup       INT
    , @userRank        INT
	, @appName		   VARCHAR(50)
    , @clientID        BIGINT
    , @patID           BIGINT
    , @recID           BIGINT
    , @pwdMinLen       INT
    , @recordID        BIGINT        OUTPUT
    , @jsonData        VARCHAR(MAX)  OUTPUT
    , @spDetails       VARCHAR(8000) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @personID                   BIGINT        = NULL;
    DECLARE @classID2                   BIGINT        = NULL;
    DECLARE @firstName                  NVARCHAR(128) = N'';
    DECLARE @lastName                   NVARCHAR(128) = N'';
    DECLARE @email                      NVARCHAR(256) = N'';
    DECLARE @phone                      NVARCHAR(14)  = N'';
    DECLARE @userIDInt                  BIGINT        = NULL;
	DECLARE @patientPersonRecID			BIGINT		  = NULL;
    DECLARE @newUserPersonID            BIGINT        = NULL;
    DECLARE @newUserRoleID              BIGINT        = NULL;
    DECLARE @newUserSvcAuthPersonRoleCode BIGINT      = NULL;
    DECLARE @newUserName                NVARCHAR(256) = N'';
    DECLARE @newUserFirstName           NVARCHAR(128) = N'';
    DECLARE @newUserLastName            NVARCHAR(128) = N'';
    DECLARE @newUserEmail               NVARCHAR(256) = N'';
    DECLARE @newUserPhone               NVARCHAR(14)  = N'';
    DECLARE @dupAcctMsg                 VARCHAR(1000) = 'Username in use already';

    DECLARE @newUserRecordID            BIGINT        = 0;
    DECLARE @newUserJSONData            VARCHAR(MAX)  = '';
    DECLARE @newUserSPDetails           VARCHAR(8000) = '';

    DECLARE @roleIDUid                  UNIQUEIDENTIFIER = NULL;
    DECLARE @reqPrtGrdIDAssc            BIT = 0;
    DECLARE @ascPrtGrdWithAcct          BIT = 0;
	DECLARE @clientName					VARCHAR(1000) = '';
	DECLARE @clientNameJson				VARCHAR(MAX) = '';


    DECLARE @userAccountsToSetup TABLE
    (
          idx INT IDENTITY(1,1)
        , personID BIGINT
        , roleID BIGINT
        , serviceAuthorizationPersonRoleCode BIGINT NULL
        , userName NVARCHAR(256)
        , firstName NVARCHAR(128)
        , lastName NVARCHAR(128)
        , email NVARCHAR(256)
        , phone NVARCHAR(14)
        , dupMsg VARCHAR(1000)
    );

	SELECT TOP 1
		@clientName = CLIENT_NAME
	FROM dbo.CLIENTS_Client
	WHERE CLIENT_ID = @clientID;	

	SET @clientNameJson = REPLACE(REPLACE(ISNULL(@clientName,''), '\', '\\'), '"', '\"');

    BEGIN TRY

        SET @recordID  = 0;
        SET @jsonData  = '';
        SET @spDetails = '';

        SELECT TOP 1
			  @patientPersonRecID = pp.id    
            , @personID  = pp.personID
            , @classID2  = pp.classID2
            , @firstName = pp.firstName
            , @lastName  = pp.lastName
            , @email     = pp.email
            , @phone     = pp.phone
            , @userIDInt = pp.userIDInt
        FROM dbo.PATIENT_PERSONS_VIEW_CORE(
              @userID
            , @userGroup
            , @userRank
            , @clientID
            , @patID
            , NULL
            , NULL
            , NULL
            , @recID
            , NULL
        ) pp;

        IF (@personID IS NULL)
            RAISERROR('Invalid patient person record', 11, 1);

        IF (@classID2 NOT IN (1000, 1001, 1002))
            RAISERROR('Portal invite is only available for parent/guardian contacts', 11, 1);

        IF (ISNULL(LTRIM(RTRIM(@email)), '') = '')
            RAISERROR('Parent/guardian email is required to send portal invite', 11, 1);

        IF (ISNULL(@userIDInt, 0) > 0)
        BEGIN
            SET @jsonData =
                '{' +
                '"accounts":[],' +
                '"messages":[],' +
                '"accountAlreadyExists":true' +
                '}';

            SET @spDetails = dbo.UPDATE_DETAILS(
                  @spDetails
                , 'This parent/guardian already has a portal account.'
                , dbo.CONST_RET_WARN()
            );

            RETURN(0);
        END


        SET @newUserRoleID = 12;
        SET @newUserSvcAuthPersonRoleCode = NULL;

        IF (ISNULL(@newUserRoleID, 0) <= 0)
            RAISERROR('Parent/guardian portal role was not resolved.', 11, 1);

        /*============================================================
         * Validate the chosen role before creating the account
         *============================================================*/

        SELECT TOP 1
              @roleIDUid         = IdUid
            , @reqPrtGrdIDAssc   = reqPrtGrdIDAscc
            , @ascPrtGrdWithAcct = ascPrtGrdWithAcct
        FROM users.dbo.ROLES_VIEW_CORE(@userID, @userGroup, @userRank, @appName, NULL, @newUserRoleID)
        WHERE canEdit = 1;

        IF (@roleIDUid IS NULL)
            RAISERROR('Invalid or inaccessible parent/guardian role.', 11, 1);

        IF (ISNULL(@reqPrtGrdIDAssc, 0) = 0)
            RAISERROR('Selected role is not configured for parent/guardian association.', 11, 1);

        IF (ISNULL(@ascPrtGrdWithAcct, 0) = 0)
            RAISERROR('Selected role does not associate accounts with parent/guardian records.', 11, 1);

        INSERT INTO @userAccountsToSetup
        (
              personID
            , roleID
            , serviceAuthorizationPersonRoleCode
            , userName
            , firstName
            , lastName
            , email
            , phone
            , dupMsg
        )
        VALUES
        (
              @personID
            , @newUserRoleID
            , @newUserSvcAuthPersonRoleCode
            , @email
            , @firstName
            , @lastName
            , @email
            , @phone
            , 'Username in use already'
        );

        SELECT TOP 1
              @newUserPersonID				= @patientPersonRecID
            , @newUserRoleID                = t1.roleID
            , @newUserSvcAuthPersonRoleCode = t1.serviceAuthorizationPersonRoleCode
            , @newUserName                  = t1.userName
            , @newUserFirstName             = t1.firstName
            , @newUserLastName              = t1.lastName
            , @newUserEmail                 = t1.email
            , @newUserPhone                 = t1.phone
            , @dupAcctMsg                   = t1.dupMsg
        FROM @userAccountsToSetup t1
        WHERE t1.idx = 1;

        /*============================================================
         * Create new account using the same existing flow
         *============================================================*/

        EXEC users.dbo.USERS_SAVE_CORE
              @userID                    = @userID
            , @userGroup                 = @userGroup
            , @userRank                  = @userRank
            , @appName                   = @appName
            , @selpaCode                 = NULL
            , @clientID                  = @clientID
            , @personID                  = @newUserPersonID
            , @roleID                    = @newUserRoleID
            , @username                  = @newUserName
            , @pwdMinLen                 = @pwdMinLen
            , @firstname                 = @newUserFirstName
            , @lastname                  = @newUserLastName
            , @email                     = @newUserEmail
            , @phone                     = @newUserPhone
            , @receiveEmailNotifications = 1
            , @recID                     = NULL
            , @editDelReason             = ''
            , @validateRec               = 0
            , @saveType                  = 1
            , @MsgNotActive              = 'This user is not active'
            , @MsgDupRec                 = @dupAcctMsg
            , @MsgNoRec                  = 'User record not found'
            , @MsgNoEdit                 = 'You cannot edit this user'
            , @MsgDataError              = 'Invalid user data'
            , @recordID                  = @newUserRecordID OUTPUT
            , @jsonData                  = @newUserJSONData OUTPUT
            , @spDetails                 = @newUserSPDetails OUTPUT;

        SET @recordID  = @newUserRecordID;
        SET @spDetails = @newUserSPDetails;

        IF (ISNULL(@newUserJSONData, '') = '')
		BEGIN
			SET @jsonData =
				'{' +
				'"accounts":[],' +
				'"messages":[],' +
				'"accountAlreadyExists":false,' +
				'"clientName":"' + @clientNameJson + '"' +
				'}';
		END
        ELSE
        BEGIN
            IF (RIGHT(RTRIM(@newUserJSONData), 1) = '}')
				SET @jsonData = STUFF(
					  RTRIM(@newUserJSONData)
					, LEN(RTRIM(@newUserJSONData))
					, 1
					, ',"messages":[],"accountAlreadyExists":false,"clientName":"' + @clientNameJson  + '"}'
				);
            ELSE
                SET @jsonData =
                    '{' +
                    '"accounts":[],' +
                    '"messages":[],' +
                    '"accountAlreadyExists":false,' +
					'"clientName":"' + @clientNameJson + '"' +
                    '}';
        END

        RETURN(0);

    END TRY
    BEGIN CATCH

        DECLARE @ErrorMessage  NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState    INT;

        SELECT
              @ErrorMessage  = ERROR_MESSAGE()
            , @ErrorSeverity = ERROR_SEVERITY()
            , @ErrorState    = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

    END CATCH
END
GO

GRANT EXECUTE ON [dbo].[PATIENT_PERSON_PORTAL_INVITE_SAVE_CORE] TO [webuser]
GO