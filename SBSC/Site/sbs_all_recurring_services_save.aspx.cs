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
   * SBSAllRecurringServicesSave */
  /**
   * Saves a record of recurring services
   ***************************************************************************/   

  public class SBSAllRecurringServicesSave : WebUI
  {
    public int saveType = Constants.SAVE_TYPE_NEW;
  
    public SBSAllRecurringServicesSave () : base("recurring_services_save",
                                                 WebUI.CreatePageSubTitle(RecurringServices.SEL_LABEL, RecurringServices.SEL_LABEL_ADD),
                                                 "",
                                                 "recurringservices.js",
                                                 Constants.ROLE_SBS_ALL){}
        
    protected void Page_Load(object sender, EventArgs e)
    {    
    
      /*-------------------------------
       * Get parameters
       *------------------------------*/ 
      
      string recid     = MBA.HttpApplication.getParameter("recid");
      string savetype  = MBA.HttpApplication.getParameter("savetype");
      string effdate   = MBA.HttpApplication.getParameter("effdate");
                 
      /*-------------------------------
       * Determine save type
       *------------------------------*/ 

      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);   
      if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;      
      saveType = (int) vSaveType;               
      
      /*-------------------------------
       * Locate steps container and
       * steps
       *------------------------------*/ 

      Steps ctrlSteps  = findControlRecu(this.Page, "save")   as Steps;

      StepSelectPatient      ctrlStep6 = findControlRecu(this.Page, "step6") as StepSelectPatient;
      StepSelectPractitioner ctrlStep9 = findControlRecu(this.Page, "step9") as StepSelectPractitioner;

      Step  ctrlStep1  = findControlRecu(this.Page, "step1")  as Step;
      Step  ctrlStep2  = findControlRecu(this.Page, "step2")  as Step;      
      Step  ctrlStep3  = findControlRecu(this.Page, "step3")  as Step;      
      Step  ctrlStep4  = findControlRecu(this.Page, "step4")  as Step;
      Step  ctrlStep5  = findControlRecu(this.Page, "step5")  as Step;
      
      Step  ctrlStep7  = findControlRecu(this.Page, "step7")  as Step;
      Step  ctrlStep8  = findControlRecu(this.Page, "step8")  as Step;           
      
      Step  ctrlStep10 = findControlRecu(this.Page, "step10") as Step;
      Step  ctrlStep11 = findControlRecu(this.Page, "step11") as Step;
      Step  ctrlStep12 = findControlRecu(this.Page, "step12") as Step;
      Step  ctrlStep13 = findControlRecu(this.Page, "step13") as Step;
      Step  ctrlStep14 = findControlRecu(this.Page, "step14") as Step;
      Step  ctrlStep15 = findControlRecu(this.Page, "step15") as Step;
      Step  ctrlStep16 = findControlRecu(this.Page, "step16") as Step;
      Step  ctrlStep17 = findControlRecu(this.Page, "step17") as Step;
      Step  ctrlStep18 = findControlRecu(this.Page, "step18") as Step;
      Step  ctrlStep19 = findControlRecu(this.Page, "step19") as Step;
      Step  ctrlStep20 = findControlRecu(this.Page, "step20") as Step;

      /*-------------------------------
       * Locate controls
       *------------------------------*/ 

      WebUIControlDataField ctrlSaveType        = findControlRecu(this.Page, "savetype")            as WebUIControlDataField;
      WebUIControlDataField ctrlRecID           = findControlRecu(this.Page, "recid")               as WebUIControlDataField;
      ComboBox              ctrlFYID            = findControlRecu(this.Page, "fiscalyearid")        as ComboBox;
      DateBox               ctrlStartDate       = findControlRecu(this.Page, "startdate")           as DateBox;
      DateBox               ctrlEndDate         = findControlRecu(this.Page, "enddate")             as DateBox;
      WebUIControlDataField ctrlClientID        = findControlRecu(this.Page, "clientid")            as WebUIControlDataField;
      ComboBox              ctrlCalendarID      = findControlRecu(this.Page, "calendarid")          as ComboBox;
      ComboBox              ctrlScheduleID      = findControlRecu(this.Page, "scheduleid")          as ComboBox;      
      MBA.DataGrid          ctrlPracDetails     = findControlRecu(this.Page, "details_pracs_all")   as MBA.DataGrid;
      MBA.DataGrid          ctrlTmtBSDetails    = findControlRecu(this.Page, "details_tmt_bs")      as MBA.DataGrid;
      MBA.DataGrid          ctrlTmtDSIndDetails = findControlRecu(this.Page, "details_tmt_ds_ind")  as MBA.DataGrid;
      MBA.DataGrid          ctrlTmtDSGrpDetails = findControlRecu(this.Page, "details_tmt_ds_grp")  as MBA.DataGrid;      
      MBA.DataGrid          ctrlTmtASDetails    = findControlRecu(this.Page, "details_tmt_as")      as MBA.DataGrid;
      MBA.DataGrid          ctrlTransHmSs       = findControlRecu(this.Page, "details_trans_hm_ss") as MBA.DataGrid;
      MBA.DataGrid          ctrlTransSsHm       = findControlRecu(this.Page, "details_trans_ss_hm") as MBA.DataGrid;
      MBA.DataGrid          ctrlTransSsOs       = findControlRecu(this.Page, "details_trans_ss_os") as MBA.DataGrid;
      MBA.DataGrid          ctrlTransOsSs       = findControlRecu(this.Page, "details_trans_os_ss") as MBA.DataGrid;
      TextAreaBox           ctrlNotes           = findControlRecu(this.Page, "notes")               as TextAreaBox;
      
      /*-------------------------------
       * Set save type
       *------------------------------*/ 

      ctrlSaveType.value = saveType.ToString();

      /*-------------------------------
       * Look up default values for
       * school year and start/end
       * dates
       *------------------------------*/ 
         
      ClientAttendanceYear yr = ClientAttendanceYears.loadNRecord(dbConnApp, log, uInfo,0);                
      
      /*-------------------------------
       * For new records
       *------------------------------*/ 
       
      if (saveType == Constants.SAVE_TYPE_NEW)
      {
        /*-------------------------------
         * Look up default values for
         * school year and start/end
         * dates
         *------------------------------*/ 
        
        yr = ClientAttendanceYears.loadNRecord(dbConnApp, log, uInfo,0);       
                                        
        /*-------------------------------
         * Set school year default value
         * and step label
         *------------------------------*/ 

        ctrlStep3.label  = yr.name;  
        ctrlFYID.value   = yr.id.ToString();
        
        /*-------------------------------
         * Set start date default value
         * and step label
         *------------------------------*/ 

        ctrlStep4.label     = yr.startDateStr;
        ctrlStartDate.value = yr.startDateStr;
        
        /*-------------------------------
         * Set end date default value
         * and step label
         *------------------------------*/ 

        ctrlStep5.label   = yr.endDateStr;
        ctrlEndDate.value = yr.endDateStr;                               
        
        /*-------------------------------
         * Set page title
         *------------------------------*/ 
        
        this.subTitle = WebUI.CreatePageSubTitle(RecurringServices.SEL_LABEL, RecurringServices.SEL_LABEL_ADD);
        
      }
      
      /*-------------------------------
       * Copy or Edit
       *------------------------------*/ 

      else 
      {        

        RecurringService rs = RecurringServices.load(dbConnApp,log, uInfo, recid);
                                             
        string detailsLabel = "Details Entered or Updated";        
        
        ctrlRecID.value                    = rs.id.ToString();
        
        ctrlStep2.label                    = rs.clientName;
        ctrlClientID.value                 = rs.clientID.ToString();
        
        ctrlStep6.selectvalue              = rs.patID.ToString();             
        ctrlStep6.label                    = rs.patientName;
                                   
        ctrlStep9.multiSelectLoad          = true;              // Tell control we want to load multi values
        ctrlStep9.multiSelectNames         = rs.pracNamesStr;
        ctrlStep9.multiSelectValues        = rs.pracIDsStr;
        ctrlStep9.multiSelectContextLabels = rs.pracTitlesStr;
        ctrlStep9.label                    = rs.pracNamesStr; 

        ctrlStep10.label = detailsLabel;        
        ctrlPracDetails.singleQuoteValueAttribute     = true;       
        ctrlPracDetails.value                         = rs.detailsPracsStr;
        
        ctrlStep11.label = detailsLabel;        
        ctrlTmtBSDetails.singleQuoteValueAttribute    = true;
        ctrlTmtBSDetails.value                        = rs.detailsTmtBSStr;
        
        ctrlStep12.label = detailsLabel;
        ctrlTmtDSIndDetails.singleQuoteValueAttribute = true;
        ctrlTmtDSIndDetails.value                     = rs.detailsTmtDSIndStr;

        ctrlStep13.label = detailsLabel;
        ctrlTmtDSGrpDetails.singleQuoteValueAttribute = true;
        ctrlTmtDSGrpDetails.value                     = rs.detailsTmtDSGrpStr;        

        ctrlStep14.label = detailsLabel;
        ctrlTmtASDetails.singleQuoteValueAttribute    = true;
        ctrlTmtASDetails.value                        = rs.detailsTmtASStr;
        
        ctrlStep15.label = detailsLabel;
        ctrlTransHmSs.singleQuoteValueAttribute       = true;
        ctrlTransHmSs.value                           = rs.detailsTransHmSsStr;

        ctrlStep16.label = detailsLabel;
        ctrlTransSsHm.singleQuoteValueAttribute       = true;
        ctrlTransSsHm.value                           = rs.detailsTransSsHmStr;

        ctrlStep17.label = detailsLabel;
        ctrlTransSsOs.singleQuoteValueAttribute       = true;
        ctrlTransSsOs.value                           = rs.detailsTransSsOsStr;

        ctrlStep18.label = detailsLabel;
        ctrlTransOsSs.singleQuoteValueAttribute       = true;
        ctrlTransOsSs.value                           = rs.detailsTransOsSsStr;
        
        ctrlStep19.label                              = Util.previewString(rs.notes); 
        ctrlNotes.value                               = rs.notes;
                
        /*-------------------------------
         * Copy
         *------------------------------*/ 
    
        if (saveType == Constants.SAVE_TYPE_COPY)
        {
                              
          yr = ClientAttendanceYears.load (dbConnApp, log, uInfo,rs.fiscalYearID.ToString()); 
               
          DateTime vEffDateIn     = MBA.Validate.reqDate (effdate, Messages.INVALID_END_DATE);         
          DateTime vEffDateNew    = vEffDateIn.AddDays(1);
          string effdatenew       = Util.dateTimeToShortDate(vEffDateNew);
          
          /*-------------------------------
           * New date is within same 
           * fiscal year
           *------------------------------*/ 
          
          if ((vEffDateNew) >= yr.startDate && (vEffDateNew <= yr.endDate))
          {

            /*-------------------------------
             * Keep fiscal year
             *------------------------------*/ 
          
            ctrlStep3.label                    = rs.fiscalYearName;
            ctrlFYID.value                     = rs.fiscalYearID.ToString();

            /*-------------------------------
             * Set start date default value
             * and step label to new data
             *------------------------------*/ 
          
            ctrlStep4.label     = effdatenew;
            ctrlStartDate.value = effdatenew;

            /*-------------------------------
             * Set end date default value
             * and step label to end of
             * fiscal year
             *------------------------------*/ 

            ctrlStep5.label     = yr.endDateStr;
            ctrlEndDate.value   = yr.endDateStr;
                
            /*-------------------------------
             * Keep same calendar and schedule
             *------------------------------*/ 
                 
            ctrlStep7.label                    = rs.calendarName;
            ctrlCalendarID.value               = (rs.calendarID != 0) ? rs.calendarID.ToString() : "";
        
            ctrlStep8.label                    = rs.scheduleName;
            ctrlScheduleID.value               = (rs.scheduleID != 0) ? rs.scheduleID.ToString() : "";                  

          }

          /*-------------------------------
           * New date is in different 
           * fiscal year
           *------------------------------*/
            
          else
          {
            /*-------------------------------
             * Look up the fiscal year
             *------------------------------*/

            yr = ClientAttendanceYears.load(dbConnApp, log, uInfo,null,effdatenew);
            
            /*-------------------------------
             * Set fiscal year 
             *------------------------------*/ 
          
            ctrlStep3.label  = yr.name;  
            ctrlFYID.value   = yr.id.ToString();
            
            /*-------------------------------
             * Set start date default value
             * and step label to new data
             *------------------------------*/ 
          
            ctrlStep4.label     = effdatenew;
            ctrlStartDate.value = effdatenew;
        
            /*-------------------------------
             * Set end date to the fiscal year
             * end date
             *------------------------------*/ 
            
            ctrlStep5.label     = yr.endDateStr;
            ctrlEndDate.value   = yr.endDateStr;
            
            /*-------------------------------
             * Blank calendar and bell sch
             *------------------------------*/ 
            
            ctrlStep7.label       = "";
            ctrlCalendarID.value  = "";
                    
            ctrlStep8.label       = "";
            ctrlScheduleID.value  = "";
            
          }
       
         this.subTitle = WebUI.CreatePageSubTitle(RecurringServices.SEL_LABEL, RecurringServices.SEL_LABEL_COPY);   
          
        }

        /*-------------------------------
         * Edit
         *------------------------------*/ 
        
        if (saveType == Constants.SAVE_TYPE_EDIT)
        {
          ctrlStep3.label                    = rs.fiscalYearName;
          ctrlFYID.value                     = rs.fiscalYearID.ToString();
                          
          ctrlStep4.label                    = rs.startDateStr;
          ctrlStartDate.value                = rs.startDateStr;
        
          ctrlStep5.label                    = rs.endDateStr;
          ctrlEndDate.value                  = rs.endDateStr;

          ctrlStep7.label                    = rs.calendarName;
          ctrlCalendarID.value               = (rs.calendarID != 0) ? rs.calendarID.ToString() : "";
        
          ctrlStep8.label                    = rs.scheduleName;
          ctrlScheduleID.value               = (rs.scheduleID != 0) ? rs.scheduleID.ToString() : "";

          this.subTitle = WebUI.CreatePageSubTitle(RecurringServices.SEL_LABEL, RecurringServices.SEL_LABEL_EDIT);
        }
        
        
      }
            
    }
  }
}
