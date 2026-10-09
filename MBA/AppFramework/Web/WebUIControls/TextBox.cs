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
   * TextBox */
  /**
   * Input of alpha numeric text
   * 
   * @param  name             name
   * @param  value            value
   ****************************************************************************/

  public class TextBox : WebUIControlDataField
  {
    public TextBox ()                          : base("input", true )              {}
    public TextBox (string name, string value) : base("input", true, name, value)  {}
    
    protected bool _showOK = true;
    public    bool  showOK { get { return _showOK; } set { _showOK = value; } }
    protected override void Render(HtmlTextWriter writer)
    {
      // If this is supposed to be a private entry (password, credit card#, etc) mask it

      if (!_privateEntry) this.addAttribute("type", "text",     ATTR_HTML_TAG);
      else                this.addAttribute("type", "password", ATTR_HTML_TAG);

      this.addCssClass (WEB_UI_FIELD_DATA_TEXT);

      string opts = "{"
                   + "privateEntry:" 
                   + Util.netBoolToJSBool(this._privateEntry) 
                   + ",useOK:" 
                   + Util.netBoolToJSBool(this._showOK) 
                   + ",privateLabel:'" + this._privateLabel 
                   + "'}";      

      this.addAttribute("spedmonTextbox", opts, ATTR_JS_PAGE_LOAD_METHOD);      
      base.Render(writer);
    }
  }

}

