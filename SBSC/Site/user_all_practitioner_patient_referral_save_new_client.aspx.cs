using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace Spedmon
{
    public class UserAllPractitionerPatientReferralSaveNewClient : WebUI
    {
        PractitionerPatientReferral referral = new PractitionerPatientReferral();
        public int saveType;
        public bool pageOK      = true;
        public MBA.User userInfo;

        /*pre-fill user logged-in data*/
        public string usrname = "";
        public string usrrolename = "";
        public long   usrroleid;
        public string usremail = "";
        public string usrphone = "";


        public UserAllPractitionerPatientReferralSaveNewClient() : base("practitioner_patient_referral_save_new_client"
                                                        , PractitionerPatientReferrals.SEL_IN_LABEL_SAVE
                                                        , "user_all_practitioner_patient_referral_save_new_client.css"
                                                        , @""
                                                        , Constants.ROLE_ALL_PCAL_AND_CLIENT )
        { }
        protected void Page_Load(object sender, EventArgs e)
        {
            /*###########################################################################
              # Fetch parameters 
              ###########################################################################*/

            string clientid     = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            string userpracid   = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID); 
            string refuserid    = MBA.HttpApplication.getParameter(Constants.PARM_REFERRING_BY_USER_ID);
            string savetype     = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
            string recid        = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);

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

            var ctrlclientid                        = findControlRecu(this.Page, Constants.PARM_CLIENT_ID) as MBA.HiddenInput;
            var ctrlPracID                          = findControlRecu(this.Page, "userpracid") as MBA.HiddenInput;
            DataEntryRowSelectPatient ctrlpatid     = findControlRecu(this.Page, @"selectPatientRef") as MBA.DataEntryRowSelectPatient;
            var ctrlrefuserid                       = findControlRecu(this.Page, Constants.PARM_REFERRING_BY_USER_ID) as MBA.HiddenInput;
            DataEntryRowSelectPractitioner ctrlprac = findControlRecu(this.Page, @"selectPractitionerRef") as MBA.DataEntryRowSelectPractitioner;
            var ctrlrecid                           = findControlRecu(this.Page, Constants.PARM_REC_ID) as MBA.HiddenInput;
            var ctrlsavetype                        = findControlRecu(this.Page, Constants.PARM_SAVE_TYPE) as MBA.HiddenInput;

            var priorityRoutine                     = findControlRecu(this.Page, "pat_ref_routine_nc") as HtmlInputCheckBox;
            var priorityUrgent                      = findControlRecu(this.Page, "pat_ref_urgent_nc") as HtmlInputCheckBox;
            var priorityCrisis                      = findControlRecu(this.Page, "pat_ref_crisis_nc") as HtmlInputCheckBox;

            var sourceRefName                       = findControlRecu(this.Page, "pat_ref_source_name_nc") as HtmlInputText;
            var sourceRefRole                       = findControlRecu(this.Page, "pat_ref_source_role_nc") as HtmlSelect;
            var sourceRefEmail                      = findControlRecu(this.Page, "pat_ref_source_email_nc") as HtmlInputControl;
            var sourceRefPhone                      = findControlRecu(this.Page, "pat_ref_source_phone_nc") as HtmlInputControl;

            var refBehavioralIssues                 = findControlRecu(this.Page, "pat_ref_behavioral_issues") as HtmlInputCheckBox;
            var refAcademicConcerns                 = findControlRecu(this.Page, "pat_ref_academic_concerns") as HtmlInputCheckBox;
            var refAnxietyDeoression                = findControlRecu(this.Page, "pat_ref_anxiety_deoression") as HtmlInputCheckBox;
            var refFamilyStress                     = findControlRecu(this.Page, "pat_ref_family_stress") as HtmlInputCheckBox;
            var refBullying                         = findControlRecu(this.Page, "pat_ref_bullying") as HtmlInputCheckBox;
            var refOtherConcerns                    = findControlRecu(this.Page, "pat_ref_other_concerns") as HtmlTextArea;

            var refReasonOrImpression               = findControlRecu(this.Page, "pat_ref_reason_or_impression_nc") as HtmlTextArea;

            ctrlprac.selectName             = " Unnassigned ";
            ctrlprac.selectValue            = "0";
            ctrlprac.entryInitiallyHidden   = false;
            ctrlprac.entryAllowed           = true;

            ctrlrefuserid.value             = string.IsNullOrEmpty(refuserid) ? uInfo.useridStr : refuserid;
            ctrlsavetype.value              = saveType.ToString();
            ctrlclientid.value              = String.IsNullOrEmpty(clientid) ? "" : clientid;
            ctrlPracID.value                = "";

            if (!string.IsNullOrEmpty(userpracid))
                ctrlPracID.value = userpracid;

            try
            {  
                if (saveType == Constants.SAVE_TYPE_NEW)
                {
                    userInfo = Users.load(dbConnApp, log, uInfo, uInfo.useridStr);
                    sourceRefName.Value = string.IsNullOrEmpty(userInfo.name) ? "" : userInfo.name;
                    var val = string.IsNullOrEmpty(userInfo.roleName) ? "0" : userInfo.roleName;

                    var li = sourceRefRole.Items.FindByValue(val);

                    if (li == null)
                    {
                        string text = (val == "0") ? "N/A" : userInfo.roleName;

                        li = new ListItem(text, val);
                        sourceRefRole.Items.Add(li);
                    }
                    li.Selected = true;

                    sourceRefEmail.Value = string.IsNullOrEmpty(userInfo.email) ? "" : userInfo.email;
                    sourceRefPhone.Value = string.IsNullOrEmpty(userInfo.phone) ? "" : userInfo.phone;
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
                        ctrlprac.selectValue = referral.referredToPracID.ToString();
                        ctrlprac.selectName = referral.referredToPracName;

                        sourceRefName.Value = referral.referralSourceName;
                        sourceRefRole.Value = referral.referralSourceRole;
                        sourceRefEmail.Value = referral.referralSourceEmail;
                        sourceRefPhone.Value = referral.referralSourcePhone;

                        refBehavioralIssues.Checked = referral.behavioralIsssuesConcerns;
                        refAcademicConcerns.Checked = referral.academicConcerns;
                        refAnxietyDeoression.Checked = referral.anxietyOrDepressionConcerns;
                        refFamilyStress.Checked = referral.familyStressConcerns;
                        refBullying.Checked = referral.bullyingConcerns;
                        refOtherConcerns.Value = referral.otherConcerns;
                        refReasonOrImpression.Value = referral.notes;
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