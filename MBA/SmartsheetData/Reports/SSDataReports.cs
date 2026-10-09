using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Smartsheet.Api;
using Smartsheet.Api.Models;
using Smartsheet.Api.OAuth;
using System.Web;
using MBA;

namespace SmartsheetData
{
  /***************************************************************************
   * SSDataReports */
  /**
   * Static methods used to abstract working with Report objects from 
   * the Smartsheets API    
   ***************************************************************************/ 

  public class SSDataReports
  {
  
    /***************************************************************************
     * GetAll */
    /**
     * Returns a List<Report> object of all of the Smartsheet Report objects 
     * the SmartsheetClient object opened using our default API key has access
     * to
     ***************************************************************************/  

    public static List<Report> GetAll ()
    {
      return GetAll(SSDataCommon.Connect());
    }
    
    /***************************************************************************
     * GetAll */
    /**
     * Returns a List<Report> object of all of the Smartsheet Report objects 
     * the SmartsheetClient object provided has access to.
     * 
     * See: http://smartsheet-platform.github.io/api-docs/#list-reports
     ***************************************************************************/  

    public static List<Report> GetAll (SmartsheetClient c)
    {	      
      PaginatedResult<Report> pr = c.ReportResources.ListReports(null);
      
      List<Report> l = pr.Data.ToList<Report>();
      return l;
    }
    
    /***************************************************************************
     * ViewAllAsHTMLTable */
    /**
     * 
     ***************************************************************************/  
    
    public static string ViewAllAsHTMLTable ()
    {
      return ViewAllAsHTMLTable (SSDataCommon.Connect());
    }
    
    /***************************************************************************
     * ViewAllAsHTMLTable */
    /**
     * 
     ***************************************************************************/  
    
    public static string ViewAllAsHTMLTable (SmartsheetClient c)
    {
      return ViewAsHTMLTable(GetAll(c));
    }
        
    /***************************************************************************
     * ViewAsHTMLTable */
    /**
     * 
     ***************************************************************************/  
     
    public static string ViewAsHTMLTable (List<Report> reports)
    {
      StringBuilder sb = new StringBuilder();
      
      sb.Append(@"<table class=""smartsheet smartsheet-links"">");            
      sb.Append(@"<caption>Reports</caption>");
      sb.Append(@"<thead>");
      sb.Append(@"<tr>");
      sb.Append(@"<th>Name</th>");
      sb.Append(@"<th>Data Extract</th>");
      sb.Append(@"<th>Original Sheet</th>");
      sb.Append(@"</tr>");
      sb.Append(@"</thead>");   
               
      sb.Append(@"<tfoot>");
      sb.Append(@"<tr>");
      sb.AppendFormat(@"<th colspan=""3"">{0} reports Available</th>",reports.Count);
      sb.Append(@"</tr>");
      sb.Append(@"</tfoot>");      
      
      sb.Append(@"<tbody>");
      
      foreach(Report report in reports)
      {                       
        
        string ourUrl = MBA.HttpApplication.createLink( "sbs_all_smartsheet.aspx"
                                                        , true
                                                        , new NameValue(SSDataCommon.PARM_SS_DATA_CLASS, SSDataCommon.VALUE_SS_DATA_CLASS_REPORT)
                                                        , new NameValue(SSDataCommon.PARM_SS_DATA_UID, report.Id.ToString()));
                                                          
        sb.Append(@"<tr>");
        sb.AppendFormat(@"<td>{0}</td>",report.Name);
        sb.AppendFormat(@"<td><a target=""_blank"" href=""{0}"">Click Here</a></td>",ourUrl);
        sb.AppendFormat(@"<td><a target=""_blank"" href=""{0}"">Click Here</a></td>",report.Permalink);
        sb.Append(@"</tr>");
      }
      sb.Append(@"</tbody>");
      sb.Append(@"</table>");

      return sb.ToString();
    }
         
  }
}
