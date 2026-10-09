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
   * ClientProvCaseloadEditDelete */
  /**
   * 
   ***************************************************************************/

  public partial class ClientProvCaseloadEditDelete : WebUI
  {    
    public ClientProvCaseloadEditDelete() : base("caseload_edit_delete", WebUI.CreatePageSubTitle(CaseLoads.SEL_LABEL, CaseLoads.SEL_LABEL_EDIT_DELETE), "", "", Constants.ROLE_LEA_PROVIDER) { }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  }
}
