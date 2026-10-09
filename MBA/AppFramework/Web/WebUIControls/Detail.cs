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

  /***************************************************************************
   * Detail */
  /**
   * Detail
   ***************************************************************************/

  public class Detail : WebUIControlDisplay
  {
    public Detail() : this("", 0, 0) { }
    public Detail(string message, int statuscode) : this(message, statuscode, 0) { }
    public Detail(string message, int statuscode, int duration)
      : base("li", false)
    {
      _message    = message;
      _statuscode = statuscode;
      _duration   = duration;
    }

    protected string _message;
    protected int _statuscode;
    protected int _duration;

    protected override void Render(HtmlTextWriter writer)
    {

      /*-------------------------------
       * Assign appropriate css and
       * image based on the status code
       *------------------------------*/

      string _cssClass = "";
      string _img = "";

      switch (_statuscode)
      {
        case Return.RET_SUCCESS:
          {
            _cssClass = Constants.CSS_DETAIL_GOOD;
            _img = Constants.IMG_GOOD_16;
            break;
          }
        case Return.RET_WARNING:
          {
            _cssClass = Constants.CSS_DETAIL_WARN;
            _img = Constants.IMG_ALERT_16;
            break;
          }
        case Return.RET_CRITICAL:
        case Return.RET_ERROR:
        case Return.RET_FATAL:
          {
            _cssClass = Constants.CSS_DETAIL_CRIT;
            _img = Constants.IMG_ERROR_16;
            break;
          }
        case Return.RET_INFO:
        default:
          {
            _cssClass = Constants.CSS_DETAIL_INFO;
            _img = Constants.IMG_INFO_16;
            break;
          }
      }

      /*-------------------------------
       * Pass the css selected to our
       * base
       *------------------------------*/

      this.cssClass = _cssClass;

      /*-------------------------------
       * Generate child controls
       * for the detail and add them
       *------------------------------*/

      string html = @"<a class=""" + _cssClass + @""" href="""">"
                  + @"<img class=""detail"" src=""" + _img + @"""/>"
                  + @"<span class=""" + _cssClass + @""">"
                  + _message
                  + @"</span></a>";

      RawHTML c = new RawHTML(html);
      base.Controls.Add(c);

      /*-------------------------------
       * Render detail
       *------------------------------*/

      base.Render(writer);

    }
  }

}

