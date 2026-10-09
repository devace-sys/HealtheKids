USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_REFERRAL_GENERATE_NOTIFICATION_MESSAGES_CORE') AND type IN (N'P', N'PC'))
    DROP PROCEDURE dbo.PRACTITIONER_PATIENT_REFERRAL_GENERATE_NOTIFICATION_MESSAGES_CORE
GO

CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_REFERRAL_GENERATE_NOTIFICATION_MESSAGES_CORE]
(
      @userID       BIGINT
    , @userGroup    INT
    , @userRank     INT
    , @clientID     BIGINT
    , @saveType     INT
    , @referralType TINYINT
    , @priority     TINYINT
)
AS
BEGIN
    SET NOCOUNT ON;

    /* If this is a new incoming referral (either assigned or unassigned) */
    IF ((@saveType = dbo.CONST_SAVE_TYPE_NEW()) AND (@referralType = 2))
    BEGIN

        /* Send a message to the triage team member(s) based on priority */
        DECLARE @msgSubject       VARCHAR(256)  = ''
        DECLARE @msgBody          VARCHAR(MAX)  = ''
        DECLARE @spDetailsSaveMsg VARCHAR(8000) = ''
        DECLARE @msgID            BIGINT        = 0
        DECLARE @msgForUserIDStrs VARCHAR(MAX)  = ''
        DECLARE @gotoUrlForManage VARCHAR(256)  = ''

        DECLARE @msgForUserIDs TABLE ( userID BIGINT );

        SET @gotoUrlForManage = 'user_all_practitioner_patient_referrals_manage.aspx'

        /* Routine */
        IF (@priority = 1)
        BEGIN
            SET @msgSubject = 'New Routine Referral Notification – Action Required'
            SET @msgBody    = '<p>Hello,<br>    A Routine referral has been submitted.<br>Please log into the Referral Management System in SpEdCare to review the referral information, determine next steps, and begin outreach based on the priority level:</p><ul><li><strong>Routine:</strong> Within standard response timelines</li><li><strong>Urgent:</strong> Early contact recommended</li><li><strong>Crisis:</strong> Immediate follow-up required per district protocols</li></ul><p>Thank you for your timely attention to this referral and for supporting our students’ behavioral health needs.</p>'

            INSERT INTO @msgForUserIDs (userID)
                 SELECT TOP 1 userIDForAllRoutineNotifications1 FROM dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS t1 WHERE t1.clientID = @clientID AND t1.userIDForAllRoutineNotifications1 IS NOT NULL
            UNION SELECT TOP 1 userIDForAllRoutineNotifications2 FROM dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS t1 WHERE t1.clientID = @clientID AND t1.userIDForAllRoutineNotifications2 IS NOT NULL
            UNION SELECT TOP 1 userIDForAllRoutineNotifications3 FROM dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS t1 WHERE t1.clientID = @clientID AND t1.userIDForAllRoutineNotifications3 IS NOT NULL
        END
        /* Urgent */
        ELSE IF (@priority = 2)
        BEGIN
            SET @msgSubject = 'New Urgent Referral Notification – Action Required'
            SET @msgBody    = '<p>Hello,<br>    A Urgent referral has been submitted.<br>Please log into the Referral Management System in SpEdCare to review the referral information, determine next steps, and begin outreach based on the priority level:</p><ul><li><strong>Routine:</strong> Within standard response timelines</li><li><strong>Urgent:</strong> Early contact recommended</li><li><strong>Crisis:</strong> Immediate follow-up required per district protocols</li></ul><p>Thank you for your timely attention to this referral and for supporting our students’ behavioral health needs.</p>'

            INSERT INTO @msgForUserIDs (userID)
                 SELECT TOP 1 userIDForAllUrgentNotifications1 FROM dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS t1 WHERE t1.clientID = @clientID AND t1.userIDForAllUrgentNotifications1 IS NOT NULL
            UNION SELECT TOP 1 userIDForAllUrgentNotifications2 FROM dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS t1 WHERE t1.clientID = @clientID AND t1.userIDForAllUrgentNotifications2 IS NOT NULL
            UNION SELECT TOP 1 userIDForAllUrgentNotifications3 FROM dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS t1 WHERE t1.clientID = @clientID AND t1.userIDForAllUrgentNotifications3 IS NOT NULL
        END
        /* Crisis */
        ELSE IF (@priority = 3)
        BEGIN
            SET @msgSubject = 'New Crisis Referral Notification – Action Required'
            SET @msgBody    = '<p>Hello,<br>    A Crisis referral has been submitted.<br>Please log into the Referral Management System in SpEdCare to review the referral information, determine next steps, and begin outreach based on the priority level:</p><ul><li><strong>Routine:</strong> Within standard response timelines</li><li><strong>Urgent:</strong> Early contact recommended</li><li><strong>Crisis:</strong> Immediate follow-up required per district protocols</li></ul><p>Thank you for your timely attention to this referral and for supporting our students’ behavioral health needs.</p>'

            INSERT INTO @msgForUserIDs (userID)
                 SELECT TOP 1 userIDForAllCrisisNotifications1 FROM dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS t1 WHERE t1.clientID = @clientID AND t1.userIDForAllCrisisNotifications1 IS NOT NULL
            UNION SELECT TOP 1 userIDForAllCrisisNotifications2 FROM dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS t1 WHERE t1.clientID = @clientID AND t1.userIDForAllCrisisNotifications2 IS NOT NULL
            UNION SELECT TOP 1 userIDForAllCrisisNotifications3 FROM dbo.PRACTITIONER_PATIENT_REFERRAL_OPTIONS t1 WHERE t1.clientID = @clientID AND t1.userIDForAllCrisisNotifications3 IS NOT NULL
        END
        ELSE
        BEGIN
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM @msgForUserIDs)
        BEGIN
            SELECT @msgForUserIDStrs = STRING_AGG(CONVERT(VARCHAR(MAX), userID), ',')
            FROM @msgForUserIDs;

            EXEC users.dbo.USERS_MESSAGES_SAVE_GENERATED
                   @userID
                 , @userGroup
                 , @userRank
                 , 'spedcare'
                 , @msgForUserIDStrs
                 , @msgSubject
                 , @msgBody
                 , 1     /* Send email */
                 , NULL  /* respPromptOptionsBitwise */
                 , NULL  /* respPromptOptionsJSON */
                 , 1
                 , @gotoUrlForManage
                 , NULL  /* gotoURLAdditionalParams */
                 , 1     /* save type */
                 , 0     /* Rec id */
                 , @spDetailsSaveMsg OUTPUT
                 , @msgID OUTPUT;
        END
    END
END
GO

GRANT EXECUTE ON [dbo].[PRACTITIONER_PATIENT_REFERRAL_GENERATE_NOTIFICATION_MESSAGES_CORE] TO [webuser];
GO
