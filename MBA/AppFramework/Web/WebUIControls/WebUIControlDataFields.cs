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
   * WebUIControlDataFields */
  /**
   * Base class for all controls that collect multiple data items from users
   * 
   * @param  name            name
   * @param  value           value
   *****************************************************************************/

  public abstract class WebUIControlDataFields : WebUIControlData
  {
    public WebUIControlDataFields (string tag, bool noclosetag )                           : base(tag, noclosetag, false) { }
    public WebUIControlDataFields (string tag, bool noclosetag, string name)               : base(tag, noclosetag, false) { this.name = name; }
    public WebUIControlDataFields (string tag, bool noclosetag, string name, string value) : base(tag, noclosetag, false) { this.name = name; this.value = value; }

    
    protected override void Render(HtmlTextWriter writer)
    {
      if (Util.IsNullOrEmpty(this.title)) throw new Critical("title required");     
      base.Render(writer);
    }
  }
}

