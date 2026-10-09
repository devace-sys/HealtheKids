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
using MBA.WebUI3Controls;

/***************************************************************************
 * Index */
/**
 * Public home page (first page user sees when they vist the site)
 ***************************************************************************/

namespace Spedmon
{
  public class index : WebUI3
  {
    public index() : base("index","","index.css",""){}
    
    public string gotoPage = @"";
    public bool displayTransitionMessage = false; /* Indicates if spedcare transition message should be displayed.*/

    protected void Page_Load(object sender, EventArgs e)
    { 
      
      /* Get host name from server variables */
      
      string hostName = (this.Request.ServerVariables.Get("HTTP_X_FORWARDED_HOST") /* Try me first */
                ?? this.Request.ServerVariables.Get("SERVER_NAME"))                /* Then me*/
                ?? "";                                                             /* Finally */ 
      
      /* If the host name was found */

      if (!String.IsNullOrWhiteSpace(hostName)) { 

        /* And it some variant of spedcare.com then indicate we need to show message */

        if (hostName.Contains("spedcare.com")) {displayTransitionMessage = true; } else { displayTransitionMessage = false; } 
      } 
      else { displayTransitionMessage = false; }

      MBA.WebUI3Controls.TextBox     ctrlUID = findControlRecu(this.Page,@"uid") as MBA.WebUI3Controls.TextBox;
      MBA.WebUI3Controls.PasswordBox ctrlPwd = findControlRecu(this.Page,@"pwd") as MBA.WebUI3Controls.PasswordBox;

      string uid = MBA.HttpApplication.getParameter (Constants.PARM_UID);
      gotoPage   = MBA.Validate.optGotoPage(MBA.HttpApplication.getParameter (Constants.PARM_GOTO_PAGE));

      if (!String.IsNullOrWhiteSpace(uid))
      { 
        ctrlUID.Value     = uid;
        ctrlUID.AutoFocus = false;
        ctrlPwd.AutoFocus = true;
      }
      
      if (!String.IsNullOrWhiteSpace(gotoPage))
      {
        
      }

    }
  }
}
