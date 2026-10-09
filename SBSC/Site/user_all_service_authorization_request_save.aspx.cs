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
   * UserAllServiceAuthorizationRequestSave */
  /**
   * General form for requesting service authorization
   ***************************************************************************/   

  public class UserAllServiceAuthorizationRequestSave: WebUI
  {
      
    public ServiceAuthorizationRequest sar;
    
    public string prevRespNotes                       = @"";
    public string tkn                                 = @"";
    public string files_tbody                         = @"";
    public string patNameDisplay                      = @"";
    public string svcDescriptionReplacementWarning    = @"";
    public UserAllServiceAuthorizationRequestSave() : base(    @"svc_auth_reqest_save"
	                                                         , @"Service Authorization Request"
                                                             , @""
                                                             , @""
										                     , Constants.ROLE_ALL_PCAL_AND_CLIENT){} 

    protected void Page_Load(object sender, EventArgs e)
    {      
      
      if (!this.rd.loggedIn) return;
      tkn = this.rd.wu.usr.token;      

      var urlSvcSave = @"";
                              
      string svcAuthorizationRequestTypeID = MBA.HttpApplication.getParameter(ServiceAuthorizationRequests.PARM_NAME_AUTH_REQUEST_TYPE);
      string referencedEntityID            = MBA.HttpApplication.getParameter(ServiceAuthorizationRequests.PARM_NAME_REFD_ENTITY_ID);
      string savetype                      = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
      string recid                         = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);   

      int    saveType = 0;
      long   recID    = 0;
      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);   
      if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
      saveType = (int) vSaveType;
      savetype = saveType.ToString();

      bool loadExisting = false;
      
      /*###########################################################################
        # Get references to controls
        ###########################################################################*/          
      
      var ctrlDataEntryForm                  = findControlRecu(this.Page,  "save")                           as MBA.DataEntryRows;
      var ctrlPrevResponseNotes              = findControlRecu(this.Page,  "prevResponseNotes")              as MBA.DataEntryRow;
      var ctrlClientID                       = findControlRecu(this.Page,  "clientid")                       as MBA.HiddenInput;
      var ctrlPatID                          = findControlRecu(this.Page,  "patid")                          as MBA.HiddenInput;
      var ctrlSvcAuthorizationRequestTypeID  = findControlRecu(this.Page,  "svcauthorizationrequesttypeid")  as MBA.HiddenInput;		        
      var ctrlReferencedEntityID             = findControlRecu(this.Page,  "referencedentityid")             as MBA.HiddenInput;
      var ctrlGroupSvcClsNameID              = findControlRecu(this.Page,  "groupserviceclassnameid")        as MBA.HiddenInput;
      var ctrlReqAuthFromID                  = findControlRecu(this.Page,  "reqsvcauthfromselectionid")      as MBA.SelectRequestServiceAuthorizationFrom;
      var ctrlSvcDescription                 = findControlRecu(this.Page,  "svcdescription")                 as MBA.NoteAreaBox;
      var ctrlFormBuilderAnswersJSONForOrder = findControlRecu(this.Page,  "formBuilderAnswersJSONForOrder") as MBA.DataEntryRowFormBuilderRenderBox;

      var ctrlSelectPrtGrd                   = findControlRecu(this.Page,  "selectParentGuardian")           as MBA.DataEntryRowSelectParentOrGuardian;
      var dataEntryRowSelectServiceAuthFrom  = findControlRecu(this.Page,  "selectAuthFrom")                 as MBA.DataEntryRow;
      var dataEntryRowSelectedFilesToInclude = findControlRecu(this.Page,  "selectedFilesToIncludeEntryRow") as MBA.DataEntryRowSelectStoredFile;
      var ctrlPrtGrd2PersonID                = findControlRecu(this.Page,  "prtgrd2personid")                as MBA.HiddenInput;
      var ctrlSelectORP                      = findControlRecu(this.Page,  "selectORP")                      as MBA.DataEntryRowSelectORP;
      var ctrlSelectDistrictContact          = findControlRecu(this.Page,  "selectDistrictContact")          as MBA.DataEntryRowSelectUser;
      var ctrlSaveOrEdit                     = findControlRecu(this.Page,  "saveOrEdit")                     as MBA.DataEntryRowSaveOrEdit;

      var ctrlIncludeFilesClientID           = findControlRecu(this.Page, "includefilesclientid")      as MBA.HiddenInput;
      var ctrlIncludeFilesPracID             = findControlRecu(this.Page, "includefilespracid")        as MBA.HiddenInput;
      var ctrlIncludeFilesPatID              = findControlRecu(this.Page, "includefilespatid")         as MBA.HiddenInput;
      var ctrlIncludeFilesFileClass          = findControlRecu(this.Page, "includefilesfileclass")     as MBA.HiddenInput;
      var ctrlIncludeFilesFileNameSpace      = findControlRecu(this.Page, "includefilesfilenamespace") as MBA.HiddenInput;
      var ctrlIncludeFilesFileSource         = findControlRecu(this.Page, "includefilesfilesource")    as MBA.HiddenInput;

      /*###########################################################################
        # Set save type and rec id
        ###########################################################################*/

      ctrlSaveOrEdit.saveType = saveType;
      ctrlSaveOrEdit.recID    = "";

      /*###########################################################################
        # New requests
        ###########################################################################*/
      
      if (saveType == Constants.SAVE_TYPE_NEW)
      {
        loadExisting = false;
        urlSvcSave   = ServiceAuthorizationRequests.URL_SVC_SAVE;                     
      }

      /*###########################################################################
        # Existing request that we are going to close and then clone
        ###########################################################################*/

      else if (saveType == Constants.SAVE_TYPE_CLOSE_AND_SAVE_NEW)
      { 
        loadExisting = true;
        urlSvcSave   = ServiceAuthorizationRequests.URL_SVC_CLOSE_AND_SAVE_NEW;
      }
      
      /*###########################################################################
        # Existing request that we are going to delete and clone
        ###########################################################################*/
     
      else if (saveType == Constants.SAVE_TYPE_DELETE_AND_SAVE_NEW)
      {
        loadExisting = true;
        urlSvcSave   = ServiceAuthorizationRequests.URL_SVC_DEL_AND_SAVE_NEW;
      }
      
      /*###########################################################################
        # Unknown request, exit
        ###########################################################################*/

      else
      {
        return;
      }
      
      /*###########################################################################
        # Load request data
        ###########################################################################*/
      
      /*------------------------------------*/
      /*   New request.  Preload as much    */ 
      /*   initial data as possible         */
      /*------------------------------------*/         

      if (loadExisting == false)
      {
        sar = ServiceAuthorizationRequests.loadInitialData(dbConnApp, log, uInfo, "", svcAuthorizationRequestTypeID, referencedEntityID);
      }
     
      /*------------------------------------*/
      /*   Existing request.                */ 
      /*   Load data                        */
      /*------------------------------------*/         
     
      else 
      {
        recID = MBA.Validate.reqInteger(recid, Messages.INVALID_RECORD_ID);
        recid = recID.ToString();
        ctrlSaveOrEdit.recID = recid;        
        sar = ServiceAuthorizationRequests.load ( dbConnApp, log, uInfo, recid );                     
      }

      /*###########################################################################
        # If we don't have any preloaded or loaded data exit
        ###########################################################################*/
      
      if (sar == null) return;

      /*###########################################################################
        # Determine display rules for requests
        ###########################################################################*/
      
      ServiceAuthorizationRequests.setDisplayRules(ref sar);

      /*###########################################################################
        # If the request was for something that was previously declined, show the
        # response notes.  TODO: Move this to display rules logic
        ###########################################################################*/
    
      ctrlPrevResponseNotes.entryAllowed = false;
      prevRespNotes = @"";
      if (sar.currentResponseCode == (long) RequestServiceAuthorizationResponse.DECLINED) 
      {         
        prevRespNotes = sar.currChainResponseNotes;        
        ctrlPrevResponseNotes.entryAllowed = true;
      }

      /*###########################################################################
        # Load control values
        ###########################################################################*/

      if (sar.patID != 0)
      {
        patNameDisplay = sar.patName;        
      }
      
      ctrlDataEntryForm.dataURL               = urlSvcSave;  /* Set appropriate save URl */
      ctrlClientID.value                      = sar.clientID.ToString();
      ctrlPatID.value                         = sar.patID.ToString();

      /*------------------------------------*/
      /*  Requested service to authorize    */
      /*------------------------------------*/      

      ctrlSvcDescription.value                                     = sar.svcDescription;
      ctrlFormBuilderAnswersJSONForOrder.formBuilderQuestionsJSON  = sar.formBuilderQuestionsJSON;
      ctrlFormBuilderAnswersJSONForOrder.value                     = sar.formBuilderAnswersJSON;

      /*------------------------------------*/
      /*  Who are we requesting             *
       *  authorization from                */
      /*------------------------------------*/      

      ctrlReqAuthFromID.value = sar.reqSvcAuthFromSelectionID.ToString();

      /*------------------------------------*/
      /*  What type of request is this      *
      /*------------------------------------*/

      ctrlSvcAuthorizationRequestTypeID.value = sar.svcAuthorizationRequestTypeID.ToString();

      /*------------------------------------*/
      /*  What entity is referenced/related *
       *  to this request                   *
      /*------------------------------------*/

      ctrlReferencedEntityID.value = sar.referencedEntityID.ToString();

      /*------------------------------------*/
      /*  What practitioner group family    *
       *  (if any) is related to this       *
      /*------------------------------------*/

      ctrlGroupSvcClsNameID.value = sar.groupSvcClassNameID.ToString();
      
      /*------------------------------------*/
      /*  Parent/Guardian 1                 */
      /*------------------------------------*/

      if (sar.prtGrd1PersonID != 0)
      {
        ctrlSelectPrtGrd.selectName  = sar.prtGrd1Name;
        ctrlSelectPrtGrd.selectValue = sar.prtGrd1PersonID.ToString();
        ctrlSelectPrtGrd.email       = sar.prtGrd1Email;
        ctrlSelectPrtGrd.phone       = sar.prtGrd1Phone;
      }

      /* Note: 2nd parent guardian is not supported */

      /*------------------------------------*/
      /*  ORP                               */
      /*------------------------------------*/

      if (sar.orpPracID != 0)
      { 
        ctrlSelectORP.selectName  = sar.orpPracName;
		ctrlSelectORP.selectValue = sar.orpPracID.ToString();
        ctrlSelectORP.email       = sar.orpPracEmail;
        ctrlSelectORP.phone       = sar.orpPracPhone;
        //ctrlOrpAddress.value      = sar.orpPracPlaceAddress;
      }

      /*------------------------------------*/
      /*  District Contact                  */
      /*------------------------------------*/
    
      if (sar.districtContactUserID != 0)
      {
        ctrlSelectDistrictContact.selectName  = sar.districtContactName;
        ctrlSelectDistrictContact.selectValue = sar.districtContactUserID.ToString();
        ctrlSelectDistrictContact.email       = sar.districtContactEmail;
        ctrlSelectDistrictContact.phone       = sar.districtContactPhone;
      }

      /*------------------------------------*/
      /*  Included files support ctrls      */
      /*------------------------------------*/

      ctrlIncludeFilesClientID.value      = (sar.filesToIncludeUseClientIdDataParameter) ? sar.clientID.ToString() : "";
      ctrlIncludeFilesPracID.value        = ""; /* No prac specific file includes yet*/
      ctrlIncludeFilesPatID.value         = (sar.filesToIncludeUsePatIdDataParameter)    ? sar.patID.ToString() : "";
      ctrlIncludeFilesFileClass.value     = sar.fileClassInclude.ToString();
      ctrlIncludeFilesFileNameSpace.value = sar.fileNameSpaceInclude;
      ctrlIncludeFilesFileSource.value    = sar.fileSourceInclude;    

      /*------------------------------------*/
      /*  Selected Files to include         */
      /*------------------------------------*/
      

      if (!String.IsNullOrWhiteSpace(sar.filesToIncludeUploadIds)) 
      {
        dataEntryRowSelectedFilesToInclude.multiSelectLoad          = true;  /* Tell control we want to load multi values*/
        dataEntryRowSelectedFilesToInclude.multiSelectNames         = sar.filesToIncludeUploadNames;
        dataEntryRowSelectedFilesToInclude.multiSelectValues        = sar.filesToIncludeUploadIds;
        dataEntryRowSelectedFilesToInclude.multiSelectContextlabels = "";
      }

      /*###########################################################################
        # Show or hide sections 
        ###########################################################################*/

      /*------------------------------------*/
      /*  Who are we requesting             *
      /*  authorization from                */
      /*------------------------------------*/

      dataEntryRowSelectServiceAuthFrom.entryInitiallyHidden = false;
      if (sar.dspRuleReqShowRequestFromSelection == false)
      {
        dataEntryRowSelectServiceAuthFrom.entryInitiallyHidden = true;
      }

      /*---------------------------------------------
       * Service description/Form Data
       *--------------------------------------------*/
      
      /* If this is a request for an entity that we are retiring service descriptions (like orders and prescriptions) */
      
      if (sar.dspRuleReplaceServiceDescriptionWithForm == true)
      {
      
        if (!String.IsNullOrEmpty(sar.formBuilderQuestionsJSON) && sar.formBuilderQuestionsJSON != "[]")
        {
          ctrlSvcDescription.hidden = true;
        }
        else
        {
        
          /* Get form data for service */

          var ssn = ORPDocumentsStandardSelectionNames.load(dbConnApp, log, uInfo, sar.svcSelectionNameID.ToString());

          /* If form data exists */

          if (!String.IsNullOrEmpty(ssn.formBuilderContentJSON) && ssn.formBuilderContentJSON != "[]")
          {
            ctrlSvcDescription.readOnly                                 = true;   /* Description is now read only*/
            svcDescriptionReplacementWarning                            = sar.replaceServiceDescriptionWithFormNotice;
            ctrlFormBuilderAnswersJSONForOrder.formBuilderQuestionsJSON = ssn.formBuilderContentJSON;
            ctrlFormBuilderAnswersJSONForOrder.value                    = "";
          }
        
        }
      }

      /* Otherwise continue to switch between service descriptions and form data */

      else
      { 
      
        /* Hide form renderer if no form template exists */

        if (String.IsNullOrEmpty(sar.formBuilderQuestionsJSON) || sar.formBuilderQuestionsJSON == "[]") {
            ctrlFormBuilderAnswersJSONForOrder.entryAllowed = false;
            ctrlFormBuilderAnswersJSONForOrder.entryNotAllowedUseReplacementValue = false;
            ctrlFormBuilderAnswersJSONForOrder.entryInitiallyHidden = true;
        }
              
        /* otherwise hide service description */

        else
        {
          ctrlSvcDescription.hidden = true;
        }
      }

      /*------------------------------------*/
      /*  Parent/Guardian 1                 */
      /*------------------------------------*/
      
      ctrlSelectPrtGrd.entryInitiallyHidden = false;
      if (sar.dspRuleReqShowParentGuardianSelection == false)
      {
        ctrlSelectPrtGrd.entryInitiallyHidden = true;
      }

      /*------------------------------------*/
      /*  ORP                               */
      /*------------------------------------*/
      
      ctrlSelectORP.entryInitiallyHidden = false;
      
      if (sar.dspRuleReqShowORPSelection == false)
      {
        ctrlSelectORP.entryInitiallyHidden = true;
      }

      /*------------------------------------*/
      /*  Files to include                  */
      /*------------------------------------*/

      dataEntryRowSelectedFilesToInclude.entryInitiallyHidden = true;
      
      if (sar.hasFileIncludes == true)
      {
        dataEntryRowSelectedFilesToInclude.entryInitiallyHidden = false;
      }
      
     }
   }
}
