using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Smartsheet.Api;
using Smartsheet.Api.Models;
using Smartsheet.Api.OAuth;

namespace SmartsheetData
{
  /***************************************************************************
   * SSDataReport */
  /**
   * Static methods used to abstract working with Report objects from 
   * the Smartsheets API   
   ***************************************************************************/ 

  public class SSDataReport
  {
  
    /***************************************************************************
     * Get */
    /**
     * 
     ***************************************************************************/    
    
    public static Report Get (long? reportId)
    {
      return Get (SSDataCommon.Connect(),reportId);
    }
    
    /***************************************************************************
     * Get */
    /**
     * 
     ***************************************************************************/    

    public static Report Get (SmartsheetClient c, long? reportId)
    {
      if (!reportId.HasValue) return null;
      Report s = c.ReportResources.GetReport(reportId.Value,null,null,null);
      return s;
    }

    /***************************************************************************
     * ViewAsHtmlTable */
    /**
     * 
     ***************************************************************************/    
    
    public static string ViewAsHtmlTable (long? reportId)
    {
      return ViewAsHtmlTable (SSDataCommon.Connect(),reportId);
    }
    
    /***************************************************************************
     * ViewAsHtmlTable */
    /**
     * 
     ***************************************************************************/    

    public static string ViewAsHtmlTable (SmartsheetClient c, long? reportId)
    {
      StringBuilder sb = new StringBuilder();
      Report report = Get(c,reportId);

      sb.AppendFormat(@"<table id=""{0}"" class=""smartsheet smartsheet-report"">",reportId.Value);
      sb.Append(@"<table class=""smartsheet smartsheet-sheet"">");
      
      sb.AppendFormat(@"<caption>{0}</caption>",report.Name);
      
      sb.Append(@"<thead>");
      sb.Append(@"<tr>");      
      foreach(ReportColumn col in report.Columns)
      {
        sb.AppendFormat(@"<th>{0}</th>",col.Title);      
      }      
      sb.Append(@"</tr>");      
      sb.Append(@"</thead>");
      
      sb.Append(@"<tfoot>");
      sb.AppendFormat(@"<tr><th colspan=""{0}"">{1} rows</th></tr>",report.Columns.Count, report.Rows.Count);
      sb.Append(@"</tfoot>");
      
      sb.Append(@"<tbody>");
      
      foreach(ReportRow row in report.Rows)
      {
        sb.Append(@"<tr>");
        
        foreach(Cell cell in row.Cells)
        {
          sb.AppendFormat(@"<td>{0}</td>",cell.DisplayValue);
        }
        
        sb.Append(@"</tr>");
      }
      sb.Append(@"</tbody>");
      sb.Append(@"</table>");
      
      return sb.ToString();
    }          

  }
}
