using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * Client */
    /**
     **************************************************************************/

    public class Client : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"name asc";

        public string   CDS;
        public string   NPI;
        public string   tax_ID;
        public DateTime firstcheck;
        public DateTime lastcheck;
        public bool     approved_837;
        public bool     approved_835;
        public string   EIN;
        public bool     COE;
        public bool     LEA;
        public bool     MAA;
        public string   rvnsharectgLEA;
        public string   rvnsharectgMAA;
        public long     clrepidLEA;
        public string   clrepnameLEA;
        public long     clrepidMAA;
        public string   clrepnameMAA;
        public long     owndbycompidLEA;
        public string   companynameLEA;
        public long     owndbycompidMAA;
        public string   companynameMAA;
        public long     lecOrLgaID;
        public string   lecOrLgaName;
        public string   shortname;
        public string   namercgbyDHCS_EDS;
        public string   TCM_RATE;
        public string   LEARecoveryBudget;
        public string   hyQueueFee;
        public string   planWriterFee;
        public string   baselineReimbursement;
        public string   address1;      /* Client's address */
        public string   address2;
        public string   city;
        public string   state;
        public string   zip;
        public string   zipplusfour;
        public string   contactname;
        public string   contactlname;  /* Client's contact details */
        public string   contactfname;
        public string   contactTitle;
        public string   contactEmail;
        public string   contactPhone;
        public string   contactFax;
        public bool     svcRecApprovalSystem;
        public bool?     claimNoPlan;
        public DateTime  claimNoPlanEffectiveDate;
        public bool?     claim_TCM;
        public DateTime  claim_TCMEffectiveDate;
        public bool?     parentConsentAgreement;
        public DateTime  parentConsentAgreementEffectiveDate;
        public bool      sendUsersEmailNotifications;
        public bool      planWriterAccessGranted;
        public string    planWriterAccessGrantedStr;
        public DateTime  planWriterAccessEndDate;
        public string    planWriterAccessEndDateStr;
        public int       numDaysToHoldClientEnteredClaims;
        public bool      autoGenerate837File;
        public string    autoGenerate837FileStr;

        public bool      teleCommTeleHealthAccessGranted;
        public string    teleCommTeleHealthAccessGrantedStr;
        public DateTime  teleCommTeleHealthAccessEndDate;
        public string    teleCommTeleHealthAccessEndDateStr;

        public bool      teleCommTeleIEPAccessGranted;
        public string    teleCommTeleIEPAccessGrantedStr;
        public DateTime  teleCommTeleIEPAccessEndDate;
        public string    teleCommTeleIEPAccessEndDateStr;
        public string    carePlanLegalLang;
        public string    clientlogofiledata;
        
		public string    defaultMCALBillingConsentMsgText;

        public string    LEAYN;
        public string    MAAYN;
        public string    COEYN;
        public string    firstcheckStr;
        public string    lastcheckStr;
        public string    approved_837YN;
        public string    approved_835YN;
        public string    claimNoPlanYN;
        public string    claimNoPlanEffectiveDateStr;
        public string    claim_TCMYN;
        public string    claim_TCMEffectiveDateStr;
        public string    parentConsentAgreementYN;
        public string    parentConsentAgreementEffectiveDateStr;
        public bool      sendRequestsForTotPop;
        public string    sendRequestsForTotPopStr;
        public bool      sendRequestsForSpEd;
        public string    sendRequestsForSpEdStr;
        public long      cronTabExpectedTotPop;
        public long      cronTabExpectedSpecEdSvcs;        
        public long      SELPACode;        
        public string    SELPACodeAndName;        
        public bool      sendElibilityDataMatchRequestsToDHCS;
        public string    sendElibilityDataMatchRequestsToDHCSStr;
        public bool      cdeComplianceClient;
        public string    cdeComplianceClientStr;
        public bool      cybhi;
        public string    cybhiStr;
        public bool      fuzzyMatchSitesByNameAndCode;
        public string    fuzzyMatchSitesByNameAndCodeStr;
        public string    cybhiClientCode;
        public DateTime? initialContractStartDate;
        public decimal   healtheKids_percent; /* Change to Decimal */
        public decimal   cybhi_percent; /* Change to Decimal */
        public decimal   crcs_percent; /* Change to Decimal */
        public decimal   cdeReporting_percent; /* Change to Decimal */
        public decimal   total_percent; /* Change to Decimal */
        public decimal   planImplementation_percent; /* Change to Decimal */
        public decimal   ruHealth_percent; /* Change to Decimal */
        public decimal   newProduct2_percent; /* Change to Decimal */
        public decimal   newProduct3_percent; /* Change to Decimal */
        public decimal   accounting_percent; /* Change to Decimal all the way down to end */
        public decimal   flatFee_amount;

        //public decimal   practiCal_percent;
        //public decimal   spEdCare_percent;

        public decimal   csba_percent;
        public decimal   lba_percent;
        public decimal   partner1_percent;
        public decimal   partner1E_percent;
        public decimal   partner2_percent;
        public decimal   clientRetention;

        public decimal   mba_bba_percent;

        // public decimal   mba_dg_percent;


        public decimal   spEdCare_bba_percent;

        // public decimal   spEdCare_dg_percent;


        public decimal   smaa_1_percent;
        public decimal   smaa_2_percent;
        public decimal   smaa_3_percent;

        public bool      cybhiDoNotClaimOverappingLEABopSvcs;
        public bool      cybhiAddOnMissingInfoRequestsToPatientPersons;

        public bool?     cybhiTpaApproved;
        public DateTime? cybhiTpaApprovedOn;
        public string    cybhiTpaID;

        public bool      cybhiConsortiumBilling;
        public long      cybhiConsortiumLeadClientID;
        public bool      leaBopConsortiumBilling;
        public long      leaBopConsortiumLeadClientID;


        public bool      impliedFerpaConsent;
        public bool      cybhiSubmitClaims;

        public long      cybhiClinicalSupervisorPracID;
        public string    cybhiClinicalSupervisorPracName;
          
        public string    cybhiClientName;
        public string    cybhiNPI;
        public string    cybhiTaxID;
        public string    cybhiAddress1;
        public string    cybhiAddress2;
        public string    cybhiCity;
        public string    cybhiState;
        public string    cybhiZip5;
        public string    cybhiZip4;

        public bool	     cybhiGenerate837;
        public bool      cybhiAutoGenerate837;
        public int       cybhiNumDaysToHoldEnteredClaims;
    }

    /***************************************************************************
    * Clients */
    /**
    * Methods to manage clients (districts)
    ***************************************************************************/

    public class Clients : Entities
  {

      //public const string SEL_LABEL = "Clients"; // We are not actually using this, but maybe we should

    public const string SEL_LABEL_RPT_SPEDCARE_WEEKLY_REPORT            = "SpEdCare Weekly Report";
    public const string URL_SBS_ALL_RPT_SPEDCARE_WEEKLY_REPORT          = "rpt_spedcare_weekly.aspx";

    public const string SEL_LABEL_RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED   = "SpEdCare Weekly Report";
    public const string URL_SBS_ALL_RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED = "rpt_spedcare_weekly_extended.aspx";

    public const string SCREEN_TITLE_MANAGE       = "user_all_client_manage";
    public const string MENU_ID_VIEW              = "clients_view";
    public const string SEL_LABEL_MANAGE          = @"Manage Clients";
    public const string SEL_LABEL_VIEW            = @"Clients - View";
    
    public const string URL_VIEW_REPORT           = @"clients.ashx";
    public const string URL_USER_ALL_MANAGE       = @"user_all_client_manage.aspx";          
    public const string URL_USER_ALL_SAVE         = @"sbs_mgmt_client_save.aspx"; 
    public const string URL_USER_ALL_VIEW         = @"user_all_client_view.aspx";

    public const string MENU_ID_MANAGE            = @"clientsmanage";
    public const string URL_SVC_BASE              = @"clients.asmx";

    public const string URL_REST_VIEW             = @"api/v1/clients";
    public const string URL_SVC_DELETE_INLINE     = URL_SVC_BASE + @"/delete";
    public const string URL_SVC_VIEWSEL           = URL_SVC_BASE + @"/viewSel";

    public const string MENU_ID_MY_ORGANIZATION      = @"myorganizationlnk";
    public const string SEL_LABEL_MY_ORGANIZATION    = @"My Organization";
    public const string URL_USER_ALL_MY_ORGANIZATION = @"user_all_my_organization.aspx";

    /***************************************************************************
     * Rest view methods */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW_BASE()
    { 
       return MBA.HttpApplication.createLink(Clients.URL_REST_VIEW, true);
    }
    public static string URL_WEB_REPORT_BASE()
    { 
       return MBA.HttpApplication.createLink(Clients.URL_VIEW_REPORT, true);
    }

    /***************************************************************************
     * URL_SVC_DELETE_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_SVC_DELETE_INLINE_BASE()
    { 
       return MBA.HttpApplication.createLink(Clients.URL_SVC_DELETE_INLINE, true);
    }

    public static string URL_SVC_VIEWSEL_BASE()
    {
        return MBA.HttpApplication.createLink(Clients.URL_SVC_VIEWSEL, true);
    }

        /***************************************************************************
         * URL_SAVE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SAVE_BASE()
    { 
       return MBA.HttpApplication.createLink(Spedmon.Clients.URL_USER_ALL_SAVE, true);
    }

   /***************************************************************************
    * viewEntity */
   /**
    * Outputs data for a single client
    *
    * @param  connSpedmon     Spedmon database connection object
    * @param  log             Logging object
    * @param  id              Client ID
    * @return                 ReturnEntity
    ***************************************************************************/

    public static ReturnEntity viewEntity
      (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string clientID)
    {
      // TODO: Legacy remove

      ReturnEntity so = new ReturnEntity();
      Client c = load(connSpedmon, log, uInfo, clientID);
      so.entity = (Entity) c;
      return so;
   }

   /***************************************************************************
    * delete */
   /**
    * "Deletes" a client record
    *
    * @param  editDelReason   Reason for edit/delete
    * @param  validateRec     Perform validation for this record?
    * @param  recID           Record id reference for edit and delete
    * @return                 ReturnSaveNewRecord
    ***************************************************************************/

   public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                             string editDelReason, string validateRec, string recID)
    {
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

          List<SqlParameter> parms = new List<SqlParameter>();

          /*----------------------------
           * Call base method
           *----------------------------*/

          return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "CLIENTS_Delete",ref parms);
    }

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single client
     *
     * Note: This calls the view method.
     *
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ReturnEntity
     ***************************************************************************/

    public static Client load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     string recID)
    {
        return (Client)Entities.load(connSpedmon, log, uInfo, recID, typeof(Client),
        delegate { return Clients.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "","","","","",
                                       "", "", "", "","", "", null); });
    }

    /***************************************************************************
     * save */
    /**
     * Save a client record
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientName      Client's name
     * @param  clientCDS
     * @param  tax_ID
     * @param  NPI
     * @param  firstcheck
     * @param  lastcheck
     * @param  approved_837
     * @param  approved_835
     * @param  EIN
     * @param  COE
     * @param  LEA
     * @param  MAA
     * @param  address1        Clients address1
     * @param  address2        Clients address2
     * @param  city
     * @param  state
     * @param  zip
     * @param  zipplusfour
     * @param  contactlname
     * @param  contactfname
     * @param  contacttitle
     * @param  contactphone
     * @param  contactfax
     * @param  contactemail
     * @param  notes
     * @param  claimNoPlan                  Claim "No Plan" Services (Free Care)
     * @param  claimNoPlanEffectiveDate     Date for claiming "No Plan" Services (Free Care)
     * @param  claim_TCM                    Claim TCM for reimbursement
     * @param  claim_TCMEffectiveDate       Date for claiming TCM for reimbursement
     * @param  editDelReason                Reason for record edit or delete
     * @param  validateRec                  1 = Performs data integrity validation tasks
     *                                          Perform advisory validation tasks that can
     *                                          only be conducted by referencing data from the
     *                                          database and then exits WITHOUT saving the record
     *                                      0 = Peform data integrity validation tasks and
     *                                          if these tasks succeed peforms the desired
     *                                          operation (saveType) on the record and exits
     * @param  saveType                     Type of operation to perform
     *                                      1 = New, 2 = Edit, 3 = Delete
     * @param  recID                        Record id of existing client record to edit or
     *                                      delete.
     * @return                              ReturnSaveNewRecord
     ***************************************************************************/

    public static ReturnSaveRecord save(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                        string clientName,
                                        string clientCDS,
                                        string NPI,
                                        string tax_ID,
                                        string firstcheck,
                                        string approved_837,
                                        string approved_835,
                                        string EIN,
                                        string COE,
                                        string LEA,
                                        string MAA,
                                        string rvnsharectgLEA,
                                        string rvnsharectgMAA,
                                        string clrepIDLEA,
                                        string clrepIDMAA,
                                        string owndbycompIDLEA,
                                        string owndbycompIDMAA,
                                        string lecOrLgaID,
                                        string shortname,
                                        string nameRcgByDHCS_EDS,
                                        string LEARecoveryBudget,
                                        string address1,
                                        string address2,
                                        string city,
                                        string state,
                                        string zip,
                                        string zipPlusFour,
                                        string contactlname,
                                        string contactfname,
                                        string contacttitle,
                                        string contactphone,
                                        string contactfax,
                                        string contactemail,
                                        string svcRecApprovalSystem,
                                        string notes,
                                        string claim_TCM,
                                        string claim_TCMEffectiveDate,
                                        string parentConsentAgreement,
                                        string parentConsentAgreementEffectiveDate,
                                        string sendUsersEmailNotifications,
                                        string planWriterAccessGranted,
                                        string planWriterAccessEndDate,
                                        string numDaysToHoldClientEnteredClaims,
                                        string autoGenerate837File,
                                        string teleCommTeleHealthAccessGranted,
                                        string teleCommTeleHealthAccessEndDate,
                                        string teleCommTeleIEPAccessGranted,
                                        string teleCommTeleIEPAccessEndDate,
                                        string hyQueueFee,
                                        string planWriterFee,
                                        string baselineReimbursement,
                                        string carePlanLegalLang,
                                        string clientlogofiledata,
                                        string cronTabExpectedTotPop,
                                        string cronTabExpectedSpecEdSvcs,
                                        string sendRequestsForTotPop,
                                        string sendRequestsForSpEd,
                                        string SELPACode,
                                        string sendElibilityDataMatchRequestsToDHCS,
                                        string cdeComplianceClient,
                                        string cybhi,
                                        string fuzzyMatchSitesByNameAndCode,
                                        string cybhiClientCode,
                                        string initialContractStartDate,
                                        string healtheKids_percent,
                                        string cybhi_percent,
                                        string crcs_percent,
                                        string cdeReporting_percent,
                                        string planImplementation_percent,
                                        string ruHealth_percent,
                                        string newProduct2_percent,
                                        string newProduct3_percent,
                                        string accounting_percent,
                                        string flatFee_amount,

                                        //string practiCal_percent,
                                        //string spEdCare_percent,

                                        string csba_percent,
                                        string lba_percent,
                                        string partner1_percent,
                                        string partner1E_percent,
                                        string partner2_percent,
                                        string clientRetention,

                                            string mba_bba_percent,

                                            //string mba_dg_percent,

                                            string spEdCare_bba_percent,

                                            //string spEdCare_dg_percent,

                                            string smaa_1_percent,
                                            string smaa_2_percent,
                                            string smaa_3_percent,

                                        string cybhidonotclaimoverappingleabopsvcs,
                                        string cybhiaddonmissinginforequeststopatientpersons,

                                        string cybhiconsortiumbilling,
                                        string cybhiconsortiumleadClientID,
                                        string leabopconsortiumbilling,
                                        string leabopconsortiumLeadClientID,

                                        string cybhiTpaApproved,
                                        string cybhiTpaApprovedOn,
                                        string cybhiTpaID,

                                        string cybhiSubmitClaims,
                                        string cybhiClinicalSupervisorPracid,
                                        string impliedFerpaConsent,

                                        string cybhiClientName,
                                        string cybhiNPI,
                                        string cybhiTaxID,
                                        string cybhiAddress1,
                                        string cybhiAddress2,
                                        string cybhiCity,
                                        string cybhiState,
                                        string cybhiZip5,
                                        string cybhiZip4,
                                        string cybhiGenerate837,
                                        string cybhiAutoGenerate837,
                                        string cybhiNumDaysToHoldEnteredClaims,
                                        
                                        string editDelReason,
                                        string validateRec,
                                        string saveType,
                                        string recID
                                        
                                        )
    {

      /*----------------------------
       * Check for required and
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      string   vname                                       = Validate.reqString               (clientName,                         Messages.INVALID_CLIENT_NAME);
      string   vNPI                                        = Validate.optNPI                  (NPI,                                Messages.INVALID_NPI);
      string   vclientCDS                                  = Validate.reqCDSDistrict          (clientCDS,                          Messages.INVALID_CDS);
      string   vEIN                                        = Validate.optString               (EIN,                                Messages.INVALID_EIN);
      bool     vCOE                                        = Validate.reqFlag                 (COE,                                Messages.INVALID_COE_FLAG);
      bool     vLEA                                        = Validate.reqFlag                 (LEA,                                Messages.INVALID_LEA_FLAG);
      bool     vMAA                                        = Validate.reqFlag                 (MAA,                                Messages.INVALID_MAA_FLAG);
      object   vfcheck                                     = Validate.optDate                 (firstcheck,                         Messages.INVALID_START_DATE);
      string   vtaxID                                      = Validate.optString               (tax_ID,                             Messages.INVALID_TAXID);
      bool     vapprov837                                  = Validate.reqFlag                 (approved_837,                       Messages.INVALID_APPROVED_837_FLAG);
      bool     vapprov835                                  = Validate.reqFlag                 (approved_835,                       Messages.INVALID_APPROVED_835_FLAG);
      string   vrvnsharectgLEA                             = Validate.optString               (rvnsharectgLEA,                     Messages.INVALID_REVENUE_SHARING_CATEGORY);
      string   vrvnsharectgMAA                             = Validate.optString               (rvnsharectgMAA,                     Messages.INVALID_REVENUE_SHARING_CATEGORY);
      object   vclrepIDLEA                                 = Validate.optInteger              (clrepIDLEA,                         Messages.INVALID_REP_ID,true);
      object   vclrepIDMAA                                 = Validate.optInteger              (clrepIDMAA,                         Messages.INVALID_REP_ID,true);
      object   vowndbycompIDLEA                            = Validate.reqInteger              (owndbycompIDLEA,                    Messages.INVALID_COMPANY_ID,true);
      object   vowndbycompIDMAA                            = Validate.reqInteger              (owndbycompIDMAA,                    Messages.INVALID_COMPANY_ID,true);
      var      vLecOrLgaID                                 = Validate.optInteger              (lecOrLgaID,                         Messages.INVALID_LEC_OR_LGA, true);

      string   vshortname                                  = Validate.reqString               (shortname,                          Messages.INVALID_SHORT_NAME);
      string   vnameRcgByDHCS_EDS                          = Validate.optString               (nameRcgByDHCS_EDS,                  Messages.INVALID_NAME_RCG_BY_DHCS_EDS);
      Object   vLEARecoveryBudget                          = Validate.optUsdAmount            (LEARecoveryBudget,                  @"Invalid LEA recovery budget amount");
      string   vaddress1                                   = Validate.optString               (address1,                           Messages.INVALID_ADDRESS);
      string   vaddress2                                   = Validate.optString               (address2,                           Messages.INVALID_ADDRESS);
      string   vcity                                       = Validate.optString               (city,                               Messages.INVALID_ADDRESS);
      string   vstate                                      = Validate.optString               (state,                              Messages.INVALID_ADDRESS);
      string   vzip                                        = Validate.optZip5                 (zip,                                Messages.INVALID_ZIP);
      object   vzipplusfour                                = Validate.optZip4                 (zipPlusFour,                        Messages.INVALID_ZIP);
      string   vclname                                     = Validate.optString               (contactlname,                       Messages.INVALID_LNAME);
      string   vcfname                                     = Validate.optString               (contactfname,                       Messages.INVALID_FNAME);
      string   vctitle                                     = Validate.optString               (contacttitle,                       Messages.INVALID_FNAME);
      Object   vcEmail                                     = Validate.optEmail                (contactemail,                       Messages.INVALID_EMAIL);
      Object   vcPhone                                     = Validate.optPhoneNumber          (contactphone,                       Messages.INVALID_PHONE_NUMBER);
      Object   vcFax                                       = Validate.optPhoneNumber          (contactfax,                         Messages.INVALID_PHONE_NUMBER);
      Object   vSvcRecApprovalSys                          = Validate.optFlag                 (svcRecApprovalSystem,               Messages.INVALID_SVC_REC_APPROVAL_SYS);
      Object   vNotes                                      = Validate.optString               (notes,                              Messages.INVALID_NOTES);
      object   vclaim_TCM                                  = Validate.reqFlagOrUnknown        (claim_TCM,                          Messages.INVALID_CLAIM_TCM);
      DateTime vclaim_TCMEffectiveDate                     = Validate.reqDate                 (claim_TCMEffectiveDate,             Messages.INVALID_CLAIM_TCM_EFF_DATE);
      object   vparentConsentAgreement                     = Validate.reqFlagOrUnknown        (parentConsentAgreement,             Messages.INVALID_PARENT_AGREE);
      DateTime vparentConsentAgreementEffectiveDate        = Validate.reqDate                 (parentConsentAgreementEffectiveDate,Messages.INVALID_PARENT_AGREE_EFF_DATE);
      bool     vSendUsersEmailNotifications                = Validate.reqFlag                 (sendUsersEmailNotifications,        @"Invalid value for send users email notifications");
      bool     vPlanWriterAccessGranted                    = Validate.reqFlag                 (planWriterAccessGranted,            @"Invalid value for plan writer access granted");
      Object   vPlanWriterAccessEndDate                    = Validate.optDate                 (planWriterAccessEndDate,            @"Invalid plan writer end date");
      int      vNumDaysToHoldClientEnteredClaims           = Validate.reqInteger              (numDaysToHoldClientEnteredClaims,   @"Invalid number of days to hold client entered claims",true);
      bool     vAutoGenerate837File                        = Validate.reqFlag                 (autoGenerate837File,                @"Invalid auto generate 837 flag");
      bool     vTeleCommTeleHealthAccessGranted            = Validate.reqFlag                 (teleCommTeleHealthAccessGranted,    @"Invalid telehealth access granted flag");
      Object   vTeleCommTeleHealthAccessEndDate            = Validate.optDate                 (teleCommTeleHealthAccessEndDate,    @"Invalid telehealth access end date");

      bool     vTeleCommTeleIEPAccessGranted               = Validate.reqFlag                 (teleCommTeleIEPAccessGranted,       @"Invalid teleiep access granted flag");
      Object   vTeleCommTeleIEPAccessEndDate               = Validate.optDate                 (teleCommTeleIEPAccessEndDate,       @"Invalid teleiep access end date");

      Object   vHyQueueFee                                 = Validate.optUsdAmount            (hyQueueFee,                         @"Invalid HyQueue fee amount");
      Object   vPlanWriterFee                              = Validate.optUsdAmount            (planWriterFee,                      @"Invalid plan writer fee amount");
      Object   vBaselineReimbursement                      = Validate.optUsdAmount            (baselineReimbursement,              @"Invalid baseline reimbursement amount");
      string   vCarePlanLegalLang                          = Validate.optString               (carePlanLegalLang,                  @"Invalid care plan legal language");
      string   vClientlogofiledata                         = Validate.optBase64String         (clientlogofiledata,                 @"Invalid logo file");
      long     vCronTabExpectedTotPop                      = Validate.reqInteger              (cronTabExpectedTotPop,              @"Invalid schedule selection for totpop file");
      long     vCronTabExpectedSpecEdSvcs                  = Validate.reqInteger              (cronTabExpectedSpecEdSvcs,          @"Invalid schedule selection for speded file");
      bool     vSendRequestsForTotPop                      = Validate.reqFlag                 (sendRequestsForTotPop,              @"Invalid send requests for totpop flag");
      bool     vSendRequestsForSpEd                        = Validate.reqFlag                 (sendRequestsForSpEd,                @"Invalid send requests for sped flag");
      var      vSELPACode                                  = Validate.optInteger              (SELPACode,                          @"Invalid SELPA", true);      
      bool     vSendElibilityDataMatchRequestsToDHCS       = Validate.reqFlag                 (sendElibilityDataMatchRequestsToDHCS, @"Invalid send elibility requests to DHCS flag", true);
      bool     vCdeComplianceClient                        = Validate.reqFlag                 (cdeComplianceClient,                  @"Invalid CDE compliance client flag",           true);
      bool     vCybhi                                      = Validate.reqFlag                 (cybhi,                                @"Invalid CYBHI flag",                           true);

      bool     vCybhiSubmitClaims                          = Validate.reqFlag                 (cybhiSubmitClaims,                    @"Invalid cybhiSubmitClaims flag",               true);
      Object vCybhiClinicalSupervisorPracid                = Validate.optInteger              (cybhiClinicalSupervisorPracid,        @"Invalid cybhiClinicalSupervisorPracid",        true);
      bool     vImpliedFerpaConsent                        = Validate.reqFlag                 (impliedFerpaConsent,                  @"Invalid impliedFerpaConsent flag",             true);

      bool     vFuzzyMatchSitesByNameAndCode               = Validate.reqFlag                 (fuzzyMatchSitesByNameAndCode,         @"Invalid fuzzyMatchSitesByNameAndCode flag",    true);
      string   vCybhiClientCode                            = Validate.optString               (cybhiClientCode,                      @"Invalid CYBHI client code.");
      Object   vinitialContractStartDate                   = Validate.optDate                 (initialContractStartDate,             @"Invalid InitialContractStartDate.");
      Object   vhealtheKids_percent                        = Validate.optUsdAmount            (healtheKids_percent,                  @"Invalid HealtheKids.");
      Object   vcybhi_percent                              = Validate.optUsdAmount            (cybhi_percent,                        @"Invalid cybhi_percent.");
      Object   vcrcs_percent                               = Validate.optUsdAmount            (crcs_percent,                         @"Invalid crcs_percent.");
      Object   vcdeReporting_percent                       = Validate.optUsdAmount            (cdeReporting_percent,                 @"Invalid cdeReporting_percent.");
      Object   vplanImplementation_percent                 = Validate.optUsdAmount            (planImplementation_percent,           @"Invalid  planImplementation_percent.");
      Object   vruHealth_percent                           = Validate.optUsdAmount            (ruHealth_percent,                     @"Invalid  ruHealth_percent.");
      Object   vnewProduct2_percent                        = Validate.optUsdAmount            (newProduct2_percent,                  @"Invalid  newProduct2_percent.");
      Object   vnewProduct3_percent                        = Validate.optUsdAmount            (newProduct3_percent,                  @"Invalid  newProduct3_percent.");
      Object   vaccounting_percent                         = Validate.optUsdAmount            (accounting_percent,                   @"Invalid  accounting_percent.");
      Object   vflatFee_amount                             = Validate.optUsdAmount            (flatFee_amount,                       @"Invalid  flatFee_amount.");

      //Object   vpractiCal_percent                          = Validate.optUsdAmount            (practiCal_percent,                    @"Invalid  practiCal_percent.");
      //Object   vspEdCare_percent                           = Validate.optUsdAmount            (spEdCare_percent,                     @"Invalid  spEdCare_percent.");

      Object   vcsba_percent                               = Validate.optUsdAmount            (csba_percent,                         @"Invalid  csba_percent.");
      Object   vlba_percent                                = Validate.optUsdAmount            (lba_percent,                          @"Invalid  lba_percent.");
      Object   vpartner1_percent                           = Validate.optUsdAmount            (partner1_percent,                     @"Invalid  partner1_percent.");
      Object   vpartner1E_percent                          = Validate.optUsdAmount            (partner1E_percent,                    @"Invalid  partner1E_percent.");
      Object   vpartner2_percent                           = Validate.optUsdAmount            (partner2_percent,                     @"Invalid  partner2_percent.");
      Object   vclientRetention                            = Validate.optUsdAmount            (clientRetention,                      @"Invalid  clientRetention.");

      Object   vMBA_BBA_Percent                            = Validate.optUsdAmount            (mba_bba_percent,                      @"Invalid  MBA_BBA_Percent .");

      //Object   vMBA_DG_Percent                             = Validate.optUsdAmount            (mba_dg_percent,                       @"Invalid  MBA_DG_Percent.");

      Object   vSpEdCare_BBA_Percent                       = Validate.optUsdAmount            (spEdCare_bba_percent,                 @"Invalid  SpEdCare_BBA_Percent.");

      //Object   vSpEdCare_DG_Percent                        = Validate.optUsdAmount            (spEdCare_dg_percent,                  @"Invalid  SpEdCare_DG_Percent .");

      Object   vSMAA_1_Percent                             = Validate.optUsdAmount            (smaa_1_percent,                       @"Invalid  SMAA_1_Percent .");
      Object   vSMAA_2_Percent                             = Validate.optUsdAmount            (smaa_2_percent,                       @"Invalid  SMAA_2_Percent .");
      Object   vSMAA_3_Percent                             = Validate.optUsdAmount            (smaa_3_percent,                       @"Invalid  SMAA_3_Percent .");                                 

      bool    vCybhiDoNotClaimOverappingLEABopSvcs           = Validate.reqFlag               (cybhidonotclaimoverappingleabopsvcs,           @"Invalid  cybhidonotclaimoverappingleabopsvcs.");
      bool    vCybhiAddOnMissingInfoRequestsToPatientPersons = Validate.reqFlag               (cybhiaddonmissinginforequeststopatientpersons, @"Invalid  cybhiaddonmissinginforequeststopatientpersons.");
      
      object  vcybhiconsortiumbilling                        = Validate.reqFlag               (cybhiconsortiumbilling,                        @"Invalid cybhiconsortiumbilling");
      object  vcybhiconsortiumleadClientID                   = Validate.optInteger            (cybhiconsortiumleadClientID,                   @"Invalid cybhiconsortiumleadClientID", true);
      object  vleabopconsortiumbilling                       = Validate.reqFlag               (leabopconsortiumbilling,                       @"Invalid leabopconsortiumbilling");
      object  vleabopconsortiumLeadClientID                  = Validate.optInteger            (leabopconsortiumLeadClientID,                  @"Invalid leabopconsortiumLeadClientID", true);

      Object  vCybhiTpaApproved                              = Validate.reqFlag               (cybhiTpaApproved,                              @"Invalid cybhiTpaApproved");
      var     vCybhiTpaApprovedOn                            = Validate.optDate               (cybhiTpaApprovedOn,                            @"Invalid cybhiTpaApprovedOn");
      Object  vCybhiTpaID                                    = Validate.optString             (cybhiTpaID,                                    @"Invalid cybhiTpaID");


      string vCybhiClientName                                = Validate.optString             (cybhiClientName,                              @"Invalid CYBHI client name");
      string vCybhiNPI                                       = Validate.optString             (cybhiNPI,                                     @"Invalid CYBHI NPI");
      string vCybhiTaxID                                     = Validate.optString             (cybhiTaxID,                                   @"Invalid CYBHI tax ID");
      string vCybhiAddress1                                  = Validate.optString             (cybhiAddress1,                                @"Invalid CYBHI address 1");
      string vCybhiAddress2                                  = Validate.optString             (cybhiAddress2,                                @"Invalid CYBHI address 2");
      string vCybhiCity                                      = Validate.optString             (cybhiCity,                                    @"Invalid CYBHI city");
      string vCybhiState                                     = Validate.optString             (cybhiState,                                   @"Invalid CYBHI state");
      string vCybhiZip5                                      = Validate.optZip5               (cybhiZip5,                                    @"Invalid CYBHI zip5");
      object vCybhiZip4                                      = Validate.optZip4               (cybhiZip4,                                    @"Invalid CYBHI zip4");

      var vCybhiGenerate837                = Validate.reqFlag   (cybhiGenerate837,     @"A valid value for CYBHI generate 837 must be provided",        true);
      var vCybhiAutoGenerate837            = Validate.reqFlag   (cybhiAutoGenerate837, @"A valid value for CYBHI autogenerate 837 must be provided",    true);
      var vCybhiNumDaysToHoldEnteredClaims = Validate.reqInteger(cybhiNumDaysToHoldEnteredClaims,@"A valid value for number of days to hold CYBHI claims must be provided", true);
      if (vCybhiNumDaysToHoldEnteredClaims < 0) { vCybhiNumDaysToHoldEnteredClaims = 0; } 


            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * save method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientName",                SqlDbType.VarChar,  vname,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@NPI",                       SqlDbType.VarChar,  vNPI,                ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@clientCDS",                 SqlDbType.VarChar,  vclientCDS,          ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@tax_ID",                    SqlDbType.VarChar,  vtaxID,              ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@first_check",               SqlDbType.DateTime, vfcheck,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@COE",                       SqlDbType.Bit,      vCOE,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@LEA",                       SqlDbType.Bit,      vLEA,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@MAA",                       SqlDbType.Bit,      vMAA,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@rvnsharectgLEA",            SqlDbType.VarChar,  vrvnsharectgLEA,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@rvnsharectgMAA",            SqlDbType.VarChar,  vrvnsharectgMAA,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clrepIDLEA",                SqlDbType.Int,      vclrepIDLEA,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clrepIDMAA",                SqlDbType.Int,      vclrepIDMAA,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@owndbycompIDLEA",           SqlDbType.Int,      vowndbycompIDLEA,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@owndbycompIDMAA",           SqlDbType.Int,      vowndbycompIDMAA,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@lecOrLgaID",                SqlDbType.BigInt,   vLecOrLgaID,         ParameterDirection.Input));

      parms.Add(Database.SqlParm("@shortname",                 SqlDbType.VarChar,  vshortname,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@nameRcgbyDHCS_EDS",         SqlDbType.VarChar,  vnameRcgByDHCS_EDS,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@LEARecoveryBudget",         SqlDbType.Decimal,  vLEARecoveryBudget,  ParameterDirection.Input));

      parms.Add(Database.SqlParm("@approved_837",              SqlDbType.Bit,      vapprov837,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@approved_835",              SqlDbType.Bit,      vapprov835,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@EIN",                       SqlDbType.VarChar,  vEIN,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@address1",                  SqlDbType.VarChar,  vaddress1,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@address2",                  SqlDbType.VarChar,  vaddress2,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@city",                      SqlDbType.VarChar,  vcity,               ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@state",                     SqlDbType.VarChar,  vstate,              ParameterDirection.Input, 14));
      parms.Add(Database.SqlParm("@zip",                       SqlDbType.VarChar,  vzip,                ParameterDirection.Input, 14));
      parms.Add(Database.SqlParm("@zipPlusFour",               SqlDbType.VarChar,  vzipplusfour,        ParameterDirection.Input, 14));
      parms.Add(Database.SqlParm("@contactLname",              SqlDbType.VarChar,  vclname,             ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@contactFname",              SqlDbType.VarChar,  vcfname,             ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@contactTitle",              SqlDbType.VarChar,  vctitle,             ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@contactemail",              SqlDbType.VarChar,  vcEmail,             ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@contactphone",              SqlDbType.VarChar,  vcPhone,             ParameterDirection.Input, 14));
      parms.Add(Database.SqlParm("@contactfax",                SqlDbType.VarChar,  vcFax,               ParameterDirection.Input, 14));
      parms.Add(Database.SqlParm("@svcRecApprovalSys",         SqlDbType.Bit,      vSvcRecApprovalSys,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@notes",                     SqlDbType.NVarChar, vNotes,              ParameterDirection.Input, -1));

      parms.Add(Database.SqlParm("@claim_TCM",                 SqlDbType.Bit,      vclaim_TCM,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@claim_TCMEffectiveDate",    SqlDbType.DateTime, vclaim_TCMEffectiveDate,     ParameterDirection.Input));

      parms.Add(Database.SqlParm("@parentConsentAgreement",                SqlDbType.Bit,      vparentConsentAgreement,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@parentConsentAgreementEffectiveDate",   SqlDbType.DateTime, vparentConsentAgreementEffectiveDate,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@sendUsersEmailNotifications",           SqlDbType.Bit,      vSendUsersEmailNotifications,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planWriterAccessGranted",               SqlDbType.Bit,      vPlanWriterAccessGranted,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planWriterAccessEndDate",               SqlDbType.Date,     vPlanWriterAccessEndDate,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@numDaysToHoldClientEnteredClaims",      SqlDbType.Int,      vNumDaysToHoldClientEnteredClaims,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@autoGenerate837File",                   SqlDbType.Bit,      vAutoGenerate837File,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@teleCommTeleHealthAccessGranted",       SqlDbType.Bit,      vTeleCommTeleHealthAccessGranted,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@teleCommTeleHealthAccessEndDate",       SqlDbType.Date,     vTeleCommTeleHealthAccessEndDate,      ParameterDirection.Input));

      parms.Add(Database.SqlParm("@teleCommTeleIEPAccessGranted",    SqlDbType.Bit,      vTeleCommTeleIEPAccessGranted,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@teleCommTeleIEPAccessEndDate",    SqlDbType.Date,     vTeleCommTeleIEPAccessEndDate,       ParameterDirection.Input));

      parms.Add(Database.SqlParm("@hyQueueFee",                      SqlDbType.Money,    vHyQueueFee,                         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planWriterFee",                   SqlDbType.Money,    vPlanWriterFee,                      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@baselineReimbursement",           SqlDbType.Money,    vBaselineReimbursement,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@carePlanLegalLang",               SqlDbType.VarChar,  vCarePlanLegalLang,                  ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@clientlogofiledata",              SqlDbType.VarChar,  vClientlogofiledata,                 ParameterDirection.Input, -1));
    
      parms.Add(Database.SqlParm("@cronTabExpectedTotPop",           SqlDbType.BigInt,  vCronTabExpectedTotPop,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cronTabExpectedSpecEdSvcs",       SqlDbType.BigInt,  vCronTabExpectedSpecEdSvcs,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@sendRequestsForTotPop",           SqlDbType.Bit,     vSendRequestsForTotPop,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@sendRequestsForSpEd",             SqlDbType.Bit,     vSendRequestsForSpEd,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@SELPACode",                       SqlDbType.BigInt,  vSELPACode,                          ParameterDirection.Input));

      parms.Add(Database.SqlParm("@sendElibilityDataMatchRequestsToDHCS",  SqlDbType.Bit,  vSendElibilityDataMatchRequestsToDHCS,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cdeComplianceClient",                   SqlDbType.Bit,  vCdeComplianceClient,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhi",                                 SqlDbType.Bit,  vCybhi,                                 ParameterDirection.Input));

      parms.Add(Database.SqlParm("@impliedFerpaConsent",                   SqlDbType.Bit,  vImpliedFerpaConsent,                   ParameterDirection.Input));

      parms.Add(Database.SqlParm("@fuzzyMatchSitesByNameAndCode",          SqlDbType.Bit,  vFuzzyMatchSitesByNameAndCode,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiClientCode",                       SqlDbType.VarChar, vCybhiClientCode,                    ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@initialContractStartDate",              SqlDbType.Date, vinitialContractStartDate,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@healtheKids_percent",                   SqlDbType.Money, vhealtheKids_percent,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhi_percent",                         SqlDbType.Money, vcybhi_percent,                        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@crcs_percent",                          SqlDbType.Money, vcrcs_percent,                         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cdeReporting_percent",                  SqlDbType.Money, vcdeReporting_percent,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planImplementation_percent",            SqlDbType.Money, vplanImplementation_percent,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@ruHealth_percent",                      SqlDbType.Money, vruHealth_percent,                     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@newProduct2_percent",                   SqlDbType.Money, vnewProduct2_percent,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@newProduct3_percent",                   SqlDbType.Money, vnewProduct3_percent,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@accounting_percent",                    SqlDbType.Money, vaccounting_percent,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@flatFee_amount",                        SqlDbType.Money, vflatFee_amount,                       ParameterDirection.Input));

      //parms.Add(Database.SqlParm("@practiCal_percent",                     SqlDbType.Money, vpractiCal_percent,                    ParameterDirection.Input));
      //parms.Add(Database.SqlParm("@spEdCare_percent",                      SqlDbType.Money, vspEdCare_percent,                     ParameterDirection.Input));

      parms.Add(Database.SqlParm("@csba_percent",                          SqlDbType.Money, vcsba_percent,                         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@lba_percent",                           SqlDbType.Money, vlba_percent,                          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@partner1_percent",                      SqlDbType.Money, vpartner1_percent,                     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@partner1E_percent",                     SqlDbType.Money, vpartner1E_percent,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@partner2_percent",                      SqlDbType.Money, vpartner2_percent,                     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clientRetention",                       SqlDbType.Money, vclientRetention,                      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@mba_bba_percent",                       SqlDbType.Money, vMBA_BBA_Percent,                      ParameterDirection.Input));

      //parms.Add(Database.SqlParm("@mba_dg_percent",                        SqlDbType.Money, vMBA_DG_Percent,                       ParameterDirection.Input));

      parms.Add(Database.SqlParm("@spEdCare_bba_percent",                  SqlDbType.Money, vSpEdCare_BBA_Percent,                 ParameterDirection.Input));

      //parms.Add(Database.SqlParm("@spEdCare_dg_percent",                   SqlDbType.Money, vSpEdCare_DG_Percent,                  ParameterDirection.Input));

      parms.Add(Database.SqlParm("@smaa_1_percent",                        SqlDbType.Money, vSMAA_1_Percent,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@smaa_2_percent",                        SqlDbType.Money, vSMAA_2_Percent,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@smaa_3_percent",                        SqlDbType.Money, vSMAA_3_Percent,                       ParameterDirection.Input));

      parms.Add(Database.SqlParm("@cybhiDoNotClaimOverappingLEABopSvcs",           SqlDbType.Bit,     vCybhiDoNotClaimOverappingLEABopSvcs,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiAddOnMissingInfoRequestsToPatientPersons", SqlDbType.Bit,     vCybhiAddOnMissingInfoRequestsToPatientPersons, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiTpaApproved",                              SqlDbType.Bit,     vCybhiTpaApproved,                              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiTpaApprovedOn",                            SqlDbType.Date,    vCybhiTpaApprovedOn,                            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiTpaID",                                    SqlDbType.VarChar, vCybhiTpaID,                                    ParameterDirection.Input, 256));

      parms.Add(Database.SqlParm("@cybhiConsortiumBilling",                        SqlDbType.Bit,     vcybhiconsortiumbilling,                        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiConsortiumLeadClientID",                   SqlDbType.BigInt,  vcybhiconsortiumleadClientID,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@leaBopConsortiumBilling",                       SqlDbType.Bit,     vleabopconsortiumbilling,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@leaBopConsortiumLeadClientID",                  SqlDbType.BigInt,  vleabopconsortiumLeadClientID,                  ParameterDirection.Input));

      parms.Add(Database.SqlParm("@cybhiSubmitClaims",                             SqlDbType.Bit,     vCybhiSubmitClaims,                             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiClinicalSupervisorPracid",                 SqlDbType.BigInt,   vCybhiClinicalSupervisorPracid,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiClientName",                               SqlDbType.NVarChar, vCybhiClientName,                              ParameterDirection.Input, 100));
      parms.Add(Database.SqlParm("@cybhiNPI",                                      SqlDbType.NChar,    vCybhiNPI,                                     ParameterDirection.Input, 10));
      parms.Add(Database.SqlParm("@cybhiTaxID ",                                   SqlDbType.NChar,    vCybhiTaxID,                                   ParameterDirection.Input, 10));
      parms.Add(Database.SqlParm("@cybhiAddress1",                                 SqlDbType.NVarChar, vCybhiAddress1,                                ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@cybhiAddress2",                                 SqlDbType.NVarChar, vCybhiAddress2,                                ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@cybhiCity",                                     SqlDbType.NVarChar, vCybhiCity,                                    ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@cybhiState",                                    SqlDbType.NVarChar, vCybhiState,                                   ParameterDirection.Input, 10));
      parms.Add(Database.SqlParm("@cybhiZip5",                                     SqlDbType.NVarChar, vCybhiZip5,                                    ParameterDirection.Input, 5));
      parms.Add(Database.SqlParm("@cybhiZip4",                                     SqlDbType.NVarChar, vCybhiZip4,                                    ParameterDirection.Input, 5));
   
      parms.Add(Database.SqlParm("@cybhiGenerate837",                              SqlDbType.Bit, vCybhiGenerate837,                                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiAutoGenerate837",                          SqlDbType.Bit, vCybhiAutoGenerate837,                              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiNumDaysToHoldEnteredClaims",               SqlDbType.Int, vCybhiNumDaysToHoldEnteredClaims,                   ParameterDirection.Input));
                                       
      parms.Add(Database.SqlParm("@MsgNoGroup",                            SqlDbType.VarChar,  Messages.INVALID_GROUP_ID,           ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoFullEdit",                         SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT_FULL,      ParameterDirection.Input, 1000));

            /*----------------------------
             * Call base method with
             * the new parms and the
             * pre database call validate
             * delegate
             *----------------------------*/

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "CLIENT_Save", Messages.DUP_CLIENT_REC, ref parms, null);
    }

    /***************************************************************************
     * view */
    /**
     * Returns a list of Clients
     *
     ***************************************************************************/

    public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                 int    recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string activelea,
                                 string activemaa,
                                 string firstCheck,
                                 string lastCheck,
                                 string approved837,
                                 string approved835,
                                 string rvnsharectgLEA,
                                 string rvnsharectgMAA,
                                 string repIDLEA,
                                 string compIDLEA,
                                 string compIDMAA,
                                 string active,
                                 string clientname,
                                 defineCols dc)
    {
        /*----------------------------
         * Validate parameters specific
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

        List<SqlParameter> parms = new List<SqlParameter>();

        string viewUDF = "dbo.CLIENTS_VIEW(@userID, @userGroup, @userRank, @recID, @clientName, @first_check, @last_check, @activeLEA, @activeMAA, @rvnsharectgLEA, " +
                         "@rvnsharectgMAA, @approved_837, @approved_835, @clrepIDLEA, @owndbycompIDLEA, @owndbycompIDMAA, @active, @canEdit)";

        Object vClientname      = Validate.optString (clientname);
        Object vActiveLEA       = Validate.optFlag   (activelea,      Messages.INVALID_LEA_FLAG);
        Object vActiveMAA       = Validate.optFlag   (activemaa,      Messages.INVALID_MAA_FLAG);
        Object vApprov837       = Validate.optFlag   (approved837,    Messages.INVALID_FLAG_ACTIVE);
        Object vApprov835       = Validate.optFlag   (approved835,    Messages.INVALID_FLAG_ACTIVE);
        object vfcheck          = Validate.optDate   (firstCheck,     Messages.INVALID_START_DATE);
        object vlcheck          = Validate.optDate   (lastCheck,      Messages.INVALID_START_DATE);
        string vrvnsharectgLEA  = Validate.optString (rvnsharectgLEA, Messages.INVALID_REVENUE_SHARING_CATEGORY);
        string vrvnsharectgMAA  = Validate.optString (rvnsharectgMAA, Messages.INVALID_REVENUE_SHARING_CATEGORY);
        object vclrepIDLEA      = Validate.optInteger(repIDLEA,       Messages.INVALID_REP_ID,     true);
        object vowndbycompIDLEA = Validate.optInteger(compIDLEA,      Messages.INVALID_COMPANY_ID, true);
        object vowndbycompIDMAA = Validate.optInteger(compIDMAA,      Messages.INVALID_COMPANY_ID, true);

        parms.Add(Database.SqlParm("@clientName",      SqlDbType.NVarChar,  vClientname,      ParameterDirection.Input));
        parms.Add(Database.SqlParm("@activeLEA",       SqlDbType.Bit,       vActiveLEA,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@activeMAA",       SqlDbType.Bit,       vActiveMAA,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@first_check",     SqlDbType.DateTime,  vfcheck,          ParameterDirection.Input));
        parms.Add(Database.SqlParm("@last_check",      SqlDbType.DateTime,  vlcheck,          ParameterDirection.Input));
        parms.Add(Database.SqlParm("@rvnsharectgLEA",  SqlDbType.VarChar,   vrvnsharectgLEA,  ParameterDirection.Input));
        parms.Add(Database.SqlParm("@rvnsharectgMAA",  SqlDbType.VarChar,   vrvnsharectgMAA,  ParameterDirection.Input));
        parms.Add(Database.SqlParm("@approved_837",    SqlDbType.Bit,       vApprov837,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@approved_835",    SqlDbType.Bit,       vApprov835,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@clrepIDLEA",      SqlDbType.Int,       vclrepIDLEA,      ParameterDirection.Input));
        parms.Add(Database.SqlParm("@owndbycompIDLEA", SqlDbType.Int,       vowndbycompIDLEA, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@owndbycompIDMAA", SqlDbType.Int,       vowndbycompIDMAA, ParameterDirection.Input));

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }

   /***************************************************************************
    * viewSel */
   /**
    * Returns a list of clients
    *
    ***************************************************************************/

   public static ReturnSel viewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string term)
   {

     /*----------------------------
      * Define our context column
      *----------------------------*/

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){
         ss.addDisplayColumn("dbo.BIT_TO_MSG(ISNULL(CLAIM_TCM,1), '', '** TCM -- DO NOT BILL FOR TCM -- TCM ** | ') + dbo.BIT_TO_MSG(LEA,'','Inactive LEA | ') + cds as context1");
        // ss.addDisplayColumn("dbo.BIT_TO_MSG(ISNULL(CLAIM_TCM,1), '', '** TCM -- DO NOT BILL FOR TCM -- TCM ** | ') + cds as context1");
     };

     /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

     ReturnSel rs = Entities.viewSel(connSpedmon, log, uInfo ,top, topSize,
     delegate{return Clients.view (connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, "", "", "", "", "", "", "", "","","","","", "", term, dc);});

     return rs;

   }

   /***************************************************************************
    * viewSelWithPcal */
   /**
    * Returns a list of clients including dummy record for practi-cal
    *
    ***************************************************************************/

   public static ReturnSel viewSelWithPcal (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string term)
   {

      ReturnSel rs = viewSel (connSpedmon, log, uInfo, top, topSize, term);

      List<SelRec> sl = new List<SelRec>();

      SelRec pcalSel = new SelRec();

      pcalSel.id       = 0;
      pcalSel.label    = "Practi-Cal";
      pcalSel.context1 = @"Practi-Cal's internal ""dummy"" client record";
      pcalSel.value    = "Practi-Cal";;

      sl.Add(pcalSel);

      if (rs.SelRecs != null)
      {
        foreach (SelRec sr in rs.SelRecs)
        {
          sl.Add(sr);
        }
      }

      rs.SelRecs = sl.ToArray();

      return rs;
   }

    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

      public static ReturnDataTable viewTbl(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                          bool   paged,
                                          string pageNumber,
                                          string clientname,
                                          string canEdit,
                                          string active,
                                          string activelea,
                                          string activemaa,
                                          string firstCheck,
                                          string lastCheck,
                                          string approved_837,
                                          string approved_835,
                                          string rvnsharectgLEA,
                                          string rvnsharectgMAA,
                                          string clrepIDLEA,
                                          string owndbycompIDLEA,
                                          string owndbycompIDMAA,
                                          string viewNotes)
      {

      bool     vDisplayNotes                               = Validate.reqFlag               (viewNotes,                          Messages.INVALID_VIEW_NOTES);
          /*----------------------------
           * Define our columns and
           * set the page order for
           * paging
           *----------------------------*/

          defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
          {

              ss.addDisplayColumn("id");


              // TODO: Remove if these will not be needed

              //ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(active) as [Is Active]");
              //ss.addDisplayColumnIfParmValueIsNull ("dbo.RPT_BIT_TO_YN(LEA) as [LEA]", "@activeLEA", ref parms);
              //ss.addDisplayColumnIfParmValueIsNull ("dbo.RPT_BIT_TO_YN(MAA) as [MAA]", "@activeMAA", ref parms);

              ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(LEA) as [LEA]");
              ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(MAA) as [MAA]");

              ss.addDisplayColumn("name                              as [Client Name]", true);
              ss.addDisplayColumn("CDS                               as [CDS]");
              ss.addDisplayColumn("NPI                               as [NPI]");
              ss.addDisplayColumn("tax_ID                            as [Tax ID]");
              ss.addDisplayColumn("blank                             as [---]");
              ss.addDisplayColumn("firstcheck                        as [Date of First Check]");
              ss.addDisplayColumn("lastcheck                         as [Date of Last Check]");
              ss.addDisplayColumn("approved_837                      as [Approved 837]");
              ss.addDisplayColumn("approved_835                      as [Approved 835]");
              ss.addDisplayColumn("EIN");
              ss.addDisplayColumn("COE");
              ss.addDisplayColumn("rvnsharectgLEA                    as [Revenue Sharing category LEA Current?]");
              ss.addDisplayColumn("rvnsharectgMAA                    as [Revenue Sharing category MAA Current?]");
              ss.addDisplayColumn("clrepnameLEA                      as [Client Rep LEA?]");
              ss.addDisplayColumn("clrepnameMAA                      as [Client Rep MAA?]");
              ss.addDisplayColumn("shortname                         as [Short Name]");
              ss.addDisplayColumn("namercgbyDHCS_EDS                 as [Name Officially recognized by DHCS & EDS]");
              ss.addDisplayColumn("TCM_RATE                          as [TCM Rate]");
              ss.addDisplayColumn("LEARecoveryBudget                 as [LEA Recovery Budget]");
              ss.addDisplayColumn("address1                          as [Address 1]");
              ss.addDisplayColumn("address2                          as [Address 2]");
              ss.addDisplayColumn("city                              as [City]");
              ss.addDisplayColumn("state                             as [State]");
              ss.addDisplayColumn("zip                               as [Zip 5]");
              ss.addDisplayColumn("zipplusfour                       as [Zip 4]");
              ss.addDisplayColumn("contactname                       as [Contact Name]");
              ss.addDisplayColumn("contactTitle                      as [Contact Title]");
              ss.addDisplayColumn("contactPhone                      as [Contact Area Code and Phone Number]");
              ss.addDisplayColumn("contactFax                        as [Contact Fax Number]");
              ss.addDisplayColumn("contactEmail                      as [Contact Email]");

              ss.addDisplayColumn("dbo.RPT_BIT_TO_YNU(claimNoPlan)   as [Bill Free Care (no plan)?]");
              ss.addDisplayColumn("claimNoPlanEffectiveDate          as [Bill Free Care Eff Date]");
              ss.addDisplayColumn("dbo.RPT_BIT_TO_YNU(claim_TCM)     as [Claim TCM?]");
              ss.addDisplayColumn("claim_TCMEffectiveDate            as [Claim TCM Eff Date]");
              ss.addDisplayColumn("parentConsentAgreement            as [Parental Consent Agreement]");
              ss.addDisplayColumn("parentConsentAgreementEffectiveDate      as [Parental Consent Agreement Effective Date]");

              ss.addDisplayColumn("cdeComplianceClientStr as [Uses\nOur\nCDE\nCompliance\nModule?]");
              ss.addDisplayColumn("cybhiStr as [Uses\nOur\nCybhi\nModule?]");
              ss.addDisplayColumn("fuzzyMatchSitesByNameAndCodeStr as [Use\nFuzzy\nMatching\nBy Name\nand Code\nFor\nSchool\nSites?]");
              ss.addDisplayColumn("cybhiClientCode as [Cybhi\nClient\nCode]");
              ss.addDisplayColumn("initialContractStartDate as [Initial\nContract\nStart\nDate]");
              ss.addDisplayColumn("healtheKids_percent as [Health\ne\nKids\nPercentage]");
              ss.addDisplayColumn("cybhi_percent as [CYBH\nPercentage]");
              ss.addDisplayColumn("crcs_percent as [CRCS\nPercentage]");
              ss.addDisplayColumn("cdeReporting_percent as [CDEReporting\nPercentage]");
              ss.addDisplayColumn("total_percent as [Total\nPercentage]");
              ss.addDisplayColumn("planImplementation_percent as [PlanImplementation\nPercentage]");
              ss.addDisplayColumn("ruHealth_percent as [RU\nHealth\nPercentage]");
              ss.addDisplayColumn("newProduct2_percent as [New\nProduct\n2\nPercentage]");
              ss.addDisplayColumn("newProduct3_percent as [New\nProduct\n3\nPercentage]");
              ss.addDisplayColumn("accounting_percent as  [Accounting\nPercentage]");
              ss.addDisplayColumn("flatFee_amount as  [FlatFee\nAmount]");

              //ss.addDisplayColumn("practiCal_percent as  [PractiCal\nPercentage]");
              //ss.addDisplayColumn("spEdCare_percent as  [SpEdCare\nPercentage]");

              ss.addDisplayColumn("csba_percent as  [CSBA\nPercentage]");
              ss.addDisplayColumn("lba_percent as  [LBA\nPercentage]");
              ss.addDisplayColumn("partner1_percent as  [Partner1\nPercentage]");
              ss.addDisplayColumn("partner1E_percent as  [Partner1E\nPercentage]");
              ss.addDisplayColumn("partner2_percent as  [Partner2\nPercentage]");
              ss.addDisplayColumn("clientRetention as  [ClientRetention]");

              ss.addDisplayColumn("mba_bba_percent  as  [MBA\nBBA\nPercent]");

              //ss.addDisplayColumn("mba_dg_percent   as  [MBA\nDG\nPercent]");

              ss.addDisplayColumn("spEdCare_bba_percent  as  [spEdCare\nBBA\nPercent]");

              //ss.addDisplayColumn("spEdCare_dg_percent   as  [spEdCare\nDG\nPercent]");

              ss.addDisplayColumn("smaa_1_percent   as   [SMAA\n1\nPercent]");
              ss.addDisplayColumn("smaa_2_percent   as   [SMAA\n2\nPercent]");
              ss.addDisplayColumn("smaa_3_percent   as   [SMAA\n3\nPercent]");


              if (vDisplayNotes == true) {
                  ss.addDisplayColumn("notes as [Notes]");
              }


              ss.addDisplayColumn("id              as ClientID");

              pageroworder = ss.pageRowOrder();

          };

          string tableName   = @"Clients - View";
          string tableFooter = Messages.CONFIDENTIAL;

          /*----------------------------
           * Call base method which
           * handles the rest and return
           * results
           *----------------------------*/

          return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
            delegate { return Clients.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, activelea, activemaa, firstCheck, lastCheck, approved_835,approved_837,rvnsharectgLEA,rvnsharectgMAA,clrepIDLEA,owndbycompIDLEA,owndbycompIDMAA,active,clientname,dc); }
            , tableName
            , tableFooter
            );
      }

     /***************************************************************************
      * viewList */
     /**
      * 
      ***************************************************************************/                                                                  
    public static List<Client> viewList (  SqlConnection connSpedmon
                                          , DetailsLog    log
                                          , UserInfo      uInfo ) 
    {
      
      var listItems = new List<Client>();

      bool hasRecords = false;
      
      Object[] recs = loadAllRecords (   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof (Client)
                                      , delegate { 
                                        return Clients.view (  connSpedmon
                                                              , log
                                                              , uInfo
                                                              , Entities.REC_VIEW_ALL
                                                              , false
                                                              , ""
                                                              , ""
                                                              , ""
                                                              ,""
                                                              ,""
                                                              ,""
                                                              ,""
                                                              ,""
                                                              ,""
                                                              ,""
                                                              ,""
                                                              ,""
                                                              ,""
                                                              ,""
                                                              ,""
                                                              ,null);
                                      }
                                     , out hasRecords);
    
      if (hasRecords == true)
      {
        foreach (Object rec in recs) {
          Client listItem = (Client) rec;
          listItems.Add(listItem);
        }
      }
      return listItems;
    }             
    
      /***************************************************************************
       * rptSpEdCareWeeklyReport */
      /**
       * Returns a data table of records for preview or record selection.
       *
       * @return                 ReturnDataTable
       ***************************************************************************/

      public static ReturnDataTable rptSpEdCareWeeklyReport(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                          bool paged,
                                          string pageNumber,
                                          string clientID,
                                          string asOfDate,
                                          string canEdit, // this param is not used anywhere, AFAIK.  Considering removing.
                                          string repID,
                                          string active
                                                        )
      {

          List<SqlParameter> prms = new List<SqlParameter>();

          /*
           * We have parameters coming in as strings, some of which are empty.  How do we build a dynamic SQL query, with multiple optional (nullable) parameters of different data types, in a
           * strongly-typed language that does not allow for truthy-falsy if-statements?
           *
           * Like this.
           */

          Object vClientID = Validate.optClientID      (uInfo,    clientID);
          Object vAsOfDate = Validate.optDate          (asOfDate, Messages.INVALID_START_DATE);
          Object vRepID    = Validate.optInteger       (repID,    Messages.INVALID_REP_ID);
          Object vActive   = Validate.optFlagYNUnknown (active,   Messages.INVALID_BOOL);

          prms.Add(Database.SqlParm("@clientID",    SqlDbType.BigInt,   vClientID, ParameterDirection.Input));
          prms.Add(Database.SqlParm("@asOfDate",    SqlDbType.Date,     vAsOfDate, ParameterDirection.Input));
          prms.Add(Database.SqlParm("@repID",       SqlDbType.BigInt,   vRepID,    ParameterDirection.Input));
          prms.Add(Database.SqlParm("@leaIsActive", SqlDbType.Bit,      vActive,   ParameterDirection.Input));

          string reportUDF = "dbo.RPT_SPEDCARE_WEEKLY_REPORT (@asOfDate, @clientID, @repID, @leaIsActive)";

          /*----------------------------
           * Define our columns and
           * set the page order for
           * paging
           *----------------------------*/

          defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
          {

              ss.addDisplayColumn("[District Rep]");
              ss.addDisplayColumn("[SpEdCare Client ID #]");
              ss.addDisplayColumn("[Active ?]");
              ss.addDisplayColumn("[CDS Code]");
              ss.addDisplayColumn("[Client Name]", true);
              ss.addDisplayColumn("BudgetTargetThisYr as [Budget Target\nThis Year\n($500 per Mcal Patient)]");

              //ss.addDisplayColumn("CliGot3FYAgo as [$ Client Got\n- 3 FY Ago -\nFor Current Work]");

              //ss.addDisplayColumn("[c27(_col_label)]");

              //ss.addDisplayColumn("c27");

              //ss.addDisplayColumn("[c24(_col_label)]");

              //ss.addDisplayColumn("c24");

              //ss.addDisplayColumn("Cli2FYAgo as [$ Client Got\n- 2 FY Ago -\nFor Current Work]");

              ss.addDisplayColumn("[c22(_col_label)]");

              ss.addDisplayColumn("c22");

              //ss.addDisplayColumn("[c19(_col_label)]");

              //ss.addDisplayColumn("c19");

              //ss.addDisplayColumn("Cli1FYAgo as [$ Client Got\n- 1 FY Ago -\nFor Current Work]");

              ss.addDisplayColumn("[c17(_col_label)]");

              ss.addDisplayColumn("c17");

              //ss.addDisplayColumn("[c14(_col_label)]");

              //ss.addDisplayColumn("c14");

              ss.addDisplayColumn("[c12(_col_label)]");

              ss.addDisplayColumn("c12");

              //ss.addDisplayColumn("[c9(_col_label)]");

              //ss.addDisplayColumn("c9");

              ss.addDisplayColumn("[c7(_col_label)]");

              ss.addDisplayColumn("c7");

              //ss.addDisplayColumn("[c4(_col_label)]");

              //ss.addDisplayColumn("c4");

              //ss.addDisplayColumn("CliGotCurrentFY as [$ Client Got\n- Current FY -\nFor Current Work]");

              ss.addDisplayColumn("NumSvcsLast30 as [Number of Services\nEntered in spEdCare\nby Clients Last 30 Days]");

              ss.addDisplayColumn("NumSvcsThisFY as [Number of Services\nEntered This Year]");

              ss.addDisplayColumn("LastDateTransmitted as [Last Date Claims\nWere Transmitted]");

              ss.addDisplayColumn("AmtInvoicedThisWk as [Amount Invoiced to\nClient This Week]");

              ss.addDisplayColumn("LastInvoiceDate as [Last Invoice Date\nFor Client]");

              //ss.addDisplayColumn("OK_TO_REPORT_UP_TO_DATE as [Reports Believed to Be Current Until]");

              /* page row order - very important */
              pageroworder = ss.pageRowOrder();
          };

          string tableName = "SpEdCare Weekly Report";
          if (asOfDate != null && asOfDate.Trim() != "")
              tableName += " - As Of " + asOfDate;
          string tableFooter = Messages.CONFIDENTIAL;

          /*----------------------------
           * Call base method which
           * handles the rest and return
           * results
           *----------------------------*/

          return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc
            , tableName
            , tableFooter
            );
      }

      /***************************************************************************
       * rptSpEdCareWeeklyReportExtended */
      /**
       * Returns a data table of records for preview or record selection.
       *
       * @return                 ReturnDataTable
       ***************************************************************************/

      public static ReturnDataTable rptSpEdCareWeeklyReportExtended (  SqlConnection connSpedmon
                                                                     , DetailsLog    log
                                                                     , UserInfo      uInfo
                                                                     , bool          paged
                                                                     , string        pageNumber
                                                                     , string        canEdit
                                                                     , string        active )
      {

        DateTime vToday = DateTime.Today;
        DateTime vStartOfCurrWeek;
        DateTime vEndOfCurrWeek;
        DateTime vStartOfPrevWeek;
        DateTime vEndOfPrevWeek;

        Util.calculateStartEndOfWeekDates   (  vToday
                                             , DayOfWeek.Sunday
                                             , out vStartOfCurrWeek
                                             , out vEndOfCurrWeek
                                             , out vStartOfPrevWeek
                                             , out vEndOfPrevWeek );

         List<SqlParameter> prms = new List<SqlParameter>();

         prms.Add(Database.SqlParm("@today",       SqlDbType.DateTime,   vToday,            ParameterDirection.Input));
         prms.Add(Database.SqlParm("@startWeek",   SqlDbType.DateTime,   vStartOfPrevWeek,  ParameterDirection.Input));
         prms.Add(Database.SqlParm("@endWeek",     SqlDbType.DateTime,   vEndOfPrevWeek,    ParameterDirection.Input));

         string reportUDF = "dbo.RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED (@today, @startWeek, @endWeek)";

         /*----------------------------
          * Define our columns and
          * set the page order for
          * paging
          *----------------------------*/

         defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
         {

           ss.addDisplayColumn("CLIENT_REP   as [District Rep]");
           ss.addDisplayColumn("CLIENT_ID    as [SpEdCare Client ID #]");
           ss.addDisplayColumn("CLIENT_NAME  as [Client Name]", true);

           ss.addDisplayColumn("[FY1_TOT_DISB]           as [Last FY - Total]");
           ss.addDisplayColumn("[FY1_TOT_STATE_FEES]     as [Last FY - State Adjustments]");
           ss.addDisplayColumn("[FY1_TOT_SVCS]           as [Last FY - Services]");

           ss.addDisplayColumn("[FY0_TOT_DISB]           as [This FY - Total]");
           ss.addDisplayColumn("[FY0_TOT_STATE_FEES]     as [This FY - State Adjustments]");
           ss.addDisplayColumn("[FY0_TOT_SVCS]           as [This FY - Services]");

           ss.addDisplayColumn("[CurrentWorkComparedToPrevious]                              as [This Year amount for current work COMPARED to Last Year amount for current work]");
           ss.addDisplayColumn("[NUM_SVCS_ENTERED_ALL_USERS_THIS_WEEK]                       as [Number of Services Entered This Week]");
           ss.addDisplayColumn("[NUM_SVCS_ENTERED_ALL_USERS_THIS_YEAR]                       as [Number of Services Entered This Year]");
           ss.addDisplayColumn("[RMTS Moments Not Matched]                                   as [Number of RMTS Moments Not Matched To Date]");
           ss.addDisplayColumn("[LAST_TX_DATE]                                               as [Last Date Claims Were Transmitted]");

           ss.addDisplayColumn("[Previous Year - Date of Service]                            as [Amount - Previous Year - Date of Service]");
           ss.addDisplayColumn("[Current Year - Date of Service]                             as [Amount - Current Year - Date of Service]");

           ss.addDisplayColumn("[Missing Orders for DOS]                                     as [Amount - Missing Orders and Missing Orders for DOS]");
           ss.addDisplayColumn("[Transportation Missing Eligible Services]                   as [Amount - Transportation - Missing Eligible Service]");
           ss.addDisplayColumn("[Missing ORP Professional]                                   as [Amount - Missing ORP Professional]");
           ss.addDisplayColumn("[No Medi-Cal Consent]                                        as [Amount - No Medi-Cal Consent]");
           ss.addDisplayColumn("[Patient Set to Do Not bill]                                 as [Amount - Patient set to do not bill]");
           ss.addDisplayColumn("[Practitioner Set to Do Not bill]                            as [Amount - Practitioner set to do not bill]");
           ss.addDisplayColumn("[Journal Not Closed or Waiting For Supervised Approval]      as [Amount - Journal Not Closed or Waiting For Supervised Approval]");
           ss.addDisplayColumn("[Practitioner Not In RMTS]                                   as [Amount - Practitioner Not In RMTS]");
           ss.addDisplayColumn("[Missing Supervision]                                        as [Amount - Missing Supervision]");
           ss.addDisplayColumn("[Missing Assessments]                                        as [Amount - Missing Assessments]");
           
           /*ss.addDisplayColumn("[Type of Client]                                             as [Type of Client]");*/
     
           ss.addDisplayColumn("[Promised Services Prior Year]                               as [Promised Services Prior Year]");
           ss.addDisplayColumn("[Promised Services Current Year]                             as [Promised Services Current Year]");
           ss.addDisplayColumn("[Promised Services Past 12 Months]                           as [Promised Services Past 12 Months]");

           pageroworder = ss.pageRowOrder();
         };

          /*----------------------------
           * Call base method which
           * handles the rest and return
           * results
           *----------------------------*/

          ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc);

          rd.tableName = vToday.ToYYYYMMDDString()
                       + @" "
                       + @"SpEdCare Weekly Report (Extended)"
                       + @" For Week "
                       + vStartOfPrevWeek.ToYYYYMMDDString()
                       + @" to "
                       + vEndOfPrevWeek.ToYYYYMMDDString();

          rd.tableFooter   = Messages.CONFIDENTIAL;
          rd.useTemplates  = false;
         
          return rd;

      }


    // TODO: We eventually want to have this functionality implemented under Spedmon.Reports instead of Spedmon.Entities.  This report has -nothing- to do
      /* with any particular client (does not even have a filter-rows-by-client-id option), so conceptually there is no reason to want to have this
       as a method for class Clients; O.O.P. #fail

       As far as I understand, we are temporarily putting it under the Clients class because we want to use the Entities.viewRpt() method, which is protected.
       It would be too spaghetti-ish to change it to public and then reach-for it from outside the class.  But we eventually want to have a Spedmon.Reports.WorkBatches
       class, modeled after Spedmon.Reports.Financial, I'm told.

       TODO:  Consider implementing a "Reportable" interface, and/or a ReportGenerator decorator or dependency.  That way, we can have any class capable of creating
       reports from data it has access to, regardless of whether or not the class is an Entity, or what namespace it was created in.

       Some possibly-relevant notes:

       * on composition, dependancy injection: https://stackoverflow.com/a/4077721
       * on decorators in C#: https://www.codeproject.com/Articles/479635/UnderstandingplusandplusImplementingplusDecoratorp
       * another example on decorators: https://www.infoworld.com/article/3072938/application-development/how-to-work-with-the-decorator-design-pattern-in-c.html

       */

      public const string SEL_LABEL_RPT_BATCHES_ASSIGNED_NOT_DONE   = "List of Batches Assigned but Not Done";
      public const string URL_SBS_ALL_RPT_BATCHES_ASSIGNED_NOT_DONE = "rpt_batches_assigned_not_done.aspx";

      /***************************************************************************
       * rptBatchesAssignedNotDoneReport */
      /**
       * Returns a data table of records for preview or record selection.
       *
       * @return                 ReturnDataTable
       ***************************************************************************/

      public static ReturnDataTable rptBatchesAssignedNotDone(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                          bool paged,
                                          string pageNumber,
                                          string consultantID,
                                          string lastAssignedID
                                                        )
      {

          List<SqlParameter> prms = new List<SqlParameter>();

          Object vConsultantID = Validate.optInteger(consultantID, "Invalid consultant identifier; try again");
          Object vLastAssignedID = Validate.optInteger(lastAssignedID, "Invalid identifer for last assigned user; try again"); // validation required, wip

          prms.Add(Database.SqlParm("@consultantID", SqlDbType.BigInt, vConsultantID, ParameterDirection.Input));
          prms.Add(Database.SqlParm("@lastAssignedID", SqlDbType.BigInt, vLastAssignedID, ParameterDirection.Input)); //validation required, wip

          string reportUDF = "dbo.RPT_BATCHES_ASSIGNED_NOT_DONE (@consultantID, @lastAssignedID)";

          /*----------------------------
           * Define our columns and
           * set the page order for
           * paging
           *----------------------------*/

          defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
          {

              ss.addDisplayColumn("id");

              //ss.addDisplayColumn("Section");

              ss.addDisplayColumn("[Last Assigned to]", true);

              ss.addDisplayColumn("[Current Status Code]");

              ss.addDisplayColumn("[Current Status Description] as [Current Status\nDescription]");

              ss.addDisplayColumn("[Status Date]");

              ss.addDisplayColumn("[Date Received]");

              ss.addDisplayColumn("[Oldest DOS]");

              ss.addDisplayColumn("[File Name]");

              ss.addDisplayColumn("[Type of Work]");

              ss.addDisplayColumn("[Practi-Cal Consultant]");

              /* page row order - very important */
              pageroworder = ss.pageRowOrder();
          };

          string tableName = "Batches - Assigned, Not Done";
          string tableFooter = Messages.CONFIDENTIAL;

          /*----------------------------
           * Call base method which
           * handles the rest and return
           * results
           *----------------------------*/

          //return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc
          //  , tableName
          //  , tableFooter
          //  );

          ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc
, Clients.SEL_LABEL_RPT_BATCHES_ASSIGNED_NOT_DONE
, tableFooter);

          rd.useTemplates = true;
          rd.excelTemplate = new ExcelFileTempateInfo();
          rd.excelTemplate.templateFileName = @"TER04-0 Batches Assigned but NOT DONE.xls";
          //rd.excelTemplate.postPopulationProcessing = true;
          rd.excelTemplate.forceFormulaRecalculate = true;
          rd.excelTemplate.collapseRowGroups = false;
          rd.excelTemplate.collapseColGroups = false;
          rd.excelTemplate.limitToPhysicalCells = false;

          rd.excelTemplate.setDataCellRegion( 2        /* Starting row*/
                                            , 199      /* Ending row*/
                                            , @"A"     /* Starting column */
                                            , @"J");   /* Ending column */

          return rd;
      }

      /* TODO: This method does not (really) pertain to clients.  This method should be placed under Spedmon.Reports.WorkBatches - see comment above */

      public const string SEL_LABEL_RPT_BATCHES_IN_PROCESS = "List of All Batches In Process by Batch Status";
      public const string URL_SBS_ALL_RPT_BATCHES_IN_PROCESS = "rpt_batches_in_process.aspx";

      /***************************************************************************
       * rptBatchesInProcess */
      /**
       * Returns a data table of records for preview or record selection.
       *
       * @return                 ReturnDataTable
       ***************************************************************************/

      public static ReturnDataTable rptBatchesInProcess(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                          bool paged,
                                          string pageNumber,
                                          string cliID,
                                          string consultantID,
                                          string currentStatus,
                                          string lastAssignedID
                                                        )
      {
          List<SqlParameter> prms = new List<SqlParameter>();

          Object vCliID = Validate.optClientID(uInfo, cliID);
          Object vConsultantID = Validate.optInteger(consultantID, "Invalid identifer for client consultant; try again"); //TODO: create utility function for validating a consultantID
          Object vLastAssignedID = Validate.optInteger(lastAssignedID, "Invalid identifer for last assigned user; try again"); // TODO: and likewise
          Object vCurrentStatus = Validate.optInteger(currentStatus, "Invalid value for Current Status filtering");

          prms.Add(Database.SqlParm("@cliID", SqlDbType.BigInt, vCliID, ParameterDirection.Input));
          prms.Add(Database.SqlParm("@consultantID", SqlDbType.BigInt, vConsultantID, ParameterDirection.Input));
          prms.Add(Database.SqlParm("@lastAssignedID", SqlDbType.Int, vLastAssignedID, ParameterDirection.Input));
          prms.Add(Database.SqlParm("@currentStatus", SqlDbType.Int, vCurrentStatus, ParameterDirection.Input));

          string reportUDF = "dbo.RPT_BATCHES_IN_PROCESS(@cliID,@consultantID,@lastAssignedID,@currentStatus)";


          defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
          {
              ss.addDisplayColumn("[Batch ID]", true);
              ss.addDisplayColumn("[Current Status Code]");
              ss.addDisplayColumn("[Current Status Description] as [Current Status\nDescription]");
              ss.addDisplayColumn("[Date Received]");
              ss.addDisplayColumn("[Oldest DOS]");
              ss.addDisplayColumn("[File Name]");
              ss.addDisplayColumn("[Type of Work]");
              ss.addDisplayColumn("[Last Assigned to]");
              ss.addDisplayColumn("[Status Date]");
              ss.addDisplayColumn("[Practi-Cal Consultant]");

              /* page row order - very important */
              pageroworder = ss.pageRowOrder();
          };

          ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc);


          rd.tableName   = DateTime.Today.ToYYYYMMDDString()
                         + " "
                         + SEL_LABEL_RPT_BATCHES_IN_PROCESS;

          rd.tableFooter   = Messages.CONFIDENTIAL;
          rd.useTemplates  = true;
          rd.excelTemplate = new ExcelFileTempateInfo();


          rd.excelTemplate.useTemplate              = true;
          rd.excelTemplate.templateFileName         = @"Batches_In_Process_by_Batch_Status_Template.xls";
          rd.excelTemplate.sheetNum                 = 0;
          rd.excelTemplate.setDataCellRegion (3,9900,@"A",@"J");

          rd.excelTemplate.collapseRowGroups        = false;
          rd.excelTemplate.collapseColGroups        = false;

         return rd;
      }

      /***************************************************************************
      * viewObjects 
      *
      * 
      ***************************************************************************/

      public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo   uInfo                                                    
                                                , bool       pageObjectList
                                                , string     pageOrder
                                                , string     idx
                                                , string     clientName)
      
      {
              
        /* Default page order */  
      
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = Client.DEFAULT_PAGING_ORDER;
      
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
      
        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          pageroworder = pageOrder;
        };
      
        return Entities.viewObjects(  connSpedmon
                                     , log
                                     , uInfo
                                     , typeof(Client)
                                     , pageObjectList
                                     , pageOrder
                                     , delegate {                                      
                                         return Clients.view (  connSpedmon
                                                              , log
                                                              , uInfo
                                                              , Entities.REC_VIEW_OBJECTS
                                                              , pageObjectList
                                                              , idx
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , ""
                                                              , clientName
                                                              , dc);
                                      });
        
     
 
      }
    }
}
