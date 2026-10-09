using System;
using System.Collections;
using MBA;
// UserAllCdeComplianceDetailsByPcalComplianceRatingAndPatientsManage
namespace Spedmon
{
    public class UserAllCdeComplianceDetailsByPcalComplianceRatingAndPatientsManage : WebUI
    {
        public UserAllCdeComplianceDetailsByPcalComplianceRatingAndPatientsManage() : base(
                                              CdeComplianceBucketDetailsByPcalComplianceRatingAndPatients.BODY_ID_MANAGE
                                            , CdeComplianceBucketDetailsByPcalComplianceRatingAndPatients.SEL_LABEL_MANAGE
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
            var pcalComplianceRatingForPatIn = HttpApplication.getParameter (Constants.PARM_PCAL_COMPLIANCE_RATING_FOR_PAT);
            
            string siteIDStr                     = null;
            string pcalComplianceRatingForPatStr = null;
            
            if (!String.IsNullOrWhiteSpace(siteIDIn))
            {
              siteIDStr = Spedmon.Validate.optInteger(siteIDIn,Messages.INVALID_SITE_ID).ToString();
            }
            
            if (!String.IsNullOrWhiteSpace(pcalComplianceRatingForPatIn))
            {
              pcalComplianceRatingForPatStr = Spedmon.Validate.optInteger(pcalComplianceRatingForPatIn, @"Invalid rating code").ToString();
            }
            
            /*------------------------------------*/
            /*  Get control references            */
            /*------------------------------------*/

            var ctrlClientID          = findControlRecu(this.Page, "selectClient")       as MBA.DataEntryRowSelectClient;
            var ctrlSiteID            = findControlRecu(this.Page, "selectSite")         as MBA.DataEntryRowSelectSchoolSite;            
            var ctrlPcalCompRatForPat = findControlRecu(this.Page,  Constants.PARM_PCAL_COMPLIANCE_RATING_FOR_PAT)  as MBA.DataEntryBoxSelect;
            
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
            /*  Get url for patient edit          */
            /*------------------------------------*/

            patEditUrlBase = Patients.URL_USER_ALL_EDIT_EXISTING_BASE(true,"");
        }
    }
}