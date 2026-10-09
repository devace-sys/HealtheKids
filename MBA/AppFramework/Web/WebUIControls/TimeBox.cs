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
   * TimeBox */
  /**
   * Permits the entry of times only
   * 
   * Sample Usage
   * 
   * <Spedmon:TimeBox ID="startTime" name="startTime" title="Start Time" runat="server" />
   * 
   *************************************************************************/

  public class TimeBox : WebUIControlDataField
  {
    public TimeBox ()                          : base("input", true ) { }
    public TimeBox (string name, string value) : base("input", true, name, value) { }


    protected string  _minTime            = "";      
    protected string  _maxTime            = "";
    protected int     _defaultType        = 0;
    protected bool    _showOK             = true;
    protected bool    _dontCreateIfHidden = true;
    
    public    string  minTime     { get { return _minTime;     } set { _minTime     = value; }}
    public    string  maxTime     { get { return _maxTime;     } set { _maxTime     = value; }}
    public    int     defaultType { get { return _defaultType; } set { _defaultType = value; }}
    public    bool    showOK      { get { return _showOK;      } set { _showOK      = value; }}
    
    public    bool    dontCreateIfHidden { get { return _dontCreateIfHidden; } set { _dontCreateIfHidden = value; }}
    
    protected string generateDefaultTimeInitialValue (int defaultType, string defaultValue)
    {
      
      if (defaultType == 0)
      {
        // defaultValue is a date literal
        return defaultValue;
      }

      else if (defaultType == 1)
      {      
        // defaultValue is a predefined constant for start times
        
        int timeType = Convert.ToInt32(defaultValue);
        return Util.generateStartTimeStr(timeType);
      }
      else if (defaultType == 2)
      {
        // defaultValue is a predefined constant for end times
      }
      else if (defaultType == 10)
      {
        // defaultValue is a time expression
        return "";
      }      
      else if (defaultType == 11)
      {
        // defaultValue is a time expression but the initial value should be blank
        return "";
      }

      return "";
   }
    
    protected override void Render(HtmlTextWriter writer)
    {
      
      string timeText = "";

      if (this.useDefaultValue)
      {  
      
        // Generate date value based on default type and default value
        
        timeText = this.generateDefaultTimeInitialValue(this.defaultType, this.defaultValue);
        
        if (Util.IsNullOrEmpty (this.value)) 
           // If a value is not passed in use the generated date value as the initial value
          this.value = timeText;
        else
          // Otherwise use the value
           timeText = this.value;        
      }
      else
      {
        this.defaultValue = "";
        timeText          = this.value;
      }
      
      string minTimePrm  = @"";
      string maxTimePrm  = @"";
      string timeTextPrm = @"";     
      string dfltValPrm  = @"";
      string showOKPrm   = @"";
      string dontCreateIfHiddenPrm = @"";
      
      minTimePrm            = String.Format(@"minTime:{0}"  , String.IsNullOrEmpty(_minTime) ? "null" : "'" + _minTime + "'");
      maxTimePrm            = String.Format(@",maxTime:{0}" , String.IsNullOrEmpty(_maxTime) ? "null" : "'" + _maxTime + "'");

      timeTextPrm           = String.Format(@",timeText:'{0}'",    timeText);
      dfltValPrm            = String.Format(@",defaultTime:'{0}'", this.defaultValue); 

      showOKPrm             = String.Format(@",showOK:{0}",            Util.netBoolToJSBool(this._showOK));
      dontCreateIfHiddenPrm = String.Format(@",dontCreateIfHidden:{0}", Util.netBoolToJSBool(this._dontCreateIfHidden));
      
      string prms =   @"{" 
                      + minTimePrm 
                      + maxTimePrm
                      + timeTextPrm
                      + dfltValPrm
                      + showOKPrm
                      + dontCreateIfHiddenPrm
                      + @"}";

      this.addAttribute("type", "text", ATTR_HTML_TAG);
      this.addCssClass (WEB_UI_FIELD_DATA_TIME);
      this.addAttribute("spedmonTimebox", prms, ATTR_JS_PAGE_LOAD_METHOD);
      base.Render(writer);
    }
  }

}

