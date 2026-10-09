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
   * WebCustomReportStyleContent */
  /**
   * WebCustomReportStyleContent
   * 
   * @param  html            html to add
   ****************************************************************************/ 

  public class WebCustomReportStyleContentPrint:WebCustomReportStyleContent
  {
    public WebCustomReportStyleContentPrint () {    
    }
    
    protected override void Render (HtmlTextWriter writer) {
      writer.Write(@"<style type=""text/css"" media=""print"">");
	    base.Render(writer);
	    writer.Write(@"</style>");
	    this.Visible = false; /* Make sure this is only rendered once */
	  }  
  }
}

