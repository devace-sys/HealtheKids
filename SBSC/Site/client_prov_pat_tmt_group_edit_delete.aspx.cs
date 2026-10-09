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
   * ClientProvPatTmtGroupEditDelete */
  /**
   * 
   ***************************************************************************/

  public partial class ClientProvPatTmtGroupEditDelete : WebUI
  {
    
    public ClientProvPatTmtGroupEditDelete() : base("patientgroup_edit_delete", WebUI.CreatePageSubTitle(PatientGroups.SEL_LABEL, PatientGroups.SEL_LABEL_EDIT_DELETE), "", "", Constants.ROLE_LEA_PROVIDER) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
