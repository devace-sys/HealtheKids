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
    /***************************************************************************
     * SbsAllWorkflowFileViewer */
    /**
     * 
     ***************************************************************************/

    public class SbsAllWorkflowFileViewer : WebUI
    {
        public SbsAllWorkflowFileViewer() : base(@"sbs_all_workflow_file_viewer"
                                                  , "Work batch"
                                                  , @"sbs_all_workflow_file_viewer.css"
                                                  , @"sbs_all_workflow_file_viewer.js"
                                                  , Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST)
        { }

        public string PDF_VIEWER_URL = @"";
        public string batchFileName = @"";
        protected void Page_Load(object sender, EventArgs e)
        {
            string batchID = MBA.HttpApplication.getParameter(Constants.PARM_BATCH_ID);
            string fileReference = MBA.HttpApplication.getParameter(Constants.PARM_BATCH_FILE_REFERENCE);

            batchFileName = fileReference;

            string pdfFileValue = MBA.HttpApplication.createLink(ServiceRecords.URL_STORED_FILE_WORK_FLOW
                                                                    , true
                                                                    , new NameValue(Constants.PARM_BATCH_ID, batchID)
                                                                    , new NameValue(Constants.PARM_BATCH_FILE_REFERENCE, fileReference));

            PDF_VIEWER_URL = MBA.HttpApplication.createLink(StoredFiles.PDF_VIEWER_URL_BASE
                                                               , false
                                                               , new NameValue(@"file", pdfFileValue));


        }
    }
}