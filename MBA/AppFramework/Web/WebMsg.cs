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
   * WebMsgNotice */
  /**
   * Custom control for displaying a notice
   ***************************************************************************/
 
  public class WebMsgNotice:Control
  {
    protected override void Render(HtmlTextWriter writer)
    {
      writer.Write(@"<div class=""message message-notice"">");
      base.Render(writer);
      writer.Write(@"</div>");
    }
  }

  /***************************************************************************
   * WebMsgProblem */
  /**
   * Custom control for displaying the problem text
   ***************************************************************************/

  public class WebMsgProblem:Control
  {
   protected override void Render(HtmlTextWriter writer)
    {
      writer.Write(@"<div class=""message message-problem"">");
      writer.Write(@"<h2>Problem : </h2>");
      base.Render(writer);
      writer.Write(@"</div>");
    }
  }
  
 /***************************************************************************
  * WebMsgSolution */
  /**
  * Custom control for displaying a proposed solution for the problem
  ***************************************************************************/
  
  public class WebMsgSolution:Control
  {
    protected override void Render(HtmlTextWriter writer)
    {
      writer.Write(@"<div class=""message message-solution"">");
      writer.Write(@"<h2>Solution : </h2>");
      base.Render(writer);
      writer.Write(@"</div>");
    }
  }
  
  /***************************************************************************
   * WebMsg */
  /**
   * Base class for all web message pages
   * These are stand alone pages that are designed to display exceptions
   * downtime notices, etc to the user
   ***************************************************************************/

  public abstract class WebMsg: System.Web.UI.Page
	{     
    /*-------------------------------
    * Constructors
    *------------------------------*/
 
    public WebMsg ()
    {
    }
    
    protected string _msg = "";
    
    /*-------------------------------
    * Methods
    *------------------------------*/
    
    protected override void Render(HtmlTextWriter writer)
    {
      
     
      /*===============================
       * Render Document Start and Head
       *===============================*/ 
      
      writer.WriteLine(@"<!doctype html>");
      writer.Write(@"<html>");
      writer.Write(@"<head>");
                  
      /*===============================
       * META
       *===============================*/ 

      writer.Write(@"<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"">");
      writer.Write(@"<meta name=""viewport"" content=""width=device-width, initial-scale=1"">");
      writer.Write(@"<meta http-equiv=""X-UA-Compatible"" content=""IE=edge,chrome=1"">");
      writer.Write(@"<meta name=""robots"" content=""noindex, nofollow"">");            
      writer.Write(@"<title>" + MBA.Constants.APP_NAME + @"</title>");

      writer.Write(@"<link type=""text/css"" rel=""stylesheet"" href=""web-ui-3/mba/css/screen.css"">");
      writer.Write(@"<link type=""text/css"" rel=""stylesheet"" href=""web-ui-3/mba/css/screen-message.css"">");
      

      writer.Write(@"</head>");

      writer.Write(@"<body>");
      
      writer.Write (@"<div id=""app-content"">");
      writer.Write(@"<header id=""page-header"">");
      
      writer.Write(@"<img src=""web-ui-3/mba/css/app-icons/branding.svg"" alt=""logo"" />");
      
      if (!Util.IsNullOrEmpty(_msg))
      { 
        writer.Write(@"<h1>{0}</h1>", _msg);
      }
      
      writer.Write(@"</header>");

      writer.Write(@"<main id=""page-content"">");
            
      // Expects to see problem/solution
      
      base.Render(writer);

      writer.Write(@"</main>");
      writer.Write(@"</div>");
      writer.Write(@"</body>");
      writer.Write(@"</html>");
    }
	}
}
