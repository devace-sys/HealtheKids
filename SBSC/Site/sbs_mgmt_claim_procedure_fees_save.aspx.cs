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
using MBA;

namespace Spedmon
{
    public class SBSMGMTProcedureFeesSave : WebUI
    {
        public int saveType = 0;

        public SBSMGMTProcedureFeesSave() : base("Claim Procedure Fees_save", "Claim Procedure Fees - New", "", "", Constants.ROLE_SBS_MGMT) { }
        protected void Page_Load(object sender, EventArgs e)
        {
            /*-------------------------------
             * Determine what save type
             * this is 
             *------------------------------*/

            string recid    = MBA.HttpApplication.getParameter("recid");
            string savetype = MBA.HttpApplication.getParameter("savetype");

            Object vSaveType = MBA.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);

            if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
            saveType = (int)vSaveType;

            WebUIControlDataField ctrlSaveType = findControlRecu(this.Page, "savetype") as WebUIControlDataField;
            Steps ctrlSteps = findControlRecu(this.Page, "save") as Steps;

            ctrlSaveType.value = saveType.ToString();

            if (saveType == Constants.SAVE_TYPE_EDIT)
            {

            /*-------------------------------
             * Load record and if its not
             * found get out
             *------------------------------*/

                ClaimProcedureFee c = ClaimProcedureFees.load(dbConnApp, log, uInfo, recid);

                /*-------------------------------
                 * Locate step controls
                 *------------------------------*/

                Step ctrlStep1 = findControlRecu(this.Page, "step1") as Step;
                Step ctrlStep2 = findControlRecu(this.Page, "step2") as Step;
                Step ctrlStep3 = findControlRecu(this.Page, "step3") as Step;
                


                /*-------------------------------
                 * Locate data controls
                 *------------------------------*/

                WebUIControlDataField ctrlRecID         = findControlRecu(this.Page, "recid")         as WebUIControlDataField;                
                WebUIControlDataField ctrlprocID        = findControlRecu(this.Page, "procID")        as WebUIControlDataField;                
                WebUIControlDataField ctrldateEffective = findControlRecu(this.Page, "startDate") as WebUIControlDataField;                
                WebUIControlDataField ctrlsvcFee        = findControlRecu(this.Page, "fee")        as WebUIControlDataField;
                

                /*-------------------------------
                 * Populate step labels
                 *------------------------------*/

                
                ctrlStep1.label = c.procID.ToString();        
                ctrlStep2.label = Util.dateTimeToShortDate(c.startDate);               
                ctrlStep3.label = c.fee.ToString();
               

                /*-------------------------------
                 * Populate Data Values
                 *------------------------------*/

                ctrlRecID.value         = c.id.ToString();               
                ctrlprocID.value        = c.procID.ToString();
                ctrldateEffective.value = Util.dateTimeToShortDate(c.startDate);                
                ctrlsvcFee.value        = c.fee.ToString();
               
                if (saveType == Constants.SAVE_TYPE_EDIT) this.subTitle   = "Claim Procedure Fees - Edit";
                if (saveType == Constants.SAVE_TYPE_DELETE) this.subTitle = "Claim Procedure Fees - Delete";

                // Set to index of last step.  Index is 0 based.  So 0 would be step 1
                ctrlSteps.firstStep = 24;
            }
            else
            {
                /*-------------------------------
                 * Otherwise its a new record
                 *------------------------------*/
                this.subTitle = "Claim Procedure Fees - New";
            }
        }
    }
}
   