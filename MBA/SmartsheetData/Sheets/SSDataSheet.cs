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
   * SSDataSheet */
  /**
   * Static methods used to abstract working with the Smartsheets API   
   ***************************************************************************/ 

  public class SSDataSheet
  {
  
    /***************************************************************************
     * Get */
    /**
     * 
     ***************************************************************************/    
    
    public static Sheet Get (long? sheetId)
    {
      return Get (SSDataCommon.Connect(),sheetId);
    }
    
    /***************************************************************************
     * Get */
    /**
     * 
     ***************************************************************************/    

    public static Sheet Get (SmartsheetClient c, long? sheetId)
    {
      if (!sheetId.HasValue) return null;
      Sheet s = c.SheetResources.GetSheet(sheetId.Value, null, null, null, null, null, null, null);      
      return s;
    }

    /***************************************************************************
     * ViewAsHtmlTable */
    /**
     * 
     ***************************************************************************/    
    
    public static string ViewAsHtmlTable (long? sheetId)
    {
      return ViewAsHtmlTable (SSDataCommon.Connect(),sheetId);
    }
    
    /***************************************************************************
     * ViewAsHtmlTable */
    /**
     * 
     ***************************************************************************/    

    public static string ViewAsHtmlTable (SmartsheetClient c, long? sheetId)
    {
      StringBuilder sb = new StringBuilder();
      Sheet sheet = Get(c,sheetId);
      
      sb.AppendFormat(@"<table id=""{0}"" class=""smartsheet smartsheet-sheet"">",sheetId.Value);
      
      sb.AppendFormat(@"<caption>{0}</caption>",sheet.Name);
      
      sb.Append(@"<thead>");
      sb.Append(@"<tr>");      
      foreach(Column col in sheet.Columns)
      {        
        sb.AppendFormat(@"<th style=""width:{1}px"">{0}</th>",col.Title,col.Width.Value);      
      }
      sb.Append(@"</tr>");            
      sb.Append(@"</thead>");
      
      sb.Append(@"<tfoot>");
      sb.AppendFormat(@"<tr><th colspan=""{0}"">{1} rows</th></tr>",sheet.Columns.Count, sheet.Rows.Count);
      sb.Append(@"</tfoot>");
      
      sb.Append(@"<tbody>");
      
      foreach(Row row in sheet.Rows)
      {
        
        sb.AppendFormat(@"<tr>");
        
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
