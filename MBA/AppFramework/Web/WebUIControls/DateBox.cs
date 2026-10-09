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
   * Datebox */
  /**
   * Input of dates
   * 
   * @param  name         name
   * @param  value        value
   * @param  numMonths    Number of months to display
   * @param  multiDate    true  = Use multi date control
   *                      false = Single date control
   * @param  altField     2nd field to update
   ******************************************************************************/

  public class DateBox : WebUIControlDataField
  {
    public DateBox ()                          : base("input", true )             {}
    public DateBox (string name, string value) : base("input", true, name, value) {}

    protected int     _defaultType        = 0;
    protected int     _numMonths          = 1;
    protected int     _monthsOffset       = 0;
    protected string  _dateFormat         = @"mm/dd/yy";
    protected string  _minDate            = "";      
    protected string  _maxDate            = "+0";    // Restricts max date to today
    protected bool    _multiDate          = false;    
    protected string  _altField           = "";   
    protected string  _onDateSelectSingle = "";
    protected string  _onDateSelectMulti  = "";
    protected string  _onDateClear        = "";
    protected bool    _showOK             = true;
    protected string  _multiDateAltFieldUseFirstOrLastSelected = @"first";
    protected bool    _useVisibleWorkaround = true;
    public  int     defaultType        { get { return _defaultType;}         set { _defaultType = value;              }}
    public  int     numMonths          { get { return _numMonths; }          set { if (value > 1) _numMonths = value; }}
    public  int     monthsOffset       { get { return _monthsOffset; }       set { _monthsOffset = value;}      }
    public  string  minDate            { get { return _minDate;}             set { _minDate      = value;}}
    public  string  maxDate            { get { return _maxDate;}             set { _maxDate      = value;}}
    public  string  dateFormat         { get { return _dateFormat;}          set { _dateFormat   = value;}}
    public  bool    multiDate          { get { return _multiDate;}           set {_multiDate = value;}          }
    public  string  altField           { get { return _altField;}            set {_altField  = value;}          }
    public  string  onDateSelectSingle { get { return _onDateSelectSingle;}  set {_onDateSelectSingle = value;} }
    public  string  onDateSelectMulti  { get { return _onDateSelectMulti;}   set {_onDateSelectMulti  = value;} }
    public  string  onDateClear        { get { return _onDateClear; }        set { _onDateClear       = value;} }
    public  bool    showOK             { get { return _showOK;}              set { _showOK            = value;} }
    public  bool    useVisibleWorkaround { get { return _useVisibleWorkaround;} set { _useVisibleWorkaround = value;} }
    public  string  multiDateAltFieldUseFirstOrLastSelected { get { return _multiDateAltFieldUseFirstOrLastSelected;  }
                                                              set { _multiDateAltFieldUseFirstOrLastSelected = value; }
                                                            }

    protected string generateDefaultDateInitialValue (int defaultType, string defaultValue)
    {
      
      if (defaultType == 0)
      {
        // defaultValue is a date literal
        return defaultValue;
      }
      else if (defaultType == 1)
      {
      
        // defaultValue is a predefined constant for start dates
        
        int dateType = Convert.ToInt32(defaultValue);
        return Util.generateStartDateStr(dateType);
      }
      else if (defaultType == 2)
      {
        // defaultValue is a predefined constant for end dates
      }
      else if (defaultType == 10)
      {
        // defaultValue is a date expression
        return Util.EvaluateDateExpression(defaultValue).ToShortDateString();
      }      
      else if (defaultType == 11)
      {
        // defaultValue is a date expression but the initial value should be blank
        return "";
      }

      return "";
   }

    protected override void Render(HtmlTextWriter writer)
    {
      this.addAttribute("type", "text", ATTR_HTML_TAG);
      this.addCssClass (WEB_UI_FIELD_DATA_DATE);
      
      string dateText = "";

      if (this.useDefaultValue)
      {  
        // TODO: Multidate default value.  Should allow for passing in multiple values... possibly as
        // comma seperated values.  mm/dd/yyyy, mm/dd/yyyy, etc.
        
        if (multiDate) 
          throw new Warning("Default values are not supported for multi date controls yet");

        // Generate date value based on default type and default value
        
        dateText = this.generateDefaultDateInitialValue(this.defaultType, this.defaultValue);
        
        if (Util.IsNullOrEmpty (this.value)) 
           // If a value is not passed in use the generated date value as the initial value
          this.value = dateText;
        else
          // Otherwise use the value
           dateText = this.value;        
      }
      else
      {
        this.defaultValue = "";
        dateText          = this.value;
      }

      string options = "{";
      
      options = options + "multidate:"            + Util.netBoolToJSBool(_multiDate) + ",";
      options = options + "showOK:"               + Util.netBoolToJSBool(_showOK) + ",";    
      options = options + "useVisibleWorkaround:" + Util.netBoolToJSBool(_useVisibleWorkaround) + ",";    
      options = options + "dateText:'"    + dateText                 + "',";
      options = options + "defaultDate:'" + this.defaultValue        + "',";
      options = options + "dateFormat:'"  + this._dateFormat         + "',";
      options = options + "minDate:'"     + this._minDate            + "',";
      options = options + "maxDate:'"     + this._maxDate            + "',";
      options = options + "numMonths:"    + _numMonths.ToString()    + @",";
      options = options + "monthsOffset:" + _monthsOffset.ToString() + @",";
      options = options + "onDateClear:function(){"                      + _onDateClear.ToString() + @"},";
      options = options + "onDateSelectSingle:function(dateText, inst){" + _onDateSelectSingle     + @"},";
      options = options + "onDateSelectMulti:function(dates){"           + _onDateSelectMulti      + @"},";
      
      options = options + "showAnim:'',";
      
      // Alternative field
      if (!Util.IsNullOrEmpty(_altField))
      {
        options = options + "altField:'" + _altField + "',";        
      }
      
      options = options + @"yearRange:'c-25:c',";
      options = options + @"multiDateAltFieldUseFirstOrLastSelected:'" + _multiDateAltFieldUseFirstOrLastSelected + @"'}";
      
      this.addAttribute("spedmonDatebox", options, ATTR_JS_PAGE_LOAD_METHOD);      
      base.Render(writer);
    }
  }
}

