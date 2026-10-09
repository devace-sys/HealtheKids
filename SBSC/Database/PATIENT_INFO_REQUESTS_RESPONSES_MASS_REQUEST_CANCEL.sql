USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_CANCEL') 
      AND type IN (N'P', N'PC')
)
DROP PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_CANCEL
GO

CREATE PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_CANCEL (
      @userID             bigint
    , @userGroup          int
    , @userRank           int
    , @clientID           bigint
	, @ageInDays          int   = 0     /* 0 = cancel everything */
	, @editDelReason	  VARCHAR(7000)
    , @validateRec        BIT	
    , @MsgNoRec           VARCHAR(1000)
    , @MsgNoEdit          VARCHAR(1000)
    , @spDetails          VARCHAR(8000) OUTPUT
    , @recordID           BIGINT        OUTPUT
)
AS
BEGIN
  
    SET NOCOUNT ON

    declare @today       AS DATETIME = null     -- Current date/time stamp
    declare @tranOpen    AS BIT      = null     -- Is a transaction open

    /*============================================================
     * Init
     *============================================================*/

    set @spDetails = ''
	set @recordID  = 0
    set @today     = GETDATE()
    set @tranOpen  = 0
	
	declare @recsToCancel as table (
	  id bigint
	  unique clustered (id)
	)

   /*============================================================
    * If a bulk info request exists and its currently being
    * processed (emails being distributed) exit.  We dont want
	* the user to attempt a bulk cancel until this is completed.
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
      * Find all pending requests
      *
	  * Note: Keep this logic in synch with 
	  * PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_CANCEL.sql
	  *============================================================*/

	insert into @recsToCancel (id)
	select 
      t2.id
    from
    (
      select 
          age = datediff(day,t1.created,@today)
        , t1.id 
      from dbo.Patient_Info_Requests_Responses as t1
      where (
	        (clientID = @clientID)
		and (responseReceived = 0)			
        and (completed        = 0)			
        and (active           = 1)
      )
  ) as t2
  where 
    (t2.age >= @ageInDays)
  
  set @recordID = 0
  select @recordID = count(t1.id) from @recsToCancel as t1
  
  if (@recordID = 0)    return (0)
  if (@validateRec = 1) return(0)

  BEGIN TRY

	  BEGIN TRANSACTION
      
	  SET @tranOpen = 1

      /*============================================================
       * Mass cancel all requests that are still pending
       *
	   * Note: Keep this logic in synch with 
	   * PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_CANCEL.sql
	   *============================================================*/

	    update t2
		set
            t2.[lastModified]              = @today
		  , t2.[lastModifiedBy]            = @userID
		  , t2.[canceled]                  = 1
		  , t2.[completed]                 = 1
		  , t2.[completedBy]               = @userID
		  , t2.[completedOn]               = @today
		from @recsToCancel                       as t1
		join dbo.Patient_Info_Requests_Responses as t2 on t2.id = t1.id

		/*-------------------------------
         * If we reach this point everything 
		 * is OK commit our changes 
		 * and exit
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

GRANT EXECUTE ON dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_REQUEST_CANCEL TO webuser;
GO

