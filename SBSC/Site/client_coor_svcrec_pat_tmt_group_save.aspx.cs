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

    public class clientcoorservicerecordpatienttmtgroupsave: WebUI
    {
        public int saveType = Constants.SAVE_TYPE_NEW;
        
        public clientcoorservicerecordpatienttmtgroupsave() : base("service_record_patient_tmt_group_save", WebUI.CreatePageSubTitle(PatientGroups.SEL_LABEL, PatientGroups.SEL_LABEL_SVC_REC_NEW), "", "", Constants.ROLE_CLIENT_BO) { }
        protected void Page_Load(object sender, EventArgs e)
        {
          /* If user is logged in get client id */
      
          if (rd.loggedIn) 
          {
            WebUIControlDataField ctrlClientID = findControlRecu(this.Page, "clientid")      as WebUIControlDataField;
            ctrlClientID.value = Spedmon.Validate.reqClientID (uInfo, "").ToString();
          }

        
        }
    }
}