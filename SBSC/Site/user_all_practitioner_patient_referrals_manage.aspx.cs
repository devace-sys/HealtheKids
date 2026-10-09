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
     * userAllPracPatReferralsManage */
    /**
     ***************************************************************************/

    public class userAllPracPatReferralsManage : WebUI
    {
        public string userClientID;
        public string pracIDStr;
        public string referringByUserID;
        public string clientIDStr                         = "";
        public string patIDStr                            = "";
        public string urlPracPatReferalOption             = "";
        public bool   canAccessReferalOptionsManageScreen = false;

        public userAllPracPatReferralsManage() : base(@"user_all_prac_pat_referrals_manage"
                                      , PractitionerPatientReferrals.SEL_LABEL_MANAGE
                                      , @"user_all_practitioner_patient_referral_manage.css"
                                      , @"qrcode.min.js"
                                      , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }


        protected void Page_Load(object sender, EventArgs e)
        {
            /***************************************************************************
             * Get parameter values
             ***************************************************************************/
           
            clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            patIDStr    = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);

            /***************************************************************************
             * Get control references and set values
             ***************************************************************************/
            
            var ctrlSelectPat = findControlRecu(this.Page, "selectPatient") as DataEntryRowSelectPatient;
            var ctrlclientid = findControlRecu(this.Page, Constants.PARM_CLIENT_ID) as MBA.HiddenInput;
            var ctrlpracid = findControlRecu(this.Page, Constants.PARM_PRACTITIONER_ID) as MBA.HiddenInput;
            var ctrlrefuserid  = findControlRecu(this.Page, Constants.PARM_REFERRING_BY_USER_ID) as MBA.HiddenInput;
            var ctrlActive   = findControlRecu(this.Page, Constants.PARM_ACTIVE) as MBA.HiddenInput;
            var ctrlRefCompletedState = findControlRecu(this.Page, @"refcompletedstate") as MBA.RadioBox;

            /*###########################################################################
              # Set default values for radio boxes 
              # Note: We have to do this before adding selections
              ###########################################################################*/

            ctrlRefCompletedState.value = "";

            /* Add selections for ORP approval state*/
            ctrlRefCompletedState.AddSelection(@"All", "");
            ctrlRefCompletedState.AddSelection(@"Not Completed", "0");
            ctrlRefCompletedState.AddSelection(@"Completed", "1");

            userClientID = String.IsNullOrEmpty(uInfo.userClientIDStr) ? "" : uInfo.userClientIDStr;
            referringByUserID = String.IsNullOrEmpty(uInfo.useridStr) ? "" : uInfo.useridStr;

            pracIDStr = String.IsNullOrEmpty(uInfo.userPracIDStr) ? "" : uInfo.userPracIDStr;
            if (!string.IsNullOrEmpty(patIDStr))
            {
                Patient p = Patients.load(dbConnApp, log, uInfo, patIDStr);

                ctrlSelectPat.selectValue = patIDStr;
                ctrlSelectPat.selectName = p.name;
                ctrlSelectPat.entryInitiallyHidden = false;
                ctrlSelectPat.entryAllowed = true;
            }

            ctrlclientid.value = string.IsNullOrEmpty(clientIDStr) ? userClientID : clientIDStr;
            ctrlrefuserid.value = referringByUserID;
            ctrlpracid.value = pracIDStr;
            ctrlActive.value   = "1";

            canAccessReferalOptionsManageScreen  = PractionerPatientReferalOptions.userCanAccessManageScreen(rd);
            urlPracPatReferalOption              = PractionerPatientReferalOptions.URL_MANAGE_REFERRALL_OPTIONS(ctrlclientid.value);

        }
    }
}