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
   * ClientCoorServiceRecordSave */
  /**
   * Saves a service record
   ***************************************************************************/   

  public class ClientCoorServiceRecordSave : WebUI
  {
    public int saveType = 0;

    public ClientCoorServiceRecordSave() : 
      base("service_record_save",
           "Service Records - Save",
            "",
            "",
            Constants.ROLE_CLIENT_BO){}

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

      WebUIControlDataField ctrlSaveType = findControlRecu(this.Page, "savetype")      as WebUIControlDataField;
      Steps            ctrlSteps    = findControlRecu(this.Page, "save")          as Steps;
      
      ctrlSaveType.value = saveType.ToString();
      
      
       /* If user is logged in get client id */
      
      if (rd.loggedIn) 
      {
        WebUIControlDataField ctrlClientID = findControlRecu(this.Page, "clientid")      as WebUIControlDataField;
        ctrlClientID.value = Spedmon.Validate.reqClientID (uInfo, "").ToString();
      }

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

        Step ctrlStep2 = findControlRecu(this.Page, "step2") as Step;
        Step ctrlStep4 = findControlRecu(this.Page,"step4") as Step;
        Step ctrlStep6 = findControlRecu(this.Page,"step6") as Step;
        Step ctrlStep7 = findControlRecu(this.Page,"step7") as Step;
        Step ctrlStep8 = findControlRecu(this.Page,"step8") as Step;
        Step ctrlStep9 = findControlRecu(this.Page,"step9") as Step;

        StepSelectPractitioner ctrlStep1 = findControlRecu(this.Page, "step1")  as StepSelectPractitioner;
        StepSelectPatient      ctrlStep3 = findControlRecu(this.Page, "step3")  as StepSelectPatient;
        StepSelectService      ctrlStep5 = findControlRecu(this.Page, "step5")  as StepSelectService;

        /*-------------------------------
         * Locate data controls
         *------------------------------*/ 

        WebUIControlDataField ctrlRecID     = findControlRecu(this.Page, "recid")         as WebUIControlDataField;
        WebUIControlDataField ctrlRef       = findControlRecu(this.Page, "reference")     as WebUIControlDataField;
        WebUIControlDataField ctrlDos       = findControlRecu(this.Page, "dos")           as WebUIControlDataField;
        WebUIControlDataField ctrlNameID    = findControlRecu(this.Page, "nameid")        as WebUIControlDataField;
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
        
        SelectSessionAttendanceStatus ctrlAttendanceStatus = findControlRecu(this.Page, "attendancestatus")   as SelectSessionAttendanceStatus;
        NoteAreaBox                   ctrlNotes            = findControlRecu(this.Page, "notes")              as NoteAreaBox;
   
        /*-------------------------------
         * Populate step labels
         *------------------------------*/ 

        ctrlStep1.label = sr.pracName;
        ctrlStep2.label = sr.dos.ToShortDateString();
        ctrlStep3.label = sr.patName;
        ctrlStep4.label = Util.boolToYesNo(sr.isIFSPorIEP);
        ctrlStep5.label = sr.svcName;

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

          ctrlStep6.label = ((sr.numMins == 0) ? "" : sr.numMins.ToString()) + " | " + sr.startTimeStr;
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
          ctrlStep6.label  = sr.tripsMiles;

        }
        
        ctrlStep7.label = sr.attendanceStatusSelectionName;
        ctrlStep8.label = sr.notes;
        
       /*-------------------------------
        * Populate Data Values
        *------------------------------*/ 

        ctrlStep3.selectvalue  = sr.patID.ToString();
        ctrlStep1.selectvalue  = sr.pracID.ToString();

        ctrlRecID.value    = sr.id.ToString();
        ctrlRef.value      = sr.reference;
        ctrlDos.value      = sr.dos.ToShortDateString();
        ctrlIsIEP.value    = Util.boolToYesNo(sr.isIFSPorIEP);
        
        ctrlStep5.nameIDValue         = sr.nameID.ToString();
        
        ctrlStep5.hasORPDocIDValue    = Util.boolTo1or0Str(sr.hasOrpDocID);
        ctrlStep5.selORPDocIDValue    = sr.orpDocID.ToString();
        ctrlStep5.selORPDocIDLabel    = sr.orpDocLabel;
        
        ctrlStep5.hasSvcDetFlagsValue = Util.boolTo1or0Str(sr.hasSvcDetFlags);
        ctrlStep5.svcDetFlag1Value    = Util.boolToYesNo(sr.svcDetFlag1);
        ctrlStep5.svcDetFlag2Value    = Util.boolToYesNo(sr.svcDetFlag2);
        ctrlStep5.svcDetFlag3Value    = Util.boolToYesNo(sr.svcDetFlag3);
        ctrlStep5.svcDetFlag4Value    = Util.boolToYesNo(sr.svcDetFlag4);
        
        ctrlStartTime.value = sr.startTimeStr;
        ctrlNumMin.value    = (sr.numMins == 0) ? "" : sr.numMins.ToString();
        
        ctrlTp1Start.value = (sr.trip1Start == 0) ? "" : sr.trip1Start.ToString();  // Handles case of 0
        ctrlTp2Start.value = (sr.trip2Start == 0) ? "" : sr.trip2Start.ToString();  // Handles case of 0
        ctrlTp3Start.value = (sr.trip3Start == 0) ? "" : sr.trip3Start.ToString();  // Handles case of 0
        ctrlTp4Start.value = (sr.trip4Start == 0) ? "" : sr.trip4Start.ToString();  // Handles case of 0

        ctrlTp1End.value   = (sr.trip1End   == 0) ? "" : sr.trip1End.ToString();    // Handles case of 0
        ctrlTp2End.value   = (sr.trip2End   == 0) ? "" : sr.trip2End.ToString();    // Handles case of 0
        ctrlTp3End.value   = (sr.trip3End   == 0) ? "" : sr.trip3End.ToString();    // Handles case of 0
        ctrlTp4End.value   = (sr.trip4End   == 0) ? "" : sr.trip4End.ToString();    // Handles case of 0
        
        ctrlAttendanceStatus.value = sr.attendanceStatusSelectionID.ToString();

        ctrlNotes.value = sr.notes;

        this.subTitle = "Service Records - Edit";
        
        ctrlSteps.firstStep = 8;

      }
      else
      {
        /*-------------------------------
         * Otherwise its a new record
         *------------------------------*/ 
         this.subTitle      = "Service Records - New";
      }
    }
  }
}
