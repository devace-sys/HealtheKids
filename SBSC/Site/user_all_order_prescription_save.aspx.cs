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
     * UserAllOrderPrescriptionSave */
    /**
     * General form for creating new and editing existing orders and 
     * prescriptions.
     ***************************************************************************/

    public class UserAllOrderPrescriptionSave : WebUI
    {
        // this is the request authorization URL
        public string requestAuthorizationURL = MBA.HttpApplication.createLink(ServiceAuthorizationRequests.URL_SAVE, true);
        public DataEntryRowFormBuilderRenderBox ctrlFormBuilderContentJSON;
        public NoteAreaBox ctrlSvcDesc;
        public string      recid;
        public string      orderOrProfileRecID;
        public bool        isProfile = false;

        public string patEditUrlBase = "";
        public string authHistTbl = "";
        public string patNameDisplay            = @"";
        public string referenceDataDisplay      = @"";
        
        public string orpDocStdNameDisplay      = @"";
        public ServiceJournalsPrescribedOrder po = new ServiceJournalsPrescribedOrder();
        public string updatedFormData          = @"""""";
        public bool   updatedFormDataAvailable = false;
        public bool   hasCarePlanAccess        = false;

        public UserAllOrderPrescriptionSave() : base(  @"user_all_order_prescription_save"
                                                     , WebUI.CreatePageSubTitle(ServiceJournals.SEL_LABEL_MANAGE_ORDERS, ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW)
                                                     , @"orders_profiles_save.css"
                                                     , @""
                                                     , Constants.ROLE_SVC_SUP_PRAC)
        { }

        protected void Page_Load(object sender, EventArgs e)
        {

            /*###########################################################################
              # Fetch parameters 
              ###########################################################################*/

            string savetype = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
            recid = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
            
            string patclientid       = MBA.HttpApplication.getParameter(Constants.PARM_PAT_CLIENT_ID);
            string patpatientid      = MBA.HttpApplication.getParameter(Constants.PARM_PAT_PAT_ID);
            string patgrpsvcclsdmeid = MBA.HttpApplication.getParameter(Constants.PARM_PAT_GRP_SVC_CLS_NME_ID);
            string patpracid         = MBA.HttpApplication.getParameter(Constants.PARM_PAT_PRAC_ID);

            /* For forward compatibility with requests that pass standard client id parm*/

            if (String.IsNullOrWhiteSpace(patclientid))
                patclientid = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

            /* For forward compatibility with requests that pass standard patient id parm*/

            if (String.IsNullOrWhiteSpace(patpatientid))
                patpatientid = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);

            /* For forward compatibility with requests that pass standard group svc class parm*/

            if (String.IsNullOrWhiteSpace(patgrpsvcclsdmeid))
                patgrpsvcclsdmeid = MBA.HttpApplication.getParameter(Constants.PARM_GRP_SVC_CLS_NME_ID);

            /* For forward compatibility with requests that pass standard prac id parm */

            if (String.IsNullOrWhiteSpace(patpracid))
                patpracid = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);

            /* For calls from pracs via the new management screen where praid is no longer passed in the request*/
           
            if (String.IsNullOrWhiteSpace(patpracid)) {
                if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID) {
                    patpracid = Spedmon.Validate.reqPracID(uInfo,"").ToString();
                }
            }

            /*###########################################################################
              # Determine save type
              ###########################################################################*/

            Object vSaveType = Spedmon.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);
            int saveType = Constants.SAVE_TYPE_NEW;
            if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
            saveType = (int)vSaveType;


            /*###########################################################################
              # Get references to data entry controls 
              ###########################################################################*/

            var ctrlSelectClient = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
            var ctrlSelectDispFamily = findControlRecu(this.Page, "selectDispFamily") as MBA.DataEntryRowSelectPractitionerDisciplineFamily;
            var ctrlSelectPatient = findControlRecu(this.Page, "selectPatient") as MBA.DataEntryRowSelectPatient;
            var ctrlSelectOrpServiceName = findControlRecu(this.Page, "selectOrpServiceName") as MBA.DataEntryRowSelectOrpServiceName;
            var ctrlEffectiveDate = findControlRecu(this.Page, "effectivedate") as MBA.DateBox;
            var ctrlSelectEndDate = findControlRecu(this.Page, "selectOrEnterEndDate") as MBA.DataEntryRow;
            var ctrlEndDate = findControlRecu(this.Page, "enddate") as MBA.DateBox;
                ctrlSvcDesc = findControlRecu(this.Page, "svcdesc") as MBA.NoteAreaBox;
            var ctrlNoteCrit1 = findControlRecu(this.Page, "notecrit1") as MBA.TextBox;
            var ctrlNoteCrit2 = findControlRecu(this.Page, "notecrit2") as MBA.TextBox;
            var ctrlNoteCrit3 = findControlRecu(this.Page, "notecrit3") as MBA.TextBox;
            var ctrlNoteCrit4 = findControlRecu(this.Page, "notecrit4") as MBA.TextBox;
            var ctrlNoteCrit5 = findControlRecu(this.Page, "notecrit5") as MBA.TextBox;
            var ctrlNoteCrit6 = findControlRecu(this.Page, "notecrit6") as MBA.TextBox;
            var ctrlNoteCrit7 = findControlRecu(this.Page, "notecrit7") as MBA.TextBox;
            var ctrlNoteCrit8 = findControlRecu(this.Page, "notecrit8") as MBA.TextBox;
            var ctrlNoteCrit9 = findControlRecu(this.Page, "notecrit9") as MBA.TextBox;
            var ctrlNoteCrit10 = findControlRecu(this.Page, "notecrit10") as MBA.TextBox;
            var ctrlSelectPracs = findControlRecu(this.Page, "pracids") as MBA.HiddenTextArea;
            var ctrlPracDetails = findControlRecu(this.Page, "details_pracs_training") as MBA.HiddenTextArea;
            var ctrlSelectORP = findControlRecu(this.Page, "selectORP") as MBA.DataEntryRowSelectORP;
            var ctrlORPAuthSvcDate = findControlRecu(this.Page, "orpauthsvcdate") as MBA.DataEntryBoxDate;
            var ctrlSelectAuthStatus = findControlRecu(this.Page, "svcauthstatusconfirmrespcode") as MBA.SelectServiceAuthorizationStatusConfirmationResponse;
            var ctrlSaveOrEdit = findControlRecu(this.Page, "saveOrEdit") as MBA.DataEntryRowSaveOrEdit;
            ctrlFormBuilderContentJSON = findControlRecu(this.Page, "formBuilderAnswersJSONForOrder") as MBA.DataEntryRowFormBuilderRenderBox;
            var ctrlformBuilderQuestionsJSON = findControlRecu(this.Page, "formBuilderQuestionsJSON") as MBA.HiddenTextArea;
            var ctrlOrpDocType = findControlRecu(this.Page, "orpdoctype") as MBA.HiddenInput;
            var ctrlAllowMultipleOrders = findControlRecu(this.Page, "allowmultipleorders") as MBA.HiddenInput;
            var ctrlOrderContextFieldName = findControlRecu(this.Page, "ordercontextfieldname") as MBA.HiddenInput;
            var ctrlFrequency        = findControlRecu(this.Page, "frequency") as MBA.ComboBox;
            var ctrlProjectedMinutes = findControlRecu(this.Page, "projectedminutes") as MBA.DataEntryBoxNumber;
            var ctrlPlanStartDate    = findControlRecu(this.Page, "planstartdate") as MBA.DataEntryBoxDate;
            var ctrlPlanEndDate      = findControlRecu(this.Page, "planenddate") as MBA.DataEntryBoxDate; 


            /* Deprecated */

            var ctrlDiagnosis = findControlRecu(this.Page, "diagnosis") as MBA.NoteAreaBox;
            var ctrlMDOrders = findControlRecu(this.Page, "mdorders") as MBA.NoteAreaBox;
            var ctrlDailyFreq = findControlRecu(this.Page, "dailyfreq") as MBA.HiddenInput;
            var ctrlSvcName = findControlRecu(this.Page, "svcname") as MBA.HiddenInput;
            var ctrlSiteAide = findControlRecu(this.Page, "siteaide") as MBA.HiddenInput;
            var ctrlBusAide = findControlRecu(this.Page, "busaide") as MBA.HiddenInput;

            /*###########################################################################
              # Get references to data entry rows we need to set entry rules for
              ###########################################################################*/

            var ctrlSelectOrEnterStartDate = findControlRecu(this.Page, "selectOrEnterStartDate") as MBA.DataEntryRow;
            var ctrlSelOrEnterEndDate = findControlRecu(this.Page, "selectOrEnterEndDate") as MBA.DataEntryRow;
            var ctrlEnterNoteCrit1 = findControlRecu(this.Page, "enterNoteCrit1") as MBA.DataEntryRow;
            var ctrlEnterNoteCrit2 = findControlRecu(this.Page, "enterNoteCrit2") as MBA.DataEntryRow;
            var ctrlEnterNoteCrit3 = findControlRecu(this.Page, "enterNoteCrit3") as MBA.DataEntryRow;
            var ctrlEnterNoteCrit4 = findControlRecu(this.Page, "enterNoteCrit4") as MBA.DataEntryRow;
            var ctrlEnterNoteCrit5 = findControlRecu(this.Page, "enterNoteCrit5") as MBA.DataEntryRow;
            var ctrlEnterNoteCrit6 = findControlRecu(this.Page, "enterNoteCrit6") as MBA.DataEntryRow;
            var ctrlEnterNoteCrit7 = findControlRecu(this.Page, "enterNoteCrit7") as MBA.DataEntryRow;
            var ctrlEnterNoteCrit8 = findControlRecu(this.Page, "enterNoteCrit8") as MBA.DataEntryRow;
            var ctrlEnterNoteCrit9 = findControlRecu(this.Page, "enterNoteCrit9") as MBA.DataEntryRow;
            var ctrlEnterNoteCrit10 = findControlRecu(this.Page, "enterNoteCrit10") as MBA.DataEntryRow;
            var ctrlEnterPracTrainingDetails = findControlRecu(this.Page, "enterPracTrainingDetails") as MBA.DataEntryRow;
            var ctrlSelectOrEnterAuthDate = findControlRecu(this.Page, "selectOrEnterAuthDate") as MBA.DataEntryRow;
            var ctrlSelectCurrAuthStatus = findControlRecu(this.Page, "selectCurrAuthStatus") as MBA.DataEntryRow;
            var ctrlEnterExpectedOutcomes = findControlRecu(this.Page, "enterExpectedOutcomes") as MBA.DataEntryRow;

            ctrlEnterExpectedOutcomes.entryInitiallyHidden = true;

            /*###########################################################################
              # Set save type and rec id
              ###########################################################################*/

            ctrlSaveOrEdit.saveType = saveType;
            //ctrlSaveOrEdit.recID = recid;

             /*###########################################################################
               # Get references to various links and set base urls
               ###########################################################################*/

              var ctrlLinkManageCarePlans = findControlRecu(this.Page, "gotomanagecareplans") as MBA.LinkInternal;
              ctrlLinkManageCarePlans.url = PlanWriterPlans.URL_USER_ALL_MANAGE_PLANS;
              patEditUrlBase = Patients.URL_USER_ALL_EDIT_EXISTING_BASE(true,"");

            /*###########################################################################
              # Set other fields for creating new records
              ###########################################################################*/

            if (saveType == Constants.SAVE_TYPE_NEW)
            {

                /*------------------------------------*/
                /*  If client id is passed then       */
                /*  preset select client              */
                /*------------------------------------*/

                if (!String.IsNullOrWhiteSpace(patclientid))
                {
                    Client c = Clients.load(dbConnApp, log, uInfo, patclientid);
                    ctrlSelectClient.selectValue = c.id.ToString();
                    ctrlSelectClient.selectName = c.name;
                }

                /*------------------------------------*/
                /*  If patient id is passed then      */
                /*  preset select patient and         */
                /*  preset client overriding any      */
                /*  previous preset                   */
                /*------------------------------------*/

                if (!String.IsNullOrWhiteSpace(patpatientid))
                {
                    Patient p = Patients.load(dbConnApp, log, uInfo, patpatientid);
                    ctrlSelectClient.selectValue = p.clientID.ToString();
                    ctrlSelectClient.selectName = p.clientName.ToString();
                    ctrlSelectPatient.selectValue = p.id.ToString();
                    ctrlSelectPatient.selectName = p.name;
                }

                /*------------------------------------*/
                /*  If group service class is passed  */
                /*  then preset select group service  */
                /*  class                             */
                /*------------------------------------*/

                if (!String.IsNullOrWhiteSpace(patgrpsvcclsdmeid))
                {
                    GroupsServiceClass gsc = GroupsServiceClasses.load(dbConnApp, log, uInfo, "5", patgrpsvcclsdmeid);
                    ctrlSelectDispFamily.selectValue = gsc.id.ToString();
                    ctrlSelectDispFamily.selectName = gsc.name;
                }

                /*------------------------------------*/
                /*  If rendering practitioner is      */
                /*  passed then reset select group    */
                /*  service class                     */
                /*------------------------------------*/

                if (!Util.IsNullOrEmpty(patpracid))
                {
                    Practitioner prp = Practitioners.load(dbConnApp, log, uInfo, patpracid);
                    ctrlSelectDispFamily.selectValue = prp.orpGroupServiceClassNameID.ToString();
                    ctrlSelectDispFamily.selectName = prp.orpGroupServiceClassName;
                }

                /*------------------------------------*/
                /*  Default plan start date           */
                /*  to beginning of fiscal year       */
                /*------------------------------------*/

                ctrlEffectiveDate.value = Constants.DEFAULT_EARLIEST_DOS; //Util.generateStartOfCurrentFiscalYearDefaultValue();

                /*------------------------------------*/
                /*  Hide svc description box          */
                /*------------------------------------*/

                ctrlSvcDesc.hidden = true;
            }

            /*###########################################################################
              # Set other fields for editing existing records
              ###########################################################################*/

            else if (saveType == Constants.SAVE_TYPE_EDIT)
            {

                this.subTitle = WebUI.CreatePageSubTitle(ServiceJournals.SEL_LABEL_MANAGE_ORDERS
                                                         , ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT);

                /*------------------------------------*/
                /*  Load previously saved record      */
                /*------------------------------------*/

                po = ORPDocuments.loadOrderOrProfileFromORPDoc(dbConnApp, log, uInfo, patclientid, recid);

                orderOrProfileRecID = po.refID.ToString();
                ctrlSaveOrEdit.recID = orderOrProfileRecID;
                ctrlOrpDocType.value = po.orpDocType.ToString();
                orpDocStdNameDisplay = String.Format(@"Service : {0}", po.orpDocStdName);
                referenceDataDisplay = String.Format(@"OrpDocID: {0} ", po.id);


                if (po.orpDocType == 3)
                {
                    isProfile = true;
                }

                /*------------------------------------*/
                /*  Load last auth given info         */
                /*------------------------------------*/

                ctrlSelectOrEnterAuthDate.additionalInformation = "";//ORPDocuments.generateLastAuthorizedInfoHtmlString(po.displayLastApproval, po.lastApprovalOrpName, po.lastApprovalOrpTitle, po.lastApprovalOrpNPI, po.lastApprovalEffectiveDateStr);

                /*------------------------------------*/
                /*  Load values into controls         */
                /*------------------------------------*/

                ctrlSelectClient.selectValue = po.clientID.ToString();
                ctrlSelectClient.selectName = po.clientName;

                ctrlSelectPatient.selectValue = po.patID.ToString();
                ctrlSelectPatient.selectName = po.patName;

                ctrlSelectDispFamily.selectValue = po.groupServiceClassNameID.ToString();
                ctrlSelectDispFamily.selectName = po.groupServiceClassNameName;                

                ctrlSelectOrpServiceName.selectValue = po.orpDocStdNameID.ToString();
                ctrlSelectOrpServiceName.selectName = po.orpDocStdName;
                ctrlSelectOrpServiceName.entryAllowed = false;
                ctrlSelectOrpServiceName.entryNotAllowedUseReplacementValue = false;

                ctrlDiagnosis.value = po.diagnosis;
                ctrlMDOrders.value  = po.mdOrders;


                ctrlEffectiveDate.value = po.effectiveDateStr;
                ctrlEndDate.value       = po.endDateStr;
                ctrlSvcDesc.value       = po.svcDesc;
                ctrlNoteCrit1.value     = po.noteCrit1;
                ctrlNoteCrit2.value     = po.noteCrit2;
                ctrlNoteCrit3.value     = po.noteCrit3;
                ctrlNoteCrit4.value     = po.noteCrit4;
                ctrlNoteCrit5.value     = po.noteCrit5;
                ctrlNoteCrit6.value     = po.noteCrit6;
                ctrlNoteCrit7.value     = po.noteCrit7;
                ctrlNoteCrit8.value     = po.noteCrit8;
                ctrlNoteCrit9.value     = po.noteCrit9;
                ctrlNoteCrit10.value    = po.noteCrit10;

                /*-------------------------------
                 * Multi order fields
                 *------------------------------*/

                ctrlAllowMultipleOrders.value = po.allowMultipleOrders.ToString().ToLower();
                ctrlOrderContextFieldName.value = po.orderContextFieldName;

                /*-------------------------------
                 * Form Builder Data JSON
                 *------------------------------*/

                ctrlFormBuilderContentJSON.formBuilderQuestionsJSON = po.formBuilderQuestionsJSON;
                ctrlFormBuilderContentJSON.value = po.formBuilderAnswersJSON;

                ctrlformBuilderQuestionsJSON.value = po.formBuilderQuestionsJSON;

                /*---------------------------------------------
                 * Hide service description (if form exists)
                 *--------------------------------------------*/

                if (!String.IsNullOrEmpty(po.formBuilderQuestionsJSON) && po.formBuilderQuestionsJSON != "[]") {
                    ctrlSvcDesc.hidden = true;

                    /*-----------------------------------------------*/
                    /* Fetch New Form Data based on ORP Std Sel Name */
                    /*-----------------------------------------------*/

                    updatedFormData = ORPDocumentsStandardSelectionNames.load(this.dbConnApp, this.log, this.uInfo, po.orpDocStdNameID.ToString()).formBuilderContentJSON;

                    updatedFormDataAvailable = (updatedFormData != po.formBuilderQuestionsJSON);
                }

                // if no form preloaded, check for forms related to service
                else
                {
                    // load service data
                    ORPDocumentStandardSelectionName ssn = ORPDocumentsStandardSelectionNames.load(dbConnApp, log, uInfo, po.orpDocStdNameID.ToString());

                    // get the form data for the service
                    if (!String.IsNullOrEmpty(ssn.formBuilderContentJSON) && ssn.formBuilderContentJSON != "[]")
                    {
                        ctrlFormBuilderContentJSON.formBuilderQuestionsJSON = ssn.formBuilderContentJSON;
                        ctrlFormBuilderContentJSON.value = "";
                    }

                }

                if (!String.IsNullOrEmpty(po.orderProfilePracIDsStr))
                {

                    /* Selections */

                    ctrlSelectPracs.value = po.orderProfilePracIDsStr;

                    /* Details data */

                    ctrlPracDetails.value = po.detailsTrainingPracsJSON;

                }

                ctrlSelectORP.selectValue = po.orpPracID.ToString();
                ctrlSelectORP.selectName = po.orpPracName;

                // populate plan type extra fields

                if (po.frequency.HasValue)        { 
                    ctrlFrequency.value = po.frequency.Value.ToString();
                    ctrlFrequency.selectName = po.frequencyName;  
                }
                
                if (po.projectedMinutes.HasValue) { ctrlProjectedMinutes.value = po.projectedMinutes.Value;  }
                if (po.planStartDate.HasValue)    { ctrlPlanStartDate.value    = po.planStartDate.Value;     }
                if (po.planEndDate.HasValue)      { ctrlPlanEndDate.value      = po.planEndDate.Value; }

                /* Deprecated or future use */

                ctrlDailyFreq.value = po.dailyFreq.HasValue ? po.dailyFreq.Value.ToString() : "";
                ctrlSvcName.value   = po.svcName;
                ctrlSiteAide.value  = po.siteAideYN;
                ctrlBusAide.value   = po.busAideYN;


                /*------------------------------------*/
                /* Get authorization history data     */
                /*------------------------------------*/

                ReturnDataTable authHist = SvcAuthStatsHists.viewTbl(dbConnApp, log, uInfo, po.clientID.ToString(), po.id.ToString());

                authHist.tableFooter = "";
                authHist.tableName = "Authorization History";

                authHistTbl = ReturnDataTable.createHTMLTable(ref authHist);


                /*------------------------------------*/
                /* Get modifications history data     */
                /*------------------------------------*/

                ReturnDataTable auditTbl = (isProfile) ?
                                            ServiceJournalsServiceDescriptions.viewTblModHist(dbConnApp, log, uInfo, null, orderOrProfileRecID) :
                                            ServiceJournalsPrescribedOrders.viewTblModHist(dbConnApp, log, uInfo, null, orderOrProfileRecID);


                auditTbl.tableFooter = "";
                auditTbl.tableName = "Modification History";

                ctrlSaveOrEdit.showAuditHistory = true;
                ctrlSaveOrEdit.auditHistoryHTML = (auditTbl.iTotalDisplayRecords > 0) ? ReturnDataTable.createHTMLTable(ref auditTbl) :
                                                                                        "<span>No audit records were found</span>";               


            }

            /*###########################################################################
             # Create entry allowed delegates 
             # NOTE: This function was changed to return false for everybody. If requirements change
             # resurrect this code as needed. The original function name was delgPCALOnly
             ###########################################################################*/

            DelegateUserSpecificAction retFalse = delegate (ref RequestResponse rd)
            {
                /*------------------------------------*/
                /*  Only PCAL users should see this   */
                /*------------------------------------*/

                //if (rd.wu.usr.userGroupID == Constants.USER_GROUP_SBSC) return true;
                return false;
            };



            DelegateUserSpecificAction delgGroupFamilyIsHealthServices = delegate (ref RequestResponse rd)
            {
                /*------------------------------------*/
                /*  Only if health services is        */
                /*  the group family                  */
                /*------------------------------------*/

                /* A value has been either preset or loaded */

                if (ctrlSelectDispFamily.hasValueOrValues())
                {
                    /* If its for health service we want to allow entry */

                    if (ctrlSelectDispFamily.selectValue == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES.ToString())
                    {
                        return true;
                    }

                    /* Otherwise don't allow entry */

                    return false;
                }

                /* No value exists */

                else
                {
                    /* PCAL Staff can select a group family value under certain conditions so we want to allow it */

                    if (rd.wu.usr.userGroupID == Constants.USER_GROUP_SBSC)
                    {
                        return true;
                    }

                    /* Same goes for cetain client users */

                    else if (rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT)
                    {

                        /* Specifically LEA coordinators and input staff */

                        if ((rd.wu.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID) || (rd.wu.usr.roleID == Constants.ROLE_LEA_INPUT_STAFF_ID))
                        {
                            return true;
                        }

                        /* Practioners SHOULD have already been handled because their group family should be preselected 
                           but just in case */

                        if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID)
                        {
                            /* Health services */
                            if (rd.wu.pr.orpGroupServiceClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES)
                            {
                                return true;
                            }
                            /* Other group familes NO */
                            return false;
                        }

                        /* Other client roles NO */
                        return false;
                    }
                }
                /* Should never get here */
                return true;
            };

            /*###########################################################################
              # Set entry rules for controls
              ###########################################################################*/
            
            hasCarePlanAccess = (uInfo.userClientID == 0) ? true : Spedmon.PlanWriterRecords.clientHasAccess(this.dbConnApp, this.log, this.uInfo, uInfo.userClientIDStr);

            /*------------------------------------*/
            /*  If a client is already provided   */
            /*  then override entry rule defaults */
            /*------------------------------------*/

            if (ctrlSelectClient.hasValueOrValues())
            {
                ctrlSelectClient.entryAllowed = false;
                ctrlSelectClient.entryNotAllowedUseReplacementValue = false;
            }

            /*------------------------------------*/
            /*  If a patient is already provided  */
            /*  then override entry rule defaults */
            /*------------------------------------*/

            if (ctrlSelectPatient.hasValueOrValues())
            {
                ctrlSelectPatient.entryAllowed = false;
                ctrlSelectPatient.entryNotAllowedUseReplacementValue = false;

                // we still want the patient name to be displayed
                patNameDisplay = "Patient: " + ctrlSelectPatient.selectName;
            }

            /*------------------------------------*/
            /*  If a disp is already provided     */
            /*  then override entry rule defaults */
            /*------------------------------------*/

            if (ctrlSelectDispFamily.hasValueOrValues())
            {
                ctrlSelectDispFamily.entryAllowed = false;
                ctrlSelectDispFamily.entryNotAllowedUseReplacementValue = false;

                //ctrlSelectOrpServiceName.entryInitiallyHidden = false;
                ctrlSelectORP.entryInitiallyHidden = false;
            }
            else
            {

                //ctrlSelectOrpServiceName.entryInitiallyHidden = true;
                ctrlSelectORP.entryInitiallyHidden = true;
            }

            /*------------------------------------*/
            /*  Dont allow select service unless  */
            /*  patient and group family are      */
            /*  selected                          */
            /*------------------------------------*/

            if ((ctrlSelectDispFamily.hasValueOrValues()) && (ctrlSelectPatient.hasValueOrValues()))
            {
                ctrlSelectOrpServiceName.entryInitiallyHidden = false;
            }
            else
            {
                ctrlSelectOrpServiceName.entryInitiallyHidden = true;
            }

            /*------------------------------------*/
            /*  Provide delegate for start and    */
            /*  end date to determine entry rules */
            /*-----------------------------------*/

            ctrlSelectOrEnterStartDate.entryAllowedFn = retFalse;
            ctrlSelOrEnterEndDate.entryAllowedFn = retFalse;

            /*------------------------------------*/
            /*  Provide delegates for note crit  */
            /*  to determine entry rules         */
            /*-----------------------------------*/

            var initiallyHideHsSpecificRows = true;

            if (ctrlSelectDispFamily.hasValueOrValues())
            {
                if (ctrlSelectDispFamily.selectValue != Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES.ToString())
                {
                    initiallyHideHsSpecificRows = true;
                }
                else
                {
                    initiallyHideHsSpecificRows = false;
                }
            }

            ctrlEnterNoteCrit1.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterNoteCrit1.entryInitiallyHidden = initiallyHideHsSpecificRows;

            ctrlEnterNoteCrit2.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterNoteCrit2.entryInitiallyHidden = initiallyHideHsSpecificRows;

            ctrlEnterNoteCrit3.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterNoteCrit3.entryInitiallyHidden = initiallyHideHsSpecificRows;

            ctrlEnterNoteCrit4.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterNoteCrit4.entryInitiallyHidden = initiallyHideHsSpecificRows;

            ctrlEnterNoteCrit5.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterNoteCrit5.entryInitiallyHidden = initiallyHideHsSpecificRows;

            ctrlEnterNoteCrit6.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterNoteCrit6.entryInitiallyHidden = initiallyHideHsSpecificRows;

            ctrlEnterNoteCrit7.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterNoteCrit7.entryInitiallyHidden = initiallyHideHsSpecificRows;

            ctrlEnterNoteCrit8.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterNoteCrit8.entryInitiallyHidden = initiallyHideHsSpecificRows;

            ctrlEnterNoteCrit9.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterNoteCrit9.entryInitiallyHidden = initiallyHideHsSpecificRows;

            ctrlEnterNoteCrit10.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterNoteCrit10.entryInitiallyHidden = initiallyHideHsSpecificRows;

            /*-----------------------------------*/
            /*  Provide delegates for rendering  */
            /*  pracs and override entry rule    */
            /*  defaults                         */
            /*-----------------------------------*/

            ctrlEnterPracTrainingDetails.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterPracTrainingDetails.entryNotAllowedUseReplacementValue = false;
            ctrlEnterPracTrainingDetails.entryInitiallyHidden = initiallyHideHsSpecificRows;

            ctrlEnterPracTrainingDetails.entryAllowedFn = delgGroupFamilyIsHealthServices;
            ctrlEnterPracTrainingDetails.entryInitiallyHidden = initiallyHideHsSpecificRows;


            var initiallyHideOrpAuthRows = true;
            if (ctrlSelectORP.hasValueOrValues() == true)
            {
                initiallyHideOrpAuthRows = false;
            }

            ctrlSelectOrEnterAuthDate.entryInitiallyHidden = initiallyHideOrpAuthRows;
            ctrlSelectCurrAuthStatus.entryInitiallyHidden = initiallyHideOrpAuthRows;

            /***************************************************************
             * Hide rows that are not required for profile
             * *************************************************************/
            if (isProfile)
            {
                ctrlSelectDispFamily.entryInitiallyHidden = true;
                ctrlEnterNoteCrit1.entryInitiallyHidden = ctrlEnterNoteCrit2.entryInitiallyHidden = ctrlEnterNoteCrit3.entryInitiallyHidden = ctrlEnterNoteCrit4.entryInitiallyHidden = ctrlEnterNoteCrit5.entryInitiallyHidden = ctrlEnterNoteCrit6.entryInitiallyHidden = ctrlEnterNoteCrit7.entryInitiallyHidden = ctrlEnterNoteCrit8.entryInitiallyHidden = ctrlEnterNoteCrit9.entryInitiallyHidden = ctrlEnterNoteCrit10.entryInitiallyHidden = true;
                ctrlSelectEndDate.entryInitiallyHidden = true;
            }


        }
    }
}