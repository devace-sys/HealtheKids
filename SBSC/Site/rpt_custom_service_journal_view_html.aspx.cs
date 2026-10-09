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
   * rpt_custom_service_journal_view_html */
  /**
   * Service Journal Custom Report
   ***************************************************************************/   

  public class rpt_custom_service_journal_view_html : WebCustomReport
  {
    
	  protected string  _clientID;
	  protected string  _patID;
	  protected string  _dos;
	  protected string  _journalID;
	  
	  protected ReturnDataTable  _rdReportPartEntriesEvery15;
	  protected ReturnDataTable  _rdReportPartRenderingPracSigs;
	  protected ReturnDataTable  _rdReportPartSupervisingPracSigs;
	  protected ReturnDataTable  _rdReportPartSupervisingNotes;
	  
	  protected ServiceJournalJournal             _journalObj;
	  protected ServiceJournalsServiceDescription _journalSvcDescObj;
	  protected Client                            _clientObj;
	  
    protected bool _svcDescExists         = false;
    protected bool _journalExists         = false;
    protected bool _clientExists          = false;

	  public string   ClientName               = "";
	  public bool     ElectronicApproval       = true;
	  public long     NumRenderingPracs        = 0;
	  public long     NumSupervisingPracs      = 0;
	  public long     NumSupervisingPracsNotes = 0;
	  
	  public string   ReportName               = "";
	  public string   ReportGeneratedOn        = "";
	  public string   ReportConfidential       = "";
	  public string   PatientName              = "";
	  public string   DateOfService            = "";
	  public string   PatientAttendance        = "";
	  public string   JournalStatus            = "";
	  
	  public string   Diagnosis                = "";
	  public string   MDOrders                 = ""; 
	  public string   ServiceDescription       = "";
	  public string   ExpectedOutcomes         = "";
	  
	  public string   ReportPartEntriesEvery15               = "";
	  public string   ReportPartEntriesRenderingPracSigs     = "";
	  public string   ReportPartEntriesSupervisingPracSigs   = "";
	  public string   ReportPartEntriesSupervisingPracsNotes = "";
	  
	  public rpt_custom_service_journal_view_html() : base(Constants.ROLE_ALL_PCAL_AND_CLIENT){
	
	  }
    
    protected void Page_Load(object sender, EventArgs e) {  
    
      /*###########################################################################
        # Report headers
        ###########################################################################*/    

      ReportName         = @"Specialized Physical Health Care - Scheduled Services";
      ReportGeneratedOn  = @"This report was generated on/at : " + DateTime.Now.ToString();
      ReportConfidential = Messages.CONFIDENTIAL;
      
      /*###########################################################################
        # Fetch parameters or provide placeholders for parameters
        ###########################################################################*/    
      
      _clientID  = MBA.HttpApplication.getParameter(ServiceJournals.PARAM_CLIENT_ID);      
      _journalID = MBA.HttpApplication.getParameter(ServiceJournals.PARAM_JOURNAL_ID);
            
      /*###########################################################################
        # Validate parameters
        ###########################################################################*/          
      
      long _vClientID = Spedmon.Validate.reqClientID (uInfo, _clientID);
      long _vJournaID = Spedmon.Validate.reqInteger  (_journalID, @"Invalid journal id");

      /*###########################################################################
        # Set defaults and reassign parameter values
        ###########################################################################*/  

      _clientID  = _vClientID.ToString();
      _journalID = _vJournaID.ToString();
    
      /*###########################################################################
        # Load client
        ###########################################################################*/  
      
      try {

        _clientObj             = Clients.load(dbConnApp,log,uInfo,_clientID);
        _clientExists          = true;
        ElectronicApproval     = _clientObj.svcRecApprovalSystem;
      }      
      
      /*-------------------------------
       * Client not found
       *------------------------------*/

      catch (Warning loadWarning) {
        if (loadWarning.Message == Messages.RECORD_NOT_FOUND)
          _clientExists = false;
        else
          throw (loadWarning);
      }
      
      /*###########################################################################
        # If client not found get out
        ###########################################################################*/  
      
      if (_clientExists == false) return;
      
      
      /*###########################################################################
        # Load journal
        ###########################################################################*/  

      try {

        _journalObj       = ServiceJournalsJournals.load(dbConnApp,log,uInfo,_clientID,_journalID);
        _journalExists    = true;
        _patID            = _journalObj.patID.ToString();
        _dos              = _journalObj.dos;      
     
        ClientName        = _journalObj.clientName;
        PatientName       = _journalObj.patName;
        DateOfService     = _journalObj.dos;
        PatientAttendance = _journalObj.patAbsentOrPresentStr;
        JournalStatus     = _journalObj.closedOrOpenStr;
        
      }      
      
      /*-------------------------------
       * Journal not found
       *------------------------------*/

      catch (Warning loadWarning) {
        if (loadWarning.Message == Messages.RECORD_NOT_FOUND)
          _journalExists = false;
        else
          throw (loadWarning);
      }

      /*-------------------------------
       * Other problem loading journal
       *------------------------------*/

      catch (Exception loadException) {
        throw(loadException);
      }
      
      /*###########################################################################
        # If journal is not found get out
        ###########################################################################*/  

      if (_journalExists == false) return;
             
      /*###########################################################################
        # Load journal service description
        ###########################################################################*/  

      try {        
        
        ReturnServiceJournalsServiceDescription _retSvcDescObj = ServiceJournalsServiceDescriptions.getServiceJournalsServiceDescription(dbConnApp,log,uInfo,_clientID,_patID,_dos);
        _svcDescExists      = true;
        _journalSvcDescObj  = _retSvcDescObj.serviceDescription;

        Diagnosis          = _journalSvcDescObj.diagnosis;
        MDOrders           = _journalSvcDescObj.mdOrders;
        ServiceDescription = _journalSvcDescObj.serviceDescription;
        ExpectedOutcomes   = _journalSvcDescObj.expectedOutcomes;   
             
      }

      /*-------------------------------
       * Service description not found
       *------------------------------*/

      catch (Warning loadWarning) {
        if (loadWarning.Message == Messages.RECORD_NOT_FOUND)
          _svcDescExists = false;
        else
          throw (loadWarning);
      }
      
      /*-------------------------------
       * Other issue with loading 
       * service description
       *------------------------------*/

      catch (Exception loadException) {
        throw(loadException);
      }
      
      /*###########################################################################
        # Get report parts
        ###########################################################################*/  

      _rdReportPartEntriesEvery15      = ServiceJournals.viewReportPartEntriesEvery15Tbl        (dbConnApp, log, uInfo, false, "", "", "", _clientID, _journalID);
      _rdReportPartRenderingPracSigs   = ServiceJournals.viewReportPartPracsRenderingSigsTbl    (dbConnApp, log, uInfo, false, "", "", "", _clientID, _journalID);
      _rdReportPartSupervisingPracSigs = ServiceJournals.viewReportPartPracsSupervisingSigsTbl  (dbConnApp, log, uInfo, false, "", "", "", _clientID, _journalID);
      _rdReportPartSupervisingNotes    = ServiceJournals.viewReportPartPracsSupervisingNotesTbl (dbConnApp, log, uInfo, false, "", "", "", _clientID, _journalID);

      if (_rdReportPartRenderingPracSigs.hasRecords == true) {
          NumRenderingPracs = _rdReportPartRenderingPracSigs.iTotalRecords;
      }
      
      if (_rdReportPartSupervisingPracSigs.hasRecords == true) {
        NumSupervisingPracs = _rdReportPartSupervisingPracSigs.iTotalRecords;
      }

      if (_rdReportPartSupervisingNotes.hasRecords == true) {
        NumSupervisingPracsNotes = _rdReportPartSupervisingNotes.iTotalRecords;
      }
      
      /*###########################################################################
        # Generate HTML tables
        ###########################################################################*/  
      
      ReportPartEntriesEvery15               = ReturnDataTable.createHTMLTableNoStyle (ref _rdReportPartEntriesEvery15);
      ReportPartEntriesRenderingPracSigs     = ReturnDataTable.createHTMLTableNoStyle (ref _rdReportPartRenderingPracSigs);      
      ReportPartEntriesSupervisingPracSigs   = ReturnDataTable.createHTMLTableNoStyle (ref _rdReportPartSupervisingPracSigs);
      ReportPartEntriesSupervisingPracsNotes = ReturnDataTable.createHTMLTableNoStyle (ref _rdReportPartSupervisingNotes);
           
    }
  }
}
