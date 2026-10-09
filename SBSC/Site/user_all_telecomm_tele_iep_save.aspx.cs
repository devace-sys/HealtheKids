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
   * UserAllTeleCommTeleIEPSave*/
  /**
   * General form for creating new and editing telecomm iep meetings
   ***************************************************************************/   

  public class UserAllTeleCommTeleIEPSave: WebUI
  {
    public UserAllTeleCommTeleIEPSave() : base( @"user_all_telecomm_tele_iep_save"
	                                       , ""
                                         , @""
                                         , @""
										                     , Constants.ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC){} 
   
    protected void Page_Load(object sender, EventArgs e)
    {      	    
     
      /*###########################################################################
        # Fetch parameters 
        ###########################################################################*/    
      
      string savetype    = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
      string recid       = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
      string clientid    = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
      string patid       = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
            
      /*###########################################################################
        # Determine save type
        ###########################################################################*/    

      Object vSaveType  = Spedmon.Validate.optInteger (savetype,  Messages.INVALID_SAVE_TYPE);
      int    saveType   = Constants.SAVE_TYPE_NEW;
      if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
      saveType  = (int) vSaveType;
     
      /*###########################################################################
        # Get control references
        ###########################################################################*/    
     
      var ctrlSelectClient                  = findControlRecu(this.Page,  "selectClient")           as MBA.DataEntryRowSelectClient;
      var ctrlSelectFacilitator             = findControlRecu(this.Page,  "selectFacilitator")      as MBA.DataEntryRowSelectUser;
      var ctrlSelectPatient                 = findControlRecu(this.Page,  "selectPatient")          as MBA.DataEntryRowSelectPatient;

      var ctrlSelectIEPFormType             = findControlRecu(this.Page,  "selectIEPFormType")      as MBA.DataEntryRow;
      var ctrlIEPFormType                   = findControlRecu(this.Page,  "iepformtype")            as MBA.ComboBox;

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

      ctrlFileClass.value      = TeleIEPSessions.VAL_FILE_CLASS;
      ctrlFileNameSpace.value  = TeleIEPSessions.VAL_FILE_NAMESPACE;
      ctrlFileSource.value     = TeleIEPSessions.VAL_FILE_SOURCE;
   
      /*###########################################################################
        # New Record
        ###########################################################################*/    

      if (saveType == Constants.SAVE_TYPE_NEW)
      {      

        var clientPassed = false;
        var patPassed    = false;
        string patName   = "";
        
        /*------------------------------------*/
        /*  If client id is passed then       */
        /*  preset select client              */
        /*------------------------------------*/

        if (!String.IsNullOrWhiteSpace(clientid))
        { 
          var c = Clients.load(dbConnApp, log, uInfo, clientid);
          ctrlSelectClient.selectValue     = c.id.ToString();
          ctrlSelectClient.selectName      = c.name;
          clientPassed = true;
        }

        /*------------------------------------*/
        /*  If patient id is passed then      */
        /*  preset patient                    */
        /*------------------------------------*/

        if (!String.IsNullOrWhiteSpace(patid))
        {
          var p = Patients.load(dbConnApp,log,uInfo,patid);
          ctrlSelectPatient.selectValue = p.id.ToString();
          ctrlSelectPatient.selectName  = p.name;
          patName = p.name;
          patPassed = true;
        }

        /*------------------------------------*/
        /* If a client is already provided    */
        /* then override entry rule defaults  */
        /*------------------------------------*/

        if (clientPassed)
        { 
          ctrlSelectClient.entryAllowed                       = false;
          ctrlSelectClient.entryNotAllowedUseReplacementValue = false;     
        }

        /*------------------------------------*/
        /* If a patient is already provided   */
        /* then override entry rule defaults  */ 
        /*------------------------------------*/

        if (patPassed)
        {
          ctrlSelectPatient.entryAllowed                       = false;
          ctrlSelectPatient.entryNotAllowedUseReplacementValue = false;     
        }

        /*------------------------------------*/
        /* If clientid and patientid are      */
        /* provided then attempt to prefill   */
        /* some of the fields with previously */
        /* recorded data.                     */
        /*------------------------------------*/
        
        if ((clientPassed) && (patPassed)) {                  
          var tis = TeleIEPSessions.loadLastEnteredForClientPatient(dbConnApp,log,uInfo,clientid,patid); /* Note if no data is found this method will provide the predefined participant data required */
          if (!String.IsNullOrEmpty(tis.iepFormTypeName)) ctrlIEPFormType.selectName = tis.iepFormTypeName;
          if (tis.purposeSpecificDataObj != null) ctrlIEPFormType.value = tis.purposeSpecificDataObj.iepFormType;
          ctrlParticipantDetails.singleQuoteValueAttribute   = true;
          if (!String.IsNullOrEmpty(tis.participantDetailsEnteredJSON)) ctrlParticipantDetails.value = tis.participantDetailsEnteredJSON;
          else ctrlParticipantDetails.value = TeleIEPSessions.createNewParticipantDetails();
        }
        
        /*------------------------------------*/
        /* Otherwise we will have to start    */
        /* with no preloaded participant      */
        /* data                               */
        /*------------------------------------*/

        else { 
          /* Generate fixed # of participants */
          ctrlParticipantDetails.singleQuoteValueAttribute   = true;        
          ctrlParticipantDetails.value                       = TeleIEPSessions.createNewParticipantDetails();
        }
        
        /*------------------------------------*/
        /* For non practi-cal users preload   */
        /* meeting contact with the current   */
        /* user                               */
        /*------------------------------------*/

        if (!uInfo.pcalStaff) {
          var u = Users.load(dbConnUser,log,uInfo,uInfo.useridStr);          
          ctrlSelectFacilitator.selectValue = u.id.ToString();
          ctrlSelectFacilitator.selectName  = u.name;
        }

        /*------------------------------------*/
        /*  Generate Subtitle                 */
        /*------------------------------------*/

        this.subTitle = WebUI.CreatePageSubTitle(  TeleIEPSessions.SEL_LABEL
                                                 , TeleIEPSessions.SEL_LABEL_ADD_NEW
                                                 , patName
                                                );

      }
     
      /*###########################################################################
        # Edit Record
        ###########################################################################*/    

      else if (saveType == Constants.SAVE_TYPE_EDIT)
      {

        /*------------------------------------*/
        /*  Load previously saved record      */
        /*------------------------------------*/
        
        var tis = TeleIEPSessions.load(dbConnApp,log,uInfo,recid);
        
        /*------------------------------------*/
        /*  Generate Subtitle                 */
        /*------------------------------------*/

        this.subTitle = WebUI.CreatePageSubTitle(  TeleIEPSessions.SEL_LABEL
                                                 , TeleIEPSessions.SEL_LABEL_EDIT
                                                 , tis.patName);

        /*------------------------------------*/
        /*  Repopulate fields                 */
        /*------------------------------------*/
        
        var clt = Clients.load(dbConnApp, log, uInfo, tis.clientID.ToString());
        ctrlSelectClient.selectValue     = clt.id.ToString();
        ctrlSelectClient.selectName      = clt.name;
        
        var pat = Patients.load(dbConnApp, log, uInfo, tis.purposeSpecificDataObj.patID);
        ctrlSelectPatient.selectValue = pat.id.ToString();
        ctrlSelectPatient.selectName  = pat.name;

        var usr = Spedmon.Users.load(dbConnUser,log,uInfo,tis.facilitatorUserID.ToString());
        ctrlSelectFacilitator.selectValue = usr.id.ToString();
        ctrlSelectFacilitator.selectName  = usr.name;

        ctrlIEPFormType.value = tis.purposeSpecificDataObj.iepFormType;
                   
        ctrlParticipantDetails.singleQuoteValueAttribute   = true;
        ctrlParticipantDetails.value                       = tis.participantDetailsEnteredJSON;  
        
        ctrlMeetingTitle.value    = tis.title;
        ctrlMeetingDate.value     = tis.meetingDateStr;
        ctrlMeetingTime.value     = tis.meetingTimeStr;
        ctrlMeetingDuration.value = tis.meetingDurationInMinsStr;

        if (!String.IsNullOrWhiteSpace(tis.filesToShareUploadIds))
        { 
          ctrlSelectFiles.multiSelectLoad             = true;  /* Tell control we want to load multi values*/
          ctrlSelectFiles.multiSelectNames            = tis.filesToShareUploadNames;
          ctrlSelectFiles.multiSelectValues           = tis.filesToShareUploadIds;
          ctrlSelectFiles.multiSelectContextlabels    = "";                            
        }
               
        /*------------------------------------*/
        /*  Hide non editable fields          */
        /*------------------------------------*/
        
        ctrlSelectClient.entryAllowed                             = false;
        ctrlSelectClient.entryNotAllowedUseReplacementValue       = false;     
        ctrlSelectPatient.entryAllowed                            = false;
        ctrlSelectIEPFormType.entryAllowed                        = false;
     
      }
      else 
      {

      }
              

    }
  }
}