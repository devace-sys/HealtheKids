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
     * ClientProvServiceRecordPatientTmtGroupSave */
    /**
     * Saves a service record
     ***************************************************************************/

    public class ClientProvServiceRecordPatientTmtGroupSave: WebUI
    {
      public int saveType = Constants.SAVE_TYPE_NEW;
        
      public ClientProvServiceRecordPatientTmtGroupSave() : base("service_record_patient_tmt_group_save", WebUI.CreatePageSubTitle(PatientGroups.SEL_LABEL, PatientGroups.SEL_LABEL_SVC_REC_NEW), "", "", Constants.ROLE_LEA_PROVIDER) { }
      protected void Page_Load(object sender, EventArgs e)
      {
        /* If user is logged in get client and prac id */
      
        if (rd.loggedIn) 
        {
          WebUIControlDataField ctrlClientID = findControlRecu(this.Page, "clientid")      as WebUIControlDataField;
          WebUIControlDataField ctrlPracID   = findControlRecu(this.Page, "pracid")        as WebUIControlDataField;

          ctrlClientID.value = Spedmon.Validate.reqClientID (uInfo, "").ToString();
          ctrlPracID.value   = Spedmon.Validate.reqPracID   (uInfo, "").ToString();
        }
      
      }
    }
}