using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;
using System.Collections.ObjectModel;
using System.Web;
using System.Text.RegularExpressions;
using System.IO;

using MBA.IdentifyData;
using MBA.Reporting;

// Excel Library

//using NPOI.POIFS.FileSystem;
//using NPOI.HSSF.UserModel.Contrib;

using NPOI.HSSF.UserModel;
using NPOI.HPSF;  // For document property, etc
using NPOI.SS.UserModel;
using NPOI.SS.Format;
using NPOI.HSSF.Util;
using NPOI.SS.Util;

namespace MBA
{
  public class Excel: File
  {
                 
    /***************************************************************************
     * ORIENTATION_X */
    /**
     * The various orientations
     ***************************************************************************/
        
	  new public static bool ORIENTATION_PORTRAIT  = false;
	  new public static bool ORIENTATION_LANDSCAPE = true;

 	  /***************************************************************************
     * BASE_FONT_X */
    /**
     * The various base fonts
     ***************************************************************************/   
    
    new public static readonly string BASE_FONT_TIMES_ROMAN = "Times New Roman";    
 	  
 	  /***************************************************************************
     * COLOR_X */
    /**
     * The various colors we will use
     ***************************************************************************/   
    
    new public static readonly short COLOR_BLACK      = HSSFColor.Black.Index;
    new public static readonly short COLOR_WHITE      = HSSFColor.White.Index;
    new public static readonly short COLOR_DARK_GREY  = HSSFColor.Grey50Percent.Index;
    new public static readonly short COLOR_LIGHT_GREY = HSSFColor.Grey25Percent.Index;
    new public static readonly short COLOR_DARK_RED   = HSSFColor.DarkRed.Index;
    new public static readonly short COLOR_DARK_GREEN = HSSFColor.DarkGreen.Index;
    
    /**************************************************************************
     * ALIGN_X */
    /**
     * For a given dataclass, determine the cells alignment.
     * These alignments are the same as the PDF alignments
     ***************************************************************************/
  
    new public static readonly HorizontalAlignment ALIGN_LEFT   = HorizontalAlignment.Left;
    new public static readonly HorizontalAlignment ALIGN_CENTER = HorizontalAlignment.Center;
    new public static readonly HorizontalAlignment ALIGN_RIGHT  = HorizontalAlignment.Right;
    
    /**************************************************************************
     * DetermineCellAlignment */
    /**
     * For a given dataclass, determine the cells alignment.
     ***************************************************************************/
        
    new protected static HorizontalAlignment DetermineCellAlignment (IdentifiedValue.DataClass dc)
    {
      int align = File.DetermineCellAlignment(dc);      
      HorizontalAlignment alignment = Excel.ALIGN_LEFT;      
      
      if (align == File.ALIGN_LEFT)   alignment = Excel.ALIGN_LEFT;
      if (align == File.ALIGN_CENTER) alignment = Excel.ALIGN_CENTER;
      if (align == File.ALIGN_RIGHT)  alignment = Excel.ALIGN_RIGHT;
      
      return alignment;
    }

    /**************************************************************************
     * CreateFonts */
    /**
     * Used by ReturnRptData to hold font references
     ***************************************************************************/   
         
    protected static void CreateFonts(ref HSSFWorkbook doc, ref Dictionary<string,IFont> fonts)
    {            
      IFont dflt = doc.CreateFont();
      dflt.Boldweight         = (short) FontBoldWeight.Normal;
      dflt.FontHeightInPoints = (short) File.FONT_SIZE_LEAF;      
      dflt.FontName = BASE_FONT_TIMES_ROMAN;
      fonts.Add("dflt",dflt);
      
      IFont title1 = doc.CreateFont();
      title1.Boldweight         = (short) FontBoldWeight.Bold;
      title1.FontHeightInPoints = (short) File.FONT_SIZE_TITLE_1;      
      title1.FontName = BASE_FONT_TIMES_ROMAN;
      fonts.Add("title1",title1);
      
      IFont title2 = doc.CreateFont();
      title2.Boldweight         = (short) FontBoldWeight.Normal;
      title2.FontHeightInPoints = (short) File.FONT_SIZE_TITLE_2;      
      title2.FontName = BASE_FONT_TIMES_ROMAN;
      fonts.Add("title2",title2);

      IFont title3 = doc.CreateFont();
      title3.Boldweight         = (short) FontBoldWeight.Normal;
      title3.FontHeightInPoints = (short) File.FONT_SIZE_TITLE_3;      
      title3.FontName = BASE_FONT_TIMES_ROMAN;
      fonts.Add("title3",title3);
      
      IFont colhdr = doc.CreateFont();
      colhdr.Boldweight         = (short) FontBoldWeight.Bold;
      colhdr.FontHeightInPoints = (short) File.FONT_SIZE_COL_HDR; 
      colhdr.FontName = BASE_FONT_TIMES_ROMAN;
      fonts.Add("colhdr",colhdr);

      IFont branch = doc.CreateFont();
      branch.Boldweight         = (short) FontBoldWeight.Normal;
      branch.FontHeightInPoints = (short) File.FONT_SIZE_BRANCH;
      branch.FontName = BASE_FONT_TIMES_ROMAN;
      fonts.Add("branch",branch);
      
      IFont leafdet   = doc.CreateFont();
      leafdet.Boldweight         = (short) FontBoldWeight.Normal;
      leafdet.FontHeightInPoints = (short) File.FONT_SIZE_LEAF;
      leafdet.FontName = BASE_FONT_TIMES_ROMAN;
      fonts.Add("leafdet",leafdet);
      
      IFont leafagr   = doc.CreateFont();
      leafagr.Boldweight         = (short) FontBoldWeight.Bold;
      leafagr.FontHeightInPoints = (short) File.FONT_SIZE_LEAF;
      leafagr.FontName = BASE_FONT_TIMES_ROMAN;
      fonts.Add("leafagr",leafagr);
      
      IFont footer   = doc.CreateFont();
      footer.Boldweight         = (short) FontBoldWeight.Bold;
      footer.FontHeightInPoints = (short) File.FONT_SIZE_FOOTER;
      footer.Color              = COLOR_DARK_GREY;
      footer.FontName = BASE_FONT_TIMES_ROMAN;
      fonts.Add("footer",footer);
                
    }

    /**************************************************************************
     * CreateStyles */
    /**
     * Used by ReturnRptData to hold style references
     ***************************************************************************/   
    
    protected static void CreateStyles(ref HSSFWorkbook doc, 
                                       ref Dictionary<string,IFont> fonts, 
                                       ref Dictionary<string, ICellStyle> styles)
    
    {            
      ICellStyle dflt = doc.CreateCellStyle();
      dflt.Alignment = Excel.ALIGN_LEFT;
      dflt.SetFont(fonts["dflt"]);
      dflt.VerticalAlignment = VerticalAlignment.Center;
      dflt.FillForegroundColor = COLOR_WHITE;
      dflt.FillPattern = FillPattern.SolidForeground;
      styles.Add("dflt",dflt);

      ICellStyle title1 = doc.CreateCellStyle();
      title1.Alignment = Excel.ALIGN_CENTER;
      title1.SetFont(fonts["title1"]);
      title1.VerticalAlignment = VerticalAlignment.Center; 
      title1.FillForegroundColor = COLOR_WHITE;
      title1.FillPattern = FillPattern.SolidForeground;      
      styles.Add("title1",title1);
      
      ICellStyle title2 = doc.CreateCellStyle();
      title2.Alignment = Excel.ALIGN_CENTER;
      title2.VerticalAlignment = VerticalAlignment.Top;
      title2.FillForegroundColor = COLOR_WHITE;    
      title2.FillPattern = FillPattern.SolidForeground;

      title2.SetFont(fonts["title2"]);
      styles.Add("title2",title2);
      
      ICellStyle title3 = doc.CreateCellStyle();
      title3.Alignment = Excel.ALIGN_CENTER;
      title3.VerticalAlignment = VerticalAlignment.Top;
      title3.FillForegroundColor = COLOR_WHITE;
      title3.FillPattern = FillPattern.SolidForeground;
      title3.SetFont(fonts["title3"]);
      styles.Add("title3",title3);

      ICellStyle colhdrleft = doc.CreateCellStyle();
      colhdrleft.Alignment = Excel.ALIGN_LEFT;
      colhdrleft.VerticalAlignment = VerticalAlignment.Bottom;
      colhdrleft.FillForegroundColor = COLOR_WHITE;    
      colhdrleft.FillPattern = FillPattern.SolidForeground;
      colhdrleft.SetFont(fonts["colhdr"]);
      colhdrleft.BorderBottom = BorderStyle.Thin;
      colhdrleft.WrapText = true;
      styles.Add("colhdrleft",colhdrleft);
      
      ICellStyle colhdrcenter = doc.CreateCellStyle();
      colhdrcenter.Alignment = Excel.ALIGN_CENTER;
      colhdrcenter.VerticalAlignment = VerticalAlignment.Bottom;
      colhdrcenter.FillForegroundColor = COLOR_WHITE;
      colhdrcenter.FillPattern = FillPattern.SolidForeground;
      colhdrcenter.SetFont(fonts["colhdr"]);
      colhdrcenter.BorderBottom = BorderStyle.Thin;
      colhdrcenter.WrapText = true;
      styles.Add("colhdrcenter",colhdrcenter);

      ICellStyle colhdrright = doc.CreateCellStyle();
      colhdrright.Alignment = Excel.ALIGN_RIGHT;
      colhdrright.VerticalAlignment = VerticalAlignment.Bottom;
      colhdrright.FillForegroundColor = COLOR_WHITE;
      colhdrright.FillPattern = FillPattern.SolidForeground;
      colhdrright.SetFont(fonts["colhdr"]);
      colhdrright.BorderBottom = BorderStyle.Thin;
      colhdrright.WrapText = true;
      styles.Add("colhdrright",colhdrright);

      ICellStyle branch = doc.CreateCellStyle();
      branch.Alignment = Excel.ALIGN_LEFT;
      branch.VerticalAlignment = VerticalAlignment.Center;
      branch.FillForegroundColor = COLOR_WHITE;
      branch.FillPattern = FillPattern.SolidForeground;
      branch.SetFont(fonts["branch"]);
      styles.Add("branch",branch);
      
      ICellStyle coldetleft = doc.CreateCellStyle();
      coldetleft.Alignment = Excel.ALIGN_LEFT;
      coldetleft.FillForegroundColor = COLOR_WHITE;
      coldetleft.FillPattern = FillPattern.SolidForeground;
      coldetleft.SetFont(fonts["leafdet"]);
      styles.Add("coldetleft",coldetleft);
      
      ICellStyle coldetcenter = doc.CreateCellStyle();
      coldetcenter.Alignment = Excel.ALIGN_CENTER;
      coldetcenter.FillForegroundColor = COLOR_WHITE;
      coldetcenter.FillPattern = FillPattern.SolidForeground;
      coldetcenter.SetFont(fonts["leafdet"]);
      styles.Add("coldetcenter",coldetcenter);
      
      ICellStyle coldetright = doc.CreateCellStyle();
      coldetright.Alignment = Excel.ALIGN_RIGHT;
      coldetright.FillForegroundColor = COLOR_WHITE;
      coldetright.FillPattern = FillPattern.SolidForeground;
      coldetright.SetFont(fonts["leafdet"]);
      styles.Add("coldetright",coldetright);
      
      ICellStyle colagrleft = doc.CreateCellStyle();
      colagrleft.Alignment = Excel.ALIGN_LEFT;
      colagrleft.FillForegroundColor = COLOR_WHITE;
      colagrleft.FillPattern = FillPattern.SolidForeground;
      colagrleft.SetFont(fonts["leafagr"]);
      colagrleft.BorderTop = BorderStyle.Thin;
      styles.Add("colagrleft",colagrleft);
     
      ICellStyle colagrcenter = doc.CreateCellStyle();
      colagrcenter.Alignment = Excel.ALIGN_CENTER;
      colagrcenter.FillForegroundColor = COLOR_WHITE;
      colagrcenter.FillPattern = FillPattern.SolidForeground;
      colagrcenter.SetFont(fonts["leafagr"]);
      colagrcenter.BorderTop = BorderStyle.Thin;
      styles.Add("colagrcenter",colagrcenter);
      
      ICellStyle colagrright = doc.CreateCellStyle();
      colagrright.Alignment = Excel.ALIGN_RIGHT;
      colagrright.FillForegroundColor = COLOR_WHITE;
      colagrright.FillPattern = FillPattern.SolidForeground;
      colagrright.SetFont(fonts["leafagr"]);
      colagrright.BorderTop = BorderStyle.Thin;
      styles.Add("colagrright",colagrright);

      ICellStyle footer = doc.CreateCellStyle();
      footer.Alignment = Excel.ALIGN_CENTER;      
      footer.FillForegroundColor = COLOR_WHITE;
      footer.FillPattern = FillPattern.SolidForeground;
      footer.SetFont(fonts["footer"]);
      styles.Add("footer",footer);
                       
    }
    
    /**************************************************************************
     * CreateCell */
    /**
     * Used by ReturnRptData to create cells
     ***************************************************************************/   

    
    protected static ICell CreateCell(ref Dictionary <string, ICellStyle> styles, 
                                     ref IRow row, 
                                     ref int colCtr, 
                                     string rowclass,
                                     IdentifiedValue.DataClass dc,
                                     int size,
                                     IdentifiedValue value)
	  {
      
      ICell cell = row.CreateCell(colCtr);
      
      /*-------------------------------
       * Store the value 
       * TODO: For formatting purposes
       * we are storing everything
       * as a string right now
       *------------------------------*/
        
      cell.SetCellType(CellType.String);
      cell.SetCellValue(value.valueStrFormatted);
      
      
      string style = "";
      
      if (rowclass == "branch")
      {
        style = rowclass;
      }
      else /* colhdr, coldet, colagr */
      {
        HorizontalAlignment ha = DetermineCellAlignment(dc);

        if (ha == HorizontalAlignment.Left)   style = rowclass + "left";
        if (ha == HorizontalAlignment.Center) style = rowclass + "center";
        if (ha == HorizontalAlignment.Right)  style = rowclass + "right";
        
      }

      cell.CellStyle = styles[style]; 
      
      
      return cell;
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
      return File.GenerateFileName(folder, name, "xls");
    }
    
    /**************************************************************************
     * ReturnRptDataToXLS */
    /**
     * For a given ReturnRptData instance create a xls doc.
     ***************************************************************************/
    
    public static Byte[] ReturnRptDataToXLS (ref ReturnRptData rd)
    {
     
      /*-------------------------------
       * Determine page alignment
       *------------------------------*/

      bool orientation = ORIENTATION_PORTRAIT;

      if (rd.output_orientation == File.ORIENTATION_LANDSCAPE)
        orientation = ORIENTATION_LANDSCAPE;
      
      /*-------------------------------
       * Create Excel workbook and
       * a memory stream we will assign
       * it to.
       *------------------------------*/

      MemoryStream ms  = new MemoryStream();
      HSSFWorkbook doc = new HSSFWorkbook();      
      
      /*-------------------------------
       * Create an Excel sheet and
       * attach it to our workbook
       *------------------------------*/   
         
      HSSFSheet table = (HSSFSheet) doc.CreateSheet("Report Data");
      
      /*-------------------------------
       * Setup margins and initial
       * print settings
       *------------------------------*/   
      
      table.SetMargin(MarginType.RightMargin,  (double) 0.5);
      table.SetMargin(MarginType.TopMargin,    (double) 0.5);
      table.SetMargin(MarginType.LeftMargin,   (double) 0.5);
      table.SetMargin(MarginType.BottomMargin, (double) 1);
      
      table.PrintSetup.Copies    = 1;      
      table.PrintSetup.Landscape = orientation;
      table.PrintSetup.PaperSize = (short) PaperSize.US_Letter;
      table.FitToPage            = false;
      table.IsPrintGridlines     = false;

      /*-------------------------------
       * Create counters to keep track
       * of current row/column.  The
       * Excel library requires these.
       *------------------------------*/

      int rowCtr   = 0;
      int colCtr   = 0;
      int lastCol  = 0;
      int lastRow  = 0;
      
      int titlesEndRow    = 0;
      int headersEndRow   = 0;
      int footersStartRow = 0;
      
      /*-------------------------------
       * Create row and cell objects
       * to hold references to instances
       * of these objects that the 
       * Excel library creates.
       *------------------------------*/
      
      IRow  currentRow  = null;         	           
      ICell currentCell = null;
             
      /*-------------------------------
       * Create various objects we will
       * use for this xls starting with
       * fonts
       *------------------------------*/ 
      
      Dictionary <string,IFont> fonts = new Dictionary<string,IFont>();
      Dictionary <string,ICellStyle> styles = new Dictionary<string, ICellStyle>();
      
      CreateFonts  (ref doc, ref fonts);
      CreateStyles (ref doc, ref fonts, ref styles);
                 
      /*-------------------------------
       * Create our title rows
       *------------------------------*/
      
      rowCtr = 0;
	          
	    foreach (TitleOrFooter title in rd.resultSetTitles)
      {
        if (!Util.IsNullOrEmpty(title.name))
        {
          
          // Create new row and column and add title
          
          currentRow = table.CreateRow(rowCtr);                                 
          currentCell = currentRow.CreateCell(0);
          currentCell.SetCellType(CellType.String);
          currentCell.SetCellValue(title.name);          
          
          // Set style and calculate row height based on style
          
          string style = "title" + title.position.ToString();
          currentCell.CellStyle = styles[style];
          short fh = currentCell.CellStyle.GetFont(doc).FontHeightInPoints;
          currentRow.HeightInPoints = fh * 1.3f;
          rowCtr++;
        
        }
      }
      
      titlesEndRow = rowCtr-1;

      /*-------------------------------
       * Create delegates
       *------------------------------*/

	   TraverseNodesCallback startheader = delegate (Object[] args)
	   {
	     int     numCols     = (int)       args[0];
	     int     totalWidth  = (int)       args[1];
	     int[]   colWidths   = (int[])     args[2];
	     float[] colWidthPer = (float[])   args[3];
	    	    
	        
	    /*-------------------------------
       * Establish default styles
       *------------------------------*/
       
	    for (int c=0;c<numCols;c++)
	      table.SetDefaultColumnStyle(c,styles["dflt"]);
	    
	    /*-------------------------------
       * Create column header row 
       *------------------------------*/
       
	     currentRow = table.CreateRow(rowCtr); 	     	     
       rowCtr++;
       colCtr = 0;            
	   };
	  
	   TraverseNodesCallback headerop = delegate(Object[] args)
	   {
	     InputColumnDefinition def = (InputColumnDefinition) args[0];	  
	     
	     // Create cell
	     
	     //def.name
	     
	     IdentifiedValue value = IdentifyData.IdentifiedValue.Parse(def.name);
	     
	     currentCell = CreateCell(ref styles, ref currentRow, ref colCtr, "colhdr", def.dataclass, def.width, value);	     
	     
	     // Calculate width
	     int colWidth = def.width * 255;
	     table.SetColumnWidth (colCtr, colWidth);	     
           
	     colCtr++;
	   };
	  
	   TraverseNodesCallback endheader = delegate(Object[] args)
	   {
	      int numCols = (int) args[0];
	      lastCol = colCtr-1;	  

	   	  // Last cell should be a header cell, use it calculate header row height
	   	  
	   	  short fh = currentCell.CellStyle.GetFont(doc).FontHeightInPoints;
        currentRow.HeightInPoints = fh * 3f;
        
        // Add extra row
        
        currentRow = table.CreateRow(rowCtr);
        rowCtr++;

	      headersEndRow = rowCtr - 1;
	   
	   };
	  
	   GenericCallBack startbody = delegate()
	   {	  
	   };
	  
	  
	   TraverseNodesOperation startrow = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	   {
	    
	     string rowType         = (string) args[0];
	     string rowStripe       = (string) args[1];	    
	     int    fillto          = (int)    args[2];
	     int    agrTitlePos     = (int)    args[3];
       string agrTitleLabel   = (string) args[4];
	     int    agrTitleSpan    = (int)    args[5];
	     
	     colCtr = 0;
	     
	     // Create new row
	     
	     currentRow = table.CreateRow(rowCtr); 
	    
	     // Fill
	     
	     for (int fill = 0; fill < fillto; fill++)
	     {	       
	       currentCell = currentRow.CreateCell(colCtr);	       
	       currentCell.SetCellType(CellType.Blank);
	       currentCell.CellStyle = styles["dflt"];
	       colCtr++;
	     }
	   	                	     
	     /*-------------------------------
        * Insert aggregate title label
        *------------------------------*/ 
        
	     if (agrTitlePos != -1)
	     {	       
	     
	       /*-------------------------------
          * There is no column span 
          * option so we have to simulate
          * this by advancing our column
          * counter
          *------------------------------*/         

	       if (agrTitleSpan > 1)
	       {
	         int spannedcols = agrTitleSpan - 1;
	         colCtr = colCtr + spannedcols;
	       }
	       
	       ICell cell = currentRow.GetCell(agrTitlePos);
	   
	       if (agrTitlePos == 0)
	         cell.CellStyle = styles["branch"];
         else
           cell.CellStyle = styles["coldetleft"];
           
	       cell.SetCellValue(agrTitleLabel);	       	       
	     }
	    
	     rowCtr++;
	    	    	  
	  };
	  
	  TraverseNodesOperation nodeop  = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	    
	    int span = (int) args[0];
	    	    	                      
	    short fh = currentCell.CellStyle.GetFont(doc).FontHeightInPoints;
      float hp = 1.3f;
      	   
      if (f.nodetype == TreeNodeType.BRANCH)
      {
        currentCell = CreateCell(ref styles, ref currentRow, ref colCtr, "branch", f.identifiedValue.dataClass, 1, f.identifiedValue);          
        hp = 3f;
        currentRow.HeightInPoints = fh * hp;
        table.AddMergedRegion(new CellRangeAddress(currentRow.RowNum,currentRow.RowNum,0,lastCol));   
        return;
      }
      
      if (f.rowtype == RowAttribute.DETAIL)
      {
        currentCell = CreateCell(ref styles, ref currentRow, ref colCtr, "coldet", f.identifiedValue.dataClass, 1, f.identifiedValue);        
      }
      else
      {
        currentCell = CreateCell(ref styles, ref currentRow, ref colCtr, "colagr", f.identifiedValue.dataClass, 1, f.identifiedValue);              
      }

      currentRow.HeightInPoints = fh * hp;
      
      colCtr++;
	  };
	  
	  TraverseNodesOperation endrow = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {	  
	  };

	  GenericCallBack endbody = delegate()
	  {	    
	      // Add extra row
        currentRow = table.CreateRow(rowCtr);
        rowCtr++;
	  };

    /*-------------------------------
     * Create table
     *------------------------------*/ 
	  
	  int safetyCtr = 0;
	  int levelCtr  = DataTree.ROOT_LEVEL;

	  DataTree.TraverseForReport (ref rd.datatree,
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
       * Create our footer 
       *------------------------------*/
      
      footersStartRow = rowCtr;

	    foreach (TitleOrFooter msg in rd.resultSetFooters)
      {
        if (!Util.IsNullOrEmpty(msg.name))
        {
          currentRow = table.CreateRow(rowCtr);
          currentCell = currentRow.CreateCell(0);  // We are using the first cell
          currentCell.SetCellValue(msg.name);
          currentCell.CellStyle = styles["footer"];
          rowCtr++;
        }
      }
      
      lastRow = rowCtr - 1 ;
      
      /*-------------------------------
       * Get our one line title
       * we will use this as part of
       * our meta data
       *------------------------------*/   

      string titleline = rd.title;
      
      /*-------------------------------
       * Setup print footer
       *------------------------------*/
            
      table.Footer.Center = "";      
      table.Footer.Left   = "Page " + HSSFFooter.Page + " of " + HSSFFooter.NumPages;
      table.Footer.Right  = "Created On " + DateTime.Now.ToString();
      
      /*-------------------------------
       * Freeze title and column 
       * headings
       *------------------------------*/
       
       table.CreateFreezePane(0, headersEndRow);
      
      /*-------------------------------
       * Set print area and 
       * fit document to 1 page wide
       * by an estimated number of
       * pages high.
       *------------------------------*/
       
       doc.SetPrintArea (0, 0, lastCol, 0, lastRow);

       table.Autobreaks = true;
       table.FitToPage  = true;
       
       int estHeight = lastRow / 25;
       
       table.PrintSetup.FitHeight = (short) estHeight;
       table.PrintSetup.FitWidth  = (short) 1;
             
      /*-------------------------------
       * Create merged regions to center
       * title and footer across the 
       * document
       *------------------------------*/
       
      for (int row=0;row<=titlesEndRow;row++)
        table.AddMergedRegion(new CellRangeAddress(row,row,0,lastCol));       
       
      for (int row=footersStartRow;row<=lastRow;row++)
        table.AddMergedRegion(new CellRangeAddress(row,row,0,lastCol));
       	    
      /*-------------------------------
       * Set repeating rows and columns
       * for printing
       *------------------------------*/
       
       doc.SetRepeatingRowsAndColumns (0, -1, -1, 0,               headersEndRow);
       doc.SetRepeatingRowsAndColumns (0, -1, -1, footersStartRow, lastRow);


	    /*-------------------------------
       * Add meta data to the document
       *------------------------------*/ 
       
      DocumentSummaryInformation dsi = PropertySetFactory.CreateDocumentSummaryInformation();
      SummaryInformation         si  = PropertySetFactory.CreateSummaryInformation();

      dsi.Company = File.META_DOCUMENT_AUTHOR;
      si.Subject  = titleline;
       
      doc.DocumentSummaryInformation = dsi;
      doc.SummaryInformation         = si;
       
      /*-------------------------------
       * Set active cell
       *------------------------------*/ 
       
      table.SetActiveCell (0, 0);          
	    
      /*-------------------------------
       * Protect sheet (no password)
       *------------------------------*/ 
       
      table.ProtectSheet("");
       
	    /*-------------------------------
       * Build a byte array from the
       * document and return it
       *------------------------------*/ 

	    doc.Write(ms);
      byte[] b1 = ms.ToArray();
      return b1;				
     
    }
    
    /**************************************************************************
     * ReturnDataTableToXLS */
    /**
     * For a given ReturnDataTable instance create a xls doc.
     ***************************************************************************/
    
    public static Byte[] ReturnDataTableToXLS (ref ReturnDataTable rd)
    {
      
      /*-------------------------------
       * Create Excel workbook and
       * a memory stream we will assign
       * it to.
       *------------------------------*/

      MemoryStream ms  = new MemoryStream();
      HSSFWorkbook doc = new HSSFWorkbook();

      /*-------------------------------
       * Create an Excel sheet and
       * attach it to our workbook.
       * This will be our table
       *------------------------------*/

      ISheet table = doc.CreateSheet(rd.tableName);
      
      table.SetMargin(MarginType.RightMargin,  (double) 0.5);
      table.SetMargin(MarginType.TopMargin,    (double) 0.5);
      table.SetMargin(MarginType.LeftMargin,   (double) 0.5);
      table.SetMargin(MarginType.BottomMargin, (double) 1);
      
      table.PrintSetup.Copies    = 1;      
      table.PrintSetup.Landscape = true;
      table.PrintSetup.PaperSize = (short) PaperSize.US_Letter;
      table.FitToPage            = false;
      table.IsPrintGridlines     = false;
                      
      /*-------------------------------
       * Create counters to keep track
       * of current row/column.  The
       * Excel library requires these.
       *------------------------------*/

      int rowCtr = 0;
      int colCtr = 0;
      
      int lastCol = 0;
      int lastRow = 0;
      
      /*-------------------------------
       * Create row and cell objects
       * to hold references to instances
       * of these objects that the 
       * Excel library creates.
       *------------------------------*/
      
      IRow  currentRow  = null;         	           
      ICell currentCell = null;

      /*-------------------------------
       * Create various objects we will
       * use for this xls starting with
       * fonts
       *------------------------------*/ 
       
      IFont cellfontTit = doc.CreateFont();
      cellfontTit.Boldweight         = (short) FontBoldWeight.Bold;
      cellfontTit.FontHeightInPoints = (short) 18;      
      
      IFont cellfontHdr = doc.CreateFont();
      cellfontHdr.Boldweight         = (short) FontBoldWeight.Bold;
      cellfontHdr.FontHeightInPoints = (short) 10;
      
      IFont cellfont = doc.CreateFont();
      cellfont.FontHeightInPoints = (short) 10;
      
      IFont cellfontFtr = doc.CreateFont();
      cellfontFtr.Boldweight         = (short) FontBoldWeight.Bold;
      cellfontFtr.FontHeightInPoints = (short) 10;
      cellfontFtr.Color              =  HSSFColor.Grey80Percent.Index;
                     
      /*-------------------------------
       * Then styles.
       *------------------------------*/ 
      
      ICellStyle styleCellTit = doc.CreateCellStyle();
      styleCellTit.SetFont(cellfontTit);
      styleCellTit.Alignment = HorizontalAlignment.Center;     
        
      ICellStyle styleCellHdrLeft = doc.CreateCellStyle();
      styleCellHdrLeft.SetFont(cellfontHdr);
      styleCellHdrLeft.BorderBottom = BorderStyle.Thin;
      styleCellHdrLeft.Alignment    = HorizontalAlignment.Left;

      ICellStyle styleCellHdrCenter = doc.CreateCellStyle();
      styleCellHdrCenter.SetFont(cellfontHdr);
      styleCellHdrCenter.BorderBottom = BorderStyle.Thin;
      styleCellHdrCenter.Alignment    = HorizontalAlignment.Center;

      ICellStyle styleCellHdrRight = doc.CreateCellStyle();
      styleCellHdrRight.SetFont(cellfontHdr);
      styleCellHdrRight.BorderBottom = BorderStyle.Thin;
      styleCellHdrRight.Alignment    = HorizontalAlignment.Right;

      
      ICellStyle styleCellLeft = doc.CreateCellStyle();
      styleCellLeft.SetFont(cellfont);
      styleCellLeft.Alignment = HorizontalAlignment.Left;
      
      ICellStyle styleCellCenter = doc.CreateCellStyle();
      styleCellCenter.SetFont(cellfont);
      styleCellCenter.Alignment = HorizontalAlignment.Center;
      
      ICellStyle styleCellRight = doc.CreateCellStyle();
      styleCellRight.SetFont(cellfont);
      styleCellRight.Alignment = HorizontalAlignment.Right;
       
      ICellStyle styleCellFtr = doc.CreateCellStyle();
      styleCellFtr.SetFont(cellfontFtr);
      styleCellFtr.Alignment = HorizontalAlignment.Center;                                    
                      
      /*-------------------------------
       * Create our header starting
       * with the title 
       *------------------------------*/
      
      currentRow = table.CreateRow(rowCtr);
      currentRow.HeightInPoints = (short) 26;
      
      currentCell = currentRow.CreateCell(0);  // We are using the first cell
      currentCell.SetCellValue(rd.tableName);
      currentCell.CellStyle = styleCellTit;
      
      rowCtr++;
	                
      /*-------------------------------
       * Next add our column headers 
       * and count the # of visible
       * columns
       *------------------------------*/ 
       
       lastCol = 0;
       colCtr  = 0;
       
       currentRow = table.CreateRow(rowCtr);
       currentRow.HeightInPoints = (short) 22;
       
       foreach (aoColumn col in rd.aoColumns)
       {
         
         if (col.bVisible)
         { 
           // Create the header cell
           
           currentCell = currentRow.CreateCell(colCtr);
           
           HorizontalAlignment a = DetermineCellAlignment(col.dataclass);
           
           if (a == HorizontalAlignment.Left)   currentCell.CellStyle = styleCellHdrLeft;
           if (a == HorizontalAlignment.Center) currentCell.CellStyle = styleCellHdrCenter;
           if (a == HorizontalAlignment.Right)  currentCell.CellStyle = styleCellHdrRight;
           
  	       currentCell.SetCellValue(col.sTitle);	         
	         colCtr++;
	         	                  
         }
       }
	     
	     rowCtr++;
	     lastCol = colCtr-1;
	          
       /*-------------------------------
        * Generate our record rows 
        *------------------------------*/
                
        foreach (Object[] arow in rd.aaData)        
        {
          // Create new row
          currentRow = table.CreateRow(rowCtr);
          
          // Reset ctrs
          colCtr = 0;
          int colPtr = 0;
          
          foreach (Object fld in arow)
          {
            aoColumn fldDef = rd.aoColumns[colPtr];

            if (fldDef.bVisible)
            {
              currentCell = currentRow.CreateCell(colCtr);  
              HorizontalAlignment a = DetermineCellAlignment(fldDef.dataclass);
           
              if (a == HorizontalAlignment.Left)   currentCell.CellStyle = styleCellLeft;
              if (a == HorizontalAlignment.Center) currentCell.CellStyle = styleCellCenter;
              if (a == HorizontalAlignment.Right)  currentCell.CellStyle = styleCellRight;
              
              string value = fld.ToString();              
              
              if (Util.IsNullOrEmpty(value)) 
              {
                currentCell.SetCellValue("");
              }
              else
              {
                if (fldDef.dataclass == IdentifiedValue.DataClass.NUMBER)
                {
                  double v;
                  if (Double.TryParse(value, out v))
                    currentCell.SetCellValue(v);                                                                                         
                }              
                else if (fldDef.dataclass == IdentifiedValue.DataClass.DATE)
                {
                    currentCell.SetCellValue(value);
                }
                else if (fldDef.dataclass == IdentifiedValue.DataClass.BOOL)
                {
                  currentCell.SetCellValue(value);
                }
                else 
                {
                  string v = fld.ToString();
                  currentCell.SetCellValue(v);
                }
              }     
              colCtr++;            
            }              
            colPtr++;
          }
                    
          rowCtr++;
        }

      /*-------------------------------
       * Create our footer row
       *------------------------------*/

      /*currentRow = table.CreateRow(rowCtr);
      currentCell = currentRow.CreateCell(0);  // We are using the first cell
      currentCell.SetCellValue(rd.tableFooter);
      currentCell.CellStyle = styleCellFtr;
      rowCtr++;
      */
      
      /*-------------------------------
       * Determine last row
       *------------------------------*/
    
      lastRow = rowCtr - 1;
            
      /*-------------------------------
       * Setup print footer
       *------------------------------*/
      
      table.Footer.Center = rd.tableFooter;  
      table.Footer.Left   = "Page " + HSSFFooter.Page + " of " + HSSFFooter.NumPages;
      table.Footer.Right  = DateTime.Now.ToString();
      
      /*-------------------------------
       * Autosize our columns,
       *------------------------------*/
        
       for (int i=0;i<colCtr;i++)
       {
         table.AutoSizeColumn(i);
       }
      
      /*-------------------------------
       * Freeze title and column 
       * headings
       *------------------------------*/
       
       table.CreateFreezePane(0,2);

      /*-------------------------------
       * Set repeating rows and columns
       * for printing
       *------------------------------*/
       
       doc.SetRepeatingRowsAndColumns(0, -1, -1, 0, 1);

      /*-------------------------------
       * Set print area and 
       * fit document to 1 page wide
       * by an estimated number of
       * pages high.
       *------------------------------*/
       
       doc.SetPrintArea (0, 0, lastCol, 0, lastRow);

       table.Autobreaks = true;
       table.FitToPage  = true;
       
       int estHeight = lastRow / 25;
       
       table.PrintSetup.FitHeight = (short) estHeight;
       table.PrintSetup.FitWidth  = (short) 1;
             
      /*-------------------------------
       * Create merged regions to center
       * title and footer across the 
       * document
       *------------------------------*/

       table.AddMergedRegion(new CellRangeAddress(0, 0, 0, lastCol));
       //table.AddMergedRegion(new CellRangeAddress(lastRow,lastRow,0,lastCol));
       
	    /*-------------------------------
       * Add meta data to the document
       *------------------------------*/ 

       DocumentSummaryInformation dsi = PropertySetFactory.CreateDocumentSummaryInformation();
       SummaryInformation         si  = PropertySetFactory.CreateSummaryInformation();

       dsi.Company = File.META_DOCUMENT_AUTHOR;
       si.Subject  = rd.tableName;
       
       doc.DocumentSummaryInformation = dsi;
       doc.SummaryInformation         = si;
       
      /*-------------------------------
       * Set active cell
       *------------------------------*/ 
       
       table.SetActiveCell (0, 0);

	    /*-------------------------------
       * Build a byte array from the
       * document and return it
       *------------------------------*/ 

	    doc.Write(ms);
      byte[] b1 = ms.ToArray();
      return b1;	
    }    
    
  }
}
