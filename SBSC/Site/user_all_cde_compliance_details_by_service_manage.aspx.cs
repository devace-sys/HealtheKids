using System;
using System.Collections;
using MBA;

namespace Spedmon
{
    public class UserAllCdeComplianceDetailsByServiceManage : WebUI
    {
        public UserAllCdeComplianceDetailsByServiceManage() : base(
                                              CdeComplianceBucketDetailsByService.MENU_ID_MANAGE
                                            , CdeComplianceBucketDetailsByService.SEL_LABEL_MANAGE
                                            , ""
                                            , ""
                                            , Constants.ROLE_CDE_COMPLIANCE_MANAGE)
        { 
        }

        public string patEditUrlBase;

        protected void Page_Load(object sender, EventArgs e)
        {            
            /*------------------------------------*/
            /*  Get incoming parameters and       */
            /*  enforce client id                 */
            /*------------------------------------*/

            var clientIDIn                   = Spedmon.Validate.optClientID (uInfo, HttpApplication.getParameter (Constants.PARM_CLIENT_ID)).ToString();
            var siteIDIn                     = HttpApplication.getParameter (Constants.PARM_SITE_ID);
            var patIDIn                      = HttpApplication.getParameter (Constants.PARM_PATIENT_ID);
            var spEdSvcCodeIn                = HttpApplication.getParameter (Constants.PARM_SPED_SERVICE_CODE);
            var pcalComplianceRatingForPatIn = HttpApplication.getParameter (Constants.PARM_PCAL_COMPLIANCE_RATING_FOR_PAT);
            var overDeliveryIn               = HttpApplication.getParameter (Constants.PARM_SVC_OVER_DELIVERY);

            string siteIDStr                     = null;
            string patIDStr                      = null;
            string spEdSvcCodeStr                = null;
            string pcalComplianceRatingForPatStr = null;
            string overDeliveryStr               = null;

            if (!String.IsNullOrWhiteSpace(siteIDIn))
            {
              siteIDStr = Spedmon.Validate.optInteger(siteIDIn,Messages.INVALID_SITE_ID).ToString();
            }

            if (!String.IsNullOrWhiteSpace(patIDIn))
            {
              patIDStr = Spedmon.Validate.optPatID(uInfo, patIDIn).ToString();
            }

            if (!String.IsNullOrWhiteSpace(spEdSvcCodeIn))
            {
              spEdSvcCodeStr = Spedmon.Validate.optInteger(spEdSvcCodeIn,Messages.INVALID_CALPADS_CODE).ToString();
            }
             
            if (!String.IsNullOrWhiteSpace(pcalComplianceRatingForPatIn))
            {
              pcalComplianceRatingForPatStr = Spedmon.Validate.optInteger(pcalComplianceRatingForPatIn, @"Invalid rating code").ToString();
            }

            if (!String.IsNullOrWhiteSpace(overDeliveryIn))
            {
              overDeliveryStr = Spedmon.Validate.optFlag(overDeliveryIn, @"Invalid value for over delivery",false).ToString();
            }

            /*------------------------------------*/
            /*  Get control references            */
            /*------------------------------------*/

            var ctrlClientID          = findControlRecu(this.Page, "selectClient")       as MBA.DataEntryRowSelectClient;
            var ctrlSiteID            = findControlRecu(this.Page, "selectSite")         as MBA.DataEntryRowSelectSchoolSite;
            var ctrlPatID             = findControlRecu(this.Page, "selectPatient")      as MBA.DataEntryRowSelectPatient;
            var ctrlSpEdSvcCode       = findControlRecu(this.Page, "selectSpEdSvcCode")  as MBA.DataEntryRowSelectSpEdServiceCode;

            var ctrlPcalCompRatForPat    = findControlRecu(this.Page,  Constants.PARM_PCAL_COMPLIANCE_RATING_FOR_PAT)  as MBA.DataEntryBoxSelect;
            var ctrlShowOverDeliveryOnly = findControlRecu(this.Page,  Constants.PARM_SVC_OVER_DELIVERY)               as MBA.SelectYesIsTrueNoIsBlank;

            /*------------------------------------*/
            /*  Load pcal compliance rating       */
            /*  selections                        */
            /*------------------------------------*/

            var ratings = PatientsPromisedServicesPcalComplianceRatingForPatCodes.viewList(dbConnApp,log,uInfo);

            ctrlPcalCompRatForPat.addSelectOneSelection = false;
            ctrlPcalCompRatForPat.addSelection(new NameValue("Any","",""));
            foreach (var rating in ratings) { 
              ctrlPcalCompRatForPat.addSelection(new NameValue(rating.name,rating.id,@""));
            }
            ctrlPcalCompRatForPat.fireSpedmonInput = false;

            /*------------------------------------*/
            /*  If client id is passed then       */
            /*  preset select client              */
            /*------------------------------------*/

            if (!String.IsNullOrWhiteSpace(clientIDIn))
            {
                Client c = Clients.load(dbConnApp, log, uInfo, clientIDIn);
                ctrlClientID.selectValue = c.id.ToString();
                ctrlClientID.selectName = c.name;
            }
            
            /*------------------------------------*/
            /*  If site id is passed then        */
            /*  preset select site               */
            /*------------------------------------*/

            if (!String.IsNullOrWhiteSpace(siteIDStr))
            {
                Site s = Sites.load(dbConnApp, log, uInfo, siteIDStr);
                ctrlSiteID.selectValue = s.id.ToString();
                ctrlSiteID.selectName  = s.name;
            }
            
            /*------------------------------------*/
            /*  If patient id is passed then      */
            /*  preset select patient             */
            /*------------------------------------*/

            if (!String.IsNullOrWhiteSpace(patIDStr))
            {
                Patient p = Patients.load(dbConnApp,log,uInfo, patIDStr);
                ctrlPatID.selectValue = p.id.ToString();
                ctrlPatID.selectName  = p.name;
            }

            /*------------------------------------*/
            /*  If spEd svc code is passed then   */
            /*  preset select svc code            */
            /*------------------------------------*/
            
            if (!String.IsNullOrWhiteSpace(spEdSvcCodeStr))
            {
                SpEdService s = SpEdServices.load(dbConnApp,log,uInfo,spEdSvcCodeStr);
                ctrlSpEdSvcCode.selectValue = s.codeValue.ToString();
                ctrlSpEdSvcCode.selectName  = s.name;
            }
            
            /*------------------------------------*/
            /*  If rating code is passed then     */
            /*  preset rating code                */
            /*------------------------------------*/
        
            if (!String.IsNullOrWhiteSpace(pcalComplianceRatingForPatStr))
            {
                ctrlPcalCompRatForPat.value = pcalComplianceRatingForPatStr;
            }
            else
            {
                ctrlPcalCompRatForPat.value = "";
            }

            /*------------------------------------*/
            /*  If over delivery flag is passed   */
            /*  then preset                       */
            /*------------------------------------*/
        
            if (!String.IsNullOrWhiteSpace(overDeliveryIn))
            {
                ctrlShowOverDeliveryOnly.setValue(overDeliveryStr);                
            }
            else
            {
                ctrlShowOverDeliveryOnly.setValue(false);
            }
            
            /*------------------------------------*/
            /*  Get url for patient edit          */
            /*------------------------------------*/

            patEditUrlBase = Patients.URL_USER_ALL_EDIT_EXISTING_BASE(true,"");
        }
    }
}