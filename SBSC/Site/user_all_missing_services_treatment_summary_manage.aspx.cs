using System;
using System.Collections;
using MBA;

namespace Spedmon
{
    public class UserAllMissingServicesTreatmentSummaryManage : WebUI
    {
        public bool showPotentialLostAmount = false;
        public UserAllMissingServicesTreatmentSummaryManage() : base(
                                              MissingServicesTreatmentsSummary.BODY_ID_MANAGE
                                            , MissingServicesTreatmentsSummary.SEL_LABEL_MANAGE
                                            , ""
                                            , ""
                                            , Constants.ROLE_MISSING_SERVICES_MANAGE)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {     
            /*------------------------------------*/
            /*  Setup radio for selecting         */
            /*  Medi-Cal billing or All SpEd      */  
            /*------------------------------------*/

            var ctrlLeaOnlyOrAllSped  = findControlRecu(this.Page, Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED) as MBA.RadioBox;

            ctrlLeaOnlyOrAllSped.AddSelection(Constants.SPED_LEA_BOP_ONLY_LABEL,  Constants.SPED_LEA_BOP_ONLY, true);
            ctrlLeaOnlyOrAllSped.AddSelection(Constants.SPED_ALL_SPED_LABEL,      Constants.SPED_ALL_SPED);  
            ctrlLeaOnlyOrAllSped.value = Constants.SPED_LEA_BOP_ONLY;

            /*------------------------------------*/
            /*  If this is a user we can show     */
            /*  potential lost reimbursement      */
            /*  amts for then do it.              */  
            /*------------------------------------*/

           if (MissingServicesTreatmentsCommon.showPotentialLostReimburseAmountToUser(uInfo))
           {
              showPotentialLostAmount = true;
           }
        }
    }
}