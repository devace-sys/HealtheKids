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
   * Dialog */
  /**
   * Dialog box
   * 
   * @param  id        Dialog id
   * @param  title     Dialog title
   *
   * Creates the required markup for the dialog control.
   * Show the dialog by calling $.spedmonWebUI.dialog
   ***************************************************************************/

  public class Dialog : WebUIControlDisplay
  {
    public Dialog() : this("", "") { }
    public Dialog(string id, string title): base("div", false)
    {
      this.ID       = id;
      this.title    = title;
      this.cssClass = "ui-spedmon-dialog";
      this.addAttribute("hide", "", ATTR_JS_PAGE_LOAD_METHOD);
    }
  }

}

