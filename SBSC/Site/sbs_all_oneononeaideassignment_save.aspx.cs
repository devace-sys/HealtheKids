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
   * SBSAllOneOnOneAideAssignmentSave */
  /**
   * Saves a 1:1 aide assignment
   ***************************************************************************/   

  public class SBSAllOneOnOneAideAssignmentSave : WebUI
  {
    public int saveType = 0;

    public SBSAllOneOnOneAideAssignmentSave() : base("oneononeaideassignment_save", WebUI.CreatePageSubTitle(OneOnOneAideAssignments.SEL_LABEL, OneOnOneAideAssignments.SEL_LABEL_ADD), "", "", Constants.ROLE_SBS_MGMT_ANI) { }
    
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
      

      ctrlSaveType.value = saveType.ToString();
      
      if (saveType == Constants.SAVE_TYPE_EDIT)
      {
        /*-------------------------------
         * Load record and if its not
         * found get out
         *------------------------------*/ 
       
        OneOnOneAideAssignment sr = OneOnOneAideAssignments.load(dbConnApp,log,uInfo,recid);
               
        /*-------------------------------
         * Locate step controls
         *------------------------------*/ 

        Step ctrlStep1  = findControlRecu(this.Page,"step1")  as Step;
        Step ctrlStep3  = findControlRecu(this.Page,"step3")  as Step;
        Step ctrlStep5  = findControlRecu(this.Page,"step5")  as Step;
        Step ctrlStep6  = findControlRecu(this.Page,"step6")  as Step;
        Step ctrlStep7  = findControlRecu(this.Page,"step7")  as Step;
        Step ctrlStep8  = findControlRecu(this.Page,"step8")  as Step;
        Step ctrlStep9  = findControlRecu(this.Page,"step9")  as Step;
        Step ctrlStep10 = findControlRecu(this.Page,"step10") as Step;
        Step ctrlStep11 = findControlRecu(this.Page,"step11") as Step;
        Step ctrlStep12 = findControlRecu(this.Page,"step12") as Step;
        Step ctrlStep13 = findControlRecu(this.Page,"step13") as Step;
        Step ctrlStep14 = findControlRecu(this.Page,"step14") as Step;
        Step ctrlStep15 = findControlRecu(this.Page, "step15") as Step;
        Step ctrlStep16 = findControlRecu(this.Page, "step16") as Step;
        Step ctrlStep17 = findControlRecu(this.Page, "step17") as Step;
        Step ctrlStep18 = findControlRecu(this.Page, "step18") as Step;


       /*-------------------------------
        * Locate entity steps
        *------------------------------*/ 
        
       StepSelectPatient ctrlStep2      = findControlRecu(this.Page, "step2") as StepSelectPatient;
       StepSelectPractitioner ctrlStep4 = findControlRecu(this.Page, "step4") as StepSelectPractitioner;


       /*-------------------------------
        * Locate data controls
        *------------------------------*/ 

        WebUIControlDataField ctrlRecID        = findControlRecu(this.Page, "recid")         as WebUIControlDataField;               
        WebUIControlDataField ctrlClientID     = findControlRecu(this.Page, "clientid")      as WebUIControlDataField;
        WebUIControlDataField ctrlSiteID       = findControlRecu(this.Page, "siteid")        as WebUIControlDataField;        
        WebUIControlDataField ctrlLastName     = findControlRecu(this.Page, "lname")         as WebUIControlDataField;        
        WebUIControlDataField ctrlFirstName    = findControlRecu(this.Page, "fname")         as WebUIControlDataField;
        WebUIControlDataField ctrlAideType     = findControlRecu(this.Page, "aidetype")      as WebUIControlDataField;
        WebUIControlDataField ctrlSvcIEP       = findControlRecu(this.Page, "svcsauthiniep") as WebUIControlDataField;
        WebUIControlDataField ctrlSvcMedNec    = findControlRecu(this.Page, "svcsmednec")    as WebUIControlDataField;
        WebUIControlDataField ctrlBusMinAM     = findControlRecu(this.Page, "busminsam")     as WebUIControlDataField;
        WebUIControlDataField ctrlMinSite      = findControlRecu(this.Page, "sitemins")      as WebUIControlDataField;
        WebUIControlDataField ctrlBusMinPM     = findControlRecu(this.Page, "busminspm")     as WebUIControlDataField;
        WebUIControlDataField ctrlStartDate    = findControlRecu(this.Page, "startdate")     as WebUIControlDataField;
        WebUIControlDataField ctrlEndDate      = findControlRecu(this.Page, "enddate")       as WebUIControlDataField;
        TextAreaBox           ctrlNotes        = findControlRecu(this.Page, "notes")         as TextAreaBox;
        WebUIControlDataField ctrlFiscalYearID = findControlRecu(this.Page, "fiscalyearid")  as WebUIControlDataField;
        WebUIControlDataField ctrlCalendarID   = findControlRecu(this.Page, "calendarid")    as WebUIControlDataField;
        WebUIControlDataField ctrlScheduleID   = findControlRecu(this.Page, "scheduleid")    as WebUIControlDataField;


        /*-------------------------------
         * Populate step labels
         *------------------------------*/
        
        ctrlStep1.label  = sr.clientName;
        ctrlStep2.label  = sr.patName;
        ctrlStep3.label  = sr.siteName;
        ctrlStep4.label  = sr.pracName;
        ctrlStep5.label  = sr.aideName;
        ctrlStep6.label  = sr.oneOnOneAideTypeName;
        ctrlStep7.label  = Util.boolToYesNo(sr.aideSvcsAuthInIEP);
        ctrlStep8.label  = Util.boolToYesNo(sr.svcsAreMedNes);
        ctrlStep9.label  = sr.busMinsAM.ToString();
        ctrlStep10.label = sr.siteMins.ToString();
        ctrlStep11.label = sr.busMinsPM.ToString();
        ctrlStep12.label = sr.startDate.ToShortDateString();
        ctrlStep13.label = sr.endDate.ToShortDateString();
        ctrlStep14.label = Util.previewString(sr.notes);
        ctrlStep15.label = sr.fiscalYear;
        ctrlStep16.label = sr.calendarName;
        ctrlStep17.label = sr.scheduleName;
         
        /*-------------------------------
         * Populate data values
         *------------------------------*/        
        
        ctrlRecID.value        = sr.id.ToString();     
        ctrlClientID.value     = sr.clientID.ToString();
        ctrlStep2.selectvalue  = sr.patID.ToString();
        ctrlSiteID.value       = sr.siteID.ToString();
        ctrlStep4.selectvalue  = sr.pracID.ToString();
        ctrlLastName.value     = sr.aideLastName;
        ctrlFirstName.value    = sr.aideFirstName;
        ctrlAideType.value     = sr.oneOnOneAideType;
        ctrlSvcIEP.value       = Util.boolToYesNo(sr.aideSvcsAuthInIEP);
        ctrlSvcMedNec.value    = Util.boolToYesNo(sr.svcsAreMedNes);
        ctrlBusMinAM.value     = sr.busMinsAM.ToString();
        ctrlMinSite.value      = sr.siteMins.ToString();
        ctrlBusMinPM.value     = sr.busMinsPM.ToString();
        ctrlStartDate.value    = sr.startDate.ToShortDateString();
        ctrlEndDate.value      = sr.endDate.ToShortDateString();
        ctrlNotes.value        = sr.notes;
        ctrlFiscalYearID.value = sr.fiscalYearID.ToString();
        ctrlCalendarID.value   = sr.calendarID.ToString();
        ctrlScheduleID.value   = sr.scheduleID.ToString();
        
        /*-------------------------------
         * Set title and 1st step
         *------------------------------*/ 
        
        this.subTitle = WebUI.CreatePageSubTitle(OneOnOneAideAssignments.SEL_LABEL, OneOnOneAideAssignments.SEL_LABEL_EDIT);        
        ctrlSteps.firstStep = 17;
      
      }
   
    }
  }
}
