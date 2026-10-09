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
   * NumberBox */
  /**
   * Permits the entry of numbers only
   *************************************************************************/

  public class NumberBox : WebUIControlDataField
  {
    public NumberBox ()                          : base("input", true ) { }
    public NumberBox (string name, string value) : base("input", true, name, value) { }

    protected bool _showControls = true;
    protected bool _showOK       = true;

    public bool showControls { get { return _showControls; } set { _showControls = value; } }
    public bool showOK       { get { return _showOK; }       set { _showOK = value; } }

    protected override void Render(HtmlTextWriter writer)
    {
      string prms = @"{" +
                      @"showControls:" + this._showControls.ToString().ToLower() + "," +
                      @"showOK:" + this._showOK.ToString().ToLower() +
                      @"}";

      this.addCssClass (WEB_UI_FIELD_DATA_NUMBER);
      this.addAttribute("spedmonNumberbox", prms, ATTR_JS_PAGE_LOAD_METHOD);
      base.Render(writer);
    }
  }

}

