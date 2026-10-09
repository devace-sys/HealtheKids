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
   * MenuItemLinkType */
  /**
   * Various types of default values this control
   ****************************************************************************/
  public enum MenuItemLinkType 
  { 
        URL                  = 1 
      , DIALOG               = 2
      , URL_OPEN_NEW         = 3
      , URL_OPEN_NEW_AMD_SUB = 4
      , URL_GOTO_AMD_SUB     = 5
  };

  /**************************************************************************
   * ButtonMenuLink */
  /**
   * Renders a button to click on a menu link if the link exists.  
   * If the link does not exist, nothing is shown.
   *
   * The intended application of this control is to only display buttons
   * that users have access to.
   *
   * Please note: The "main menu" must be present in order for this to work
   *
   ***************************************************************************/


  public class ButtonMenuItemLink : WebUIControlCommand
  {
    public ButtonMenuItemLink() : base("button", false) { }

    private string _menuitemid  = "";
    private string _icon        = "";
    private string _text        = "";

    protected bool _noLinkInMenuThenRemoveParentLi  = false;

    protected MenuItemLinkType _menuitemlinktype = MenuItemLinkType.URL;
           
    public string            menuitemid       { get { return _menuitemid;}       set { _menuitemid      = value; }}    
    public string            icon             { get { return _icon; }            set { _icon            = value.ToLower(); }}
    public string            text             { get { return _text; }            set { _text            = value; }}
    public MenuItemLinkType  menuitemlinktype { get { return _menuitemlinktype;} set {_menuitemlinktype = value;}}
    public bool              noLinkInMenuThenRemoveParentLi { get {return _noLinkInMenuThenRemoveParentLi;} set { _noLinkInMenuThenRemoveParentLi = value;}}
    protected override void Render(HtmlTextWriter writer)
    {
      this.addAttribute("type", "button", ATTR_HTML_TAG);
      
      // TODO: Improve this link type passing logic
      
      string _linktype = "1";
      
      if      (_menuitemlinktype == MenuItemLinkType.DIALOG)               _linktype = "2";
      else if (_menuitemlinktype == MenuItemLinkType.URL_OPEN_NEW)         _linktype = "3";
      else if (_menuitemlinktype == MenuItemLinkType.URL_OPEN_NEW_AMD_SUB) _linktype = "4";
      else if (_menuitemlinktype == MenuItemLinkType.URL_GOTO_AMD_SUB)     _linktype = "5";
      else _linktype = "1";
      
      string options = "{" + 
                        (Util.IsNullOrEmpty(_icon) ? "" : "icons:{primary:'" + _icon + "'},") + 
                        "menuitemid:'"      + _menuitemid + "'," +
                        "menuitemlinktype:" + _linktype   + ", " +
                        "noLinkInMenuThenRemoveParentLi:" + Util.netBoolToJSBool(_noLinkInMenuThenRemoveParentLi) + 
                        "}";
      
      this.addAttribute("spedmonButtonMenuItemLink", options, ATTR_JS_PAGE_LOAD_METHOD);

      // Is the button an option button in a step control or something similar

      this.cssClass = "ui-spedmon-button";

      if (!Util.IsNullOrEmpty(_text))      
        this.Controls.Add(new RawText(_text));
      
      base.Render(writer);
    }
  }

}

