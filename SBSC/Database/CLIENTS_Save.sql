USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLIENT_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLIENT_Save]    
 (@userID                                 BIGINT,    
  @userGroup                              INT,    
  @userRank                               INT,
  @clientName                             NVARCHAR(50),    
  @clientCDS                              NVARCHAR(7),
  @NPI                                    NVARCHAR(10),
  @tax_ID                                 NVARCHAR(10),
  @first_check                            datetime,
  @approved_837                           BIT,
  @approved_835                           BIT,
  @EIN                                    NCHAR(10),
  @COE                                    BIT,
  @LEA                                    BIT,
  @MAA                                    BIT,
  @rvnsharectgLEA                         NVARCHAR(100),  
  @rvnsharectgMAA                         NVARCHAR(100),  
  @clrepIDLEA                             BIGINT,         
  @clrepIDMAA                             BIGINT,
  @owndbycompIDLEA                        BIGINT,  
  @owndbycompIDMAA                        BIGINT,
  @lecOrLgaID                             BIGINT,
  @shortname                              NVARCHAR(100),  
  @nameRcgbyDHCS_EDS                      NVARCHAR(100),
  @LEArecoveryBudget                      DECIMAL(18,2),
  @hyQueueFee                             MONEY,
  @planWriterFee                          MONEY,
  @baselineReimbursement                  MONEY,    
  @address1                               NVARCHAR(50),  
  @address2                               NVARCHAR(50),
  @city                                   NVARCHAR(50),
  @state                                  NVARCHAR(50),
  @zip                                    NVARCHAR(5),
  @zipPlusFour                            NVARCHAR(4),
  @contactLname                           NVARCHAR(50), 
  @contactFname                           NVARCHAR(50),
  @contactTitle                           NVARCHAR(50),
  @contactPhone                           NCHAR(14),
  @contactFax                             NCHAR(14),
  @contactEmail                           NVARCHAR(MAX),
  @svcRecApprovalSys                      BIT,
  @notes                                  NVARCHAR(MAX),
  @cybhiDoNotClaimOverappingLEABopSvcs    BIT,
  @cybhiAddOnMissingInfoRequestsToPatientPersons	BIT,

  @cybhiTpaApproved						  BIT,
  @cybhiTpaApprovedOn				      DATE,
  @cybhiTpaID							  VARCHAR(256),

  @cybhiConsortiumBilling  				  BIT,
  @cybhiConsortiumLeadClientID 			  BIGINT,
  @leaBopConsortiumBilling  			  BIT,
  @leaBopConsortiumLeadClientID 		  BIGINT,

  @claim_TCM                              BIT,    
  @claim_TCMEffectiveDate                 DATETIME,
  @parentConsentAgreement                 BIT,
  @parentConsentAgreementEffectiveDate    DATETIME,
  @sendUsersEmailNotifications            BIT,
  @planWriterAccessGranted                bit,
  @planWriterAccessEndDate                date,
  @numDaysToHoldClientEnteredClaims       int,
  @autoGenerate837File                    bit,
  @teleCommTeleHealthAccessGranted        bit,
  @teleCommTeleHealthAccessEndDate        date,

  @teleCommTeleIEPAccessGranted           bit,
  @teleCommTeleIEPAccessEndDate           date,
  @carePlanLegalLang					  VARCHAR(MAX),
  @clientlogofiledata					  VARCHAR(MAX),
  @cronTabExpectedTotPop                  bigint = 99,
  @cronTabExpectedSpecEdSvcs              bigint = 99,
  @sendRequestsForTotPop                  bit = 0,
  @sendRequestsForSpEd                    bit = 0,
  @SELPACode                              bigint,
  @sendElibilityDataMatchRequestsToDHCS   bit = 0,
  @cdeComplianceClient                    bit = 1,
  @cybhi								  bit = 0,
  @fuzzyMatchSitesByNameAndCode           bit = 0,
  @cybhiClientCode                        VARCHAR(256),
  @initialContractStartDate               date,
  @healtheKids_percent                    money,
  @cybhi_percent                          money,
  @crcs_percent                           money,
  @cdeReporting_percent                   money,
  @planImplementation_percent             money,
  @ruHealth_percent                       money,
  @newProduct2_percent                    money,
  @newProduct3_percent                    money,
  @accounting_percent                     money,
  @flatFee_amount                         money,

  -- @practiCal_percent                      money,
  -- @spEdCare_percent                       money,

  @csba_percent                           money,
  @lba_percent                            money,
  @partner1_percent                       money,
  @partner1E_percent                      money,
  @partner2_percent                       money,
  @clientRetention                        money,


  @impliedFerpaConsent					  bit = 0,
  @cybhiSubmitClaims					  bit = 1,
  @cybhiClinicalSupervisorPracID	      bigint,
  @cybhiClientName						  nvarchar(100),
  @cybhiNPI								  nchar(10),
  @cybhiTaxID							  nchar(10),
  @cybhiAddress1						  nvarchar(256),
  @cybhiAddress2						  nvarchar(256),
  @cybhiCity							  nvarchar(50),
  @cybhiState							  nvarchar(10),
  @cybhiZip5							  nvarchar(5),
  @cybhiZip4							  nvarchar(5),  
  @cybhiGenerate837                       bit = 0,
  @cybhiAutoGenerate837                   bit = 0,
  @cybhiNumDaysToHoldEnteredClaims        int = 7,

  @mba_bba_percent                            money,


  --@mba_dg_percent                         money,

  @spEdCare_bba_percent                   money,

  --@spEdCare_dg_percent                    money,

  @smaa_1_percent                         money,
  @smaa_2_percent                         money,
  @smaa_3_percent                         money,

  @editDelReason                          VARCHAR(7000),    
  @validateRec                            BIT,    
  @saveType                               INT,    
  @recID                                  INT,
  @MsgNotActive                           VARCHAR(1000),
  @MsgNoRec                               VARCHAR(1000),    
  @MsgNoEdit                              VARCHAR(1000),
  @MsgNoFullEdit                          VARCHAR(1000),    
  @MsgDupRec                              VARCHAR(1000),
  @MsgNoGroup                             VARCHAR(1000),   
  @MsgDataError                           VARCHAR(1000),    
  @spDetails                              VARCHAR(8000) OUTPUT,    
  @recordID                               BIGINT        OUTPUT) 
  
  
AS    
BEGIN    
   
/***************************************************************************    
 * CLIENT_SAVE */    
/**    
 * Creates a new or edits existing entity record    
 * and manages any associated records.    
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   clientName
 * @param   clientCDS
 * @param   NPI
 * @param   tax_ID 
 * @param   first_check
 * @param   approved_837    
 * @param   approved_835   
 * @param   EIN
 * @param   COE
 * @param   LEA
 * @param   MAA
 * @param   rvnsharectgLEA    
 * @param   rvnsharectgMAA    
 * @param   clrepIDLEA                
 * @param   clrepIDMAA        
 * @param   owndbycompIDLEA   
 * @param   owndbycompIDMAA   
 * @param   shortname         
 * @param   nameRcgbyDHCS_EDS 
 * @param   LEArecoveryBudget
 * @param   hyQueueFee
 * @param   planWriterFee
 * @param   baselineReimbursement 
 * @param   address1        
 * @param   address2 
 * @param   city     
 * @param   state
 * @param   zip       
 * @param   contactLname  
 * @param   contactFname 
 * @param   contactTitle
 * @param   contactPhone 
 * @param   contactFax   
 * @param   contactEmail
 * @param   notes           Notes  
 * @param   nameRcgbyDHCS_EDS
 * @param   editDelReason                Reason for record edit or delete    
 * @param   validateRec                  1 = Performs data integrity validation tasks    
                                             Perform advisory validation tasks that can    
 *                                           only be conducted by referencing data from the    
 *                                           database and then exits WITHOUT saving the record    
 *                                       0 = Peform data integrity validation tasks and    
 *                                           if these tasks succeed peforms the desired    
 *                                           operation (saveType) on the record and exits    
 * @param   saveType                     Type of operation to perform    
 *                                       1 = New, 2 = Edit, 3 = Delete    
 * @param   recID                        Record id of existing client record to edit or    
 *                                       delete.
 * @param   claim_TCM                    Claim TCM for reimbursement    
 * @param   claim_TCMEffectiveDate       Date for claiming TCM for reimbursement    
 * @param   MsgNoRec                     Desired error message if a recID is not found    
 * @param   MsgNoEdit                    Desired error message if a record cannot be edited    
 * @param   MsgNoFullEdit                Desired error message if a record can only be partially edited
 * @param   MsgDupRec                    Desired error message for duplicate detection    
 * @param   MsgNoClient                  Desired error message if a clientID is not found 
 * @param   MsgNoGroup                   Desired error message if a groupID is not found    
 * @param   MsgDataError                 Desired error message for data errors    
 * @returns spDetails                    Validation or error details    
 * @returns recordID                     New record id or record id of service record that    
 *                                       was changed or deleted    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @today                     AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen                  AS BIT            -- Is a transaction open    
DECLARE @dupCount                  AS INT            -- Duplicate counter used for validation    
DECLARE @updateState               AS SMALLINT       -- Indicates what state the record is left in    
DECLARE @canEdit                   AS BIT            -- If the record is inactive it cannot be edited
DECLARE @isActive                  AS BIT            -- Is this record active?
DECLARE @noFullEdit                AS BIT
DECLARE @tempRecID                 AS INT            -- Used for determining if a rec exists  
DECLARE @pracClientRecID           AS INT
DECLARE @clientNoteRecID           AS INT
DECLARE @clientAddressRecID        AS INT
DECLARE @clientContactRecID        AS INT
DECLARE @svcRecApprovalOptionRecID as BIGINT
DECLARE @pracrecordID              AS INT
DECLARE @auditRecID                AS BIGINT         -- Audit record id    


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
   
IF (@userGroup                  IS NULL) RAISERROR ('userGroup is required',       11, 1)    
IF (@userRank                   IS NULL) RAISERROR ('userRank is required',        11, 1)    
IF (@validateRec                IS NULL) RAISERROR ('Validate flag required',      11, 1)    
IF (@saveType                   IS NULL) RAISERROR ('Save type is required',       11, 1)    
IF (@clientCDS                  IS NULL) RAISERROR ('ClientCDS is required',       11, 1) 
IF (@clientName                 IS NULL) RAISERROR ('Client Name is required',     11, 1)

-- Need to uncomment this eventually. The frontend for these two fields are currently optional since all
-- the eff dates are NULL right now, but we'll eventually make it required after we backfill the eff dates.     
      -- IF (@claimNoPlanEffectiveDate   IS NULL) RAISERROR ('Claim Free Care is required', 11, 1)    
      -- IF (@claim_TCMEffectiveDate     IS NULL) RAISERROR ('Claim TCM is required',       11, 1)    

IF ((@saveType = dbo.CONST_SAVE_TYPE_EDIT()) AND (@recID IS NULL))    
  RAISERROR ('updateRecID is required', 11, 1)                             

/*-------------------------------    
 * Prep worker variables    
 *------------------------------*/    
     
SET @today      = GETDATE()   
SET @isActive   = 1  

/*-------------------------------    
 * Set default values
 *------------------------------*/  

IF (@notes IS NULL)                         set @notes           = ''   
if (trim(isnull(@cybhiClientCode,'')) = '') set @cybhiClientCode = ''

declare @testLeadClientID as int = 0

if (@leaBopConsortiumBilling = 1)
begin
  
  /* Consortium lead selected*/
  
  if (isnull(@leaBopConsortiumLeadClientID,0) != 0)
  begin
      
	  set @testLeadClientID = 0

	  /* Test selection.  It cannot have a lead of its own */
	  
	  select top 1 
	    @testLeadClientID = isnull(clc.leaBopConsortiumLeadClientID,0)
      from dbo.CLIENTS_Client as clc
      where 
	    (clc.CLIENT_ID = @leaBopConsortiumLeadClientID)

      if (@testLeadClientID != 0)
	  begin
	    RAISERROR ('Lead consortium for LEA BOP cannot have its own lead consortium selected', 11, 1)
	  end
  end
end

if (@cybhiConsortiumBilling = 1)
begin
  
  /* Consortium lead selected*/
  
  if (isnull(@cybhiConsortiumLeadClientID,0) != 0)
  begin
	  
	  set @testLeadClientID = 0

	  /* Test selection.  It cannot have a lead of its own */

	  select top 1 
	    @testLeadClientID = isnull(clc.cybhiConsortiumLeadClientID,0)
      from dbo.CLIENTS_Client as clc
      where 
	    (clc.CLIENT_ID = @cybhiConsortiumLeadClientID)

      if (@testLeadClientID != 0)
	  begin
	    RAISERROR ('Lead consortium selected for CYBHI cannot have its own lead consortium selected.', 11, 1)
	  end
  end
end

/*-------------------------------    
   * CYBHI Clinical Supervisor
   * Sanity check
   *------------------------------*/  

/* Framework sets null ints to 0.  We need to set back to null */
 
set @cybhiClinicalSupervisorPracID = isnull(@cybhiClinicalSupervisorPracID,0)  
if (@cybhiClinicalSupervisorPracID = 0) set @cybhiClinicalSupervisorPracID = null

if (@cybhiClinicalSupervisorPracID is not null)
  begin
    if not exists (select top 1 PRACTITIONER_ID from dbo.PRACTITIONER_Practitioner where PRACTITIONER_ID = @cybhiClinicalSupervisorPracID)
    begin
      RAISERROR ('CYBHI clinical supervisor not found', 11, 1)
    end
  end


/*-------------------------------    
 * If this is an edit
 * perform edit sanity checks
 *------------------------------*/ 



IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
BEGIN   
   
  declare @activeClaimRecs int   
  declare @activeSvcRecs   int 

  SET @recordID   = NULL    
  SET @canEdit    = 1 /* Note: No current restrictions on edit */
  
  /*-------------------------------    
   * Does the record exist and if    
   * so can it be edited    
   *------------------------------*/
     
  SELECT    
    @recordID           = ID,
    @isActive           = ACTIVE 
  FROM dbo.CLIENTS_VIEW(@userID,@userGroup,@userRank,@recID,null,null,null,null,null,null,null,null,null,null,null,null,null,null) 
    
  /*-------------------------------    
   * If the record does not exist
   * or it cannot be edited  
   * exit and let the user know   
   *------------------------------*/

  IF (@recordID IS NULL) RAISERROR (@MsgNoRec,  11, 1)        
  IF (@canEdit = 0)      RAISERROR (@MsgNoEdit, 11, 1) 

END    
        
/*-------------------------------    
 * Validation    
 *------------------------------*/    
   
IF (((@saveType = dbo.CONST_SAVE_TYPE_NEW()) OR    
     (@saveType = dbo.CONST_SAVE_TYPE_EDIT())))    
BEGIN          
  
  /*-------------------------------    
   * Advisement validation   
   * Advisement does not prohibit
   * a record save. 
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
     * the  clientname and CDS        
     *------------------------------*/    
       
    SELECT 
      @dupCount = COUNT(cv.id) 
    FROM
      CLIENTS_VIEW(@userID,@userGroup,@userRank,@recID,@clientName,null,null,null,null,null,null,null,null,null,null,null,null,1) AS Cv
    WHERE 
      ((@recID IS NULL) OR (cv.id != @recID)) and CDS = @clientCDS             
   
    IF @dupCount > 0    
    BEGIN    
      SET @msgDupRec = dbo.STRING_CREATE(@msgDupRec, CONVERT(VARCHAR(10),@dupCount), NULL, NULL)    
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
         
    RETURN(0)         

  END    
END 
   
/*-------------------------------    
 * Create or modify our    
 * practitioner record    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  SET @TranOpen = 1    
   
  /*-------------------------------    
   * New client record
   *------------------------------*/    
   
  IF (@saveType = dbo.CONST_SAVE_TYPE_NEW())    
  BEGIN    
   
    SET @updateState = dbo.CONST_REC_STATE_NEW()    
    
    /*-------------------------------    
     * Client
     *------------------------------*/    
  
    INSERT INTO dbo.CLIENTS_Client
    (  
      CLIENT_NAME,
      CLIENT_CDS,
      NPI,
      TAX_ID,
      FIRST_CHECK,
      DATE_CREATED,
      APPROVED_837,
      APPROVED_835,
      EIN,
      COE,
      LEA,
      MAA,
      RevenueSharingCategoryLEACurrent,
      RevenueSharingCategoryMAACurrent,
      ClientRepIDLEACurrent,
      ClientRepIDMAACurrent,
      OwnedByCompanyID_LEA,
      OwnedByCompanyID_MAA,
	  lecOrLgaID,
      ShortName,
      NameRecgByDHCS_EDS,
	  TCM_RATE,
      LEARecoveryBudget,
	  hyQueueFee,
	  planWriterFee,
	  baselineReimbursement,
      createdByUserID,
      state,
	  claimNoPlan,
      claim_TCM,
	  claimNoPlanEffectiveDate,
      claim_TCMEffectiveDate,
      parentConsentAgreement,
	  parentConsentAgreementEffectiveDate,
      sendUsersEmailNotifications,
      numDaysToHoldClientEnteredClaims,
      autoGenerate837File,
	  teleCommTeleHealthAccessGranted,
	  teleCommTeleHealthAccessEndDate,
	  teleCommTeleIEPAccessGranted,
	  teleCommTeleIEPAccessEndDate,
	  carePlanLegalLang,
	  clientlogofiledata,
      defaultMCALBillingConsentMsgText,
	  cronTabExpectedTotPop,
      cronTabExpectedSpecEdSvcs,
      sendRequestsForTotPop,
      sendRequestsForSpEd,	  
	  SELPACode,
	  sendElibilityDataMatchRequestsToDHCS,
	  cdeComplianceClient,
	  cybhi,
	  fuzzyMatchSitesByNameAndCode,
	  cybhiClientCode,
	  initialContractStartDate,
	  healtheKids_percent,
	  cybhi_percent,
	  crcs_percent,
	  cdeReporting_percent,
	  planImplementation_percent,
	  ruHealth_percent,
	  newProduct2_percent,
	  newProduct3_percent,
	  accounting_percent,
	  flatFee_amount,

	  -- practiCal_percent,
	  -- spEdCare_percent,

	  csba_percent,
	  lba_percent,
	  partner1_percent,
	  partner1E_percent,
	  partner2_percent,
	  clientRetention,
	  mba_bba_percent,
	  -- mba_dg_percent,
	  spEdCare_bba_percent,
	  -- spEdCare_dg_percent,
      smaa_1_percent,
      smaa_2_percent,
      smaa_3_percent,  
	  cybhiDoNotClaimOverappingLEABopSvcs, 
	  cybhiAddOnMissingInfoRequestsToPatientPersons,
	  cybhiTpaApproved,
	  cybhiTpaApprovedOn,
	  
	  cybhiConsortiumBilling,
	  cybhiConsortiumLeadClientID,
	  leaBopConsortiumBilling,
	  leaBopConsortiumLeadClientID,


      cybhiTpaID,
	  impliedFerpaConsent,
	  cybhiSubmitClaims,
	  cybhiClinicalSupervisorPracID,    
	  cybhiClientName,
	  cybhiNPI,
	  cybhiTaxID,
	  cybhiAddress1,
	  cybhiAddress2,
	  cybhiCity,
	  cybhiState,
	  cybhiZip5,
	  cybhiZip4,
	  cybhiGenerate837,
      cybhiAutoGenerate837,
      cybhiNumDaysToHoldEnteredClaims
    )    
    VALUES    
    (  
      @clientName,
      @clientCDS,
      @NPI,
      @tax_ID,
      @first_check,
      @today,
      @approved_837,
      @approved_835,
      @EIN,
      @COE,
      @LEA,
      @MAA,
      @rvnsharectgLEA,
      @rvnsharectgMAA,
      @clrepIDLEA,
      @clrepIDMAA,
      @owndbycompIDLEA, 
      @owndbycompIDMAA,
	  @lecOrLgaID,
      @shortname, 
      @nameRcgbyDHCS_EDS,
	  'HIGH',
      @LEArecoveryBudget,
	  @hyQueueFee,
	  @planWriterFee,
	  @baselineReimbursement,
      @userID,
      @updateState,
	  1,
      @claim_TCM,
	  @today,
      @claim_TCMEffectiveDate,
      @parentConsentAgreement,
	  @parentConsentAgreementEffectiveDate,
      @sendUsersEmailNotifications,
      @numDaysToHoldClientEnteredClaims,
      @autoGenerate837File,
	  @teleCommTeleHealthAccessGranted,
	  @teleCommTeleHealthAccessEndDate,
	  @teleCommTeleIEPAccessGranted,
	  @teleCommTeleIEPAccessEndDate,
	  @carePlanLegalLang,
	  @clientlogofiledata,
	  'This written notification is to inform you of your rights prior to the school district seeking permission to access the students or parents public benefits or public insurance program (e.g. Medi-Cal) for covered health-related services in the school setting. These rights include... Medi-Cal funds help with state and local costs for providing Special Education and health-related services',
     @cronTabExpectedTotPop,
     @cronTabExpectedSpecEdSvcs,
	 @sendRequestsForTotPop,
	 @sendRequestsForSpEd,
	 @SELPACode,
	 @sendElibilityDataMatchRequestsToDHCS,
	 @cdeComplianceClient,
	 @cybhi,
	 @fuzzyMatchSitesByNameAndCode,
	 @cybhiClientCode,
	 @initialContractStartDate,
	 @healtheKids_percent,
	 @cybhi_percent,
	 @crcs_percent,
	 @cdeReporting_percent,
	 @planImplementation_percent,
	 @ruHealth_percent,
	 @newProduct2_percent,
	 @newProduct3_percent,
	 @accounting_percent,
	 @flatFee_amount,

	 -- @practiCal_percent,
	 -- @spEdCare_percent,

	 @csba_percent,
	 @lba_percent,
	 @partner1_percent,
	 @partner1E_percent,
	 @partner2_percent,
	 @clientRetention,
	 @mba_bba_percent,
	 --@mba_dg_percent,
	 @spEdCare_bba_percent,
	 --@spEdCare_dg_percent,
	 @smaa_1_percent,
	 @smaa_2_percent,
	 @smaa_3_percent,
	 @cybhiDoNotClaimOverappingLEABopSvcs,
	 @cybhiAddOnMissingInfoRequestsToPatientPersons,

	 @cybhiTpaApproved,
	 @cybhiTpaApprovedOn,
	 
	 @cybhiConsortiumBilling,
	 @cybhiConsortiumLeadClientID,
	 @leaBopConsortiumBilling,
	 @leaBopConsortiumLeadClientID,
	  
	 @cybhiTpaID,
	 @impliedFerpaConsent,
	 @cybhiSubmitClaims,
	 @cybhiClinicalSupervisorPracID,
	 @cybhiClientName,
	 @cybhiNPI,
	 @cybhiTaxID,
	 @cybhiAddress1,
	 @cybhiAddress2,
	 @cybhiCity,
	 @cybhiState,
	 @cybhiZip5,
	 @cybhiZip4,
	 @cybhiGenerate837,
     @cybhiAutoGenerate837,
     @cybhiNumDaysToHoldEnteredClaims
	)      
    
    SET @recordID = SCOPE_IDENTITY()    
     
   /*-------------------------------    
    * CLIENTS_Address
    *------------------------------*/    
    
   INSERT INTO dbo.CLIENTS_Address
   (
    ADDRESS_1,
    ADDRESS_2,
    CITY,
    STATE,
    ZIP,
    ZIP_PLUS_FOUR,
    CLIENT_ID
   )  
   VALUES
   (  
    @address1,
    @address2,
    @city,
    @state,
    @zip,
    @zipPlusFour,
    @recordID
   )      

   /*-------------------------------    
    * CLIENTS_Contact
    *------------------------------*/    
   
   INSERT INTO dbo.CLIENTS_Contact
   (
    CONTACT_LAST_NAME,
    CONTACT_FIRST_NAME,
    TITLE,
    PHONE,
    EMAIL,
    CLIENT_ID,
    FAX
    )    
    VALUES
    (
     @contactLname,
     @contactFname,
     @contactTitle,
     @contactPhone,
     @contactEmail,
     @recordID,
     @contactFax
    ) 
       
   /*-------------------------------    
    * CLIENTS_InputNote
    *------------------------------*/    

   INSERT INTO dbo.CLIENTS_InputNote
   (
     INPUT_NOTE_CLIENT_ID,
     INPUT_NOTE
   )  
   VALUES
   (  
    @recordID,
    @notes
   )
                   
   /*-------------------------------    
    * Service record approval options
    *------------------------------*/    

   INSERT INTO dbo.SERVICE_RECORDS_APPROVAL_OPTIONS (clientID, approvalSystem) values (@recordID, @svcRecApprovalSys)
   
   /*-------------------------------    
    * Plan writer access
    *------------------------------*/    
   
   insert into dbo.PLAN_WRITER (
      CLIENT_ID
    , ACCESS_GRANTED
    , END_DATE 
    , CREATED_BY
    , CREATED_ON
    , ACTIVE )
   
   values (
       @recordID
     , @planWriterAccessGranted
     , @planWriterAccessEndDate
     , @userID
     , @today
     , 1
   )
   
   /*------------------------------------------    
    * Since each client is associated with a
    * practitioner for state adjustment, insert
    * a practitioner record 
    *------------------------------------------*/     
   
   INSERT INTO PRACTITIONER_Practitioner
   ( 
     LAST_NAME,
     FIRST_NAME,
     DATE_CREATED,
     ACTIVE,
     createdByUserID
    )
    VALUES
    (
     'STATE',
     'ADJUSTMENT',
     @today,
     1,
     @userID
    )
    
    SET @pracrecordID = SCOPE_IDENTITY()    
    
    INSERT INTO dbo.PRACTITIONER_Client  
    (
      CLIENT_ID,
      PRACTITIONER_ID
    )
    VALUES
    (
      @recordID,
      @pracrecordID
    ) 
    
   /*-------------------------------    
    * Practitioner group
    *------------------------------*/    

   INSERT INTO dbo.PRACTITIONER_GROUPS
   (
     GROUP_ID,
     PRACTITIONER_ID
   )  
   VALUES
   (  152,
      @pracrecordID
   ) 
   
   /*-------------------------------    
    * Sites_Site
	* Non public school
    *------------------------------*/  

   declare @siteCDS  as nchar(7)
   declare @siteName as nvarchar(50)
   
   select top 1 @siteCDS = t1.NEXT_CDS_NUMBER from dbo.GENERATE_NEXT_CDS_7_X_CODE as t1
   set @siteName = dbo.CONST_NON_PUBLIC_SCHOOL_NAME()
   
   INSERT INTO dbo.SITES_Site
   (
     SITE_CLIENT_ID,
     SITE_CDS,
     SITE_NAME,
     DATE_CREATED,
     DATE_MODIFIED
   )  
   VALUES
   (   @recordID
     , @siteCDS
     , @siteName
     , @today
     , @today
   ) 
    
   /*-------------------------------    
    * Unknown school name
    *------------------------------*/  

   select top 1 @siteCDS = t1.NEXT_CDS_NUMBER  from dbo.GENERATE_NEXT_CDS_7_X_CODE as t1
   set @siteName = dbo.CONST_UNKNOWN_SCHOOL_NAME()

   INSERT INTO dbo.SITES_Site
   (
     SITE_CLIENT_ID,
     SITE_CDS,
     SITE_NAME,
     DATE_CREATED,
     DATE_MODIFIED
   )  
   VALUES
   (   @recordID
      ,@siteCDS
      ,@siteName
      ,@today
      ,@today
   ) 
   
  END         
  
  ELSE IF (@saveType = dbo.CONST_SAVE_TYPE_EDIT())    
  BEGIN    
     
    /*-------------------------------    
     * Edit existing entity record    
     *------------------------------*/    
     
     SET @updateState = dbo.CONST_REC_STATE_MOD()                  
       
     UPDATE dbo.CLIENTS_Client
     SET
       CLIENT_NAME                               = @clientName,
       CLIENT_CDS                                = @clientCDS,
       NPI                                       = @NPI,
       TAX_ID                                    = @tax_ID,
       FIRST_CHECK                               = @first_check,
       APPROVED_837                              = @approved_837,
       APPROVED_835                              = @approved_835,
       EIN                                       = @EIN,
       COE                                       = @COE,
       LEA                                       = @LEA,
       MAA                                       = @MAA,
       RevenueSharingCategoryLEACurrent          = @rvnsharectgLEA,
       RevenueSharingCategoryMAACurrent          = @rvnsharectgMAA,
       ClientRepIDLEACurrent                     = @clrepIDLEA,
       ClientRepIDMAACurrent                     = @clrepIDMAA,
       OwnedByCompanyID_LEA                      = @owndbycompIDLEA,
       OwnedByCompanyID_MAA                      = @owndbycompIDMAA,
	   lecOrLgaID								 = @lecOrLgaID,
       ShortName                                 = @shortname,
       NameRecgByDHCS_EDS                        = @nameRcgbyDHCS_EDS,
       LEARecoveryBudget                         = @LEArecoveryBudget,
	   hyQueueFee                                = @hyQueueFee,
	   planWriterFee                             = @planWriterFee,
	   baselineReimbursement                     = @baselineReimbursement,
       DATE_MODIFIED                             = @today,
       state                                     = @updateState,
       claim_TCM                                 = @claim_TCM,           
       claim_TCMEffectiveDate                    = @claim_TCMEffectiveDate,
       parentConsentAgreement                    = @parentConsentAgreement,
	   parentConsentAgreementEffectiveDate       = @parentConsentAgreementEffectiveDate,
       sendUsersEmailNotifications               = @sendUsersEmailNotifications,
       numDaysToHoldClientEnteredClaims          = @numDaysToHoldClientEnteredClaims,
       autoGenerate837File                       = @autoGenerate837File,
	   teleCommTeleHealthAccessGranted           = @teleCommTeleHealthAccessGranted,
	   teleCommTeleHealthAccessEndDate           = @teleCommTeleHealthAccessEndDate,
	   teleCommTeleIEPAccessGranted              = @teleCommTeleIEPAccessGranted,
	   teleCommTeleIEPAccessEndDate              = @teleCommTeleIEPAccessEndDate,
	   carePlanLegalLang                         = @carePlanLegalLang,
	   clientlogofiledata                        = @clientlogofiledata,
	   
	   cronTabExpectedTotPop                     = @cronTabExpectedTotPop,
       cronTabExpectedSpecEdSvcs                 = @cronTabExpectedSpecEdSvcs,
	   sendRequestsForTotPop                    = @sendRequestsForTotPop,
	   sendRequestsForSpEd                       = @sendRequestsForSpEd,
	   SELPACode                                 = @SELPACode,
	   sendElibilityDataMatchRequestsToDHCS      = @sendElibilityDataMatchRequestsToDHCS,
	   cdeComplianceClient                       = @cdeComplianceClient,
	   cybhi									 = @cybhi,
	   fuzzyMatchSitesByNameAndCode              = @fuzzyMatchSitesByNameAndCode,
	   cybhiClientCode							 = @cybhiClientCode,
	   initialContractStartDate                  = @initialContractStartDate,
	   healtheKids_percent                       = @healtheKids_percent,
	   cybhi_percent                             = @cybhi_percent,
       crcs_percent                              = @crcs_percent,
       cdeReporting_percent                      = @cdeReporting_percent,
       planImplementation_percent                = @planImplementation_percent,
       ruHealth_percent                          = @ruHealth_percent,
	   newProduct2_percent                       = @newProduct2_percent,
	   newProduct3_percent                       = @newProduct3_percent,
	   accounting_percent                        = @accounting_percent,
	   flatFee_amount                            = @flatFee_amount,

	   -- practiCal_percent                         = @practiCal_percent,
	   -- spEdCare_percent                          = @spEdCare_percent,

	   csba_percent                              = @csba_percent,
	   lba_percent                               = @lba_percent,
	   partner1_percent                          = @partner1_percent,
	   partner1E_percent                         = @partner1E_percent,
	   partner2_percent                          = @partner2_percent,
	   clientRetention                           = @clientRetention,
	   mba_bba_percent                           = @mba_bba_percent,
	   --mba_dg_percent                            = @mba_dg_percent,
	   spEdCare_bba_percent                      = @spEdCare_bba_percent,
	   --spEdCare_dg_percent                       = @spEdCare_dg_percent,
	   smaa_1_percent                            = @smaa_1_percent,
	   smaa_2_percent                            = @smaa_2_percent,
	   smaa_3_percent                            = @smaa_3_percent,
	   cybhiDoNotClaimOverappingLEABopSvcs       = @cybhiDoNotClaimOverappingLEABopSvcs,
	   cybhiAddOnMissingInfoRequestsToPatientPersons = @cybhiAddOnMissingInfoRequestsToPatientPersons,

       cybhiTpaApproved						     = @cybhiTpaApproved,
	   cybhiTpaApprovedOn						 = @cybhiTpaApprovedOn,

	   cybhiConsortiumBilling					 = @cybhiConsortiumBilling,
	   cybhiConsortiumLeadClientID				 = @cybhiConsortiumLeadClientID,
	   leaBopConsortiumBilling					 = @leaBopConsortiumBilling,
	   leaBopConsortiumLeadClientID				 = @leaBopConsortiumLeadClientID,
	 
	   cybhiTpaID								 = @cybhiTpaID,
	   cybhiSubmitClaims						 = @cybhiSubmitClaims,
	   impliedFerpaConsent						 = @impliedFerpaConsent,
	   cybhiClinicalSupervisorPracID			 = @cybhiClinicalSupervisorPracID,
	   cybhiClientName							 = @cybhiClientName,
	   cybhiNPI									 = @cybhiNPI,
	   cybhiTaxID								 = @cybhiTaxID,
	   cybhiAddress1							 = @cybhiAddress1,
	   cybhiAddress2							 = @cybhiAddress2,
	   cybhiCity								 = @cybhiCity,
	   cybhiState								 = @cybhiState,
	   cybhiZip5								 = @cybhiZip5,
	   cybhiZip4								 = @cybhiZip4,
	   cybhiGenerate837                          = @cybhiGenerate837,
       cybhiAutoGenerate837                      = @cybhiAutoGenerate837,
       cybhiNumDaysToHoldEnteredClaims           = @cybhiNumDaysToHoldEnteredClaims

     WHERE (CLIENT_ID  = @recID)    
     
     /*-------------------------------    
      * Service record approval options
      *------------------------------*/    
   
     /* Look for existing record */
     
     set @svcRecApprovalOptionRecID = null
     select @svcRecApprovalOptionRecID = id from dbo.SERVICE_RECORDS_APPROVAL_OPTIONS where clientID = @recID
   
     /* If there is one, update it */
     
     if (@svcRecApprovalOptionRecID is not null)
     begin
     
       update dbo.SERVICE_RECORDS_APPROVAL_OPTIONS 
       set approvalSystem = @svcRecApprovalSys 
       where id = @svcRecApprovalOptionRecID
     
       if (@svcRecApprovalSys = 0)
       begin
         /* If client requests opt out, update any held records that client entered indicating they want to release these */
         update dbo.SERVICE_RECORDS_APPROVAL 
         set clientReleased = 1, active = 0 
         where (clientID = @recID and svcRecCreatedByUserGroup = dbo.CONST_USER_GROUP_CLIENT())
       end     
       
     end
     else
     /* This is a new record*/
     begin
       INSERT INTO dbo.SERVICE_RECORDS_APPROVAL_OPTIONS (clientID, approvalSystem) values (@recID, @svcRecApprovalSys)
     end
   
   declare @planWriterID as bigint = null
   
   select top 1 
     @planWriterID = ID
   from dbo.PLAN_WRITER as pw 
   where (
       (pw.CLIENT_ID = @recID) 
   and (pw.ACTIVE    = 1)
   )
   
   /* No existing rec, create new */
   
   if (@planWriterID is null)
   begin
   
     insert into dbo.PLAN_WRITER (
         CLIENT_ID
       , ACCESS_GRANTED
       , END_DATE 
       , CREATED_BY
       , CREATED_ON
       , ACTIVE )
     values (
         @recID
       , @planWriterAccessGranted
       , @planWriterAccessEndDate
       , @userID
       , @today
       , 1
     )
   
     set @planWriterID = SCOPE_IDENTITY()
   end
   
   /* Modify existing */
   
   else
   begin
   
     update dbo.PLAN_WRITER
     set 
        ACCESS_GRANTED    = @planWriterAccessGranted
      , END_DATE          = @planWriterAccessEndDate
      , LAST_MODIFIED_BY  = @userID
      , LAST_MODIFIED_ON  = @today
     where (ID= @planWriterID)
   
   end
   
   /*-------------------------------    
      * CLIENT_Address
      *------------------------------*/    
  
    select @clientAddressRecID = ADDRESS_ID FROM dbo.CLIENTS_Address WHERE CLIENT_ID = @recID
      
    IF( @clientAddressRecID IS NOT NULL)
       
     UPDATE dbo.CLIENTS_Address
     SET
       ADDRESS_1     = @address1,
       ADDRESS_2     = @address2,
       CITY          = @city,
       STATE         = @state,
       ZIP           = @zip,
       ZIP_PLUS_FOUR = @zipPlusFour
     WHERE (CLIENT_ID = @recordID) 
     ELSE
      INSERT INTO dbo.CLIENTS_Address
	   (
		ADDRESS_1,
		ADDRESS_2,
		CITY,
		STATE,
		ZIP,
		ZIP_PLUS_FOUR,
		CLIENT_ID
	   )  
	   VALUES
	   (  
		@address1,
		@address2,
		@city,
		@state,
		@zip,
		@zipPlusFour,
		@recordID
	   )      
          
      /*-------------------------------    
      * CLIENT_Contact
      *------------------------------*/  
     select @clientContactRecID = CONTACT_ID from CLIENTS_Contact WHERE CLIENT_ID = @recID
  
     IF (@clientContactRecID IS NOT NULL)       
		 UPDATE dbo.CLIENTS_Contact
		 SET
		   CONTACT_LAST_NAME   = @contactLname,
		   CONTACT_FIRST_NAME  = @contactFname,
		   TITLE               = @contactTitle,
		   PHONE               = @contactPhone,       
		   EMAIL               = @contactEmail,
		   FAX                 = @contactFax
		 WHERE CLIENT_ID = @recID   
      ELSE
        INSERT INTO dbo.CLIENTS_Contact
	    (
		 CONTACT_LAST_NAME,
		 CONTACT_FIRST_NAME,
		 TITLE,
		 PHONE,
		 EMAIL,
		 CLIENT_ID,
		 FAX
		)    
		VALUES
		(
		 @contactLname,
		 @contactFname,
		 @contactTitle,
		 @contactPhone,
		 @contactEmail,
		 @recordID,
		 @contactFax
		)          		          
	      
   /*-------------------------------    
     * Edit CLIENT_Inputnote
     *------------------------------*/    
    SELECT @clientNoteRecID = INPUT_NOTE_CLIENT_ID 
      FROM dbo.CLIENTS_InputNote 
     WHERE INPUT_NOTE_CLIENT_ID = @recID
    
    IF(@clientNoteRecID IS NOT NULL)
      UPDATE DBO.CLIENTS_InputNote
      SET INPUT_NOTE = @notes
      WHERE (INPUT_NOTE_CLIENT_ID = @recID)  
    ELSE
      INSERT INTO dbo.CLIENTS_InputNote
      (
      INPUT_NOTE_CLIENT_ID,
      INPUT_NOTE
      )  
      VALUES
      (  
      @recordID,
      @notes
      )
     
    
  END    
  ELSE    
  BEGIN    
    RAISERROR ('Unknown save type', 11, 1)    
  END    
   
  /*-------------------------------    
   * Add public insurance request
   * form record if one does not
   * exist.
   *------------------------------*/    
  
  if not exists (
    select top 1 
	  t1.id 
    from dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS as t1
    where 
      ((t1.clientID = @recordID))
  )
  begin
    
	declare @publicInsuranceRequestFormPublicToken as varchar(512) = convert(varchar(256),@recordID) 
    
	select top 1
      @publicInsuranceRequestFormPublicToken = @publicInsuranceRequestFormPublicToken + gnui.NEW_UNIQUE_ID_STR_NO_DASH
    from GENERATE_NEW_UNIQUE_ID as gnui
    
	insert into dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS (
        clientID             
      , publicToken  
      , created   
      , createdBy
    )
    values (@recordID,@publicInsuranceRequestFormPublicToken,@today,@userID)
  end
  
  /*-------------------------------    
   * Add public referral mental health request
   * form record if one does not
   * exist.
   *------------------------------*/    
  
  if not exists (
    select top 1 
	  t1.id 
    from dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_REFERRAL_FORMS as t1
    where 
      ((t1.clientID = @recordID))
  )
  begin
    
	declare @publicReferralMentalHealthRequestFormPublicToken as varchar(512) = convert(varchar(256),@recordID) 
    
	select top 1
      @publicReferralMentalHealthRequestFormPublicToken = @publicReferralMentalHealthRequestFormPublicToken + gnui.NEW_UNIQUE_ID_STR_NO_DASH
    from GENERATE_NEW_UNIQUE_ID as gnui
    
	insert into dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_REFERRAL_FORMS (
        clientID             
      , publicToken  
      , created   
      , createdBy
    )
    values (@recordID,@publicReferralMentalHealthRequestFormPublicToken,@today,@userID)
  end

  /*-------------------------------    
   * Create initial or add new
   * practice family specific rules
   *------------------------------*/    

  insert into dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES (
      clientID                     
    , groupServiceClassNameID      
    , createdOn
    , createdBy
  )
  select 
      clientID = @recordID
    , png2.groupServiceClassNameID
    , createdOn = @today
    , createdBy = @userID
  from
  (
    select 
      png1.* 
    from 
    (
      select distinct 
        groupServiceClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID 
      from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png
      where 
        (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
    ) as png1
    where (
      png1.groupServiceClassNameID not in (
        select 
	      t1.groupServiceClassNameID 
	    from dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES as t1
        where 
          ((t1.clientID = @recordID) and (t1.groupServiceClassNameID = png1.groupServiceClassNameID))
      ) 
    )
  ) as png2
  
  /*-------------------------------    
   * Create audit record    
   *------------------------------*/    
   
   EXEC dbo.CLIENTS_Audit @recordID, @today, @userID, @saveType, @updateState, @editDelReason, @auditRecID OUTPUT    
      
       
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

GRANT EXECUTE ON  [dbo].[CLIENT_Save] TO [webuser]
GO
 
