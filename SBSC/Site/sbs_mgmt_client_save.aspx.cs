using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;
using System.Collections.Generic;



namespace Spedmon
{
  /***************************************************************************
  * ClientSave */
  /**
  * Saves a client
  ***************************************************************************/

  public class SBSMGMTClientSave : WebUI
  {
    public string clientSaveURL;
    public int saveType                      = 0;
    public string firstcheckVal              = "";
    public string claim_TCMEffectiveDateVal  = "";
    public string parentConsentAgreementEffectiveDateVal = "";
    public string planWriterAccessEndDateVal = "";
    public string TeleHealthAccessEndDateVal = "";
    public string TeleIEPAccessEndDateVal    = "";
    public string LEARecoveryBudgetVal       = "";
    public string hyQueueFeeVal              = "";
    public string planWriterFeeVal           = "";
    public string baselineReimbursementVal   = "";
    //public bool   isPCalStaff                = false;
    //public string isPcalStaffJSBoolStr       = "";
    public bool   userCanSeePartnerData          = false;
    public string userCanSeePartnerDataJSBoolStr = "";
    public string clientShortName = "";
    public string baseUrlAriesTestPage = "";
    public List<ClientPBSDocumentRecord> specAuthRecs = new List<ClientPBSDocumentRecord>();
    public List<ClientContactsRecord>    contactRecs  = new List<ClientContactsRecord>();
    public List<ClientContractsRecord>   contractRecs  = new List<ClientContractsRecord>();
    public SBSMGMTClientSave() : base(  "client_save"
                                       , "Clients - New"
                                       , "sbs_mgmt_client_save.css"
                                       , "sbs_mgmt_client_save.js|rec_special_authorizations.js|rec_contacts.js|rec_contracts.js|client-invoices.js|client-school-session-academic-years.js|client-school-session-breaks.js|client-domains.js|client-group-service-class-name-specific-practice-rule-sets.js|client-student-information-systems.js"
                                       , Constants.ROLE_SBS_MGMT_ANI) { }
    protected void Page_Load(object sender, EventArgs e)
    {
      /*-------------------------------
       * Determine what save type
       * this is 
       *------------------------------*/
       
        userCanSeePartnerData = ClientInvoices.userCanSeePartnerData(uInfo);

        userCanSeePartnerDataJSBoolStr = Util.netBoolToJSBool(userCanSeePartnerData);

        //isPCalStaff          = uInfo.pcalStaff;
        //isPcalStaffJSBoolStr = Util.netBoolToJSBool(isPCalStaff);
        string recid    = MBA.HttpApplication.getParameter("recid");
        string savetype = MBA.HttpApplication.getParameter("savetype");

        Object vSaveType = MBA.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);

        if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
        saveType = (int)vSaveType;

        baseUrlAriesTestPage = MBA.HttpApplication.createLink( "user_all_aries_api_test.aspx"
                                                              , true
                                                              , new NameValue(Constants.PARM_APP_MODE,Constants.AMD_UI_DBS_SUB_PAGE));

        /*-------------------------------
         * Find controls we use for both
         * new and edit
         *------------------------------*/
      
        var ctrlCybhiGenerate837                   = findControlRecu(this.Page, "cybhigenerate837")                  as MBA.SelectYesOrNo;
        var ctrlCybhiAutoGenerate837               = findControlRecu(this.Page, "cybhiautogenerate837")              as MBA.SelectYesOrNo;
        var ctrlCybhiNumDaysToHoldEnteredClaims    = findControlRecu(this.Page, "cybhinumdaystoholdenteredclaims")   as MBA.DataEntryBoxNumber;

        if (saveType == Constants.SAVE_TYPE_EDIT)
        {
            /*-------------------------------
             * Load record and if its not
             * found get out
             *------------------------------*/

            Client c = Clients.load(dbConnApp, log, uInfo, recid);

            /*-------------------------------
             * Locate data controls
             *------------------------------*/

            DataEntryRowSaveOrEdit  ctrlSaveOrEdit                               = findControlRecu(this.Page, "saveOrEdit")              as DataEntryRowSaveOrEdit;
            var                     ctrlrecSpecAuthJSON                          = findControlRecu(this.Page, "recSpecAuthJSON")         as MBA.HiddenTextArea;
            var                     ctrlrecContactJSON                           = findControlRecu(this.Page, "recContactJSON")          as MBA.HiddenTextArea;
            var                     ctrlrecContractJSON                          = findControlRecu(this.Page, "recContractJSON")         as MBA.HiddenTextArea;
            var                     ctrlclientid                                 = findControlRecu(this.Page, Constants.PARM_CLIENT_ID)  as MBA.HiddenInput;
            var                     ctrlclientlogofiledata                       = findControlRecu(this.Page, "clientlogofiledata")      as MBA.HiddenTextArea;
            WebUIControlDataField   ctrlclientname                               = findControlRecu(this.Page, "clientName")              as WebUIControlDataField;
            WebUIControlDataField   ctrlclientCDS                                = findControlRecu(this.Page, "clientCDS")               as WebUIControlDataField;
            WebUIControlDataField   ctrlNPI                                      = findControlRecu(this.Page, "NPI")                     as WebUIControlDataField;
            WebUIControlDataField   ctrltaxID                                    = findControlRecu(this.Page, "tax_ID")                  as WebUIControlDataField;
            SelectYesOrNo           ctrlapproved_837                             = findControlRecu(this.Page, "approved_837")            as SelectYesOrNo;
            SelectYesOrNo           ctrlapproved_835                             = findControlRecu(this.Page, "approved_835")            as SelectYesOrNo;
            WebUIControlDataField   ctrlEIN                                      = findControlRecu(this.Page, "EIN")                     as WebUIControlDataField;
            SelectYesOrNo           ctrlCOE                                      = findControlRecu(this.Page, "COE")                     as SelectYesOrNo;
            SelectYesOrNo           ctrlLEA                                      = findControlRecu(this.Page, "LEA")                     as SelectYesOrNo;
            SelectYesOrNo           ctrlMAA                                      = findControlRecu(this.Page, "MAA")                     as SelectYesOrNo;
            var                     ctrlrvnsharectgLEA                           = findControlRecu(this.Page, "rvnsharectgLEA")          as MBA.DataEntryBoxText; 
            WebUIControlDataField   ctrlrvnsharectgMAA                           = findControlRecu(this.Page, "rvnsharectgMAA")          as WebUIControlDataField;
            ComboBox                ctrlclrepidLEA                               = findControlRecu(this.Page, "clrepidLEA")              as ComboBox;
            ComboBox                ctrlclrepidMAA                               = findControlRecu(this.Page, "clrepidMAA")              as ComboBox;
            ComboBox                ctrlowndbycompidLEA                          = findControlRecu(this.Page, "owndbycompidLEA")         as ComboBox;
            ComboBox                ctrlowndbycompidMAA                          = findControlRecu(this.Page, "owndbycompidMAA")         as ComboBox;
            var                     ctrlLecOrLga                                 = findControlRecu(this.Page, "selectLecOrLga")          as DataEntryRowSelectLecOrLga;
            WebUIControlDataField   ctrlshortname                                = findControlRecu(this.Page, "shortname")               as WebUIControlDataField;
            WebUIControlDataField   ctrlnameRcgByDHCS_EDS                        = findControlRecu(this.Page, "namercgbyDHCS_EDS")       as WebUIControlDataField;
            MBA.FieldSetUSPSAddress ctrlAddress                                  = findControlRecu(this.Page, "clientAddress")           as MBA.FieldSetUSPSAddress;
            WebUIControlDataField   ctrllname                                    = findControlRecu(this.Page, "lname")                   as WebUIControlDataField;
            WebUIControlDataField   ctrlfname                                    = findControlRecu(this.Page, "fname")                   as WebUIControlDataField;
            WebUIControlDataField   ctrltitle                                    = findControlRecu(this.Page, "title")                   as WebUIControlDataField;
            WebUIControlDataField   ctrlemail                                    = findControlRecu(this.Page, "email")                   as WebUIControlDataField;
            WebUIControlDataField   ctrlPhone                                    = findControlRecu(this.Page, "phone")                   as WebUIControlDataField;
            WebUIControlDataField   ctrlFax                                      = findControlRecu(this.Page, "fax")                     as WebUIControlDataField;
            SelectYesOrNo           ctrlSvcRecApprovalSys                        = findControlRecu(this.Page, "svcrecapprovalsystem")    as SelectYesOrNo;
            
            SelectYesOrNoOrUnknown  ctrlclaim_TCM                                = findControlRecu(this.Page, "claim_TCM")                           as SelectYesOrNoOrUnknown;
            SelectYesOrNoOrUnknown  ctrlparentConsentAgreement                   = findControlRecu(this.Page, "parentConsentAgreement")              as SelectYesOrNoOrUnknown;
            SelectYesOrNo           ctrlSendUsersEmailNotifications              = findControlRecu(this.Page, "sendUsersEmailNotifications")         as SelectYesOrNo;
            SelectYesOrNo           ctrlPlanWriterAccessGranted                  = findControlRecu(this.Page, "planWriterAccessGranted")             as SelectYesOrNo;
            NumberBox               ctrlNumDaysToHoldClientEnteredClaims         = findControlRecu(this.Page, "numDaysToHoldClientEnteredClaims")    as NumberBox;
            SelectYesOrNo           ctrlAutoGenerate837File                      = findControlRecu(this.Page, "autoGenerate837File")                 as SelectYesOrNo;            
            SelectYesOrNo           ctrlTeleHealthAccessGranted                  = findControlRecu(this.Page, "teleCommTeleHealthAccessGranted")     as SelectYesOrNo;
            SelectYesOrNo           ctrlTeleIEPAccessGranted                     = findControlRecu(this.Page, "teleCommTeleIEPAccessGranted")        as SelectYesOrNo;

            TextAreaBox             ctrlNotes                                    = findControlRecu(this.Page, "notes")                               as TextAreaBox;
            TextAreaBox             ctrlcarePlanLegalLang                        = findControlRecu(this.Page, "carePlanLegalLang")                   as TextAreaBox;

            SelectYesOrNo           ctrlSendRequestsForTotPop                    = findControlRecu(this.Page, "sendRequestsForTotPop")                as SelectYesOrNo;
            SelectCronTabOccurance  ctrlSelectExpectedTotalPop                   = findControlRecu(this.Page, "cronTabExpectedTotPop")                as SelectCronTabOccurance;
            SelectYesOrNo           ctrlSendRequestsForSpEd                      = findControlRecu(this.Page, "sendRequestsForSpEd")                  as SelectYesOrNo;
            SelectCronTabOccurance  ctrlSelectExpectedSpecEdSvcs                 = findControlRecu(this.Page, "cronTabExpectedSpecEdSvcs")            as SelectCronTabOccurance;

            SelectYesOrNo           ctrlCybhiDoNotClaimOverlap                   = findControlRecu(this.Page, "cybhidonotclaimoverappingleabopsvcs")           as SelectYesOrNo;
            SelectYesOrNo           ctrlCybhiAddOnMissingInfoRequests            = findControlRecu(this.Page, "cybhiaddonmissinginforequeststopatientpersons") as SelectYesOrNo;

            SelectYesOrNo           ctrlcybhiconsortiumbilling                   = findControlRecu(this.Page, "cybhiconsortiumbilling")                        as SelectYesOrNo;
            var                     ctrlcybhiconsortiumleadclientID              = findControlRecu(this.Page, "selectcybhiconsortiumleadClientID")             as MBA.DataEntryRowSelectClient;
            SelectYesOrNo           ctrlleabopconsortiumbilling                  = findControlRecu(this.Page, "leabopconsortiumbilling")                       as SelectYesOrNo;
            var                     ctrlleabopconsortiumLeadClientID             = findControlRecu(this.Page, "selectleabopconsortiumLeadClientID")            as MBA.DataEntryRowSelectClient;

            SelectYesOrNo           ctrlCybhiTpaApproved                         = findControlRecu(this.Page, "cybhitpaapproved")                              as SelectYesOrNo;
            DataEntryBoxDate        ctrlCybhiTpaApprovedOn                       = findControlRecu(this.Page, "cybhitpaapprovedon")                            as DataEntryBoxDate;
            DataEntryBoxText        ctrlCybhiTpaID                               = findControlRecu(this.Page, "cybhitpaid")                                    as DataEntryBoxText;
            SelectYesOrNo           ctrlCybhiSubmitClaims                        = findControlRecu(this.Page, "cybhisubmitclaims")                             as SelectYesOrNo;
            SelectYesOrNo           ctrlImpliedFerpaConsent                      = findControlRecu(this.Page, "impliedferpaconsent")                           as SelectYesOrNo;

            var ctrlSendElibilityDataMatchRequestsToDHCS                         = findControlRecu(this.Page, "sendElibilityDataMatchRequestsToDHCS") as SelectYesOrNo;
            
            var                     ctrlSelectClientSELPA                        = findControlRecu(this.Page, "selectClientSELPA")                    as MBA.DataEntryRowSelectSELPA;
            var                     ctrlCdeComplianceClient                      = findControlRecu(this.Page, "cdecomplianceclient")                  as SelectYesOrNo;
            var                     ctrlCybhi                                    = findControlRecu(this.Page, "cybhi")                                as SelectYesOrNo;
            var                     ctrlFuzzyMatchSitesByNameAndCode             = findControlRecu(this.Page, "fuzzymatchsitesbynameandcode")         as SelectYesOrNo;
            var                     ctrlCybhiClientCode                          = findControlRecu(this.Page, "cybhiclientcode")                      as MBA.DataEntryBoxText;
            var                     ctrlinitialContractStartDate                 = findControlRecu(this.Page, "initialContractStartDate")             as MBA.DataEntryBoxDate;
            var                     ctrlhealtheKids_percent                      = findControlRecu(this.Page, "healtheKids_percent")                  as MBA.DataEntryBoxNumber;
            var                     ctrlcybhi_percent                            = findControlRecu(this.Page, "cybhi_percent")                        as MBA.DataEntryBoxNumber;
            var                     ctrlcrcs_percent                             = findControlRecu(this.Page, "crcs_percent")                         as MBA.DataEntryBoxNumber;
            var                     ctrlcdeReporting_percent                     = findControlRecu(this.Page, "cdeReporting_percent")                 as MBA.DataEntryBoxNumber;
            var                     ctrltotal_percent                            = findControlRecu(this.Page, "total_percent")                        as MBA.DataEntryBoxNumber;
            var                     ctrlplanImplementation_percent               = findControlRecu(this.Page, "planImplementation_percent")           as MBA.DataEntryBoxNumber;
            var                     ctrlruHealth_percent                         = findControlRecu(this.Page, "ruHealth_percent")                     as MBA.DataEntryBoxNumber;
            var                     ctrlnewProduct2_percent                      = findControlRecu(this.Page, "newProduct2_percent")                  as MBA.DataEntryBoxNumber;
            var                     ctrlnewProduct3_percent                      = findControlRecu(this.Page, "newProduct3_percent")                  as MBA.DataEntryBoxNumber;
            var                     ctrlaccounting_percent                       = findControlRecu(this.Page, "accounting_percent")                   as MBA.DataEntryBoxNumber;
            var                     ctrlflatFee_amount                           = findControlRecu(this.Page, "flatFee_amount")                       as MBA.DataEntryBoxNumber; 

            // var                     ctrlpractiCal_percent                        = findControlRecu(this.Page, "practiCal_percent")                    as MBA.DataEntryBoxNumber;
            // var                     ctrlspEdCare_percent                         = findControlRecu(this.Page, "spEdCare_percent")                     as MBA.DataEntryBoxNumber;

            var                     ctrlcsba_percent                             = findControlRecu(this.Page, "csba_percent")                         as MBA.DataEntryBoxNumber;
            var                     ctrllba_percent                              = findControlRecu(this.Page, "lba_percent")                          as MBA.DataEntryBoxNumber;
            var                     ctrlpartner1_percent                         = findControlRecu(this.Page, "partner1_percent")                     as MBA.DataEntryBoxNumber;
            var                     ctrlpartner1E_percent                        = findControlRecu(this.Page, "partner1E_percent")                    as MBA.DataEntryBoxNumber;
            var                     ctrlpartner2_percent                         = findControlRecu(this.Page, "partner2_percent")                     as MBA.DataEntryBoxNumber;
            var                     ctrlclientRetention                          = findControlRecu(this.Page, "clientRetention")                      as MBA.DataEntryBoxNumber;

            var ctrlCybhiSelectClinicalSupervisorPracID = findControlRecu(this.Page, "cybhiSelectClinicalSupervisorPracID") as MBA.DataEntryRowSelectPractitioner;
            var                     ctrlMBA_BBA_Percent                          = findControlRecu(this.Page, "mba_bba_percent")                      as MBA.DataEntryBoxNumber;

            // var                     ctrlMBA_DG_Percent                           = findControlRecu(this.Page, "mba_dg_percent")                       as MBA.DataEntryBoxNumber;

            var                     ctrlSpEdCare_BBA_Percent                     = findControlRecu(this.Page, "spEdCare_bba_percent")                 as MBA.DataEntryBoxNumber;

            // var                     ctrlSpEdCare_DG_Percent                      = findControlRecu(this.Page, "spEdCare_dg_percent")                  as MBA.DataEntryBoxNumber;
            var                     ctrlSMAA_1_Percent                           = findControlRecu(this.Page, "smaa_1_percent")                       as MBA.DataEntryBoxNumber;
            var                     ctrlSMAA_2_Percent                           = findControlRecu(this.Page, "smaa_2_percent")                       as MBA.DataEntryBoxNumber;
            var                     ctrlSMAA_3_Percent                           = findControlRecu(this.Page, "smaa_3_percent")                       as MBA.DataEntryBoxNumber;
         
            
            var ctrlCybhiClientName = findControlRecu(this.Page, "cybhiclientname")  as MBA.DataEntryBoxText;
            var ctrlCybhiNPI        = findControlRecu(this.Page, "cybhinpi")         as MBA.DataEntryBoxText;
            var ctrlCybhiTaxID      = findControlRecu(this.Page, "cybhitaxid")       as MBA.DataEntryBoxText;
            var ctrlCybhiAddress    = findControlRecu(this.Page, "cybhiAddressData") as MBA.FieldSetUSPSAddress;
                
   
            /*-------------------------------
             * Populate Data Values
             *------------------------------*/

            ctrlSaveOrEdit.saveType                          = saveType;
            ctrlSaveOrEdit.recID                             = c.id.ToString();

            // clientid same as record id
            ctrlclientid.value                               = c.id.ToString();
            ctrlclientname.value                             = c.name;
            ctrlclientCDS.value                              = c.CDS;    
            ctrlNPI.value                                    = c.NPI;
            ctrltaxID.value                                  = c.tax_ID;                    
            ctrlapproved_837.value                           = Util.boolToYesNo(c.approved_837);
            ctrlapproved_835.value                           = Util.boolToYesNo(c.approved_835); 
            ctrlEIN.value                                    = c.EIN;
            ctrlCOE.value                                    = Util.boolToYesNo(c.COE);
            ctrlLEA.value                                    = Util.boolToYesNo(c.LEA);
            ctrlMAA.value                                    = Util.boolToYesNo(c.MAA);
            ctrlrvnsharectgLEA.value                         = c.rvnsharectgLEA;
            ctrlrvnsharectgMAA.value                         = c.rvnsharectgMAA;
            ctrlclrepidLEA.value                             = c.clrepidLEA.ToString();
            ctrlclrepidMAA.value                             = c.clrepidMAA.ToString();
            ctrlowndbycompidLEA.value                        = c.owndbycompidLEA.ToString();
            ctrlowndbycompidMAA.value                        = c.owndbycompidMAA.ToString();
            ctrlLecOrLga.selectValue                         = c.lecOrLgaID.ToString();
            ctrlshortname.value                              = c.shortname;
            ctrlnameRcgByDHCS_EDS.value                      = c.namercgbyDHCS_EDS;
            ctrlAddress.parmValueStreet1                     = c.address1;     
            ctrlAddress.parmValueStreet2                     = c.address2;     
            ctrlAddress.parmValueCity                        = c.city;         
            ctrlAddress.parmValueState                       = c.state;        
            ctrlAddress.parmValueZip5                        = c.zip;          
            ctrlAddress.parmValueZip4                        = c.zipplusfour;  
            ctrllname.value                                  = c.contactlname;
            ctrlfname.value                                  = c.contactfname;        
            ctrltitle.value                                  = c.contactTitle;        
            ctrlemail.value                                  = c.contactEmail;        
            ctrlPhone.value                                  = c.contactPhone;        
            ctrlFax.value                                    = c.contactFax;
            ctrlSvcRecApprovalSys.value                      = Util.boolToYesNo(c.svcRecApprovalSystem);
            ctrlclaim_TCM.value                              = Util.boolToYesNoUnknown(c.claim_TCM);
            ctrlparentConsentAgreement.value                 = Util.boolToYesNoUnknown(c.parentConsentAgreement);
            ctrlSendUsersEmailNotifications.value            = Util.boolToYesNo(c.sendUsersEmailNotifications);
            ctrlPlanWriterAccessGranted.value                = c.planWriterAccessGrantedStr;
            ctrlNumDaysToHoldClientEnteredClaims.value       = c.numDaysToHoldClientEnteredClaims.ToString();
            ctrlAutoGenerate837File.value                    = c.autoGenerate837FileStr;
            ctrlTeleHealthAccessGranted.value                = c.teleCommTeleHealthAccessGrantedStr;
            ctrlTeleIEPAccessGranted.value                   = c.teleCommTeleIEPAccessGrantedStr;
            ctrlNotes.value                                  = c.notes;
            ctrlcarePlanLegalLang.value                      = c.carePlanLegalLang;
            ctrlclientlogofiledata.value                     = c.clientlogofiledata;
           
            ctrlCybhiDoNotClaimOverlap.value                 = Util.boolToYesNo(c.cybhiDoNotClaimOverappingLEABopSvcs);
            ctrlCybhiAddOnMissingInfoRequests.value          = Util.boolToYesNo(c.cybhiAddOnMissingInfoRequestsToPatientPersons);

            ctrlcybhiconsortiumbilling.setValue(c.cybhiConsortiumBilling);
            string cybhiConsortiumLeadClientIDstr            = (c.cybhiConsortiumLeadClientID != 0)?c.cybhiConsortiumLeadClientID.ToString():"";
            if (!String.IsNullOrEmpty(cybhiConsortiumLeadClientIDstr))
            {
                var _clt = Clients.load(dbConnApp, log, uInfo, cybhiConsortiumLeadClientIDstr);
                ctrlcybhiconsortiumleadclientID.selectName  = _clt.name;
                ctrlcybhiconsortiumleadclientID.selectValue = cybhiConsortiumLeadClientIDstr;
            }

            ctrlleabopconsortiumbilling.setValue(c.leaBopConsortiumBilling);
            string leaBopConsortiumLeadClientIDstr = (c.leaBopConsortiumLeadClientID != 0) ? c.leaBopConsortiumLeadClientID.ToString() : "";
            if (!String.IsNullOrEmpty(leaBopConsortiumLeadClientIDstr))
            {
                var _clt = Clients.load(dbConnApp, log, uInfo, leaBopConsortiumLeadClientIDstr);
                ctrlleabopconsortiumLeadClientID.selectName  = _clt.name;
                ctrlleabopconsortiumLeadClientID.selectValue = leaBopConsortiumLeadClientIDstr;
            }

            ctrlCybhiTpaApproved.value                       = Util.boolToYesNoUnknown(c.cybhiTpaApproved);
            ctrlCybhiTpaApprovedOn.value                     = c.cybhiTpaApprovedOn;
            ctrlCybhiTpaID.value                             = c.cybhiTpaID;

            ctrlCybhiSubmitClaims.setValue(c.cybhiSubmitClaims);
            ctrlImpliedFerpaConsent.setValue(c.impliedFerpaConsent);

                // the following are input values which will be used by js in the front-end page
                // we don't load them directly from here because the inputs are regular html inputs
                // rather than <Spedmon> inputs
                firstcheckVal = (c.firstcheck == DateTime.MinValue) ? "" : c.firstcheck.ToString("yyyy-MM-dd");

            claim_TCMEffectiveDateVal              = (c.claim_TCMEffectiveDate == DateTime.MinValue) ? "" : c.claim_TCMEffectiveDate.ToString("yyyy-MM-dd");
            parentConsentAgreementEffectiveDateVal = (c.parentConsentAgreementEffectiveDate == DateTime.MinValue) ? "" : c.parentConsentAgreementEffectiveDate.ToString("yyyy-MM-dd");
            planWriterAccessEndDateVal             = c.planWriterAccessEndDateStr;
            TeleHealthAccessEndDateVal             = c.teleCommTeleHealthAccessEndDateStr;
            TeleIEPAccessEndDateVal                = c.teleCommTeleIEPAccessEndDateStr;
            LEARecoveryBudgetVal                   = c.LEARecoveryBudget;
            hyQueueFeeVal                          = c.hyQueueFee;
            planWriterFeeVal                       = c.planWriterFee;
            baselineReimbursementVal               = c.baselineReimbursement;
            clientShortName                        = c.shortname;

            // populate the drop-down values with the saved selections
            ctrlclrepidLEA.selectName      = c.clrepnameLEA;
            ctrlclrepidMAA.selectName      = c.clrepnameMAA;
            ctrlowndbycompidLEA.selectName = c.companynameLEA;
            ctrlowndbycompidMAA.selectName = c.companynameMAA;
            ctrlLecOrLga.selectName        = c.lecOrLgaName;
  
            if (saveType == Constants.SAVE_TYPE_EDIT)   this.subTitle = "Clients - Edit";
            if (saveType == Constants.SAVE_TYPE_DELETE) this.subTitle = "Clients - Delete";

            // load the special authorization records to the table
            specAuthRecs              = ClientPBSDocumentation.viewListPBSRecs (dbConnApp,log,uInfo, ctrlclientid.value, "1");
            ctrlrecSpecAuthJSON.value = MBA.JSON.toJSONString(specAuthRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);
            
            // load the contact records to the table
            contactRecs              = ClientContacts.viewList (dbConnApp,log,uInfo, ctrlclientid.value, "1");
            ctrlrecContactJSON.value = MBA.JSON.toJSONString(contactRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);
            
            // load the contract records to the table
            contractRecs              = ClientContracts.viewList (dbConnApp,log,uInfo, ctrlclientid.value, "1");
            ctrlrecContractJSON.value = MBA.JSON.toJSONString(contractRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);
            
            /* Load expected schedule for sending email reminders for total pop and special ed*/
            
            ctrlSelectExpectedTotalPop.value   = c.cronTabExpectedTotPop.ToString();           
            ctrlSelectExpectedSpecEdSvcs.value = c.cronTabExpectedSpecEdSvcs.ToString();
            ctrlSendRequestsForTotPop.value    = c.sendRequestsForTotPopStr;
            ctrlSendRequestsForSpEd.value      = c.sendRequestsForSpEdStr;
            ctrlSendElibilityDataMatchRequestsToDHCS.setValue(c.sendElibilityDataMatchRequestsToDHCS);
            ctrlSelectClientSELPA.selectValue = c.SELPACode.ToString();
            ctrlSelectClientSELPA.selectName  = c.SELPACodeAndName;
            ctrlCdeComplianceClient.setValue(c.cdeComplianceClient);
            ctrlCybhi.setValue(c.cybhi);
            ctrlFuzzyMatchSitesByNameAndCode.setValue(c.fuzzyMatchSitesByNameAndCode);
            ctrlCybhiClientCode.value         = c.cybhiClientCode;
            
            ctrlinitialContractStartDate.value       = c.initialContractStartDate;
            ctrlhealtheKids_percent.value            =  Convert.ToDouble(c.healtheKids_percent);
            ctrlcybhi_percent.value                  =  Convert.ToDouble(c.cybhi_percent);
            ctrlcrcs_percent.value                   =  Convert.ToDouble(c.crcs_percent);
            ctrlcdeReporting_percent.value           =  Convert.ToDouble(c.cdeReporting_percent);
            ctrltotal_percent.value                  =  Convert.ToDouble(c.total_percent);
            ctrlplanImplementation_percent.value     =  Convert.ToDouble(c.planImplementation_percent);
            ctrlruHealth_percent.value               =  Convert.ToDouble(c.ruHealth_percent);
            ctrlnewProduct2_percent.value            =  Convert.ToDouble(c.newProduct2_percent);
            ctrlnewProduct3_percent.value            =  Convert.ToDouble(c.newProduct3_percent);
            ctrlaccounting_percent.value             =  Convert.ToDouble(c.accounting_percent);
            ctrlflatFee_amount.value                 =  Convert.ToDouble(c.flatFee_amount);

            // ctrlpractiCal_percent.value              =  Convert.ToDouble(c.practiCal_percent);
            // ctrlspEdCare_percent.value               =  Convert.ToDouble(c.spEdCare_percent);

            ctrlcsba_percent.value                   =  Convert.ToDouble(c.csba_percent);
            ctrllba_percent.value                    =  Convert.ToDouble(c.lba_percent);
            ctrlpartner1_percent.value               =  Convert.ToDouble(c.partner1_percent);
            ctrlpartner1E_percent.value              =  Convert.ToDouble(c.partner1E_percent);
            ctrlpartner2_percent.value               =  Convert.ToDouble(c.partner2_percent);
            ctrlclientRetention.value                =  Convert.ToDouble(c.clientRetention);

            ctrlCybhiSelectClinicalSupervisorPracID.selectValue = c.cybhiClinicalSupervisorPracID.ToString();
            ctrlCybhiSelectClinicalSupervisorPracID.selectName  = c.cybhiClinicalSupervisorPracName;


            ctrlCybhiClientName.value           = c.cybhiClientName;
            ctrlCybhiNPI.value                  = c.cybhiNPI;
            ctrlCybhiTaxID.value                = c.cybhiTaxID;
            ctrlCybhiAddress.parmValueStreet1   = c.cybhiAddress1;
            ctrlCybhiAddress.parmValueStreet2   = c.cybhiAddress2; 
            ctrlCybhiAddress.parmValueCity      = c.cybhiCity; 
            ctrlCybhiAddress.parmValueState     = c.cybhiState;     
            ctrlCybhiAddress.parmValueZip5      = c.cybhiZip5;    
            ctrlCybhiAddress.parmValueZip4      = c.cybhiZip4;  

            ctrlCybhiGenerate837.setValue(c.cybhiGenerate837);
            ctrlCybhiAutoGenerate837.setValue(c.cybhiAutoGenerate837);
            ctrlCybhiNumDaysToHoldEnteredClaims.setValue(c.cybhiNumDaysToHoldEnteredClaims);

            ctrlMBA_BBA_Percent.value                =  Convert.ToDouble(c.mba_bba_percent);

            // ctrlMBA_DG_Percent.value                 = Convert.ToDouble(c.mba_dg_percent);

            ctrlSpEdCare_BBA_Percent.value           = Convert.ToDouble(c.spEdCare_bba_percent);

            // ctrlSpEdCare_DG_Percent.value            = Convert.ToDouble(c.spEdCare_dg_percent);

            ctrlSMAA_1_Percent.value                 = Convert.ToDouble(c.smaa_1_percent);
            ctrlSMAA_2_Percent.value                 = Convert.ToDouble(c.smaa_2_percent);
            ctrlSMAA_3_Percent.value                 = Convert.ToDouble(c.smaa_3_percent);


            }
            else
        {
            /*-------------------------------
             * Otherwise its a new record
             *------------------------------*/
            this.subTitle = "Clients - New";
            var                     ctrlhealtheKids_percent                      = findControlRecu(this.Page, "healtheKids_percent")                  as MBA.DataEntryBoxNumber;
            var                     ctrlcybhi_percent                            = findControlRecu(this.Page, "cybhi_percent")                        as MBA.DataEntryBoxNumber;
            var                     ctrlcrcs_percent                             = findControlRecu(this.Page, "crcs_percent")                         as MBA.DataEntryBoxNumber;
            var                     ctrlcdeReporting_percent                     = findControlRecu(this.Page, "cdeReporting_percent")                 as MBA.DataEntryBoxNumber;
            var                     ctrltotal_percent                            = findControlRecu(this.Page, "total_percent")                        as MBA.DataEntryBoxNumber;
            var                     ctrlplanImplementation_percent               = findControlRecu(this.Page, "planImplementation_percent")           as MBA.DataEntryBoxNumber;
            var                     ctrlruHealth_percent                         = findControlRecu(this.Page, "ruHealth_percent")                     as MBA.DataEntryBoxNumber;
            var                     ctrlnewProduct2_percent                      = findControlRecu(this.Page, "newProduct2_percent")                  as MBA.DataEntryBoxNumber;
            var                     ctrlnewProduct3_percent                      = findControlRecu(this.Page, "newProduct3_percent")                  as MBA.DataEntryBoxNumber;
            var                     ctrlaccounting_percent                       = findControlRecu(this.Page, "accounting_percent")                   as MBA.DataEntryBoxNumber;
            var                     ctrlflatFee_amount                           = findControlRecu(this.Page, "flatFee_amount")                       as MBA.DataEntryBoxNumber; 
            //var                     ctrlpractiCal_percent                        = findControlRecu(this.Page, "practiCal_percent")                    as MBA.DataEntryBoxNumber;
            //var                     ctrlspEdCare_percent                         = findControlRecu(this.Page, "spEdCare_percent")                     as MBA.DataEntryBoxNumber;
            var                     ctrlcsba_percent                             = findControlRecu(this.Page, "csba_percent")                         as MBA.DataEntryBoxNumber;
            var                     ctrllba_percent                              = findControlRecu(this.Page, "lba_percent")                          as MBA.DataEntryBoxNumber;
            var                     ctrlpartner1_percent                         = findControlRecu(this.Page, "partner1_percent")                     as MBA.DataEntryBoxNumber;
            var                     ctrlpartner1E_percent                        = findControlRecu(this.Page, "partner1E_percent")                    as MBA.DataEntryBoxNumber;
            var                     ctrlpartner2_percent                         = findControlRecu(this.Page, "partner2_percent")                     as MBA.DataEntryBoxNumber;
            var                     ctrlclientRetention                          = findControlRecu(this.Page, "clientRetention")                      as MBA.DataEntryBoxNumber;

            var                     ctrlMBA_BBA_Percent                          = findControlRecu(this.Page, "mba_bba_percent")                      as MBA.DataEntryBoxNumber;
            //var                     ctrlMBA_DG_Percent                           = findControlRecu(this.Page, "mba_dg_percent")                       as MBA.DataEntryBoxNumber;

            var                     ctrlSpEdCare_BBA_Percent                     = findControlRecu(this.Page, "spEdCare_bba_percent")                 as MBA.DataEntryBoxNumber;
            //var                     ctrlSpEdCare_DG_Percent                      = findControlRecu(this.Page, "spEdCare_dg_percent")                  as MBA.DataEntryBoxNumber;
            var                     ctrlSMAA_1_Percent                           = findControlRecu(this.Page, "smaa_1_percent")                       as MBA.DataEntryBoxNumber;
            var                     ctrlSMAA_2_Percent                           = findControlRecu(this.Page, "smaa_2_percent")                       as MBA.DataEntryBoxNumber;
            var                     ctrlSMAA_3_Percent                           = findControlRecu(this.Page, "smaa_3_percent")                       as MBA.DataEntryBoxNumber;

            ctrlhealtheKids_percent.value            =   4;
            ctrlcybhi_percent.value                  =   6;
            ctrlcrcs_percent.value                   =   17;
            ctrlcdeReporting_percent.value           =   4;
            ctrltotal_percent.value                  =   39;
            ctrlplanImplementation_percent.value     =   8;
            ctrlruHealth_percent.value               =   0;
            ctrlnewProduct2_percent.value            =   0;
            ctrlnewProduct3_percent.value            =   0;
            ctrlaccounting_percent.value             =   4.28;
            ctrlflatFee_amount.value                 =   0;
            //ctrlpractiCal_percent.value              =   0;
            //ctrlspEdCare_percent.value               =   0;
            ctrlcsba_percent.value                   =   3.5;
            ctrllba_percent.value                    =   2;
            ctrlpartner1_percent.value               =   3;
            ctrlpartner1E_percent.value              =   3;
            ctrlpartner2_percent.value               =   0;
            ctrlclientRetention.value                =   0;

            ctrlCybhiGenerate837.setValue(true);             /* Keep this in synch with client table column default */
            ctrlCybhiAutoGenerate837.setValue(false);        /* Keep this in synch with client table column default */
            ctrlCybhiNumDaysToHoldEnteredClaims.setValue(7); /* Keep this in synch with client table column default */


            ctrlMBA_BBA_Percent.value                =   5;
            //ctrlMBA_DG_Percent.value                 =   5;
            ctrlSMAA_1_Percent.value                 =   0;
            ctrlSMAA_2_Percent.value                 =   0;
            ctrlSMAA_3_Percent.value                 =   0;
            ctrlSpEdCare_BBA_Percent.value           =   1;
            //ctrlSpEdCare_DG_Percent.value            =   1;
        }
      
        clientSaveURL = MBA.HttpApplication.createLink("sbs_mgmt_client_save.aspx", true);
    }
  }
}