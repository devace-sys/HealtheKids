USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_COMPLETE_REVIEW') 
      AND type IN (N'P', N'PC')
)
DROP PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_COMPLETE_REVIEW
GO

CREATE PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_COMPLETE_REVIEW (
      @userID             bigint
    , @userGroup          int
    , @userRank           int
    , @clientID           bigint	
	, @editDelReason	  VARCHAR(7000)
    , @validateRec        BIT
	, @recID              bigint
    , @MsgNoRec           VARCHAR(1000)
    , @MsgDupRec          VARCHAR(1000)
    , @MsgNoEdit          VARCHAR(1000)
    , @MsgNotActive       VARCHAR(1000)
    , @MsgDataError       VARCHAR(1000)
    , @saveType           SMALLINT
    , @spDetails          VARCHAR(8000) OUTPUT
    , @recordID           BIGINT OUTPUT
)
AS
BEGIN
  
    SET NOCOUNT ON

    declare @today       AS DATETIME = null     -- Current date/time stamp
    declare @tranOpen    AS BIT      = null     -- Is a transaction open
	declare @pirrID      as bigint
	declare @insuranceDataUpdated        as bit 
	declare @patientInsuranceCarrierID   as bigint

    /*============================================================
     * Init
     *============================================================*/

    set @spDetails = ''
	set @recordID  = 0
    set @today     = GETDATE()
    set @tranOpen  = 0
	
    BEGIN TRY

	  /*============================================================
       * Find request
       *============================================================*/
      
	  set @pirrID = -1

      select top 1       
	      @pirrID = isnull(pirr.id,-1)		
      from dbo.Patient_Info_Requests_Responses as pirr
      where ( 
                (pirr.clientID         = @clientID)
			and (pirr.id               = @recID)
            and (pirr.responseReceived = 1)
            and (pirr.reviewRequired   = 1)
			and (pirr.completed        = 0)
            and (pirr.active           = 1)
      )

      if (@pirrID = -1)
      begin	    
        RAISERROR ('Request for information not found or waiting for response or already reviewed', 11, 1)
      end
	  else
	  begin
	    set @recordID = @pirrID
	  end
	  
	  BEGIN TRANSACTION      
	  SET @tranOpen = 1
	    
        /*============================================================
         * Save Followup Flag
         *============================================================*/

  	    UPDATE dbo.Patient_Info_Requests_Responses
            SET
              [reviewed]                  = 1
            , [lastModified]              = @today
		    , [lastModifiedBy]            = @userID
		    , [completed]                 = 1
		    , [completedBy]               = @userID
		    , [completedOn]               = @today
		    
		  where 
		    (id = @pirrID)      

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

GRANT EXECUTE ON dbo.PATIENT_INFO_REQUESTS_RESPONSES_RESPONSE_COMPLETE_REVIEW TO webuser
GO

