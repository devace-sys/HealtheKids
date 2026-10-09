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
   * SSDataSheets */
  /**
   * Static methods used to abstract working with the Smartsheets API   
   ***************************************************************************/ 

  public class SSDataSheets
  {
  
    /***************************************************************************
     * GetAll */
    /**
     * Returns a List<Sheet> object of all of the Smartsheet Sheet objects 
     * the SmartsheetClient object opened using our default API key has access
     * to
     ***************************************************************************/  

    public static List<Sheet> GetAll ()
    {
      return GetAll(SSDataCommon.Connect());
    }
    
    /***************************************************************************
     * GetAll */
    /**
     * Returns a List<Sheet> object of all of the Smartsheet Sheet objects 
     * the SmartsheetClient object provided has access to.
     * 
     * See: http://smartsheet-platform.github.io/api-docs/#list-sheets
     ***************************************************************************/  

    public static List<Sheet> GetAll (SmartsheetClient c)
    {	      
      PaginatedResult<Sheet> pr = c.SheetResources.ListSheets(null,null);
      List<Sheet> l = pr.Data.ToList<Sheet>();
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
     
    public static string ViewAsHTMLTable (List<Sheet> sheets)
    {
      
      StringBuilder sb = new StringBuilder();
      
      sb.Append(@"<table class=""smartsheet smartsheet-links"">");            
      sb.Append(@"<caption>Sheets</caption>");
      sb.Append(@"<thead>");
      sb.Append(@"<tr>");
      sb.Append(@"<th>Name</th>");
      sb.Append(@"<th>Data Extract</th>");
      sb.Append(@"<th>Original Sheet</th>");
      sb.Append(@"</tr>");
      sb.Append(@"</thead>");   
               
      sb.Append(@"<tfoot>");
      sb.Append(@"<tr>");
      sb.AppendFormat(@"<th colspan=""3"">{0} Sheets Available</th>",sheets.Count);
      sb.Append(@"</tr>");
      sb.Append(@"</tfoot>");      
      
      sb.Append(@"<tbody>");
      
      foreach(Sheet sheet in sheets)
      {                       
        
        string ourUrl = MBA.HttpApplication.createLink( "sbs_all_smartsheet.aspx"
                                                        , true
                                                        , new NameValue(SSDataCommon.PARM_SS_DATA_CLASS, SSDataCommon.VALUE_SS_DATA_CLASS_SHEET)
                                                        , new NameValue(SSDataCommon.PARM_SS_DATA_UID, sheet.Id.ToString()));
                                                          
        sb.Append(@"<tr>");
        sb.AppendFormat(@"<td>{0}</td>",sheet.Name);
        sb.AppendFormat(@"<td><a target=""_blank"" href=""{0}"">Click Here</a></td>",ourUrl);
        sb.AppendFormat(@"<td><a target=""_blank"" href=""{0}"">Click Here</a></td>",sheet.Permalink);
        sb.Append(@"</tr>");
      }
      sb.Append(@"</tbody>");
      sb.Append(@"</table>");

      return sb.ToString();
    }
      
  }
}
