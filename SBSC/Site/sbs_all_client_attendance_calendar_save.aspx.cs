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

namespace Spedmon
{
  /***************************************************************************
   * SBSAllClientAttendanceCalendarSave */
  /**
   * Saves an attendance calendar
   ***************************************************************************/   

  public class SBSAllClientAttendanceCalendarSave : WebUI
  {
    public int saveType = 0;
   
    public SBSAllClientAttendanceCalendarSave() : base("attendance_calendar_save",WebUI.CreatePageSubTitle(ClientAttendanceCalendars.SEL_LABEL, ClientAttendanceCalendars.SEL_LABEL_ADD),"","",Constants.ROLE_SBS_ALL){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /*-------------------------------
       * Determine what save type
       * this is 
       *------------------------------*/ 
      
      string recid     = MBA.HttpApplication.getParameter("recid");
      string savetype  = MBA.HttpApplication.getParameter("savetype");
            
      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);
   
      if (vSaveType == null) 
        vSaveType = Constants.SAVE_TYPE_NEW;
      
      saveType = (int) vSaveType;

      WebUIControlDataField ctrlSaveType = findControlRecu(this.Page, "savetype")   as WebUIControlDataField;      
      Steps                 ctrlSteps    = findControlRecu(this.Page, "save")       as Steps;
      
      /*-------------------------------
       * Locate step controls
       *------------------------------*/ 

      Step ctrlStep1 = findControlRecu(this.Page,"step1") as Step;
      Step ctrlStep2 = findControlRecu(this.Page,"step2") as Step;
      Step ctrlStep3 = findControlRecu(this.Page,"step3") as Step;
      Step ctrlStep4 = findControlRecu(this.Page,"step4") as Step;
      Step ctrlStep5 = findControlRecu(this.Page,"step5") as Step;

      /*-------------------------------
       * Locate data controls
       *------------------------------*/ 

      WebUIControlDataField ctrlRecID               = findControlRecu(this.Page, "recid")              as WebUIControlDataField;
      WebUIControlDataField ctrlClientID            = findControlRecu(this.Page, "clientid")           as WebUIControlDataField;
      WebUIControlDataField ctrlFiscalYearID        = findControlRecu(this.Page, "fiscalyearid")       as WebUIControlDataField;
      WebUIControlDataField ctrlName                = findControlRecu(this.Page, "name")               as WebUIControlDataField;        
      WebUIControlDataField ctrlDesc                = findControlRecu(this.Page, "description")        as WebUIControlDataField;        
      
      ctrlSaveType.value = saveType.ToString();
      
      /*-------------------------------
       * New Records
       *------------------------------*/ 

      if (saveType == Constants.SAVE_TYPE_NEW)
      {
      
        /*-------------------------------
         * Look up default values for
         * school year and start/end
         * dates
         *------------------------------*/ 
         
        ClientAttendanceYear yr = ClientAttendanceYears.loadNRecord(dbConnApp, log, uInfo,0);
                        
        /*-------------------------------
         * Set school year default value
         * and step label
         *------------------------------*/ 

        ctrlStep2.label          = yr.name;  
        ctrlFiscalYearID.value   = yr.id.ToString();
      }
      
      /*-------------------------------
       * Edits
       *------------------------------*/ 
      
      if (saveType == Constants.SAVE_TYPE_EDIT)
      {
        /*-------------------------------
         * Load record and if its not
         * found get out
         *------------------------------*/

        ClientAttendanceCalendar adt = ClientAttendanceCalendars.load(dbConnApp, log, uInfo, recid);
             
        /*-------------------------------
         * Populate step labels
         *------------------------------*/

        ctrlStep1.label = adt.clientName;
        ctrlStep2.label = adt.fiscalYearName;
        ctrlStep3.label = adt.name;
        ctrlStep4.label = adt.description;
  
        /*-------------------------------
         * Populate data values
         *------------------------------*/

        ctrlRecID.value         = adt.id.ToString();
        ctrlClientID.value      = adt.clientID.ToString();
        ctrlFiscalYearID.value  = adt.fiscalYearID.ToString();
        ctrlName.value          = adt.name;
        ctrlDesc.value          = adt.description;
        
        /*-------------------------------
         * Set title and 1st step
         *------------------------------*/ 
        
        this.subTitle = WebUI.CreatePageSubTitle(ClientAttendanceCalendars.SEL_LABEL, ClientAttendanceCalendars.SEL_LABEL_EDIT);
        
        ctrlSteps.firstStep = 4; // step - 1
      
      }
   
    }
  }
}
