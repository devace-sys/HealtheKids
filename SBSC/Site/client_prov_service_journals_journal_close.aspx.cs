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
   * client_prov_service_journals_journal_close */
  /**
   * Saves a service journal
   ***************************************************************************/   

  public class client_prov_service_journals_journal_close : WebUI
  {
    public int saveType = 0;    
    
    public string closeJournalURL              = "";
    public string journalEntriesTable          = "";
    public string journalWarningsProblemsTable = "";
    public string journalIDParm                = ServiceJournals.PARAM_JOURNAL_ID; 
    public string journalEntryIDParm           = ServiceJournals.PARAM_JOURNAL_ENTRY_ID; 
    public bool   vDoAutoCloseExit             = false; 
    
    public client_prov_service_journals_journal_close() : base("service_journal_close"
                                                             , WebUI.CreatePageSubTitle(ServiceJournals.SEL_LABEL, ServiceJournals.SEL_LABEL_CLOSE)
                                                             , ""
                                                             , ""
                                                             , Constants.ROLE_SVC_JOURNALS){}
    
    protected void Page_Load(object sender, EventArgs e)
    {

      /*###########################################################################
        # Fetch parameters or provide placeholders for parameters
        ###########################################################################*/    
      
      string savetype         = MBA.HttpApplication.getParameter("savetype");
      string recid            = MBA.HttpApplication.getParameter("journalid");
      string reqautocloseexit = MBA.HttpApplication.getParameter("reqautocloseexit");
      
      string clientid   = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
      string pracid     = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);

      /*###########################################################################
        # Validate parameters
        ###########################################################################*/  
      
      long   vClientID,
             vPracID;

      // for consultants and staff, prac and client are passed in
      if (rd.wu.usr.pcalStaff == true || rd.wu.usr.clientID == 0) { 
          vClientID = Spedmon.Validate.reqInteger(clientid, Messages.INVALID_CLIENT_ID);
          vPracID   = Spedmon.Validate.reqInteger(pracid,   Messages.INVALID_PRAC_ID);
      } else {
          vClientID = Spedmon.Validate.reqClientID (uInfo, "");
          vPracID   = Spedmon.Validate.reqPracID   (uInfo, "");    
      }

      long   vRecID                   = Spedmon.Validate.reqInteger  (recid, @"Invalid journal id");                  
      Object vSaveType                = Spedmon.Validate.optInteger  (savetype,  Messages.INVALID_SAVE_TYPE);
      bool   vReqAutoCloseAndExit     = Spedmon.Validate.reqFlag     (reqautocloseexit,@"Invalid auto close flag",true);
      bool   vNoWarningsOrProblems    = false;
    

     /*###########################################################################
       # Set defaults
       ###########################################################################*/          

      if (vSaveType  == null) vSaveType = Constants.SAVE_TYPE_NEW;
      saveType = (int) vSaveType;

      /*###########################################################################
        # Create urls
        ###########################################################################*/    

      homeLink                 = MBA.HttpApplication.createLink (MBA.Constants.HOME_PRIVATE,               true);  
      
     /*###########################################################################
       # Reassign parameter values with results of validation
       ###########################################################################*/          

      clientid  = vClientID.ToString();
      pracid    = vPracID.ToString();

      /*###########################################################################
        # Load journal 
        ###########################################################################*/    

      ServiceJournalJournal sj = ServiceJournalsJournals.load(dbConnApp, log, uInfo, clientid, recid);

      /*###########################################################################
        # If the journal is completed get out and return to the list of open journals
        ###########################################################################*/    

      if (sj.completed == true) 
      {
          this.gotoNewURL(homeLink);
      }

     /*###########################################################################
       # Find controls
       ###########################################################################*/    
      
      WebUIControlDataField ctrlClientID = findControlRecu(this.Page, "clientid")      as WebUIControlDataField;
      WebUIControlDataField ctrlPracID   = findControlRecu(this.Page, "pracid")        as WebUIControlDataField;
      WebUIControlDataField ctrlPatID    = findControlRecu(this.Page, "patid") as WebUIControlDataField;

      /*###########################################################################
        # Set control values
        ###########################################################################*/    
              
      ctrlClientID.value    = clientid;
      ctrlPracID.value      = pracid;
      ctrlPatID.value       = sj.patID.ToString();
      
     /*###########################################################################
       # Generate html table of journal entries entered so far
       ###########################################################################*/    
            
     journalEntriesTable          = ServiceJournalsJournalEntries.generateStaticHTMLTable(dbConnApp, log, uInfo, clientid, pracid, recid, false);
     
     /*###########################################################################
       # Generate html table of any warnings or problems
       ###########################################################################*/    

     journalWarningsProblemsTable = "";
     vNoWarningsOrProblems        = false; 
     
     ReturnDataTable rdt = ServiceJournals.viewWarningsProblemsTbl(dbConnApp, log, uInfo, false,"1",null,null,clientid,recid);
     
     if (rdt.iTotalRecords > 0)
     {
       rdt.tableName   = "Warnings and Problems";
       rdt.tableFooter = rdt.iTotalRecords.ToString() + " warnings or problems";
       vNoWarningsOrProblems = false;
       journalWarningsProblemsTable = @"<div class=""svc-journal-journal-warnings-and-problems-container"">" + ReturnDataTable.createHTMLTable(ref rdt) + @"</div>"; 
     
     }
     else
     {
       journalWarningsProblemsTable = "";
       vNoWarningsOrProblems        = true;
     }
     
     /*###########################################################################
       # Determine if we should autosave
       ###########################################################################*/    

     vDoAutoCloseExit = false;
               
     if ((vReqAutoCloseAndExit == true) && (vNoWarningsOrProblems == true)){
       vDoAutoCloseExit = true;
     }
     
     /*###########################################################################
       # Find controls
       ###########################################################################*/    

     WebUIControlDataField ctrlSaveType   = findControlRecu(this.Page, "savetype")      as WebUIControlDataField;
     WebUIControlDataField ctrlRecID      = findControlRecu(this.Page, "recid")         as WebUIControlDataField;
     Steps                 ctrlSteps      = findControlRecu(this.Page, "save")          as Steps;      
     
     /*###########################################################################
       # Populate control values
       ###########################################################################*/    

     ctrlSaveType.value  = saveType.ToString();
     ctrlRecID.value     = recid;
     
     /*###########################################################################
       # Set starting step
       ###########################################################################*/    
 
     ctrlSteps.firstStep = 0;
          
    }
  }
}
