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
     * ClientProvServiceRecordPatientTmtGrpSave */
    /**
     * Saves a service record
     ***************************************************************************/

    public class ClientProvServiceRecordPatientTmtGrpSave: WebUI
    {
      public int saveType = Constants.SAVE_TYPE_NEW;
        
      public ClientProvServiceRecordPatientTmtGrpSave() : base("service_record_patient_tmt_grp_save", WebUI.CreatePageSubTitle(PatientGroups.SEL_LABEL, PatientGroups.SEL_LABEL_SVC_REC_NEW), "", "", Constants.ROLE_LEA_PROVIDER) { }
      protected void Page_Load(object sender, EventArgs e)
      {
      }
    }
}