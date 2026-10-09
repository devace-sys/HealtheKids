using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;
using Geo;
using System.Text;

namespace Spedmon
{
  /***************************************************************************
   * UserAllComponentTest */
  /**
   * 
   ***************************************************************************/   
  
  public class UserAllComponentTest: WebUI
  {
    public UserAllComponentTest() : base( @"user_all_component_test"
	                                      , "Component Test"
                                          , @""
                                          , @""
										  , Constants.ROLE_ADMIN){}
    
    public static string outputLines = @"";
    protected void Page_Load(object sender, EventArgs e)
    {
    }
  } 
}