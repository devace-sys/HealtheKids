USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM') 
      AND type IN (N'P', N'PC')
)
DROP PROCEDURE dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM
GO

CREATE PROCEDURE dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM (
    @userIP                                 varchar(500)                      
  , @userAgent                              varchar(8000)        
  , @ptkn                                   varchar(512)       
  
  , @patientFirstName                 nvarchar(50)
  , @patientLastName                  nvarchar(50)
  , @patientDOB                       datetime    

  , @studentID                        nvarchar(50) 
  , @insuranceCarrierID               bigint
  , @memberID                         varchar(80)
  , @noInsuranceOptionSelected        bit
  , @otherInsuranceOptionSelected     bit
  , @insuranceCarrierOtherName        varchar(256)
  , @consentToReleaseOfChildHealthRecsAndOrBenefitInfo bit 
  , @responderIsParentGuardian                         bit 
  , @responderFirstName                                nvarchar(50)
  , @responderLastName                                 nvarchar(50)
  , @responderEmail                                    varchar(255)
  , @responderPhone                                    varchar(255)
  , @responderSignatureImgData                         varchar(max)
)
AS
BEGIN
  
    SET NOCOUNT ON

    declare @today       AS DATETIME       -- Current date/time stamp
    declare @tranOpen    AS BIT            -- Is a transaction open
	declare @pirrID      as bigint         -- Request id
	declare @clientID    as bigint
	declare @patID       as bigint
	declare @patPerID    as bigint

    /*============================================================
     * Init
     *============================================================*/

    set @today     = GETDATE()
    set @tranOpen  = 0
	set @pirrID    = -1

    BEGIN TRY

	  /*============================================================
       * Find public token 
       *============================================================*/

      select top 1
          @pirrID   = isnull(t1.id,-1)  
		, @clientID = t1.clientID
      from dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS_GET_BY_PTKN (@ptkn) as t1

      if (@pirrID = -1)
      begin
        RAISERROR ('Form not found or form is no longer valid', 11, 1)
      end

	  /*============================================================
       * Clean up parameters we will use to attempt to find a patient
       *============================================================*/

	  set @studentID        = trim(isnull(@studentID,       N''))
	  set @patientFirstName = trim(isnull(@patientFirstName,N''))
	  set @patientLastName  = trim(isnull(@patientLastName, N''))
	        
	   /*============================================================
        * Attempt to find patID using student id
        * if the student id has been passed
		*============================================================*/

       set @patID = -1	   

       if (len(@studentID) > 0)
       begin

         select top 1 
           @patID = isnull(ps.PATIENT_ID,-1)
         from dbo.PATIENTS_SCHOOL as ps
         join dbo.PATIENTS_Client as pc on ((pc.CLIENT_ID = @clientID) and (pc.PATIENT_ID = ps.PATIENT_ID))
         /* Uses [STUDENT_ID_PAT_ID_IDX] index */
         where (
               (ps.STUDENT_ID = @studentID)
           and (ps.PATIENT_ID        is not null)
           and (ps.PATIENT_SCHOOL_ID is not null)
         )
       end

	   /*============================================================
        * Attempt to find patID using first + last + date of birth
		* if the student id was not passed or the search by student id
		* did not find the patient        
		*============================================================*/
       
	   if (@patID = -1)
	   begin
	     
		 /* If we have last + first + dob available try to find the patient */

	     if ((len(@patientLastName) > 0) and (len(@patientFirstName) > 0) and (@patientDOB is not null))
	     begin

	       select top 1 
		     @patID = isnull(pap.PATIENT_ID,-1)
		   from dbo.PATIENTS_Patient as pap
		   join dbo.PATIENTS_Client  as pc on ((pc.CLIENT_ID = @clientID) and (pc.PATIENT_ID = pap.PATIENT_ID))
		   /* Uses [LAST_FIRST_DOB_SEX_ID] index */
           where (
                 (pap.LAST_NAME     = @patientLastName)
             and (pap.FIRST_NAME    = @patientFirstName)
             and (pap.DATE_OF_BIRTH = @patientDOB)
		     and (pap.ACTIVE        = N'Y')
		     and (pap.PATIENT_ID is not null)
           )
	     end
	   end

	   if (@patID = -1) set @patID = null
	   
	   if (@patID is not null)
	   begin
	     if (@responderEmail is not null)
	     begin
		   select top 1
		     @patPerID = patper.id
		   from dbo.PATIENTS_PERSON as patper
	       join dbo.PERSONS_PERSON  as per on per.id = patper.PERSON_ID
	       where (
		          (patper.CLIENT_ID  = @clientID)
	          and (patper.PATIENT_ID = @patID)
	          and (patper.ACTIVE     = 1)	       
		      and (per.CLASS_ID_1    = 1)
	          and (per.EMAIL         = @responderEmail)
		      and (per.ACTIVE        = 1)
	       )
	     end
	   end

	  BEGIN TRANSACTION
      SET @tranOpen = 1

      /*============================================================
       * Save Response
       *============================================================*/
	
	insert into dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES (     
	  patInfoReqPublicInsuranceFormID
	, patientFirstName                 
	, patientLastName                  
	, patientDOB                       
	, studentID                        
	, insuranceCarrierID               
	, memberID                        
	, noInsuranceOptionSelected       
	, otherInsuranceOptionSelected    
	, insuranceCarrierOtherName       
	, consentToReleaseOfChildHealthRecsAndOrBenefitInfo 
	, responderIsParentGuardian                         
	, responderFirstName       
	, responderLastName        
	, responderEmail           
    , responderPhone    
	, responderSignatureImgData 
	, responderUserIP    
	, responderUserAgent 	

	, clientID       
	, patID      
	, created    
	, createdBy  
	, patPerID
   )
   values (
	  @pirrID
    , @patientFirstName 
    , @patientLastName  
    , @patientDOB    
    , @studentID             
    , @insuranceCarrierID    
    , @memberID                       
    , @noInsuranceOptionSelected      
    , @otherInsuranceOptionSelected   
    , @insuranceCarrierOtherName      
    , @consentToReleaseOfChildHealthRecsAndOrBenefitInfo 
    , @responderIsParentGuardian   
    , @responderFirstName
    , @responderLastName 
    , @responderEmail 
    , @responderPhone 
    , @responderSignatureImgData 
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

GRANT EXECUTE ON dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORM_RESPONSES_SAVE_FROM_PUBLIC_FORM TO webuser;
GO

