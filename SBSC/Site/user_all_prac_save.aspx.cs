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
     * PractitionerSave */
    /**
     * Saves a practitioner
     ***************************************************************************/

    public class UserAllPractitionerSave : WebUI
    {
        public int saveType = 0;
        public string showContentOnly;
        public string userIsProvider = Util.netBoolToJSBool(false);
        public string pracSaveURL;
        public string pracEarliestLatestServiceDatesSummary = "";
        public bool showPractitionerEmploymentRelationships = false;
        public string practitionerEmploymentRelationshipUrlView = "";
        public string practitionerEmploymentRelationshipUrlSave = "";
        public string practitionerEmploymentRelationshipUrlDelete = "";
        public string practitionerEmploymentRelationshipClientID = "";
        public string practitionerEmploymentRelationshipPracID = "";
        public string tabToOpen = "";
        public UserAllPractitionerSave() : base("practitioner_save", "Practitioners - New", "user_all_prac_save.css", "user_all_prac_save.js|rec_prac_qualifications.js|practitioner-sites.js", Constants.ROLE_SVC_SUP_PRAC) { }

        protected void Page_Load(object sender, EventArgs e)
        {

            /*###########################################################################
              # Get parameters
              ###########################################################################*/

            string recid = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
            string savetype = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
            string clientID = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

            /*###########################################################################
              # Check over save type
              ###########################################################################*/

            Object vSaveType = MBA.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);
            if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
            saveType = (int)vSaveType;

            /*###########################################################################
              # Find controls
              ###########################################################################*/

            DataEntryRowSaveOrEdit ctrlSaveOrEdit = findControlRecu(this.Page, "saveOrEdit") as DataEntryRowSaveOrEdit;
            MBA.ComboBox ctrlClientID = findControlRecu(this.Page, "clientid") as MBA.ComboBox;
            var ctrllname = findControlRecu(this.Page, "lname") as MBA.DataEntryBoxText;
            var ctrlfname = findControlRecu(this.Page, "fname") as MBA.DataEntryBoxText;
            MBA.ComboBox ctrlGrpDispID = findControlRecu(this.Page, "groupdisp") as MBA.ComboBox;
            MBA.FieldSetEmploymentRelationship ctrlEmploymentRel = findControlRecu(this.Page, "prac_emp_rel") as MBA.FieldSetEmploymentRelationship;
            var ctrlStartDateCPR = findControlRecu(this.Page, "cprCertEffectiveDate") as DateBoxHTML5;
            var ctrlEndDateCPR = findControlRecu(this.Page, "cprCertExpirationDate") as DateBoxHTML5;
            var ctrlEmail = findControlRecu(this.Page, "email") as MBA.DataEntryBoxEmail;
            var ctrlPhone = findControlRecu(this.Page, "phone") as MBA.DataEntryBoxPhone;
            var ctrlFax = findControlRecu(this.Page, "fax") as MBA.DataEntryBoxPhone;
            MBA.FieldSetUSPSAddress ctrlAddress = findControlRecu(this.Page, "prac_prof_address") as MBA.FieldSetUSPSAddress;
            MBA.FieldSetNPI ctrlNPI = findControlRecu(this.Page, "prac_npi") as MBA.FieldSetNPI;
            SelectYesOrNoOrUnknown ctrlIsValidMcalORP = findControlRecu(this.Page, "is_valid_mcal_orp") as SelectYesOrNoOrUnknown;
            DateBoxHTML5 ctrlValidMcalORPEffectiveDate = findControlRecu(this.Page, "is_valid_mcal_orp_last_validated") as DateBoxHTML5;
            MBA.ComboBox ctrlGrpReptID = findControlRecu(this.Page, "grouprept") as MBA.ComboBox;
            SelectYesOrNo ctrlIncInFinRepts = findControlRecu(this.Page, "inc_in_fin_repts") as SelectYesOrNo;

            SelectYesOrNo ctrlParticipatesinleabop = findControlRecu(this.Page, "participatesinleabop") as SelectYesOrNo;
            SelectYesOrNo ctrlParticipatesinleabopNonSpEd = findControlRecu(this.Page, "participatesinleabopnonsped") as SelectYesOrNo;
            SelectYesOrNo ctrlParticipatesincyhbi = findControlRecu(this.Page, "participatesincyhbi") as SelectYesOrNo;
            SelectYesOrNo ctrlParticipatesInRuHealth = findControlRecu(this.Page, "participatesinruhealth") as SelectYesOrNo;


            SelectYesOrNo ctrlSubmitClaims = findControlRecu(this.Page, "submitclaims") as SelectYesOrNo;
            DateBoxHTML5 ctrlSubmitClaimsEffectiveDate = findControlRecu(this.Page, "submitClaimsEffectiveDate") as DateBoxHTML5;
            SelectYesOrNoOrUnknown ctrlClaimTCM = findControlRecu(this.Page, "claim_TCM") as SelectYesOrNoOrUnknown;
            DateBoxHTML5 ctrlClaimTCMEffectiveDate = findControlRecu(this.Page, "claim_TCMEffectiveDate") as DateBoxHTML5;
            SelectYesOrNo ctrlCybhiTpaApproved = findControlRecu(this.Page, "cybhitpaapproved") as SelectYesOrNo;
            DataEntryBoxDate ctrlCybhiTpaApprovedOn = findControlRecu(this.Page, "cybhitpaapprovedon") as DataEntryBoxDate;
            DataEntryBoxText ctrlCybhiTpaID = findControlRecu(this.Page, "cybhitpaid") as DataEntryBoxText;
            SelectYesOrNo ctrlCybhiSubmitClaims = findControlRecu(this.Page, "cybhisubmitclaims") as SelectYesOrNo;

            MBA.TextAreaBox ctrlNotes = findControlRecu(this.Page, "notes") as MBA.TextAreaBox;

            var ctrlQualificationsJSONData = findControlRecu(this.Page, "qualificationsJSONData") as MBA.HiddenTextArea;
            var ctrlDisplaypercent = findControlRecu(this.Page, "displaypercent") as SelectYesOrNo;
            var ctrlDisplaymoney = findControlRecu(this.Page, "displaymoney") as SelectYesOrNo;
            var ctrlACESCertCompletedOn = findControlRecu(this.Page, "acescertcompletedon") as MBA.DataEntryBoxDate;

            var ctrlDeptHead = findControlRecu(this.Page, "deptHead") as SelectYesOrNo;

            var ctrlCurrentlyWithClient = findControlRecu(this.Page, "currentlyWithClient") as SelectYesOrNo;

            var ctrlDeptHeadCSEPIDRR = findControlRecu(this.Page, "deptheadcanseeentirepracticefamilyindeptreviewreports") as SelectYesOrNo;

            var ctrlDOB = findControlRecu(this.Page, "dob") as DataEntryBoxDate;
            var ctrlGender = findControlRecu(this.Page, "gender") as SelectMaleOrFemale;
            var ctrlSSN = findControlRecu(this.Page, "ssn") as DataEntryBoxText;
            var ctrlCybhiDegreeCode = findControlRecu(this.Page, "cybhidegreecode") as DataEntryBoxSelect;
            var ctrlCybhiDegreeCode2 = findControlRecu(this.Page, "cybhidegreecode2") as DataEntryBoxSelect;
            var ctrlCybhiDegreeCode3 = findControlRecu(this.Page, "cybhidegreecode3") as DataEntryBoxSelect;

            var ctrlCybhiSpecialityCode = findControlRecu(this.Page, "cybhispecialtycode") as DataEntryBoxSelect;
            var ctrlCybhiSpecialityCode2 = findControlRecu(this.Page, "cybhispecialtycode2") as DataEntryBoxSelect;
            var ctrlCybhiSpecialityCode3 = findControlRecu(this.Page, "cybhispecialtycode3") as DataEntryBoxSelect;
            var ctrlCybhiSpecialityCode4 = findControlRecu(this.Page, "cybhispecialtycode4") as DataEntryBoxSelect;

            /*-------------------------------
             * Grab client and provider specific fields
             *------------------------------*/

            DataEntryRow ctrlClientidDataEntryRow = findControlRecu(this.Page, "clientidDataEntryRow") as DataEntryRow;
            DataEntryRow ctrlPrac_emp_relDataEntryRow = findControlRecu(this.Page, "prac_emp_relDataEntryRow") as DataEntryRow;
            DataEntryRow ctrlGroupreptDataEntryRow = findControlRecu(this.Page, "groupreptDataEntryRow") as DataEntryRow;
            DataEntryRow ctrlInc_in_fin_reptsDataEntryRow = findControlRecu(this.Page, "inc_in_fin_reptsDataEntryRow") as DataEntryRow;
            DataEntryRow ctrlSubmitclaimsDataEntryRow = findControlRecu(this.Page, "submitclaimsDataEntryRow") as DataEntryRow;
            DataEntryRow ctrlClaim_TCMDataEntryRow = findControlRecu(this.Page, "claim_TCMDataEntryRow") as DataEntryRow;
            var ctrlDeptHeadDataEntryRow = findControlRecu(this.Page, "deptHeadDataEntryRow") as DataEntryRow;
            var ctrlPrac_emp_relPrevDataEntryRow = findControlRecu(this.Page, "prac_emp_rel_prev_DataEntryRow") as DataEntryRow;


            var ctrlPracID = findControlRecu(this.Page, Constants.PARM_PRACTITIONER_ID) as MBA.HiddenInput;

            /*-------------------------------
             * Hide specific fields
             * based on user role
             *------------------------------*/

            if (((IList)Constants.ROLE_CLIENT_BO).Contains(uInfo.userRole.ToLower()))
            {
                ctrlClientidDataEntryRow.entryAllowed = false;
                ctrlClientidDataEntryRow.entryNotAllowedUseReplacementValue = false;

                /*-------------------------------
                 * Set values for hidden fields
                 * that are required for saving
                 *------------------------------*/

                ctrlClientID.value = Spedmon.Validate.optClientID(uInfo, @"").ToString();
            }

            else if (uInfo.userRole.ToLower() == Constants.ROLE_LEA_PROVIDER)
            {
                userIsProvider = Util.netBoolToJSBool(true);

                ctrlClientidDataEntryRow.entryAllowed = false;
                ctrlClientidDataEntryRow.entryNotAllowedUseReplacementValue = false;

                ctrlPrac_emp_relDataEntryRow.entryAllowed = false;
                ctrlPrac_emp_relDataEntryRow.entryNotAllowedUseReplacementValue = false;

                ctrlGroupreptDataEntryRow.entryAllowed = false;
                ctrlGroupreptDataEntryRow.entryNotAllowedUseReplacementValue = false;

                ctrlInc_in_fin_reptsDataEntryRow.entryAllowed = false;
                ctrlInc_in_fin_reptsDataEntryRow.entryNotAllowedUseReplacementValue = false;

                ctrlSubmitclaimsDataEntryRow.entryAllowed = false;
                ctrlSubmitclaimsDataEntryRow.entryNotAllowedUseReplacementValue = false;

                ctrlClaim_TCMDataEntryRow.entryAllowed = false;
                ctrlClaim_TCMDataEntryRow.entryNotAllowedUseReplacementValue = false;

                ctrlNotes.hidden = true;

                /*-------------------------------
                 * Set values for hidden fields
                 * that are required for saving
                 *------------------------------*/

                ctrlClientID.value = Spedmon.Validate.optClientID(uInfo, @"").ToString();
            }

            if (!((IList)Constants.ROLE_SBS_ALL_LEA_COORD).Contains(uInfo.userRole.ToLower()))
            {
                ctrlDeptHeadDataEntryRow.entryAllowed = false;
                ctrlDeptHeadDataEntryRow.entryNotAllowedUseReplacementValue = false;
            }


            /*###########################################################################
              # Populate CYBHI Provider Degree selections
              ###########################################################################*/

            var cybhiProviderDegrees = CYBHIProviderDegrees.viewList(dbConnApp, log, uInfo);
            foreach (var cybhiProviderDegree in cybhiProviderDegrees)
            {
                ctrlCybhiDegreeCode.addSelection(new NameValue(cybhiProviderDegree.name, cybhiProviderDegree.codeValue, ""));

                ctrlCybhiDegreeCode2.addSelection(new NameValue(cybhiProviderDegree.name, cybhiProviderDegree.codeValue, ""));

                ctrlCybhiDegreeCode3.addSelection(new NameValue(cybhiProviderDegree.name, cybhiProviderDegree.codeValue, ""));
            }

            /*###########################################################################
              # Populate CYBHI Provider Specialty selections
              ###########################################################################*/

            var cybhiProviderSpecialties = CYBHIProviderSpecialties.viewList(dbConnApp, log, uInfo);
            foreach (var cybhiProviderSpecialty in cybhiProviderSpecialties)
            {
                ctrlCybhiSpecialityCode.addSelection(new NameValue(cybhiProviderSpecialty.name, cybhiProviderSpecialty.codeValue, ""));

                ctrlCybhiSpecialityCode2.addSelection(new NameValue(cybhiProviderSpecialty.name, cybhiProviderSpecialty.codeValue, ""));

                ctrlCybhiSpecialityCode3.addSelection(new NameValue(cybhiProviderSpecialty.name, cybhiProviderSpecialty.codeValue, ""));

                ctrlCybhiSpecialityCode4.addSelection(new NameValue(cybhiProviderSpecialty.name, cybhiProviderSpecialty.codeValue, ""));
            }

            /*###########################################################################
              #                                EDIT
              # Load record, set control values, step labels, first step, and page title
              ###########################################################################*/

            if (saveType == Constants.SAVE_TYPE_EDIT)
            {
                /*============================================================
                 * Get tab to open (only applies to edits)
                 *============================================================*/

                tabToOpen = MBA.HttpApplication.getParameter(Constants.PARM_TAB_TO_OPEN);

                /*if (!String.IsNullOrWhiteSpace(tabToOpen)) {   
                   this.animateCloseIcon = true;
                }*/

                /*============================================================
                 * Load record and exit if not found
                 *============================================================*/

                Practitioner p = Practitioners.load(dbConnApp, log, uInfo, recid);

                /*============================================================
                 * Set earliest latest dos summary
                 *============================================================*/

                pracEarliestLatestServiceDatesSummary = "Earliest Date of Service : "
                                                      + p.earliestServiceDate
                                                      + " | "
                                                      + "Latest Date of Service : "
                                                      + p.latestServiceDate;

                /*============================================================
                 * Set view, save, and delete urls and additional parm values
                 * for employement relationship restview.
                 *============================================================*/

                /* Only pcal staff is allowed to manage these and only if its an edit */
                ctrlPrac_emp_relPrevDataEntryRow.entryInitiallyHidden = true;
                showPractitionerEmploymentRelationships = false;

                if (rd.wu.usr.pcalStaff == true)
                {
                    showPractitionerEmploymentRelationships = true;
                    ctrlPrac_emp_relPrevDataEntryRow.entryInitiallyHidden = false;
                }

                practitionerEmploymentRelationshipClientID = p.clientID.ToString();
                practitionerEmploymentRelationshipPracID = p.id.ToString();

                ctrlPracID.value = practitionerEmploymentRelationshipPracID;

                practitionerEmploymentRelationshipUrlView = PractitionerEmploymentRelationships.URL_REST_VIEW();
                practitionerEmploymentRelationshipUrlSave = PractitionerEmploymentRelationships.URL_SAVE_INLINE();
                practitionerEmploymentRelationshipUrlDelete = PractitionerEmploymentRelationships.URL_DELETE_INLINE();

                /*============================================================
                 * Set control values and step labels
                 *============================================================*/

                ctrlSaveOrEdit.saveType = saveType;
                ctrlSaveOrEdit.recID = p.id.ToString();

                /*-------------------------------
                 * ClientID
                 *------------------------------*/

                ctrlClientID.value = p.clientID.ToString();
                ctrlClientID.selectName = p.clientName;

                /*-------------------------------
                 * Name
                 *------------------------------*/

                ctrllname.value = p.lastName;
                ctrlfname.value = p.firstName;

                /*-------------------------------
                 * Allied disp groupID
                 *------------------------------*/

                ctrlGrpDispID.value = p.groupID.ToString();
                ctrlGrpDispID.selectName = p.groupName;

                /*-------------------------------
                 * Employment relationship
                 *------------------------------*/

                ctrlEmploymentRel.parmValueEmployeeId = p.clientEmployeeID;
                ctrlEmploymentRel.parmValueRelationship = p.employeeRelationshipID.ToString();
                ctrlEmploymentRel.parmValueStartDate = Util.dateTimeToShortDate(p.startDate);
                ctrlEmploymentRel.parmValueEndDate = Util.dateTimeToShortDate(p.endDate);

                /*-------------------------------
                 * CPR
                 *------------------------------*/

                ctrlStartDateCPR.value = (p.cprCertEffectiveDate == DateTime.MinValue) ?
                                                    "" : p.cprCertEffectiveDate.ToString("yyyy-MM-dd");
                ctrlEndDateCPR.value = (p.cprCertExpirationDate == DateTime.MinValue) ?
                                                    "" : p.cprCertExpirationDate.ToString("yyyy-MM-dd");

                /*-------------------------------
                 * Email
                 *------------------------------*/

                ctrlEmail.value = p.email;

                /*-------------------------------
                 * Phone
                 *------------------------------*/

                ctrlPhone.value = p.phone;

                /*-------------------------------
                 * Fax
                 *------------------------------*/

                ctrlFax.value = p.fax;

                /*-------------------------------
                 * Professional address
                 *------------------------------*/

                ctrlAddress.parmValueStreet1 = p.street1;
                ctrlAddress.parmValueStreet2 = p.street2;
                ctrlAddress.parmValueCity = p.city;
                ctrlAddress.parmValueState = p.state;
                ctrlAddress.parmValueZip5 = p.zip5;
                ctrlAddress.parmValueZip4 = p.zip4;

                /*-------------------------------
                 * NPI#
                 *------------------------------*/

                ctrlNPI.numParmValue = p.npiNumber;

                /*-------------------------------
                 * ORP Validation
                 *------------------------------*/

                ctrlIsValidMcalORP.value = Util.boolToYesNoUnknown(p.isValidMcalOrp);
                ctrlValidMcalORPEffectiveDate.value = (p.isValidMcalOrpLastValidated == DateTime.MinValue) ?
                                                    "" : p.isValidMcalOrpLastValidated.ToString("yyyy-MM-dd");

                /*-------------------------------
                 * Reporting group
                 *------------------------------*/

                ctrlGrpReptID.value = (p.groupIDRept == 0) ? "" : p.groupIDRept.ToString();  // Handles case of 0
                ctrlGrpReptID.selectName = p.groupNameRept;

                /*-------------------------------
                 * Include in financial reports
                 *------------------------------*/

                ctrlIncInFinRepts.value = Util.boolToYesNo(p.includeInFinRepts);

                /*-------------------------------
                 * Submit claims
                 *------------------------------*/

                ctrlParticipatesinleabop.value = Util.boolToYesNoUnknown(p.participatesInLEABOP);
                ctrlParticipatesinleabopNonSpEd.setValue(p.participatesInLEABOPNonSpEd);
                ctrlParticipatesincyhbi.value = Util.boolToYesNoUnknown(p.participatesInCYBHI);
                ctrlParticipatesInRuHealth.setValue(p.participatesInRUHealth);

                ctrlSubmitClaims.value = Util.boolToYesNoUnknown(p.submitClaims);
                ctrlSubmitClaimsEffectiveDate.value = (p.submitClaimsEffectiveDate == DateTime.MinValue) ?
                                                    "" : p.submitClaimsEffectiveDate.ToString("yyyy-MM-dd");

                /*-------------------------------
                 * Submit TCM claims
                 *------------------------------*/

                ctrlClaimTCM.value = Util.boolToYesNoUnknown(p.claim_TCM);
                ctrlClaimTCMEffectiveDate.value = (p.claim_TCMEffectiveDate == DateTime.MinValue) ?
                                                    "" : p.claim_TCMEffectiveDate.ToString("yyyy-MM-dd");
                /*-------------------------------
                 * cybhiTpa feilds
                 *------------------------------*/

                ctrlCybhiTpaApproved.value = Util.boolToYesNoUnknown(p.cybhiTpaApproved);
                ctrlCybhiTpaApprovedOn.value = p.cybhiTpaApprovedOn;
                ctrlCybhiTpaID.value = p.cybhiTpaID;
                ctrlCybhiSubmitClaims.setValue(p.cybhiSubmitClaims);

                /*-------------------------------
                 * Notes
                 *------------------------------*/

                ctrlNotes.value = p.notes;

                /*-------------------------------
                 * Qualifications
                 *------------------------------*/

                ctrlQualificationsJSONData.value = p.qualificationsJSONData;



                /*-------------------------------
                 * Certificate Completion
                 *------------------------------*/

                ctrlACESCertCompletedOn.value = p.acesCertCompletedOn;

                /*-------------------------------
                 * Department Head
                 *------------------------------*/

                ctrlCurrentlyWithClient.value = Util.boolToYesNoUnknown(p.currentlyWithClient);

                ctrlDeptHead.value = Util.boolToYesNoUnknown(p.deptHead);
                ctrlDisplaypercent.value = Util.boolToYesNoUnknown(p.displayPercent);
                ctrlDisplaymoney.value = Util.boolToYesNoUnknown(p.displayMoney);
                ctrlDeptHeadCSEPIDRR.value = Util.boolToYesNo(p.deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports);

                /*-------------------------------
                 * CYBHI required
                 *------------------------------*/

                ctrlDOB.value = p.dob;
                ctrlGender.value = p.gender;
                ctrlSSN.value = p.ssn;
                ctrlCybhiDegreeCode.value = p.cybhiDegreeCode;
                ctrlCybhiDegreeCode2.value = p.cybhiDegreeCode2;
                ctrlCybhiDegreeCode3.value = p.cybhiDegreeCode3;
                ctrlCybhiSpecialityCode.value = p.cybhiSpecialtyCode;
                ctrlCybhiSpecialityCode2.value = p.cybhiSpecialtyCode2;
                ctrlCybhiSpecialityCode3.value = p.cybhiSpecialtyCode3;
                ctrlCybhiSpecialityCode4.value = p.cybhiSpecialtyCode4;

                /*============================================================
                 * Set page title
                 *============================================================*/

                this.subTitle = "Practitioners - Edit";

            }

            /*###########################################################################
              #                                NEW
              # Set control values, step labels, first step, and page title
              ###########################################################################*/

            else
            {

                ctrlPrac_emp_relPrevDataEntryRow.entryInitiallyHidden = true;
                showPractitionerEmploymentRelationships = false;

                /*============================================================
                 * Set control values (default values) and step labels
                 *============================================================*/

                /*-------------------------------
                 * Gender
                 *------------------------------*/

                ctrlGender.value = MBA.SelectMaleOrFemale.UNKNOWN;

                /*-------------------------------
                 * Notes (put template text in)
                 *------------------------------*/

                ctrlNotes.value = Practitioners.createNotesTemplateText();

                /*-------------------------------
                 * Set client ID if passed in
                 *------------------------------*/

                if (!String.IsNullOrEmpty(clientID) && clientID != "0")
                {
                    ctrlClientID.value = clientID;
                    ctrlClientidDataEntryRow.entryInitiallyHidden = true;
                    ctrlClientidDataEntryRow.entryAllowed = false;
                }



                /*-------------------------------
                 * Department Head
                 *------------------------------*/

                ctrlCurrentlyWithClient.value = SelectYesOrNo.YES;
                ctrlDeptHead.value = SelectYesOrNo.NO;
                ctrlDeptHeadCSEPIDRR.value = SelectYesOrNo.NO;
                ctrlDisplaypercent.value = SelectYesOrNo.YES;
                ctrlDisplaymoney.value = SelectYesOrNo.NO;
                ctrlParticipatesInRuHealth.value = SelectYesOrNo.NO;

                /*============================================================
                 * Set page title
                 *============================================================*/

                this.subTitle = "Practitioners - New";

            }

            // set showContentOnly flag for redirects
            showContentOnly = MBA.HttpApplication.getParameter(Constants.PARM_CONTENT_ONLY);
            if (String.IsNullOrEmpty(showContentOnly))
            {
                showContentOnly = "0";
            }

            // set URL for navigating after save and proceed
            pracSaveURL = MBA.HttpApplication.createLink(Practitioners.URL_USER_ALL_SAVE
                                                          , true
                                                          , new NameValue(Constants.PARM_CONTENT_ONLY, showContentOnly));

        }
    }
}
