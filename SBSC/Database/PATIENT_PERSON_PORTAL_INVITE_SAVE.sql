USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PERSON_PORTAL_INVITE_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PERSON_PORTAL_INVITE_SAVE
GO

CREATE PROCEDURE [dbo].[PATIENT_PERSON_PORTAL_INVITE_SAVE]
(
      @userID          BIGINT
    , @userGroup       INT
    , @userRank        INT

    , @clientID        BIGINT
    , @patID           BIGINT
    , @pwdMinLen       INT

    , @editDelReason   VARCHAR(7000)
    , @validateRec     BIT
    , @saveType        INT
    , @recID           BIGINT

	, @MsgNotActive	   VARCHAR(1000)
    , @MsgDupRec       VARCHAR(1000)
    , @MsgNoRec        VARCHAR(1000)
    , @MsgNoEdit       VARCHAR(1000)
    , @MsgDataError    VARCHAR(1000)

    , @recordID        BIGINT        OUTPUT
    , @jsonData        VARCHAR(MAX)  OUTPUT
    , @spDetails       VARCHAR(8000) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        SET @recordID  = 0;
        SET @jsonData  = '';
        SET @spDetails = '';

        IF (@userID    IS NULL) RAISERROR('userID is required',    11, 1);
        IF (@userGroup IS NULL) RAISERROR('userGroup is required', 11, 1);
        IF (@userRank  IS NULL) RAISERROR('userRank is required',  11, 1);

        IF (ISNULL(@clientID,0) <= 0) RAISERROR('clientID is required', 11, 1);
        IF (ISNULL(@patID,0)    <= 0) RAISERROR('patID is required',    11, 1);
        IF (ISNULL(@recID,0)    <= 0) RAISERROR('recID is required',    11, 1);
        IF (ISNULL(@pwdMinLen,0) <= 0) RAISERROR('valid min password length is required', 11, 1);

        EXEC dbo.PATIENT_PERSON_PORTAL_INVITE_SAVE_CORE
              @userID    = @userID
            , @userGroup = @userGroup
            , @userRank  = @userRank
            , @appName   = 'spedcare'
            , @clientID  = @clientID
            , @patID     = @patID
            , @recID     = @recID
            , @pwdMinLen = @pwdMinLen
            , @recordID  = @recordID OUTPUT
            , @jsonData  = @jsonData OUTPUT
            , @spDetails = @spDetails OUTPUT;

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

GRANT EXECUTE ON [dbo].[PATIENT_PERSON_PORTAL_INVITE_SAVE] TO [webuser]
GO