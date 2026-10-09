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
   * YesNo */
  /**
   * Permits the entry of yes or no only.
   ****************************************************************************/

  public class YesNo : WebUIControlDataField
  {
    public YesNo ()                          : base("input", true)              {}
    public YesNo (string name, string value) : base("input", true, name, value) {}
    
    protected override void Render(HtmlTextWriter writer)
    {
      this.addCssClass(WEB_UI_FIELD_DATA_BOOL);
      this.addAttribute("spedmonYesNo", "", ATTR_JS_PAGE_LOAD_METHOD);
      base.Render(writer);
    }
  }

}

