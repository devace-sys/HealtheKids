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
   * HiddenInput */
  /**
   * Input field that should be hidden from view.  
   * 
   * Note: This should be used in lieu of an html input tag because since it
   * a server control we can work with it at render time and at page load time.
   * 
   * @param  name             name
   * @param  value            value
   ****************************************************************************/

  public class HiddenInput : WebUIControlDataField
  {
    public HiddenInput ()                          : base("input", true )             {}
    public HiddenInput (string name, string value) : base("input", true, name, value) {}

    protected override void Render(HtmlTextWriter writer)
    {
      this.addAttribute("type", "text", ATTR_HTML_TAG);
      this.hidden = true;
      base.Render(writer);
    }
  } 

}

