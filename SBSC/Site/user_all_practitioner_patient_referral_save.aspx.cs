using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace Spedmon
{
    public class UserAllPractitionerPatientReferralSave : WebUI
    {
        PractitionerPatientReferral referral = new PractitionerPatientReferral();
        public int saveType;
        public bool pageOK      = true;
        public MBA.User userInfo;

        public UserAllPractitionerPatientReferralSave() : base("practitioner_patient_referral_save"
                                                        , PractitionerPatientReferrals.SEL_OUT_LABEL_SAVE
                                                        , "user_all_practitioner_patient_referral_save.css"
                                                        , @""
                                                        , Constants.ROLE_ALL_PCAL_AND_CLIENT )
        { }
        protected void Page_Load(object sender, EventArgs e)
        {
            /*###########################################################################
              # Fetch parameters 
              ###########################################################################*/

            string clientid     = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);            
            string savetype     = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
            string patid        = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
            string pracid       = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
            string recid        = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
            string refuserid    = MBA.HttpApplication.getParameter(Constants.PARM_REFERRING_BY_USER_ID);

            /*###########################################################################
              # Determine save type
              ###########################################################################*/

            Object vSaveType = Spedmon.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);
            saveType = Constants.SAVE_TYPE_NEW;
            if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
            saveType = (int)vSaveType;

            /***************************************************************************
            * Get control references and set values
            ***************************************************************************/

            var ctrlclientid = findControlRecu(this.Page, Constants.PARM_CLIENT_ID) as MBA.HiddenInput;
            var ctrlpracid = findControlRecu(this.Page, Constants.PARM_PRACTITIONER_ID) as MBA.HiddenInput;
            var ctrlpatid   = findControlRecu(this.Page, "selectPatient") as MBA.DataEntryRowSelectPatient;
            var ctrlrefuserid = findControlRecu(this.Page, Constants.PARM_REFERRING_BY_USER_ID) as MBA.HiddenInput;
            var ctrlrecid = findControlRecu(this.Page, Constants.PARM_REC_ID) as MBA.HiddenInput;
            var ctrlsavetype = findControlRecu(this.Page, Constants.PARM_SAVE_TYPE) as MBA.HiddenInput;

            var priorityRoutine = findControlRecu(this.Page, "pat_ref_routine") as HtmlInputCheckBox;
            var priorityUrgent = findControlRecu(this.Page, "pat_ref_urgent") as HtmlInputCheckBox;
            var priorityCrisis = findControlRecu(this.Page, "pat_ref_crisis") as HtmlInputCheckBox;
            var pracRefName = findControlRecu(this.Page, "pat_ref_prac_name") as HtmlInputText;
            var pracRefAgency = findControlRecu(this.Page, "pat_ref_prac_agency") as HtmlInputText; 
            var pracRefEmail = findControlRecu(this.Page, "pat_ref_prac_email") as HtmlInputControl;
            var pracRefPhone = findControlRecu(this.Page, "pat_ref_prac_phone") as HtmlInputControl;
            var parentRefName = findControlRecu(this.Page, "pat_ref_parent_name_datalist") as HtmlInputText;
            var parentRefRelationship = findControlRecu(this.Page, "pat_ref_parent_relationship") as HtmlInputText;
            var parentRefEmail = findControlRecu(this.Page, "pat_ref_parent_email") as HtmlInputControl;
            var parentRefPhone = findControlRecu(this.Page, "pat_ref_parent_phone") as HtmlInputControl;
            var refReason = findControlRecu(this.Page, "pat_ref_reason_or_impression") as HtmlTextArea;
            //var refFiles = findControlRecu(this.Page, "pat_ref_select_attach") as HtmlSelect;
            var chkdiagnosis = findControlRecu(this.Page, "pat_ref_diagnosis") as HtmlInputCheckBox;
            var chkscreenings = findControlRecu(this.Page, "pat_ref_recent_screenings") as HtmlInputCheckBox;
            var chkmedications = findControlRecu(this.Page, "pat_ref_medications") as HtmlInputCheckBox;
            var chkdirectservices = findControlRecu(this.Page, "pat_ref_direct_svc_history") as HtmlInputCheckBox;
            var chknonconfidentialnotes = findControlRecu(this.Page, "pat_ref_nonconfid_session_notes") as HtmlInputCheckBox;
            var chkconfidentialnotes = findControlRecu(this.Page, "pat_ref_confid_session_notes") as HtmlInputCheckBox;

            ctrlpracid.value = "";

            if (!string.IsNullOrEmpty(pracid))
                ctrlpracid.value = pracid;

            ctrlrefuserid.value = string.IsNullOrEmpty(refuserid) ? uInfo.useridStr : refuserid;
            ctrlsavetype.value = saveType.ToString();

            if (!string.IsNullOrEmpty(clientid))
                ctrlclientid.value = clientid;
            
            try
            {
                if (saveType == Constants.SAVE_TYPE_NEW)
                {
                    if (!string.IsNullOrEmpty(patid))
                    {
                        Patient p = Patients.load(dbConnApp, log, uInfo, patid);
                        ctrlpatid.selectValue = p.id.ToString();
                        ctrlpatid.selectName = p.name;

                        pageOK = true;
                    }
                }
                else if (saveType == Constants.SAVE_TYPE_EDIT)
                {
                    referral = PractitionerPatientReferrals.load(dbConnApp, log, uInfo, clientid, recid);

                    if (referral != null)
                    {
                        ctrlclientid.value = referral.clientID.ToString();
                        ctrlrecid.value = recid;
                        priorityRoutine.Checked = (referral.priority == 1);
                        priorityUrgent.Checked = (referral.priority == 2);
                        priorityCrisis.Checked = (referral.priority == 3);

                        ctrlpatid.selectValue = referral.patID.ToString();
                        ctrlpatid.selectName = referral.patName;
                        pracRefName.Value = referral.referredToPracName;
                        pracRefAgency.Value = referral.referredToOrgName;
                        pracRefEmail.Value = referral.referredToPracEmail;
                        pracRefPhone.Value = referral.referredToPracPhone;
                        parentRefName.Value = referral.parentGuardianName;
                        parentRefRelationship.Value = referral.parentGuardianRelationship;
                        parentRefEmail.Value = referral.parentGuardianEmail;
                        parentRefPhone.Value = referral.parentGuardianPhone;
                        refReason.Value = referral.notes;
                        chkdiagnosis.Checked = referral.includeDiagnoses;
                        chkscreenings.Checked = referral.includeServiceRecordsAssessementsOrScreenings;
                        chkmedications.Checked = referral.includeOrdersOrPrescriptions;
                        chkdirectservices.Checked = referral.includeServiceRecordsTreatments;
                        chknonconfidentialnotes.Checked = referral.includeServiceNotesNonConfidential;
                        chkconfidentialnotes.Checked = referral.includeServiceNotesConfidential;
                    }
                }

                pageOK = true;
            }
            catch
            {
                pageOK = false;
                return;
            }
        }
    }
}