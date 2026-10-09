USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM') 
      AND type IN (N'P', N'PC')
)
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM
GO

CREATE PROCEDURE dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM (
      @userIP                           varchar(500)
    , @userAgent                        varchar(8000)
    , @ptkn                             varchar(512)

    , @patientFirstName                 nvarchar(50)
    , @patientLastName                  nvarchar(50)
    , @patientDOB                       datetime
    , @studentID                        nvarchar(50)
    , @teacherName                      nvarchar(50)
    , @referralPriority                 tinyint
    , @referralDetailNote               varchar(8000)

    , @responderIsParentGuardian        bit
    , @responderRelationship            varchar(20)
    , @responderFirstName               nvarchar(50)
    , @responderLastName                nvarchar(50)
    , @responderEmail                   varchar(255)
    , @responderPhone                   varchar(255)
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @today              DATETIME
    DECLARE @tranOpen           BIT
    DECLARE @pirrID             BIGINT
    DECLARE @publicToken        VARCHAR(512)
    DECLARE @pinParent          VARCHAR(10)
    DECLARE @pinPract           VARCHAR(10)
    DECLARE @clientID           BIGINT
    DECLARE @patID              BIGINT
    DECLARE @patPerID           BIGINT
    DECLARE @startDate          DATE
    DECLARE @startTime          TIME(0)
    DECLARE @expirationDate     DATE
    DECLARE @expirationTime     TIME(0)
    DECLARE @referralID         BIGINT

    DECLARE @userID BIGINT = NULL
    DECLARE @userGroup INT = NULL
    DECLARE @userRank INT = NULL
    DECLARE @saveType INT = dbo.CONST_SAVE_TYPE_NEW()
    DECLARE @referralType TINYINT = 2
    DECLARE @priority TINYINT = @referralPriority
    DECLARE @parentGuardianConsent TINYINT = 3

    SET @today = GETDATE()
    SET @tranOpen = 0
    SET @pirrID = -1
    SET @referralID = NULL
    SET @startDate = CONVERT(DATE, @today)
    SET @startTime = CONVERT(TIME(0), @today)
    SET @expirationDate = DATEADD(DAY, 30, @startDate)
    SET @expirationTime = @startTime

    IF (@responderRelationship IS NULL) RAISERROR ('responder relationship is required', 11, 1)
    IF (@responderFirstName IS NULL) RAISERROR ('responder first name is required', 11, 1)
    IF (@responderLastName IS NULL) RAISERROR ('responder last name is required', 11, 1)

    BEGIN TRY

        SELECT TOP 1
              @pirrID = ISNULL(t1.id, -1)
            , @clientID = t1.clientID
        FROM dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORMS_GET_BY_PTKN(@ptkn) AS t1

        IF (@pirrID = -1)
        BEGIN
            RAISERROR ('Form not found or form is no longer valid', 11, 1)
        END

        SET @studentID = TRIM(ISNULL(@studentID, N''))
        SET @patientFirstName = TRIM(ISNULL(@patientFirstName, N''))
        SET @patientLastName = TRIM(ISNULL(@patientLastName, N''))

        SET @patID = -1

        IF (LEN(@studentID) > 0)
        BEGIN
            SELECT TOP 1 
                @patID = ISNULL(ps.PATIENT_ID, -1)
            FROM dbo.PATIENTS_SCHOOL AS ps
            JOIN dbo.PATIENTS_Client AS pc 
              ON pc.CLIENT_ID = @clientID 
             AND pc.PATIENT_ID = ps.PATIENT_ID
            WHERE ps.STUDENT_ID = @studentID
              AND ps.PATIENT_ID IS NOT NULL
              AND ps.PATIENT_SCHOOL_ID IS NOT NULL
        END

        IF (@patID = -1)
        BEGIN
            IF (
                LEN(@patientLastName) > 0 
                AND LEN(@patientFirstName) > 0 
                AND @patientDOB IS NOT NULL
            )
            BEGIN
                SELECT TOP 1 
                    @patID = ISNULL(pap.PATIENT_ID, -1)
                FROM dbo.PATIENTS_Patient AS pap
                JOIN dbo.PATIENTS_Client AS pc 
                  ON pc.CLIENT_ID = @clientID 
                 AND pc.PATIENT_ID = pap.PATIENT_ID
                WHERE pap.LAST_NAME = @patientLastName
                  AND pap.FIRST_NAME = @patientFirstName
                  AND pap.ACTIVE = N'Y'
                  AND pap.PATIENT_ID IS NOT NULL
            END
        END

        IF (@patID = -1) SET @patID = NULL

        IF (@patID IS NOT NULL)
        BEGIN
            IF (@responderEmail IS NOT NULL)
            BEGIN
                SELECT TOP 1
                    @patPerID = patper.id
                FROM dbo.PATIENTS_PERSON AS patper
                JOIN dbo.PERSONS_PERSON AS per 
                  ON per.id = patper.PERSON_ID
                WHERE patper.CLIENT_ID = @clientID
                  AND patper.PATIENT_ID = @patID
                  AND patper.ACTIVE = 1
                  AND per.CLASS_ID_1 = 1
                  AND per.EMAIL = @responderEmail
                  AND per.ACTIVE = 1
            END
        END

        SET @publicToken = ''
        SET @publicToken = @publicToken + dbo.GENERATE_RANDOM_ALPHA_NUMERIC_STRING(CAST(CRYPT_GEN_RANDOM(1) AS tinyint), 0)

        SELECT TOP 1
            @publicToken = @publicToken + gnui.NEW_UNIQUE_ID_STR_NO_DASH
        FROM dbo.GENERATE_NEW_UNIQUE_ID AS gnui

        SET @publicToken = @publicToken + dbo.GENERATE_RANDOM_ALPHA_NUMERIC_STRING(32, 0)

        SET @pinParent = ''
        SET @pinPract = ''

        SELECT TOP 1 
            @pinParent = LEFT(CONVERT(varchar(256), ABS(VALUE_INT)), 10) 
        FROM dbo.GENERATE_RANDOM_NUMBERS

        BEGIN TRANSACTION
        SET @tranOpen = 1

        INSERT INTO dbo.PRACTITIONER_PATIENT_REFERRALS (
              clientID
            , pracID
            , patID
            , referringByUserID
            , priority
            , publicToken
            , pinParent
            , pinPract
            , referredToPracName
            , referredToOrgName
            , referredToPracEmail
            , referredToPracPhone
            , parentGuardianName
            , parentGuardianRelationship
            , parentGuardianEmail
            , parentGuardianPhone
            , parentGuardianConsent
            , referralType
            , notes
            , refFileID
            , includeDiagnoses
            , includeOrdersOrPrescriptions
            , includeServiceRecordsTreatments
            , includeServiceRecordsAssessementsOrScreenings
            , includeServiceNotesNonConfidential
            , includeServiceNotesConfidential
            , startDate
            , startTime
            , expirationDate
            , expirationTime
            , isUsed
            , referredToPracID
            , referralSourceName
            , referralSourceRole
            , referralSourceEmail
            , referralSourcePhone
            , behavioralIsssuesConcerns
            , academicConcerns
            , anxietyOrDepressionConcerns
            , familyStressConcerns
            , bullyingConcerns
            , otherConcerns
            , created
            , createdBy
            , active
        )
        VALUES (
              @clientID
            , @pirrID
            , @patID
            , NULL
            , @referralPriority
            , @publicToken
            , @pinParent
            , @pinPract
            , ''
            , ''
            , ''
            , ''
            , ''
            , ''
            , ''
            , ''
            , @parentGuardianConsent
            , @referralType
            , @referralDetailNote
            , ''
            , 0
            , 0
            , 0
            , 0
            , 0
            , 0
            , @startDate
            , @startTime
            , @expirationDate
            , @expirationTime
            , 0
            , @pirrID
            , @responderFirstName
            , @responderRelationship
            , @responderEmail
            , @responderPhone
            , 0
            , 0
            , 0
            , 0
            , 0
            , ''
            , @today
            , NULLIF(@userID, 0)
            , 1
        )

        SET @referralID = SCOPE_IDENTITY()

        INSERT INTO dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_REFERRAL_FORM_RESPONSES (
              reqRefFormID
            , referralID
            , patientFirstName
            , patientLastName
            , patientDOB
            , studentID
            , teacherName
            , referralPriority
            , referralDetailNote
            , responderIsParentGuardian
            , responderRelationship
            , responderFirstName
            , responderLastName
            , responderEmail
            , responderPhone
            , responderUserIP
            , responderUserAgent
            , clientID
            , patID
            , created
            , createdBy
            , patPerID
        )
        VALUES (
              @pirrID
            , @referralID
            , @patientFirstName
            , @patientLastName
            , @patientDOB
            , @studentID
            , @teacherName
            , @referralPriority
            , @referralDetailNote
            , @responderIsParentGuardian
            , @responderRelationship
            , @responderFirstName
            , @responderLastName
            , @responderEmail
            , @responderPhone
            , @userIP
            , @userAgent
            , @clientID
            , @patID
            , @today
            , 0
            , @patPerID
        )

        COMMIT TRANSACTION
        SET @tranOpen = 0

        EXEC dbo.PRACTITIONER_PATIENT_REFERRAL_GENERATE_NOTIFICATION_MESSAGES_CORE 
              0
            , 0
            , 0
            , @clientID
            , @saveType
            , @referralType
            , @priority

    END TRY
    BEGIN CATCH

        IF @tranOpen = 1 ROLLBACK TRANSACTION

        DECLARE @ErrorMessage NVARCHAR(4000)
        DECLARE @ErrorSeverity INT
        DECLARE @ErrorState INT

        SELECT  
              @ErrorMessage = ERROR_MESSAGE()
            , @ErrorSeverity = ERROR_SEVERITY()
            , @ErrorState = ERROR_STATE()

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

    END CATCH
END
GO

GRANT EXECUTE ON dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM TO webuser
GO