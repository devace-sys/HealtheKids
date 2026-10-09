USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.STUDENT_REFERRAL_REQUEST_RESPONSE_SAVE') 
      AND type IN (N'P', N'PC')
)
DROP PROCEDURE dbo.STUDENT_REFERRAL_REQUEST_RESPONSE_SAVE
GO

CREATE PROCEDURE dbo.STUDENT_REFERRAL_REQUEST_RESPONSE_SAVE (
    @userIP                                 VARCHAR(500)                      
  , @userAgent                              VARCHAR(8000)
  , @parentGuardianConsent                  BIT	
  , @isUsed									BIT
  , @requestPublicUrl						VARCHAR(1000)
  , @ptkn									VARCHAR (512) 
  , @recID									BIGINT
  , @parmNamePtkn						    VARCHAR(256)
  , @parmNametoPrac							VARCHAR(256)
  , @requestURL								VARCHAR(MAX)  OUTPUT
  , @pinPract								VARCHAR(10)   OUTPUT
)
AS
BEGIN
  
    SET NOCOUNT ON

    declare @today       AS DATETIME       -- Current date/time stamp
    declare @tranOpen    AS BIT            -- Is a transaction open
	declare @recordID    AS BIGINT

    /*============================================================
     * Init
     *============================================================*/

    set @today     = GETDATE()
    set @tranOpen  = 0

    BEGIN TRY

	/*============================================================
     * Generate new pin for referrals authorization
     *============================================================*/
	 
	set @pinPract		  =''
	select top 1 @pinPract = left(convert(varchar(256),abs(VALUE_INT)),10) from dbo.GENERATE_RANDOM_NUMBERS

	/*============================================================
      * Create request url for parent guardian
      *============================================================*/

	 set @requestURL = @requestPublicUrl 
	                + '?' + @parmNamePtkn + '=' + @ptkn 
					+ '&' + @parmNametoPrac + '=' + 'true'

      if (@recordID = -1)
      begin
        RAISERROR ('Request for information not found or response already received', 11, 1)
      end
      
	  BEGIN TRANSACTION
      SET @tranOpen = 1

        /*============================================================
         * Save Response
         *============================================================*/

	    UPDATE dbo.PRACTITIONER_PATIENT_REFERRALS
        SET
			parentGuardianConsent								= @parentGuardianConsent
		  ,	isUsed												= @isUsed
		  , pinPract											= @pinPract	
		  , approvalRejectionDate								= @today
		  , approvalRejectionTime								= convert(time(0),@today)
		  , lastModified										= @today
          , lastModifiedBy										= 0

		where (
		  (id = @recID) 
		  and (isUsed = 0)
		  and (active = 1)
		  )

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

GRANT EXECUTE ON dbo.STUDENT_REFERRAL_REQUEST_RESPONSE_SAVE TO webuser;
GO

