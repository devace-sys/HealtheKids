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
     * SBSAllServiceRecordPatientTmtGroupSave */
    /**
     * Saves a service record
     ***************************************************************************/

    public class SBSAllServiceRecordPatientTmtGroupSave: WebUI
    {
        public int saveType = Constants.SAVE_TYPE_NEW;
        
        public SBSAllServiceRecordPatientTmtGroupSave() : base("service_record_patient_tmt_group_save", WebUI.CreatePageSubTitle(PatientGroups.SEL_LABEL, PatientGroups.SEL_LABEL_SVC_REC_NEW), "", "", Constants.ROLE_SBS_ALL) { }
        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}