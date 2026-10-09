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
   * Link */
  /**
   * Link
   *
   * @param  href            action to take when button is clicked
   * @param  beforeOpen      function to call before link is opened 
   * @param  icon            jquery ui icon (ui-icon-x)
   ****************************************************************************/

  public class Link : WebUIControlCommand
  {
    public Link() : base("a", false) { _isButton = true; }

    private  string  _icon       = "";
    private  string  _text       = "";
    private  string  _url        = "";
    private  bool    _pvt        = false;
    private  string  _appmode    = "";
    private  int     _linkmode   = 1;
    private  string  _beforeOpen = "";
    private  bool    _isButton   = true;
    private  string  _parameters = "";
    
    public  string  url        { get { return _url;        } set { _url        = value; } }
    public  bool    pvt        { get { return _pvt;        } set { _pvt        = value; } }
    public  string  icon       { get { return _icon;       } set { _icon       = value.ToLower(); } }
    public  string  text       { get { return _text;       } set { _text       = value; } }
    public  string  appMode    { get { return _appmode;    } set { _appmode    = value; } }
    public  int     linkMode   { get { return _linkmode;   } set { _linkmode   = value; } }
    public  string  beforeOpen { get { return _beforeOpen; } set { _beforeOpen = value; } }
    public  bool    isButton   { get { return _isButton;   } set { _isButton   = value; } }
    public  string  parameters { get { return _parameters; } set { _parameters = value; } }
    
    protected override void Render(HtmlTextWriter writer)
    {
      
      // Determine application mode
      // uidbs
      // uidbssub
      
      
      if (Util.IsNullOrEmpty(_appmode))
        _url = HttpApplication.createLink(_url, _pvt);
      else
        _url = HttpApplication.createLink(_url, _pvt, new NameValue(Constants.PARM_APP_MODE, _appmode));

      // TODO: This is a hack.  It will break stuff.  Fix it!
      
      if (!Util.IsNullOrEmpty(_parameters))
      {
      _parameters = Uri.EscapeUriString(_parameters);
      _url = _url + _parameters;
      }
      // Assign attributes

      this.addAttribute("href", _url, ATTR_HTML_TAG);
      if (_linkmode == 1) this.addAttribute("target", "_blank", ATTR_HTML_TAG);

      // Button options

      if (_isButton)
      {
        string bOpts = "{" + (Util.IsNullOrEmpty(_icon) ? "" : "icons:{primary:'" + _icon + "'}") + "}";
        this.addAttribute("button", bOpts, ATTR_JS_PAGE_LOAD_METHOD);
        this.cssClass = "ui-spedmon-button";
      }
      
      // Link options
      
      string lOpts = "{linkmode:" + _linkmode.ToString() + ",beforeOpen:" + _beforeOpen + "}";
      this.addAttribute("spedmonLink", lOpts, ATTR_JS_PAGE_LOAD_METHOD);

      // Add text
      
      if (!Util.IsNullOrEmpty(_text))
        this.Controls.Add(new RawText(_text));

      base.Render(writer);

    }
  }


}

