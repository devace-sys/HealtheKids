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
   * WebUIControlForm */
  /**
   * Base class for all forms.
   * 
   * @param  url     submit to
   * @param  private  
   *****************************************************************************/

  public abstract class WebUIControlForm : WebUIControlContainer
  {
    public WebUIControlForm() : this("", true) { }
    public WebUIControlForm(string url) : this(url, true) { }
    public WebUIControlForm(string url, bool pvt)
      : base("form", false)
    {
      _url = url;
      _pvt = pvt;
    }

    protected string _url          = "";
    protected bool   _pvt          = true;
    protected string _action       = "";
    protected string _dataType     = "json_synch";
    protected string _statusCtrlID = "";
    protected string _procResponse = "";
    protected string _procResponseSuccess = "";

    public string url                 { get { return _url; }          set { _url = value; } }
    public bool   pvt                 { get { return _pvt; }          set { _pvt = value; } }
    public string dataType            { get { return _dataType; }     set { _dataType = value; } }
    public string statusCtrlID        { get { return _statusCtrlID; } set { _statusCtrlID = value; } }
    public string procResponse        { get { return _procResponse; } set { _procResponse = value; } }
    public string procResponseSuccess { get { return _procResponse; } set { _procResponse = value; } }
    public string action              { get { return _action; } }

    protected override void Render(HtmlTextWriter writer)
    {

      /*-------------------------------
       * Build action url
       *------------------------------*/

      if (!Util.IsNullOrEmpty(_url))
      {

        if (_pvt)
          _action = HttpApplication.createLink(_url, _pvt);
        else
          _action = HttpApplication.createLink(_url);
      }

      /*-------------------------------
       * Add attributes
       *------------------------------*/

      this.addAttribute("method", "post", ATTR_HTML_TAG);
      this.addAttribute("action", _action, ATTR_HTML_TAG);

      /*-------------------------------
       * Supress submit on enter to
       * overcome the default form
       * behavoir
       *------------------------------*/

      this.addAttribute("keypress", "var kp = $.spedmonWebUI.whatKeycode(e);if (kp == 13) return false;", ATTR_JS_PAGE_LOAD_EVENT_ASSIGN);

      base.Render(writer);

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"function " + this.ID + @"_submit(){");
      writer.Write(@"var $frm = $('#" + this.ID + @"');");
      if (!Util.IsNullOrEmpty(_statusCtrlID))
        writer.Write(@"var $statusCtrl = $('#" + this._statusCtrlID + @"');");
      else
        writer.Write(@"var $statusCtrl = null;");
      writer.Write(@"$.spedmonWebUI.ajaxFrm($frm,'" + this._action + @"','" + this._dataType + @"',function(){" + this._procResponse + @"},$statusCtrl,function(){" + this._procResponseSuccess + @"});");
      writer.Write(@"}");
      writer.Write(@"</script>");

    }
  }
}

