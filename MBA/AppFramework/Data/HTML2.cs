using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Collections.ObjectModel;
using System.Web;
using System.IO;
using System.Drawing;
using MBA.Reporting;
using MBA.IdentifyData;
using MBA;

namespace MBA
{
    
  /***************************************************************************
   * HTML */
  /**
   * Various methods for generating files from various data structures
   * Supporting methods for style rule determination and various HTML
   * specific support classes and methods.
   ***************************************************************************/
  
  public class HTML2:File2
  {  
  
    	  		  
   /**************************************************************************
     * generateFileName */
    /**
     * Create file name
     * 
     ***************************************************************************/

    public static string generateFileName (string name)
    {
      return generateFileName("", name);
    }
    
    public static string generateFileName (string folder, string name)
    {
      return File2.GenerateFileName(folder, name, "html");
    }    
    
    /**************************************************************************
     * createFormats */
    /**
     * Create formats
     *
     ***************************************************************************/    
   
    protected static Dictionary <string, string> createFormats ()
    {

      Dictionary <string,string> formats = new Dictionary <string, string> ();        
     
      formats.Add(FS_EMPTY,           @"");
      formats.Add(FS_TIME,            @"{0:h:mm tt}");
      formats.Add(FS_DATE,            @"{0:MM/dd/yy}");
      formats.Add(FS_DATE_MONTH_YEAR, @"{0:MMM yyyy}");      
      formats.Add(FS_BOOLEAN,         @"");
      formats.Add(FS_INTEGER,         @"{0:0}");
      formats.Add(FS_FLOAT,           @"{0:0.##}");  // Max 2 decimal places
      formats.Add(FS_PERCENT,         @"");
      formats.Add(FS_DECIMAL,         @"{0:0,0.00}");  
      formats.Add(FS_STRING,          @"");
      formats.Add(FS_EMAIL,           @"");
      formats.Add(FS_URI,             @"");
      
      return formats;
   
    }
    
    /**************************************************************************
     * HTMLCellType */
    /**
     * 
     * 
     * 
     ***************************************************************************/

    protected enum HTMLCellType
    {
        TH
      , TD
    }
    
    
    /**************************************************************************
     * createCell */
    /**
     * 
     * 
     * 
     ***************************************************************************/

    protected static string createCell (  ref Dictionary <string, string> formats
                                        , HTMLCellType                    htmlCellType
                                        , int                             colSpan
                                        , ref Object                      value )
    {
    

      StringBuilder cell      = new StringBuilder();
      
      /*###########################################################################
        # Get references to styles using format style constants
        ###########################################################################*/
   
      string emptyStyle         = formats [FS_EMPTY];
      string timeStyle          = formats [FS_TIME];
      string dateStyle          = formats [FS_DATE];
      string dateMonthYearStyle = formats [FS_DATE_MONTH_YEAR];
      string booleanStyle       = formats [FS_BOOLEAN];
      string integerStyle       = formats [FS_INTEGER];
      string floatStyle         = formats [FS_FLOAT];
      string percentStyle       = formats [FS_PERCENT];
      string decimalStyle       = formats [FS_DECIMAL];
      string stringStyle        = formats [FS_STRING];                                
      
    /*###########################################################################
       # Identify value data class
       ###########################################################################*/
     
     Util.ValueDataClass         valueDataClass;
     int                         valueSizeInChars;
     bool                        valueHasLineBreaks;
     bool                        valueIsLink;
     String                      valueString;
     TimeSpan?                   valueTimeSpan;
     DateTime?                   valueDateTime;
     long?                       valueInteger;
     System.Decimal?             valueFixed;
     Double?                     valueFloating;
     Boolean?                    valueBoolean;
     System.Net.Mail.MailAddress valueEmail;
     Uri                         valueUri;

     string        cellValue = @"";
     string        cellStyle = @"";

     Util.identifyAndParseValue (  ref value
                                 , out valueDataClass
                                 , out valueSizeInChars
                                 , out valueHasLineBreaks
                                 , out valueIsLink
                                 , out valueString
                                 , out valueTimeSpan
                                 , out valueDateTime
                                 , out valueInteger
                                 , out valueFixed
                                 , out valueFloating
                                 , out valueBoolean
                                 , out valueEmail
                                 , out valueUri );
                
     /*###########################################################################
       # If the value object passed in is null or empty, treat it as an empty string
       ###########################################################################*/
     
     if      ( valueDataClass == Util.ValueDataClass.EMPTY )               cellValue = valueString;                               
     else if ( valueDataClass == Util.ValueDataClass.DATETIME_MONTH_YEAR ) cellValue = String.Format ( dateMonthYearStyle, valueDateTime );
     else if ( valueDataClass == Util.ValueDataClass.TIME )                cellValue = String.Format ( timeStyle,          valueDateTime);
     else if ( valueDataClass == Util.ValueDataClass.DATETIME )            cellValue = String.Format ( dateStyle,          valueDateTime );
     else if ( valueDataClass == Util.ValueDataClass.BOOLEAN )             cellValue = valueString;          
     else if ( valueDataClass == Util.ValueDataClass.NUMBER_INTEGER )      cellValue = String.Format ( integerStyle,       valueInteger  );
     else if ( valueDataClass == Util.ValueDataClass.NUMBER_FLOATING )     cellValue = String.Format ( floatStyle,         valueFloating ) ;
     else if ( valueDataClass == Util.ValueDataClass.NUMBER_FIXED )        cellValue = String.Format ( decimalStyle,       valueFixed) ;
     else if ( valueDataClass == Util.ValueDataClass.STRING_PERCENTAGE )   cellValue = valueString;
     else if ( valueDataClass == Util.ValueDataClass.STRING_EMAIL )        cellValue = valueString;
     else if ( valueDataClass == Util.ValueDataClass.STRING_URI)           cellValue = valueString;
     else if ( valueDataClass == Util.ValueDataClass.STRING )              cellValue = valueString;          
     else if ( valueDataClass == Util.ValueDataClass.UNKNOWN )             cellValue = valueString;      
     else                                                                  cellValue = valueString;
     
     cellStyle = Util.valueDataClassToDtCssClass (valueDataClass);
      
     if (htmlCellType == HTMLCellType.TH) cell.AppendFormat (@"<th class=""{0}"" colspan=""{1}"">", cellStyle, colSpan);
     if (htmlCellType == HTMLCellType.TD) cell.AppendFormat (@"<td class=""{0}"" colspan=""{1}"">", cellStyle, colSpan);     
     
     if (valueIsLink)
     {
       string address = valueString;
       if (valueDataClass == Util.ValueDataClass.STRING_EMAIL) address = @"mailto:" + valueString;
       cell.AppendFormat (@"<a target=""_blank"" href=""{0}"">", address);
     }
     
     if (valueHasLineBreaks)              cell.Append(@"<pre>");

     cell.Append(cellValue);

     if (valueHasLineBreaks)              cell.Append(@"</pre>");
     if (valueIsLink)                     cell.Append(@"</a>");
     if (htmlCellType == HTMLCellType.TH) cell.Append(@"</th>");
     if (htmlCellType == HTMLCellType.TD) cell.Append(@"</td>");
 
     return cell.ToString();
      
    }                                        
    
    /**************************************************************************
     * ReturnDataTableToFile */
    /**
     * Generates a stand-alone HTML document from a ReturnDataTable instance
     * 
     * @param  rd    ReturnDataTable
     ***************************************************************************/
    
    public static Byte[] ReturnDataTableToHTML ( ref ReturnDataTable rd )
    {
      
      StringWriter  doc         = new StringWriter();
      StringBuilder thead       = new StringBuilder();
      StringBuilder theadTitle  = new StringBuilder();
      StringBuilder theadCols   = new StringBuilder();      
      StringBuilder tfoot       = new StringBuilder();
      StringBuilder tbody       = new StringBuilder();        
      StringBuilder style       = new StringBuilder();
      StringBuilder table       = new StringBuilder();

      int  colPtr   = 0;      
      int  numCols  = 0;
      int  numRows  = 0;
                                                           	    
      Dictionary <string, string> formats = createFormats(); 

      /*###########################################################################
        # Style 
        ###########################################################################*/ 
        
       style.Append(@"body, div, table, tr, td, th, a, pre {font-family: ""Times New Roman"", Georgia, Serif; font-size:10pt;}");       
       style.Append(@"div.container {width:100%;}");
       style.Append(@"table {display:block;border-collapse: collapse;width:94%;margin:0 auto;}");
       style.Append(@"table thead tr th {background-color:#000; color:#fff; padding-left:2px; padding-right:2px; padding-top:4px; padding-bottom:4px;border:1px solid #000;}");
       style.Append(@"table tbody tr td {background-color:#fff; color:#000; padding-left:2px; padding-right:2px; padding-top:.5px; padding-bottom:.5px;border:1px solid #000;}");
       style.Append(@"table thead tr td, table thead tr th, table tfoot tr td {text-align:center; vertical-align: middle; line-height: normal;}");
       style.Append(@"table tbody tr td {vertical-align:middle; line-height: normal; }");
       style.Append(@"table tbody tr td.dt-string {text-align: left;}");
       style.Append(@"table tbody tr td.dt-string pre {white-space: pre-wrap; white-space: -moz-pre-wrap; white-space: -pre-wrap; white-space: -o-pre-wrap; word-wrap: break-word;}");
       style.Append(@"table tbody tr td.dt-time {text-align: center;}");
       style.Append(@"table tbody tr td.dt-date {text-align: center;}");
       style.Append(@"table tbody tr td.dt-numeric {text-align: right;}");
       style.Append(@"table tbody tr td.dt-bool {text-align: center;}");

       style.Append(@"@media print {");
       style.Append(@"@page {size: letter landscape; margin: 1cm;}");
       style.Append(@"table {display:block;page-break-after:auto;}");
       style.Append(@"tr {page-break-inside:avoid; page-break-after:auto;}");
       style.Append(@"td {page-break-inside:avoid; page-break-after:auto;}");
       style.Append(@"thead {display:table-header-group;}");
       style.Append(@"tfoot {display:table-footer-group;}");
       style.Append(@"}");

      /*###########################################################################
        # Create table head cols and count number of visible columns
        ###########################################################################*/ 

      colPtr  = 0;   
      numCols = 0;   
      
      theadCols.Append (@"<tr class=""thead-cols"">");
      
      foreach (aoColumn col in rd.aoColumns)
      {
        aoColumn fldDef = rd.aoColumns[colPtr];
        
        if (col.bVisible)
        {                      
          numCols++;
          
          /*-------------------------------
           * Replace spaces with breaks
           * if specified
           *------------------------------*/
         
          if (rd.columnTitlesReplaceSpacesWithBreaks == true)
          {
            col.sTitle = col.sTitle.Replace(@" ",@"<br>");
          }
          Object thVal = col.sTitle;
          string thCell = createCell (ref formats, HTMLCellType.TH, 1, ref thVal);
          theadCols.Append(thCell);
          //theadCols.Append (@"<th class=""thead-cols"">");
          //theadCols.Append (col.sTitle); 
          //theadCols.Append (@"</th>");    
        }
        colPtr++;
      }
      	     
	    theadCols.Append (@"</tr"); 	     	     
 	    
 	    /*###########################################################################
        # Create table head title.  Content will span all visible columns.
        ###########################################################################*/ 
      
      theadTitle.Append       (@"<tr class=""thead-title"">");
      theadTitle.AppendFormat (@"<td colspan=""{0}"">",numCols);
      theadTitle.Append       (rd.tableName);
      theadTitle.Append       (@"</td>");
 	    theadTitle.Append       (@"</tr>");
 	    
 	    /*###########################################################################
        # Create table head
        ###########################################################################*/ 
      
 	    thead.Append (@"<thead>");
 	    thead.Append (theadTitle.ToString());
 	    thead.Append (theadCols.ToString());
 	    thead.Append (@"</thead>");

 	    /*###########################################################################
        # Create table foot.  Content will span all visible columns.
        ###########################################################################*/ 

      tfoot.Append       ("<tfoot>");
      tfoot.Append       (@"<tr>");
      tfoot.AppendFormat (@"<td colspan=""{0}"">",numCols);
      tfoot.Append       (rd.tableFooter);
      tfoot.Append       (@"</td>");
 	    tfoot.Append       (@"</tr>");
 	    tfoot.Append       (@"</tfoot>");
	          
      /*###########################################################################
        # Create table body
        ###########################################################################*/ 

      tbody.Append (@"<tbody>");
      numRows = 0;
      foreach (Object[] arow in rd.aaData)        
      {
        numRows++;        
        
        String evenOddRow = ((numRows % 2) == 0) ? "even": "odd";
        
        tbody.AppendFormat (@"<tr class=""{0}"">", evenOddRow);                         
        
        colPtr = 0;        
        foreach (Object fld in arow)
        {                    
          aoColumn fldDef = rd.aoColumns[colPtr];         
          if (fldDef.bVisible)
          {                        
            
            Object tdVal = fld;
            string tdCell = createCell (ref formats, HTMLCellType.TD, 1, ref tdVal);                     
            tbody.Append (tdCell);                                                                          
          }                          
          colPtr++;
        }
        
        tbody.Append (@"</tr>");                  
      }
      
      tbody.Append(@"</tbody>");

      /*###########################################################################
        # Create table
        ###########################################################################*/ 
      
      table.Append(@"<table>");
      table.Append(thead.ToString());
      table.Append(tfoot.ToString());
      table.Append(tbody.ToString());
      table.Append(@"</table>");
                       
      /*###########################################################################
        # Create HTML document
        ###########################################################################*/ 
      
      doc.WriteLine(@"<!doctype html>"); 
      doc.Write(@"<html>");      
	    doc.Write(@"<head>");		  
		  doc.Write(@"<meta charset=""utf-8"">");
      doc.Write(@"<meta http-equiv=""Content-Type"" content=""text/html"">");
      doc.Write(@"<meta http-equiv=""X-UA-Compatible"" content=""IE=edge"">");
      doc.Write(@"<meta name=""viewport"" content=""width=device-width, initial-scale=1"">");     
      doc.Write(@"<meta name=""application-name"" content=""" + Constants.APP_TITLE + @""">");     		      
      doc.Write(@"<meta name=""author"" content=""" + Messages.COPYRIGHT_2 + @""">");
      doc.Write(@"<meta name=""description"" content=""" + rd.tableName + @""">");      
      doc.Write(@"<title>");       
      doc.Write(rd.tableName);	  
      doc.Write(@"</title>");       
      doc.Write (@"<style type=""text/css"">");
      doc.Write(style.ToString());
      doc.Write (@"</style>");                      
      doc.Write (@"</head>");
      doc.Write(@"<body>");            
      doc.Write(@"<div class=""container"">");
      doc.Write(table.ToString());
      doc.Write(@"</div>");            
      doc.Write(@"</body>");    		  
	    doc.Write(@"</html>");
      	  
      byte[] b1 = System.Text.Encoding.UTF8.GetBytes (doc.ToString());
      return b1;				
      
    }    
      
    /***************************************************************************
     * ReturnRptDataToHTML */
    /**
     * Generates a stand-alone HTML document from a ReturnRptData instance
     * 
     * @param  rd    ReturnRptDataInstance
     ***************************************************************************/     

    public static Byte[] ReturnRptDataToHTML (ref ReturnRptData rd)
    {
     
      StringWriter  doc         = new StringWriter();
      StringBuilder thead       = new StringBuilder();
      StringBuilder theadTitle  = new StringBuilder();
      StringBuilder theadCols   = new StringBuilder();      
      StringBuilder tfoot       = new StringBuilder();
      StringBuilder tbody       = new StringBuilder();        
      StringBuilder style       = new StringBuilder();
      StringBuilder table       = new StringBuilder();

      int  colCtr   = 0;
      int  lastCol  = 0;
                                                           	    
      Dictionary <string, string> formats = createFormats(); 

      /*###########################################################################
        # Style 
        ###########################################################################*/ 
        
       style.Append(@"body, div, table, tr, td, th, pre {font-family: ""Times New Roman"", Georgia, Serif; font-size:10pt;}");       
       style.Append(@"div.container {width:100%;}");
       style.Append(@"table {display:block;border-collapse: collapse;width:94%;margin:0 auto;}");
       style.Append(@"table thead tr th {background-color:#000; color:#fff; padding-left:2px; padding-right:2px; padding-top:4px; padding-bottom:4px;border:1px solid #000;}");
       style.Append(@"table tbody tr td {background-color:#fff; color:#000; padding-left:2px; padding-right:2px; padding-top:.5px; padding-bottom:.5px;border:1px solid #000;}");
       style.Append(@"table thead tr td, table thead tr th, table tfoot tr td {text-align:center; vertical-align: middle; line-height: normal;}");
       style.Append(@"table tbody tr td {vertical-align:middle; line-height: normal; }");
       style.Append(@"table tbody tr td.dt-empty  {text-align: right;}");
       style.Append(@"table tbody tr td.dt-string {text-align: left;}");
       style.Append(@"table tbody tr td.dt-time {text-align: center;}");
       style.Append(@"table tbody tr td.dt-date {text-align: center;}");
       style.Append(@"table tbody tr td.dt-numeric {text-align: right;}");
       style.Append(@"table tbody tr td.dt-bool {text-align: center;}");

       style.Append(@"@media print {");
       style.Append(@"@page {size: letter landscape; margin: 1cm;}");
       style.Append(@"table {display:block;page-break-after:auto;}");
       style.Append(@"tr {page-break-inside:avoid; page-break-after:auto;}");
       style.Append(@"td {page-break-inside:avoid; page-break-after:auto;}");
       style.Append(@"thead {display:table-header-group;}");
       style.Append(@"tfoot {display:table-footer-group;}");
       style.Append(@"}");

                              
      /*###########################################################################
        # Get copies of titles and footers we can use in our delegates
        ###########################################################################*/

      List<TitleOrFooter> titles  = rd.resultSetTitles;
      List<TitleOrFooter> footers = rd.resultSetFooters;
      
     /*-------------------------------
      * Define start header
      *------------------------------*/ 

	  TraverseNodesCallback startheader = delegate(Object[] args)
	  {	
	  	
	   /*-------------------------------
      * Start col headers
      *------------------------------*/

	    colCtr = 0;
	    theadCols.Append(@"<tr>");
	    
	  };
	  
	  TraverseNodesCallback headerop = delegate(Object[] args)
	  {
	    /*----------------------------
       * Create column header
       *----------------------------*/

	    InputColumnDefinition def  = (InputColumnDefinition) args[0];	
	    Object thVal = def.name;
	    string thCell = createCell(ref formats, HTMLCellType.TH, 1, ref thVal);
      theadCols.Append(thCell);            	    
	    colCtr++;

	  };
	  
	  TraverseNodesCallback endheader = delegate(Object[] args)
	  {  
	    lastCol = colCtr; 
	    colCtr = 0;
	    
	    /*-------------------------------
       * End col headers
       *------------------------------*/

	    theadCols.Append(@"</tr>");

	    /*-------------------------------
       * Create title rows and cols
       *------------------------------*/

      foreach (TitleOrFooter title in titles)
      {
        if (!Util.IsNullOrEmpty(title.name))
        {        
          theadTitle.Append(@"<tr>");
          Object tdVal = title.name;
	        string tdCell = createCell(ref formats, HTMLCellType.TD, lastCol, ref tdVal);
          theadTitle.Append(tdCell);
          theadTitle.Append(@"</tr>");
        }
      }
	   	
	   	thead.Append (@"<thead>");
	   	thead.Append (theadTitle.ToString());
	   	thead.Append (theadCols.ToString());
	    thead.Append (@"</thead>");  	    	  	    
	  
	  };
	  
	  GenericCallBack startbody = delegate()
	  {
	    tbody.Append (@"<tbody>");	   	    
	  };
	  
	  string evenodd = "";
	  
	  TraverseNodesOperation startrow = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	  
	    string rowType         = (string) args[0];
	    evenodd                = (string) args[1];	    
	    int    fillto          = (int)    args[2];
      int    agrTitlePos     = (int)    args[3];
      string agrTitleLabel   = (string) args[4];
      int    agrTitleSpan    = (int)    args[5];
	    
	    colCtr = 0;
      tbody.Append (@"<tr>");
      	    
	    /*-------------------------------
       * Create filler cells and 
       * insert aggregate title if
       * neccessary
       *------------------------------*/
       
      if (fillto != 0)
      {
        Object tdVal = @"";
        int span     = fillto;
        
        if (agrTitlePos != -1) 
        {
          tdVal = agrTitleLabel;          
          if (agrTitlePos == 0) span = agrTitleSpan;
	      }
	      
	      string tdCell = createCell(ref formats, HTMLCellType.TD, span, ref tdVal);
        tbody.Append(tdCell);	   
	    }
	  };
	  
	  TraverseNodesOperation nodeop = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {	    
	    int span = (int) args[0];	    
      Object tdVal = f.identifiedValue.value;
	    string tdCell = createCell(ref formats, HTMLCellType.TD, span, ref tdVal);
      tbody.Append(tdCell);
	  };
	  
	  TraverseNodesOperation endrow = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	    table.Append (@"</tr>");
	  };

	  GenericCallBack endbody = delegate()
	  {
	    tbody.Append (@"</tbody>");
	    
	    tfoot.Append (@"<tfoot>");
	    
	    /*-------------------------------
       * Create footer rows and cols
       *------------------------------*/

	    foreach (TitleOrFooter footer in footers)
	    {
	      if (!Util.IsNullOrEmpty(footer.name))
        {                 
          tfoot.Append(@"<tr>");
          Object tdVal = footer.name;
	        string tdCell = createCell(ref formats, HTMLCellType.TD, lastCol, ref tdVal);
          tfoot.Append(tdCell);
          tfoot.Append(@"</tr>");
        }
	    }
	    
	    tfoot.Append (@"</tfoot>");
	   	          
	  };

     /*-------------------------------
      * Build our data table
      *------------------------------*/ 
	  
	  int safetyCtr = 0;
	  int levelCtr  = DataTree.ROOT_LEVEL;

	  DataTree.TraverseForReport
	                         (ref rd.datatree,
	                          DataTree.ROOT_NODE_ID, 
                            ref safetyCtr,
                            ref levelCtr,
                            startheader,
                            headerop,
                            endheader,
                            startbody,
                            startrow,
                            nodeop,
                            endrow,
                            endbody);
                                        
   /*###########################################################################
        # Create table
        ###########################################################################*/ 
      
      table.Append(@"<table>");
      table.Append(thead.ToString());
      table.Append(tfoot.ToString());
      table.Append(tbody.ToString());
      table.Append(@"</table>");
                       
      /*###########################################################################
        # Create HTML document
        ###########################################################################*/ 
      
      doc.WriteLine(@"<!doctype html>"); 
      doc.Write(@"<html>");      
	    doc.Write(@"<head>");		  
		  doc.Write(@"<meta charset=""utf-8"">");
      doc.Write(@"<meta http-equiv=""Content-Type"" content=""text/html"">");
      doc.Write(@"<meta http-equiv=""X-UA-Compatible"" content=""IE=edge"">");
      doc.Write(@"<meta name=""viewport"" content=""width=device-width, initial-scale=1"">");     
      doc.Write(@"<meta name=""application-name"" content=""" + Constants.APP_TITLE + @""">");     		      
      doc.Write(@"<meta name=""author"" content=""" + Messages.COPYRIGHT_2 + @""">");
      doc.Write(@"<meta name=""description"" content=""" + rd.title + @""">");      
      doc.Write(@"<title>");       
      doc.Write(rd.title);	  
      doc.Write(@"</title>");       
      doc.Write (@"<style type=""text/css"">");
      doc.Write(style.ToString());
      doc.Write (@"</style>");                      
      doc.Write (@"</head>");
      doc.Write(@"<body>");            
      doc.Write(@"<div class=""container"">");
      doc.Write(table.ToString());
      doc.Write(@"</div>");            
      doc.Write(@"</body>");    		  
	    doc.Write(@"</html>");
      	  
      byte[] b1 = System.Text.Encoding.UTF8.GetBytes (doc.ToString());
      return b1;				      
    }    


  }     
}
