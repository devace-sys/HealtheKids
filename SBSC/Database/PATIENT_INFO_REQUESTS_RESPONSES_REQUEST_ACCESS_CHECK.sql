USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_ACCESS_CHECK') 
      AND type IN (N'P', N'PC')
)
DROP PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_ACCESS_CHECK
GO

CREATE PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_ACCESS_CHECK (
     @userIP                                 varchar(500)                      
   , @userAgent                              varchar(8000)        
   , @ptkn                                   varchar(512)  
   , @accessGranted                          bit output
)
AS
BEGIN
  
    SET NOCOUNT ON

	declare @userID                   as bigint = 0
    declare @today                    as DATETIME
    declare @tranOpen                 as BIT    
	declare @pirrID                   as bigint 
	declare @patID                    as bigint
	declare @clientID                 as bigint
	declare @accessAttemptsAllowedCtr as smallint = 5
	declare @accessAttemptsAllowed    as tinyint  = 5 /* tinyints dont store negative*/
	declare @accessLockedOut          as bit      = 0

    /*============================================================
     * Init
     *============================================================*/

    set @today                    = GETDATE()
    set @tranOpen                 = 0
	set @pirrID                   = -1
    set @userID                   = 0
	set @accessAttemptsAllowedCtr = 5
	set @accessAttemptsAllowed    = 5
	set @accessLockedOut          = 0
	set @accessGranted            = 0

    BEGIN TRY

	  /*============================================================
       * Find request
       *============================================================*/

      select top 1
          @pirrID                   = isnull(pirr.id,-1)  
		, @clientID                 = pirr.clientID
		, @patID                    = pirr.patID
	    , @accessAttemptsAllowedCtr = pirr.accessAttemptsAllowed
		, @accessLockedOut          = pirr.accessLockedOut
	  from dbo.Patient_Info_Requests_Responses as pirr
      where ( 
            (pirr.publicToken      = @ptkn)
        and (pirr.responseReceived = 0)       
		and (pirr.completed        = 0)
        and (pirr.active           = 1)
      )
	  
	  /*============================================================
       * If request is not found
       *============================================================*/

      if (@pirrID = -1)
      begin
		set @accessGranted = 0
		return(0)
      end

	  /*============================================================
       * Just in case access was denied in another process
       *============================================================*/
  
	  if (@accessLockedOut = 1)
	  begin
        set @accessGranted = 0
		return(0)
	  end

	  /*============================================================
		* Note: DOB validation was removed.
		* But if an access check using a passkey or something else
		* is required then this is a good place to inject it.
		*============================================================*/
		
		set @accessGranted         = 1
		set @accessAttemptsAllowed = 5 /* Reset in case they exit before completing form and have to do it again*/
		set @accessLockedOut       = 0
        
	  BEGIN TRANSACTION
        SET @tranOpen = 1

	    update Patient_Info_Requests_Responses
	    set 		     
		       responderUserIP       = @userIP
		     , responderUserAgent    = @userAgent
		     , accessAttemptsAllowed = @accessAttemptsAllowed
             , accessLockedOut       = @accessLockedOut
		     , lastModified          = @today
		     , lastModifiedBy        = @userID
		     , [completed]           = iif ((@accessLockedOut = 1),1,0)
		     , [completedBy]         = iif ((@accessLockedOut = 1),@userID,null)
		     , [completedOn]         = iif ((@accessLockedOut = 1),@userID,null)

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

GRANT EXECUTE ON dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_ACCESS_CHECK TO webuser;
GO

