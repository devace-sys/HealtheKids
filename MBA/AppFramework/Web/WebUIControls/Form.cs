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

  /****************************************************************************
   * Form */
  /**
   * Form
   * 
   * @param  url             url to submit to
   * @param  pvt             Is this form private (requires login)
   ****************************************************************************/

  public class Form : WebUIControlForm
  {
    public Form() : base() { }
    public Form(string url) : this(url, true) { }
    public Form(string url, bool pvt) : base(url, pvt) { }
  }

}

