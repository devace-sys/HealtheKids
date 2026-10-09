USE SPEDMON
GO



/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_Save_Profile') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_Save_Profile
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PATIENT_Save_Profile] (
    @userID                             BIGINT
  , @userGroup                          INT    
  , @userRank                           INT
  , @clientID                           INT
  , @siteID                             INT    
  , @siteRefID                          NVARCHAR(50)    
  , @siteRank                           NVARCHAR(2)      
  , @lname                              VARCHAR(50)    
  , @fname                              VARCHAR(50)    
  , @mname                              VARCHAR(50)
  , @dob                                DATETIME  
  , @sex                                NVARCHAR(1) 
  , @preferredContactMethodCode			INT
  , @hasPlan                            BIT   
  , @ssn                                NVARCHAR(9)     
  , @bic                                NVARCHAR(14)    
  , @csis                               NVARCHAR(10)
  , @submitClaims                       bit
  , @submitClaimsEffectiveDate          datetime   
  , @notes                              NVARCHAR(MAX)
  , @parentConsentMCAL                  BIT
  , @parentConsentMCALEffectiveDate     DATETIME
  , @parentConsentOHCI                  BIT  
  , @parentConsentOHCIEffectiveDate     DATETIME
  , @ferpaConsent                       BIT
  , @ferpaConsentEffectiveDate          DATE
  , @treatmentConsent                   BIT
  , @treatmentConsentEffectiveDate      DATE		  
  , @minorConsent						BIT	  
  , @minorConsentEffectiveDate			DATE	
  , @cybhiTpaApproved                   BIT
  , @cybhiTpaApprovedOn                 DATE
  , @cybhiTpaID                         VARCHAR(256)
  , @cybhiSubmitClaims                  BIT
  , @p_nickname                         nvarchar(50)
  , @teacherOrCounselorName                   varchar(256)
  , @speciallyAdaptedVehicleForTransportation bit
  , @inTransitionalHousingStatus              bit 
  , @email                                    NVARCHAR(256)
  , @phone                                    NVARCHAR(14)
  , @deceased                                 bit = 0  
  
  , @patientHomePlaceID       bigint
  , @street1                  varchar(1000)
  , @street2                  varchar(1000)
  , @city                     varchar(100)
  , @state                    varchar(2)
  , @zip5                     varchar(5)
  , @zip4                     varchar(4)

  , @editDelReason                            VARCHAR(7000)
  , @validateRec                        BIT    
  , @saveType                           INT
  , @recID                              bigint
  , @MsgNoRec                           VARCHAR(1000)    
  , @MsgNoEdit                          VARCHAR(1000) 
  , @MsgNoFullEdit                      VARCHAR(1000)       
  , @MsgDupRec                          VARCHAR(1000)     
  , @MsgNoClient                        VARCHAR(1000)    
  , @MsgNoSite                          VARCHAR(1000)    
  , @MsgDataError                       VARCHAR(1000)
  , @MsgNotActive                       VARCHAR(1000)
  , @spDetails                          VARCHAR(8000) OUTPUT
  , @recordID                           BIGINT        OUTPUT
  , @recData1                           varchar(255)  OUTPUT
  , @recData2                           varchar(255)  OUTPUT
  , @recData3                           varchar(255)  OUTPUT
  , @recData4                           varchar(255)  OUTPUT
  
  )    
AS    
BEGIN     
    
/***************************************************************************    
 * PATIENT_Save_Profile */    
/**    
 * Creates a new or edits existing patient record (profile columns only)
 * and manages any associated records.    
 *    
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE @today         AS DATETIME       -- Current date/time stamp    
DECLARE @today5        AS DATETIME       -- @today five years from now    
DECLARE @tranOpen      AS BIT            -- Is a transaction open    
DECLARE @dupCount      AS INT            -- Duplicate counter used for validation    
DECLARE @updateState   AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @auditRecID    AS BIGINT         -- Audit record id    
DECLARE @valPass       AS BIT    
DECLARE @canEdit       AS BIT   
DECLARE @tempRecID     AS INT            -- Used for determining if a rec exists    
DECLARE @concat_name   AS NVARCHAR(100)    
DECLARE @planName      AS NVARCHAR(10)    
DECLARE @patAge        AS INT 
DECLARE @noFullEdit    AS BIT   
DECLARE @isActive      AS BIT  
DECLARE @createdByPCAL AS BIT = 1
    
BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
    
SET @recordID   = 0    
SET @spDetails  = ''    
 
set @recData1 = '0'
set @recData2 = ''
set @recData3 = ''
set @recData4 = ''
  
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
IF (@siteID      IS NULL) RAISERROR ('Site ID is required',     11, 1)    
IF (@lname       IS NULL) RAISERROR ('Last name is required',   11, 1)    
IF (@fname       IS NULL) RAISERROR ('First name is required',  11, 1)    
IF (@dob         IS NULL) RAISERROR ('DOB is required',         11, 1)    
IF (@sex         IS NULL) RAISERROR ('Sex is required',         11, 1)    
IF (@hasPlan     IS NULL) RAISERROR ('Has Plan is required',    11, 1)    
IF (@saveType    IS NULL) RAISERROR ('Save type is required',   11, 1)    
    
IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))     
  RAISERROR ('updateRecID is required', 11, 1)    
                              
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
     
SET @today       = GETDATE()    
SET @today5      = DATEADD(year,5,@today)  
SET @isActive    = 1    

/*-------------------------------    
 * Replace nulls with empty spaces
 * for middle name and nickname
 *------------------------------*/    

set @mname      = isnull(@mname,'')
set @p_nickname = isnull(@p_nickname,N'')

-- I don't know why we're setting these fields to empty strings if they come in NULL; I'm assuming there is a reason

set @teacherOrCounselorName = isnull( @teacherOrCounselorName ,N'')

/*-------------------------------    
 * Replace ' with ` for name
 *------------------------------*/    

set @lname      = replace (@lname,     '''', '`')
set @fname      = replace (@fname,     '''', '`')
set @mname      = replace (@mname,     '''', '`')
set @p_nickname = replace (@p_nickname,'''', '`')

set @teacherOrCounselorName = replace (@teacherOrCounselorName,'''', '`')

/*-------------------------------    
 * Make sure preferred contact
 * method is the valid default
 * value if the value is not
 * defined.
 *------------------------------*/    

set @preferredContactMethodCode =     isnull(@preferredContactMethodCode,10)
if (@preferredContactMethodCode <= 0) set @preferredContactMethodCode = 10

IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())     
BEGIN  
  declare @activeClaimRecs int   
  declare @activeSvcRecs   int 
  declare @tempClientID    int

  SET @recordID = null    
  SET @canEdit  = 1   
         
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
--    @canEdit        = dbo.YN_TO_BIT(pp.ACTIVE),
    @tempClientID   = pc.CLIENT_ID
  from PATIENTS_Client  as pc
  join PATIENTS_Patient as pp on pp.PATIENT_ID = pc.PATIENT_ID 
  where  pp.PATIENT_ID = @recID   
    
  IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)        
  IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1)  
  
  /*-------------------------------    
   * See if this record
   * has any related records
   * that would prohibit a full edit
   *------------------------------*/
       
  select @activeSvcRecs   = COUNT(*) from dbo.SERVICE_RECORDS where patID      = @recID and state !=  dbo.CONST_SVC_REC_STATE_DEL()
  select @activeClaimRecs = COUNT(*) from dbo.CLAIM_Claim     where PATIENT_ID = @recID  
  
    /*--------------------------------------    
     * Client can not be changed if there are 
     * active service records or claims
     *--------------------------------------*/
   
   if (((@activeClaimRecs > 0) OR (@activeSvcRecs > 0)) and (@clientID != @tempClientID)) 
      RAISERROR (@MsgNoFullEdit, 11, 1) 
       
END    
    
    
IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
BEGIN    
    
  /*-------------------------------    
   * If the siteID is not provided    
   * set the site to Unknown    
   * otherwise locate the site    
   *------------------------------*/    
      
  IF @siteID IS NULL    
  BEGIN        
    select top 1 @siteID = id from dbo.SITES_VIEW(null,null,null,@clientID,null,null,null,null) where uFlag = 1        
    IF (@siteID IS NULL) RAISERROR (@MsgDataError, 11, 1)    
  END    
  ELSE    
  BEGIN    
    SET @tempRecID = NULL    
    select top 1 @tempRecID = id from dbo.SITES_VIEW (null, null, null, @clientID, null, null, null, @siteID)
    IF (@tempRecID IS NULL)    RAISERROR (@MsgNoSite,    11, 1)      
    IF (@tempRecID <> @siteID) RAISERROR (@MsgDataError, 11, 1)    
  END
  
  /*-------------------------------    
   * If no answer was provided for
   * submit claims, assume a Yes  
   *------------------------------*/    
  
  if (@submitClaims is null) set @submitClaims = 1
  
  /*-------------------------------    
   * Determine if PCAL created
   * this record
   *------------------------------*/    
  
  select top 1
    @createdByPCAL = mm.SBSC_Employee
  from users.dbo.Users        as uu
  join users.dbo.Membership   as mm on mm.UserId = uu.UserId
  where 
    (uu.userrid = @userID)
  
  if (@createdByPCAL is null) set @createdByPCAL = 1
        
  /*-------------------------------    
   * If a new records has a BIC 
   * that is not a 14 character
   * string then set it to null
   *------------------------------*/ 

  set @bic = trim(isnull(@bic,''))
  if (len(@bic) != 14) set @bic = null

END    
    
/*-------------------------------    
 * Generate derived values    
 *------------------------------*/    
    
SET @concat_name = @lname + ', ' + @fname    
SET @patAge      = dbo.CALC_AGE(@dob,@today)    
SET @planName    = dbo.PLAN_TYPE_TO_NAME(dbo.AGE_IEP_TO_PLAN_TYPE(@patAge,@hasPlan))    
    
/*-------------------------------    
 * Validation    
 *------------------------------*/    
    
IF (((@saveType = dbo.CONST_SAVE_TYPE_NEW()) OR    
     (@saveType = dbo.CONST_SAVE_TYPE_EDIT())))    
BEGIN    
       
  /*-------------------------------    
   * Advisement validation    
   *------------------------------*/    
    
  IF (@validateRec = 1)    
  BEGIN    
       
   /*-------------------------------    
    * Look for duplicate    
    * records excluding the record    
    * specified by recid    
    *------------------------------*/    
        
    SET @dupCount = 0    
      
  /*-------------------------------    
   * For duplicate checking    
   * We can rely on always having    
   * the following fields:    
   *    
   *   clientid    
   *   lastname     
   *   firstname    
   *   dob    
   *   sex    
   *------------------------------*/    
  
   select @dupCount = COUNT(p.PATIENT_ID) 
   from PATIENTS_Client  as pc
   join PATIENTS_Patient as p on p.PATIENT_ID = pc.PATIENT_ID
   where
     pc.CLIENT_ID    = @clientID and
     p.LAST_NAME     = @lname    and
     p.FIRST_NAME    = @fname    and
     p.DATE_OF_BIRTH = @dob      and
     p.SEX           = @sex      and
     ((@recID IS NULL) OR (p.PATIENT_ID != @recID))
  
  IF @dupCount > 0     
  BEGIN    
    SET @msgDupRec = dbo.STRING_CREATE(@msgDupRec, CONVERT(VARCHAR(10),@dupCount), null, null)    
    SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,@msgDupRec,dbo.CONST_RET_DUP_RECORD())    
  END    
      
  /*-------------------------------    
   * If we are editing and the
   * record we are editing is not    
   * active warn the user
   *------------------------------*/    

  IF ((@isActive = 0) AND (@saveType = dbo.CONST_SAVE_TYPE_EDIT())) 
    SET @spDetails = dbo.UPDATE_DETAILS(@spDetails,@MsgNotActive, dbo.CONST_RET_WARN())    
      
  
  /*-------------------------------    
   * If we are providing advisement    
   * validation exit now    
   *------------------------------*/    
         
  IF (@validateRec = 1) RETURN(0)    
       
END  
END  
    
    
/*-------------------------------    
 * Create or modify our     
 * patient record    
 *------------------------------*/    
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1    
    
  /*-------------------------------    
   * New patient record    
   *------------------------------*/    
    
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN    
    
    SET @updateState = dbo.CONST_REC_STATE_NEW()    
        
    INSERT INTO dbo.PATIENTS_Patient    
      (LAST_NAME,     
       FIRST_NAME,     
       MIDDLE_NAME,

       preferredNickname,

       teacherOrCounselorName ,

       DATE_OF_BIRTH,     
       SEX,     
       SSN,     
       BIC,     
       CSIS,     
       DATE_CREATED,     
       LAST_UPDATED,     
       CONCAT_NAME,     
       LASTPOP,     
       ACTIVE,    
       userID,    
       state,
       SUBMIT_CLAIMS,
       submitClaimsEffectiveDate,
       parentConsentMCAL,
       parentConsentMCALEffectiveDate,
       parentConsentOHCI,
       parentConsentOHCIEffectiveDate,

	   ferpaConsent,
	   ferpaConsentEffectiveDate,
       treatmentConsent,
       treatmentConsentEffectiveDate,

	   cybhiTpaApproved,
	   cybhiTpaApprovedOn,
       cybhiTpaID,
	   cybhiSubmitClaims,

	   speciallyAdaptedVehicleForTransportation,
     inTransitionalHousingStatus,
	 deceased,
	 
	 preferredContactMethodCode, 
	 minorConsent,
	 minorConsentEffectiveDate 		   
)        
    VALUES     
      (@lname,     
       @fname,     
       @mname,

       @p_nickname,

       @teacherOrCounselorName ,

       @dob,     
       @sex,     
       @ssn,     
       @bic,    
       @csis,     
       @today,     
       @today,     
       @concat_name,     
       dbo.CONST_MIN_DATETIME_GREGORIAN(),     
       'Y',    
       @userID,    
       @updateState,
       @submitClaims,
       @submitClaimsEffectiveDate,
       @parentConsentMCAL,
       @parentConsentMCALEffectiveDate,
       @parentConsentOHCI, 
       @parentConsentOHCIEffectiveDate,

	   @ferpaConsent,
       @ferpaConsentEffectiveDate,
       @treatmentConsent,
       @treatmentConsentEffectiveDate,

	   @cybhiTpaApproved,
	   @cybhiTpaApprovedOn,
	   @cybhiTpaID,
	   @cybhiSubmitClaims,

	   @speciallyAdaptedVehicleForTransportation,
     @inTransitionalHousingStatus,
	 @deceased, 

	 @preferredContactMethodCode,
	 @minorConsent,
	 @minorConsentEffectiveDate			

)  

    SET @recordID = SCOPE_IDENTITY()       
      
  /*-------------------------------    
   * New patient client record    
   *------------------------------*/    
    
  INSERT INTO dbo.PATIENTS_Client    
    (CLIENT_ID,    
     PATIENT_ID,    
     START_DATE,    
     END_DATE)    
   VALUES    
     (@clientID,    
      @recordID,    
      @today,    
      @today5    
     )    
        
  /*-------------------------------    
   * New patient site record    
   *------------------------------*/    
    
  INSERT INTO dbo.PATIENTS_School    
    (SITE_ID,    
     PATIENT_ID,    
     GRADE,    
     STUDENT_ID,    
     START_DATE,    
     END_DATE)    
   VALUES    
     (@siteID,    
      @recordID,    
      @siteRank,    
      @siteRefID,    
      @today,    
      @today5    
     )    
      
  /*-------------------------------    
   * New patient plan (IEP) record    
   *-------------------------------*/    
      
    INSERT INTO dbo.PATIENTS_IEP    
    (PATIENT_ID,    
     IEP_IFSP_NONE     
     )    
     VALUES    
     (@recordID,    
      @planName    
     )
               
  END       
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
      
    /*-------------------------------    
     * Edit existing patient record    
     *------------------------------*/    
      
     SET @updateState = dbo.CONST_REC_STATE_MOD()        
              
     UPDATE PATIENTS_Patient
     SET
        LAST_NAME                      = @lname,
        FIRST_NAME                     = @fname,
        MIDDLE_NAME                    = @mname,

        preferredNickname              = @p_nickname,

        teacherOrCounselorName        = @teacherOrCounselorName ,

        DATE_OF_BIRTH                  = @dob,
        SEX                            = @sex,
        SSN                            = @ssn,
        BIC                            = @bic,
        CSIS                           = @csis,
        LAST_UPDATED                   = @today,
        CONCAT_NAME                    = @concat_name,
        userID                         = @userID,
        state                          = @updateState,
        SUBMIT_CLAIMS                  = @submitClaims,
        submitClaimsEffectiveDate      = @submitClaimsEffectiveDate,
        parentConsentMCAL              = @parentConsentMCAL,
        parentConsentMCALEffectiveDate = @parentConsentMCALEffectiveDate,
        parentConsentOHCI              = @parentConsentOHCI,
        parentConsentOHCIEffectiveDate = @parentConsentOHCIEffectiveDate,

		ferpaConsent                   = @ferpaConsent,
	    ferpaConsentEffectiveDate      = @ferpaConsentEffectiveDate,
		treatmentConsent               = @treatmentConsent,
		treatmentConsentEffectiveDate  = @treatmentConsentEffectiveDate,

		cybhiTpaApproved			   = @cybhiTpaApproved,
		cybhiTpaApprovedOn			   = @cybhiTpaApprovedOn,
		cybhiTpaID					   = @cybhiTpaID,
		cybhiSubmitClaims			   = @cybhiSubmitClaims,

		speciallyAdaptedVehicleForTransportation = @speciallyAdaptedVehicleForTransportation,

    inTransitionalHousingStatus         =   @inTransitionalHousingStatus,
	deceased                           = @deceased,
	preferredContactMethodCode		   = @preferredContactMethodCode,
	minorConsent					   = @minorConsent,
	minorConsentEffectiveDate		   = @minorConsentEffectiveDate
                      
     WHERE 
        PATIENT_ID = @recordID        

     UPDATE dbo.PATIENTS_Client
     SET
       CLIENT_ID  = @clientID
     WHERE (PATIENT_ID = @recordID)
     
     declare @patSchoolID as bigint = null
     
     select top 1 
       @patSchoolID = PATIENT_SCHOOL_ID 
     from dbo.PATIENTS_SITES_VIEW_CURRENT(@clientID) as psvc
     where (psvc.PATIENT_ID = @recordID)
     
     UPDATE dbo.PATIENTS_School
     SET 
         SITE_ID    = @siteID
       , GRADE      = @siteRank
       , STUDENT_ID = @siteRefID
     WHERE (PATIENT_SCHOOL_ID = @patSchoolID)
               
     UPDATE dbo.PATIENTS_IEP
     SET
        IEP_IFSP_NONE    = @planName     
     WHERE (PATIENT_ID = @recordID)
                          
  END    
  ELSE     
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
    
  /*-------------------------------    
   * Patients Notes 
   * Handles new and edit
   * Also handles cases when
   * no notes record exists yet
   *------------------------------*/    
  
  set @notes = ISNULL(@notes,'')
  
  declare @patNotesID as bigint = null
  
  select top 1 
    @patNotesID = pn.NOTE_ID
  from dbo.PATIENTS_Notes as pn
  where (pn.PATIENT_ID = @recordID)
  
  if (@patNotesID is null)
  begin  
    INSERT INTO dbo.PATIENTS_Notes (
        PATIENT_ID
      , NOTE
      , DATE_CREATED
      , DATE_MODIFIED )
    VALUES (
        @recordID
      , @notes
      , @today
      , @today )      
   end
   else
   begin
     update dbo.PATIENTS_Notes
     set
        NOTE          = @notes
       ,DATE_MODIFIED = @today
     where 
       (NOTE_ID = @patNotesID)
   end
   
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
	 
	 set @recData1 = '0'
     set @recData2 = ''
     set @recData3 = ''
     set @recData4 = ''

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
	   where 
	     (id = @patientHomePlaceID)

	   set @recData1 = '1'
       set @recData2 = ''
       set @recData3 = ''
       set @recData4 = ''
  	   
	 end
	 else
	 begin
	   set @recData1 = '0'
       set @recData2 = ''
       set @recData3 = ''
       set @recData4 = ''  	  
	 end
	 
  end

  if (@recData1 = '1')
  begin
	 
   select top 1
      @recData2 = placeID     
   from dbo.PATIENT_PLACES_VIEW_CORE (  @userID
                                      , @userGroup
                                      , @userRank
                                      , @clientID
                                      , @recordID /* Patient id */
                                      , null
                                      , 1
                                      , @patientHomePlaceID ) as t1
   where 
     (t1.id = @patientHomePlaceID)

  end


  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
       
   EXEC PATIENT_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT     
       
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
    
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
END    
    
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PATIENT_Save_Profile] TO [webuser]
GO
