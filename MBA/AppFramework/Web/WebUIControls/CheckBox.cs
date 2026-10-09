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
   * CheckBox */
  /**
   * Check box
   * 
   * @param  name             name
   * @param  value            value
   ****************************************************************************/

  public class CheckBox : WebUIControlDataField
  {
    public CheckBox ()                          : base ("input", true) { }
    public CheckBox (string name, bool value)   : base ("input", true, name, Util.boolToYesNo(value)) { this._value = value;}

    /*-------------------------------
     * Override value so we can pass
     * in a boolean.  Convert boolean
     * to string and pass to base
     * class.
     *------------------------------*/
    
    protected bool _value;
    public new bool value {get{return _value;} set {this._value = value; base.value = Util.boolToYesNo (value);}}

    /*-------------------------------
     * Override default value so we can
     * pass in a boolean.  Convert boolean
     * to string and pass to base
     * class.
     *------------------------------*/
    
    protected bool _defaultvalue;
    public new bool defaultValue {get{return _defaultvalue;} set {this._defaultvalue = value; base.defaultValue = Util.boolToYesNo (value);}}
    
    /*-------------------------------
     * Provide way to disable firing
     * the data selected event
     *------------------------------*/
    
    protected bool _firedataselected = true;
    public bool firedataselected {get{return _firedataselected;} set {_firedataselected = value;}}
     
    
    protected override void Render(HtmlTextWriter writer)
    {      
            
      /*-------------------------------
       * Render as a regular text input
       * We will enhance it into a 
       * checkbox in the browser
       *------------------------------*/
      
      this.addCssClass  (WEB_UI_FIELD_DATA_FLAG);

      string options = "{fireDataSelected:" + Util.netBoolToJSBool(_firedataselected) + "}";
      
      this.addAttribute ("type",            "text",  ATTR_HTML_TAG);
      this.addAttribute ("spedmonCheckBox", options, ATTR_JS_PAGE_LOAD_METHOD);      
      
      base.Render(writer);
    }
  }
}

