using System;
using System.Data.SqlClient;
using System.Web.UI;
using MBA;
using System.Configuration;

namespace Spedmon
{
    public class StudentInformationRequestForm : WebUI3
    {       
        public StudentInformationRequestForm()
            : base("student_information_request_form"
                  , ""
                  , "student_information_request_form.css"
                  , "")
        {
        }
        
        
        public static string PARM_INSURANCE_CARRIER_CODE                     = "insurance-carrier-code";
        public static string PARM_INSURANCE_CARRIER_OTHER_NAME               = "insurance-carrier-other-name";
        public static string PARM_INSURANCE_CARRIER_POLICY_HOLDER_FIRST_NAME = "insurance-carrier-policy-holder-first-name";
        public static string PARM_INSURANCE_CARRIER_POLICY_HOLDER_LAST_NAME  = "insurance-carrier-policy-holder-last-name";
        public static string PARM_POLICY_NUMBER                              = "policy-number";
        public static string PARM_INSURANCE_GROUP_NUMBER_ID                  = "insurance-group-number-id";
        public static string PARM_CONSENT                                    = "consent";        
        public static string PARM_RESPONDER_SIGNATURE_IMG_DATA               = "responder-signature-img-data";
        
        public int  promptForWhat                   = 0; /* 1 = Language, 2 = DOB, 3 = Information request */
        
        public bool commonHeaderShowRequestTitle    = true;
        public bool commonHeaderShowRequestIDLabel  = true;
        public bool pageInitIsOK                    = true;        
        public bool responseMode                    = false;
        public bool responseShowNoInsuranceOptions  = false;

        public string MIN_DOB                       = DateTime.Today.AddYears(-100).ToHTML5DateString();
        public string MAX_DOB                       = DateTime.Today.ToHTML5DateString();

        public string requestIDStr            = "";
        public string clientIDStr             = "";
        public string clientName              = "";
        public string clientLogoDataURL       = "";
        public string ptkn                    = "";
        public string patDOB                  = "";
        public string patPerID                = "";
        public long   patPerIDVal             = -1;   
        public string studentIDLast2Chars     = "";
        public string studentName             = "";
        public string frmReqOrRsp             = "";
        public string requesterName           = "";
        public string requesterTitle          = "";
        public string requesterEmail          = "";
        public string requesterPhone          = "";
        public string insuranceCarrierOptions = @"";
        
        public string insuranceCarrierPolicyHolderFirstName = "";
        public string insuranceCarrierPolicyHolderLastName  = "";
        public string insuranceCarrierCode                  = "";
        public string insuranceCarrierOtherName             = "";
        public string policyNumber                          = "";
        public string insuranceGroupNumberID                = "";
        public string consent                               = "";                
        public string responderSigImgData                   = "";
        public string requestMessageContent                 = "";

        public PatientInfoRequestResponsePublic rec    = new PatientInfoRequestResponsePublic();
        public PatientInfoRequestToPerson       person = new PatientInfoRequestToPerson();

        public string requestURL_EN  = @"";
        public string requestURL_ES  = @"";
        public string requestURL_DOB = "";
        
        protected void Page_Load(object sender, EventArgs e)
        {
            this.renderOptionContentOnly         = true;  /* Supress framework logo headers, etc */
            this.pageInitIsOK                    = true;          
            this.commonHeaderShowRequestTitle    = true;
            this.commonHeaderShowRequestIDLabel  = true;

            try
            {
                uInfo = new UserInfo();
                
                /* Get parameters that should be provided for any request or response */

                ptkn        = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_PUBLIC_TOKEN);
                patPerID    = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_PAT_PER_ID);

                /* No token, get out! */

                if (String.IsNullOrWhiteSpace(ptkn))
                {
                    pageInitIsOK = false;
                    return;
                }

                /* No patient person id, get out! */

                if (String.IsNullOrWhiteSpace(patPerID))
                {
                    pageInitIsOK = false;
                    return;
                }
                
                /* Patient person id passed, test to make sure its actually an integer */
                
                else
                {
                    
                    patPerIDVal = -1;

                    /* Not an integer, get out! */
                    
                    if (!long.TryParse(patPerID,out patPerIDVal)) {
                      pageInitIsOK = false;
                      return;
                    }
                    
                    /* Its an integer but its 0 or less, get out! */

                    if (patPerIDVal <= 0) {
                      pageInitIsOK = false;
                      return;
                    }
                }
                
                /* Get parameters that will be either entered by user or assumed */

                frmReqOrRsp = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_FORM_REQUEST_OR_RESPONSE);
                //patDOB      = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_DOB);

                /* If request response mode is not passed assume its a request */

                if (string.IsNullOrWhiteSpace(frmReqOrRsp)) frmReqOrRsp = Constants.FRM_REQ;

               
                /* If the value for request/response mode is a valid value then perform the actions
                 * needed for both request and response
                 */

                if ((frmReqOrRsp == Constants.FRM_REQ) || (frmReqOrRsp == Constants.FRM_RSP))
                {
                    /* Look up info request response record by token */

                    rec = PatientInfoRequestsResponsesCommon.getPatientInfoRequestResponseByPtkn(dbConnApp, log, ptkn);

                    /* No record found, get out! */

                    if (!rec.recFound) {
                        pageInitIsOK = false;
                        return;
                    }
                    
                    /* From the info request response record extract list of persons this request was sent to */

                    var persons = PatientInfoRequestsResponsesCommon.parsePatientInfoRequestToPersonsJSONToList(rec.requestSentToJSON);

                    /* If the patient person id passed is NOT on the list, get out! */

                    if (!PatientInfoRequestsResponsesCommon.findPatientInfoRequestToPersonByPatPerID(persons,patPerIDVal,out person)) {
                        pageInitIsOK = false;
                        return;
                    }

                    /* Get client name and logo and requester name and data from info request response record */

                    requestIDStr        = rec.requestID.ToString();
                    clientLogoDataURL   = rec.clientLogoFileData;
                    clientName          = rec.clientName;
                    clientIDStr         = rec.clientID.ToString();
                    studentIDLast2Chars = rec.studentIDLast2Chars;
                    studentName         = "";
                    requesterName       = rec.requesterName;
                    requesterTitle      = rec.requesterTitle;
                    requesterEmail      = rec.requesterEmail;
                    requesterPhone      = rec.requesterPhone;
                    patDOB              = rec.dobStr;

                    /* Need a language selected */

                    if (rd.languageSpecified == false) {                      
                      promptForWhat     = 1;
                      pageInitIsOK      = true;                     
                      requestURL_EN     = Util.appendParmToLink(rd.requestURL,Constants.PARM_LANGUAGE,"en",true);
                      requestURL_ES     = Util.appendParmToLink(rd.requestURL,Constants.PARM_LANGUAGE,"es",true);
                      this.commonHeaderShowRequestTitle   = false;
                      this.commonHeaderShowRequestIDLabel = false;
                      return;
                    }
                    
                    requestMessageContent = GetLocalResourceObject("Request_Message").ToString();

                    if (rd.languageSpecified == true) { 
                      PatientInfoRequestsFormOption ro = PatientInfoRequestsFormOptions.load (dbConnApp, log, uInfo, clientIDStr);                      
                      if (ro != null)
                      {
                        if      (rd.language == "en")  requestMessageContent = (String.IsNullOrWhiteSpace(ro.insuranceInfoRequestMessageBodyContentEN)) ? "" : ro.insuranceInfoRequestMessageBodyContentEN;
                        else if (rd.language == "es")  requestMessageContent = (String.IsNullOrWhiteSpace(ro.insuranceInfoRequestMessageBodyContentES)) ? "" : ro.insuranceInfoRequestMessageBodyContentES;                        
                        else                           requestMessageContent = GetLocalResourceObject("Request_Message").ToString();                        
                      }                                       
                    }

                    bool accessGranted = false;
      
                    accessGranted = Spedmon.PatientInfoRequestsResponses.responseAccessCheck (
                        dbConnApp
                        , log
                        , rd
                        , ptkn);   
                    
                    /* If the dob was empty or did not match then return */

                    if (accessGranted == false) {                        
                        promptForWhat   = 1;                        
                        pageInitIsOK    = true;                                                
                        requestURL_DOB  = rd.requestURL;
                        return;
                      }
                    
                    /* We can prompt for info request now */
                    promptForWhat = 2;
                    
                }
               
                /* If value passed for request/response mode is not valid, get out! */
                
                else
                {
                    pageInitIsOK = false;
                    return;
                }
    
                /* If the mode is request mode setup form */

                if (frmReqOrRsp == Constants.FRM_REQ)
                {
                    /* Set flag that controls if we render the request form or response message */

                    responseMode = false;
                    
                    /* Get list of insurance carriers */
                                            
                    insuranceCarrierOptions = InsuranceCarriers.generateSelectOptionsMarkup ( dbConnApp
                                                                                            , log
                                                                                            , uInfo
                                                                                            , true
                                                                                            , true
                                                                                            , GetLocalResourceObject("INSURANCE_CARRIER_CODE_PLACEHOLDER").ToString()
                                                                                            , GetLocalResourceObject("INSURANCE_CARRIER_SELECTION_OTHER").ToString()
                                                                                            , GetLocalResourceObject("INSURANCE_CARRIER_SELECTION_NO_INSURANCE").ToString());
                }

                /* If the mode is response mode process response */

                else if (frmReqOrRsp == Constants.FRM_RSP)
                {
                    /* Set flag that controls if we render the request form or response message */
                    
                    responseMode = true;

                    /* Get form values */

                    insuranceCarrierPolicyHolderFirstName = MBA.HttpApplication.getParameter(PARM_INSURANCE_CARRIER_POLICY_HOLDER_FIRST_NAME);
                    insuranceCarrierPolicyHolderLastName  = MBA.HttpApplication.getParameter(PARM_INSURANCE_CARRIER_POLICY_HOLDER_LAST_NAME);
                    insuranceCarrierCode                  = MBA.HttpApplication.getParameter(PARM_INSURANCE_CARRIER_CODE);
                    insuranceCarrierOtherName             = MBA.HttpApplication.getParameter(PARM_INSURANCE_CARRIER_OTHER_NAME);
                    policyNumber                          = MBA.HttpApplication.getParameter(PARM_POLICY_NUMBER);
                    insuranceGroupNumberID                = MBA.HttpApplication.getParameter(PARM_INSURANCE_GROUP_NUMBER_ID);
                    consent                               = MBA.HttpApplication.getParameter(PARM_CONSENT);                    
                    responderSigImgData                   = MBA.HttpApplication.getParameter(PARM_RESPONDER_SIGNATURE_IMG_DATA);

                    /* Attempt to save response data */

                    try
                    {
                      
                       var saveResponseResult = Spedmon.PatientInfoRequestsResponses.saveResponse (
                            dbConnApp
                          , log
                          , rd
                          , ptkn
                          , insuranceCarrierCode
                          , insuranceCarrierPolicyHolderFirstName
                          , insuranceCarrierPolicyHolderLastName
                          , policyNumber
                          , insuranceGroupNumberID
                          , insuranceCarrierOtherName
                          , consent                          
                          , responderSigImgData
                          , patPerID
                        );
                      
                        /* If the respondant selected no insurance then display a PSA */

                        responseShowNoInsuranceOptions = false;
                        if (saveResponseResult.confirmValue.ToString() == InsuranceCarriers.OPTION_VALUE_NO_INSURANCE.ToString()) { 
                          responseShowNoInsuranceOptions = true;
                        }
                    } 
                    
                    /* Any problems saving, get out!*/

                    catch (Exception saveResponseError)
                    {
                        pageInitIsOK = false;
                        return;
                    }

              }

              /* Should never get here, but invalid mode, get out! */

              else
              {
                  pageInitIsOK = false;
                  return;
              }                                                                             
            }
            
            /* Any runtime errors or other exceptions, get out! */

            catch
            {
                pageInitIsOK = false;
                return;
            }

        }
    }
}