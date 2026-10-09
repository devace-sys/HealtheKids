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
    public class UserAllManagePatientsWithMissingInfo : WebUI
    {
        public string  tabToOpen                                 = "";
        public bool    isPCalStaff                               = false;
        public string  isPcalStaffJSBoolStr                      = "";
        public string  urlEditPatient                            = "";
        public bool    canAccessPatientInfoRequestResponseSystem = false;
        public bool    canAccessCombinedOptionsManageScreen      = false;
        public string  infoRequestFormBaseURL                    = "";

        public static string LABEL_BULK_INFO_REQUEST_SEND   = "Send Requests";
        public static string LABEL_BULK_INFO_REQUEST_CANCEL = "Cancel Pending Requests";
        
        public UserAllManagePatientsWithMissingInfo()
            : base (   Spedmon.PatientsWithMissingInfo.BODY_ID_MANAGE
                     , Spedmon.PatientsWithMissingInfo.SEL_LABEL_MANAGE
                     , "user_all_manage_patients_with_missing_info.css"
                     , "patient-persons.js"
                     , Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD_CYBHI_COORD )
        { }

        protected void Page_Load(object sender, EventArgs e)
        {
           isPCalStaff                               = uInfo.pcalStaff;
           isPcalStaffJSBoolStr                      = Util.netBoolToJSBool(isPCalStaff);
           urlEditPatient                            = Patients.URL_USER_ALL_EDIT_EXISTING_BASE(true,"");
           canAccessPatientInfoRequestResponseSystem = PatientInfoRequestsResponses.userHasAccess(dbConnApp,log,uInfo);
           infoRequestFormBaseURL                    = MBA.HttpApplication.createLink (PatientInfoRequestsResponsesCommon.URL_REQUEST_FORM_PUBLIC_BASE);

           canAccessCombinedOptionsManageScreen      = false;
           canAccessCombinedOptionsManageScreen      = PatientInfoRequestOptionsCommon.userCanAccessCombinedManageScreen(this.rd);

  	       var ctrlClientID             = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
           var ctrlMissingInsuranceInfo = findControlRecu(this.Page, Constants.PARM_MISSING_INSURANCE_INFO) as MBA.SelectYesOrNoOrAny;
           var ctrlMissingAddressInfo   = findControlRecu(this.Page, Constants.PARM_MISSING_ADDRESS_INFO)   as MBA.SelectYesOrNoOrAny;
           var ctrlMissingFerpaConsent  = findControlRecu(this.Page, Constants.PARM_MISSING_FERPA_CONSENT)  as MBA.SelectYesOrNoOrAny;
           var ctrlMissingPGEmails      = findControlRecu(this.Page, Constants.PARM_MISSING_PG_EMAILS)      as MBA.SelectYesOrNoOrAny;
           var ctrlDataSource           = findControlRecu(this.Page, Constants.PARM_DATA_SOURCE)            as MBA.HiddenInput;           

           var ctrlHasCurrInfoRequest   = findControlRecu(this.Page, Constants.PARM_HAS_CURR_INFO_REQUEST)                       as MBA.SelectYesIsTrueNoIsBlank;
           var ctrlHasCurrInfoRequestRR = findControlRecu(this.Page, Constants.PARM_HAS_CURR_INFO_REQUEST_THAT_REQUIRES_REVIEW)  as MBA.SelectYesIsTrueNoIsBlank;

           var ctrlRequesterName        = findControlRecu(this.Page, "requestername")                       as MBA.DataEntryBoxText;
           var ctrlRequesterEmail       = findControlRecu(this.Page, "requesteremail")                      as MBA.DataEntryBoxEmail;
           var ctrlRequesterPhone       = findControlRecu(this.Page, "requesterphone")                      as MBA.DataEntryBoxPhone;

           string clientIDStr             = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
           string missingInsuranceInfoStr = MBA.HttpApplication.getParameter(Constants.PARM_MISSING_INSURANCE_INFO);
           string missingAddressInfoStr   = MBA.HttpApplication.getParameter(Constants.PARM_MISSING_ADDRESS_INFO);
           string missingFerpaConsentStr  = MBA.HttpApplication.getParameter(Constants.PARM_MISSING_FERPA_CONSENT);
           string missingPgEmailsStr      = MBA.HttpApplication.getParameter(Constants.PARM_MISSING_PG_EMAILS);
           string dataSource              = MBA.HttpApplication.getParameter(Constants.PARM_DATA_SOURCE);

           tabToOpen = MBA.HttpApplication.getParameter(Constants.PARM_TAB_TO_OPEN);

           /* Prepopulate info for bulk requests*/

           ctrlRequesterName.value  = rd.wu.usr.name;
           ctrlRequesterEmail.value = rd.wu.usr.email;
           ctrlRequesterPhone.value = rd.wu.usr.phone;
           
           /* preselect clientid if passed */

           if (!String.IsNullOrEmpty(clientIDStr))
           {
             ctrlClientID.selectValue          = clientIDStr;
             ctrlClientID.entryInitiallyHidden = true;
             ctrlClientID.entryAllowed         = false;
           }
           
           ctrlMissingInsuranceInfo.setValueFromFlag(missingInsuranceInfoStr);                       
           ctrlMissingAddressInfo.setValueFromFlag(missingAddressInfoStr);            
           ctrlMissingFerpaConsent.setValueFromFlag(missingFerpaConsentStr);
           ctrlMissingPGEmails.setValueFromFlag(missingPgEmailsStr);
           ctrlHasCurrInfoRequest.setValue(false);
           ctrlHasCurrInfoRequestRR.setValue(false);

            if (!String.IsNullOrEmpty(dataSource)) {
                ctrlDataSource.value = dataSource;
            }
            else
            {
              ctrlDataSource.value = "1"; /* 1 = CYBHI */
            }
           
        }
    }
}
