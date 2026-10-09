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
   * CalendarBox */
  /**
   * Creates an on screen calender for the selection of multiple dates
   * 
   * @param  name         name
   * @param  value        value
   * @param  numMonths    Number of months to display
   * @param  multiDate    true  = Use multi date control
   *                      false = Single date control
   * @param  altField     2nd field to update
   ******************************************************************************/

  public class CalendarBox : WebUIControlDataField
  {
    public CalendarBox ()                          : base("input", true)             {}
    public CalendarBox (string name, string value) : base("input", true, name, value) {}

    protected string _minDate          = "-1y";
    protected string _maxDate          = "+0";
    protected string _defaultDate      = "-1y";    
    protected string _unavailableDates = "";
    
    public string minDate          { get { return _minDate;          } set { _minDate          = value; } }
    public string maxDate          { get { return _maxDate;          } set { _maxDate          = value; } }
    public string defaultDate      { get { return _defaultDate;      } set { _defaultDate      = value; } }    
    public string unavailableDates { get { return _unavailableDates; } set { _unavailableDates = value; } }
    
    protected override void Render(HtmlTextWriter writer)
    {
      this.addAttribute("type", "text", ATTR_HTML_TAG);
      this.addCssClass (WEB_UI_FIELD_DATA_DATE);
          
      string options = "{" + Util.createMessageString("minDate: '{0}', maxDate: '{1}', defaultDate:'{2}', unavailableDates:[{3}]",_minDate,_maxDate,_defaultDate,_unavailableDates) + "}";
        
      this.addAttribute("spedmonCalendarbox", options, ATTR_JS_PAGE_LOAD_METHOD);      
      base.Render(writer);
    }
  }
}

