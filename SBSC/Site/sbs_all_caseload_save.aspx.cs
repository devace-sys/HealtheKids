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
   * CaseloadSave */
  /**
   * Saves a caseload.
   * 
   * Note: For caseload, edit is a seperate page.
   ***************************************************************************/   

  public class SBSAllCaseloadSave : WebUI
  {
      public SBSAllCaseloadSave() : base("caseload_save", WebUI.CreatePageSubTitle(CaseLoads.SEL_LABEL, CaseLoads.SEL_LABEL_ADD), "", "", Constants.ROLE_SBS_MGMT_ANI) { }
    
    public string saveType = Constants.SAVE_TYPE_NEW.ToString();
     
    protected void Page_Load(object sender, EventArgs e)
    {            
                   
      /*-------------------------------
       * Locate save type and set its
       * value to new
       *------------------------------*/ 

      WebUIControlDataField ctrlSaveType = findControlRecu(this.Page, "savetype") as WebUIControlDataField;            
      ctrlSaveType.value = Constants.SAVE_TYPE_NEW.ToString();
      
      
    }
  }
}
