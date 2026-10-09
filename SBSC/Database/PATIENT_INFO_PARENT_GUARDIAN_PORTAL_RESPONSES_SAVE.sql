USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES_SAVE') AND type IN (N'P', N'PC'))
	DROP PROCEDURE dbo.PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES_SAVE
GO

CREATE PROCEDURE dbo.PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES_SAVE (
     @userID                             bigint
   , @userGroup                          bigint
   , @userRank                           int

   , @clientID                           bigint
   , @patID                              bigint
   , @patPerID                           bigint

   , @ferpaConsent                       bit
   , @responderSignatureImgData          varchar(max)

   , @primaryInsuranceCarrierID          bigint
   , @primaryBeneficiaryFirstName        nvarchar(50)
   , @primaryBeneficiaryLastName         nvarchar(50)
   , @primaryMemberID                    varchar(80)
   , @primaryPolicyGroupID               varchar(80)
   , @primaryPolicyHolderName            nvarchar(255)
   , @primaryInsuranceCarrierOtherName   varchar(256)

   , @secondaryInsuranceCarrierID        bigint
   , @secondaryBeneficiaryFirstName      nvarchar(50) 
   , @secondaryBeneficiaryLastName       nvarchar(50)
   , @secondaryMemberID                  varchar(80)
   , @secondaryPolicyGroupID             varchar(80)
   , @secondaryPolicyHolderName          nvarchar(255)
   , @secondaryInsuranceCarrierOtherName varchar(256)

   , @editDelReason                      varchar(7000)
   , @validateRec                        bit
   , @saveType                           int
   , @recID                              bigint
   , @MsgNoRec							 varchar(1000)
   , @MsgNoEdit							 varchar(1000)
   , @MsgDupRec							 varchar(1000)
   , @MsgDataError						 varchar(1000)
   , @MsgNotActive						 varchar(1000)
   , @recordID                           bigint OUTPUT
   , @spDetails                          varchar(8000) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @today         as datetime;
    DECLARE @tranOpen      as bit;
    DECLARE @existingRecID as bigint;
	declare @hasSecondary  as bit;
    
	SET @today         = GETDATE();
    SET @tranOpen      = 0;
    SET @recordID      = 0;
    SET @spDetails     = '';
    SET @existingRecID = 0;
	set @hasSecondary  = 0;
    
	/* Remove white space and replace single quotes with apostrophes */

	set @primaryBeneficiaryFirstName         = replace((trim(isnull(@primaryBeneficiaryFirstName,     N''))) ,'''', '`');
    set @primaryBeneficiaryLastName          = replace((trim(isnull(@primaryBeneficiaryLastName,      N''))) ,'''', '`');
    set @primaryMemberID                     = replace((trim(isnull(@primaryMemberID,                  ''))) ,'''', '`');
    set @primaryPolicyGroupID                = replace((trim(isnull(@primaryPolicyGroupID,             ''))) ,'''', '`');
    set @primaryPolicyHolderName             = replace((trim(isnull(@primaryPolicyHolderName,         N''))) ,'''', '`');
    set @primaryInsuranceCarrierOtherName    = replace((trim(isnull(@primaryInsuranceCarrierOtherName, ''))) ,'''', '`');

	set @secondaryBeneficiaryFirstName       = replace((trim(isnull(@secondaryBeneficiaryFirstName,     N''))) ,'''', '`');
    set @secondaryBeneficiaryLastName        = replace((trim(isnull(@secondaryBeneficiaryLastName,      N''))) ,'''', '`');
    set @secondaryMemberID                   = replace((trim(isnull(@secondaryMemberID,                  ''))) ,'''', '`');
    set @secondaryPolicyGroupID              = replace((trim(isnull(@secondaryPolicyGroupID,             ''))) ,'''', '`');
    set @secondaryPolicyHolderName           = replace((trim(isnull(@secondaryPolicyHolderName,         N''))) ,'''', '`'); 
    set @secondaryInsuranceCarrierOtherName  = replace((trim(isnull(@secondaryInsuranceCarrierOtherName, ''))) ,'''', '`');

	/* Determine if secondary was provided */

	if (
            (len (@secondaryMemberID)                  > 0)
         or (len (@secondaryPolicyGroupID)             > 0)
         or (len (@secondaryPolicyHolderName)          > 0)
         or (len (@secondaryInsuranceCarrierOtherName) > 0)
         or (len (@secondaryBeneficiaryFirstName)      > 0)
         or (len (@secondaryBeneficiaryLastName)       > 0)
   )
   begin
     set @hasSecondary = 1
   end
   else
   begin
     set @hasSecondary = 0
   end

   BEGIN TRY

        IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
        BEGIN
            SELECT TOP 1
                @recordID = id
            FROM dbo.PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES
            WHERE id = @recID
              AND clientID = @clientID
              AND patID = @patID
              AND active = 1;

            IF ISNULL(@recordID, 0) = 0
                RAISERROR('Please select a valid portal response record to edit.', 11, 1);
        END

        IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
        BEGIN
            SELECT TOP 1
                @existingRecID = id
            FROM dbo.PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES
            WHERE clientID = @clientID
              AND patID = @patID
              AND active = 1
            ORDER BY id DESC;

            IF ISNULL(@existingRecID, 0) > 0
            BEGIN
                SET @recordID = @existingRecID;
				SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,'Existing portal response found; updating existing record.', dbo.CONST_RET_INFO())        
            END
        END

        IF (@validateRec = 1)
            RETURN(0);

        BEGIN TRANSACTION;
        SET @tranOpen = 1;

        IF (@saveType = dbo.CONST_SAVE_TYPE_NEW() AND ISNULL(@recordID, 0) = 0)
        BEGIN
            INSERT INTO dbo.PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES (
                  clientID
                , patID
                , patPerID
                , ferpaConsent
                , responderSignatureImgData
                , active
                , created
                , createdBy
            )
            VALUES (
                  @clientID
                , @patID
                , @patPerID
                , @ferpaConsent
                , @responderSignatureImgData
                , 1
                , @today
                , @userID
            );

            SET @recordID = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE dbo.PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES
            SET
                  patPerID                  = @patPerID
                , ferpaConsent              = @ferpaConsent
                , responderSignatureImgData = @responderSignatureImgData
                , lastModified              = @today
                , lastModifiedBy            = @userID
            WHERE id = @recordID;
        END

		UPDATE dbo.PATIENTS_Patient
			SET
				  ferpaConsent = @ferpaConsent
				, ferpaConsentEffectiveDate = @today
			WHERE PATIENT_ID = @patID;

        DELETE FROM dbo.PATIENT_INFO_RESPONSES_FROM_PARENT_GUARDIAN_PORTAL_INSURANCE
        WHERE portalResponseID = @recordID;

        INSERT INTO dbo.PATIENT_INFO_RESPONSES_FROM_PARENT_GUARDIAN_PORTAL_INSURANCE (
              portalResponseID
            , insuranceType
            , insuranceOrder
            , insuranceCarrierID
            , beneficiaryFirstName
            , beneficiaryLastName
            , memberID
            , policyGroupID
            , policyHolderName
            , insuranceCarrierOtherName
            , active
            , created
            , createdBy
        )
        VALUES (
              @recordID
            , 'Primary'
            , 1
            , @primaryInsuranceCarrierID
            , @primaryBeneficiaryFirstName
            , @primaryBeneficiaryLastName
            , @primaryMemberID
            , @primaryPolicyGroupID
            , @primaryPolicyHolderName
            , @primaryInsuranceCarrierOtherName
            , 1
            , @today
            , @userID
        );

        IF (@hasSecondary = 1)
        BEGIN
            INSERT INTO dbo.PATIENT_INFO_RESPONSES_FROM_PARENT_GUARDIAN_PORTAL_INSURANCE (
                  portalResponseID
                , insuranceType
                , insuranceOrder
                , insuranceCarrierID
                , beneficiaryFirstName
                , beneficiaryLastName
                , memberID
                , policyGroupID
                , policyHolderName
                , insuranceCarrierOtherName
                , active
                , created
                , createdBy
            )
            VALUES (
                  @recordID
                , 'Secondary'
                , 2
                , @secondaryInsuranceCarrierID
                , @secondaryBeneficiaryFirstName
                , @secondaryBeneficiaryLastName
                , @secondaryMemberID
                , @secondaryPolicyGroupID
                , @secondaryPolicyHolderName
                , @secondaryInsuranceCarrierOtherName
                , 1
                , @today
                , @userID
            );
        END

        COMMIT TRANSACTION;
        SET @tranOpen = 0;

    END TRY
    BEGIN CATCH
        IF @tranOpen = 1
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage nvarchar(4000);
        DECLARE @ErrorSeverity int;
        DECLARE @ErrorState int;

        SELECT
              @ErrorMessage = ERROR_MESSAGE()
            , @ErrorSeverity = ERROR_SEVERITY()
            , @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

GRANT EXECUTE ON dbo.PATIENT_INFO_PARENT_GUARDIAN_PORTAL_RESPONSES_SAVE TO webuser
GO