USE [spedmon]
GO

DROP PROCEDURE if exists [dbo].[PATIENT_DATA_SAVE]
GO


CREATE PROCEDURE [dbo].[PATIENT_DATA_SAVE](
    @userID               BIGINT    
  , @userGroup            INT  
  , @userRank             INT 
  , @clientID             BIGINT
  , @recID                BIGINT
  , @phone                VARCHAR(255)
  , @email                VARCHAR(255)
  , @street1              VARCHAR(1000)
  , @street2			  VARCHAR(1000)
  , @city                 VARCHAR(100)
  , @state                VARCHAR(2)
  , @zip5                 VARCHAR(5)
  , @zip4                 VARCHAR(4)
  , @patientHomePlaceID   BIGINT
  , @contactMethod        INT
  , @editDelReason        VARCHAR(7000)
  , @validateRec          BIT
  , @MsgNoRec             VARCHAR(max)
  , @MsgNoEdit            VARCHAR(max)    
  , @MsgNoClient          VARCHAR(1000)  
  , @recordID             BIGINT        OUTPUT
  , @spDetails            VARCHAR(8000) OUTPUT)  
AS    
BEGIN

SET NOCOUNT ON      

DECLARE @updateState   AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @auditRecID    AS BIGINT         -- Audit record id  
DECLARE @canEdit       AS BIT   
DECLARE @tempRecID     AS INT            -- Used for determining if a rec exists 
DECLARE @isActive      AS BIT  
DECLARE @today         AS DATETIME = GETDATE()
DECLARE @TranOpen      AS BIT = 0
DECLARE @tempClientID  AS INT
DECLARE @activeClaimRecs AS INT   
DECLARE @activeSvcRecs   AS INT 
DECLARE @saveType		 AS INT 
DECLARE @onFileContactMethod AS INT = NULL

BEGIN TRY  
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @recordID  = 0;
SET @spDetails = '';

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
    
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
IF (@clientID    IS NULL) RAISERROR ('Client ID is required',   11, 1)    
IF (@recID		 IS NULL) RAISERROR ('updateRecID is required', 11, 1) 

IF (@contactMethod IS NOT NULL AND @contactMethod NOT IN (10,20,30,40,50))
    RAISERROR('Invalid contact method code.', 11, 1)  

/*-------------------------------    
 * Verify client id exists    
 *-------------------------------*/    
    
SET @tempRecID = NULL    
SELECT @tempRecID = CLIENT_ID FROM CLIENTS_CLIENT WHERE CLIENT_ID = @ClientID    
IF (@tempRecID <> @clientID)    
  RAISERROR (@MsgNoClient, 11, 1)   

/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/  

SET @isActive    = 1  
SET @editDelReason = 'user updated person information'
SET @recordID = null    
SET @canEdit  = 1  
SET @saveType = dbo.CONST_SAVE_TYPE_EDIT() 
         
/*-------------------------------    
 * Does the record exist and if    
 * so can it be edited    
 *
 * TODO: Determine new canEdit
 * criterea.  If the rec is active
 * is no longer how we can tell
 *------------------------------*/     
    
  select     
    @recordID       = pp.PATIENT_ID,     
    @isActive       = dbo.YN_TO_BIT(pp.ACTIVE),
	@onFileContactMethod = pp.preferredContactMethodCode
  from PATIENTS_Client  as pc
  join PATIENTS_Patient as pp on pp.PATIENT_ID = pc.PATIENT_ID 
  WHERE pc.CLIENT_ID  = @clientID
      AND pp.PATIENT_ID = @recID;   
    
  IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)        
  IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1)  

  IF (
    @contactMethod IS NOT NULL
    AND ISNULL(@onFileContactMethod, 10) <> @contactMethod
    )
  BEGIN
    SET @editDelReason = 'user change de contact method from portal screen'
  END

  /*-------------------------------    
   * If we are providing advisement    
   * validation exit now    
   *------------------------------*/    
         
  IF (@validateRec = 1) RETURN(0)  
    

BEGIN TRANSACTION    
  /*-------------------------------    
   * Edit existing patient record    
   *------------------------------*/    
      
  SET @updateState = dbo.CONST_REC_STATE_MOD() 
  set @TranOpen = 1    
  
  UPDATE pp
  SET 
    pp.LAST_UPDATED                     = @today
    , pp.userID                         = @userID
    , pp.[state]                        = @updateState
	, pp.preferredContactMethodCode		=
		CASE
		  WHEN @contactMethod IS NULL THEN pp.preferredContactMethodCode
		  ELSE @contactMethod
		END
  from [dbo].[PATIENTS_Client] as pc
  join [dbo].PATIENTS_Patient  as pp on pp.PATIENT_ID = pc.PATIENT_ID
  where (
           (pc.CLIENT_ID  = @clientID)
       and (pp.PATIENT_ID = @recordID)
  )

  /*-------------------------------    
   * Manage email and phone
   *------------------------------*/    
  
   exec dbo.PATIENT_EMAIL_ADDRESS_MANAGE_CORE @userID, @today, @recordID, @email
   exec dbo.PATIENT_PHONE_NUMBER_MANAGE_CORE  @userID, @today, @recordID, @phone 

   /*-------------------------------    
    * Manage primary home address
    *------------------------------*/  
   
   set @patientHomePlaceID = isnull(@patientHomePlaceID,0)

   set @street1 = trim(isnull(@street1,''))
   set @street2 = trim(isnull(@street2,''))
   set @city    = trim(isnull(@city,''))
   set @state   = trim(isnull(@state,''))
   set @zip5    = trim(isnull(@zip5,''))
   set @zip4    = trim(isnull(@zip4,''))

   if (@patientHomePlaceID = 0)
   begin
     declare @createNewPatientPlace as bit = 0

	 set @createNewPatientPlace = case 
	   when @street1 != '' then 1
	   when @city    != '' then 1
	   when @state   != '' then 1
	   when @zip5    != '' then 1	     
	   else 0
	 end
	 if (@createNewPatientPlace = 1)
	 begin

       insert into dbo.PATIENT_PLACES (
           CLIENT_ID
	     , PATIENT_ID
	     , NAME 
	     , PATIENT_PLACE_TYPE
	     , PLACE_FORMAT_TYPE
	     , PLACE_SOURCE_TYPE
	     , ADDRESS_1
	     , ADDRESS_2
	     , CITY
	     , STATE
	     , ZIP_5
	     , ZIP_4
	     , CREATED_BY
	     , CREATED_ON
	     , ACTIVE 
	   )
       values (
	       @clientID
	     , @recordID
	     , 'Primary Home'
	     , 1 /* PATIENT_PLACE_TYPE */  
	     , 1 /*PLACE_FORMAT_TYPE*/
	     , 2 /*PLACE_SOURCE_TYPE*/
	     , @street1
	     , @street2
	     , @city
	     , @state
	     , @zip5
	     , @zip4
	     , @userID
	     , @today
	     , 1  
	   )
	 
	   set @patientHomePlaceID = SCOPE_IDENTITY()
	 end
   end
   /* Edit patient place */
   else
   begin

	 declare @onFilePatientHomePlaceID as bigint = -1
	 declare @onFileStreet1 as varchar (1000) = ''
	 declare @onFileStreet2 as varchar (1000) = ''
	 declare @onFileCity    as varchar (100)  = ''
	 declare @onFileState   as varchar(2)     = ''
	 declare @onFileZip5    as varchar(5)     = ''
	 declare @onFileZip4    as varchar(4)     = ''

     select top 1
	     @onFilePatientHomePlaceID = isnull(pp.id,-1)
	   , @onFileStreet1            = trim(isnull(pp.ADDRESS_1,''))
	   , @onFileStreet2            = trim(isnull(pp.ADDRESS_2,''))
	   , @onFileCity               = trim(isnull(pp.CITY,''))
	   , @onFileState              = trim(isnull(pp.STATE,''))
	   , @onFileZip5               = trim(isnull(pp.ZIP_5,''))
	   , @onFileZip4               = trim(isnull(pp.ZIP_4,''))
	 from dbo.PATIENT_PLACES as pp 
	 where 
	   (pp.id = @patientHomePlaceID)

	 declare @updatePatientPlaces as bit = 0

	 set @updatePatientPlaces = case 
	   when @onFilePatientHomePlaceID = -1 then 0
	   when @street1 != @onFileStreet1 then 1
	   when @street2 != @onFileStreet2 then 1
	   when @city    != @onFileCity    then 1
	   when @state   != @onFileState   then 1
	   when @zip5    != @onFileZip5    then 1
	   when @zip4    != @onFileZip4    then 1
	   else 0
	 end

	 if (@updatePatientPlaces = 1)
	 begin

	   update dbo.PATIENT_PLACES
	   set 
	       ADDRESS_1 = @street1
	     , ADDRESS_2 = @street2
	     , CITY      = @city
	     , STATE     = @state
	     , ZIP_5     = @zip5
	     , ZIP_4     = @zip4
		 , LAST_MODIFIED_BY = @userID
		 , LAST_MODIFIED_ON = @today
	   where 
	     (id = @patientHomePlaceID)
	 end	 
  end

  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
       
   EXEC PATIENT_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT  

COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)

END TRY    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
     

end
GO


GRANT EXECUTE ON [dbo].[PATIENT_DATA_SAVE] to webuser
GO