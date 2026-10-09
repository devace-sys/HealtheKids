USE SPEDMON
GO



/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_Save
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PATIENT_Save]     
 (

  @userID                             BIGINT,    
  @userGroup                          INT,    
  @userRank                           INT,

  @clientID                           INT,

  @siteID                             INT,    
  @siteRefID                          NVARCHAR(50),    
  @siteRank                           NVARCHAR(2),
      
  @lname                              VARCHAR(50),    
  @fname                              VARCHAR(50),    
  @mname                              VARCHAR(50),    
  @dob                                DATETIME,    
  @sex                                NVARCHAR(1),
      
  @hasPlan                            BIT,    
  @ssn                                NVARCHAR(9),     
  @bic                                NVARCHAR(14),    
  @csis                               NVARCHAR(10),
  @submitClaims                       bit,
  @submitClaimsEffectiveDate          datetime,       
  @notes                              NVARCHAR(MAX),
  @editDelReason                      VARCHAR(7000),    
  @validateRec                        BIT,    
  @saveType                           INT,    
  @recID                              INT,

  @parentConsentMCAL                  BIT,      
  @parentConsentMCALEffectiveDate     DATETIME,      
  @parentConsentOHCI                  BIT,      
  @parentConsentOHCIEffectiveDate     DATETIME,

  @ferpaConsent                       BIT,
  @ferpaConsentEffectiveDate          DATE,
  @treatmentConsent                   BIT,
  @treatmentConsentEffectiveDate      DATE,
		  
  @cybhiTpaApproved                   BIT,
  @cybhiTpaApprovedOn                 DATE,
  @cybhiTpaID                         VARCHAR(256),
  @cybhiSubmitClaims                  BIT,
  
  @p_nickname                         nvarchar(50),

  @teacherOrCounselorName             varchar(256),

  @speciallyAdaptedVehicleForTransportation BIT,
  @spEdSpecialTransportation          BIT,
  @spEdLastEvalDate                   DATE,
  @spEdLastAnnualIEPDate              DATE,
  @spEdNextAnnualIEPDate              DATE,
  @spEdCurIEPDate                     DATE,
  @spEdDisability1Code                INT,
  @spEdDisability2Code                INT,
  @spEdCaseManagerName                varchar(256),
  @spEdExitedSpEdDate                 date,
  @spEdStudentStrengths                    varchar(max),
  @spEdParentConcerns                      varchar(max),
  @spEdProgressMonitoringData              varchar(max),
  @spEdStudentPresentLevelsStatement       varchar(max),
  @spEdStudentDisabilityAffectsPerformance bit,
  @spEdCurEligibilityDate                  date,
  @spEdInitEligibilityDate                 date,
  @spEdIEPAttendeesIdentified              bit,
  @spEdEligibilityReasons                  varchar(max),
  @spEdPlanTranslateToLanguageCodeID       bigint,
  @spEdInitRefDate                         date,
  @spEdReferringPartyCode                  int,
  @spEdReferringPartyOtherOption           varchar(50),
  @spEdDistrictReceivedParentConsentDate   date,
  @spEdMeetingPurposeDataJSON              varchar(max),
  @spEdAdditionalMeetingPurposeDataJSON    varchar(max),
  @spEdAmendmentReasonsDataJSON            varchar(max),
  @spEdAmendmentReasonsOtherOption         varchar(max),
  @spEdMeetingPurposeOtherOption           varchar(max),
  @spEdFacilitatorUserID                   bigint,
  @spEdFacilitatorUserName				   varchar(256),
  @spEdMeetingDate                         date,
  @spEdMeetingDurationInMins               int,
  @spEdMeetingTime                         varchar(50),
  @spEdMeetingTitle                        varchar(256),
  @spEdPlanTypeCode                        int,
  @spEdStudentLanguageCodeID               bigint,
  @spEdStudentRaceCode                     int,  
  @spEdNextEvalDate                        datetime,
  @spEdEnteredSpEdDate                     datetime,
  @spEdStudentLanguageEnglishLearner       bit,
  @spEdStudentLanguageInfoReclassified     bit,
  @spEdStudentLanguageInterpreterNeeded    bit,
  @spEdStudentLanguageTranslationRequested bit,
  @spEdStudentLanguageEnglishLearnerUndesignatedPreschool bit,
  @spEdServicesDataJSON                    varchar(max),
  @spEdTransitionGoalEducation             bit,
  @spEdTransitionGoalTraining              bit,
  @spEdTransitionGoalEmployment            bit,
  @spEdTransitionGoalIndependentLiving     bit,
  @inTransitionalHousingStatus             bit,

 @spEdDevAcaFunSkillsReading			   varchar(max),
 @spEdDevAcaFunSkillsWriting               varchar(max),
 @spEdDevAcaFunSkillsMath                  varchar(max),
 @spEdDevAcaFunSkillsCommunicationDev      varchar(max),
 @spEdDevAcaFunSkillsGrossFineMotorDev     varchar(max),
 @spEdDevAcaFunSkillsHealth				   varchar(max),
 @spEdDevAcaFunSkillsVocational			   varchar(max),
 @spEdDevAcaFunSkillsAdaptiveDailyLiving   varchar(max),
 @spEdDevAcaFunSkillsAreasOfNeccessity	   varchar(max),
 @spEdDevAcaFunSkillsSocialEmotionalBehavioral varchar(max),  
 @spEdParticipantDetailsJSON			   varchar(max),

 @spEdProceduralSafeguardsSentDate         date,
 @spEdSpecialTransportationComments        varchar(max),
 @spEdVehicleAdaptationType				   int,
 @spEdCorrectionDetails					   varchar(max),
 @spEdPreferredLanguageCodeID              bigint,

 @spEdPresentLevelsDataJSON                varchar(max),
 @spEdPresentLevelsPreparedBy              bigint,
 @spEdPresentLevelsPreparedByName          varchar(200),
 @spEdStudentStrengthsSource               varchar(100),
 @spEdStudentStrengthsSourceJSON           varchar(max),
 @spEdStudentStrengthsImpact               varchar(max),
 @spEdParentConcernsSource                 varchar(100),
 @spEdParentConcernsSourceJSON             varchar(max),
 @spEdReadingReviewedNA                    bit,
 @spEdReadingSource                        varchar(100),
 @spEdReadingSourceJSON                    varchar(max),
 @spEdReadingBaselineValue                 varchar(100),
 @spEdReadingBaselineUnit                  varchar(100),
 @spEdReadingToolsUsed                     varchar(500),
 @spEdReadingToolsUsedJSON                 varchar(max),      
 @spEdReadingBaselineDate                  date,
 @spEdReadingImpactSummary                 varchar(max),
 @spEdWritingReviewedNA                    bit,
 @spEdWritingSource                        varchar(100),
 @spEdWritingSourceJSON                    varchar(max),
 @spEdWritingBaselineValue                 varchar(100),
 @spEdWritingBaselineUnit                  varchar(100),
 @spEdWritingToolsUsed                     varchar(500),
 @spEdWritingToolsUsedJSON                 varchar(max),      
 @spEdWritingBaselineDate                  date,
 @spEdWritingImpactSummary                 varchar(max),
 @spEdMathReviewedNA                       bit,
 @spEdMathSource                           varchar(100),
 @spEdMathSourceJSON                       varchar(max),
 @spEdMathBaselineValue                    varchar(100),
 @spEdMathBaselineUnit                     varchar(100),
 @spEdMathToolsUsed                        varchar(500),
 @spEdMathToolsUsedJSON                    varchar(max),      
 @spEdMathBaselineDate                     date,
 @spEdMathImpactSummary                    varchar(max),
 @spEdCommunicationDevReviewedNA           bit,
 @spEdCommunicationDevSource               varchar(100),
 @spEdCommunicationDevSourceJSON           varchar(max),
 @spEdCommunicationDevBaselineValue        varchar(100),
 @spEdCommunicationDevBaselineUnit         varchar(100),
 @spEdCommunicationDevToolsUsed            varchar(500),
 @spEdCommunicationDevToolsUsedJSON        varchar(max),      
 @spEdCommunicationDevBaselineDate         date,
 @spEdCommunicationDevImpactSummary        varchar(max),
 @spEdGrossFineMotorReviewedNA             bit,
 @spEdGrossFineMotorSource                 varchar(100),
 @spEdGrossFineMotorSourceJSON             varchar(max),
 @spEdGrossFineMotorBaselineValue          varchar(100),
 @spEdGrossFineMotorBaselineUnit           varchar(100),
 @spEdGrossFineMotorToolsUsed              varchar(500),
 @spEdGrossFineMotorToolsUsedJSON          varchar(max),      
 @spEdGrossFineMotorBaselineDate           date,
 @spEdGrossFineMotorImpactSummary          varchar(max),
 @spEdHealthReviewedNA                     bit,
 @spEdHealthSource                         varchar(100),
 @spEdHealthSourceJSON                     varchar(max),
 @spEdHealthBaselineValue                  varchar(100),
 @spEdHealthBaselineUnit                   varchar(100),
 @spEdHealthToolsUsed                      varchar(500),
 @spEdHealthToolsUsedJSON                  varchar(max),      
 @spEdHealthBaselineDate                   date,
 @spEdHealthImpactSummary                  varchar(max),
 @spEdVocationalReviewedNA                 bit,
 @spEdVocationalSource                     varchar(100),
 @spEdVocationalSourceJSON                 varchar(max),
 @spEdVocationalBaselineValue              varchar(100),
 @spEdVocationalBaselineUnit               varchar(100),
 @spEdVocationalToolsUsed                  varchar(500),
 @spEdVocationalToolsUsedJSON              varchar(max),      
 @spEdVocationalBaselineDate               date,
 @spEdVocationalImpactSummary              varchar(max),
 @spEdAdaptiveDailyLivingReviewedNA        bit,
 @spEdAdaptiveDailyLivingSource            varchar(100),
 @spEdAdaptiveDailyLivingSourceJSON        varchar(max),
 @spEdAdaptiveDailyLivingBaselineValue     varchar(100),
 @spEdAdaptiveDailyLivingBaselineUnit      varchar(100),
 @spEdAdaptiveDailyLivingToolsUsed         varchar(500),
 @spEdAdaptiveDailyLivingToolsUsedJSON     varchar(max),      
 @spEdAdaptiveDailyLivingBaselineDate      date,
 @spEdAdaptiveDailyLivingImpactSummary     varchar(max),
 @spEdSocialEmotionalBehavioralReviewedNA       bit,
 @spEdSocialEmotionalBehavioralSource           varchar(100),
 @spEdSocialEmotionalBehavioralSourceJSON       varchar(max),
 @spEdSocialEmotionalBehavioralBaselineValue    varchar(100),
 @spEdSocialEmotionalBehavioralBaselineUnit     varchar(100),
 @spEdSocialEmotionalBehavioralToolsUsed        varchar(500),
 @spEdSocialEmotionalBehavioralToolsUsedJSON    varchar(max),
 @spEdSocialEmotionalBehavioralBaselineDate     date,
 @spEdSocialEmotionalBehavioralImpactSummary    varchar(max),
 @spEdStudentStrengthsSourceNames		   VARCHAR(MAX),
 @spEdParentConcernsSourceNames			   VARCHAR(MAX),
 @spEdReadingSourceNames				   VARCHAR(MAX),
 @spEdWritingSourceNames				   VARCHAR(MAX),
 @spEdMathSourceNames					   VARCHAR(MAX),
 @spEdCommunicationDevSourceNames	       VARCHAR(MAX),
 @spEdGrossFineMotorSourceNames		       VARCHAR(MAX),
 @spEdHealthSourceNames					   VARCHAR(MAX),
 @spEdVocationalSourceNames			       VARCHAR(MAX),
 @spEdAdaptiveDailyLivingSourceNames       VARCHAR(MAX),
 @spEdSocialEmotionalBehavioralSourceNames VARCHAR(MAX),      
 @spEdReadingBaselineUnitNames			   VARCHAR(256),
 @spEdWritingBaselineUnitNames			   VARCHAR(256),
 @spEdMathBaselineUnitNames				   VARCHAR(256),
 @spEdCommunicationDevBaselineUnitNames	   VARCHAR(256),
 @spEdGrossFineMotorBaselineUnitNames	   VARCHAR(256),
 @spEdHealthBaselineUnitNames			   VARCHAR(256),
 @spEdVocationalBaselineUnitNames		   VARCHAR(256),
 @spEdAdaptiveDailyLivingBaselineUnitNames  VARCHAR(256),
 @spEdSocialEmotionalBehavioralBaselineUnitNames VARCHAR(256), 
 @spEdReadingToolsUsedNames                VARCHAR(MAX),
 @spEdWritingToolsUsedNames                VARCHAR(MAX),
 @spEdMathToolsUsedNames                   VARCHAR(MAX),
 @spEdCommunicationDevToolsUsedNames       VARCHAR(MAX),
 @spEdGrossFineMotorToolsUsedNames         VARCHAR(MAX),
 @spEdHealthToolsUsedNames                 VARCHAR(MAX),
 @spEdVocationalToolsUsedNames             VARCHAR(MAX),
 @spEdAdaptiveDailyLivingToolsUsedNames    VARCHAR(MAX),
 @spEdSocialEmotionalBehavioralToolsUsedNames VARCHAR(MAX),   

  

  @MsgNoRec                           VARCHAR(1000),    
  @MsgNoEdit                          VARCHAR(1000), 
  @MsgNoFullEdit                      VARCHAR(1000),       
  @MsgDupRec                          VARCHAR(1000),     
  @MsgNoClient                        VARCHAR(1000),    
  @MsgNoSite                          VARCHAR(1000),    
  @MsgDataError                       VARCHAR(1000),
  @MsgNotActive                       VARCHAR(1000),     
  @spDetails                          VARCHAR(8000) OUTPUT,    
  @recordID                           BIGINT        OUTPUT)    
AS    
BEGIN     
    
/***************************************************************************    
 * PATIENT_SAVE */    
/**    
 * Creates a new or edits existing patient record    
 * and manages any associated records.    
 *    
 * @param   userID                The userid of who saved the record    
 * @param   userGroup             Users group    
 * @param   userRank              User rank    
 * @param   clientID              Patient's client id    
 * @param   siteID                Patient's site id    
 * @param   siteRefID             The unique id the client/site assigns to the patient (ie student id)    
 * @param   siteRank              A ranking code or organization code the site assigns to the patient (ie grade)    
 * @param   lname                 Patient's last name    
 * @param   fname                 Patient's first name    
 * @param   mname                 Patient's middle name    
 * @param   dob                   Patient's date of birth    
 * @param   sex                   Patient's gender    
 * @param   hasPlan               Patient has a IFSP/IEP.  Could also be used to indicate    
 *                                patient has a health plan?    
 * @param   ssn                   Patient's social security number    
 * @param   bic                   Patient's Medi-cal Benefits Identification Card number    
 * @param   csis                  Patient's Statewide Student Identifier (SSID)     
                                  on file with CSIS (California School Information Services)    
 * @param   editDelReason         Reason for record edit or delete    
 * @param   validateRec           1 = Performs data integrity validation tasks    
                                      Perform advisory validation tasks that can    
 *                                    only be conducted by referencing data from the    
 *                                    database and then exits WITHOUT saving the record    
 *                                0 = Peform data integrity validation tasks and    
 *                                    if these tasks succeed peforms the desired    
 *                                    operation (saveType) on the record and exits    
 * @param   saveType              Type of operation to perform    
 *                                1 = New, 2 = Edit, 3 = Delete    
 * @param   recID                 Record id of existing patient record to edit or    
 *                                delete.
 * @param   parentConsentMCAL     Parental consent for Medi-Cal
 * @param   parentConsentOHCI     Parental consent for other health care insurance
 * @param   MsgNoRec              Desired error message if a recID is not found    
 * @param   MsgNoEdit             Desired error message if a record cannot be edited    
 * @param   MsgDupRec             Desired error message for duplicate detection    
 * @param   MsgNoClient           Desired error message if a clientID is not found    
 * @param   MsgNoSite             Desired error message if a siteID is not found     
 * @param   MsgDataError          Desired error message for data errors    
 * @returns spDetails             Validation or error details    
 * @returns recordID              New record id or record id of service record that    
 *                                was changed or deleted     
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
       spEdSpecialTransportation,
       spEdLastEvalDate,
       spEdLastAnnualIEPDate,
       spEdNextAnnualIEPDate,
       spEdDisability1Code,
       spEdDisability2Code,
	   spEdCaseManagerName,
       spEdExitedSpEdDate,
	   spEdCurIEPDate,
	   spEdStudentStrengths,                  
	   spEdParentConcerns,                     
	   spEdProgressMonitoringData,             
	   spEdStudentPresentLevelsStatement,      
	   spEdStudentDisabilityAffectsPerformance,
	   spEdCurEligibilityDate,                 
	   spEdInitEligibilityDate,                
	   spEdIEPAttendeesIdentified,             
	   spEdEligibilityReasons,
	   spEdPlanTranslateToLanguageCodeID,	   
	   spEdInitRefDate,                        
	   spEdReferringPartyCode,                 
	   spEdReferringPartyOtherOption,          
	   spEdDistrictReceivedParentConsentDate,  
	   spEdMeetingPurposeDataJSON,             
	   spEdAdditionalMeetingPurposeDataJSON,   
	   spEdAmendmentReasonsDataJSON,           
	   spEdAmendmentReasonsOtherOption,
	   spEdMeetingPurposeOtherOption,
	   spEdFacilitatorUserID,
	   spEdFacilitatorUserName,
	   spEdMeetingDate,
	   spEdMeetingDurationInMins,
	   spEdMeetingTime,
	   spEdMeetingTitle,
	   spEdPlanTypeCode,
	   spEdStudentLanguageCodeID,
       spEdStudentRaceCode,
	   spEdNextEvalDate,
	   spEdEnteredSpEdDate,
	   spEdStudentLanguageEnglishLearner,
	   spEdStudentLanguageInfoReclassified,
	   spEdStudentLanguageInterpreterNeeded,
	   spEdStudentLanguageTranslationRequested,
	   spEdStudentLanguageEnglishLearnerUndesignatedPreschool,
	   spEdTransitionGoalEducation,
	   spEdTransitionGoalTraining,
	   spEdTransitionGoalEmployment,
	   spEdTransitionGoalIndependentLiving,

     inTransitionalHousingStatus ,

	   spEdDevAcaFunSkillsReading,
       spEdDevAcaFunSkillsWriting,
       spEdDevAcaFunSkillsMath,
       spEdDevAcaFunSkillsCommunicationDev,
       spEdDevAcaFunSkillsGrossFineMotorDev,
       spEdDevAcaFunSkillsHealth,
       spEdDevAcaFunSkillsVocational,
       spEdDevAcaFunSkillsAdaptiveDailyLiving,
       spEdDevAcaFunSkillsAreasOfNeccessity,
       spEdDevAcaFunSkillsSocialEmotionalBehavioral,          
			
	   spEdPresentLevelsDataJSON,
	   spEdPresentLevelsPreparedBy,
	   spEdPresentLevelsPreparedByName,
	   spEdStudentStrengthsSource,
	   spEdStudentStrengthsSourceJSON,
	   spEdStudentStrengthsImpact,
	   spEdParentConcernsSource,
	   spEdParentConcernsSourceJSON,
	   spEdReadingReviewedNA,
	   spEdReadingSource,
	   spEdReadingSourceJSON,
	   spEdReadingBaselineValue,
	   spEdReadingBaselineUnit,
       spEdReadingToolsUsed,
       spEdReadingToolsUsedJSON,                              
       spEdReadingBaselineDate,
	   spEdReadingImpactSummary,
	   spEdWritingReviewedNA,
	   spEdWritingSource,
	   spEdWritingSourceJSON,
	   spEdWritingBaselineValue,
	   spEdWritingBaselineUnit,
	   spEdWritingToolsUsed,
	   spEdWritingToolsUsedJSON,                              
	   spEdWritingBaselineDate,
	   spEdWritingImpactSummary,
       spEdMathReviewedNA,
	   spEdMathSource,
	   spEdMathSourceJSON,
	   spEdMathBaselineValue,
	   spEdMathBaselineUnit,
	   spEdMathToolsUsed,
	   spEdMathToolsUsedJSON,                                 
	   spEdMathBaselineDate,
	   spEdMathImpactSummary,
	   spEdCommunicationDevReviewedNA,
	   spEdCommunicationDevSource,
	   spEdCommunicationDevSourceJSON,
	   spEdCommunicationDevBaselineValue,
	   spEdCommunicationDevBaselineUnit,
	   spEdCommunicationDevToolsUsed,
	   spEdCommunicationDevToolsUsedJSON,                     
	   spEdCommunicationDevBaselineDate,
	   spEdCommunicationDevImpactSummary,
	   spEdGrossFineMotorReviewedNA,
	   spEdGrossFineMotorSource,
	   spEdGrossFineMotorSourceJSON,
	   spEdGrossFineMotorBaselineValue,
	   spEdGrossFineMotorBaselineUnit,
	   spEdGrossFineMotorToolsUsed,
	   spEdGrossFineMotorToolsUsedJSON,                       
	   spEdGrossFineMotorBaselineDate,
	   spEdGrossFineMotorImpactSummary,
	   spEdHealthReviewedNA,
	   spEdHealthSource,
	   spEdHealthSourceJSON,
	   spEdHealthBaselineValue,
	   spEdHealthBaselineUnit,
	   spEdHealthToolsUsed,
	   spEdHealthToolsUsedJSON,                               
	   spEdHealthBaselineDate,
	   spEdHealthImpactSummary,
	   spEdVocationalReviewedNA,
	   spEdVocationalSource,
	   spEdVocationalSourceJSON,
	   spEdVocationalBaselineValue,
	   spEdVocationalBaselineUnit,
	   spEdVocationalToolsUsed,
	   spEdVocationalToolsUsedJSON,                           
	   spEdVocationalBaselineDate,
	   spEdVocationalImpactSummary,
	   spEdAdaptiveDailyLivingReviewedNA,
	   spEdAdaptiveDailyLivingSource,
	   spEdAdaptiveDailyLivingSourceJSON,
	   spEdAdaptiveDailyLivingBaselineValue,
	   spEdAdaptiveDailyLivingBaselineUnit,
	   spEdAdaptiveDailyLivingToolsUsed,
	   spEdAdaptiveDailyLivingToolsUsedJSON,                  
	   spEdAdaptiveDailyLivingBaselineDate,
	   spEdAdaptiveDailyLivingImpactSummary,
       spEdSocialEmotionalBehavioralReviewedNA,
       spEdSocialEmotionalBehavioralSource,
       spEdSocialEmotionalBehavioralSourceJSON,
       spEdSocialEmotionalBehavioralBaselineValue,
       spEdSocialEmotionalBehavioralBaselineUnit,
       spEdSocialEmotionalBehavioralToolsUsed,
       spEdSocialEmotionalBehavioralToolsUsedJSON,
       spEdSocialEmotionalBehavioralBaselineDate,
       spEdSocialEmotionalBehavioralImpactSummary,
	   spEdStudentStrengthsSourceNames,
	   spEdParentConcernsSourceNames,
	   spEdReadingSourceNames,
	   spEdWritingSourceNames,
	   spEdMathSourceNames,
	   spEdCommunicationDevSourceNames,
	   spEdGrossFineMotorSourceNames,
	   spEdHealthSourceNames,
	   spEdVocationalSourceNames,
	   spEdAdaptiveDailyLivingSourceNames,
	   spEdSocialEmotionalBehavioralSourceNames,              
	   spEdReadingBaselineUnitNames,
	   spEdWritingBaselineUnitNames,
	   spEdMathBaselineUnitNames,
	   spEdCommunicationDevBaselineUnitNames,
	   spEdGrossFineMotorBaselineUnitNames,
	   spEdHealthBaselineUnitNames,
	   spEdVocationalBaselineUnitNames,
	   spEdAdaptiveDailyLivingBaselineUnitNames,
	   spEdSocialEmotionalBehavioralBaselineUnitNames,         
	   spEdReadingToolsUsedNames,
	   spEdWritingToolsUsedNames,
	   spEdMathToolsUsedNames,
	   spEdCommunicationDevToolsUsedNames,
	   spEdGrossFineMotorToolsUsedNames,
	   spEdHealthToolsUsedNames,
	   spEdVocationalToolsUsedNames,
	   spEdAdaptiveDailyLivingToolsUsedNames,
	   spEdSocialEmotionalBehavioralToolsUsedNames,           


	   spEdParticipantDetailsJSON,
	   spEdProceduralSafeguardsSentDate,
	   spEdSpecialTransportationComments,
	   spEdVehicleAdaptationType,
	   spEdCorrectionDetails,
	   spEdPreferredLanguageCodeID,              
	   spEdServicesDataJSON
	
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
       @spEdSpecialTransportation,
       @spEdLastEvalDate,
       @spEdLastAnnualIEPDate,
       @spEdNextAnnualIEPDate,
       @spEdDisability1Code,
       @spEdDisability2Code,
	   @spEdCaseManagerName,
       @spEdExitedSpEdDate,
	   @spEdCurIEPDate,
	   @spEdStudentStrengths,                   
	   @spEdParentConcerns,                     
	   @spEdProgressMonitoringData,             
	   @spEdStudentPresentLevelsStatement,      
	   @spEdStudentDisabilityAffectsPerformance,
	   @spEdCurEligibilityDate,                 
	   @spEdInitEligibilityDate,                
	   @spEdIEPAttendeesIdentified,             
	   @spEdEligibilityReasons,                 
	   @spEdPlanTranslateToLanguageCodeID,                         
	   @spEdInitRefDate,                        
	   @spEdReferringPartyCode,                 
	   @spEdReferringPartyOtherOption,          
	   @spEdDistrictReceivedParentConsentDate,  
	   @spEdMeetingPurposeDataJSON,             
	   @spEdAdditionalMeetingPurposeDataJSON,  
	   @spEdAmendmentReasonsDataJSON,           
	   @spEdAmendmentReasonsOtherOption,
	   @spEdMeetingPurposeOtherOption,
	   @spEdFacilitatorUserID,
	   @spEdFacilitatorUserName,
	   @spEdMeetingDate,
	   @spEdMeetingDurationInMins,
	   @spEdMeetingTime,
	   @spEdMeetingTitle,
	   @spEdPlanTypeCode,  
	   @spEdStudentLanguageCodeID,
       @spEdStudentRaceCode,                     
	   @spEdNextEvalDate,
	   @spEdEnteredSpEdDate,
	   @spEdStudentLanguageEnglishLearner,
	   @spEdStudentLanguageInfoReclassified,
	   @spEdStudentLanguageInterpreterNeeded,
	   @spEdStudentLanguageTranslationRequested,
	   @spEdStudentLanguageEnglishLearnerUndesignatedPreschool,
	   @spEdTransitionGoalEducation,
	   @spEdTransitionGoalTraining,
	   @spEdTransitionGoalEmployment,
	   @spEdTransitionGoalIndependentLiving,

       @inTransitionalHousingStatus ,

	   @spEdDevAcaFunSkillsReading,
       @spEdDevAcaFunSkillsWriting,
       @spEdDevAcaFunSkillsMath,
       @spEdDevAcaFunSkillsCommunicationDev,
       @spEdDevAcaFunSkillsGrossFineMotorDev ,
       @spEdDevAcaFunSkillsHealth,
       @spEdDevAcaFunSkillsVocational,
       @spEdDevAcaFunSkillsAdaptiveDailyLiving,
       @spEdDevAcaFunSkillsAreasOfNeccessity,
       @spEdDevAcaFunSkillsSocialEmotionalBehavioral,         

	   @spEdPresentLevelsDataJSON,
	   @spEdPresentLevelsPreparedBy,
  	   @spEdPresentLevelsPreparedByName,
       @spEdStudentStrengthsSource,
	   @spEdStudentStrengthsSourceJSON,
	   @spEdStudentStrengthsImpact,
	   @spEdParentConcernsSource,
	   @spEdParentConcernsSourceJSON,
	   @spEdReadingReviewedNA,
	   @spEdReadingSource,
	   @spEdReadingSourceJSON,
	   @spEdReadingBaselineValue,
	   @spEdReadingBaselineUnit,
	   @spEdReadingToolsUsed,
	   @spEdReadingToolsUsedJSON,                             
	   @spEdReadingBaselineDate,
       @spEdReadingImpactSummary,
       @spEdWritingReviewedNA,
       @spEdWritingSource,
       @spEdWritingSourceJSON,
	   @spEdWritingBaselineValue,
	   @spEdWritingBaselineUnit,
	   @spEdWritingToolsUsed,
	   @spEdWritingToolsUsedJSON,                             
	   @spEdWritingBaselineDate,
	   @spEdWritingImpactSummary,
	   @spEdMathReviewedNA,
	   @spEdMathSource,
	   @spEdMathSourceJSON,
	   @spEdMathBaselineValue,
	   @spEdMathBaselineUnit,
	   @spEdMathToolsUsed,
	   @spEdMathToolsUsedJSON,                                
	   @spEdMathBaselineDate,
	   @spEdMathImpactSummary,
	   @spEdCommunicationDevReviewedNA,
	   @spEdCommunicationDevSource,
	   @spEdCommunicationDevSourceJSON,
	   @spEdCommunicationDevBaselineValue,
	   @spEdCommunicationDevBaselineUnit,
	   @spEdCommunicationDevToolsUsed,
	   @spEdCommunicationDevToolsUsedJSON,                    
	   @spEdCommunicationDevBaselineDate,
	   @spEdCommunicationDevImpactSummary,
	   @spEdGrossFineMotorReviewedNA,
	   @spEdGrossFineMotorSource,
	   @spEdGrossFineMotorSourceJSON,
	   @spEdGrossFineMotorBaselineValue,
	   @spEdGrossFineMotorBaselineUnit,
	   @spEdGrossFineMotorToolsUsed,
	   @spEdGrossFineMotorToolsUsedJSON,                      
	   @spEdGrossFineMotorBaselineDate,
	   @spEdGrossFineMotorImpactSummary,
	   @spEdHealthReviewedNA,
	   @spEdHealthSource,
	   @spEdHealthSourceJSON,
	   @spEdHealthBaselineValue,
	   @spEdHealthBaselineUnit,
	   @spEdHealthToolsUsed,
	   @spEdHealthToolsUsedJSON,                              
	   @spEdHealthBaselineDate,
	   @spEdHealthImpactSummary,
	   @spEdVocationalReviewedNA,
	   @spEdVocationalSource,
	   @spEdVocationalSourceJSON,
	   @spEdVocationalBaselineValue,
	   @spEdVocationalBaselineUnit,
	   @spEdVocationalToolsUsed,
	   @spEdVocationalToolsUsedJSON,                          
	   @spEdVocationalBaselineDate,
	   @spEdVocationalImpactSummary,
	   @spEdAdaptiveDailyLivingReviewedNA,
	   @spEdAdaptiveDailyLivingSource,
	   @spEdAdaptiveDailyLivingSourceJSON,
	   @spEdAdaptiveDailyLivingBaselineValue,
	   @spEdAdaptiveDailyLivingBaselineUnit,
	   @spEdAdaptiveDailyLivingToolsUsed,
	   @spEdAdaptiveDailyLivingToolsUsedJSON,                 
	   @spEdAdaptiveDailyLivingBaselineDate,
	   @spEdAdaptiveDailyLivingImpactSummary,
       @spEdSocialEmotionalBehavioralReviewedNA,
       @spEdSocialEmotionalBehavioralSource,
       @spEdSocialEmotionalBehavioralSourceJSON,
       @spEdSocialEmotionalBehavioralBaselineValue,
       @spEdSocialEmotionalBehavioralBaselineUnit,
       @spEdSocialEmotionalBehavioralToolsUsed,
       @spEdSocialEmotionalBehavioralToolsUsedJSON,
       @spEdSocialEmotionalBehavioralBaselineDate,
       @spEdSocialEmotionalBehavioralImpactSummary,
	   @spEdStudentStrengthsSourceNames,
	   @spEdParentConcernsSourceNames,
	   @spEdReadingSourceNames,
	   @spEdWritingSourceNames,
	   @spEdMathSourceNames,
	   @spEdCommunicationDevSourceNames,
	   @spEdGrossFineMotorSourceNames,
	   @spEdHealthSourceNames,
	   @spEdVocationalSourceNames,
	   @spEdAdaptiveDailyLivingSourceNames,
	   @spEdSocialEmotionalBehavioralSourceNames,             
	   @spEdReadingBaselineUnitNames,
	   @spEdWritingBaselineUnitNames,
	   @spEdMathBaselineUnitNames,
       @spEdCommunicationDevBaselineUnitNames,
	   @spEdGrossFineMotorBaselineUnitNames,
	   @spEdHealthBaselineUnitNames,
	   @spEdVocationalBaselineUnitNames,
	   @spEdAdaptiveDailyLivingBaselineUnitNames,
	   @spEdSocialEmotionalBehavioralBaselineUnitNames,        
	   @spEdReadingToolsUsedNames,
	   @spEdWritingToolsUsedNames,
	   @spEdMathToolsUsedNames,
	   @spEdCommunicationDevToolsUsedNames,
	   @spEdGrossFineMotorToolsUsedNames,
	   @spEdHealthToolsUsedNames,
	   @spEdVocationalToolsUsedNames,
	   @spEdAdaptiveDailyLivingToolsUsedNames,
	   @spEdSocialEmotionalBehavioralToolsUsedNames,          

	   @spEdParticipantDetailsJSON,
	   @spEdProceduralSafeguardsSentDate,
	   @spEdSpecialTransportationComments,
	   @spEdVehicleAdaptationType,
       @spEdCorrectionDetails,
       @spEdPreferredLanguageCodeID,              

	   @spEdServicesDataJSON
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
        spEdSpecialTransportation      = @spEdSpecialTransportation,
        spEdLastEvalDate               = @spEdLastEvalDate,
        spEdLastAnnualIEPDate          = @spEdLastAnnualIEPDate,
        spEdNextAnnualIEPDate          = @spEdNextAnnualIEPDate,
        spEdDisability1Code            = @spEdDisability1Code,
        spEdDisability2Code            = @spEdDisability2Code,
        spEdCaseManagerName            = @spEdCaseManagerName,
        spEdExitedSpEdDate             = @spEdExitedSpEdDate,
		spEdCurIEPDate                          = @spEdCurIEPDate,
		spEdStudentStrengths                    = @spEdStudentStrengths,                   
		spEdParentConcerns                      = @spEdParentConcerns,                    
		spEdProgressMonitoringData              = @spEdProgressMonitoringData,             
		spEdStudentPresentLevelsStatement       = @spEdStudentPresentLevelsStatement,      
		spEdStudentDisabilityAffectsPerformance = @spEdStudentDisabilityAffectsPerformance,
		spEdCurEligibilityDate                  = @spEdCurEligibilityDate,                 
		spEdInitEligibilityDate                 = @spEdInitEligibilityDate,                
		spEdIEPAttendeesIdentified              = @spEdIEPAttendeesIdentified,            
		spEdEligibilityReasons                  = @spEdEligibilityReasons,                 
		spEdPlanTranslateToLanguageCodeID       = @spEdPlanTranslateToLanguageCodeID,                         
		spEdInitRefDate                         = @spEdInitRefDate,                        
		spEdReferringPartyCode                  = @spEdReferringPartyCode,                 
		spEdReferringPartyOtherOption           = @spEdReferringPartyOtherOption,          
		spEdDistrictReceivedParentConsentDate   = @spEdDistrictReceivedParentConsentDate,  
		spEdMeetingPurposeDataJSON              = @spEdMeetingPurposeDataJSON,             
		spEdAdditionalMeetingPurposeDataJSON    = @spEdAdditionalMeetingPurposeDataJSON,   
		spEdAmendmentReasonsDataJSON            = @spEdAmendmentReasonsDataJSON,          
		spEdAmendmentReasonsOtherOption         = @spEdAmendmentReasonsOtherOption,
		spEdMeetingPurposeOtherOption           = @spEdMeetingPurposeOtherOption,
		spEdFacilitatorUserID                   = @spEdFacilitatorUserID,
		spEdFacilitatorUserName                 = @spEdFacilitatorUserName,
		spEdMeetingDate                         = @spEdMeetingDate,
		spEdMeetingDurationInMins               = @spEdMeetingDurationInMins,
		spEdMeetingTime                         = @spEdMeetingTime,
		spEdMeetingTitle                        = @spEdMeetingTitle,
		spEdPlanTypeCode                        = @spEdPlanTypeCode, 
		spEdStudentLanguageCodeID               = @spEdStudentLanguageCodeID,
        spEdStudentRaceCode                     = @spEdStudentRaceCode,   
        spEdNextEvalDate                        = @spEdNextEvalDate,
		spEdEnteredSpEdDate                     = @spEdEnteredSpEdDate,
		spEdStudentLanguageEnglishLearner       = @spEdStudentLanguageEnglishLearner,
		spEdStudentLanguageInfoReclassified     = @spEdStudentLanguageInfoReclassified,
		spEdStudentLanguageInterpreterNeeded    = @spEdStudentLanguageInterpreterNeeded,
		spEdStudentLanguageTranslationRequested = @spEdStudentLanguageTranslationRequested,
		spEdStudentLanguageEnglishLearnerUndesignatedPreschool = @spEdStudentLanguageEnglishLearnerUndesignatedPreschool,
		spEdTransitionGoalEducation = @spEdTransitionGoalEducation,
		spEdTransitionGoalTraining = @spEdTransitionGoalTraining,
		spEdTransitionGoalEmployment = @spEdTransitionGoalEmployment,

		spEdTransitionGoalIndependentLiving =   @spEdTransitionGoalIndependentLiving,

	    inTransitionalHousingStatus         =   @inTransitionalHousingStatus ,

		spEdDevAcaFunSkillsReading = @spEdDevAcaFunSkillsReading,

		spEdDevAcaFunSkillsWriting= @spEdDevAcaFunSkillsWriting,
		spEdDevAcaFunSkillsMath= @spEdDevAcaFunSkillsMath,
		spEdDevAcaFunSkillsCommunicationDev = @spEdDevAcaFunSkillsCommunicationDev,
		spEdDevAcaFunSkillsGrossFineMotorDev = @spEdDevAcaFunSkillsGrossFineMotorDev,
		spEdDevAcaFunSkillsHealth= @spEdDevAcaFunSkillsHealth,
		spEdDevAcaFunSkillsVocational= @spEdDevAcaFunSkillsVocational,
		spEdDevAcaFunSkillsAdaptiveDailyLiving= @spEdDevAcaFunSkillsAdaptiveDailyLiving,
		spEdDevAcaFunSkillsAreasOfNeccessity= @spEdDevAcaFunSkillsAreasOfNeccessity,
		spEdDevAcaFunSkillsSocialEmotionalBehavioral = @spEdDevAcaFunSkillsSocialEmotionalBehavioral,  

	    spEdPresentLevelsDataJSON            = @spEdPresentLevelsDataJSON,
		spEdPresentLevelsPreparedBy          = @spEdPresentLevelsPreparedBy,
		spEdPresentLevelsPreparedByName      = @spEdPresentLevelsPreparedByName,
		spEdStudentStrengthsSource           = @spEdStudentStrengthsSource,
		spEdStudentStrengthsSourceJSON       = @spEdStudentStrengthsSourceJSON,
		spEdStudentStrengthsImpact           = @spEdStudentStrengthsImpact,
		spEdParentConcernsSource             = @spEdParentConcernsSource,
		spEdParentConcernsSourceJSON         = @spEdParentConcernsSourceJSON,
		spEdReadingReviewedNA                = @spEdReadingReviewedNA,
		spEdReadingSource                    = @spEdReadingSource,
		spEdReadingSourceJSON                = @spEdReadingSourceJSON,
		spEdReadingBaselineValue             = @spEdReadingBaselineValue,
		spEdReadingBaselineUnit              = @spEdReadingBaselineUnit,
		spEdReadingToolsUsed                 = @spEdReadingToolsUsed,
		spEdReadingToolsUsedJSON             = @spEdReadingToolsUsedJSON,                 
		spEdReadingBaselineDate              = @spEdReadingBaselineDate,
		spEdReadingImpactSummary             = @spEdReadingImpactSummary,
		spEdWritingReviewedNA                = @spEdWritingReviewedNA,
		spEdWritingSource                    = @spEdWritingSource,
		spEdWritingSourceJSON                = @spEdWritingSourceJSON,
		spEdWritingBaselineValue             = @spEdWritingBaselineValue,
		spEdWritingBaselineUnit              = @spEdWritingBaselineUnit,
		spEdWritingToolsUsed                 = @spEdWritingToolsUsed,
		spEdWritingToolsUsedJSON             = @spEdWritingToolsUsedJSON,                 
		spEdWritingBaselineDate              = @spEdWritingBaselineDate,
		spEdWritingImpactSummary             = @spEdWritingImpactSummary,
		spEdMathReviewedNA                   = @spEdMathReviewedNA,
		spEdMathSource                       = @spEdMathSource,
		spEdMathSourceJSON                   = @spEdMathSourceJSON,
		spEdMathBaselineValue                = @spEdMathBaselineValue,
		spEdMathBaselineUnit                 = @spEdMathBaselineUnit,
		spEdMathToolsUsed                    = @spEdMathToolsUsed,
		spEdMathToolsUsedJSON                = @spEdMathToolsUsedJSON,                    
		spEdMathBaselineDate                 = @spEdMathBaselineDate,
		spEdMathImpactSummary                = @spEdMathImpactSummary,
		spEdCommunicationDevReviewedNA       = @spEdCommunicationDevReviewedNA,
		spEdCommunicationDevSource           = @spEdCommunicationDevSource,
		spEdCommunicationDevSourceJSON       = @spEdCommunicationDevSourceJSON,
		spEdCommunicationDevBaselineValue    = @spEdCommunicationDevBaselineValue,
		spEdCommunicationDevBaselineUnit     = @spEdCommunicationDevBaselineUnit,
		spEdCommunicationDevToolsUsed        = @spEdCommunicationDevToolsUsed,
		spEdCommunicationDevToolsUsedJSON    = @spEdCommunicationDevToolsUsedJSON,        
		spEdCommunicationDevBaselineDate     = @spEdCommunicationDevBaselineDate,
		spEdCommunicationDevImpactSummary    = @spEdCommunicationDevImpactSummary,
		spEdGrossFineMotorReviewedNA         = @spEdGrossFineMotorReviewedNA,
		spEdGrossFineMotorSource             = @spEdGrossFineMotorSource,
		spEdGrossFineMotorSourceJSON         = @spEdGrossFineMotorSourceJSON,
		spEdGrossFineMotorBaselineValue      = @spEdGrossFineMotorBaselineValue,
		spEdGrossFineMotorBaselineUnit       = @spEdGrossFineMotorBaselineUnit,
		spEdGrossFineMotorToolsUsed          = @spEdGrossFineMotorToolsUsed,
		spEdGrossFineMotorToolsUsedJSON      = @spEdGrossFineMotorToolsUsedJSON,          
		spEdGrossFineMotorBaselineDate       = @spEdGrossFineMotorBaselineDate,
		spEdGrossFineMotorImpactSummary      = @spEdGrossFineMotorImpactSummary,
		spEdHealthReviewedNA                 = @spEdHealthReviewedNA,
		spEdHealthSource                     = @spEdHealthSource,
		spEdHealthSourceJSON                 = @spEdHealthSourceJSON,
		spEdHealthBaselineValue              = @spEdHealthBaselineValue,
		spEdHealthBaselineUnit               = @spEdHealthBaselineUnit,
		spEdHealthToolsUsed                  = @spEdHealthToolsUsed,
		spEdHealthToolsUsedJSON              = @spEdHealthToolsUsedJSON,                  
		spEdHealthBaselineDate               = @spEdHealthBaselineDate,
		spEdHealthImpactSummary              = @spEdHealthImpactSummary,
		spEdVocationalReviewedNA             = @spEdVocationalReviewedNA,
		spEdVocationalSource                 = @spEdVocationalSource,
		spEdVocationalSourceJSON             = @spEdVocationalSourceJSON,
		spEdVocationalBaselineValue          = @spEdVocationalBaselineValue,
		spEdVocationalBaselineUnit           = @spEdVocationalBaselineUnit,
		spEdVocationalToolsUsed              = @spEdVocationalToolsUsed,
		spEdVocationalToolsUsedJSON          = @spEdVocationalToolsUsedJSON,              
		spEdVocationalBaselineDate           = @spEdVocationalBaselineDate,
		spEdVocationalImpactSummary          = @spEdVocationalImpactSummary,
		spEdAdaptiveDailyLivingReviewedNA    = @spEdAdaptiveDailyLivingReviewedNA,
		spEdAdaptiveDailyLivingSource        = @spEdAdaptiveDailyLivingSource,
		spEdAdaptiveDailyLivingSourceJSON    = @spEdAdaptiveDailyLivingSourceJSON,
		spEdAdaptiveDailyLivingBaselineValue = @spEdAdaptiveDailyLivingBaselineValue,
		spEdAdaptiveDailyLivingBaselineUnit  = @spEdAdaptiveDailyLivingBaselineUnit,
		spEdAdaptiveDailyLivingToolsUsed     = @spEdAdaptiveDailyLivingToolsUsed,
		spEdAdaptiveDailyLivingToolsUsedJSON = @spEdAdaptiveDailyLivingToolsUsedJSON,     
		spEdAdaptiveDailyLivingBaselineDate  = @spEdAdaptiveDailyLivingBaselineDate,
		spEdAdaptiveDailyLivingImpactSummary = @spEdAdaptiveDailyLivingImpactSummary,
        spEdSocialEmotionalBehavioralReviewedNA    = @spEdSocialEmotionalBehavioralReviewedNA,
        spEdSocialEmotionalBehavioralSource        = @spEdSocialEmotionalBehavioralSource,
        spEdSocialEmotionalBehavioralSourceJSON    = @spEdSocialEmotionalBehavioralSourceJSON,
        spEdSocialEmotionalBehavioralBaselineValue = @spEdSocialEmotionalBehavioralBaselineValue,
        spEdSocialEmotionalBehavioralBaselineUnit  = @spEdSocialEmotionalBehavioralBaselineUnit,
        spEdSocialEmotionalBehavioralToolsUsed     = @spEdSocialEmotionalBehavioralToolsUsed,
        spEdSocialEmotionalBehavioralToolsUsedJSON = @spEdSocialEmotionalBehavioralToolsUsedJSON,
        spEdSocialEmotionalBehavioralBaselineDate  = @spEdSocialEmotionalBehavioralBaselineDate,
        spEdSocialEmotionalBehavioralImpactSummary = @spEdSocialEmotionalBehavioralImpactSummary,

		spEdParticipantDetailsJSON			 = @spEdParticipantDetailsJSON,
		spEdReadingToolsUsedNames            = @spEdReadingToolsUsedNames,
		spEdWritingToolsUsedNames            = @spEdWritingToolsUsedNames,
		spEdMathToolsUsedNames               = @spEdMathToolsUsedNames,
		spEdCommunicationDevToolsUsedNames   = @spEdCommunicationDevToolsUsedNames,
		spEdGrossFineMotorToolsUsedNames     = @spEdGrossFineMotorToolsUsedNames,
		spEdHealthToolsUsedNames             = @spEdHealthToolsUsedNames,
		spEdVocationalToolsUsedNames         = @spEdVocationalToolsUsedNames,
		spEdAdaptiveDailyLivingToolsUsedNames  = @spEdAdaptiveDailyLivingToolsUsedNames,
		spEdSocialEmotionalBehavioralToolsUsedNames = @spEdSocialEmotionalBehavioralToolsUsedNames,  
        spEdSocialEmotionalBehavioralSourceNames = @spEdSocialEmotionalBehavioralSourceNames,       
        spEdSocialEmotionalBehavioralBaselineUnitNames = @spEdSocialEmotionalBehavioralBaselineUnitNames,  

		spEdProceduralSafeguardsSentDate	 = @spEdProceduralSafeguardsSentDate,
		spEdSpecialTransportationComments	 = @spEdSpecialTransportationComments,
		spEdVehicleAdaptationType		     = @spEdVehicleAdaptationType,
		spEdCorrectionDetails                = @spEdCorrectionDetails,
	    spEdPreferredLanguageCodeID          = @spEdPreferredLanguageCodeID,

    
		spEdServicesDataJSON                 = @spEdServicesDataJSON

                      
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
GRANT EXECUTE ON  [dbo].[PATIENT_Save] TO [webuser]
GO