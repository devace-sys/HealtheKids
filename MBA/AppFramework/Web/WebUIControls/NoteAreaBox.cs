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
   * NoteAreaBox */
  /**
   * Multi-line note box
   * 
   * @param  name             name
   * @param  value            value
   ****************************************************************************/ 
  
  public class NoteAreaBox:WebUIControlDataField
  {
       
    /*-------------------------------
     * Note: We do not store this
     * controls value in an 
     * attribute.  Therefore we
     * override the value property.
     *------------------------------*/
 
    public NoteAreaBox ()                          : base("textarea", false ){}
    public NoteAreaBox (string name, string value) : base("textarea", false, name) {this._value = value;}
    
    protected  string   _value  = "";         
    new public string   value     { get { return _value;  } set { _value = value;} }


    protected bool _showOKButton = true;
    protected bool _autoSize     = true;

    public bool showOKButton { get { return _showOKButton;} set { _showOKButton = value; } }
    public bool autoSize     { get { return _autoSize;}     set { _autoSize = value; }}
    
    /***************************************************************************
     * setParentStepLabel */
    /**
     * Finds ctrls parent step control (if it exists) sets its label using 
     * the value of this control
     * 
     * @param  labelText       text to display in label
     * @return                 Step control or null
     ***************************************************************************/   

    public new Step setParentStepLabel ()
    {
      string stpLbl = @"";
      if (!String.IsNullOrEmpty(_value)) stpLbl = Util.previewString(_value);
      return setParentStepLabel(stpLbl);
    }

    protected override void Render(HtmlTextWriter writer)
    {
      string opts = "{" 
                  + "showOKButton:" + Util.netBoolToJSBool(_showOKButton) 
                  + ",autoSize:"   + Util.netBoolToJSBool(_autoSize) 
                  + "}";
      
      //this.addAttribute("rows",        "2",        ATTR_HTML_TAG);
      //this.addAttribute("cols",        "80",       ATTR_HTML_TAG);
      this.addAttribute("placeholder", this.title, ATTR_HTML_TAG);
      //this.addAttribute("wrap",        "hard",     ATTR_HTML_TAG);
      
      this.addCssClass (WEB_UI_FIELD_DATA_TEXT_AREA);

      this.addAttribute("spedmonNoteAreaBox",opts,ATTR_JS_PAGE_LOAD_METHOD);
      this.addChildControl(new RawText(_value));
      base.Render(writer);      
    }
  }
}

