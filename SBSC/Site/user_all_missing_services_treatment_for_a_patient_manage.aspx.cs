using System;
using MBA;

namespace Spedmon
{
    public class UserAllMissingServicesTreatmentForAPatient : WebUI
    {
        public UserAllMissingServicesTreatmentForAPatient() : base(
                                              MissingServicesTreatmentsForAPatient.MENU_ID_MANAGE
                                            , MissingServicesTreatmentsForAPatient.SEL_LABEL_MANAGE
                                            , ""
                                            , ""
                                            , Constants.ROLE_MISSING_SERVICES_MANAGE)
        { }

        public string urlRecordMissingSvcsForPatient             = @"";
        public string urlViewSvcsEnteredForPatient               = @"";
        public string urlGetNonPromisedServicesEnteredForPatient = @"";  /* TODO: Possible future use */

        public string patID                           = @"";
        public Patient pat                            = null;

        public bool   okToShowRecordMissingSvcs       = false;
        public bool   okToShowDeferMissingSvcs        = false;
        protected void Page_Load(object sender, EventArgs e)
        {
            pat = new Patient();

            var ctrlClientID             = findControlRecu(this.Page, Constants.PARM_CLIENT_ID)                as MBA.HiddenInput;
            var ctrlSpEdSvcCode          = findControlRecu(this.Page, Constants.PARM_SPED_SERVICE_CODE)        as MBA.HiddenInput;
            var ctrlOrpDocID             = findControlRecu(this.Page, Constants.PARM_ORP_DOC_ID)               as MBA.HiddenInput;
            var ctrlGrpSvcClsNmeID       = findControlRecu(this.Page, Constants.PARM_GRP_SVC_CLS_NME_ID)       as MBA.HiddenInput;
            
            var ctrlSvcTrackingClass     = findControlRecu(this.Page, Constants.PARM_SVC_TRACKING_CLASS)       as MBA.HiddenInput;
            var ctrlPatID                = findControlRecu(this.Page, Constants.PARM_PATIENT_ID)               as MBA.HiddenInput;
            var ctrlPracID               = findControlRecu(this.Page, Constants.PARM_PRACTITIONER_ID)          as MBA.HiddenInput;

            var ctrlLeaBopOnlyOrAllSpEd  = findControlRecu(this.Page, Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED) as MBA.HiddenInput;
            var ctrlStartDate            = findControlRecu(this.Page, Constants.PARM_START_DATE)               as MBA.HiddenInput;
            var ctrlEndDate              = findControlRecu(this.Page, Constants.PARM_END_DATE)                 as MBA.HiddenInput;
            var ctrlRefScreen            = findControlRecu(this.Page, Constants.PARM_REF_SCREEN)               as MBA.HiddenInput;

            var ctrlExceptionAddReasonPromisedService    = findControlRecu(this.Page, "exceptionaddreasonpromisedserviceid")     as MBA.DataEntryBoxSelect;
            var ctrlExceptionRemoveReasonPromisedService = findControlRecu(this.Page, "exceptionremovereasonpromisedserviceid")  as MBA.DataEntryBoxSelect;

            var clientID             = HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            var spEdSvcCode          = HttpApplication.getParameter(Constants.PARM_SPED_SERVICE_CODE);
            var orpDocID             = HttpApplication.getParameter(Constants.PARM_ORP_DOC_ID);
            var groupSvcClassNameID  = HttpApplication.getParameter(Constants.PARM_GRP_SVC_CLS_NME_ID);
            var svcTrackingClass     = HttpApplication.getParameter(Constants.PARM_SVC_TRACKING_CLASS);
            var pracID               = HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
            var leaBopOnlyOrAllSpEd  = HttpApplication.getParameter(Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED);
            var startDate            = HttpApplication.getParameter(Constants.PARM_START_DATE);
            var endDate              = HttpApplication.getParameter(Constants.PARM_END_DATE);
            var refScreen            = HttpApplication.getParameter(Constants.PARM_REF_SCREEN);
           
            patID                    = HttpApplication.getParameter(Constants.PARM_PATIENT_ID);

            ctrlClientID.value            = clientID;
            ctrlSpEdSvcCode.value         = spEdSvcCode;
            ctrlOrpDocID.value            = orpDocID;
            ctrlGrpSvcClsNmeID.value      = groupSvcClassNameID;
            ctrlSvcTrackingClass.value    = svcTrackingClass;
            ctrlPatID.value               = patID;
            ctrlPracID.value              = pracID;
            ctrlLeaBopOnlyOrAllSpEd.value = leaBopOnlyOrAllSpEd;
            ctrlStartDate.value           = startDate;
            ctrlEndDate.value             = endDate;
            ctrlRefScreen.value           = refScreen;
        
            urlViewSvcsEnteredForPatient               = ServiceRecords.generateUrlViewSvcsEnteredForAPat(clientID,patID,"");            
            urlGetNonPromisedServicesEnteredForPatient = PatientPromisedServices.generateUrlGetNonPromised(clientID,patID,startDate,endDate); /* Possible future use */

            okToShowRecordMissingSvcs = false;
            okToShowDeferMissingSvcs  = false;

            if (!String.IsNullOrWhiteSpace(refScreen))
            {
                int refScreenVal = 0;
                int.TryParse(refScreen,out refScreenVal);
                
                if (refScreenVal == Spedmon.MissingServicesTreatmentsForAPatient.REF_PATIENTS_PROMISED_SERVICES_CDE_AUDIT_CURRENT)
                {
                  okToShowDeferMissingSvcs  = true;                
                }                
                else if (refScreenVal == Spedmon.MissingServicesTreatmentsForAPatient.REF_PATIENTS_PROMISED_SERVICES_CDE_AUDIT)
                {
                  okToShowDeferMissingSvcs  = true;                
                }
                else if (refScreenVal == Spedmon.MissingServicesTreatmentsForAPatient.REF_SCREEN_MISSING_SVCS_DETAILS)
                {
                  okToShowDeferMissingSvcs  = true;                
                }
                else if (refScreenVal == Spedmon.MissingServicesTreatmentsForAPatient.REF_SCREEN_CASELOAD_GROUP)
                { 
                  okToShowRecordMissingSvcs = true;
                  okToShowDeferMissingSvcs  = true;                
                }
                else
                {
                  okToShowRecordMissingSvcs = false;
                  okToShowDeferMissingSvcs  = false;                
                }
            }
            
            if (okToShowRecordMissingSvcs)
            {
              urlRecordMissingSvcsForPatient = MBA.HttpApplication.createLink ( 
                                                            ServiceRecords.URL_USER_ALL_SVCREC_SAVE_BATCH_MULTI_PRAC_PAT_DOS_SVC
                                                            , true
                                                            , new NameValue(Constants.PARM_APP_MODE,           Constants.AMD_UI_DBS_SUB_PAGE)
                                                            , new NameValue(Constants.PARM_CLIENT_ID,          clientID)
                                                            , new NameValue(Constants.PARM_PRACTITIONER_ID,    pracID)
                                                            , new NameValue(Constants.PARM_PATIENT_ID,         patID)
                                                            , new NameValue(Constants.PARM_SVC_TRACKING_CLASS, svcTrackingClass)
                                                            , new NameValue(Constants.PARM_SPED_SERVICE_CODE,  spEdSvcCode)
                                                            , new NameValue(Constants.PARM_START_DATE,         startDate)
                                                            , new NameValue(Constants.PARM_END_DATE,           endDate)
                                                            , new NameValue(Constants.PARM_SVCETRMDE,          Constants.SVCETEMDE_RECORD_MISSING_TMT_FOR_PAT)
                                                          );
            }

            if (okToShowDeferMissingSvcs)
            {
              var addedReasons = PatientPromisedServicesDeliveryExceptionAddedReasons.viewList(dbConnApp,log,uInfo);
            
              foreach (var addedReason in addedReasons) { 
                ctrlExceptionAddReasonPromisedService.addSelection(new NameValue(addedReason.name,addedReason.id,@""));
              }

              var removedReasons = PatientPromisedServicesDeliveryExceptionRemovedReasons.viewList(dbConnApp,log,uInfo);

              foreach (var removedReason in removedReasons) { 
                ctrlExceptionRemoveReasonPromisedService.addSelection(new NameValue(removedReason.name,removedReason.id,@""));
              }
              
            } /* ok to show defer missing svcs*/

            /* Load patient */

            pat = Patients.load(dbConnApp,log,uInfo,patID);

        } /* Page Load */
    }
}