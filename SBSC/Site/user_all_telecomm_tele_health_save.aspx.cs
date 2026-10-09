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
   * UserAllTeleCommTeleHealthSave */
  /**
   * General form for creating new and editing telecomm telehealth meetings
   ***************************************************************************/   

  public class UserAllTeleCommTeleHealthSave: WebUI
  {
    public UserAllTeleCommTeleHealthSave() : base( @"user_all_telecomm_tele_health_save"
	                                       , ""
                                         , @""
                                         , @""
										                     , Constants.ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC){} 
   
    public string URL_PATIENT_GROUP_MEMBERS_VIEW_SEL = @"practitioner_patient_group_members.asmx/viewSel";
    protected void Page_Load(object sender, EventArgs e)
    {      	    

      /*###########################################################################
        # Fetch parameters 
        ###########################################################################*/    
      
      string savetype    = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
      string recid       = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
      string clientid    = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
      string pracid      = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
            
      /*###########################################################################
        # Determine save type
        ###########################################################################*/    

      Object vSaveType  = Spedmon.Validate.optInteger (savetype,  Messages.INVALID_SAVE_TYPE);
      int    saveType   = Constants.SAVE_TYPE_NEW;
      if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
      saveType  = (int) vSaveType;

     /*###########################################################################
       # Generate URLS used by client side code
       ###########################################################################*/    

      URL_PATIENT_GROUP_MEMBERS_VIEW_SEL = MBA.HttpApplication.createLink(@"practitioner_patient_group_members.asmx/viewSelByClientPrac",true);
     
      /*###########################################################################
        # Get control references
        ###########################################################################*/    
     
      var ctrlSelectClient                  = findControlRecu(this.Page,  "selectClient")              as MBA.DataEntryRowSelectClient;
      var ctrlSelectPractitioner            = findControlRecu(this.Page,  "selectPractitioner")        as MBA.DataEntryRowSelectPractitioner;      

      var ctrlSelectServiceSubType          = findControlRecu(this.Page,  "selectServiceSubType")      as MBA.DataEntryRow;
      var ctrlServiceSubType                = findControlRecu(this.Page,  "servicesubtype")            as MBA.SelectServiceSubTypeIndividualOrGroup;

      var ctrlSelectIndividualPatient       = findControlRecu(this.Page,  "selectIndividualPatient")   as MBA.DataEntryRowSelectPatient;

      var ctrlSelectGroupOfPatients         = findControlRecu(this.Page,  "selectGroupOfPatients")     as MBA.DataEntryRow;
      var ctrlPatientGroup                  = findControlRecu(this.Page,  "patgroupid")                as MBA.ComboBox;

      var ctrlEnterParticipantDetails       = findControlRecu(this.Page,  "enterParticipantDetails")   as MBA.DataEntryRow;      
      var ctrlParticipantDetails            = findControlRecu(this.Page,  "participantdetails")        as MBA.DataGrid;
      
      var ctrlEnterMeetingTitle             = findControlRecu(this.Page,  "enterMeetingTitle")         as MBA.DataEntryRow;
      var ctrlMeetingTitle                  = findControlRecu(this.Page,  "title")                     as MBA.TextBox;

      var ctrlSelectOrEnterMeetingDate      = findControlRecu(this.Page,  "selectOrEnterMeetingDate")  as MBA.DataEntryRow;
      var ctrlMeetingDate                   = findControlRecu(this.Page,  "meetingdate")               as MBA.DateBox;

      var ctrlSelectOrEnterMeetingTime      = findControlRecu(this.Page,  "selectOrEnterMeetingTime")  as MBA.DataEntryRow;
      var ctrlMeetingTime                   = findControlRecu(this.Page,  "meetingtime")               as MBA.TimeBox;
      
      var ctrlSelectOrEnterMeetingDuration  = findControlRecu(this.Page,  "selectOrEnterMeetingDuration")  as MBA.DataEntryRow;
      var ctrlMeetingDuration               = findControlRecu(this.Page,  "meetingdurationinmins")         as MBA.NumberBox;

      var ctrlSelectFiles                   = findControlRecu(this.Page,  "selectFiles")                   as MBA.DataEntryRowSelectStoredFile;

      var ctrlEnterMeetingContent           = findControlRecu(this.Page,  "enterMeetingContent")           as MBA.DataEntryRow;
      var ctrlMeetingContent                = findControlRecu(this.Page,  "content")                       as MBA.RichTextAreaBox;

      var ctrlSaveOrEdit                    = findControlRecu(this.Page,  "saveOrEdit")                as MBA.DataEntryRowSaveOrEdit;     
      var ctrlFileClass                     = findControlRecu(this.Page,  "fileclass")                 as MBA.HiddenInput;
      var ctrlFileNameSpace                 = findControlRecu(this.Page,  "filenamespace")             as MBA.HiddenInput;
      var ctrlFileSource                    = findControlRecu(this.Page,  "filesource")                as MBA.HiddenInput;

      /*###########################################################################
        # Set save type and rec id
        ###########################################################################*/          

      ctrlSaveOrEdit.saveType = saveType;
      ctrlSaveOrEdit.recID    = recid;
      
      /*###########################################################################
        # Set file class, namespace, and source data.  This is constant.
        ###########################################################################*/    

      ctrlFileClass.value      = TeleHealthSessions.VAL_FILE_CLASS;
      ctrlFileNameSpace.value  = TeleHealthSessions.VAL_FILE_NAMESPACE;
      ctrlFileSource.value     = TeleHealthSessions.VAL_FILE_SOURCE;
   
      /*###########################################################################
        # New Record
        ###########################################################################*/    

      if (saveType == Constants.SAVE_TYPE_NEW)
      {      

        this.subTitle = WebUI.CreatePageSubTitle(  TeleHealthSessions.SEL_LABEL
                                                 , TeleHealthSessions.SEL_LABEL_ADD_NEW);

        /*------------------------------------*/
        /*  If client id is passed then       */
        /*  preset select client              */
        /*------------------------------------*/

        if (!String.IsNullOrWhiteSpace(clientid))
        { 
          var c = Clients.load(dbConnApp, log, uInfo, clientid);
          ctrlSelectClient.selectValue     = c.id.ToString();
          ctrlSelectClient.selectName      = c.name;
        }

        /*------------------------------------*/
        /*  If practitioner id is passed then */
        /*  preset practitioner               */
        /*------------------------------------*/

        if (!String.IsNullOrWhiteSpace(pracid))
        {
          var p = Practitioners.load(dbConnApp,log,uInfo,pracid);
          ctrlSelectPractitioner.selectValue = p.id.ToString();
          ctrlSelectPractitioner.selectName  = p.name;
        }

        /*------------------------------------*/
        /*  If a client is already provided   */
        /*  then override entry rule defaults */
        /*------------------------------------*/

        if (ctrlSelectClient.hasValueOrValues())
        { 
          ctrlSelectClient.entryAllowed                       = false;
          ctrlSelectClient.entryNotAllowedUseReplacementValue = false;     
        }

        /*------------------------------------*/
        /*  If a prac is already provided     */
        /*  then override entry rule defaults */
        /*------------------------------------*/

        if (ctrlSelectPractitioner.hasValueOrValues())
        {
          ctrlSelectPractitioner.entryAllowed                       = false;
          ctrlSelectPractitioner.entryNotAllowedUseReplacementValue = false;     
        }
           
        /*------------------------------------*/
        /*  Initially hide some fields        */
        /*------------------------------------*/

        ctrlSelectIndividualPatient.entryInitiallyHidden = true;
        ctrlSelectGroupOfPatients.entryInitiallyHidden   = true;
        ctrlEnterParticipantDetails.entryInitiallyHidden = true;
      }
     
      /*###########################################################################
        # Edit Record
        ###########################################################################*/    

      else if (saveType == Constants.SAVE_TYPE_EDIT)
      {
         this.subTitle = WebUI.CreatePageSubTitle(  TeleHealthSessions.SEL_LABEL
                                                  , TeleHealthSessions.SEL_LABEL_EDIT);

        /*------------------------------------*/
        /*  Load previously saved record      */
        /*------------------------------------*/
        
        var ths = TeleHealthSessions.load(dbConnApp,log,uInfo,recid);
        
        /*------------------------------------*/
        /*  Repopulate fields                 */
        /*------------------------------------*/
        
        var clt = Clients.load(dbConnApp, log, uInfo, ths.clientID.ToString());
        ctrlSelectClient.selectValue     = clt.id.ToString();
        ctrlSelectClient.selectName      = clt.name;
        
        var prac = Practitioners.load(dbConnApp,log,uInfo,ths.facilitatorEntityID.ToString());
        ctrlSelectPractitioner.selectValue = prac.id.ToString();
        ctrlSelectPractitioner.selectName  = prac.name;
        
        ctrlServiceSubType.value = ths.purposeSpecificDataObj.serviceSubType;
        
        if (!String.IsNullOrWhiteSpace(ths.purposeSpecificDataObj.patID))
        { 
          var pat = Patients.load(dbConnApp, log, uInfo, ths.purposeSpecificDataObj.patID);
          ctrlSelectIndividualPatient.selectValue = pat.id.ToString();
          ctrlSelectIndividualPatient.selectName  = pat.name;
        }
        
        if (!String.IsNullOrWhiteSpace(ths.purposeSpecificDataObj.patGroupID))
        {
          /* TODO: Add a load*/
          ctrlPatientGroup.value = ths.purposeSpecificDataObj.patGroupID;
        }

    
        ctrlParticipantDetails.singleQuoteValueAttribute   = true;
        ctrlParticipantDetails.value                       = ths.participantDetailsEnteredJSON;  
        
        ctrlMeetingTitle.value    = ths.title;
        ctrlMeetingDate.value     = ths.meetingDateStr;
        ctrlMeetingTime.value     = ths.meetingTimeStr;
        ctrlMeetingDuration.value = ths.meetingDurationInMinsStr;

        if (!String.IsNullOrWhiteSpace(ths.filesToShareUploadIds))
        { 
          ctrlSelectFiles.multiSelectLoad             = true;  /* Tell control we want to load multi values*/
          ctrlSelectFiles.multiSelectNames            = ths.filesToShareUploadNames;
          ctrlSelectFiles.multiSelectValues           = ths.filesToShareUploadIds;
          ctrlSelectFiles.multiSelectContextlabels    = "";                            
        }
        
        ctrlMeetingContent.value = ths.content;

        /*------------------------------------*/
        /*  Hide non editable fields          */
        /*------------------------------------*/
        
        ctrlSelectClient.entryAllowed                             = false;
        ctrlSelectClient.entryNotAllowedUseReplacementValue       = false;     
        ctrlSelectPractitioner.entryAllowed                       = false;
        ctrlSelectPractitioner.entryNotAllowedUseReplacementValue = false;     
        ctrlSelectServiceSubType.entryAllowed                     = false;
        ctrlSelectIndividualPatient.entryAllowed                  = false;
        ctrlSelectGroupOfPatients.entryAllowed                    = false;

      
      }
      else 
      {

      }
              

    }
  }
}