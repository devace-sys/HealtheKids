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
   * ServiceRecordSave */
  /**
   * Saves a service record
   ***************************************************************************/   

  public class SBSAllServiceRecordSave : WebUI
  {
    public int saveType = 0;    

    public SBSAllServiceRecordSave() : base("service_record_save","Service Records - Save","","",Constants.ROLE_SBS_ALL){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /*-------------------------------
       * Determine what save type
       * this is 
       *------------------------------*/ 
      
      string recid     = MBA.HttpApplication.getParameter("recid");
      string savetype  = MBA.HttpApplication.getParameter("savetype");
      
      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);
   
      if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
      saveType = (int) vSaveType;

      WebUIControlDataField ctrlSaveType         = findControlRecu(this.Page, "savetype")          as WebUIControlDataField;
      WebUIControlDataField ctrlIsMultiDos       = findControlRecu(this.Page, "ismultidos")        as WebUIControlDataField;
      WebUIControlDataField ctrlDos              = findControlRecu(this.Page, "dos")               as WebUIControlDataField;
      WebUIControlDataField ctrlDosMulti         = findControlRecu(this.Page, "dosmulti")          as WebUIControlDataField;
      WebUIControlDataField ctrlAttendanceStatus = findControlRecu(this.Page, "attendancestatus")  as WebUIControlDataField;

      Steps ctrlSteps = findControlRecu(this.Page, "save") as Steps;
      
      ctrlSaveType.value = saveType.ToString();
      ctrlAttendanceStatus.value = MBA.SessionAttendanceStatus.REGULAR_SESSION.GetValueAsString();

      if (saveType == Constants.SAVE_TYPE_EDIT)
      {
        
        /*-------------------------------
         * Load record and if its not
         * found get out
         *------------------------------*/ 

        ServiceRecord sr = ServiceRecords.load(dbConnApp,log,uInfo,recid);
        
        /*-------------------------------
         * Locate step controls
         *------------------------------*/ 

        Step ctrlStep1 = findControlRecu(this.Page,"step1") as Step;
        Step ctrlStep2 = findControlRecu(this.Page,"step2") as Step;
        Step ctrlStep3 = findControlRecu(this.Page,"step3") as Step;
        Step ctrlStep5 = findControlRecu(this.Page,"step5") as Step;        
        Step ctrlStep8 = findControlRecu(this.Page,"step8") as Step;
        
        StepSelectPractitioner ctrlStep4 = findControlRecu(this.Page, "step4")  as StepSelectPractitioner;
        StepSelectPatient      ctrlStep6 = findControlRecu(this.Page, "step6")  as StepSelectPatient;
        StepSelectService      ctrlStep7 = findControlRecu(this.Page, "step7")  as StepSelectService;

        /*-------------------------------
         * Locate data controls
         *------------------------------*/ 

        WebUIControlDataField ctrlRecID     = findControlRecu(this.Page, "recid")         as WebUIControlDataField;
        WebUIControlDataField ctrlRef       = findControlRecu(this.Page, "reference")     as WebUIControlDataField;
        WebUIControlDataField ctrlClientID  = findControlRecu(this.Page, "clientid")      as WebUIControlDataField;
        
        WebUIControlDataField ctrlIsIEP     = findControlRecu(this.Page, "isiep" )        as WebUIControlDataField;
        WebUIControlDataField ctrlStartTime = findControlRecu(this.Page, "starttime")     as WebUIControlDataField;
        WebUIControlDataField ctrlNumMin    = findControlRecu(this.Page, "nummin")        as WebUIControlDataField;
        
        WebUIControlDataField ctrlTp1Start  = findControlRecu(this.Page, "trip1start")    as WebUIControlDataField;
        WebUIControlDataField ctrlTp2Start  = findControlRecu(this.Page, "trip2start")    as WebUIControlDataField;
        WebUIControlDataField ctrlTp3Start  = findControlRecu(this.Page, "trip3start")    as WebUIControlDataField;
        WebUIControlDataField ctrlTp4Start  = findControlRecu(this.Page, "trip4start")    as WebUIControlDataField;
        
        WebUIControlDataField ctrlTp1End    = findControlRecu(this.Page, "trip1end")      as WebUIControlDataField;
        WebUIControlDataField ctrlTp2End    = findControlRecu(this.Page, "trip2end")      as WebUIControlDataField;
        WebUIControlDataField ctrlTp3End    = findControlRecu(this.Page, "trip3end")      as WebUIControlDataField;
        WebUIControlDataField ctrlTp4End    = findControlRecu(this.Page, "trip4end")      as WebUIControlDataField;

        WebUIControlDataField ctrlNotes     = findControlRecu(this.Page, "notes")         as WebUIControlDataField;

        /*-------------------------------
         * Populate step labels
         *------------------------------*/

        ctrlStep1.label = Util.boolToYesNo(sr.isIFSPorIEP);
        ctrlStep2.label = sr.reference;
        ctrlStep3.label = sr.clientName;
        ctrlStep4.label = sr.pracName;
        ctrlStep5.label = sr.dos.ToShortDateString();
        ctrlStep6.label = sr.patName;
        ctrlStep7.label = sr.svcName;
        
        if (sr.svcType != Constants.SERVICES_TRANSPORT)
        {
          /*-------------------------------
           * If the service is NOT transport
           * service then the system will
           * pick the first section
           * as the active section (default)
           * and it will set the label
           * accordingly
           *------------------------------*/

          ctrlStep8.label = ((sr.numMins == 0) ? "" : sr.numMins.ToString()) + " | " + sr.startTimeStr;
        }
        else
        {
          /*-------------------------------
           * If the service is a transport
           * service switch start section
           * to the transportation section
           * and also set the label
           * accordingly.
           *------------------------------*/

          StepSection sec  = findControlRecu(this.Page, "milebased")  as StepSection;
          sec.startSection = true;
          ctrlStep8.label  = sr.tripsMiles;

        }

       /*-------------------------------
        * Populate Data Values
        *------------------------------*/ 

        ctrlStep4.selectvalue = sr.pracID.ToString();
        ctrlStep6.selectvalue = sr.patID.ToString();
        
        ctrlRecID.value    = sr.id.ToString();
        ctrlRef.value      = sr.reference;
        ctrlClientID.value = sr.clientID.ToString();
        ctrlDos.value      = sr.dos.ToShortDateString();
        ctrlIsIEP.value    = Util.boolToYesNo(sr.isIFSPorIEP);
        
        ctrlStep7.nameIDValue         = sr.nameID.ToString();
        
        ctrlStep7.hasORPDocIDValue    = Util.boolTo1or0Str(sr.hasOrpDocID);
        ctrlStep7.selORPDocIDValue    = sr.orpDocID.ToString();
        ctrlStep7.selORPDocIDLabel    = sr.orpDocLabel;
                
        ctrlStep7.hasSvcDetFlagsValue = Util.boolTo1or0Str(sr.hasSvcDetFlags);
        ctrlStep7.svcDetFlag1Value    = Util.boolToYesNo(sr.svcDetFlag1);
        ctrlStep7.svcDetFlag2Value    = Util.boolToYesNo(sr.svcDetFlag2);
        ctrlStep7.svcDetFlag3Value    = Util.boolToYesNo(sr.svcDetFlag3);
        ctrlStep7.svcDetFlag4Value    = Util.boolToYesNo(sr.svcDetFlag4);
        
        ctrlStartTime.value = sr.startTimeStr;
        ctrlNumMin.value    = (sr.numMins == 0) ? "" : sr.numMins.ToString();        // Handles case of 0
        
        ctrlTp1Start.value = (sr.trip1Start == 0) ? "" : sr.trip1Start.ToString();  // Handles case of 0
        ctrlTp2Start.value = (sr.trip2Start == 0) ? "" : sr.trip2Start.ToString();  // Handles case of 0
        ctrlTp3Start.value = (sr.trip3Start == 0) ? "" : sr.trip3Start.ToString();  // Handles case of 0
        ctrlTp4Start.value = (sr.trip4Start == 0) ? "" : sr.trip4Start.ToString();  // Handles case of 0

        ctrlTp1End.value   = (sr.trip1End   == 0) ? "" : sr.trip1End.ToString();    // Handles case of 0
        ctrlTp2End.value   = (sr.trip2End   == 0) ? "" : sr.trip2End.ToString();    // Handles case of 0
        ctrlTp3End.value   = (sr.trip3End   == 0) ? "" : sr.trip3End.ToString();    // Handles case of 0
        ctrlTp4End.value   = (sr.trip4End   == 0) ? "" : sr.trip4End.ToString();    // Handles case of 0

        ctrlAttendanceStatus.value = sr.attendanceStatusSelectionID.ToString();        
        ctrlNotes.value            = sr.notes;        
        
        /*-------------------------------
         * Turn multi date off
         *------------------------------*/ 
        
        ctrlDosMulti.hidden  = true;
        ctrlIsMultiDos.value = "0";

        /*-------------------------------
         * Set title
         *------------------------------*/ 
        
        if (saveType == Constants.SAVE_TYPE_EDIT)   this.subTitle = "Service Records - Edit";
        if (saveType == Constants.SAVE_TYPE_DELETE) this.subTitle = "Service Records - Delete";
        
        ctrlSteps.firstStep = 8;

      }

      /*-------------------------------
       * Otherwise its a new record
       *------------------------------*/ 

      else
      {
          
        /*-------------------------------
         * Turn multi date on
         *------------------------------*/ 

        ctrlDos.hidden        = true;        
        ctrlIsMultiDos.value  = "1";
        
        /*-------------------------------
         * Set title
         *------------------------------*/ 

        this.subTitle = "Service Records - New";

      }
    }
  }
}
