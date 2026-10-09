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
   * Section */
  /**
   * Page section
   ****************************************************************************/

  public class Section : WebUIControlContainer
  {
    public Section() : base("div", false) { }

    protected override void Render(HtmlTextWriter writer)
    {
      string html = @"<h3><a id=""" + this.ID + @"""_header href=""#"">" + this.title + @"</a></h3>";
      RawHTML c = new RawHTML(html);
      this.addPreControl(c);
      this.ID = this.ID + "_content";
      base.Render(writer);
    }
  }

}

