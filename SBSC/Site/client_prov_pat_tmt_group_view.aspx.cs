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

namespace Spedmon
{
  /***************************************************************************
   * ClientProvPatientGroupsView */
  /**
   * 
   ***************************************************************************/

  public class ClientProvPatientGroupsView : WebUI
  {
    public ClientProvPatientGroupsView() : base("patient_groups_view", WebUI.CreatePageSubTitle(PatientGroups.SEL_LABEL, PatientGroups.SEL_LABEL_VIEW), "", "", Constants.ROLE_LEA_PROVIDER) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
