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
   * CaseloadDelete */
  /**
   * Deletes a given caseload
   ***************************************************************************/   

  public class SBSAllCaseloadDelete : WebUI
  {
   
    public SBSAllCaseloadDelete() : base("caseload-delete",WebUI.CreatePageSubTitle(CaseLoads.SEL_LABEL, CaseLoads.SEL_LABEL_DELETE),"","",Constants.ROLE_SBS_ALL){}
    
    public string recid    = "";
    public string saveType = Constants.SAVE_TYPE_DELETE.ToString();
    public string pname    = "";
    public string sdate    = "";
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /*-------------------------------
       * Get parameters
       *------------------------------*/ 
      
      recid = MBA.HttpApplication.getParameter("recid");
     
      /*-------------------------------
       * Load record
       *------------------------------*/ 
           
      CaseLoad c = CaseLoads.load(dbConnApp, log, uInfo, recid);
      
      pname = c.patName;
      sdate = Util.dateTimeToShortDate(c.startDate);
      
      WebUIControlDataField ctrlRecID    = findControlRecu(this.Page, "recid")    as WebUIControlDataField;
      WebUIControlDataField ctrlSaveType = findControlRecu(this.Page, "savetype") as WebUIControlDataField;

      ctrlRecID.value    = recid;
      ctrlSaveType.value = saveType;
   
    }
  }
}
