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
using System.Text.RegularExpressions;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * WebUITeleCommBase */
  /**
   *
   ****************************************************************************/

  public class WebUITeleCommBase: MBA.WebUITeleCommBase
  {
    public WebUITeleCommBase (string roomtitlepublic) : base(Constants.APP_NAME,roomtitlepublic)
    {
   
    }
    
    /***************************************************************************
     * Page_Load */
    /**
     ***************************************************************************/   
    protected new void Page_Load (object sender, EventArgs e)
    {
      base.Page_Load(sender, e);
    }
  }
}