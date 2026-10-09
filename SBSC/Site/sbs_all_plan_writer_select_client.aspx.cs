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
   * SBSAllTransportMgmtSelectClient */
  /**
   * Manage transportation services
   ***************************************************************************/   

  public class SBSAllPlanWriterSelectClient : WebUI
  {
  
    
    public string url = "";
    
    public SBSAllPlanWriterSelectClient() : base(  "plan_writer"
	                                                , WebUI.CreatePageSubTitle(  PlanWriterRecords.SEL_LABEL
	                                                                           , PlanWriterRecords.SEL_LABEL_MANAGE)
				                                          , ""
						                                      , ""
										                              , Constants.ROLE_SBS_ALL ){}
    
    
    protected void Page_Load(object sender, EventArgs e)
    {      
      if (this.rd.loggedIn) {                 
        url = MBA.HttpApplication.createLink(PlanWriterRecords.URL_USER_ALL_MANAGE_PLANS,true);
      }
    }
  }
}
