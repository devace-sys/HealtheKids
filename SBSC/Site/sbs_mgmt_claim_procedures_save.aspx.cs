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
    public class SBSMGMTClaimProceduresSave : WebUI
    {
        public int saveType = 0;

        public SBSMGMTClaimProceduresSave() : base("claimprocedures_save", "Claim Procedures - New", "", "", Constants.ROLE_SBS_MGMT) { }
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

                ClaimProcedure c = ClaimProcedures.load(dbConnApp, log, uInfo, recid);

                /*-------------------------------
                 * Locate step controls
                 *------------------------------*/

                Step ctrlStep1  = findControlRecu(this.Page, "step1")  as Step;
                Step ctrlStep2  = findControlRecu(this.Page, "step2")  as Step;
                Step ctrlStep3  = findControlRecu(this.Page, "step3")  as Step;
                Step ctrlStep4  = findControlRecu(this.Page, "step4")  as Step;
                Step ctrlStep5  = findControlRecu(this.Page, "step5")  as Step;
                Step ctrlStep6  = findControlRecu(this.Page, "step6")  as Step;
                Step ctrlStep7  = findControlRecu(this.Page, "step7")  as Step;
                Step ctrlStep8  = findControlRecu(this.Page, "step8")  as Step;
                Step ctrlStep9  = findControlRecu(this.Page, "step9")  as Step;
                Step ctrlStep10 = findControlRecu(this.Page, "step10") as Step;
                Step ctrlStep11 = findControlRecu(this.Page, "step11") as Step;
                Step ctrlStep12 = findControlRecu(this.Page, "step12") as Step;
                Step ctrlStep13 = findControlRecu(this.Page, "step13") as Step;
                Step ctrlStep14 = findControlRecu(this.Page, "step14") as Step;
                Step ctrlStep15 = findControlRecu(this.Page, "step15") as Step;
                Step ctrlStep16 = findControlRecu(this.Page, "step16") as Step;
                Step ctrlStep17 = findControlRecu(this.Page, "step17") as Step;
                Step ctrlStep18 = findControlRecu(this.Page, "step18") as Step;
                Step ctrlStep19 = findControlRecu(this.Page, "step19") as Step;
                Step ctrlStep20 = findControlRecu(this.Page, "step20") as Step;
                Step ctrlStep21 = findControlRecu(this.Page, "step21") as Step;
                Step ctrlStep22 = findControlRecu(this.Page, "step22") as Step;
                Step ctrlStep23 = findControlRecu(this.Page, "step23") as Step;
                Step ctrlStep24 = findControlRecu(this.Page, "step24") as Step;
                


                /*-------------------------------
                 * Locate data controls
                 *------------------------------*/

                WebUIControlDataField ctrlRecID          = findControlRecu(this.Page, "recid")          as WebUIControlDataField;
                WebUIControlDataField ctrlnoPlanNameID   = findControlRecu(this.Page, "noPlanNameID")   as WebUIControlDataField;
                WebUIControlDataField ctrlIEP_IFSPNameID = findControlRecu(this.Page, "IEP_IFSPNameID") as WebUIControlDataField;
                WebUIControlDataField ctrlprocCode       = findControlRecu(this.Page, "proccode")       as WebUIControlDataField;
                WebUIControlDataField ctrlprocMod1       = findControlRecu(this.Page, "procmod1")       as WebUIControlDataField;
                WebUIControlDataField ctrlprocMod2       = findControlRecu(this.Page, "procmod2")       as WebUIControlDataField;
                WebUIControlDataField ctrlprocMod3       = findControlRecu(this.Page, "procmod3")       as WebUIControlDataField;
                WebUIControlDataField ctrlprocName       = findControlRecu(this.Page, "name")       as WebUIControlDataField;
                WebUIControlDataField ctrldateEffective  = findControlRecu(this.Page, "dateEffective")  as WebUIControlDataField;
                WebUIControlDataField ctrldateExpires    = findControlRecu(this.Page, "dateExpires")    as WebUIControlDataField;
                WebUIControlDataField ctrlIEPRequired    = findControlRecu(this.Page, "IEPRequired")    as WebUIControlDataField;
                WebUIControlDataField ctrlsvcFee         = findControlRecu(this.Page, "svcFee")         as WebUIControlDataField;
                WebUIControlDataField ctrlmaxUnits       = findControlRecu(this.Page, "maxUnits")       as WebUIControlDataField;
                WebUIControlDataField ctrlmaxSvcUnits    = findControlRecu(this.Page, "maxSvcUnits ")   as WebUIControlDataField;
                WebUIControlDataField ctrlTCMlowRate     = findControlRecu(this.Page, "TCMlowRate")     as WebUIControlDataField;
                WebUIControlDataField ctrlTCMmedRate     = findControlRecu(this.Page, "TCMmedRate")     as WebUIControlDataField;
                WebUIControlDataField ctrlTCMhighRate    = findControlRecu(this.Page, "TCMhighRate")    as WebUIControlDataField;
                WebUIControlDataField ctrlover17Fee      = findControlRecu(this.Page, "over17Fee")      as WebUIControlDataField;
                WebUIControlDataField ctrlunder18Fee     = findControlRecu(this.Page, "under18Fee")     as WebUIControlDataField;
                WebUIControlDataField ctrlpageNum        = findControlRecu(this.Page, "pageNum")        as WebUIControlDataField;
                WebUIControlDataField ctrldiagnosisCode  = findControlRecu(this.Page, "diagnosisCode")  as WebUIControlDataField;
                WebUIControlDataField ctrlyearlyFlag     = findControlRecu(this.Page, "yearlyFlag")     as WebUIControlDataField;
                WebUIControlDataField ctrlputIn837       = findControlRecu(this.Page, "putIn837")       as WebUIControlDataField;
                WebUIControlDataField ctrlcombIntoProxy  = findControlRecu(this.Page, "combIntoProxy")  as WebUIControlDataField;
                WebUIControlDataField ctrllinkToSvc      = findControlRecu(this.Page, "linkToSvc")      as WebUIControlDataField;
                
                /*-------------------------------
                 * Populate step labels
                 *------------------------------*/

                ctrlStep1.label  = c.noPlanName;
                ctrlStep2.label  = c.IEP_IFSPName;
                ctrlStep3.label  = c.proccode;
                ctrlStep4.label  = c.procmod1;
                ctrlStep5.label  = c.procmod2;
                ctrlStep6.label  = c.procmod3;
                ctrlStep7.label  = c.name;
                ctrlStep8.label  = Util.dateTimeToShortDate(c.dateEffective);
                ctrlStep9.label  = Util.dateTimeToShortDate(c.dateExpires);
                ctrlStep10.label = c.IEPRequired;
                ctrlStep11.label = c.svcFee.ToString();
                ctrlStep12.label = c.maxUnits;
                ctrlStep13.label = c.maxSvcUnits;
                ctrlStep14.label = c.TCMlowRate;
                ctrlStep15.label = c.TCMmedRate;
                ctrlStep16.label = c.TCMhighRate;
                ctrlStep17.label = c.over17Fee;
                ctrlStep18.label = c.under18Fee;
                ctrlStep19.label = c.pageNum;
                ctrlStep20.label = c.diagnosisCode;
                ctrlStep21.label = c.yearlyFlag;
                ctrlStep22.label = Util.boolToYesNo(c.putIn837);
                ctrlStep23.label = Util.boolToYesNo(c.combIntoProxy);
                ctrlStep24.label = Util.boolToYesNo(c.linkToSvc);
               

                /*-------------------------------
                 * Populate Data Values
                 *------------------------------*/

                ctrlRecID.value          = c.id.ToString();
                ctrlnoPlanNameID.value   = c.noPlanNameID.ToString();
                ctrlIEP_IFSPNameID.value = c.IEP_IFSPNameID.ToString();
                ctrlprocCode.value       = c.proccode;
                ctrlprocMod1.value       = c.procmod1;
                ctrlprocMod2.value       = c.procmod2;
                ctrlprocMod3.value       = c.procmod3;
                ctrlprocName.value       = c.name;
                ctrldateEffective.value  = Util.dateTimeToShortDate(c.dateEffective);
                ctrldateExpires.value    = Util.dateTimeToShortDate(c.dateExpires);
                ctrlIEPRequired.value    = c.IEPRequired;
                ctrlsvcFee.value         = c.svcFee.ToString();
                ctrlmaxUnits.value       = c.maxUnits;
                ctrlTCMlowRate.value     = c.TCMlowRate;
                ctrlTCMmedRate.value     = c.TCMmedRate;
                ctrlTCMhighRate.value    = c.TCMhighRate;
                ctrlover17Fee.value      = c.over17Fee; 
                ctrlunder18Fee.value     = c.under18Fee ;
                ctrlpageNum.value        = c.pageNum;
                ctrldiagnosisCode.value  = c.diagnosisCode;
                ctrlyearlyFlag.value     = c.yearlyFlag;                
                ctrlputIn837.value       = Util.boolToYesNo(c.putIn837);
                ctrlcombIntoProxy.value  = Util.boolToYesNo(c.combIntoProxy);
                ctrllinkToSvc.value      = Util.boolToYesNo(c.linkToSvc);

                if (saveType == Constants.SAVE_TYPE_EDIT) this.subTitle = "Claim Procedures - Edit";
                if (saveType == Constants.SAVE_TYPE_DELETE) this.subTitle = "Claim Procedures - Delete";

                // Set to index of last step.  Index is 0 based.  So 0 would be step 1
                ctrlSteps.firstStep = 24;
            }
            else
            {
                /*-------------------------------
                 * Otherwise its a new record
                 *------------------------------*/
                this.subTitle = "Claim Procedures - New";
            }

        }

    }
}
