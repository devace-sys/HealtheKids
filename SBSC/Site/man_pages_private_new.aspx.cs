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
using System.Text;
using MBA;


namespace Spedmon
{

  public class ManPagesPrivateNew : WebUI
  {
    public string parm_welcome_new_user = "0";
    public ManPagesPrivateNew(): base ("manpages", WebUI.CreatePageSubTitle (   ManPages.SEL_LABEL_CONTENT
												                                                      , "New" )
												                                                      , ""
                                                                              , "", Constants.ROLE_ALL){}
    
    public string tkn         = "";
    public string urlNextPage = @"";

    protected void Page_Load(object sender, EventArgs e)
    {   
      string startingPage = rd.wu.usr.startingPage;
      if (String.IsNullOrWhiteSpace(startingPage)) startingPage = Constants.HOME_PRIVATE;
      urlNextPage = MBA.HttpApplication.createLink(startingPage,true);      
      tkn  = ((this.rd.loggedIn) ? this.rd.wu.usr.token : "");      
    }
}
}


