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

/*####################################################################################################################
  # NOTE: DO NOT ADD ANY AUTHORIZATION TYPE SPECIFIC CODE AT THIS LEVEL.
  # ALL CONTENT MUST BE IN TERMS OF THE GENERAL AUTHORIZATION REQUEST/RESPONSE FORMATS.
  ####################################################################################################################*/   

namespace Spedmon

{

  /***************************************************************************
   * UserAllServiceAuthorizationRequestResponseSave */
  /**
   * Form for responding to service authorization requests
   ***************************************************************************/   

  public class UserAllServiceAuthorizationRequestResponseSave : WebUI
  {
      
    
    public ServiceAuthorizationRequest sar = new ServiceAuthorizationRequest();

    public string  urlSvcSave                 = @"";
    public string  includedFiles              = @"";
    public bool    showSupportingFilesSection = false;
    public string  supportingFiles            = @"";
    public bool    showDownloadReturnedForm   = false;
    public string  responseStatusSummary      = @"";
    
    public string urlFormPrint               = @"";
    public string urlPaperFormDownload       = @"";
    public string urlPaperFormUpload         = @"";
    public string urlDeleteAndSaveNewRequest = @"";
    public string urlDeleteRequest           = @"";
    public string urlCloseAndSaveNewRequest  = @"";
   
    // used in ajax data for delete
    public string deleteAjaxDataObj          = @"";

    public UserAllServiceAuthorizationRequestResponseSave() : base(@"svc_auth_request_response_save"
	                                                           , ServiceAuthorizationRequests.SEL_LABEL_RESPOND
                                                             , @"service_authorization_requests_response_save.css"
                                                             , @""
										                     , Constants.ROLE_SVC_AUTH_RESPONDERS){} 

    protected void Page_Load(object sender, EventArgs e)
    {      
	  if (!this.rd.loggedIn) return;                           
      string recid  = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
      
      /*###########################################################################
        # Load request
        ###########################################################################*/

      sar = ServiceAuthorizationRequests.load(dbConnApp,log,uInfo,recid);
      
      /*###########################################################################
        # Determine display rules for requests and responses
        ###########################################################################*/

      ServiceAuthorizationRequests.setDisplayRules         (ref sar);
      ServiceAuthorizationRequestResponses.setDisplayRules (ref sar);

      /*###########################################################################
        # Generate various urls that will be needed
        ###########################################################################*/

      urlSvcSave                  = MBA.HttpApplication.createLink(ServiceAuthorizationRequestResponses.URL_SVC_SAVE, true);
      urlPaperFormDownload        = ServiceAuthorizationCommon.generateRequestResponseFileURL(recid);
      urlPaperFormUpload          = ServiceAuthorizationCommon.URL_UPLOAD_COMPLETED_REQUEST_FORM;

      urlDeleteAndSaveNewRequest  = MBA.HttpApplication.createLink (  ServiceAuthorizationRequests.URL_SAVE
                                                                     , true
                                                                     , new NameValue(Constants.PARM_APP_MODE,  Constants.AMD_UI_DBS_SUB_PAGE)
                                                                     , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_DELETE_AND_SAVE_NEW.ToString())
                                                                     , new NameValue(Constants.PARM_REC_ID,    sar.id.ToString())
                                                                    );
                                    
      urlDeleteRequest            = MBA.HttpApplication.createLink (  ServiceAuthorizationRequests.URL_DELETE
                                                                     , true
                                                                    );

      urlCloseAndSaveNewRequest   = MBA.HttpApplication.createLink (  ServiceAuthorizationRequests.URL_SAVE
                                                                     , true
                                                                     , new NameValue(Constants.PARM_APP_MODE,  Constants.AMD_UI_DBS_SUB_PAGE)
                                                                     , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_CLOSE_AND_SAVE_NEW.ToString())
                                                                     , new NameValue(Constants.PARM_REC_ID,    sar.id.ToString())
                                                                    );

      /* set the data object params for the delete ajax call */

      deleteAjaxDataObj = "{'" + Constants.PARM_APP_MODE                 + "':'" + Constants.AMD_UI_DBS_SUB_PAGE          + "',"
                               + "'"  + Constants.PARM_SAVE_TYPE         + "':'" + Constants.SAVE_TYPE_DELETE.ToString()  + "',"
                               + "'"  + Constants.PARM_REC_ID            + "':'" + sar.id.ToString()                      + "',"
                               + "'"  + Constants.PARM_EDIT_DEL_REASON   + "':'"                                          + "',"
                               + "'"  + Constants.PARM_VALIDATE_REC      + "':0"                                          + "}";

     /*###########################################################################
       # Get control references
       ###########################################################################*/

      var ctrlRequestID                = findControlRecu(this.Page,  "requestid")                       as MBA.HiddenInput;      
      var ctrlPracEmailLink            = findControlRecu(this.Page,  "pracemail")                       as MBA.EmailLink;
      var ctrlPracPhoneLink            = findControlRecu(this.Page,  "pracphone")                       as MBA.PhoneLink;      
      var ctrlPrevRespondantEmailLink  = findControlRecu(this.Page,  "prevRespondantEmail")             as MBA.EmailLink;
      var ctrlPrevRespondantPhoneLink  = findControlRecu(this.Page,  "prevRespondantPhone")             as MBA.PhoneLink;      
      var ctrlCurrRespondantEmailLink  = findControlRecu(this.Page,  "currRespondantEmail")             as MBA.EmailLink;
      var ctrlCurrRespondantPhoneLink  = findControlRecu(this.Page,  "currRespondantPhone")             as MBA.PhoneLink;      
      var ctrlEffectiveDate            = findControlRecu(this.Page,  "effectivedate")                   as MBA.DateBox;
      var ctrlEditDelReason            = findControlRecu(this.Page,  "editDelReason")                   as MBA.NoteAreaBox;
      var ctrlFormBuilderContentJSON   = findControlRecu(this.Page,  "formBuilderAnswersJSONForOrder")  as MBA.DataEntryRowFormBuilderRenderBox;

     /*###########################################################################
       # Set control values
       ###########################################################################*/

      ctrlRequestID.value                                 = sar.id.ToString();
      ctrlPracEmailLink.value                             = sar.districtContactEmail;
      ctrlPracPhoneLink.value                             = sar.districtContactPhone;
      ctrlPrevRespondantEmailLink.value                   = sar.prevChainRespondantEmail;
      ctrlPrevRespondantPhoneLink.value                   = sar.prevChainRespondantPhone;
      ctrlCurrRespondantEmailLink.value                   = sar.currChainRespondantEmail;
      ctrlCurrRespondantPhoneLink.value                   = sar.currChainRespondantPhone;      
      ctrlFormBuilderContentJSON.formBuilderQuestionsJSON = sar.formBuilderQuestionsJSON;
      ctrlFormBuilderContentJSON.value                    = sar.formBuilderAnswersJSON;

     /*###########################################################################
       # Get supporting files
       ###########################################################################*/
     
      ReturnInfoTable ritFiles = StoredFiles.viewInfoTable (  dbConnApp
                                                            , log
                                                            , uInfo
                                                            , sar.clientID.ToString()
                                                            , ""
                                                            , sar.patID.ToString()
                                                            , ""
                                                            , sar.fileClass.ToString()
                                                            , sar.fileNameSpace.ToString()
                                                            , sar.fileSource);

     /*###########################################################################
       # Get included files
       ###########################################################################*/
     
      includedFiles = ServiceAuthorizationRequestFilesToInclude.generateContentIncludeList ( dbConnApp
                                                                                            , log
                                                                                            , uInfo
                                                                                            , ""
                                                                                            , sar.id.ToString());

     /*###########################################################################
       # TODO: Get supporting links (ie plan writer pdf generation, etc)
       ###########################################################################*/
     
     // TODO: Write this

     /*###########################################################################
       # Determine if we show or hide certain options
       ###########################################################################*/
     
      /*------------------------------------*/
      /*          Supporting Files          */ 
      /*------------------------------------*/         

     showSupportingFilesSection = ((ritFiles.hasRecords) && (sar.dspRuleRspShowSupportingFilesSection));                     
     
     if (showSupportingFilesSection) 
       supportingFiles = ReturnInfoTable.ToHTMLTableString(ref ritFiles,"returninfo","No Files",false,false);

     /*------------------------------------*/
     /*      Download Return Form          */ 
     /*------------------------------------*/         

     showDownloadReturnedForm = sar.dspRuleRspShowDownloadReturnForm;

     /*###########################################################################
       # Set constaints for data entry
       ###########################################################################*/
     
     /* Effective date cannot be before patient date of birth*/

     if (!String.IsNullOrWhiteSpace(sar.patDOBStr))
       ctrlEffectiveDate.minDate = sar.patDOBStr;  

     /*###########################################################################
       # Set defaults
       ###########################################################################*/
     
     if (sar.currentResponseCode == (int) RequestServiceAuthorizationResponse.PENDING)
     { 
        ctrlEffectiveDate.value  = sar.requestDateStr; 
     }

     else if (sar.currentResponseCode == (int) RequestServiceAuthorizationResponse.DECLINED)
     {
       ctrlEffectiveDate.value  = sar.requestDateStr;
       ctrlEditDelReason.value  = sar.currChainResponseNotes;
     }
     else if (sar.currentResponseCode == (int) RequestServiceAuthorizationResponse.APPROVED)
     {
       /* Nothing to set */
     }
     else
     {
       ctrlEffectiveDate.value = sar.requestDateStr;
     }
   }

  }
}
