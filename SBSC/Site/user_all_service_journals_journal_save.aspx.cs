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
   * user_all_service_journals_journal_save */
  /**
   * Saves a service journal
   ***************************************************************************/   

  public class user_all_service_journals_journal_save : WebUI
  {
    public string journalEntryScreenURL = MBA.HttpApplication.createLink(ServiceJournals.URL_USER_ALL_GO_TO_JOURNAL, true);
    public bool   showEveryonesOpenJournals = false;

    public user_all_service_journals_journal_save() : base("service_journal_save",WebUI.CreatePageSubTitle(ServiceJournals.SEL_LABEL
                                                                                                         , ServiceJournals.SEL_LABEL_OPEN_NEW)
                                                                                                         , ""
                                                                                                         , ""
                                                                                                         , Constants.ROLE_SVC_JOURNALS) {}
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /*###########################################################################
        # Fetch parameters or provide placeholders for parameters
        ###########################################################################*/    
      
      string clientid = uInfo.userClientIDStr;
      string pracid   = uInfo.userPracIDStr;      
      
      /*###########################################################################
        # Get references to controls
        ###########################################################################*/          

      SelectYesOrNo                  ctrlPatAbsent       = findControlRecu(this.Page, "patabsent")                          as SelectYesOrNo;
      DataEntryRowSelectClient       ctrlClientID        = findControlRecu(this.Page, "selectClient")                       as DataEntryRowSelectClient;
      DataEntryRowSelectPractitioner ctrlPracID          = findControlRecu(this.Page, "selectPractitioner")                 as DataEntryRowSelectPractitioner;
      RadioBox                       ctrlShowAllJournals = findControlRecu(this.Page, @"getallclientjournalsifpracallowed") as RadioBox;

      /*###########################################################################
        # Default value for absent
        ###########################################################################*/    
          
      string patAbsent      = Util.boolToYesNo(false);
      ctrlPatAbsent.value   = patAbsent;      
      
      
      if (clientid != "0") {
        ctrlClientID.selectValue  = clientid;
      }

      if (!string.IsNullOrEmpty(pracid)) {
        ctrlPracID.selectValue  = pracid;
      }

      /*#######################################################################
       * Set flag to show all open journals for client if user has access
       * ######################################################################*/
      if (rd.wu.usr.pcalStaff == true || rd.wu.usr.clientID == 0)
      { 
          showEveryonesOpenJournals = true;
      }
      else
      {
        if (rd.wu.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID)
        {
          showEveryonesOpenJournals = true;
        }
        else if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID)
        {
          if (rd.wu.pr.isAParaProfessional == false) 
             showEveryonesOpenJournals = true;
          else 
            showEveryonesOpenJournals = false;
        }
        else
        {
          showEveryonesOpenJournals = false;
        }
      }   
      
        /*###########################################################################
        # Set default value for include all open journals 
        # Note: For radio boxes we have to do this before adding selections
        ###########################################################################*/
        ctrlShowAllJournals.value = @"0";

        ctrlShowAllJournals.AddSelection(@"My Journals",     "0");
        ctrlShowAllJournals.AddSelection(@"All Journals",    "1");


    }
  }
}
