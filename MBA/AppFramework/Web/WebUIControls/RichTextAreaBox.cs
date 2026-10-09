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
   * RichTextAreaBox */
  /**
   * Multiline text entry
   * 
   * @param  name             name
   * @param  value            value
   ****************************************************************************/ 
  
  public class RichTextAreaBox:WebUIControlDataFields
  {
       
    /*-------------------------------
     * Note: We do not store this
     * controls value in an 
     * attribute.  Therefore we
     * override the value property.
     *------------------------------*/
 
    public RichTextAreaBox ()                          : base("textarea", false ){}
    public RichTextAreaBox (string name, string value) : base("textarea", false, name) {this._value = value;}
    
    protected  string   _value  = "";         
    new public string   value     { get { return _value;  } set { _value = value;} }

    protected bool _showControls = true;
    public bool showControls { get { return _showControls;} set {_showControls = value;}}
 
    protected override void Render(HtmlTextWriter writer)
    {
      string opts = "{showControls:" + Util.netBoolToJSBool(_showControls) + "}";
           
      this.addAttribute("spedmonRichTextAreaBox",opts,ATTR_JS_PAGE_LOAD_METHOD);
      this.addChildControl(new RawText(_value));
      base.Render(writer);      
    }
  }
}

