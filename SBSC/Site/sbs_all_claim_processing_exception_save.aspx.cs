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
    /***************************************************************************
    * SBSClaimProcessingExceptionSave */
    /**
    * Saves a client
    ***************************************************************************/
    public class SBSClaimProcessingExceptionSave : WebUI
    {
        public int saveType = 0;

        public SBSClaimProcessingExceptionSave() : base("ClaimProcessingException_save", "Claims Processing Exceptions - New", "", "", Constants.ROLE_SBS_MGMT) { }
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

            ClaimsProcessingException c = ClaimsProcessingExceptions.load(dbConnApp, log, uInfo, recid);

            /*-------------------------------
             * Locate step controls
             *------------------------------*/

            Step ctrlStep1 = findControlRecu(this.Page, "step1") as Step;
            Step ctrlStep3 = findControlRecu(this.Page, "step3") as Step;
            Step ctrlStep4 = findControlRecu(this.Page, "step4") as Step;
            Step ctrlStep5 = findControlRecu(this.Page, "step5") as Step;
            Step ctrlStep6 = findControlRecu(this.Page, "step6") as Step;

            StepSelectPractitioner ctrlStep2 = findControlRecu(this.Page, "step2") as StepSelectPractitioner;

            /*-------------------------------
             * Locate data controls
             *------------------------------*/

            WebUIControlDataField ctrlRecID       = findControlRecu(this.Page, "recid")       as WebUIControlDataField;            
            WebUIControlDataField ctrlClientID    = findControlRecu(this.Page, "clientid")    as WebUIControlDataField;
            WebUIControlDataField ctrlStartDate   = findControlRecu(this.Page, "startDate")   as WebUIControlDataField;
            WebUIControlDataField ctrlEndDate     = findControlRecu(this.Page, "endDate")     as WebUIControlDataField;
            WebUIControlDataField ctrlExceptionID = findControlRecu(this.Page, "exceptionid") as WebUIControlDataField;           
            TextAreaBox ctrlNotes                 = findControlRecu(this.Page, "notes")       as TextAreaBox;

            /*-------------------------------
             * Populate step labels
             *------------------------------*/

            ctrlStep1.label = c.name;
            ctrlStep2.label = c.pracname;
            ctrlStep3.label = Util.dateTimeToShortDate(c.startDate);
            ctrlStep4.label = Util.dateTimeToShortDate(c.endDate);
            ctrlStep5.label = c.exceptionname;           
            ctrlStep6.label = Util.previewString(c.notes);

            /*-------------------------------
             * Populate Data Values
             *------------------------------*/

            ctrlRecID.value       = c.id.ToString();
            ctrlClientID.value    = c.clientid.ToString();
            ctrlStep2.selectvalue = c.pracid.ToString();
            ctrlStartDate.value   = Util.dateTimeToShortDate(c.startDate);
            ctrlEndDate.value     = Util.dateTimeToShortDate(c.endDate);
            ctrlExceptionID.value = c.exceptionid.ToString();            
            ctrlNotes.value       = c.notes;

            if (saveType == Constants.SAVE_TYPE_EDIT) this.subTitle = "Claims Processing Exceptions - Edit";
            if (saveType == Constants.SAVE_TYPE_DELETE) this.subTitle = "Claims Processing Exceptions - Delete";
            ctrlSteps.firstStep = 6;

        }
        else
        {
            /*-------------------------------
             * Otherwise its a new record
             *------------------------------*/
            this.subTitle = "Claims Processing Exceptions - New";
        }
        }
    }
}
