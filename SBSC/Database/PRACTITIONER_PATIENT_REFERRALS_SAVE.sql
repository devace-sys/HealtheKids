USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_REFERRALS_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_REFERRALS_SAVE
GO

CREATE PROCEDURE dbo.PRACTITIONER_PATIENT_REFERRALS_SAVE (
    @userID											BIGINT
  , @userGroup										INT
  , @userRank										INT       
  , @clientID										BIGINT
  , @pracID											BIGINT
  , @referringByUserID								BIGINT
  , @patID											BIGINT
  , @priority										TINYINT
  , @referredToPracName								VARCHAR(256)
  , @referredToOrgName								VARCHAR(256)
  , @referredToPracEmail							VARCHAR(256)
  , @referredToPracPhone							VARCHAR(256)
  , @parentGuardianName								VARCHAR(256)
  , @parentGuardianRelationship						VARCHAR(256)
  , @parentGuardianEmail							VARCHAR(256)
  , @parentGuardianPhone							VARCHAR(256)
  , @parentGuardianConsent							TINYINT
  , @referralType									TINYINT
  , @notes											VARCHAR(MAX)
  , @includeDiagnoses								BIT  
  , @includeOrdersOrPrescriptions					BIT  
  , @includeServiceRecordsTreatments				BIT  
  , @includeServiceRecordsAssessementsOrScreenings	BIT  
  , @includeServiceNotesNonConfidential				BIT  
  , @includeServiceNotesConfidential				BIT 
  , @refFileID										VARCHAR(MAX)
  , @isUsed											BIT
  , @referredToPracID								BIGINT
  , @referralSourceName								VARCHAR(256)
  , @referralSourceRole								VARCHAR(256)
  , @referralSourceEmail							VARCHAR(256)	
  , @referralSourcePhone							VARCHAR(256)
  , @behavioralIsssuesConcerns						BIT
  , @academicConcerns								BIT
  , @anxietyOrDepressionConcerns					BIT
  , @familyStressConcerns							BIT
  , @bullyingConcerns								BIT
  , @otherConcerns									VARCHAR(MAX)
  , @requestPublicUrl							    VARCHAR(1000)
  , @parmNamePtkn									VARCHAR(256)
  , @parmNametoParent								VARCHAR(256)
  , @editDelReason									VARCHAR(7000)
  , @validateRec									BIT
  , @saveType										INT
  , @recID											BIGINT
  , @MsgNotActive									VARCHAR(1000)
  , @MsgNoRec										VARCHAR(1000)
  , @MsgNoEdit										VARCHAR(1000)  
  , @MsgDupRec										VARCHAR(1000)  
  , @MsgDataError									VARCHAR(1000)  
  , @requestURL										VARCHAR(MAX)  OUTPUT
  , @pinParent										VARCHAR(10)   OUTPUT
  , @spDetails										VARCHAR(8000) OUTPUT
  , @recordID										BIGINT        OUTPUT
)
AS
BEGIN
  
    SET NOCOUNT ON

    DECLARE @today			AS DATETIME       -- Current date/time stamp
    DECLARE @tranOpen		AS BIT            -- Is a transaction open	
	DECLARE @publicToken	AS VARCHAR (512) 
	DECLARE @pinPract		AS VARCHAR (10)
	DECLARE @startDate		AS DATE
	DECLARE @startTime		AS TIME(0)
	DECLARE @expirationDate	AS DATE
	DECLARE @expirationTime	AS TIME(0)

    /*============================================================
     * Init
     *============================================================*/

    SET @recordID        = 0
    SET @spDetails       = ''
    SET @today           = GETDATE()
    SET @tranOpen        = 0
	SET @startDate		 = convert(date,@today)
	SET @startTime		 = convert(time(0),@today)
	SET @expirationDate	 = DATEADD(DAY, 30, @startDate);
	SET @expirationTime	 = @startTime

	SET @pracID	   = NULLIF(@pracID, 0);
	SET @userID    = ISNULL(@userID, 0);
	SET @userGroup = ISNULL(@userGroup, 0);
	SET @userRank  = ISNULL(@userRank, 0);

	BEGIN TRY

    /*============================================================
     * Required validation
     *============================================================*/

    IF (@validateRec         IS NULL) RAISERROR ('Validate flag required',             11, 1)
    IF (@saveType            IS NULL) RAISERROR ('Save type is required',              11, 1)
    IF (@clientID            IS NULL) RAISERROR ('Client ID is required',              11, 1)
	IF (@requestPublicUrl    IS NULL) RAISERROR ('Request public url is required',     11, 1)

	/*============================================================
     * Check for duplicate records in all active records
     *============================================================*/

     IF EXISTS (
		SELECT 1
		FROM dbo.PRACTITIONER_PATIENT_REFERRALS ppr
		WHERE (
		ppr.clientID = @clientID
		AND (
				 (ppr.pracID = @pracID)
			  OR (ppr.pracID IS NULL AND @pracID IS NULL)
			  )
		  AND (
				(ppr.referringByUserID = @referringByUserID)
			  OR (ppr.referringByUserID IS NULL AND @referringByUserID IS NULL)
			  )
		  AND (
				 (ppr.patID = @patID)
			  OR (ppr.patID IS NULL AND @patID IS NULL)
			  )
		  AND ppr.active = 1
		  AND ppr.isUsed = 0
		  AND ppr.referralType = @referralType
		  AND ((@recID IS NULL) or (ppr.id != @recID))  /* In the case of edits we skip the record being edited */
		  )
	)
	BEGIN
		RAISERROR(@MsgDupRec, 11, 1);
	END

	/*============================================================
	 * Exit if save type is unknown
	 *============================================================*/  

	if (@saveType = 0) RAISERROR ('Unknown save type', 11, 1)	

	/*============================================================
	 * If we are editing the record, make sure it exists 
	 *============================================================*/  

	set @recordID  = 0

  IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT()) 
  BEGIN   
	select top 1 
		@recordID = isnull(id, 0)
	  from dbo.PRACTITIONER_PATIENT_REFERRALS
	  where (
			(1=1)
		and (clientID			 = @clientID)
		and (id					 = @recID)
	)
  END
	

	IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())
	BEGIN
		/*============================================================
		 * Generate new public token for new records
		 *============================================================*/
        
		set @publicToken = ''

		/* Adds random length alphanumeric component 0 to 255 chars */

		set @publicToken = @publicToken + dbo.GENERATE_RANDOM_ALPHA_NUMERIC_STRING(CAST(CRYPT_GEN_RANDOM(1) AS tinyint), 0)

		/* Adds unique component to token (32 chars) */

		SELECT TOP 1
			@publicToken = @publicToken + gnui.NEW_UNIQUE_ID_STR_NO_DASH
		FROM dbo.GENERATE_NEW_UNIQUE_ID AS gnui

		/* Adds fixed length alphanumeric component 32 chars */

		set @publicToken = @publicToken + dbo.GENERATE_RANDOM_ALPHA_NUMERIC_STRING(32, 0)

		/*============================================================
		 * Generate new pin for referrals authorization
		 *============================================================*/
	 
		set @pinParent		  =''
		set @pinPract		  =''
		select top 1 @pinParent = left(convert(varchar(256),abs(VALUE_INT)),10) from dbo.GENERATE_RANDOM_NUMBERS
	END
	ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())
	BEGIN
		/* Keep existing token/PINs to preserve original URL */
		SELECT TOP 1
			  @publicToken = ppr.publicToken
			, @pinParent   = ppr.pinParent
			, @pinPract    = ppr.pinPract
		FROM dbo.PRACTITIONER_PATIENT_REFERRALS ppr
		WHERE ppr.id = @recID
		  AND ppr.clientID = @clientID
	END

	/*============================================================
      * Create request url for parent guardian
      *============================================================*/

	 set @requestURL = @requestPublicUrl 
	                + '?' + @parmNamePtkn     + '=' + @publicToken
					+ '&' + @parmNametoParent + '=' + 'true'

	/*============================================================
     * Save Data
     *============================================================*/
         
     BEGIN TRANSACTION
         SET @tranOpen = 1

	   /*-------------------------------    
		* New record
		*------------------------------*/    
   
		IF (@saveType = dbo.CONST_SAVE_TYPE_NEW()) 
		BEGIN

         INSERT INTO dbo.PRACTITIONER_PATIENT_REFERRALS (                    
					clientID,
					pracID,
					patID,
					referringByUserID,
					priority, 
					publicToken,
					pinParent, 
					pinPract,
					referredToPracName,
					referredToOrgName,
					referredToPracEmail,
					referredToPracPhone,
					parentGuardianName,
					parentGuardianRelationship,
					parentGuardianEmail,
					parentGuardianPhone,
					parentGuardianConsent,
					referralType,
					notes,
					refFileID,
					includeDiagnoses,
					includeOrdersOrPrescriptions,
					includeServiceRecordsTreatments,
					includeServiceRecordsAssessementsOrScreenings,
					includeServiceNotesNonConfidential,
					includeServiceNotesConfidential,
					startDate,
					startTime,
					expirationDate,
					expirationTime,
					isUsed,
					referredToPracID,								
					referralSourceName,							
					referralSourceRole,								
					referralSourceEmail,							
					referralSourcePhone,							
					behavioralIsssuesConcerns,						
					academicConcerns,								
					anxietyOrDepressionConcerns,					
					familyStressConcerns,							
					bullyingConcerns,								
					otherConcerns,									
					created,
					createdBy,
					active         
                )
                VALUES (                      
                      @clientID
					, @pracID
                    , @patID
					, @referringByUserID
					, @priority
					, @publicToken
					, @pinParent
					, @pinPract
					, @referredToPracName
					, @referredToOrgName
					, @referredToPracEmail
					, @referredToPracPhone
					, @parentGuardianName
					, @parentGuardianRelationship
					, @parentGuardianEmail
					, @parentGuardianPhone
					, @parentGuardianConsent
					, @referralType
					, @notes
					, @refFileID
					, @includeDiagnoses
					, @includeOrdersOrPrescriptions
					, @includeServiceRecordsTreatments
					, @includeServiceRecordsAssessementsOrScreenings
					, @includeServiceNotesNonConfidential
					, @includeServiceNotesConfidential
					, @startDate
					, @startTime
					, @expirationDate
					, @expirationTime
					, @isUsed
					, @referredToPracID								
					, @referralSourceName						
					, @referralSourceRole						
					, @referralSourceEmail	
					, @referralSourcePhone
					, @behavioralIsssuesConcerns						
					, @academicConcerns								
					, @anxietyOrDepressionConcerns					
					, @familyStressConcerns							
					, @bullyingConcerns								
					, @otherConcerns			
					, @today
                    , @userID
                    , 1
                )

        SET @recordID = SCOPE_IDENTITY()   
		END
		ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
		  BEGIN    
     
			/*-------------------------------    
			 * Edit existing entity record    
			 *------------------------------*/                      
       
			 UPDATE [dbo].[PRACTITIONER_PATIENT_REFERRALS]
			 SET    	       
					  clientID				= @clientID
					, pracID				= @pracID
					, patID					= @patID
					, referringByUserID		= @referringByUserID
					, priority				= @priority
					, referredToPracName	= @referredToPracName
					, referredToOrgName		= @referredToOrgName
					, referredToPracEmail	= @referredToPracEmail
					, referredToPracPhone	= @referredToPracPhone					
					, notes					= @notes
					, refFileID			    = @refFileID
					, includeDiagnoses		= @includeDiagnoses
					, includeOrdersOrPrescriptions					= @includeOrdersOrPrescriptions
					, includeServiceRecordsTreatments				= @includeServiceRecordsTreatments
					, includeServiceRecordsAssessementsOrScreenings = @includeServiceRecordsAssessementsOrScreenings
					, includeServiceNotesNonConfidential			= @includeServiceNotesNonConfidential
					, includeServiceNotesConfidential				= @includeServiceNotesConfidential
					, startDate				= @startDate
					, startTime				= @startTime
					, expirationDate		= @expirationDate
					, expirationTime		= @expirationTime
					, isUsed				= @isUsed
					, active				= 1 
					, referredToPracID		= @referredToPracID						
					, referralSourceName	= @referralSourceName						
					, referralSourceRole	= @referralSourceRole							
					, referralSourceEmail	= @referralSourceEmail						
					, referralSourcePhone	= @referralSourcePhone						
					, behavioralIsssuesConcerns	= @behavioralIsssuesConcerns						
					, academicConcerns			= @academicConcerns							
					, anxietyOrDepressionConcerns	= @anxietyOrDepressionConcerns					
					, familyStressConcerns			= @familyStressConcerns						
					, bullyingConcerns				= @bullyingConcerns						
					, otherConcerns					= @otherConcerns
				    , lastModified					= @today
				    , lastModifiedBy				= @userID
			 WHERE (
					(id = @recID)
			)
    
		  END    
		  ELSE    
		  BEGIN    
			RAISERROR ('Unknown save type', 11, 1)    
		  END    
        
		/*-------------------------------
         * If we reach this point everything 
		 * is OK commit our changes and exit
         *------------------------------*/
        
		COMMIT TRANSACTION
        SET @tranOpen = 0

		IF (@saveType = dbo.CONST_SAVE_TYPE_NEW() AND @referralType = 2)
		BEGIN
			EXEC dbo.PRACTITIONER_PATIENT_REFERRAL_GENERATE_NOTIFICATION_MESSAGES_CORE @userID, @userGroup, @userRank, @clientID, @saveType, @referralType, @priority;
		END
    END TRY
    BEGIN CATCH
        /*-------------------------------
         * If we end up here something went wrong.
         * Cancel any pending transactions and return any error
         * messages to the caller
         *------------------------------*/
        IF @tranOpen = 1 ROLLBACK TRANSACTION

        DECLARE @ErrorMessage  NVARCHAR(4000)
        DECLARE @ErrorSeverity INT
        DECLARE @ErrorState    INT

        SELECT  @ErrorMessage  = ERROR_MESSAGE(),
                @ErrorSeverity = ERROR_SEVERITY(),
                @ErrorState    = ERROR_STATE()

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

GRANT EXECUTE ON dbo.PRACTITIONER_PATIENT_REFERRALS_SAVE TO webuser;
GO

