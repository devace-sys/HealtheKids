using System;
using System.Data.SqlClient;
using System.Web.UI;
using MBA;
using System.Configuration;

namespace Spedmon
{
    public class StudentInsuranceInfoRequestForm : WebUI3
    {
        public StudentInsuranceInfoRequestForm()
            : base("student_insurance_info_request_form"
                  , ""
                  , "student_information_request_form.css"
                  , "")
        {
        }

        public static string PARM_STUDENT_FIRST_NAME = "student-first-name";
        public static string PARM_STUDENT_LAST_NAME = "student-last-name";
        public static string PARM_STUDENT_DOB = "student-dob";
        public static string PARM_STUDENT_ID = "student-id";
        public static string PARM_INSURANCE_MEMBER_ID = "insurance-member-id";
        public static string PARM_INSURANCE_CARRIER_CODE = "insurance-carrier-code";
        public static string PARM_INSURANCE_CARRIER_OTHER_NAME = "insurance-carrier-other-name";
        public static string PARM_CONSENT = "consent";
        public static string PARM_RESPONDER_SIGNATURE_IMG_DATA = "responder-signature-img-data";
        public static string PARM_RESPONDER_IS_PARENT_GUARDIAN = "responder-is-parent-guardian";
        public static string PARM_RESPONDER_FIRST_NAME = "responder-first-name";
        public static string PARM_RESPONDER_LAST_NAME = "responder-last-name";
        public static string PARM_RESPONDER_EMAIL = "responder-email";
        public static string PARM_RESPONDER_PHONE = "responder-phone";

        public string MAX_DOB = "";

        public PatientInfoRequestsPublicInsuranceForm rec;

        public int promptForWhat = 0; /* 1 = Language, 2 = Information request */

        public bool commonHeaderShowRequestTitle = true;
        public bool commonHeaderShowRequestIDLabel = true;
        public bool pageInitIsOK = true;
        public bool responseMode = false;
        public bool responseShowNoInsuranceOptions = false;

        public string clientName = "";
        public string clientLogoDataURL = "";
        public string clientIDStr       = "";
        public string ptkn = "";
        public string frmReqOrRsp = "";
        public string insuranceCarrierOptions = @"";

        public string studentFirstName = "";
        public string studentLastName = "";
        public string studentDOB = "";
        public string studentID = "";
        public string insuranceMemberID = "";
        public string insuranceCarrierCode = "";
        public string insuranceCarrierOtherName = "";
        public string policyNumber = "";
        public string consent = "";
        public string responderSigImgData = "";
        public string responderIsParentGuardian = "";
        public string responderFirstName = "";
        public string responderLastName = "";
        public string responderEmail = "";
        public string responderPhone = "";
        public string requestMessageContent = "";

        public string requestURL_EN = @"";
        public string requestURL_ES = @"";
        public string requestURL_DOB = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            this.renderOptionContentOnly = true;  /* Supress framework logo headers, etc */
            this.pageInitIsOK = true;
            this.commonHeaderShowRequestTitle = true;
            this.commonHeaderShowRequestIDLabel = true;

            try
            {
                MAX_DOB = DateTime.Today.ToHTML5DateString();

                uInfo = new UserInfo();

                /* Get parameters that should be provided for any request or response */

                ptkn = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_PUBLIC_TOKEN);
                
                /* No token, get out! */

                if (String.IsNullOrWhiteSpace(ptkn))
                {
                    pageInitIsOK = false;
                    return;
                }
             
                /* Get parameters that will be either entered by user or assumed */

                frmReqOrRsp = MBA.HttpApplication.getParameter(Spedmon.Constants.PARM_FORM_REQUEST_OR_RESPONSE);

                /* If request response mode is not passed assume its a request */

                if (string.IsNullOrWhiteSpace(frmReqOrRsp)) frmReqOrRsp = Constants.FRM_REQ;


                /* If the value for request/response mode is a valid value then perform the actions
                 * needed for both request and response
                 */

                if ((frmReqOrRsp == Constants.FRM_REQ) || (frmReqOrRsp == Constants.FRM_RSP))
                {
                    /* Look up form record by token */

                    rec = PatientInfoRequestsPublicInsuranceForms.getFormByPtkn(dbConnApp, log, ptkn);

                    /* No record found, get out! */

                    if (!rec.recFound)
                    {
                        pageInitIsOK = false;
                        return;
                    }

                    /* Get client name and logo  */

                    clientLogoDataURL = rec.clientLogoFileData;
                    clientName        = rec.clientName;
                    clientIDStr       = rec.clientID.ToString();

                    /* Need a language selected */

                    if (rd.languageSpecified == false && frmReqOrRsp != Constants.FRM_RSP)
                    {
                        promptForWhat = 1;
                        pageInitIsOK = true;
                        requestURL_EN = Util.appendParmToLink(rd.requestURL, Constants.PARM_LANGUAGE, "en", true);
                        requestURL_ES = Util.appendParmToLink(rd.requestURL, Constants.PARM_LANGUAGE, "es", true);
                        this.commonHeaderShowRequestTitle = false;
                        this.commonHeaderShowRequestIDLabel = false;
                        return;
                    }
                    promptForWhat = 2;
                }

                /* If value passed for request/response mode is not valid, get out! */

                else
                {
                    pageInitIsOK = false;
                    return;
                }

                if (rd.languageSpecified == true)
                { 
                  requestMessageContent = GetLocalResourceObject("Common_Header_Text").ToString();
                  PatientInfoRequestsPublicFormOption ro = PatientInfoRequestsPublicFormOptions.load(dbConnApp, log, uInfo, clientIDStr);

                  if (ro != null)
                  {
                    if      (rd.language == "en") requestMessageContent = (string.IsNullOrEmpty(ro.insuranceInfoRequestMessageBodyContentEN)) ? "" : ro.insuranceInfoRequestMessageBodyContentEN;
                    else if (rd.language == "es") requestMessageContent = (string.IsNullOrEmpty(ro.insuranceInfoRequestMessageBodyContentES)) ? "" : ro.insuranceInfoRequestMessageBodyContentES;
                    else                          requestMessageContent = GetLocalResourceObject("Common_Header_Text").ToString();
                  }
              
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
                                                                                            , GetLocalResourceObject("Insurance_Carrier_PlaceHolder").ToString()
                                                                                            , GetLocalResourceObject("INSURANCE_CARRIER_SELECTION_OTHER").ToString()
                                                                                            , GetLocalResourceObject("INSURANCE_CARRIER_SELECTION_NO_INSURANCE").ToString());

                    }

                /* If the mode is response mode process response */

                else if (frmReqOrRsp == Constants.FRM_RSP)
                {
                    /* Set flag that controls if we render the request form or response message */

                    responseMode = true;

                    /* Get form values */

                    studentFirstName = MBA.HttpApplication.getParameter(PARM_STUDENT_FIRST_NAME);
                    studentLastName = MBA.HttpApplication.getParameter(PARM_STUDENT_LAST_NAME);
                    studentDOB = MBA.HttpApplication.getParameter(PARM_STUDENT_DOB);
                    studentID = MBA.HttpApplication.getParameter(PARM_STUDENT_ID);
                    insuranceMemberID = MBA.HttpApplication.getParameter(PARM_INSURANCE_MEMBER_ID);
                    insuranceCarrierCode = MBA.HttpApplication.getParameter(PARM_INSURANCE_CARRIER_CODE);
                    insuranceCarrierOtherName = MBA.HttpApplication.getParameter(PARM_INSURANCE_CARRIER_OTHER_NAME);
                    consent = MBA.HttpApplication.getParameter(PARM_CONSENT);
                    responderSigImgData = MBA.HttpApplication.getParameter(PARM_RESPONDER_SIGNATURE_IMG_DATA);
                    responderIsParentGuardian = MBA.HttpApplication.getParameter(PARM_RESPONDER_IS_PARENT_GUARDIAN);
                    responderFirstName = MBA.HttpApplication.getParameter(PARM_RESPONDER_FIRST_NAME);
                    responderLastName = MBA.HttpApplication.getParameter(PARM_RESPONDER_LAST_NAME);
                    responderEmail = MBA.HttpApplication.getParameter(PARM_RESPONDER_EMAIL);
                    responderPhone = MBA.HttpApplication.getParameter(PARM_RESPONDER_PHONE);

                    /* Attempt to save response data */

                    try
                    {

                        var saveResponseResult = Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.saveResponse(
                             dbConnApp
                           , log
                           , rd
                           , ptkn
                           , studentFirstName
                           , studentLastName
                           , studentDOB
                           , studentID
                           , insuranceCarrierCode
                           , insuranceMemberID
                           , insuranceCarrierOtherName
                           , responderIsParentGuardian
                           , responderFirstName
                           , responderLastName
                           , responderEmail
                           , responderPhone
                           , consent
                           , responderSigImgData
                         );

                        /* If the respondant selected no insurance then display a PSA */

                        responseShowNoInsuranceOptions = false;
                        if (saveResponseResult.confirmValue.ToString() == InsuranceCarriers.OPTION_VALUE_NO_INSURANCE.ToString())
                        {
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