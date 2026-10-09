using System;
using System.Collections.Generic;
using System.Text;
using System.Web.Script.Serialization;
using MBA.IdentifyData;

namespace MBA
{
  
  public class RowValues
  {
    public string[] values;
  }
    
  /***************************************************************************
   * ReturnInfoTable */
  /**
   * Read only informational data (such as news, etc) in tabular form.
   ***************************************************************************/   
    
  public class ReturnInfoTable: Return
  {
    public ReturnInfoTable ()                 : base(){}
    public ReturnInfoTable (string msg)       : base(msg){}
    public ReturnInfoTable (Exception e)      : base(e){}
    public ReturnInfoTable (Warning e)        : base(e){}
    public ReturnInfoTable (Critical e)       : base(e){}
    public ReturnInfoTable (SessionExpired e) : base(e){}
    
    public bool hasRecords;
    public int  numCols;
    public int  numRows;
    public string      caption = "";
    public string[]    colnames;
    public RowValues[] rowvalues;
    
    /***************************************************************************
     * GenerateNoRecordsString */
    /**
     * 
     ***************************************************************************/   
     
       
    public static string GenerateNoRecordsString (  string tblClass         = @"returninfo"
                                                  , string noRecordsMessage = @"No Records")
    {
      return String.Format(@"<div class=""{0}"">{1}</div>",tblClass,noRecordsMessage);
    }

    /***************************************************************************
     * ToHTMLTableString */
    /**
     * Converts rit into a HTML table 
     ***************************************************************************/   
     
    public static string ToHTMLTableString (  ref ReturnInfoTable rit
                                            , string tblClass         = @"returninfo"
                                            , string noRecordsMessage = @"No Records"
                                            , bool includeCaption     = true
                                            , bool includeFooter      = true
                                            , string tblID            = null)
    {
      string tableID = String.IsNullOrEmpty(tblID) ? Util.createUniqueID() : tblID;
      string noRecordsMarkup = GenerateNoRecordsString(tblClass,noRecordsMessage);

      if (rit == null)             return noRecordsMarkup; 
      if (rit.hasRecords == false) return noRecordsMarkup;     
      
      StringBuilder sb = new StringBuilder();      
      
      sb.AppendFormat(@"<table id=""{0}"" class=""{1}"">", tblID, tblClass);
      
      if (includeCaption) sb.AppendFormat(@"<caption>{0}</caption>",rit.caption);
      
      sb.Append(@"<thead>");
      sb.Append(@"<tr>");
      foreach (string colname in rit.colnames) {
        sb.AppendFormat(@"<th>{0}</th>",colname);
      }
      sb.Append(@"</tr>");
      sb.Append(@"</thead>");
      
      if (includeFooter)
      { 
        sb.Append(@"<tfoot>");
        sb.Append(@"<tr>");
        sb.AppendFormat(@"<th colspan=""{0}"">{0} rows</th>",rit.numRows);
        sb.Append(@"</tr>");
        sb.Append(@"</tfoot>");
      }

      sb.Append(@"<tbody>");
      foreach (RowValues rvs in rit.rowvalues) { 
        sb.Append(@"<tr>");
        foreach (string v in rvs.values) {
          sb.AppendFormat(@"<td>{0}</td>",v);
        } 
        sb.Append(@"</tr>");
      }
      sb.Append(@"</tbody>");
      
      sb.Append(@"</table>");
      
      return sb.ToString();
    }

    /***************************************************************************
     * ToNoteString */
    /**
     * Converts rit into a multiline string representation of the data
     ***************************************************************************/   
    
    public static string ToNoteString(ReturnInfoTable rit)
    {
      return ToNoteString(rit,25);
    }
    
    public static string ToNoteString(ReturnInfoTable rit, int pad)
    {
      /*-------------------------------
       * If the table is empty or pad 
       * is unreasonable, get out!
       *------------------------------*/ 
      
      if (rit == null)             return ""; 
      if (rit.hasRecords == false) return "";     
      if (pad <= 0)    return "";
      if (pad > 50)    return "";
             
      /*-------------------------------
       * We use a string builder to
       * construct a multi line
       * string representation of
       * the info table
       *------------------------------*/ 
      
      StringBuilder sb = new StringBuilder();      
      string row = "";

      /*-------------------------------
       * Construct table header
       * Column names + lines
       *------------------------------*/ 
        
      string lines = ""; // Lines under col names
      
      foreach(string colname in rit.colnames)
      {
        string name = colname.PadRight(pad);
        int linelen = name.Length - 1;
        
        if (linelen < 0) 
          linelen = 0;
        
        // Line is a row of spaces the len of column name - 1 + one blank space
        string line = "".PadRight(linelen, '-') + " ";
        row   = row   + name;        
        lines = lines + line;
      }
      
      sb.AppendLine(row);
      sb.AppendLine(lines);
      
      /*-------------------------------
       * Table content
       *------------------------------*/ 
      
      foreach(RowValues rowvalues in rit.rowvalues)
      {
        row = "";
        foreach(string value in rowvalues.values)
        {
          row = row + value.PadRight(pad);         
        }
        sb.AppendLine(row);
      }
            
      return sb.ToString();
    }
    
  }
 
}
