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
using System.Text;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * SBSMgmtClientPBSDocDataSave */
  /**
   * Saves physican based standards doc data
   ***************************************************************************/   

  public class SBSMgmtClientPBSDocDataSave : WebUI
  {
    public int saveType = 0;
   
    public SBSMgmtClientPBSDocDataSave() : base("mgmt_client_pbs_doc_data_save","Practitioners - New","","",Constants.ROLE_SBS_ALL){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
    
    }
  }  
}
