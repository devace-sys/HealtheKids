using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;
using System.Text.RegularExpressions;
using MBA;
using System.IO;

namespace Spedmon
{
    public class QuestionForm : WebUI
    {
        public QuestionForm() : base("Question form", "Please answer each of the following questions.", "", "") { }

        public string qFormMode   = "";
        public bool allAnswered   = true;
        public const string qtkn  = "qftkn";
        public const string mode = "qformmode";
        protected void Page_Load(object sender, EventArgs e)
        {

            string qtoken = MBA.HttpApplication.getParameter(qtkn);
            qFormMode     = MBA.HttpApplication.getParameter(mode);

            int ct = this.Context.Request.Params.Count;            
            /*-------------------------------
             * Load record, if its not
             * found or all questions answered get out
             *------------------------------*/


            QformDetails details = new QformDetails();

            details = Qforms.load(dbConnUser,dbConnApp, qtoken);

            if (details.details.Count == 0) qFormMode = "2";

            if (qFormMode != "2")
            {
            Instructions qfromInstructions = findControlRecu(this.Page, "qformIntructions") as Instructions;

            string repTitleStr  = String.Format("These questions are for school year {0}</br>If you have any questions please contact your district represenative {1}", details.details[0].OldestDOSOnQform, details.details[0].RepName);
            string repDetailStr = String.Format(@"<sub>Email</sub> {0} <sub>Phone</sub> {1}", details.details[0].RepEmail, details.details[0].RepPhone);
            string repMsgStr = repTitleStr + "<br/>" + repDetailStr;

            qfromInstructions.title = repMsgStr;
            }
            if (qFormMode == "0")
            {
                MBA.HiddenInput ctrlQToken = findControlRecu(this.Page, "qftkn") as MBA.HiddenInput;
                MBA.HiddenInput ctrlQFormMode = findControlRecu(this.Page, "qformmode") as MBA.HiddenInput;

                Steps form = findControlRecu(this.Page, "RequestResponseForm") as Steps;


                ctrlQToken.value = qtoken;
                ctrlQFormMode.value = qFormMode;
                RawHTML frmQA = findControlRecu(this.Page, "qformrequestcontent") as RawHTML;
                StringBuilder sbQA = new StringBuilder();

                int i = 1;
                foreach (QformDetail detail in details.details)
                {

                        string idxStr = detail.id.ToString();
                        string q = detail.Question; //String.Format("Your {0} question", idxStr);
                        string a = detail.Answer; //String.Format("Previous answer for {0}", idxStr);

                        string qPr = String.Format(@"<p style=""padding:.50em;font-size:1em;font-weight:bold;"" class=""qform"">{0}</p>", q);
                        string aTa = String.Format(@"<textarea id=""a{0}"" name=""a{0}"" class=""qform"">{1}</textarea>", idxStr, a);
                        string faBu = String.Format(@"<button id=""fa{0}"" data-list-id = ""fl{0}"" type=""button"" class=""qform qform-add-file"">Add File</button>", idxStr);
                        string fUl = String.Format(@"<ol id=""fl{0}""></ol>", idxStr);

                        sbQA.Append(@"<div class=""ui-widget qform-qaf"">");
                        sbQA.Append(@"<div class=""ui-widget-header"">");
                        sbQA.Append(qPr);
                        sbQA.Append(@"</div>");
                        sbQA.Append(@"<div class=""ui-widget-content"">");
                        sbQA.Append(aTa);
                        sbQA.Append("<div>");
                        sbQA.Append(faBu);
                        sbQA.Append("</div>");
                        sbQA.Append(fUl);
                        sbQA.Append("</div>");
                        sbQA.Append("</div>");
                        i++;
                }

                    frmQA.html = sbQA.ToString();

                

                Qforms.InfoRequestResponseAuditLog(this.dbConnUser, details.details[0].InfoRequestResponseID.ToString(), details.details[0].Status.ToString(), HttpContext.Current.Request.UserHostAddress);

            }

            else if (qFormMode == "1")
            {
                string openedOn    = "";
                string respondedOn = "";
                string status      = details.details[0].Status.ToString();

                if (Convert.ToInt16(status) > Convert.ToInt16(Constants.QFORM_STATE_SENT))
                {
                    openedOn    = details.details[0].OpenedOn.ToShortDateString();
                }
                else
                {
                    openedOn = DateTime.Now.ToShortDateString();
                    status   = Constants.QFORM_STATE_OPENED;
                }

                 if (Convert.ToInt16(status) >= Convert.ToInt16(Constants.QFORM_STATE_RESPONDED))
                     respondedOn = details.details[0].RespondedOn.ToShortDateString();

                foreach (QformDetail detail in details.details)
                {
                    if (MBA.HttpApplication.getParameter("a" + detail.id.ToString()) == "")
                    {
                        allAnswered      = false;
                        break;
                    }                    
                }

                /* Check to see if a response file folder exists for this response for this batch */

                string refBatchID = details.details[0].ReferenceID.ToString();
                string irrID = details.details[0].InfoRequestResponseID.ToString();

                Object QformDir = System.Web.Configuration.WebConfigurationManager.AppSettings["appWebQformSaveDir"];

                if (QformDir == null) {throw new InvalidOperationException ("appWebQformSaveDir path not specified in config");}

                string SaveDirectory = QformDir.ToString();
                    
                string BatchSaveDirectory = Path.Combine(SaveDirectory, refBatchID);
                string irrSaveDirectory = Path.Combine(BatchSaveDirectory, irrID);


                /*-------------------------------    
                    * Get references to uploaded 
                    * file
                    *------------------------------*/

                for (int i = 0; i<Request.Files.Count;i++)
                {
                    HttpPostedFile file = Request.Files[i];
                    /*-------------------------------    
                     * If a file has been uploaded
                     *------------------------------*/

                    if (file != null && file.ContentLength > 0)
                    {
                        /* Determine which reponse question it belongs to & trim field key so it matches response detail ID. */
                        String irrDetailID = Request.Files.GetKey(i).Substring(0, Request.Files.GetKey(i).IndexOf('_')).Replace("fl", "");
                        String irrFolderPath_Detail = Path.Combine(irrSaveDirectory, irrDetailID);

                        if (!Directory.Exists(irrFolderPath_Detail))
                        {
                            /* CreateDirectory will recursively create directories that were specified in path but do not exist. */
                            Directory.CreateDirectory(irrFolderPath_Detail);
                        }

                        /*-------------------------------    
                         * Create unique file name
                         *------------------------------*/

                        string fNameUploaded = Path.GetFileName(file.FileName);
                        string fNameUploadedExt = Path.GetExtension(fNameUploaded);
                        string uniqueStr = Guid.NewGuid().ToString();
                        string uniqueFName = String.Format("{0}{1}", uniqueStr, fNameUploadedExt);


                        /*-------------------------------    
                         * Prepend the upload path
                         * directory
                         *------------------------------*/

                        string fSave = Path.Combine(irrFolderPath_Detail, uniqueFName);

                        /*-------------------------------    
                         * Save the file 
                         *------------------------------*/

                        file.SaveAs(fSave);

                        /*----------------------------
                         * Store original filename to retrieve in workflow
                         * ---------------------------*/

                        Qforms.InfoRequestResponseAddFile(this.dbConnUser, irrDetailID, uniqueFName, fNameUploaded);
                        
                    
                    }
                }

                foreach (QformDetail detail in details.details)
                {
                    
                    string detailID = detail.id.ToString();
                    string answer = MBA.HttpApplication.getParameter("a" + detailID);
                    if (!string.IsNullOrEmpty(answer))
                    {
                        Qforms.InfoRequestResponseDetailSaveAnswers(this.dbConnUser, detailID, answer);
                        if (respondedOn == "")
                        {
                            respondedOn = DateTime.Now.ToShortDateString();
                            status      = Constants.QFORM_STATE_RESPONDED;
                        }
                    }           
                }

                if (allAnswered) status = Constants.QFORM_STATE_ANSWERED;

                Qforms.InfoRequestResponseUpdate(this.dbConnUser, this.dbConnApp, irrID, openedOn, respondedOn, status, details.details[0].ReferenceID.ToString(), HttpContext.Current.Request.UserHostAddress);

            }

        }        

    }
}
