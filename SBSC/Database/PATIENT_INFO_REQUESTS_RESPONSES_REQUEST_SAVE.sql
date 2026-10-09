/* TODO: Future expansion:
   When we implement the update existing insurance info request we will need to pass in a 
   save type of 2 and the existing patientCarrierRecID as @recID and set patientCarrierRecID 
   to this value */

USE SPEDMON
GO

IF EXISTS (
    SELECT * 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_SAVE') 
      AND type IN (N'P', N'PC')
)
BEGIN
  DROP PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_SAVE
END
GO

CREATE PROCEDURE dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_SAVE (
      @userID             BIGINT
    , @userGroup          INT
    , @userRank           INT
    , @clientID           BIGINT
    , @patID              BIGINT
	, @requestBaseUrl     varchar(1000)
	, @parmNamePtkn       varchar(256)
	, @parmNamePatPerID   varchar(256)
	, @patPerIDs          varchar(max)	
	, @requestingWhatInfo tinyint   = 1
	, @individualRequest  bit       = 1
	, @requestFromAuthor  bit       = 1
	, @massUpdateRowID    bigint
	, @editDelReason	  VARCHAR(7000)
    , @validateRec        BIT
    , @recID              BIGINT
    , @MsgNoRec           VARCHAR(1000)
    , @MsgDupRec          VARCHAR(1000)
    , @MsgNoEdit          VARCHAR(1000)
    , @MsgNotActive       VARCHAR(1000)
    , @MsgDataError       VARCHAR(1000)
    , @saveType           SMALLINT             /* Note: Used differently than standard in this procedure */
	, @jsonData           varchar(max)  OUTPUT
    , @spDetails          VARCHAR(8000) OUTPUT
    , @recordID           BIGINT OUTPUT
)
AS
BEGIN

    SET NOCOUNT ON

    declare @today                   as datetime       -- Current date/time stamp
    declare @tranOpen                as bit            -- Is a transaction open
    declare @publicToken             as varchar(512)   -- Used for accessing public token
	declare @numPatPerRecIDs         as int    = 0
	declare @numPatPers              as int    = 0 
	declare @existingRequestRecordID as bigint = -1
	declare @okToCreateRequest       as bit    = 0
	declare @isPartOfMassUpdate      as bit    = 0
	declare @massUpdateRowIDCheck    as bigint = -1
	declare @massUpdateRowProcessed  as bit    = 0

	declare @patPerRecIDs as table (
      id bigint
    )
	
	declare @patPers as table (
        id              bigint
      , [name]          varchar(512)
      , firstName       varchar(255)
      , lastName        varchar(255)
      , email           varchar(255)
      , phone           varchar(255)
	  , clientName      varchar(512)
	  , requestURL      varchar(max)	  
	  , sendEmail       bit default(1)
	  , sendText        bit	default(0)
	  , sentEmail       bit default(0)
	  , sentText        bit default(0)
	  , sentEmailStatus varchar(max) default('')
	  , sendTextStatus  varchar(max) default('')
    )

    /*============================================================
     * Init
     *============================================================*/
    
	set @recordID                = 0
    set @spDetails               = ''
    set @today                   = GETDATE()
    set @tranOpen                = 0
	set @jsonData                = ''
	set @patPerIDs               = trim(isnull(@patPerIDs,''))
	set @numPatPerRecIDs         = 0
	set @numPatPers              = 0 
	set @okToCreateRequest       = 1
	set @existingRequestRecordID = -1
	set @isPartOfMassUpdate      = 0

    /*============================================================
     * Determine if this is a mass update
     *============================================================*/
    
	if (@individualRequest = 0)
	begin
     if (@massUpdateRowID is not null)
     begin
	   set @isPartOfMassUpdate = 1
	 end
    end

	BEGIN TRY

      /*============================================================
       * Required validation
       *============================================================*/
     
	  IF (@userGroup           IS NULL) RAISERROR ('userGroup is required',              11, 1)
      IF (@userID              IS NULL) RAISERROR ('user id is required',                11, 1)
      IF (@userRank            IS NULL) RAISERROR ('userRank is required',               11, 1)
      IF (@validateRec         IS NULL) RAISERROR ('Validate flag required',             11, 1)
      IF (@saveType            IS NULL) RAISERROR ('Save type is required',              11, 1)
      IF (@clientID            IS NULL) RAISERROR ('Client ID is required',              11, 1)
      IF (@patID               IS NULL) RAISERROR ('Patient ID is required',             11, 1)
      if (@requestBaseUrl      IS NULL) RAISERROR ('Request base url is required',       11, 1)
      if (@parmNamePtkn        IS NULL) RAISERROR ('Parm name for ptkn is required',     11, 1)
      if (@parmNamePatPerID    IS NULL) RAISERROR ('Parm name for patperid is required', 11, 1)
      if (len(@patPerIDs) = 0)          RAISERROR ('Patient guardian is required',       11, 1)

      /*============================================================
       * If this is not part of a mass update campaign then
	   * check for campaigns in progress
       *============================================================*/

	  if (@isPartOfMassUpdate = 0)
	  begin
	  
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
        end
	  
	  end /* is individual request */
	  
	  /*============================================================
       * If this is part of a mass update campaign then check
	   * the status of the update row
       *============================================================*/

	  else
	  begin
	  
	    set @massUpdateRowIDCheck    = -1
	    set @massUpdateRowProcessed  = 0

	    /*============================================================
         * Get row
         *============================================================*/

		select top 1 
		   @massUpdateRowIDCheck   = isnull(mur.id,-1)
		 , @massUpdateRowProcessed = mur.processed  /* Has to have value */
		from dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS as mur
		where 
		  (mur.id = @massUpdateRowID)

	    /*============================================================
         * If not found get out
         *============================================================*/
		
		if (@massUpdateRowIDCheck = -1)
		begin		  
	      RAISERROR ('Mass update request row not found', 11, 1)
		end

	    /*============================================================
         * If found and row is already processed get out
         *============================================================*/
		
		if (@massUpdateRowProcessed = 1)
		begin		  
	      RAISERROR ('Mass update request row already processed', 11, 1)
		end
			  
	  end

	  /*============================================================
       * Check for existing requests in all active records
       *============================================================*/

      set @existingRequestRecordID = -1

      select top 1 
		@existingRequestRecordID = isnull(pirr.id,-1)
      from dbo.Patient_Info_Requests_Responses as pirr
      where (
             (1=1)
         and (pirr.clientID  = @clientID) 
         and (pirr.patID     = @patID)
		 and (pirr.completed = 0)
		 and (pirr.active    = 1)
      )
      
      /*============================================================
       * If one exists, exit
       *============================================================*/

	  if (@existingRequestRecordID != -1)
	  begin	        
          RAISERROR (@MsgDupRec, 11, 1)
      end
      else
	  begin
	    set @existingRequestRecordID = null
	  end

	  /*============================================================
       * Extract parent guardian ids
       *============================================================*/
	   
	   insert into @patPerRecIDs (id)
       select 
         [id] = try_convert(bigint,t1.[value]) 
       from string_split(@patPerIDs,',') as t1

	   /*============================================================
        * Count check.  Any fail exit
        *============================================================*/
	   
	   select 
	     @numPatPerRecIDs = count(t1.id) 
	   from @patPerRecIDs as t1

	   if (@numPatPerRecIDs = 0)
	   begin
	     set @okToCreateRequest = 0
	     RAISERROR ('Please select at least one parent/guardian', 11, 1)
	   end

	   if (@numPatPerRecIDs > 10)
	   begin	     
		 RAISERROR ('Requests are limited to a max of 10 parent/guardians per request', 11, 1)
	   end
	   
	   /*============================================================
        * Get parent guardian data
        *============================================================*/
	   
	   insert into @patPers (
           id
         , [name]
         , firstName
         , lastName
         , email
         , phone
		 , clientName
       )
    
	  select 
	      id           = ppp.ID
        , [name]       = pep.FIRST_NAME + ' ' + pep.LAST_NAME
        , firstName    = pep.FIRST_NAME
        , lastName     = pep.LAST_NAME
        , email        = trim(isnull(pep.EMAIL,''))
        , phone        = trim(isnull(pep.PHONE,''))
		, clientName   = clc.CLIENT_NAME
    
	 from dbo.PATIENTS_PERSON  as ppp  
     join @patPerRecIDs        as t1   on  t1.id  = ppp.ID
     join dbo.PERSONS_PERSON   as pep  on  pep.ID = ppp.PERSON_ID
     join dbo.CLIENTS_Client   as clc  on  clc.CLIENT_ID = ppp.CLIENT_ID

	 where (    
           (ppp.CLIENT_ID  = @clientID)
  	   and (ppp.PATIENT_ID = @patID)
	   and (pep.CLASS_ID_1 = 1)
	   and (ppp.ACTIVE     = 1)
	   and (pep.ACTIVE     = 1)
     )
	 
	 /*============================================================
      * Count check.  Any issues exit.
      *============================================================*/

	 select @numPatPers = count(t1.id) from @patPers as t1
	 
	 if (@numPatPers != @numPatPerRecIDs)
	 begin	     
	     RAISERROR ('Unable to find one or more parent/guardian selections', 11, 1)	 
	 end
     
	 /*============================================================
      * Check for valid emails.  Any issues exit.
      *============================================================*/

	 if exists (select top 1 t1.id from @patPers as t1 where (t1.email = ''))
	 begin	     
	     RAISERROR ('All parent guardians selected must have a valid email address', 11, 1)	 
	 end

	 /*============================================================
      * Get final count
      *============================================================*/
    
	 select @numPatPers = count(t1.id) from @patPers as t1

     /*============================================================
      * Search for existing insurance data
      *============================================================*/
/*     
	 declare @policyHolderFirstName as varchar(255)
	 declare @policyHolderLastName as varchar(255)
	 declare @insuranceCarrierID   as bigint
     declare @insuranceGroupNumberID as varchar(256)
	 declare @memberID               as varchar(256)

	 select top 1
        @memberID                = pic3.beneficiaryID
	  , @insuranceCarrierID      = pic3.patInsuranceCarrierID
	  ,	@policyHolderFirstName   = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(LEFT(pic3.policyHolderName, CHARINDEX(' ', pic3.policyHolderName + ' ') - 1),1,1,1,0,35)
	  , @policyHolderLastName    = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(REVERSE(LEFT(REVERSE(pic3.policyHolderName), CHARINDEX(' ', REVERSE(pic3.policyHolderName) + ' ') - 1)),1,1,1,0,60)
	  , @insuranceGroupNumberID  = pic3.policyGroupID
     from
     (
       select 
           pic2.*
  	     , hasCompleteInsuranceInfo = convert(bit,(
           case        
               when pic2.beneficiaryLastName       = '' then 0
	           when pic2.beneficiaryFirstName      = '' then 0
	           when pic2.beneficiaryID             = '' then 0
	           when pic2.carrierCode               = '' then 0
	           when pic2.policyHolderName          = '' then 0
	           else 1
	         end))
        from
        (
          select 
            
			  beneficiaryID         = trim(isnull(pic1.beneficiaryID,''))
	        , beneficiaryLastName   = trim(isnull(pic1.beneficiaryLastName,''))
            , beneficiaryFirstName  = trim(isnull(pic1.beneficiaryFirstName,''))
	        , carrierCode           = trim(isnull(ic.carrierCode,''))
	        , policyHolderName      = trim(isnull(pic1.policyHolderName,''))
	        , policyGroupID         = trim(isnull(pic1.policyGroupID,''))
            , planSupportedByCYBHI  = isnull(ic.planSupportedByCYBHI,0)
	        , patInsuranceCarrierID = pic1.id
			
          from dbo.PATIENT_INSURANCE_CARRIERS as pic1  
          join dbo.INSURANCE_CARRIERS         as ic on ic.id = pic1.insuranceCarrierID

          where (
                (pic1.clientID = @clientID)
            and (pic1.patID    = @patID)
            and (pic1.active   = 1)
          )
        ) as pic2
      
	  ) as pic3
      where (
	        (pic3.hasCompleteInsuranceInfo = 1)
		and (pic3.planSupportedByCYBHI     = 1)
	  )
	  order by 
        pic3.patInsuranceCarrierID desc
*/
    
	 /*============================================================
      * Exit if in validation mode
      *============================================================*/
          
     IF (@validateRec = 1)
     BEGIN
         SET @recordID          = 0		 
         RETURN(0)
     END

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
      * Create request url for each parent guardian
      *============================================================*/
     
	 update @patPers 
	 set requestURL = @requestBaseUrl 
	                + '?' + @parmNamePtkn     + '=' + @publicToken
					+ '&' + @parmNamePatPerID + '=' + convert(varchar(256),id)

	 /*============================================================
      * Get json data (we both save and return this)
      *============================================================*/
     
	 set @jsonData = (select * from @patPers FOR JSON AUTO, INCLUDE_NULL_VALUES)
     
	 /*============================================================
      * Save Data
      *============================================================*/
         
     BEGIN TRANSACTION
         
		 SET @tranOpen = 1

         INSERT INTO dbo.Patient_Info_Requests_Responses (
                      [publicToken]
                    , [clientID]
                    , [patID]
					, [patPerIDs]
					, [numPatPerIDs]
					, [requestingSaveType]
					, [requestSent]
					, [requestSentOn]
					, [requestSentToJSON]
                    , [created]
                    , [createdBy]
					, [completed]
                    , [active]           
					, requestingWhatInfo /* Future use */
	                , individualRequest 
	                , requestFromAuthor					      
          )
          VALUES (
                      @publicToken
                    , @clientID
                    , @patID
					, @patPerIDs
					, @numPatPers
					, @saveType  /* Request save type.  Note: Different use than standard.  We will use this to denote if we are updating info. */
					, 0          /* requestSent */
					, null       /* requestSentOn */
					, @jsonData  /* requestSentToJSON */
                    , @today
                    , @userID
					, 0 /* Completed */
                    , 1 /* Active */
					, @requestingWhatInfo /* Future Use */
	                , @individualRequest 
	                , @requestFromAuthor      
           )

        SET @recordID = SCOPE_IDENTITY()   

		/* If this is part of a mass update campaign then update the mass update row */
		
		if (@isPartOfMassUpdate = 1)
		begin
		  update dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS
		  set 
		      processed          = 1
			, okToCreateRequest  = 1
		    , pirrID             = @recordID
		  where (
		          (id = @massUpdateRowID)		
			  and (processed = 0)	
		  )
		end
		  
        /*-------------------------------
         * If we reach this point everything 
		 * is OK commit our changes and exit
         *------------------------------*/
        
		COMMIT TRANSACTION
        SET @tranOpen = 0
        
        RETURN(0)

    END TRY
    BEGIN CATCH
        
		
		/*-------------------------------
         * If we end up here something went wrong.
         * Cancel any pending transactions 
		 * and return any error
         * messages to the caller
         *------------------------------*/
        
		IF @tranOpen = 1 ROLLBACK TRANSACTION

		set @jsonData          = ''

        DECLARE @ErrorMessage  NVARCHAR(4000)
        DECLARE @ErrorSeverity INT
        DECLARE @ErrorState    INT

        SELECT  @ErrorMessage  = ERROR_MESSAGE(),
                @ErrorSeverity = ERROR_SEVERITY(),
                @ErrorState    = ERROR_STATE()        
		
		if (@isPartOfMassUpdate = 1)
		begin
		  update dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS
		  set 
		        processed         = 1
		      , pirrID            = @existingRequestRecordID  /* In case its an existing request record */
			  , okToCreateRequest = 0
			  , errorMessage      = @ErrorMessage
		  where 
		          (id = @massUpdateRowID)
			  and (processed = 0)
        end

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

    END CATCH
END
GO

GRANT EXECUTE ON dbo.PATIENT_INFO_REQUESTS_RESPONSES_REQUEST_SAVE TO webuser
GO

