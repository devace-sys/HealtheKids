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
using System.Collections.Generic;

namespace Spedmon
{
  /***************************************************************************
   * user_all_service_journals_journal_entry_save */
  /**
   * Saves a journal entry
   ***************************************************************************/   

  public class user_all_service_journals_journal_entry_save : WebUI
  {
    public string   dos               = "" 
                  , dosLbl            = "" 
                  , patName           = "" 
                  , closeJournalURL
                  , holdReason        = ""
                  , svcrectocorrectid = ""
                  , pracID     
                  , pracGroupID
                  , journalrecid;
    public bool   journalIsReopened = false
                , patAbsent;



    public user_all_service_journals_journal_entry_save() : base(   "service_journal_entry_save"
                                                                     , WebUI.CreatePageSubTitle(ServiceJournals.SEL_LABEL, ServiceJournals.SEL_LABEL_ENTRY_ADD)
                                                                     , "svcjournal_save_all.css"
                                                                     , "svcjournal_save_all.js|form-builder-patient-goal.js"
                                                                     , Constants.ROLE_SVC_JOURNALS){}
    
    protected void Page_Load(object sender, EventArgs e)
    {      	    
       /*###########################################################################
        # Get control references
        ###########################################################################*/

      var ctrlSvcrecForDOSJSON    = findControlRecu (this.Page, "svcjournalForDOSJSON" ) as MBA.HiddenTextArea;
      var ctrlClientid            = findControlRecu (this.Page, "clientid"             ) as MBA.HiddenInput;      
      var ctrlSelectPatid         = findControlRecu (this.Page, "selectPatient"        ) as MBA.DataEntryRowSelectPatient;      
      DateBoxHTML5 ctrlDOS        = findControlRecu (this.Page, "dos"                  ) as DateBoxHTML5;
      var ctrlPatname             = findControlRecu (this.Page, "patname"              ) as MBA.HiddenInput;      
      var ctrlPracid              = findControlRecu (this.Page, "pracid"               ) as MBA.HiddenInput;      
      var ctrlJournalid           = findControlRecu (this.Page, "journalid"            ) as MBA.HiddenInput;      
      var ctrlPracgroupid         = findControlRecu (this.Page, "pracgroupid"          ) as MBA.HiddenInput;      
      var ctrlSaveOrEdit          = findControlRecu (this.Page, "saveOrEdit"           ) as MBA.DataEntryRowSaveOrEdit;

      /*###########################################################################
        # Get parameters passed on URL
        ###########################################################################*/

      var clientid          = (uInfo.userClientID <= 0) ? null : uInfo.userClientIDStr;
      var patid             = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);

      // for practitioner information, we need pracID to be passed in for PCal staff and admins
      // otherwise, we get prac info from uInfo      

      // if PCal staff or admin
      if (uInfo.userGroup == Constants.USER_GROUP_SBSC || uInfo.userClientID == 0)
      {
          // get pracid from passed in params and prac groupid from prac db record
          try { 
              pracID      = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
              
              Practitioner prac = Practitioners.load(dbConnApp, log, uInfo, pracID);
              clientid          = prac.clientID.ToString();
              pracGroupID       = prac.groupID.ToString();
          } catch(Exception err)
          {
              throw new Exception(Messages.INVALID_PRAC_ID);
          }
      }
      else { 
          pracID      = uInfo.userPracIDStr;
          pracGroupID = rd.wu.pr.groupID.ToString();
      }

      journalrecid      = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);

      // if no record ID, go home or retrieve journalid as journal id
      if (string.IsNullOrEmpty(journalrecid) || journalrecid == "0") { 
        if (string.IsNullOrEmpty(MBA.HttpApplication.getParameter(ServiceJournals.PARAM_JOURNAL_ID))) { 
            string url = MBA.HttpApplication.createLink(Constants.HOME_PRIVATE, true);
            Response.Redirect(url, false);
            return;
        }
        else {
            journalrecid = MBA.HttpApplication.getParameter(ServiceJournals.PARAM_JOURNAL_ID);
        }
      }

      svcrectocorrectid = MBA.HttpApplication.getParameter(Constants.PARM_SVCREC_TO_CORRECT_ID);
      closeJournalURL   = MBA.HttpApplication.createLink (ServiceJournals.URL_PROV_CLOSE, true , new NameValue("journalid", journalrecid), new NameValue("reqautocloseexit","1"));

      ServiceJournalJournal sj = ServiceJournalsJournals.load(dbConnApp, log, uInfo, clientid, journalrecid);
      patid                    = sj.patID.ToString();
      journalIsReopened        = sj.isReopened;
      patAbsent                = sj.patientAbsent;

      /*------------------------------------*/
      /* If this is a held service,
       * get hold notes/reason              */
      /*------------------------------------*/
      if (!String.IsNullOrEmpty(svcrectocorrectid) && svcrectocorrectid != "0") {
        ServiceRecordsApprovalSvcRecsToChangeDetail svcRecToCorrect = ServiceRecordsApprovalSvcRecsToChangeDetails.load(dbConnApp, log, uInfo, svcrectocorrectid);
        holdReason = svcRecToCorrect.startTimeStr + " - " + svcRecToCorrect.endTimeStr + " : " + svcRecToCorrect.SvcReviewNotes;
      }
      
      /*------------------------------------*/
      /* Get patient information            */
      /*------------------------------------*/

      Patient p = Patients.load(dbConnApp, log, uInfo, patid);
      patName = "Patient: " + p.name;

      /*------------------------------------*/
      /* Service date                       */
      /* Default is today                   */
      /*------------------------------------*/       
      
      DateTime dosVal = DateTime.Now;
      var dosIn = sj.dos;
      if (!DateTime.TryParse(dosIn,out dosVal)) throw new InvalidOperationException("Invalid DOS for journal");
      dos = dosVal.ToString("MM/dd/yyyy"); /* HTML5 friendly format */
      dosLbl = "Date of Service: " + dos;
      
      /*###########################################################################
        # Load data into controls
        ###########################################################################*/

      ctrlClientid.value                   = clientid;
      ctrlSelectPatid.selectValue          = patid;
      ctrlSelectPatid.selectName           = p.name;
      ctrlSelectPatid.entryInitiallyHidden = true;
      ctrlSelectPatid.entryAllowed         = false;
      ctrlPatname.value                    = p.name;
      ctrlPracid.value                     = pracID;
      ctrlJournalid.value                  = journalrecid;
      ctrlDOS.value                        = (sj.dosVal == DateTime.MinValue) ? "" : dosVal.ToString("yyyy-MM-dd"); 
      ctrlPracgroupid.value                = pracGroupID;


      /*###########################################################################
        # Load journal entries
        ###########################################################################*/
      List<ServiceJournalJournalEntry> journalEntries = ServiceJournalsJournalEntries.viewList (dbConnApp,log,uInfo, clientid, journalrecid, null);
      ctrlSvcrecForDOSJSON.value = MBA.JSON.toJSONString(journalEntries, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);
    }
  }
}
