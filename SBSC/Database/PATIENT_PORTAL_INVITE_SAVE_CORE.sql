USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS ( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PORTAL_INVITE_SAVE_CORE') AND type IN (N'P', N'PC'))
	DROP PROCEDURE dbo.PATIENT_PORTAL_INVITE_SAVE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PATIENT_PORTAL_INVITE_SAVE_CORE]
(
      @userID          BIGINT
    , @userGroup       INT
    , @userRank        INT
	, @source		   INT
    , @appName         VARCHAR(50)
    , @clientID        BIGINT
    , @patID           BIGINT
    , @pwdMinLen       INT
    , @recordID        BIGINT        OUTPUT
    , @jsonData        VARCHAR(MAX)  OUTPUT
    , @spDetails       VARCHAR(8000) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @patientID                   BIGINT        = NULL;
    DECLARE @firstName                   NVARCHAR(128) = N'';
    DECLARE @lastName                    NVARCHAR(128) = N'';
    DECLARE @email                       NVARCHAR(256) = N'';
    DECLARE @phone                       NVARCHAR(14)  = N'';
    DECLARE @userIDInt                   BIGINT        = NULL;

    DECLARE @newUserPersonID             BIGINT        = NULL;
    DECLARE @newUserRoleID               BIGINT        = NULL;
    DECLARE @newUserSvcAuthPersonRoleCode BIGINT       = NULL;

    DECLARE @newUserName                 NVARCHAR(256) = N'';
    DECLARE @newUserFirstName            NVARCHAR(128) = N'';
    DECLARE @newUserLastName             NVARCHAR(128) = N'';
    DECLARE @newUserEmail                NVARCHAR(256) = N'';
    DECLARE @newUserPhone                NVARCHAR(14)  = N'';
    DECLARE @dupAcctMsg                  VARCHAR(1000) = 'Username in use already';

    DECLARE @newUserRecordID             BIGINT        = 0;
    DECLARE @newUserJSONData             VARCHAR(MAX)  = '';
    DECLARE @newUserSPDetails            VARCHAR(8000) = '';

    DECLARE @roleIDUid                   UNIQUEIDENTIFIER = NULL;
    DECLARE @reqPatIDAssc                BIT = 0;
    DECLARE @ascPatWithAcct              BIT = 0;

    DECLARE @clientName                  VARCHAR(1000) = '';
    DECLARE @clientNameJson              VARCHAR(MAX)  = '';

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

    BEGIN TRY

        SET @recordID  = 0;
        SET @jsonData  = '';
        SET @spDetails = '';

        SELECT TOP 1
            @clientName = CLIENT_NAME
        FROM dbo.CLIENTS_Client
        WHERE CLIENT_ID = @clientID;

        SET @clientNameJson = REPLACE(REPLACE(ISNULL(@clientName, ''), '\', '\\'), '"', '\"');

        /*============================================================
         *  * Load patient data
		 *============================================================*/

		SELECT TOP 1
			  @patientID = p.id
			, @firstName = p.firstName
			, @lastName  = p.lastName
			, @userIDInt = ISNULL(pat.userIDInt, 0)
			, @email     = ISNULL(pat_email.Email, '')
			, @phone     = ISNULL(pat_phone.Phone, '')
		FROM dbo.PATIENTS_VIEW_CORE(
			  @source    -- @source
			, @clientID  -- @clientID
			, NULL       -- @pracID
			, NULL       -- @lnamePat
			, NULL       -- @fnamePat
			, NULL       -- @dob
			, NULL       -- @active
			, GETDATE()  -- @refDate
			, NULL       -- @siteID
			, NULL       -- @siteRefID
			, @patID     -- @recID
		) p

		OUTER APPLY (
			SELECT TOP 1
				pua.userIDInt
			FROM dbo.PATIENT_USER_ACCOUNTS_VIEW_CORE(
				  @userID
				, @userGroup
				, @userRank
				, @clientID
				, p.id
				, 1
				, NULL
				, NULL
			) AS pua
			WHERE 
				ISNULL(pua.active, 0) = 1
			ORDER BY 
				pua.id DESC
		) AS pat

		OUTER APPLY (
			SELECT TOP 1
				pat_e.[Email]
			FROM dbo.[PATIENTS_Email] AS pat_e
			WHERE 
					pat_e.[PATIENT_ID] = p.id
				AND pat_e.ACTIVE = 1
			ORDER BY pat_e.ID DESC
		) AS pat_email

		OUTER APPLY (
			SELECT TOP 1
				pat_ph.[Phone]
			FROM dbo.[PATIENTS_Phone] AS pat_ph
			WHERE 
					pat_ph.[PATIENT_ID] = p.id
				AND pat_ph.ACTIVE = 1
			ORDER BY pat_ph.ID DESC
		) AS pat_phone;

        IF (@patientID IS NULL)
            RAISERROR('Invalid patient record', 11, 1);

        IF (ISNULL(LTRIM(RTRIM(@email)), '') = '')
            RAISERROR('Patient email is required to send portal invite', 11, 1);

        IF (ISNULL(@userIDInt, 0) > 0)
        BEGIN
            SET @jsonData =
                '{' +
                '"accounts":[],' +
                '"messages":[],' +
                '"accountAlreadyExists":true,' +
                '"clientName":"' + @clientNameJson + '"' +
                '}';

            SET @spDetails = dbo.UPDATE_DETAILS(
                  @spDetails
                , 'This patient already has a portal account.'
                , dbo.CONST_RET_WARN()
            );

            RETURN(0);
        END

        /*============================================================
         * Resolve Patient Portal role
         *============================================================*/

        SELECT TOP 1
              @newUserRoleID = id
        FROM users.dbo.ROLES_VIEW_CORE(
              @userID
            , @userGroup
            , @userRank
            , @appName
            , NULL
            , NULL
        )
        WHERE 
                canEdit = 1
            AND ISNULL(reqPatIDAscc, 0) = 1
            AND ISNULL(ascPatWithAcct, 0) = 1
        ORDER BY id;

        SET @newUserSvcAuthPersonRoleCode = NULL;

        IF (ISNULL(@newUserRoleID, 0) <= 0)
            RAISERROR('Patient portal role was not resolved.', 11, 1);

        /*============================================================
         * Validate chosen role before creating the account
         *============================================================*/

        SELECT TOP 1
              @roleIDUid      = IdUid
            , @reqPatIDAssc   = reqPatIDAscc
            , @ascPatWithAcct = ascPatWithAcct
        FROM users.dbo.ROLES_VIEW_CORE(
              @userID
            , @userGroup
            , @userRank
            , @appName
            , NULL
            , @newUserRoleID
        )
        WHERE canEdit = 1;

        IF (@roleIDUid IS NULL)
            RAISERROR('Invalid or inaccessible patient portal role.', 11, 1);

        IF (ISNULL(@reqPatIDAssc, 0) = 0)
            RAISERROR('Selected role is not configured for patient association.', 11, 1);

        IF (ISNULL(@ascPatWithAcct, 0) = 0)
            RAISERROR('Selected role does not associate accounts with patient records.', 11, 1);

        /*============================================================
         * Prepare new account
         *============================================================*/

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
              @patID
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
              @newUserPersonID              = t1.personID
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
         * Create new account using existing user flow
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

        /*============================================================
         * Normalize JSON response for C# PatientPortalCommon
         *============================================================*/

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
                    , ',"messages":[],"accountAlreadyExists":false,"clientName":"' + @clientNameJson + '"}'
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

GRANT EXECUTE ON [dbo].[PATIENT_PORTAL_INVITE_SAVE_CORE] TO [webuser]
GO