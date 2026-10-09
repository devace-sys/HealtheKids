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
   * ClientProvServiceRecordSave */
  /**
   * Saves a service record
   ***************************************************************************/   

  public class ClientProvServiceRecordSave : WebUI
  {
    public int saveType = 0;

    public ClientProvServiceRecordSave() : base("service_record_save","Service Records - Save","","",Constants.ROLE_CLIENT_ALL){}
    
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

      Steps                 ctrlSteps    = findControlRecu(this.Page, "save")          as Steps;
      WebUIControlDataField ctrlSaveType = findControlRecu(this.Page, "savetype")      as WebUIControlDataField;
      
      ctrlSaveType.value = saveType.ToString();

      /* If user is logged in get client and prac id */
      
      if (rd.loggedIn) 
      {
        WebUIControlDataField ctrlClientID = findControlRecu(this.Page, "clientid")      as WebUIControlDataField;
        WebUIControlDataField ctrlPracID   = findControlRecu(this.Page, "pracid")        as WebUIControlDataField;

        ctrlClientID.value = Spedmon.Validate.reqClientID (uInfo, "").ToString();
        ctrlPracID.value   = Spedmon.Validate.reqPracID   (uInfo, "").ToString();
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

        Step ctrlStep1 = findControlRecu(this.Page,"step1") as Step;
        Step ctrlStep3 = findControlRecu(this.Page,"step3") as Step;
        Step ctrlStep5 = findControlRecu(this.Page,"step5") as Step;
        Step ctrlStep6 = findControlRecu(this.Page,"step6") as Step;
        Step ctrlStep7 = findControlRecu(this.Page,"step7") as Step;
        Step ctrlStep8 = findControlRecu(this.Page,"step8") as Step;
        
        StepSelectPatient ctrlStep2 = findControlRecu(this.Page, "step2")  as StepSelectPatient;
        StepSelectService ctrlStep4 = findControlRecu(this.Page, "step4")  as StepSelectService;
        
        /*-------------------------------
         * Locate data controls
         *------------------------------*/ 

        WebUIControlDataField ctrlRecID     = findControlRecu(this.Page, "recid")         as WebUIControlDataField;
        WebUIControlDataField ctrlRef       = findControlRecu(this.Page, "reference")     as WebUIControlDataField;
        WebUIControlDataField ctrlDos       = findControlRecu(this.Page, "dos")           as WebUIControlDataField;
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

        ctrlStep1.label = sr.dos.ToShortDateString();
        ctrlStep2.label = sr.patName;
        ctrlStep3.label = Util.boolToYesNo(sr.isIFSPorIEP);
        ctrlStep4.label = sr.svcName;
        
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

          ctrlStep5.label = ((sr.numMins == 0) ? "" : sr.numMins.ToString()) + " | " + sr.startTimeStr;
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
          ctrlStep5.label  = sr.tripsMiles;

        }
               
        ctrlStep6.label = sr.attendanceStatusSelectionName;       
        ctrlStep7.label = sr.notes;
        
       /*-------------------------------
        * Populate Data Values
        *------------------------------*/ 

        ctrlStep2.selectvalue  = sr.patID.ToString();
        
        ctrlRecID.value    = sr.id.ToString();
        ctrlRef.value      = sr.reference;
        ctrlDos.value      = sr.dos.ToShortDateString();
        ctrlIsIEP.value    = Util.boolToYesNo(sr.isIFSPorIEP);
        
        /* Service and service details */
        
        ctrlStep4.nameIDValue         = sr.nameID.ToString();
        
        ctrlStep4.hasORPDocIDValue    = Util.boolTo1or0Str(sr.hasOrpDocID);        
        ctrlStep4.selORPDocIDValue    = sr.orpDocID.ToString();
        ctrlStep4.selORPDocIDLabel    = sr.orpDocLabel;
                        
        ctrlStep4.hasSvcDetFlagsValue = Util.boolTo1or0Str(sr.hasSvcDetFlags);
        ctrlStep4.svcDetFlag1Value    = Util.boolToYesNo(sr.svcDetFlag1);
        ctrlStep4.svcDetFlag2Value    = Util.boolToYesNo(sr.svcDetFlag2);
        ctrlStep4.svcDetFlag3Value    = Util.boolToYesNo(sr.svcDetFlag3);
        ctrlStep4.svcDetFlag4Value    = Util.boolToYesNo(sr.svcDetFlag4);
        
        ctrlStartTime.value = (sr.startTimeStr);
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
        ctrlNotes.value     = sr.notes;

        this.subTitle = "Service Records - Edit";
        ctrlSteps.firstStep = 7;

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
