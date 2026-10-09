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
   * DateBoxRangeDefaultType */
  /**
   * Various types of default values this control
   ****************************************************************************/

  public enum DateBoxRangeDefaultType { LITERAL , RANGE_CONSTANT };
  
  /**************************************************************************
   * DateBoxRange */
  /**
   * Input range of dates based on filament group's date range picker control.
   * 
   * @param  name             name
   * @param  value            value
   ****************************************************************************/


  public class DateBoxRange : WebUIControlDataField
  {
    public DateBoxRange ()                          : base("input", true ) { }
    public DateBoxRange (string name, string value) : base("input", true, name, value) { }

    // TODO: would be nice if we had settable attributes here for startdate and enddate,
    // as separate setters.
    
    protected DateBoxRangeDefaultType  _defaultType = DateBoxRangeDefaultType.LITERAL;       
    public    DateBoxRangeDefaultType  defaultType {get {return _defaultType;} set {_defaultType = value;}}
    
    public new string  defaultValue  { /* We use an HTML5 attribute data-? (? = user defined) to pass the default value */
                                      get { return (string) this.findAttribute("data-default-value"); }
                                      set { this.addOrReplaceAttribute("data-default-value", value, ATTR_HTML_TAG);}}

    protected bool  _showOK = true;
    public  bool    showOK  { get { return _showOK;}              set { _showOK            = value;} }
    protected string generateDefaultDateInitialValue (DateBoxRangeDefaultType defaultType, string defaultValue)
    {      
      /*-------------------------------
       * defaultValue is a date range
       * literal:
       * 
       * mm/dd/yyyy - mm/dd/yyyy
       *------------------------------*/
      
      if (defaultType == DateBoxRangeDefaultType.LITERAL)
      {
        /*-------------------------------
         * Make sure literal value 
         * is valid
         *------------------------------*/
        
        Validate.reqDateRange(defaultValue, @"Please check your code.  Invalid default date range literal.");
        return defaultValue;
      }
      
      /*-------------------------------
       * defaultValue is a predefined
       * constant
       *------------------------------*/

      else if (defaultType == DateBoxRangeDefaultType.RANGE_CONSTANT)
      {      
        
        int    when  = Convert.ToInt32(defaultValue);
        string range = Util.GenerateDateRange(when);        
        return range;
      }
      
      /*-------------------------------
       * Unknown
       *------------------------------*/
      
      return "";
    }

    protected override void Render(HtmlTextWriter writer)
    {
      
      /*-------------------------------
       * If we are using a default
       * value
       *------------------------------*/

      if (this.useDefaultValue)
      {        
        /*-------------------------------
         * Generate a date range 
         * based on defaultType
         * and defaultValue
         *------------------------------*/
               
        string dateText = this.generateDefaultDateInitialValue(this.defaultType, this.defaultValue);
        
        /*-------------------------------
         * Set our value and default 
         * value
         *------------------------------*/
                
        this.value = dateText;
        this.defaultValue = dateText;
      }
      
      // Provided default title if title is not specified
      
      this.title = "Enter or Select a Date Range";
      this.addAttribute("type", "text", ATTR_HTML_TAG);
      this.addCssClass (WEB_UI_FIELD_DATA_DATE_RANGE);

      string options = @"{"
                     + @"showOK: " + Util.netBoolToJSBool(_showOK)
                     + @"}";
      this.addAttribute("spedmonDateRangeBox", options, ATTR_JS_PAGE_LOAD_METHOD);
      base.Render(writer);
    }
  }  

}

