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
  * TextAreaBox */
  /**
  * Multiline text entry
  * 
  * @param  name             name
  * @param  value            value
  ****************************************************************************/ 
  
  public class TextAreaBox:WebUIControlDataField
  {
       
    /*-------------------------------
     * Note: We do not store this
     * controls value in an 
     * attribute.  Therefore we
     * override the value property.
     *------------------------------*/
 
    public TextAreaBox ()                          : base("textarea", false ){}
    public TextAreaBox (string name, string value) : base("textarea", false, name) {this._value = value;}
    
    protected  string   _value  = "";         
    new public string   value     { get { return _value;  } set { _value = value;} }
        
    /**************************************************************************
     * setParentStepLabel */
    /**
     * Sets parent step label if it exists with selected name (if provided)
     **************************************************************************/

    public new Step setParentStepLabel()
  	{
  	  string textPreview = Util.previewString(this.value);
  	  return this.setParentStepLabel (textPreview );
  	}
    
    protected override void Render(HtmlTextWriter writer)
    {
      string opts = "{}";

      this.addAttribute("rows",        "10",       ATTR_HTML_TAG);
      this.addAttribute("cols",        "10",       ATTR_HTML_TAG);
      this.addAttribute("placeholder", this.title, ATTR_HTML_TAG);
      
      this.addCssClass (WEB_UI_FIELD_DATA_TEXT_AREA);

      this.addAttribute("spedmonTextAreaBox",opts,ATTR_JS_PAGE_LOAD_METHOD);
      this.addChildControl(new RawText(_value));
      base.Render(writer);      
    }
  }
}

