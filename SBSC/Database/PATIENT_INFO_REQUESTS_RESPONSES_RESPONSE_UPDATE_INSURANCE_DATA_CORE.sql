USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_UPDATE_INSURANCE_DATA_CORE') 
      AND type IN (N'P', N'PC')
)
DROP PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_UPDATE_INSURANCE_DATA_CORE
GO

CREATE PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_UPDATE_INSURANCE_DATA_CORE (
      @userID                       bigint
    , @requestID                    bigint
    , @today                        datetime
	, @dataWasDirectlyInputByPatPer bit
	, @dataUpdated                  bit    output
	, @patientInsuranceCarrierID    bigint output
)
AS
BEGIN
  
    SET NOCOUNT ON

	declare @pirrID      as bigint
	declare @clientID    as bigint
	declare @patID       as bigint   

	declare @insuranceCarrierID                    as bigint
    declare @insuranceCarrierPolicyHolderFirstName as varchar (255)
    declare @insuranceCarrierPolicyHolderLastName  as varchar (255)
    declare @policyNumber                          as varchar (80)
    declare @insuranceGroupNumberID                as varchar (256)
    declare @insuranceCarrierOtherName             as varchar (256)
	declare @beneficiaryLastName                   as varchar (60)
    declare @beneficiaryFirstName                  as varchar (35)
	declare @policyHolderName                      as varchar (512)
	
    /*============================================================
     * Init
     *============================================================*/

	set @patientInsuranceCarrierID = -1
	set @dataUpdated               = 0

    BEGIN TRY

	  /*============================================================
       * Find request
       *============================================================*/
      
	  set @pirrID = -1

      select top 1       
	      @pirrID                                = isnull(pirr.id,-1)
        , @clientID                              = pirr.clientID
		, @patID                                 = pirr.patID
	    , @insuranceCarrierID                    = pirr.insuranceCarrierID
        , @insuranceCarrierPolicyHolderFirstName = pirr.insuranceCarrierPolicyHolderFirstName
        , @insuranceCarrierPolicyHolderLastName  = pirr.insuranceCarrierPolicyHolderLastName
        , @policyNumber                          = pirr.policyNumber
        , @insuranceGroupNumberID                = pirr.insuranceGroupNumberID
        , @insuranceCarrierOtherName             = pirr.insuranceCarrierOtherName
		
      from dbo.Patient_Info_Requests_Responses as pirr
      where ( 
			    (pirr.id               = @requestID)
            and (pirr.responseReceived = 1)			
            and (pirr.completed        = 0)
            and (pirr.active           = 1)
      )

      if (@pirrID = -1)
      begin	    
	    set @patientInsuranceCarrierID = -1
		set @dataUpdated               = 0	    
		return(0)        
      end
	  
	  else
	  begin

	    if ((@insuranceCarrierID > 0) and (not exists (select top 1 ic.id from dbo.INSURANCE_CARRIERS as ic where (ic.id = @insuranceCarrierID))))
        begin
  	      set @patientInsuranceCarrierID = -1
		  set @dataUpdated               = 0	              
		  return(0)
        end
  
        /*============================================================
          * Get patient data
          *============================================================*/
        
		declare @recordIDCheck as bigint = -1
		      
	    select top 1 
	        @beneficiaryLastName  = convert(varchar(50),pap.LAST_NAME)
	      , @beneficiaryFirstName = convert(varchar(35),(left(pap.FIRST_NAME,35)))
	      , @recordIDCheck        = pap.PATIENT_ID
		from dbo.PATIENTS_Patient as pap
	    where 
	      (pap.PATIENT_ID = @patID)
	  
	    if (isnull(@recordIDCheck,-1) = -1)
		begin
		  set @patientInsuranceCarrierID = -1
		  set @dataUpdated               = 0	              
		  return(0)
		end

	    /*============================================================
         * Update insurance data
         *============================================================*/

	    set @patientInsuranceCarrierID = -1

	    set @policyHolderName = @insuranceCarrierPolicyHolderFirstName 
	                          + ' ' 
			  				  + @insuranceCarrierPolicyHolderLastName

	    INSERT INTO dbo.PATIENT_INSURANCE_CARRIERS (
	           clientID
             , patID
             , insuranceCarrierID 
             , beneficiaryLastName
	         , beneficiaryFirstName
             , beneficiaryID
             , policyHolderName
             , insCarrierNameStr
             , policyGroupID
             , expiredOrInvalid
	         , created
	         , createdBy
	         , active
			 , dataWasDirectlyInputByPatPer
			 , primaryCarrier )
	     
	     values (
	         @clientID
	       , @patID
	       , @insuranceCarrierID 
           , @beneficiaryLastName
	       , @beneficiaryFirstName
           , @policyNumber
           , @policyHolderName
		   , @insuranceCarrierOtherName
           , @insuranceGroupNumberID
           , 0         /*expiredOrInvalid*/
	       , @today    /* created */
	       , @userID   /* created by */
	       , 1         /* active */
		   , @dataWasDirectlyInputByPatPer
		   , 1			/* primary carrier*/
	     )
		  
	     set @patientInsuranceCarrierID = SCOPE_IDENTITY()      
		 set @dataUpdated               = 1             
         RETURN(0)
	  end

    END TRY
    BEGIN CATCH

	     set @patientInsuranceCarrierID = -1
		 set @dataUpdated               = 0            

        /*-------------------------------
         * If we end up here something went wrong.
         * Return any error
         * messages to the caller
         *------------------------------*/

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

GRANT EXECUTE ON dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_UPDATE_INSURANCE_DATA_CORE TO webuser
GO

