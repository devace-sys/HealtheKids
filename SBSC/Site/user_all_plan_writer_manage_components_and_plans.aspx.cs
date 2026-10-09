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
   * UserAllPlanWriterManageComponentsAndPlans */
  /**
   * Manage components and plans
   ***************************************************************************/   

  public class UserAllPlanWriterManageComponentsAndPlans : WebUI
  {
  
    
    
    public UserAllPlanWriterManageComponentsAndPlans() : base( "plan_writer"
	                                                             , WebUI.CreatePageSubTitle(   PlanWriterRecords.SEL_LABEL
	                                                                                         , PlanWriterRecords.SEL_LABEL_MANAGE)
				                                                       , "plan_writer_manage.css"
						                                                   , "plan_writer_manage.js"
										                                           , Constants.ROLE_ALL_PCAL_AND_CLIENT){}										                   
    public string clientID                = "";
    public string groupSvcClassNameID     = "";    
    public string tkn                     = "";
    public bool   showTopInfo             = true;
    
    protected void Page_Load(object sender, EventArgs e)
    {      
	    if (this.rd.loggedIn)
	    {
	      
	      /* Force values */
	      
	      clientID            = Spedmon.Validate.optClientID                       (uInfo,MBA.HttpApplication.getParameter(@"clientid")).ToString();
       	groupSvcClassNameID = Spedmon.Validate.optPlanWriterGroupSvcClassNameID  (uInfo,MBA.HttpApplication.getParameter(PlanWriterRecords.PARM_NAME_GROUP_SVC_CLASS_NAME_ID)).ToString();	      	      
        tkn                 = this.rd.wu.usr.token;         
        
        PlanWriterRecords.validateClientAccessForPage (  dbConnApp
                                                        , log
                                                        , uInfo
                                                        , clientID
                                                        , Response
                                                        , Context );
                                                   
        if (this.rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT) showTopInfo = false;

      }
    }
  }
}
