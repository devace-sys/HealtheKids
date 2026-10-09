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
   * UserAllPatientProfileSave */
  /**
   * General form for creating new and editing existing patient profiles
   ***************************************************************************/   

  public class UserAllPatientProfileSave: WebUI
  {
      
    // this is the request authorization URL
    public string requestAuthorizationURL = MBA.HttpApplication.createLink(ServiceAuthorizationRequests.URL_SAVE, true);

    // authorization history table 
    public string authHistTbl = "";

    public string patNameDisplay = "";

    public DataEntryRowFormBuilderRenderBox ctrlFormBuilderContentJSON;


    public UserAllPatientProfileSave() : base( @"user_all_patient_profile_save"
	                                         , WebUI.CreatePageSubTitle(ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW)
                                             , @""
                                             , @""
                                             , Constants.ROLE_SVC_SUP_PRAC){} 


    protected void Page_Load(object sender, EventArgs e)
    {      	 
        /*###########################################################################
        # Fetch parameters 
        ###########################################################################*/

        string savetype = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
        string recid = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
        string patclientid = MBA.HttpApplication.getParameter(Constants.PARM_PAT_CLIENT_ID);
        string patpatientid = MBA.HttpApplication.getParameter(Constants.PARM_PAT_PAT_ID);
        string patgrpsvcclsdmeid = MBA.HttpApplication.getParameter(Constants.PARM_PAT_GRP_SVC_CLS_NME_ID);
        string patpracid = MBA.HttpApplication.getParameter(Constants.PARM_PAT_PRAC_ID);

        string url = MBA.HttpApplication.createLink(ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_NEW
                                                          , true
                                                          , new NameValue(Constants.PARM_SAVE_TYPE,              savetype)
                                                          , new NameValue(Constants.PARM_REC_ID,                 recid)
                                                          , new NameValue(Constants.PARM_PAT_CLIENT_ID,          patclientid)
                                                          , new NameValue(Constants.PARM_PAT_PAT_ID,             patpatientid)
                                                          , new NameValue(Constants.PARM_PAT_GRP_SVC_CLS_NME_ID, patgrpsvcclsdmeid)
                                                          , new NameValue(Constants.PARM_PAT_PRAC_ID,            patpracid)                                                          
                                                    );
        Response.Redirect(url, false);
        Context.ApplicationInstance.CompleteRequest();
    }
  }
}