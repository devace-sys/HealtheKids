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
   * SBSAllPatTmtGroupDelete */
  /**
   * Deletes a given treatment group
   ***************************************************************************/   

  public class ClientAllPatTmtGroupDelete : WebUI
  {
   
    public ClientAllPatTmtGroupDelete() : base("tmtgroupdelete",WebUI.CreatePageSubTitle(PatientGroups.SEL_LABEL, PatientGroups.SEL_LABEL_DELETE),"","",Constants.ROLE_CLIENT_ALL){}
    
    public string recid    = "";
    public string saveType = Constants.SAVE_TYPE_DELETE.ToString();
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /*-------------------------------
       * Get parameters
       *------------------------------*/ 
      
      recid = MBA.HttpApplication.getParameter("recid");
           
      WebUIControlDataField ctrlRecID    = findControlRecu(this.Page, "recid")    as WebUIControlDataField;
      WebUIControlDataField ctrlSaveType = findControlRecu(this.Page, "savetype") as WebUIControlDataField;

      ctrlRecID.value    = recid;
      ctrlSaveType.value = saveType;
   
    }
  }
}
