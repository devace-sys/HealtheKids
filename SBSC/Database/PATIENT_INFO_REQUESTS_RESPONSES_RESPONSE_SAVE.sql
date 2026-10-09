USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_SAVE') 
      AND type IN (N'P', N'PC')
)
DROP PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_SAVE
GO

CREATE PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_SAVE (
    @userIP                                 varchar(500)                      
  , @userAgent                              varchar(8000)        
  , @ptkn                                   varchar(512)       
  , @insuranceCarrierID                     bigint
  , @insuranceCarrierPolicyHolderFirstName  varchar(255)
  , @insuranceCarrierPolicyHolderLastName   varchar(255)
  , @policyNumber                           varchar(80)
  , @insuranceGroupNumberID                 varchar(256)
  , @insuranceCarrierOtherName              varchar(256)
  , @consent                                bit	
  , @responderSignatureImgData              varchar(max)
  , @patPerID                               bigint
  , @noInsuranceOptionSelected              bit
  , @otherInsuranceOptionSelected           bit
)
AS
BEGIN
  
    SET NOCOUNT ON

    declare @today                     as datetime       -- Current date/time stamp
    declare @tranOpen                  as bit            -- Is a transaction open
	declare @pirrID                    as bigint         -- Request id
	declare @patID                     as bigint
	declare @clientID                  as bigint
    declare @patientInsuranceCarrierID as bigint
	declare @insuranceDataUpdated      as bit
	declare @canFlagAsCompleted        as bit

    /*============================================================
     * Init
     *============================================================*/

    set @today                     = GETDATE()
    set @tranOpen                  = 0
	set @pirrID                    = -1
	set @canFlagAsCompleted        = 1 /* Assume we can until we cannot */
	set @insuranceDataUpdated      = 0
	set @patientInsuranceCarrierID = -1

    BEGIN TRY

	  /*============================================================
       * Find incomplete request
       *============================================================*/

      select top 1
          @pirrID   = isnull(pirr.id,-1)  
		, @clientID = pirr.clientID
		, @patID    = pirr.patID      
	  from dbo.Patient_Info_Requests_Responses as pirr
      where ( 
            (pirr.publicToken      = @ptkn)
        and (pirr.responseReceived = 0)
        and (pirr.completed        = 0)
        and (pirr.active           = 1)
      )

	  /*============================================================
       * If incomplete request is not found then exit
       *============================================================*/

      if (@pirrID = -1)
      begin
        RAISERROR ('Request for information not found or response already received', 11, 1)
      end
      
	  /*============================================================
       * Start saving and updating data
       *============================================================*/
      
	  set @canFlagAsCompleted = 1

	  BEGIN TRANSACTION
      SET @tranOpen = 1

        /*============================================================
         * Save response data
         *============================================================*/

	    UPDATE dbo.Patient_Info_Requests_Responses
        SET
            [insuranceCarrierID]                    = @insuranceCarrierID
          , [insuranceCarrierPolicyHolderFirstName] = @insuranceCarrierPolicyHolderFirstName
          , [insuranceCarrierPolicyHolderLastName]  = @insuranceCarrierPolicyHolderLastName
          , [policyNumber]                          = @policyNumber
          , [insuranceCarrierOtherName]             = @insuranceCarrierOtherName
          , [insuranceGroupNumberID]	            = @insuranceGroupNumberID
		  , [responderSignatureImgData]             = @responderSignatureImgData
          , [responseReceivedByPatPerID]            = @patPerID
		  , [responderUserIP]                       = @userIP
		  , [responderUserAgent]                    = @userAgent
		  , [noInsuranceOptionSelected]             = @noInsuranceOptionSelected              
          , [otherInsuranceOptionSelected]          = @otherInsuranceOptionSelected           
          , [consentToReleaseOfChildHealthRecsAndOrBenefitInfo]	= @consent
		  , [responseReceived]                                  = 1
		  , [responseReceivedOn]                                = @today
		  , [lastModified]                                      = @today
          , [lastModifiedBy]                                    = 0
		where 
		  (id = @pirrID)
	   
	   /*============================================================
         * Update patient record with FERPA consent data
         *============================================================*/

	   update dbo.PATIENTS_Patient
	   set 
	       ferpaConsent              = @consent
	     , ferpaConsentEffectiveDate = @today
	   where 
	     (PATIENT_ID = @patID)

	   /*============================================================
         * If consent was a NO then flag for review
         *============================================================*/

	   if (@consent = 0) set @canFlagAsCompleted = 0
	   
	   /*============================================================
        * If NEITHER the no insurance option and the other insurance
		* options were selected then a carrier was selected
        *==========================================================*/
	
        if ((@noInsuranceOptionSelected = 0) and (@otherInsuranceOptionSelected = 0))
		begin
		  
          /*============================================================
           * Attempt to update the insurance data
           *============================================================*/

		  set @insuranceDataUpdated = 0	      
	
	      exec dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_UPDATE_INSURANCE_DATA_CORE 
             0         
           , @pirrID
           , @today
		   , 1
		   , @insuranceDataUpdated      output
	       , @patientInsuranceCarrierID output

          /*============================================================
           * If the insurance update failed then flag for review
           *============================================================*/

           if (@insuranceDataUpdated = 0) 
		   begin
		     set @canFlagAsCompleted = 0
		   end
		   
		   /*============================================================
            * Otherwise update the response data with the patients
		    * insurance record id
            *============================================================*/

           else
		   begin
		     UPDATE dbo.Patient_Info_Requests_Responses
             SET
               [patientInsuranceCarrierRecID] = @patientInsuranceCarrierID
		     where 
		       (id = @pirrID)
	       end /* Updating response data */
		   		   			
		end /* Carrier selected */
		
		/*============================================================
         * Otherwise the no insurance or the other insurance options
		 * were selected so we flag for review	  	 
         *==========================================================*/
	
		else 
		begin		  
		  set @insuranceDataUpdated = 0	
		  set @canFlagAsCompleted   = 0	          		  	
		end /* Carrier not selected */

		/*============================================================
         * If we reached this point and this response has not been
		 * flagged for review we can consider it COMPLETE 
         *==========================================================*/

        if (@canFlagAsCompleted = 1)
		begin			    

	      UPDATE dbo.Patient_Info_Requests_Responses
          SET
              [reviewRequired]               = 0
            , [reviewed]                     = 0
	        , [lastModified]                 = @today
		    , [lastModifiedBy]               = 0
		    , [completed]                    = 1
		    , [completedBy]                  = 0
		    , [completedOn]                  = @today
		    , [patPerCompleted]              = 1      /* Denote that pg response resulted in a completion */
		  where 
		    (id = @pirrID)
        end /* No review required - This cycle is complete */

		/*============================================================
         * Otherwise this response has to be reviewed 
		 * and the review process will determine the complete status 
         *==========================================================*/

	    else
		begin
		   UPDATE dbo.Patient_Info_Requests_Responses
           SET
                [reviewRequired]            = 1
			  , [reviewed]                  = 0
              , [lastModified]              = @today
		      , [lastModifiedBy]            = 0
		   where 
            (id = @pirrID)		        
		end /* Needs a review */

    /*-------------------------------
     * If we reach this point everything is OK
     * commit our changes and exit
     *------------------------------*/

      COMMIT TRANSACTION
      SET @tranOpen = 0
      
      RETURN(0)

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

GRANT EXECUTE ON dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_SAVE TO webuser;
GO

