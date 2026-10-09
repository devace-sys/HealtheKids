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
   * Button */
  /**
   * Button
   * 
   * @param  onclick         action to take when button is clicked
   * @param  icon            jquery ui icon (ui-icon-x)
   ****************************************************************************/

  public class Button : WebUIControlCommand
  {
    public Button() : base("button", false) { }

    private string _icon                = "";
    private string _faIcon              = "";
    private string _text                = "";
    private int    _priority            = 0;
    private bool   _showIconOnly        = false;
    private bool   _applyDefautStyles   = true;

    /***************************************************************************
     * icon */
    /**
     * jQuery UI icon class to use (ui-icon-x)
     ***************************************************************************/   
    
    public string icon              { get { return _icon;              } set { _icon = value.ToLower(); } }
    public string faIcon            { get { return _faIcon;              } set { _faIcon = value.ToLower(); } }
    public bool   showIconOnly      { get { return _showIconOnly;      } set { _showIconOnly = value;} }
    public bool   applyDefautStyles { get { return _applyDefautStyles; } set { _applyDefautStyles = value;} }
    

    /***************************************************************************
     * text */
    /**
     * Button text to use if no text is provided between the button tags
     ***************************************************************************/   
    
    public string text { get { return _text; } set { _text = value; } }

    /***************************************************************************
     * priority */
    /**
     * 0 = none
     * 1 = Primary
     * 2 = Secondary
     ***************************************************************************/   
    
    public int priority { get { return _priority; } set { _priority = value; } }
    
    /***************************************************************************
     * onclick */
    /**
     * Assigns on click
     ***************************************************************************/   

    public string onclick
    {
      get { return (string)this.findAttribute("click"); }
      set { this.addAttribute("click", value, ATTR_JS_PAGE_LOAD_EVENT_ASSIGN); }
    }
    
    /***************************************************************************
     * onfocusin */
    /**
     * Assigns on focus in
     ***************************************************************************/   
    public string onfocusin
    {
      get { return (string)this.findAttribute("focusin"); }
      set { this.addAttribute("focusin", value, ATTR_JS_PAGE_LOAD_EVENT_ASSIGN); }
    }

    protected override void Render(HtmlTextWriter writer)
    {
      this.addAttribute("type", "button", ATTR_HTML_TAG);
      
      if (_excludeFromTabIndex == true)
      {
        this.addAttribute("tabindex", "-1", ATTR_HTML_TAG);
      }

      if (_applyDefautStyles == true) 
      { 

        string options = "{" 
                     + (Util.IsNullOrEmpty(_icon) ? "" : "icons:{primary:'" + _icon + "'}") 
                     + ((_showIconOnly)           ? ",text:false":"")
                     + "}";
        this.addAttribute("button", options, ATTR_JS_PAGE_LOAD_METHOD);
        
        // Is the button an option button in a step control or something similar
        
        this.cssClass = "ui-spedmon-button";
        
        if (_priority == 1) this.addCssClass(@"ui-priority-primary");
        if (_priority == 2) this.addCssClass(@"ui-priority-secondary");
        
        if (!Util.IsNullOrEmpty(_text))
        {
          this.Controls.Add(new RawText(_text));
        }
      }
      else
      {
        this.addChildControl(new RawHTML(@"<i class='ui-spedmon-data-entry-fa-icon fas " + _faIcon +  @"'></i>"));
        this.cssClass = "ui-spedmon-button-blank"; // remove any button styling
      }
      
      base.Render(writer);
    }
  }

}

