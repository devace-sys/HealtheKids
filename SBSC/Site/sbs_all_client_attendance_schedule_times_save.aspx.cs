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
   * SBSAllClientAttendanceScheduleTimesSave */
  /**
   * Saves an attendance schedule times
   ***************************************************************************/   

  public class SBSAllClientAttendanceScheduleTimesSave : WebUI
  {
    public int saveType = 0;
   
    public SBSAllClientAttendanceScheduleTimesSave() : base("attendance_schedule_times_save",WebUI.CreatePageSubTitle(ClientAttendanceScheduleTimes.SEL_LABEL, ClientAttendanceScheduleTimes.SEL_LABEL_ADD),"","",Constants.ROLE_SBS_ALL){}
    
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

      Step ctrlStep1  = findControlRecu(this.Page, "step1")  as Step;
      Step ctrlStep2  = findControlRecu(this.Page, "step2")  as Step;
      Step ctrlStep3  = findControlRecu(this.Page, "step3")  as Step;
      Step ctrlStep4  = findControlRecu(this.Page, "step4")  as Step;
      Step ctrlStep5  = findControlRecu(this.Page, "step5")  as Step;
      Step ctrlStep6  = findControlRecu(this.Page, "step6")  as Step;
      Step ctrlStep7  = findControlRecu(this.Page, "step7")  as Step;
      Step ctrlStep8  = findControlRecu(this.Page, "step8")  as Step;
      Step ctrlStep9  = findControlRecu(this.Page, "step9")  as Step;
      Step ctrlStep10 = findControlRecu(this.Page, "step10") as Step;
      Step ctrlStep11 = findControlRecu(this.Page, "step11") as Step;
      Step ctrlStep12 = findControlRecu(this.Page, "step12") as Step;
      Step ctrlStep13 = findControlRecu(this.Page, "step13") as Step;
      Step ctrlStep14 = findControlRecu(this.Page, "step14") as Step;
      Step ctrlStep15 = findControlRecu(this.Page, "step15") as Step;
      Step ctrlStep16 = findControlRecu(this.Page, "step16") as Step;
      Step ctrlStep17 = findControlRecu(this.Page, "step17") as Step;
      Step ctrlStep18 = findControlRecu(this.Page, "step18") as Step;
      Step ctrlStep19 = findControlRecu(this.Page, "step19") as Step;
      
      /*-------------------------------
       * Locate data controls
       *------------------------------*/ 

      WebUIControlDataField ctrlRecID               = findControlRecu(this.Page, "recid")               as WebUIControlDataField;
      WebUIControlDataField ctrlClientID            = findControlRecu(this.Page, "clientid")            as WebUIControlDataField;
      WebUIControlDataField ctrlFiscalYearID        = findControlRecu(this.Page, "fiscalyearid")        as WebUIControlDataField;
      WebUIControlDataField ctrlScheduleID          = findControlRecu(this.Page, "scheduleid")          as WebUIControlDataField;
      WebUIControlDataField ctrlAttendanceDayTypeID = findControlRecu(this.Page, "attendancedaytypeid") as WebUIControlDataField;
      WebUIControlDataField ctrlStartTime           = findControlRecu(this.Page, "starttime")           as WebUIControlDataField;
      WebUIControlDataField ctrlEndTime             = findControlRecu(this.Page, "endtime")             as WebUIControlDataField;
      WebUIControlDataField ctrlP0StartTime         = findControlRecu(this.Page, "period0TimeStart")    as WebUIControlDataField;
      WebUIControlDataField ctrlP0EndTime           = findControlRecu(this.Page, "period0TimeEnd")      as WebUIControlDataField;
      WebUIControlDataField ctrlP1StartTime         = findControlRecu(this.Page, "period1TimeStart")    as WebUIControlDataField;
      WebUIControlDataField ctrlP1EndTime           = findControlRecu(this.Page, "period1TimeEnd")      as WebUIControlDataField;
      WebUIControlDataField ctrlP2StartTime         = findControlRecu(this.Page, "period2TimeStart")    as WebUIControlDataField;
      WebUIControlDataField ctrlP2EndTime           = findControlRecu(this.Page, "period2TimeEnd")      as WebUIControlDataField;
      WebUIControlDataField ctrlP3StartTime         = findControlRecu(this.Page, "period3TimeStart")    as WebUIControlDataField;
      WebUIControlDataField ctrlP3EndTime           = findControlRecu(this.Page, "period3TimeEnd")      as WebUIControlDataField;
      WebUIControlDataField ctrlP4StartTime         = findControlRecu(this.Page, "period4TimeStart")    as WebUIControlDataField;
      WebUIControlDataField ctrlP4EndTime           = findControlRecu(this.Page, "period4TimeEnd")      as WebUIControlDataField;
      WebUIControlDataField ctrlP5StartTime         = findControlRecu(this.Page, "period5TimeStart")    as WebUIControlDataField;
      WebUIControlDataField ctrlP5EndTime           = findControlRecu(this.Page, "period5TimeEnd")      as WebUIControlDataField;
      WebUIControlDataField ctrlP6StartTime         = findControlRecu(this.Page, "period6TimeStart")    as WebUIControlDataField;
      WebUIControlDataField ctrlP6EndTime           = findControlRecu(this.Page, "period6TimeEnd")      as WebUIControlDataField;
      WebUIControlDataField ctrlP7StartTime         = findControlRecu(this.Page, "period7TimeStart")    as WebUIControlDataField;
      WebUIControlDataField ctrlP7EndTime           = findControlRecu(this.Page, "period7TimeEnd")      as WebUIControlDataField;
      WebUIControlDataField ctrlP8StartTime         = findControlRecu(this.Page, "period8TimeStart")    as WebUIControlDataField;
      WebUIControlDataField ctrlP8EndTime           = findControlRecu(this.Page, "period8TimeEnd")      as WebUIControlDataField;
      WebUIControlDataField ctrlP9StartTime         = findControlRecu(this.Page, "period9TimeStart")    as WebUIControlDataField;
      WebUIControlDataField ctrlP9EndTime           = findControlRecu(this.Page, "period9TimeEnd")      as WebUIControlDataField;
      WebUIControlDataField ctrlP10StartTime        = findControlRecu(this.Page, "period10TimeStart")   as WebUIControlDataField;
      WebUIControlDataField ctrlP10EndTime          = findControlRecu(this.Page, "period10TimeEnd")     as WebUIControlDataField;  

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

        ctrlStep3.label          = yr.name;  
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

        ClientAttendanceScheduleTime adt = ClientAttendanceScheduleTimes.load(dbConnApp,log,uInfo,recid);
        
      
        /*-------------------------------
         * Populate step labels
         *------------------------------*/

        ctrlStep2.label  = adt.clientName;
        ctrlStep3.label  = adt.fiscalYearName;
        ctrlStep4.label  = adt.scheduleName;
        ctrlStep5.label  = adt.attendanceDayType;
        ctrlStep6.label  = adt.timeStartStr;
        ctrlStep7.label  = adt.timeEndStr;
        ctrlStep8.label  = adt.p0StartTimeStr  + " - " + adt.p0EndTimeStr;
        ctrlStep9.label  = adt.p1StartTimeStr  + " - " + adt.p1EndTimeStr;
        ctrlStep10.label  = adt.p2StartTimeStr  + " - " + adt.p2EndTimeStr;
        ctrlStep11.label = adt.p3StartTimeStr  + " - " + adt.p3EndTimeStr;
        ctrlStep12.label = adt.p4StartTimeStr  + " - " + adt.p4EndTimeStr;
        ctrlStep13.label = adt.p5StartTimeStr  + " - " + adt.p5EndTimeStr;
        ctrlStep14.label = adt.p6StartTimeStr  + " - " + adt.p6EndTimeStr;
        ctrlStep15.label = adt.p7StartTimeStr  + " - " + adt.p7EndTimeStr;
        ctrlStep16.label = adt.p8StartTimeStr  + " - " + adt.p8EndTimeStr;
        ctrlStep17.label = adt.p9StartTimeStr  + " - " + adt.p9EndTimeStr;
        ctrlStep18.label = adt.p10StartTimeStr + " - " + adt.p10EndTimeStr;
          
        /*-------------------------------
         * Populate data values
         *------------------------------*/

        ctrlRecID.value               = adt.id.ToString();
        ctrlClientID.value            = adt.clientID.ToString();
        ctrlFiscalYearID.value        = adt.fiscalYearID.ToString();
        ctrlScheduleID.value          = adt.scheduleID.ToString();
        ctrlAttendanceDayTypeID.value = adt.attendanceDayTypeID.ToString();
        ctrlStartTime.value           = adt.timeStartStr;
        ctrlEndTime.value             = adt.timeEndStr;
        ctrlP0StartTime.value         = adt.p0StartTimeStr;
        ctrlP0EndTime.value           = adt.p0EndTimeStr;
        ctrlP1StartTime.value         = adt.p1StartTimeStr;
        ctrlP1EndTime.value           = adt.p1EndTimeStr;
        ctrlP2StartTime.value         = adt.p2StartTimeStr;
        ctrlP2EndTime.value           = adt.p2EndTimeStr; 
        ctrlP3StartTime.value         = adt.p3StartTimeStr;
        ctrlP3EndTime.value           = adt.p3EndTimeStr;
        ctrlP4StartTime.value         = adt.p4StartTimeStr;
        ctrlP4EndTime.value           = adt.p4EndTimeStr; 
        ctrlP5StartTime.value         = adt.p5StartTimeStr;
        ctrlP5EndTime.value           = adt.p5EndTimeStr;
        ctrlP6StartTime.value         = adt.p6StartTimeStr;
        ctrlP6EndTime.value           = adt.p6EndTimeStr;
        ctrlP7StartTime.value         = adt.p7StartTimeStr;
        ctrlP7EndTime.value           = adt.p7EndTimeStr; 
        ctrlP8StartTime.value         = adt.p8StartTimeStr;
        ctrlP8EndTime.value           = adt.p8EndTimeStr; 
        ctrlP9StartTime.value         = adt.p9StartTimeStr;
        ctrlP9EndTime.value           = adt.p9EndTimeStr;
        ctrlP10StartTime.value        = adt.p10StartTimeStr;
        ctrlP10EndTime.value          = adt.p10EndTimeStr;
        
        /*-------------------------------
         * Set title and 1st step
         *------------------------------*/

        this.subTitle = WebUI.CreatePageSubTitle(ClientAttendanceScheduleTimes.SEL_LABEL, ClientAttendanceScheduleTimes.SEL_LABEL_EDIT);
        
        ctrlSteps.firstStep = 18;
      
      }
   
    }
  }
}
