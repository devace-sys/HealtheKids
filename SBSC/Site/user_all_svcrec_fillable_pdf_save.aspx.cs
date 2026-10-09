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
using System.Text;
using MBA;
using System.Collections.Generic;

namespace Spedmon
{
    public class UserAllSvcRecFillablePdfSave : WebUI
    {
        public UserAllSvcRecFillablePdfSave() : base( @"user_all_svcrec_fillable_pdf_save"
                                                      , "Fill Out"
                                                      , @""
                                                      , @""
                                                      , Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC)
        {
        
        }
        
        public string clientID                 = "";
        public string pracID                   = "";
        public string patID                    = "";
        public string storedFileID             = "";        
        public string svcName                  = "";       
        public string svcNamesListDataSourceID = "";
        public string refDate                  = "";
        public string startTime                = "";
        public string numMins                  = "";        
        public string pdfViewerURL             = "";
        public string msgChannel               = "";
        public string selectionID              = "";
        public string answerID                 = "";
        public string formDataJSON             = "";

        public Patient    pat = null;
        public StoredFile sf  = null;

        protected void Page_Load(object sender, EventArgs e)
        {                  
          renderOptionContentOnly = true;
        
         /*###########################################################################
           # Get various parm values needed
           ###########################################################################*/

          clientID                 = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
          pracID                   = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
          patID                    = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
          storedFileID             = MBA.HttpApplication.getParameter(Constants.PARM_STORED_FILE_ID);          
          selectionID              = MBA.HttpApplication.getParameter("fpdfsid");
          svcName                  = MBA.HttpApplication.getParameter(Constants.PARM_SVC_NAME);
          refDate                  = MBA.HttpApplication.getParameter(Constants.PARM_REF_DATE);
          numMins                  = MBA.HttpApplication.getParameter(Constants.PARM_NUM_MINS);
          startTime                = MBA.HttpApplication.getParameter(Constants.PARM_START_TIME);
          svcNamesListDataSourceID = MBA.HttpApplication.getParameter(Constants.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID);
          msgChannel               = MBA.HttpApplication.getParameter(Constants.PARM_MSG_CHANNEL);
          formDataJSON             = MBA.HttpApplication.getParameter("fpdffrmdata");

         /*###########################################################################
           # Find and setup edit patient link
           ###########################################################################*/

          var ctrlGotoEditPatient = findControlRecu( this.Page, @"gotoEditPatient") as MBA.LinkInternal;
          ctrlGotoEditPatient.urlPrivate = true;
          ctrlGotoEditPatient.url        = Patients.URL_USER_ALL_SAVE;                   
          ctrlGotoEditPatient.addParameter(new NameValue(Constants.PARM_SAVE_TYPE,Constants.SAVE_TYPE_EDIT));
          ctrlGotoEditPatient.addParameter(new NameValue(Constants.PARM_REC_ID, patID));

         /*###########################################################################
           # Get info about stored file (questions data)
           ###########################################################################*/

          sf  = Spedmon.StoredFiles.load(dbConnApp,log,uInfo,storedFileID);          

         /*###########################################################################
           # Get info about patient
           ###########################################################################*/

          pat = Spedmon.Patients.load(dbConnApp,log,uInfo,patID);

         /*###########################################################################
           # Set this pages subtitle to show patient name and name of file
           ###########################################################################*/

          this.subTitle = pat.name + " - " + sf.label;

         /*###########################################################################
           # Generate pdf viewer url
           ###########################################################################*/

          pdfViewerURL = StoredFiles.generatePDFViewerURL(storedFileID);
        
        
        }
    }
}