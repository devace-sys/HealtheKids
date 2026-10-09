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
   * Sections */
  /**
   * Page sections
   **************************************************************************/

  public class Sections : WebUIControlContainer
  {
    public Sections() : base("div", false) { }
    protected string _options = "";

    protected override void Render(HtmlTextWriter writer)
    {
      _options = @"{autoHeight:false, collapsible:true, change:function(event,ui){}}";
      this.addAttribute("accordion", _options, ATTR_JS_PAGE_LOAD_METHOD);
      base.Render(writer);
      // $.scrollTo(ui.newContent,500);
    }
  }

}

