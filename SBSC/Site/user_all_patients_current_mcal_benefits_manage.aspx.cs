using System;
using MBA;

namespace Spedmon
{
    public class userAllPatientsCurrentMcalBenefitsManage : WebUI
    {
        public userAllPatientsCurrentMcalBenefitsManage() : base( "user_all_patients_current_mcal_benefits_manage"
                                                                , PatientsCurrentMcalBenefits.SEL_LABEL_MANAGE
                                                                , "user_all_patients_current_mcal_benefits_manage.css"
                                                                , ""
                                                                , Constants.ROLE_SBS_ALL_LEA_COORD)
        { }

        public string urlEditPatInfo = @"";

        protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlCurrentbenefitstatuscode = findControlRecu(this.Page, "currentbenefitstatuscode")    as MBA.RadioBox;
            var ctrlHasAltFormat             = findControlRecu(this.Page, Constants.PARM_HAS_ALT_FORMAT) as MBA.SelectYesOrNoOrAny;
            // set up radio box for management tab
            ctrlCurrentbenefitstatuscode.value = PatientsCurrentMcalBenefits.MCAL_EXPIRED_TAB_ID; /* Default */
            
            ctrlCurrentbenefitstatuscode.AddSelection(@"Medi-Cal Expired", PatientsCurrentMcalBenefits.MCAL_EXPIRED_TAB_ID);
            ctrlCurrentbenefitstatuscode.AddSelection(@"Medi-Cal Current", PatientsCurrentMcalBenefits.MCAL_CURRENT_TAB_ID);
            ctrlCurrentbenefitstatuscode.AddSelection(@"Unknown"         , PatientsCurrentMcalBenefits.UNKNOWN_TAB_ID);

            ctrlHasAltFormat.value    = @"u";
            ctrlHasAltFormat.anyLabel = @"Does Not Matter";
            ctrlHasAltFormat.anyValue = @"u";

            urlEditPatInfo = MBA.HttpApplication.createLink(Patients.URL_USER_ALL_SAVE
                                              , true
                                              , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                              , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                              , new NameValue(Constants.PARM_REC_ID, @""));
        }
    }
}