using System;
using System.Collections;
using MBA;

namespace Spedmon
{
    public class UserAllMissingServicesTreatmentDetailsManage : WebUI
    {
        public UserAllMissingServicesTreatmentDetailsManage() : base(
                                              MissingServicesTreatmentDetails.MENU_ID_MANAGE
                                            , MissingServicesTreatmentDetails.SEL_LABEL_MANAGE
                                            , ""
                                            , ""
                                            , Constants.ROLE_MISSING_SERVICES_MANAGE)
        { 
        }

        public bool   showPotentialLostAmount = false;
        public string urlEditPatientSpEdInfo  = @"";
        public string tabToOpen               = @"";

        protected void Page_Load(object sender, EventArgs e)
        {
            /*------------------------------------*/
            /*  Get incoming parameters and       */
            /*  enforce client id and svc tracking*/
            /*  class values                      */
            /*------------------------------------*/

            var clientIDIn            = Spedmon.Validate.optClientID (uInfo, HttpApplication.getParameter (Constants.PARM_CLIENT_ID)).ToString();
            var svcTrackingClassIn    = Spedmon.Validate.reqInteger  (HttpApplication.getParameter (Constants.PARM_SVC_TRACKING_CLASS),@"Service tracking class required");

            var groupSvcClassNameIDIn = HttpApplication.getParameter (Constants.PARM_GRP_SVC_CLS_NME_ID);
            var spEdSvcCodeIn         = HttpApplication.getParameter (Constants.PARM_SPED_SERVICE_CODE);
            var leaOnlyOrAllSpedIn    = HttpApplication.getParameter (Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED);

            /*------------------------------------*/
            /*  Get control references            */
            /*------------------------------------*/

            var ctrlClientID          = findControlRecu(this.Page, Constants.PARM_CLIENT_ID)                as MBA.HiddenInput;
            var ctrlSvcTrackingClass  = findControlRecu(this.Page, Constants.PARM_SVC_TRACKING_CLASS)       as MBA.HiddenInput;
            var ctrlSpEdSvcCode       = findControlRecu(this.Page, "selectSpedSvcCode")                     as MBA.DataEntryRowSelectSpEdServiceCode;
            var ctrlDispFamily        = findControlRecu(this.Page, "selectGroupServiceClassNameID")         as MBA.DataEntryRowSelectPractitionerDisciplineFamily;
            var ctrlLeaOnlyOrAllSped  = findControlRecu(this.Page, Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED) as MBA.RadioBox;
            var ctrlLinkCalsAndBreaks = findControlRecu(this.Page, @"gotomanagecalsandbreaks")              as MBA.LinkInternal;
        
            /*------------------------------------*/
            /*  Set values                        */
            /*------------------------------------*/

            ctrlClientID.value         = clientIDIn;            
            ctrlSvcTrackingClass.value = svcTrackingClassIn.ToString();

            /*------------------------------------*/
            /*  If service tracking class is for  */
            /*  SpEd Services                     */
            /*------------------------------------*/
            
            if (svcTrackingClassIn == MBA.ServiceTrackingClass.SPED_SERVICE.GetValueAsInt()) { 
              SpEdService ss = SpEdServices.load(dbConnApp,log,uInfo,spEdSvcCodeIn);
              ctrlSpEdSvcCode.selectValue          = ss.codeValue.ToString();
              ctrlSpEdSvcCode.selectName           = ss.name;
              ctrlSpEdSvcCode.entryInitiallyHidden = false;
              ctrlDispFamily.entryInitiallyHidden  = true;
              this.subTitle = MissingServicesTreatmentDetails.SEL_LABEL_MANAGE_IEP_IFSP;
              tabToOpen = @"tab-promised-services";
            }

            /*------------------------------------*/
            /*  If service tracking class is for  */
            /*  non SpEd Services                 */
            /*------------------------------------*/

            else if (svcTrackingClassIn == MBA.ServiceTrackingClass.NON_SPED_SERVICE.GetValueAsInt()) {
              GroupsServiceClass gsc = GroupsServiceClasses.load(dbConnApp, log, uInfo, "100", groupSvcClassNameIDIn);
              ctrlDispFamily.selectValue           = gsc.id.ToString();
              ctrlDispFamily.selectName            = gsc.name;
              ctrlDispFamily.entryInitiallyHidden  = false;
              ctrlSpEdSvcCode.entryInitiallyHidden = true;
              this.subTitle = MissingServicesTreatmentDetails.SEL_LABEL_MANAGE_NON_IEP_IFSP;
              tabToOpen = @"tab-services";
             }


            /*------------------------------------*/
            /*  Setup radio for selecting         */
            /*  Medi-Cal billing or All SpEd      */  
            /*------------------------------------*/
            
            /* If a parm is passed use it */
            
            
            if (!String.IsNullOrWhiteSpace(leaOnlyOrAllSpedIn)) {                  
              ctrlLeaOnlyOrAllSped.AddSelection(Constants.SPED_LEA_BOP_ONLY_LABEL,  Constants.SPED_LEA_BOP_ONLY, ((Constants.SPED_LEA_BOP_ONLY == leaOnlyOrAllSpedIn) ? true: false));
              ctrlLeaOnlyOrAllSped.AddSelection(Constants.SPED_ALL_SPED_LABEL,      Constants.SPED_ALL_SPED,     ((Constants.SPED_ALL_SPED     == leaOnlyOrAllSpedIn) ? true: false));  
              ctrlLeaOnlyOrAllSped.value = leaOnlyOrAllSpedIn;      
            } 
            
            /* Otherwise use defaults */
            
            else {
              ctrlLeaOnlyOrAllSped.AddSelection(Constants.SPED_LEA_BOP_ONLY_LABEL,  Constants.SPED_LEA_BOP_ONLY, true);
              ctrlLeaOnlyOrAllSped.AddSelection(Constants.SPED_ALL_SPED_LABEL,      Constants.SPED_ALL_SPED);  
              ctrlLeaOnlyOrAllSped.value = Constants.SPED_LEA_BOP_ONLY;
            }
                        
            /*------------------------------------*/
            /*  Setup URL for managing calendars  */
            /*  and breaks                        */
            /*------------------------------------*/
           
            ctrlLinkCalsAndBreaks.url = Clients.URL_USER_ALL_MY_ORGANIZATION;
            ctrlLinkCalsAndBreaks.addParameter(new NameValue(Constants.PARM_CLIENT_ID,clientIDIn));

            /*------------------------------------*/
            /*  Setup url for editing patient     */
            /*------------------------------------*/

            urlEditPatientSpEdInfo = MBA.HttpApplication.createLink(Patients.URL_USER_ALL_SAVE
                                              , true
                                              , new NameValue(Constants.PARM_TAB_TO_OPEN, tabToOpen)
                                              , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                              , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                              , new NameValue(Constants.PARM_REC_ID, @""));
            
            /*------------------------------------*/
            /*  Determine if we show potential    */
            /*  lost reimbursement amounts to     */
            /*  user                              */
            /*------------------------------------*/

            if (MissingServicesTreatmentsCommon.showPotentialLostReimburseAmountToUser(uInfo))
            {
                showPotentialLostAmount = true;
            }

            if (rd.wu.pr != null)
            {
                if (rd.wu.pr.displayMoney)
                {
                    showPotentialLostAmount = true;
                }
            }

           
            
        }
    }
}