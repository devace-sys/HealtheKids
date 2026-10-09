using System;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web;
using System.Web.Security;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;
using MBA;
using System.Configuration;

namespace Spedmon
{
    public class MentalHealthReqesutReferralForm : WebUI3
    {
        public MentalHealthReqesutReferralForm()
            : base("mental_health_request_referral"
                  , ""
                  , "student_information_request_form.css"
                  , "")
        {
        }

        public static string PARM_STUDENT_FIRST_NAME = "student-first-name";
        public static string PARM_STUDENT_LAST_NAME = "student-last-name";
        public static string PARM_STUDENT_DOB = "student-dob";
        public static string PARM_STUDENT_ID = "student-id";
        public static string PARM_STUDENT_TEACHER = "student-teacher";
        public static string PARM_REFERRAL_SOURCE_ROLE = "pat_ref_source_role_nc";
        public static string PARM_RESPONDER_FIRST_NAME = "responder-first-name";
        public static string PARM_RESPONDER_LAST_NAME = "responder-last-name";
        public static string PARM_DETAIL_INFO = "detail-info";
        public static string PARM_FEELING_SAFE = "feelingsafevalue";
        public static string PARM_RESPONDER_EMAIL = "responder-email";
        public static string PARM_RESPONDER_PHONE = "responder-phone";

        public string MAX_DOB = "";

        public PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm rec;

        public int promptForWhat = 0; /* 1 = Language, 2 = Information request */

        public bool commonHeaderShowRequestTitle = true;
        public bool commonHeaderShowRequestIDLabel = true;
        public bool pageInitIsOK = true;
        public bool responseMode = false;

        public string clientName = "";
        public string clientLogoDataURL = "";
        public string clientIDStr = "";
        public string ptkn = "";
        public string frmReqOrRsp = "";
        public string englishYesMessageTemplate = "";
        public string spanishYesMessageTemplate = "";
        public string englishNoMessageTemplate = "";
        public string spanishNoMessageTemplate = "";

        public string studentFirstName = "";
        public string studentLastName = "";
        public string studentDOB = "";
        public string studentID = "";
        public string teacherName = "";
        public string referralSource = "";
        public string feelingSafe = "";
        public string responderFirstName = "";
        public string responderLastName = "";
        public string detailInfo = "";
        public string responderEmail = "";
        public string responderPhone = "";

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

                    rec = PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForms.getFormByPtkn(dbConnApp, log, ptkn);

                    /* No record found, get out! */

                    if (!rec.recFound)
                    {
                        pageInitIsOK = false;
                        return;
                    }

                    /* Get client name and logo  */

                    clientLogoDataURL = rec.clientLogoFileData;
                    clientName = rec.clientName;
                    clientIDStr = rec.clientID.ToString();

                    PractionerPatientReferalOption ro = PractionerPatientReferalOptions.load(dbConnApp, log, uInfo, clientIDStr);
                    englishYesMessageTemplate = (string.IsNullOrEmpty(ro.englishYesMessageTemplate)) ? "" : ro.englishYesMessageTemplate;
                    spanishYesMessageTemplate = (string.IsNullOrEmpty(ro.spanishYesMessageTemplate)) ? "" : ro.spanishYesMessageTemplate;
                    englishNoMessageTemplate = (string.IsNullOrEmpty(ro.englishNoMessageTemplate)) ? "" : ro.englishNoMessageTemplate;
                    spanishNoMessageTemplate = (string.IsNullOrEmpty(ro.spanishNoMessageTemplate)) ? "" : ro.spanishNoMessageTemplate;

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

                /* If the mode is request mode setup form */

                if (frmReqOrRsp == Constants.FRM_REQ)
                {
                    /* Set flag that controls if we render the request form or response message */

                    responseMode = false;

                }

                /* If the mode is response mode process response */

                else if (frmReqOrRsp == Constants.FRM_RSP)
                {
                    /* Set flag that controls if we render the request form or response message */

                    responseMode = true;

                    /* Get form values */

                    studentFirstName = MBA.HttpApplication.getParameterForm(PARM_STUDENT_FIRST_NAME);
                    studentLastName = MBA.HttpApplication.getParameterForm(PARM_STUDENT_LAST_NAME);
                    studentDOB = MBA.HttpApplication.getParameterForm(PARM_STUDENT_DOB);
                    studentID = MBA.HttpApplication.getParameterForm(PARM_STUDENT_ID);
                    teacherName = MBA.HttpApplication.getParameterForm(PARM_STUDENT_TEACHER);
                    responderFirstName = MBA.HttpApplication.getParameterForm(PARM_RESPONDER_FIRST_NAME);
                    responderLastName = MBA.HttpApplication.getParameterForm(PARM_RESPONDER_LAST_NAME);
                    detailInfo = MBA.HttpApplication.getParameterForm(PARM_DETAIL_INFO);
                    responderEmail = MBA.HttpApplication.getParameterForm(PARM_RESPONDER_EMAIL);
                    responderPhone = MBA.HttpApplication.getParameterForm(PARM_RESPONDER_PHONE);
                    referralSource = MBA.HttpApplication.getParameterForm(PARM_REFERRAL_SOURCE_ROLE);
                    feelingSafe = MBA.HttpApplication.getParameterForm(PARM_FEELING_SAFE);

                    string referralPriority = "1";
                    string responderIsParentGuardian = "0";
                    if (referralSource == "Parent/Guardian")
                        responderIsParentGuardian = "1";
                    if (feelingSafe == "Yes")
                        referralPriority = "3";

                    /* Attempt to save response data */

                    try
                    {

                        var saveResponseResult = Spedmon.PractitioenrPatientReferralsPublicMentalHealthRequestReferrallFormResponses.saveResponse(
                             dbConnApp
                           , log
                           , rd
                           , ptkn
                           , studentFirstName
                           , studentLastName
                           , studentDOB
                           , studentID
                           , teacherName
                           , referralPriority
                           , detailInfo
                           , responderIsParentGuardian
                           , referralSource
                           , responderFirstName
                           , responderLastName
                           , responderEmail
                           , responderPhone
                         );
                    }


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