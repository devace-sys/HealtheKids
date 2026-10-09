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
   * DateBoxHTML5 */
  /**
   * Input of dates
   * 
   * @param  name         name
   * @param  value        value
   ******************************************************************************/

  public class DateBoxHTML5: WebUIControlDataField
  {
    public DateBoxHTML5 ()                          : base("input", true )             {}
    public DateBoxHTML5 (string name, string value) : base("input", true, name, value) {}

    protected string  _minDate     = @"";      
    protected string  _maxDate     = @"";
    protected string  _placeHolder = @"";
	  public  string  minDate     { get { return _minDate;}  set { _minDate = value;}}
    public  string  maxDate     { get { return _maxDate;}  set { _maxDate = value;}}
    protected override void Render(HtmlTextWriter writer)
    {
      this.addAttribute("type", "date", ATTR_HTML_TAG);    
      
      if (!String.IsNullOrWhiteSpace(_minDate)) 
      { 
        /* TODO: Add code to convert min value to html5 format*/
        this.addAttribute("min", _minDate, ATTR_HTML_TAG);
      }
      
      if (!String.IsNullOrWhiteSpace(_maxDate)) 
      { 
        /* TODO: Add code to convert max value to html5 format*/
        this.addAttribute("max", _maxDate, ATTR_HTML_TAG);
      }
      
      /* TODO: Add code to convert value to html5 format*/
      base.Render(writer);
    }
  }
}

