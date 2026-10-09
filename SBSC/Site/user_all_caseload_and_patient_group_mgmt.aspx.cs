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

namespace Spedmon
{
    /*###########################################################################
     *#                                                                         #
     *#             !!!!!!!!!!!!!!!! NOTICE !!!!!!!!!!!!!!!!!!                  #
     *#                                                                         #
     *# The value of planType is NOT our standard values for planType           #
     *#                                                                         #
     *# In this context.....                                                    #
     *#                                                                         #
     *# 1 = IEP or IFSP, 2 = No Plan                                            #
     *#                                                                         #
     *# Everywhere else                                                         #
     *#                                                                         #
     *#  1 = IFSP, 2 = IEP, 3 = No Plan                                         #
     *###########################################################################*/

    public class UserAllCaseloadAndPatientGroupMgmt : WebUI2
    {



        public UserAllCaseloadAndPatientGroupMgmt() : base("caseload_and_group_mgmt"
                                                         , @"Caseload and Patient Group Management"
                                                         , "caseload-and-patient-group-mgmt.css"
                                                         , "practitioner_preference_sped_services_restview.js"
                                                         , Constants.ROLE_SVC_SUP_PRAC)
        { }

        public string clientID = "";
        public string pracID = "";
        public string tkn = "";
        public string svcRecURL;
        public string caseloadSvcRecURL;
        public string assessmentSvcRecURL;
        public string caseloadOrGrpSvcRecURL;
        public string patSaveURL;
        public string patEditUrlBase;
        public string dosVal;

        protected void Page_Load(object sender, EventArgs e)
        {            
            this.includeBackgroundLayer = false; /* TODO: Consider change to true when controls that do not have enough contrast are restyled*/

            /*************************************************
             * Get references to controls
             *************************************************/

            var ctrlClientID = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
            var ctrlPracID = findControlRecu(this.Page, "selectPractitioner") as MBA.DataEntryRowSelectPractitioner;
            var ctrlLinkCalsAndBreaks = findControlRecu(this.Page, "gotomanagecalsandbreaks") as MBA.LinkInternal;
            var ctrlUseMinsPerFreqAss = findControlRecu(this.Page, Constants.PARM_USE_MINS_PER_FREQ_ASSIGNED) as MBA.RadioBox;
            var ctrlOpenDiaSvcResp = findControlRecu(this.Page, "butDoManageCalpadPrefs") as MBA.DataEntryButtonCommandToolbar;
            var ctrlDisableProgressCalcs = findControlRecu(this.Page, Constants.PARM_DISABLE_COMPLIANCE_CALC) as MBA.SelectYesOrNo;

            /*************************************************
             * Default for disableProgressCalcs is No             
             *************************************************/
            
            ctrlDisableProgressCalcs.setValue(false);
            
            /*************************************************
             * Set title and label for svc responsibilities
             * (CALPADS I Support)
             *************************************************/

            ctrlOpenDiaSvcResp.label = Spedmon.PractitionerPreferenceSpedServices.calpadsCodeSupportTitle;
            ctrlOpenDiaSvcResp.title = Spedmon.PractitionerPreferenceSpedServices.calpadsCodeSupportTooltip;

            /*************************************************
             * Get passed-in params and set important
             * variable values
             *************************************************/

            //var ctrlDOS       = findControlRecu (this.Page, "dos") as MBA.DateBox;
            clientID = (Spedmon.Validate.optClientID(uInfo, "") != null) ? Spedmon.Validate.optClientID(uInfo, "").ToString() : "";
            pracID = (Spedmon.Validate.optPracID(uInfo, "") != null) ? Spedmon.Validate.optPracID(uInfo, "").ToString() : "";
            tkn = ((this.rd.loggedIn) ? this.rd.wu.usr.token : "");
            dosVal = DateTime.Now.ToString("MM/dd/yyyy");

            /*************************************************
             * Set options for ctrlUseMinsPerFreqAss
             *************************************************/

            ctrlUseMinsPerFreqAss.AddSelection(@"All Minutes District is Required to Provide", "N", true);
            ctrlUseMinsPerFreqAss.AddSelection(@"Minutes I Am Responsible For Providing", "Y", false);
            ctrlUseMinsPerFreqAss.value = "N";

            /*************************************************
             * Set URLs for links used on screen
             *************************************************/

            ctrlLinkCalsAndBreaks.url = Clients.URL_USER_ALL_MY_ORGANIZATION;

            svcRecURL = MBA.HttpApplication.createLink(ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC
                                                                , true
                                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                , new NameValue(Constants.PARM_SVCETRMDE, Constants.SVCETRMDE_RECORD_SERVICES));

            caseloadSvcRecURL = MBA.HttpApplication.createLink(ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC
                                                                , true
                                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                , new NameValue(Constants.PARM_SVCETRMDE, Constants.SVCETRMDE_RECORD_SCHEDULED_SERVICES));

            assessmentSvcRecURL = MBA.HttpApplication.createLink(ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC
                                                                    , true
                                                                    , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                    , new NameValue(Constants.PARM_SVCETRMDE, Constants.SVCETRMDE_RECORD_MISSING_ASSMTS_CASELOAD_ONLY));

            caseloadOrGrpSvcRecURL = MBA.HttpApplication.createLink(ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC
                                                                , true
                                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
                                                                , new NameValue(Constants.PARM_SVCETRMDE, Constants.SVCETRMDE_RECORD_SERVICES));
            patSaveURL = MBA.HttpApplication.createLink(Spedmon.Patients.URL_USER_ALL_SAVE
                                                                , true
                                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));

            patEditUrlBase = Patients.URL_USER_ALL_EDIT_EXISTING_BASE(true, "");

            /**************************************************
             * set control values
            ***************************************************/

            //ctrlDOS.value = dosVal;

            // for consultants and admins, set prac and client based on what is passed
            if (uInfo.userGroup == Constants.USER_GROUP_SBSC || uInfo.userClientID == 0)
            {

                string pracID = MBA.HttpApplication.getParameter(MBA.Constants.PARM_PRACTITIONER_ID);

                if (!String.IsNullOrEmpty(pracID) && pracID != "0")
                {
                    string clientID = Practitioners.load(dbConnApp, log, uInfo, pracID).clientID.ToString();

                    if (String.IsNullOrEmpty(clientID) || clientID == "0")
                    {
                        throw new Exception("Invalid practitioner");
                    }

                    ctrlPracID.selectValue = pracID;
                    ctrlPracID.entryInitiallyHidden = true;
                    ctrlPracID.entryAllowed = false;
                    ctrlPracID.entryNotAllowedUseReplacementValue = false;

                    ctrlClientID.selectValue = clientID;
                    ctrlClientID.entryInitiallyHidden = true;
                    ctrlClientID.entryAllowed = false;
                    ctrlClientID.entryNotAllowedUseReplacementValue = false;

                }
            }
        }
    }
}
