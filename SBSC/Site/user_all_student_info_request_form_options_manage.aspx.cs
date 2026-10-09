using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * userAllStudentInfoRequestFormOptionsManage */
    /**
     ***************************************************************************/

    public class userAllStudentInfoRequestFormOptionsManage : WebUI
    {
        public string userClientID;
        public string clientIDStr    = "";
        public bool   clientIDPassed = false;
        public userAllStudentInfoRequestFormOptionsManage() : base(@"user_all_student_info_request_form_options_manage"
                                      , PatientInfoRequestOptionsCommon.SEL_LABEL_INSURANCE_OPTION_MANAGE
                                      , @"user_all_student_info_request_form_options_manage.css"
                                      , @""
                                      , Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD_CYBHI_COORD)
        { }

        protected void Page_Load(object sender, EventArgs e)
        {

            var ctrlClientID = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
           
            clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            clientIDPassed = false;

            /* preselect clientid if passed */

            if (!String.IsNullOrEmpty(clientIDStr))
            {
                clientIDPassed = true;
                var client = Clients.load(dbConnApp, log, uInfo, clientIDStr);
                ctrlClientID.selectValue = clientIDStr;
                ctrlClientID.selectName = client.name;
            }

            /*###########################################################################
              # Set default values for messages
              # We use the content in the markup for this via the runat="server" attribute
              ###########################################################################*/

            HtmlGenericControl enPrivateMsg = (HtmlGenericControl)FindControl("enPrivateMsg");
            MBA.RichTextAreaBox englishPrivateMessageCtrl = findControlRecu(this.Page, "insuranceInfoRequestMessageBodyContentPrivateEN") as MBA.RichTextAreaBox;
            englishPrivateMessageCtrl.value = enPrivateMsg.InnerHtml;
            
            HtmlGenericControl esPrivateMsg = (HtmlGenericControl)FindControl("esPrivateMsg");
            MBA.RichTextAreaBox spanishPrivateMessageCtrl = findControlRecu(this.Page, "insuranceInfoRequestMessageBodyContentPrivateES") as MBA.RichTextAreaBox;
            spanishPrivateMessageCtrl.value = esPrivateMsg.InnerHtml;
            
            HtmlGenericControl enPublicMsg = (HtmlGenericControl)FindControl("enPublicMsg");
            MBA.RichTextAreaBox englishPublicMessageCtrl = findControlRecu(this.Page, "insuranceInfoRequestMessageBodyContentPublicEN") as MBA.RichTextAreaBox;
            englishPublicMessageCtrl.value = enPublicMsg.InnerHtml;
            
            HtmlGenericControl esPublicMsg = (HtmlGenericControl)FindControl("esPublicMsg");
            MBA.RichTextAreaBox spanishPublicMessageCtrl = findControlRecu(this.Page, "insuranceInfoRequestMessageBodyContentPublicES") as MBA.RichTextAreaBox;
            spanishPublicMessageCtrl.value = esPublicMsg.InnerHtml;

            if (clientIDPassed)
            {
                string selectedclientid = ctrlClientID.selectValue;
                PatientInfoRequestsFormOption ro = PatientInfoRequestsFormOptions.load(dbConnApp, log, uInfo, selectedclientid);
                PatientInfoRequestsPublicFormOption ro1 = PatientInfoRequestsPublicFormOptions.load(dbConnApp, log, uInfo, selectedclientid);

                if (ro != null)
                {
                    englishPrivateMessageCtrl.value = (string.IsNullOrEmpty(ro.insuranceInfoRequestMessageBodyContentEN)) ? "" : ro.insuranceInfoRequestMessageBodyContentEN;
                    spanishPrivateMessageCtrl.value = (string.IsNullOrEmpty(ro.insuranceInfoRequestMessageBodyContentES)) ? "" : ro.insuranceInfoRequestMessageBodyContentES;
                }

                if (ro1 != null)
                {
                    englishPublicMessageCtrl.value = (string.IsNullOrEmpty(ro1.insuranceInfoRequestMessageBodyContentEN)) ? "" : ro1.insuranceInfoRequestMessageBodyContentEN;
                    spanishPublicMessageCtrl.value = (string.IsNullOrEmpty(ro1.insuranceInfoRequestMessageBodyContentES)) ? "" : ro1.insuranceInfoRequestMessageBodyContentES;
                }
            }
        }
    }
}