USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_CANCEL') 
      AND type IN (N'P', N'PC')
)
DROP PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_CANCEL
GO

CREATE PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_CANCEL (
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

    /*============================================================
     * Init
     *============================================================*/

    set @spDetails = ''
	set @recordID  = 0
    set @today     = GETDATE()
    set @tranOpen  = 0
	
    BEGIN TRY

	  /*============================================================
       * If a bulk request exists and its currently being
       * processed (emails being distributed) exit.
       *============================================================*/
 	
      if exists (
        select top 1 
          t1.id 
        from dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES as t1
        where (
              (t1.clientID   = @clientID)
          and (t1.completed  = 0)
          and (t1.active     = 1)
        )
        order by 
          t1.id desc
      )
      begin
        RAISERROR ('A bulk student information request is currently being processed.  Please wait for a minute then try again.', 11, 1)
        return(0)
      end

	  /*============================================================
       * Find pending request
	   * 
	   * Note: Keep this logic in synch with 
	   * PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_CANCEL.sql
       *============================================================*/
	         
	  set @pirrID = -1

      select top 1       
	      @pirrID = isnull(pirr.id,-1)
      from dbo.Patient_Info_Requests_Responses as pirr
      where ( 
                (pirr.clientID         = @clientID)
			and (pirr.id               = @recID)            
			and (pirr.responseReceived = 0)			
            and (pirr.completed        = 0)
            and (pirr.active           = 1)
      )

      if (@pirrID = -1)
      begin	    
        RAISERROR ('Request for information not found or response already received', 11, 1)
      end
	  else
	  begin
	    set @recordID = @pirrID
	  end

	  BEGIN TRANSACTION
      
	  SET @tranOpen = 1

      /*============================================================
       * Cancel pending request
	   * 
	   * Note: Keep this logic in synch with 
	   * PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_CANCEL.sql
       *============================================================*/

	    UPDATE dbo.Patient_Info_Requests_Responses
        SET
            [lastModified]              = @today
		  , [lastModifiedBy]            = @userID
		  , [canceled]                  = 1
		  , [completed]                 = 1
		  , [completedBy]               = @userID
		  , [completedOn]               = @today
		where 
		  (id = @recordID)

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

GRANT EXECUTE ON dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_CANCEL TO webuser;
GO

