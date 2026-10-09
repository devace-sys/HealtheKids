using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace MBA
{
  /***************************************************************************
   * WebContent */
  /**
   * Base class for all "static" content such as help files
   * The markup is completely up to the page.  No markup is generated.
   ***************************************************************************/

  public class WebContent: WebApp
	{     
    public WebContent():this(null){}
    public WebContent(params string[] permittedroles):base("",permittedroles)
    {
    }

    protected override void Render(HtmlTextWriter writer)
    {  
      base.Render(writer);      
    }
	}
}
