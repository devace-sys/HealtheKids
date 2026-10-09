using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
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
     * UserAllPractitionerPatientScheduledServiceSave */
    /**
     *
 	 ***************************************************************************/

    public class UserAllPractitionerPatientScheduledServiceSave : WebUI
    {

        public UserAllPractitionerPatientScheduledServiceSave() : base (  
                                                       @"user_all_practitioner_patient_scheduled_service_save"
                                                     , PractitionerPatientScheduledServices.SEL_LABEL_ADD_NEW
                                                     , @""
                                                     , @""
                                                     , Constants.ROLE_ALL_PCAL_AND_CLIENT )
        { }

        public int      saveType                 = Constants.SAVE_TYPE_NEW;
        public bool     isPrac                   = false;
        public bool     showSvcsForLeaBop        = true;
        public bool     showSvcsForLeaBopNonSpEd = true;
        public bool     showSvcsForCYBHI         = true;
        public bool     showSvcsForRUHealth      = true;
        public bool     clientAndPracAreOK       = true;
        public bool     lockSelectPatient        = false;
        public DateTime today                    = DateTime.Now;
        public bool     fromCaseloadRow          = false;
        public bool     hasPPCES                 = false;

        protected void Page_Load(object sender, EventArgs e)
        {
                
            /*###########################################################################
              # Fetch parameters 
              ###########################################################################*/

            string savetype  = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
            string recid     = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);            
            string clientid  = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            string pracid    = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
            string patid     = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);

            string frmAgnd = MBA.HttpApplication.getParameter(Constants.PARM_SVC_FRM_AGENDA);

            string pracPatCaseloadExpectedSvcID = MBA.HttpApplication.getParameter(Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID);

            /*###########################################################################
              # Determine save type
              ###########################################################################*/

            Object vSaveType = Spedmon.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);
            saveType = Constants.SAVE_TYPE_NEW;
            if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
            saveType = (int)vSaveType;
            
            /*###########################################################################
              # Validate required references (client and prac)
              ###########################################################################*/
            
            clientAndPracAreOK = true;

            try
            { 
              int vClientID = Spedmon.Validate.reqClientID (uInfo, clientid);
              int vPracID   = Spedmon.Validate.reqPracID   (uInfo, pracid);
              clientid      = vClientID.ToString();
              pracid        = vPracID.ToString();
            }
            catch
            {
              clientAndPracAreOK = false;
            }
            
            if (clientAndPracAreOK == false) return;


            /*###########################################################################
              # Get references to data entry controls 
              ###########################################################################*/
            
            var ctrlSelectCaseloadEntryRow  = findControlRecu(this.Page, "selectRelatedToCaseloadRow")                     as DataEntryRow;
            var ctrlPracPatCaseloadExpSvcID = findControlRecu(this.Page, Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID) as MBA.ComboBox;
            var ctrlSelectPlanType          = findControlRecu(this.Page, Constants.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID)     as MBA.DataEntryBoxSelect;

            var ctrlClientID             = findControlRecu(this.Page, Constants.PARM_CLIENT_ID)       as MBA.HiddenInput;
            var ctrlPracID               = findControlRecu(this.Page, Constants.PARM_PRACTITIONER_ID) as MBA.HiddenInput;
            var ctrlSelectPatient        = findControlRecu(this.Page, "selectPatient")                as MBA.DataEntryRowSelectPatient;
            var ctrlSelectRecurring      = findControlRecu(this.Page, "recurring")                    as MBA.SelectYesOrNo;
            var ctrlSelectViaTeleHealth  = findControlRecu(this.Page, "viatelehealth")                as MBA.SelectYesOrNo;
            var ctrlSelectService        = findControlRecu(this.Page, "selectService")                as MBA.DataEntryRowSelectService;
            var ctrlAltModNameID         = findControlRecu(this.Page, "altmodalitynameid")            as MBA.HiddenInput;
            var ctrlStartDate            = findControlRecu(this.Page, "startdate")                    as MBA.DataEntryBoxDate;
            var ctrlDos                  = findControlRecu(this.Page, "dos")                          as MBA.HiddenInput;
            var ctrlEndDate              = findControlRecu(this.Page, "enddate")                      as MBA.DataEntryBoxDate;
            var ctrlNumMins              = findControlRecu(this.Page, "nummins")                      as MBA.DataEntryBoxNumber;
            var ctrlStartTime            = findControlRecu(this.Page, "starttime")                    as MBA.DataEntryBoxTime;
            
            var ctrlMon                  = findControlRecu(this.Page, "mon")                          as MBA.CheckBox;
            var ctrlTue                  = findControlRecu(this.Page, "tue")                          as MBA.CheckBox;
            var ctrlWed                  = findControlRecu(this.Page, "wed")                          as MBA.CheckBox;
            var ctrlThu                  = findControlRecu(this.Page, "thu")                          as MBA.CheckBox;
            var ctrlFri                  = findControlRecu(this.Page, "fri")                          as MBA.CheckBox;

            var ctrlMonStartTime         = findControlRecu(this.Page, "monstarttime")                 as MBA.DataEntryBoxTime;
            var ctrlTueStartTime         = findControlRecu(this.Page, "tuestarttime")                 as MBA.DataEntryBoxTime;
            var ctrlWedStartTime         = findControlRecu(this.Page, "wedstarttime")                 as MBA.DataEntryBoxTime;
            var ctrlThuStartTime         = findControlRecu(this.Page, "thustarttime")                 as MBA.DataEntryBoxTime;
            var ctrlFriStartTime         = findControlRecu(this.Page, "fristarttime")                 as MBA.DataEntryBoxTime;
            var ctrlNotes                = findControlRecu(this.Page, "notes")                        as MBA.DataEntryBoxTextArea;
            var ctrlSaveOrEdit           = findControlRecu(this.Page, "saveOrEdit")                   as MBA.DataEntryRowSaveOrEdit;
                       
            /*###########################################################################
              # Load practitioner data
              ###########################################################################*/
            
            var prac = Practitioners.load(dbConnApp,log,uInfo,pracid);
            showSvcsForLeaBop        = prac.participatesInLEABOP;
            showSvcsForLeaBopNonSpEd = prac.participatesInLEABOPNonSpEd;
            showSvcsForCYBHI         = prac.participatesInCYBHI;
            showSvcsForRUHealth      = prac.participatesInRUHealth;
            
            /*###########################################################################
              # Get service name list data sources prac can pick from
              ###########################################################################*/
            
            var svcNameDataSources = Services.viewListOfSvcNameListDataSources (                  
                  showSvcsForLeaBop
                , showSvcsForLeaBopNonSpEd
                , showSvcsForCYBHI
                , showSvcsForRUHealth );

            /*###########################################################################
              # Add options for plan type using the service name list data sources
              ###########################################################################*/
            
            ctrlSelectPlanType.addSelectOneSelection = false;
            
            foreach(var svcNameDataSource in svcNameDataSources) {             
              var newSelection      = svcNameDataSource;
              newSelection.typename = @"";
              ctrlSelectPlanType.addSelection(newSelection);              
            }
            
            /*###########################################################################
              # Set recid and save type
              ###########################################################################*/

            ctrlSaveOrEdit.recID    = recid;
            ctrlSaveOrEdit.saveType = saveType;
            
            /*###########################################################################
              # Set passed in values for client and practitioner 
              ###########################################################################*/

             ctrlClientID.value  = clientid;
             ctrlPracID.value    = pracid;              
            
            /*###########################################################################
              # Setup reference for ppces.  We will populate this with a passed in value
              # for new rows or load previously associated ppces id for edits
              ###########################################################################*/
            
            PractitionerPatientCaseloadExpectedService ppces = new PractitionerPatientCaseloadExpectedService();
            fromCaseloadRow = false;
            hasPPCES        = false;
            if (!String.IsNullOrWhiteSpace(pracPatCaseloadExpectedSvcID)) {
              fromCaseloadRow = true;              
            }

            /*###########################################################################
              # Set date of service
              ###########################################################################*/

            ctrlDos.value = DateTime.Now.ToShortDateString();

            /*###########################################################################
              # Add New
              ###########################################################################*/

            if (saveType == Constants.SAVE_TYPE_NEW) {
               
              /*------------------------------------*/
              /* Load data for prac pat caseload    */
              /* expected service if this request   */
              /* came from a caseload row           */
              /*------------------------------------*/
            
              hasPPCES = false;
              if (fromCaseloadRow == true)
              {                     
                try { 
                  ppces = PractitionerPatientCaseloadExpectedServices.load(dbConnApp,log,uInfo,clientid,pracid,patid,pracPatCaseloadExpectedSvcID);                
                  hasPPCES = true;
                }
                catch
                {
                  hasPPCES = false;
                }                
              }

              /*------------------------------------*/
              /* Load data for patient if reference */
              /* is passed in and set flag to       */
              /* indicate patient selection should  */
              /* be locked.                         */
              /*------------------------------------*/
                   
              if (!String.IsNullOrWhiteSpace(patid))
              {
                patid = Spedmon.Validate.optPatID(uInfo,patid).ToString();
                var pat = Patients.load(dbConnApp,log,uInfo,patid);
                ctrlSelectPatient.selectValue = patid;
                ctrlSelectPatient.selectName  = pat.name;         
                lockSelectPatient = true;
              }
            
              /*------------------------------------*/
              /* Preset various fields if           */
              /* prac pat caseload expected svc     */
              /* data is available                  */
              /*------------------------------------*/
                           
              if (hasPPCES == true)
              {
                
                ctrlPracPatCaseloadExpSvcID.value      = pracPatCaseloadExpectedSvcID;
                ctrlPracPatCaseloadExpSvcID.selectName = ppces.name;
                ctrlStartDate.setValue(ppces.startDateAssignedStr);
                ctrlEndDate.setValue(ppces.endDateStr);
                //ctrlStartDate.value               = ppces.startDateAssigned;
                //ctrlEndDate.value                 = ppces.endDate;                
              }
              else
              {
                ctrlPracPatCaseloadExpSvcID.value = "";
                ctrlStartDate.value               = today;
                ctrlEndDate.setValue("");
              }


              /*------------------------------------*/
              /* Preset other fields                */
              /*------------------------------------*/
              if (string.IsNullOrEmpty(frmAgnd) || frmAgnd.Equals("false", StringComparison.OrdinalIgnoreCase))
              {
                  ctrlSelectRecurring.setValue(true);
              }
              else
              {
                  ctrlSelectRecurring.setValue(false);
              }
              
              ctrlSelectViaTeleHealth.setValue(false);
             
              ctrlMon.value = false;
              ctrlTue.value = false;
              ctrlWed.value = false;
              ctrlThu.value = false;
              ctrlFri.value = false;      
              
              ctrlNotes.value = "";
            }

            /*###########################################################################
              # Edit
              ###########################################################################*/

            else if (saveType == Constants.SAVE_TYPE_EDIT) {

                /*------------------------------------*/
                /* Change page title                  */
                /*------------------------------------*/

                this.subTitle = PractitionerPatientScheduledServices.SEL_LABEL_EDIT;

                /*------------------------------------*/
                /* Load previously saved record       */
                /*------------------------------------*/

                var rec = PractitionerPatientScheduledServices.load(dbConnApp,log,uInfo,clientid,pracid,recid);

                /*------------------------------------*/
                /* Set values                         */
                /*------------------------------------*/

                ctrlClientID.value              = rec.clientID.ToString();
                ctrlPracID.value                = rec.pracID.ToString();
                               
                ctrlSelectPatient.selectValue   = rec.patID.ToString();
                ctrlSelectPatient.selectName    = rec.patName;
                ctrlSelectPlanType.value        = rec.svcNamesListDataSourceID.ToString();

                ctrlSelectRecurring.setValue     (rec.recurring);
                ctrlSelectViaTeleHealth.setValue (rec.viaTeleHealth);
                
                ctrlSelectService.selectValue = rec.nameID.ToString();
                ctrlSelectService.selectName  = rec.svcName;
                ctrlAltModNameID.value        = rec.altModalityNameID.ToString();
                
                ctrlStartDate.value = rec.startDate;
                ctrlEndDate.setValue(rec.endDateYMD);
                ctrlNumMins.value = rec.numMins;
                ctrlStartTime.setValue(rec.startTimeHMS);
                ctrlNotes.value = rec.notes;
                
                ctrlMon.value = rec.mon;
                ctrlTue.value = rec.tue;
                ctrlWed.value = rec.wed;
                ctrlThu.value = rec.thu;
                ctrlFri.value = rec.fri;

                ctrlMonStartTime.setValue(rec.monStartTimeHMS);
                ctrlTueStartTime.setValue(rec.tueStartTimeHMS);
                ctrlWedStartTime.setValue(rec.wedStartTimeHMS);
                ctrlThuStartTime.setValue(rec.thuStartTimeHMS);
                ctrlFriStartTime.setValue(rec.friStartTimeHMS);
                
                /*------------------------------------*/
                /* Load previously associated ppces   */
                /* data.                              */
                /*------------------------------------*/

                ctrlPracPatCaseloadExpSvcID.value = rec.practitionerPatientCaseloadExpectedServiceID.ToString();                
                hasPPCES = false;
                if (ctrlPracPatCaseloadExpSvcID.value != "0") {                  
                  try { 
                    ppces = PractitionerPatientCaseloadExpectedServices.load( dbConnApp
                                                                         , log
                                                                         , uInfo
                                                                         , rec.clientID.ToString()
                                                                         , rec.pracID.ToString()
                                                                         , rec.patID.ToString()
                                                                         , rec.practitionerPatientCaseloadExpectedServiceID.ToString());
               
                    hasPPCES = true;
                    ctrlPracPatCaseloadExpSvcID.selectName = ppces.name;
                  } 
                  catch
                  {
                    hasPPCES = false; 
                  }                  
                }

                /*------------------------------------*/
                /* Set flag to indicate patient       */
                /* selection should be locked         */
                /*------------------------------------*/

                lockSelectPatient = true;                               
                
            }
            else {
            
            }

            /*###########################################################################
              # Show or hide associated caseload entry row based on where user is coming
              # from.
              ###########################################################################*/

            /*------------------------------------*/
            /* From caseload row.                 */
            /* Selection should be hidden         */
            /*------------------------------------*/

            if (fromCaseloadRow == true) { 
                ctrlSelectCaseloadEntryRow.entryInitiallyHidden = true;
            }

            /*------------------------------------*/
            /* From external manage.              */
            /* Selection should be shown         */
            /*------------------------------------*/

            else {  
                ctrlSelectCaseloadEntryRow.entryInitiallyHidden = false;
            }

      }
  }
}