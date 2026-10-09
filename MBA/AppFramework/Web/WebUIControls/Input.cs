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
   * Input */
  /**
   * Generic input
   * 
   * @param  name             name
   * @param  value            value
   ****************************************************************************/

  public class Input : WebUIControlDataField
  {
    public Input ()                          : base ("input", true) { }
    public Input (string name, string value) : base ("input", true, name, value) { }

    protected override void Render(HtmlTextWriter writer)
    {
      this.addAttribute("type", "text", ATTR_HTML_TAG);
      this.addAttribute("spedmonInput", "", ATTR_JS_PAGE_LOAD_METHOD);
      base.Render(writer);
    }
  }

}

