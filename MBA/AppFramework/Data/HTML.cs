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
   * HTMLDocument */
  /**
   * 
   ****************************************************************************/    

  public class HTMLDocument:MBA.Document 
  {     
    public HTMLDocument():base(){}    
  }
  
  /***************************************************************************
   * HTMLCell */
  /**
   * Class for holding and generating text representing an HTML cell
   ****************************************************************************/  
  
  public class HTMLCell
  {
    public static readonly string BORDER_STYLE               = "1px solid #000";    
    public static readonly string CSS_FONT_FAMILY_SERIF      = @"""Times New Roman"", TimesNR, Times, serif";
	  public static readonly string CSS_RULE_FONT_FAMILY_SERIF = @"font-family:" + CSS_FONT_FAMILY_SERIF + @";";	   
    public static readonly string CSS_CLASS_FONT_SERIF       = HTML.BASE_FONT_TIMES_ROMAN      + @"{" + CSS_RULE_FONT_FAMILY_SERIF + @"}";
    public static readonly string CSS_CLASS_FONT_SERIF_BOLD  = HTML.BASE_FONT_TIMES_ROMAN_BOLD + @"{" + CSS_RULE_FONT_FAMILY_SERIF + @";font-weight:bold;}";
 
    
    public string   background_color    = "";
    public string   border              = "";
	  public string   alignment           = "";	
	  public int      span                = 1;  
	  public string   colspan             = "1";  
	  public string   font                = "";
	  public string   value               = "";
    public string   colctr              = "";
    public string   cls                 = "";
    public string   style               = "";
    public string   cell                = "";
	  
	  public string CreateTH()
	  {
	   CreateClass();
	   CreateStyle();
	   cell = @"<th " + colspan + @" " + cls + " " + style + @">" + value + @"</th>";
	   return cell;
	  }
	  
	  public string CreateTD()
	  {
      CreateClass();
      CreateStyle();      
	    cell = @"<td " + colspan + @" " + cls + " " + style + @">" + value + @"</td>";
	    return cell;
	  }
	  
	  protected void CreateClass()
	  {	    
	    cls = @"class = """ + colctr + @"""";
	  }
	  
	  protected void CreateStyle()
	  {
	    style = @"style = """ + font + background_color + border + alignment + @"""";
	  }	  
	  
    public void SetColCtr (int ctr)
    {
      if (ctr >= 0)
        colctr = "c" + ctr.ToString();
      else
        colctr = "";
    }
    
    public void SetFont (int size, Color color, bool bold)
    {
      string    fontsize  = size.ToString() + "pt";
	    string    fontcolor = ColorTranslator.ToHtml(color);
	    string    fontweight = (bold) ? ";font-weight:bold;" : "";      
      font = @"font-size:" + fontsize + ";color:" + fontcolor + @";" + fontweight + @";";
    }
    
    public void SetBackgroundColor(Color c)
    {
      this.background_color  = @"background-color: " + ColorTranslator.ToHtml(c) + @";";
    }
    
    public void SetColSpan (int span)
    {
      this.span = span;
      this.colspan = @"colspan=""" + span.ToString() + @"""";
    }
    
    public void SetBorder(int[] borders)
    {
      border = "";
      
      if (borders != null)
      {
        foreach (int b in borders)
        {
          if (b == File.BORDER_NONE)
          {
            border = "";  
            return;
          }
        
          if (b == File.BORDER_TOP)     border = border + "border-top:"    + BORDER_STYLE + ";";
          if (b == File.BORDER_BOTTOM)  border = border + "border-bottom:" + BORDER_STYLE + ";";
          if (b == File.BORDER_LEFT)    border = border + "border-left:"   + BORDER_STYLE + ";";
          if (b == File.BORDER_RIGHT)   border = border + "border-right:"  + BORDER_STYLE + ";";
        }
      }
            
      return;
    }
    
    public void SetAlignment(int align)
    { 
      alignment = "";
      
      if (align == File.ALIGN_LEFT)   alignment = "text-align:left;";
      if (align == File.ALIGN_RIGHT)  alignment = "text-align:right;";
      if (align == File.ALIGN_CENTER) alignment = "text-align:center;";
      
      return;
      
    }
        
    public void SetValue (string val)
    {
      this.value = val;
    }
     
  }
  
  /***************************************************************************
   * HTML */
  /**
   * Various methods for generating files from various data structures
   * Supporting methods for style rule determination and various HTML
   * specific support classes and methods.
   ***************************************************************************/
  
  public class HTML: File
  {  
    
	  /***************************************************************************
     * ORIENTATION_X */
    /**
     * The various page sizes we will use
     ***************************************************************************/
    
	  new public static readonly string ORIENTATION_PORTRAIT  = "width:8.5in;height:11in;";
	  new public static readonly string ORIENTATION_LANDSCAPE = "width:11in;height:8.5in;";

    /***************************************************************************
     * BASE_FONT_ */
    /**
     * The various fonts we will use
     ***************************************************************************/
    
    new public static readonly string BASE_FONT_TIMES_ROMAN      = @".serif";
    new public static readonly string BASE_FONT_TIMES_ROMAN_BOLD = @".serif-bold";
    
    /**************************************************************************
     * CreateTitleCells */
    /**
     * Create a cell
     ***************************************************************************/
     
    protected static HTMLCell[] CreateTitleCells (TitleOrFooter[] titles)
    {
      List<HTMLCell> cells = new List<HTMLCell>();
      
      foreach (TitleOrFooter title in titles)
      {
        if (!Util.IsNullOrEmpty(title.name))
        { 
          CellStyle cs   = DetermineCellStyleTitle(title);      
    	    HTMLCell cell  = CreateCell(cs,title.name,1);           
          cells.Add(cell);
        }
      }
     
     HTMLCell padcell = new HTMLCell();
     padcell.SetValue("&nbsp");
     cells.Add(padcell);
     
     return cells.ToArray();

    }
    
    /**************************************************************************
     * CreateFooterCells */
    /**
     * Create a cell
     ***************************************************************************/
     
    protected static HTMLCell[] CreateFooterCells (TitleOrFooter[] footers)
    {
      List<HTMLCell> cells = new List<HTMLCell>();
      
      HTMLCell padcell = new HTMLCell();
      padcell.SetValue("&nbsp");
      cells.Add(padcell);

      foreach (TitleOrFooter footer in footers)
      {
        if (!Util.IsNullOrEmpty(footer.name))
        { 
          CellStyle cs   = DetermineCellStyleFooter(footer);      
    	    HTMLCell cell  = CreateCell(cs,footer.name,1);           
          cells.Add(cell);
        }
      }
     
     return cells.ToArray();

    }
    
    /**************************************************************************
     * CreateCell */
    /**
     * Create a cell
     ***************************************************************************/
    
    protected static HTMLCell CreateCell(InputColumnDefinition d, int span, int colctr)
    {
      CellStyle cs = DetermineCellStyleColumn(d);
	    return CreateCell(cs, d.name, span, colctr);	    
    }
    
    protected static HTMLCell CreateCell(DataTreeNode f, int span, string evenodd, int colctr)
	  {
	    CellStyle cs = DetermineCellStyleColumn(f, evenodd);
	    return CreateCell(cs, f.identifiedValue.valueStrFormatted, span, colctr);	          	    
	  }
	  
	  protected static HTMLCell CreateCell (int agrTitlePos, string agrTitleLabel, int agrTitleSpan)
	  {
	    CellStyle cs = new CellStyle();
	    
	    cs.borders = DetermineCellBorders(agrTitlePos);       
		    
	    if (agrTitlePos > 0) 
	    {
	      cs.font_size = FONT_SIZE_AGGREGATE_LABEL_L1;
	    }
	    else
	    {
	      cs.font_size = FONT_SIZE_AGGREGATE_LABEL_L0;
	      cs.bold = true;
	    }
	    
	    return CreateCell (cs, agrTitleLabel, agrTitleSpan);	    
	  }
    
    protected static HTMLCell CreateCell (CellStyle cs, string value, int span)
    {
      return CreateCell(cs,value,span,-1);
    }
    	  	     

    
    protected static HTMLCell CreateCell (CellStyle cs, string value, int span, int colctr)
	  {	    
	    
      HTMLCell cell = new HTMLCell();
            
      cell.SetBackgroundColor (cs.background_color);      
      cell.SetBorder          (cs.borders);
	    cell.SetAlignment       (cs.alignment);	    
	    cell.SetColSpan         (span);
	    cell.SetFont            (cs.font_size, cs.font_color, cs.bold);
	    cell.SetColCtr          (colctr);
	    cell.SetValue           (value);
	    
	    return cell;
	    
	  }
    
    /**************************************************************************
     * CreateFillerCells */
    /**
     * Create filler cells
     ***************************************************************************/	  
        
    protected static HTMLCell[] CreateFillerCells(int fillto)
    {
      
      List<HTMLCell> cells = new List<HTMLCell>();
  
	    for (int fill = 0; fill < fillto; fill++)
	    {	          
        
        /*----------------------------
         * Create new empty cell
         *----------------------------*/
         
        HTMLCell cell = new HTMLCell();
        cell.SetValue(""); 
        cell.SetColSpan(1);         	    
	      cells.Add(cell);
	    
	    }
      
      return cells.ToArray();
    
    }    	  
    
    /***************************************************************************
     * GenerateFileName */
    /**
     * Combines folder and name into a filename
     * 
     * @param  folder     Path to file (optional)
     * @param  name       Name of the file (no extension)
     **************************************************************************/    
    
    public static string GenerateFileName (string name)
    {
      return GenerateFileName("", name);
    }

    public new static string GenerateFileName (string folder, string name)
    {
      return File.GenerateFileName(folder, name, "html");
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
     
      /*-------------------------------
       * Determine page alignment
       *------------------------------*/

      string orientation = ORIENTATION_PORTRAIT;

      if (rd.output_orientation == File.ORIENTATION_LANDSCAPE)
        orientation = ORIENTATION_LANDSCAPE;
     
      /*-------------------------------
       * Get default settings
       *------------------------------*/

      HTMLDocument htmldoc = new HTMLDocument();
      
      string default_font_size  = htmldoc.defaultStyle.font_size.ToString() + "pt";
      string default_color_back = ColorTranslator.ToHtml(htmldoc.defaultStyle.background_color);
      string default_color_font = ColorTranslator.ToHtml(htmldoc.defaultStyle.font_color);
      
      /*-------------------------------
       * We will use a StringWriter to
       * hold the final document and
       * various string builders to hold
       * parts of the document
       *------------------------------*/
      
      StringWriter  doc   = new StringWriter();
      StringBuilder style = new StringBuilder();
      StringBuilder table = new StringBuilder();
            
      /*-------------------------------
       * Create counters to keep track
       * of current row/column.  
       *------------------------------*/

      int rowCtr = 0;
      int colCtr = 0;
                              
      /*-------------------------------
       * Start building document wide
       * style starting with a css reset
       *------------------------------*/ 
      
      style.Append (@"html,body,div,span,applet,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote,pre,a,abbr,acronym,address,big,cite,code,del,dfn,em,img,ins,kbd,q,s,samp,small,strike,strong,sub,sup,tt,var,b,u,i,center,dl,dt,dd,ol,ul,li,fieldset,form,label,legend,table,caption,tbody,tfoot,thead,tr,th,td,article,aside,canvas,details,embed,figure,figcaption,footer,header,hgroup,menu,nav,output,ruby,section,summary,time,mark,audio,video{border:0;font-size:100%;font:inherit;vertical-align:baseline;margin:0;padding:0}article,aside,details,figcaption,figure,footer,header,hgroup,menu,nav,section{display:block}body{line-height:1}ol,ul{list-style:none}blockquote,q{quotes:none}blockquote:before,blockquote:after,q:before,q:after{content:none}table{border-collapse:collapse;border-spacing:0}");
      
      /*-------------------------------
       * Font classes
       *------------------------------*/ 
      
      style.Append (HTMLCell.CSS_CLASS_FONT_SERIF);
      style.Append (HTMLCell.CSS_CLASS_FONT_SERIF_BOLD);
      
      /*-------------------------------
       * Set default font and size
       *------------------------------*/ 
      
      style.Append (@"body,table,tr,td,th,span {background-color:" + default_color_back + 
                                             @";color:" + default_color_font + 
                                             @";"       + HTMLCell.CSS_RULE_FONT_FAMILY_SERIF + 
                                             @";font-size:" + default_font_size + @";}");
      
      /*-------------------------------
       * Set page wide style
       *------------------------------*/ 
       
      style.Append (@"#page {" + orientation + @"margin:0 auto;}");      
      style.Append (@"#data {width:95%;margin:0 auto;}");
      
       //doc.Write (@"#data-head    {display:table-header-group;}");       
       //doc.Write (@"#data-body    {display:table-row-group;}");
       //doc.Write (@"#data-body tr {page-break-inside:avoid;}");
                                 
      style.Append(@"tbody td, tbody th {padding:3pt;}");
      
     /*-------------------------------
      * Titles and footers
      *------------------------------*/ 
     
     HTMLCell[] titlecells  = CreateTitleCells(rd.resultSetTitles.ToArray());
		 HTMLCell[] footercells = CreateFooterCells(rd.resultSetFooters.ToArray());
               		  
     /*-------------------------------
      * Define start header
      *------------------------------*/ 

	  TraverseNodesCallback startheader = delegate(Object[] args)
	  {	
	  
	    int       numCols     = (int)       args[0];
	    int       totalWidth  = (int)       args[1];
	    int[]     colWidths   = (int[])     args[2];
	    float[]   colWidthPer = (float[])   args[3];
	    
	    colCtr = 0;
	    
	    /*-------------------------------
       * Determine column widths
       *------------------------------*/ 
	    
	    foreach (float cwp in colWidthPer)
	    {
	      float  cwidthf = cwp * 100f;
	      string cwidths = cwidthf.ToString() + @"%";
	      string cstyle  = @".c" + colCtr.ToString() + @"{width:" + cwidths + @";}";
	      style.Append(cstyle);
	      colCtr++;
	    }
	   
	    colCtr = 0;
  	    
	    /*-------------------------------
       * Start creating table
       *------------------------------*/ 
	    
	    table.Append (@"<table id=""data"">");
	    table.Append (@"<thead id=""data-head"">");
	    
	    /*----------------------------
       * Add the titles
       * being sure to set the proper
       * column span and count them
       *----------------------------*/
	    
	    foreach(HTMLCell cell in titlecells)
      {
        cell.SetColSpan(numCols);
        table.Append(@"<tr>");
        table.Append(cell.CreateTH());
        table.Append(@"</tr>");
      }
	    
	    /*----------------------------
       * Open the row for our column
       * headings.  Also reset col ctr.
       *----------------------------*/
       
	    colCtr = 0;
	    table.Append (@"<tr>");
	    
	  };
	  
	  TraverseNodesCallback headerop = delegate(Object[] args)
	  {
	    /*----------------------------
       * Add column heading
       *----------------------------*/

	    InputColumnDefinition def  = (InputColumnDefinition) args[0];	    	    
	    HTMLCell              cell = CreateCell(def,1,colCtr);
	    table.Append (cell.CreateTH());	    
	    colCtr++;
	  };
	  
	  TraverseNodesCallback endheader = delegate(Object[] args)
	  {  
	    int numCols = (int) args[0];
	    
	    /*----------------------------
       * Close the row for our column
       * headings and close the table
       * head.  Also reset col ctr.
       *----------------------------*/

	    table.Append (@"</tr>");	    
	    table.Append (@"</thead>");
	    colCtr = 0;
	    
	    /*----------------------------
       * Add the footers
       * being sure to set the proper
       * column span and count them
       *----------------------------*/
	    
	    table.Append (@"<tfoot id=""data-foot"">");

	    foreach(HTMLCell cell in footercells)
      {
        cell.SetColSpan(numCols);
        table.Append(@"<tr>");
        table.Append(cell.CreateTH());
        table.Append(@"</tr>");
      }
	    
	    table.Append (@"</tfoot>");	    
	    
	  };
	  
	  GenericCallBack startbody = delegate()
	  {
	    table.Append (@"<tbody id=""data-body"">");
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
      	    
	    table.Append (@"<tr>");
	    
	 	  HTMLCell[] cells = CreateFillerCells(fillto);	    	    
      	    	    
	    /*-------------------------------
       * Insert aggregate title label
       *------------------------------*/ 
	    
	    if (agrTitlePos != -1)
	    {	      
	      HTMLCell cell = CreateCell(agrTitlePos, agrTitleLabel, agrTitleSpan);
	      cells[agrTitlePos] = cell;
	    }
	    
	    foreach (HTMLCell cell in cells)
	    { 	      
	      cell.SetColCtr(colCtr);
	      table.Append (cell.CreateTD());
	      colCtr = colCtr + cell.span;
	      colCtr++;
	    }	      	  
	    rowCtr++;    	    	  
	  
	  };
	  
	  TraverseNodesOperation nodeop = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	    
	    int span = (int) args[0];	    
   
	    HTMLCell cell = CreateCell(f, span, evenodd, colCtr);
	    table.Append (cell.CreateTD());	    	   
	    colCtr++;
	  };
	  
	  TraverseNodesOperation endrow   = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	    table.Append (@"</tr>");
	  };

	  GenericCallBack endbody = delegate()
	  {
	    table.Append (@"</tbody>");
      table.Append (@"</table>");
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
                                        

      /*-------------------------------
       * Create document starting with
       * doctype and (c) notice
       *------------------------------*/ 
      
      doc.WriteLine(@"<!doctype html>");      
      doc.WriteLine(@"<!-- " + File.META_DOCUMENT_AUTHOR  + @" -->");      
      
      /*-------------------------------
       * Start html and head section
       *------------------------------*/ 

      doc.Write(@"<html>");
	    doc.Write(@"<head>");

	    /*-------------------------------
       * Meta tags
       *------------------------------*/ 
		  
		  doc.Write(@"<meta http-equiv=""X-UA-Compatible"" content=""IE=edge"">");
      doc.Write(@"<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"">");
      doc.Write(@"<meta name=""author"" content=""" + File.META_DOCUMENT_AUTHOR + @"""/>");
      
      /*-------------------------------
       * Output document title in
       * html title
       *------------------------------*/ 

      doc.Write(@"<title>");       
      doc.Write(rd.title);	  
      doc.Write(@"</title>");

      /*-------------------------------
       * Render document wide style
       *------------------------------*/ 
       
      doc.Write (@"<style type=""text/css"">");
      doc.Write(style.ToString());
      doc.Write (@"</style>");           
     
     /*-------------------------------
      * Close head, start body 
      * and containing div
      *------------------------------*/ 

     doc.Write (@"</head>");
     doc.Write(@"<body>");
     doc.Write(@"<div id=""page"">");
      
     /*-------------------------------
      * Render data table
      *------------------------------*/ 			

      doc.Write(table.ToString());
      
      /*-------------------------------
       * Close up document
       *------------------------------*/ 			

      doc.Write(@"</div>");
      doc.Write(@"</body>");    		  
	    doc.Write(@"</html>");
      
	    /*-------------------------------
       * Build a byte array from the
       * string and return it
       *------------------------------*/ 
	  
      byte[] b1 = System.Text.Encoding.UTF8.GetBytes (doc.ToString());
      return b1;				
      
    }    
    
    /**************************************************************************
     * ReturnDataTableToHTMLFile */
    /**
     * Generates a stand-alone HTML document from a ReturnDataTable instance
     * 
     * @param  rd    ReturnDataTable
     ***************************************************************************/
    
    public static Byte[] ReturnDataTableToHTMLFile (ref ReturnDataTable rd)
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
       style.Append(@"table tbody tr td.dt-string {text-align: left;}");
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
          theadCols.Append (@"<th class=""thead-cols"">");
          theadCols.Append (col.sTitle); 
          theadCols.Append (@"</th>");    
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
            Object                      value;
            String                      dtCssClass;
           
            value = fld;
            
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
 
            
            dtCssClass = fldDef.sClass;
            dtCssClass = Util.valueDataClassToDtCssClass (valueDataClass);
            tbody.AppendFormat (@"<td class=""{0}"">", dtCssClass);
            
            if (valueHasLineBreaks) 
            {
              tbody.Append(@"<pre>");
              tbody.Append(valueString);
              tbody.Append(@"</pre>");
            }
            else
            {
              tbody.Append (valueString);                                        
            }
            
            tbody.Append (@"</td>");            
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
      
  }     
}
