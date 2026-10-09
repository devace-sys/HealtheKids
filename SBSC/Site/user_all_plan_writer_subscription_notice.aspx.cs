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
   * UserAllPlanWriterSubscriptionNotice */
  /**
   * 
   ***************************************************************************/   

  public class UserAllPlanWriterSubscriptionNotice : WebUI
  {
  
    
    
    public UserAllPlanWriterSubscriptionNotice() : base( "plan_writer"
	                                                       , WebUI.CreatePageSubTitle(  PlanWriterRecords.SEL_LABEL
	                                                                                  , PlanWriterRecords.SEL_LABEL_SUBSCRIPTION_NOTICE)
				                                                 , ""
						                                             , ""
										                                     , Constants.ROLE_ALL_PCAL_AND_CLIENT){}
										                   
    protected void Page_Load(object sender, EventArgs e)
    {      
	    if (this.rd.loggedIn)
	    {
	      //if (this.rd.wu.usr.userGroup == Constants.USER_GROUP_CLIENT) showTopInfo = false;
      }
    }
  }
}
