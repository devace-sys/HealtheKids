using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace MBA
{
  /***************************************************************************
   * WebCustomReport */
  /**
   * Base class for custom HTML reports
   ***************************************************************************/

  public class WebCustomReport: WebApp
  {     
    public WebCustomReport():this(null){}
    
    public WebCustomReport(params string[] permittedroles):base("",permittedroles)
    {
    }
    
    protected override void Render(HtmlTextWriter writer)
    {  
	    
	    writer.Write(@"<!doctype html>");
	    writer.Write(@"<html dir=""ltr"" lang=""en-US"">");
	    writer.Write(@"<head>");
	    writer.Write(@"<meta name=""viewport"" content=""width=device-width, initial-scale=1"">");
      writer.Write(@"<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"">");
	    writer.Write(@"<title>");
	    writer.Write(@"Report");
	    writer.Write(@"</title>");
	    	    
	    foreach (Control c in this.Controls) {
	      if ((c.GetType()) == typeof(WebCustomReportStyleContentAll)) {
	        c.RenderControl(writer);
	        break;  
	      }
	    }	    

	    foreach (Control c in this.Controls) {
	      if ((c.GetType()) == typeof(WebCustomReportStyleContentScreen)) {
	        c.RenderControl(writer);
	        break;  
	      }
	    }	    
	    
	    foreach (Control c in this.Controls) {
	      if ((c.GetType()) == typeof(WebCustomReportStyleContentPrint)) {
	        c.RenderControl(writer);
	        break;  
	      }
	    }	    

	    writer.Write(@"</head>");
	    writer.Write(@"<body>");
	  
	    base.Render(writer);  

	    writer.Write(@"</body>");
	    writer.Write(@"</html>");
    }

  }
}
