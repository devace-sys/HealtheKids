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
   * ClientCoorPlanWriterSelectGroup */
  /**
   * 
   ***************************************************************************/   

  public class ClientCoorPlanWriterSelectGroup : WebUI
  {
  
    
    public string url      = "";
    public string clientid = "";

    public ClientCoorPlanWriterSelectGroup() : base(  "plan_writer"
	                                                , WebUI.CreatePageSubTitle(  PlanWriterRecords.SEL_LABEL
	                                                                           , PlanWriterRecords.SEL_LABEL_MANAGE)
				                                          , ""
						                                      , ""
										                              , Constants.ROLE_CLIENT_BO ){}
    
    
    protected void Page_Load(object sender, EventArgs e)
    {      
      if (this.rd.loggedIn) 
      {
        clientid                 = Spedmon.Validate.optClientID(uInfo, "").ToString();	  
        url                      = MBA.HttpApplication.createLink(PlanWriterRecords.URL_USER_ALL_MANAGE_PLANS,true);
		    HiddenInput ctrlClientID = findControlRecu(this.Page, "clientid") as HiddenInput;
		    ctrlClientID.value       = clientid;
      
        PlanWriterRecords.validateClientAccessForPage (  dbConnApp
                                                        , log
                                                        , uInfo
                                                        , clientid
                                                        , Response
                                                        , Context );
      }
    }
  }
}
