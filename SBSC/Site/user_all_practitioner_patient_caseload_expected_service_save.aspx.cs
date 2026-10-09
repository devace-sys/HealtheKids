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
     * UserAllPractitionerPatientCaseloadExpectedServiceSave */
    /**
     *
 	 ***************************************************************************/

    public class UserAllPractitionerPatientCaseloadExpectedServiceSave : WebUI
    {

        public UserAllPractitionerPatientCaseloadExpectedServiceSave() : base(  @"user_all_practitioner_patient_caseload_expected_service_save"
                                                     , PractitionerPatientCaseloadExpectedServices.SEL_LABEL_EXPECTED_SERVICE_NEW
                                                     , @"caseload-and-patient-group-mgmt.css"
                                                     , @"practitioner_preference_sped_services_restview.js|practitioner-patient-scheduled-services-manage.js"
                                                     , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }

        public int      saveType                 = Constants.SAVE_TYPE_NEW;
        public string   patEditUrlBase           = @"";
        public bool     lockServiceTerms         = false;
        public bool     clientAndPracAreOK       = true;
        public bool     showSvcsForLeaBop        = true;
        public bool     showSvcsForLeaBopNonSpEd = true;
        public bool     showSvcsForCYBHI         = true;
        public bool     showSvcsForRUHealth      = true;
        protected void Page_Load(object sender, EventArgs e)
        {

            /*###########################################################################
              # Fetch parameters 
              ###########################################################################*/

            string savetype  = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
            string recid     = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);            
            string clientid  = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            string pracid    = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
           
            /*###########################################################################
              # Determine save type
              ###########################################################################*/

            Object vSaveType = Spedmon.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);
            saveType = Constants.SAVE_TYPE_NEW;
            if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
            saveType = (int)vSaveType;
            
            /*###########################################################################
              # Validate client and prac
              ###########################################################################*/
            
            clientAndPracAreOK = true;

            try
            { 
              int vClientID = Spedmon.Validate.reqClientID(uInfo,clientid);
              int vPracID   = Spedmon.Validate.reqPracID(uInfo,pracid);
              clientid      = vClientID.ToString();
              pracid        = vPracID.ToString();
            }
            catch
            {
                clientAndPracAreOK = false;
                return;
            }

            /*###########################################################################
              # Load practitioner data
              ###########################################################################*/
            
            var prac = Practitioners.load(dbConnApp,log,uInfo,pracid);
            showSvcsForLeaBop        = prac.participatesInLEABOP;
            showSvcsForLeaBopNonSpEd = prac.participatesInLEABOPNonSpEd;
            showSvcsForCYBHI         = prac.participatesInCYBHI;
            showSvcsForRUHealth      = prac.participatesInRUHealth;

            /*###########################################################################
              # Get references to data entry controls 
              ###########################################################################*/
            
            var ctrlOpenDiaSvcResp          = findControlRecu(this.Page, "butDoManageCalpadPrefs")       as MBA.DataEntryButton;
            var ctrlClientID                = findControlRecu(this.Page, "clientid")                     as MBA.HiddenInput;
            var ctrlPracID                  = findControlRecu(this.Page, "pracid")                       as MBA.HiddenInput;
            var ctrlSelectPatient           = findControlRecu(this.Page, "selectPatient")                as MBA.DataEntryRowSelectPatient;
            var ctrlSelectSvcTrackingClass  = findControlRecu(this.Page, "svctrackingclass")             as MBA.DataEntryBoxSelect;
            var ctrlSpEdSvcCode             = findControlRecu(this.Page, "spedservicecode")              as MBA.HiddenInput;
            var ctrlSelectPromisedSvc       = findControlRecu(this.Page, "promisedserviceid")            as MBA.ComboBox;
            var ctrlSelectOrpDoc            = findControlRecu(this.Page, "orpdocid")                     as MBA.ComboBox;
            var ctrlSelectSvcNameDS         = findControlRecu(this.Page, "svcnameslistdatasourceid")     as MBA.DataEntryBoxSelect;                        
            var ctrlSelectViaTeleHealth     = findControlRecu(this.Page, "viatelehealth")                as MBA.SelectYesOrNo;
            var ctrlSelectService           = findControlRecu(this.Page, "selectService")                as MBA.DataEntryRowSelectService;
            var ctrlAltModNameID            = findControlRecu(this.Page, "altmodalitynameid")            as MBA.HiddenInput;
            var ctrlDos                     = findControlRecu(this.Page, "dos")                          as MBA.HiddenInput;
            var ctrlSelectSpEdFreqCode      = findControlRecu(this.Page, "spedfreqcode")                 as MBA.ComboBox;
            var ctrlStartDate               = findControlRecu(this.Page, "startdate")                    as MBA.DataEntryBoxDate;
            var ctrlStartDateAss            = findControlRecu(this.Page, "startdateassigned")            as MBA.DataEntryBoxDate;
            var ctrlEndDate                 = findControlRecu(this.Page, "enddate")                      as MBA.DataEntryBoxDate;
            var ctrlMinsPerFreq             = findControlRecu(this.Page, "minsperfreq")                  as MBA.DataEntryBoxNumber;
            var ctrlMinsPerFreqAss          = findControlRecu(this.Page, "minsperfreqassigned")          as MBA.DataEntryBoxNumber;
            var ctrlHasSvcDetails           = findControlRecu(this.Page, "hassvcdetails")                as MBA.HiddenInput;
            var ctrlSvcDetailsJSON          = findControlRecu(this.Page, "svcdetailsjson")               as MBA.HiddenTextArea;
            var ctrlSaveOrEdit              = findControlRecu(this.Page, "saveOrEdit")                   as MBA.DataEntryRowSaveOrEdit;

            var ctrlPracPatCaseloadExpectedSvcID = findControlRecu (this.Page, Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID) as MBA.HiddenInput;
            var ctrlRelatedScheduledServices     = findControlRecu (this.Page,"relatedScheduledServices")                        as MBA.DataEntryRow;
            
           /*###########################################################################
             # Set title and label for svc responsibilities (CALPADS I Support)
             ###########################################################################*/

           ctrlOpenDiaSvcResp.label = Spedmon.PractitionerPreferenceSpedServices.calpadsCodeSupportTitle;
           ctrlOpenDiaSvcResp.title = Spedmon.PractitionerPreferenceSpedServices.calpadsCodeSupportTooltip;
                       
           /*###########################################################################
              # Get service name list data sources prac can pick from
              ###########################################################################*/
            
            var svcNameDataSources = Services.viewListOfSvcNameListDataSources (
                  showSvcsForLeaBop
                , showSvcsForLeaBopNonSpEd
                , showSvcsForCYBHI
                , showSvcsForRUHealth );

            /*###########################################################################
              # Add options for service name list data source using this list
              ###########################################################################*/
            
            ctrlSelectSvcNameDS.addSelectOneSelection = false;
            
            foreach(var svcNameDataSource in svcNameDataSources) {             
              var newSelection      = svcNameDataSource;
              newSelection.typename = @"";              
              ctrlSelectSvcNameDS.addSelection(newSelection);              
            }
           
            /*###########################################################################
              # Add options for service tracking class
              ###########################################################################*/
            
            ctrlSelectSvcTrackingClass.addSelectOneSelection = false;

            ctrlSelectSvcTrackingClass.addSelection(new NameValue (  PractitionerPatientCaseloadExpectedServices.SVC_TRACKING_CLASS_SPED_NAME 
                                                           , PractitionerPatientCaseloadExpectedServices.SVC_TRACKING_CLASS_SPED_VALUE
                                                           , ""));

            ctrlSelectSvcTrackingClass.addSelection(new NameValue (  PractitionerPatientCaseloadExpectedServices.SVC_TRACKING_CLASS_NON_SPED_NAME   
                                                           , PractitionerPatientCaseloadExpectedServices.SVC_TRACKING_CLASS_NON_SPED_VALUE
                                                           , ""));
            
            ctrlSelectSvcTrackingClass.addSelection(new NameValue (  PractitionerPatientCaseloadExpectedServices.SVC_TRACKING_CLASS_USER_PROVIDED_NAME    
                                                           , PractitionerPatientCaseloadExpectedServices.SVC_TRACKING_CLASS_USER_PROVIDED_VALUE
                                                           , ""));
            
            /*###########################################################################
              # Set date of service
              ###########################################################################*/

            ctrlDos.value = DateTime.Now.ToShortDateString();
                        
            /*###########################################################################
              # Set recid and save type
              ###########################################################################*/

            ctrlSaveOrEdit.recID    = recid;
            ctrlSaveOrEdit.saveType = saveType;
            
            /*###########################################################################
              # Add New
              ###########################################################################*/

            if (saveType == Constants.SAVE_TYPE_NEW) {

                ctrlClientID.value                 = clientid;
                ctrlPracID.value                   = pracid;
                ctrlSelectSvcTrackingClass.value   = PractitionerPatientCaseloadExpectedServices.SVC_TRACKING_CLASS_SPED_VALUE;
                ctrlHasSvcDetails.value            = "N";
                ctrlSvcDetailsJSON.value           = "{}";
                ctrlSelectPatient.showAddNew       = true;
                ctrlSelectViaTeleHealth.setValue(false);        
                ctrlRelatedScheduledServices.entryInitiallyHidden = true;
             }

            /*###########################################################################
              # Edit
              ###########################################################################*/

            else if (saveType == Constants.SAVE_TYPE_EDIT) {

                this.subTitle = PractitionerPatientCaseloadExpectedServices.SEL_LABEL_EXPECTED_SERVICE_EDIT;

                /*------------------------------------*/
                /*  Load previously saved record      */
                /*------------------------------------*/

                var rec = PractitionerPatientCaseloadExpectedServices.load(dbConnApp,log,uInfo,clientid,pracid,"",recid);

                ctrlClientID.value                 = rec.clientID.ToString();
                ctrlPracID.value                   = rec.pracID.ToString();
                ctrlSelectPatient.selectValue      = rec.patID.ToString();
                ctrlSelectPatient.selectName       = rec.patName;
                ctrlSelectPatient.showAddNew       = false;
                ctrlSelectSvcTrackingClass.value   = rec.svcTrackingClass.ToString();
                
                /* Note: Only sped service code is saved.  Users select sped service code from promised services list */

                ctrlSelectPromisedSvc.selectName   = rec.spEdServiceName;                
                ctrlSpEdSvcCode.value              = (rec.spEdServiceCode == 0) ? "" : rec.spEdServiceCode.ToString();
                if (rec.spEdServiceCode > 0) lockServiceTerms = true;
                
                ctrlSelectOrpDoc.selectName        = rec.orpDocName;
                ctrlSelectOrpDoc.value             = (rec.orpDocID == 0) ? "" : rec.orpDocID.ToString();
                if (rec.orpDocID > 0) lockServiceTerms = true;

                ctrlSelectSvcNameDS.value          = rec.svcNamesListDataSourceID.ToString();
                ctrlSelectViaTeleHealth.setValue(rec.viaTeleHealth);
                ctrlSelectService.selectName       = rec.svcName;
                ctrlSelectService.selectValue      = (rec.nameID == 0) ? "" : rec.nameID.ToString();                
                ctrlAltModNameID.value             = (rec.altModalityNameID == 0) ? "" : rec.altModalityNameID.ToString();
                ctrlSelectSpEdFreqCode.selectName  = rec.spEdFreqName;
                ctrlSelectSpEdFreqCode.value       = (rec.spEdFreqCode == 0) ? "" : rec.spEdFreqCode.ToString();

                ctrlStartDate.setValue(rec.startDateStrYMD);
                ctrlEndDate.setValue(rec.endDateStrYMD);
                
                ctrlMinsPerFreq.value              = rec.minsPerFreq;

                ctrlStartDateAss.setValue(rec.startDateAssignedStrYMD); 
                ctrlMinsPerFreqAss.value           = rec.minsPerFreqAssigned;

                ctrlHasSvcDetails.value                = rec.hasSvcDetailsStr;
                ctrlSvcDetailsJSON.value               = rec.svcDetailsJSON;
                ctrlPracPatCaseloadExpectedSvcID.value = rec.id.ToString();
                ctrlRelatedScheduledServices.entryInitiallyHidden = false;
            }
            else {
            
            }

            patEditUrlBase = Patients.URL_USER_ALL_EDIT_EXISTING_BASE(true,"");
      }
  }
}