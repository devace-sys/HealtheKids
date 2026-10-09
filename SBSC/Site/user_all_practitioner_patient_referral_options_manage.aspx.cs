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
using System.Text;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * userAllPracPatReferralOptionsManage */
    /**
     ***************************************************************************/

    public class userAllPracPatReferralOptionsManage : WebUI
    {
        public string userClientID;
        public string clientIDStr = "";
        public userAllPracPatReferralOptionsManage() : base(@"user_all_prac_pat_referral_options_manage"
                                      , PractitionerPatientReferrals.SEL_LABEL_OPTION_MANAGE
                                      , @"user_all_practitioner_patient_referral_option_manage.css"
                                      , @""
                                      , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }

        protected void Page_Load(object sender, EventArgs e)
        {
            /***************************************************************************
             * Get parameter values
             ***************************************************************************/
            clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

            /***************************************************************************
             * Get control references and set values
             ***************************************************************************/
            var ctrlclientid = findControlRecu(this.Page, Constants.PARM_CLIENT_ID) as MBA.HiddenInput;

            /*###########################################################################
              # Set default values for radio boxes 
              # Note: We have to do this before adding selections
              ###########################################################################*/

            userClientID = String.IsNullOrEmpty(uInfo.userClientIDStr) ? "" : uInfo.userClientIDStr;
            ctrlclientid.value = string.IsNullOrEmpty(clientIDStr) ? userClientID : clientIDStr;

            PractionerPatientReferalOption ro = PractionerPatientReferalOptions.load(dbConnApp, log, uInfo, ctrlclientid.value);

            if (ro != null)
            {
                if (ro.userIDForAllRoutineNotifications1 != 0)
                { /* The framework returns a 0 if the value is null */
                    var ctrlSelectUserForAllRoutineNotifications1 = findControlRecu(this.Page, "selectUserForAllRoutineNotifications1") as MBA.DataEntryRowSelectUser;
                    ctrlSelectUserForAllRoutineNotifications1.selectName = ro.personNameForAllRoutineNotifications1;
                    ctrlSelectUserForAllRoutineNotifications1.selectValue = ro.userIDForAllRoutineNotifications1.ToString();
                }
                if (ro.userIDForAllRoutineNotifications2 != 0)
                { /* The framework returns a 0 if the value is null */
                    var ctrlSelectUserForAllRoutineNotifications2 = findControlRecu(this.Page, "selectUserForAllRoutineNotifications2") as MBA.DataEntryRowSelectUser;
                    ctrlSelectUserForAllRoutineNotifications2.selectName = ro.personNameForAllRoutineNotifications2;
                    ctrlSelectUserForAllRoutineNotifications2.selectValue = ro.userIDForAllRoutineNotifications2.ToString();
                }
                if (ro.userIDForAllRoutineNotifications3 != 0)
                { /* The framework returns a 0 if the value is null */
                    var ctrlSelectUserForAllRoutineNotifications3 = findControlRecu(this.Page, "selectUserForAllRoutineNotifications3") as MBA.DataEntryRowSelectUser;
                    ctrlSelectUserForAllRoutineNotifications3.selectName = ro.personNameForAllRoutineNotifications3;
                    ctrlSelectUserForAllRoutineNotifications3.selectValue = ro.userIDForAllRoutineNotifications3.ToString();
                }

                if (ro.userIDForAllUrgentNotifications1 != 0)
                { /* The framework returns a 0 if the value is null */
                    var ctrlSelectUserForAllUrgentNotifications1 = findControlRecu(this.Page, "selectUserForAllUrgentNotifications1") as MBA.DataEntryRowSelectUser;
                    ctrlSelectUserForAllUrgentNotifications1.selectName = ro.personNameForAllUrgentNotifications1;
                    ctrlSelectUserForAllUrgentNotifications1.selectValue = ro.userIDForAllUrgentNotifications1.ToString();
                }
                if (ro.userIDForAllUrgentNotifications2 != 0)
                { /* The framework returns a 0 if the value is null */
                    var ctrlSelectUserForAllUrgentNotifications2 = findControlRecu(this.Page, "selectUserForAllUrgentNotifications2") as MBA.DataEntryRowSelectUser;
                    ctrlSelectUserForAllUrgentNotifications2.selectName = ro.personNameForAllUrgentNotifications2;
                    ctrlSelectUserForAllUrgentNotifications2.selectValue = ro.userIDForAllUrgentNotifications2.ToString();
                }
                if (ro.userIDForAllUrgentNotifications3 != 0)
                { /* The framework returns a 0 if the value is null */
                    var ctrlSelectUserForAllUrgentNotifications3 = findControlRecu(this.Page, "selectUserForAllUrgentNotifications3") as MBA.DataEntryRowSelectUser;
                    ctrlSelectUserForAllUrgentNotifications3.selectName = ro.personNameForAllUrgentNotifications3;
                    ctrlSelectUserForAllUrgentNotifications3.selectValue = ro.userIDForAllUrgentNotifications3.ToString();
                }

                if (ro.userIDForAllCrisisNotifications1 != 0)
                { /* The framework returns a 0 if the value is null */
                    var ctrlSelectUserForAllCrisisNotifications1 = findControlRecu(this.Page, "selectUserForAllCrisisNotifications1") as MBA.DataEntryRowSelectUser;
                    ctrlSelectUserForAllCrisisNotifications1.selectName = ro.personNameForAllCrisisNotifications1;
                    ctrlSelectUserForAllCrisisNotifications1.selectValue = ro.userIDForAllCrisisNotifications1.ToString();
                }
                if (ro.userIDForAllCrisisNotifications2 != 0)
                { /* The framework returns a 0 if the value is null */
                    var ctrlSelectUserForAllCrisisNotifications2 = findControlRecu(this.Page, "selectUserForAllCrisisNotifications2") as MBA.DataEntryRowSelectUser;
                    ctrlSelectUserForAllCrisisNotifications2.selectName = ro.personNameForAllCrisisNotifications2;
                    ctrlSelectUserForAllCrisisNotifications2.selectValue = ro.userIDForAllCrisisNotifications2.ToString();
                }
                if (ro.userIDForAllCrisisNotifications3 != 0)
                { /* The framework returns a 0 if the value is null */
                    var ctrlSelectUserForAllCrisisNotifications3 = findControlRecu(this.Page, "selectUserForAllCrisisNotifications3") as MBA.DataEntryRowSelectUser;
                    ctrlSelectUserForAllCrisisNotifications3.selectName = ro.personNameForAllCrisisNotifications3;
                    ctrlSelectUserForAllCrisisNotifications3.selectValue = ro.userIDForAllCrisisNotifications3.ToString();
                }

                MBA.RichTextAreaBox englishYesMessageCtrl = findControlRecu(this.Page, "announcementcontent1") as MBA.RichTextAreaBox;
                englishYesMessageCtrl.value = (string.IsNullOrEmpty(ro.englishYesMessageTemplate))?"": ro.englishYesMessageTemplate;
                MBA.RichTextAreaBox spanishYesMessageCtrl = findControlRecu(this.Page, "announcementcontent2") as MBA.RichTextAreaBox;
                spanishYesMessageCtrl.value = (string.IsNullOrEmpty(ro.spanishYesMessageTemplate)) ? "" : ro.spanishYesMessageTemplate;
                MBA.RichTextAreaBox englishNoMessageCtrl = findControlRecu(this.Page, "announcementcontent3") as MBA.RichTextAreaBox;
                englishNoMessageCtrl.value = (string.IsNullOrEmpty(ro.englishNoMessageTemplate)) ? "" : ro.englishNoMessageTemplate;
                MBA.RichTextAreaBox spanishNoMessageCtrl = findControlRecu(this.Page, "announcementcontent4") as MBA.RichTextAreaBox;
                spanishNoMessageCtrl.value = (string.IsNullOrEmpty(ro.spanishNoMessageTemplate)) ? "" : ro.spanishNoMessageTemplate;
            }
            else
            {
                HtmlGenericControl enYesMsg = (HtmlGenericControl)FindControl("enYesMsg");
                MBA.RichTextAreaBox englishYesMessageCtrl = findControlRecu(this.Page, "announcementcontent1") as MBA.RichTextAreaBox;
                englishYesMessageCtrl.value = enYesMsg.InnerHtml;
                HtmlGenericControl esYesMsg = (HtmlGenericControl)FindControl("esYesMsg");
                MBA.RichTextAreaBox spanishYesMessageCtrl = findControlRecu(this.Page, "announcementcontent2") as MBA.RichTextAreaBox;
                spanishYesMessageCtrl.value = esYesMsg.InnerHtml;
                HtmlGenericControl enNoMsg = (HtmlGenericControl)FindControl("enNoMsg");
                MBA.RichTextAreaBox englishNoMessageCtrl = findControlRecu(this.Page, "announcementcontent3") as MBA.RichTextAreaBox;
                englishNoMessageCtrl.value = enNoMsg.InnerHtml;
                HtmlGenericControl esNoMsg = (HtmlGenericControl)FindControl("esNoMsg");
                MBA.RichTextAreaBox spanishNoMessageCtrl = findControlRecu(this.Page, "announcementcontent4") as MBA.RichTextAreaBox;
                spanishNoMessageCtrl.value = esNoMsg.InnerHtml;
            }
        }
    }
}