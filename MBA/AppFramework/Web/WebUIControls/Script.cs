using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;

namespace MBA
{

  /**************************************************************************
   * Script */
  /**
   * Inline script wrapper
   * 
   *****************************************************************************/

  public class Script : WebUIControlContainer
  {
    public Script(): base("script", false){}
    
    protected override void Render(HtmlTextWriter writer)
    {
      /*-------------------------------
       * Add required attributes
       *------------------------------*/

      this.addAttribute("type", "text/javascript", ATTR_HTML_TAG);
      base.Render(writer);
    }
  }

}

