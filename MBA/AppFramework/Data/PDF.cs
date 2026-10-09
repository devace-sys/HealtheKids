using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Collections.ObjectModel;
using System.Web;
using System.IO;

using MBA.IdentifyData;
using MBA.Reporting;

// PDF

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.html;

namespace MBA
{
  
  /***************************************************************************
   * PDF */
  /**
   * Various methods for generating PDF files from various data structures
   * Supporting methods for style rule determination and various PDF
   * specific support classes and methods.
   ***************************************************************************/
  
  public class PDF:File
  {  
	  /***************************************************************************
     * PAGE_SIZE_X */
    /**
     * The various page sizes we will use
     ***************************************************************************/
        
	  new public static readonly Rectangle ORIENTATION_PORTRAIT  = PageSize.LETTER;
	  new public static readonly Rectangle ORIENTATION_LANDSCAPE = PageSize.LETTER.Rotate();
	

	  /***************************************************************************
     * BASE_FONT_ */
    /**
     * The various fonts we will use
     ***************************************************************************/
    
    new public static readonly string BASE_FONT_TIMES_ROMAN      = BaseFont.TIMES_ROMAN;
    new public static readonly string BASE_FONT_TIMES_ROMAN_BOLD = BaseFont.TIMES_BOLD;
           
    /**************************************************************************
     * CreateTitleCells */
    /**
     * Create a cell
     ***************************************************************************/
     
    protected static PdfPCell[] CreateTitleCells (TitleOrFooter[] titles)
    {
      List<PdfPCell> cells = new List<PdfPCell>();
      
      foreach (TitleOrFooter title in titles)
      {
        if (!Util.IsNullOrEmpty(title.name))
        { 
          CellStyle cs   = DetermineCellStyleTitle(title);      
    	    PdfPCell cell  = CreateCell(cs,title.name,1);           
          cells.Add(cell);
        }
      }
     
     PdfPCell padcell = new PdfPCell(new Phrase(Chunk.NEWLINE));
     padcell.Border = Rectangle.NO_BORDER;
     cells.Add(padcell);

     return cells.ToArray();

    }
    
    /**************************************************************************
     * CreateFooterCells */
    /**
     * Create a cell
     ***************************************************************************/
     
    protected static PdfPCell[] CreateFooterCells (TitleOrFooter[] footers)
    {
      List<PdfPCell> cells = new List<PdfPCell>();
      
      PdfPCell padcell = new PdfPCell(new Phrase(Chunk.NEWLINE));
      padcell.Border = Rectangle.NO_BORDER;
      cells.Add(padcell);
      
      foreach (TitleOrFooter footer in footers)
      {
        if (!Util.IsNullOrEmpty(footer.name))
        { 
          CellStyle cs   = DetermineCellStyleFooter(footer);      
    	    PdfPCell cell  = CreateCell(cs,footer.name,1);    	               
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
    
    protected static PdfPCell CreateCell(InputColumnDefinition d, int span)
    {
      CellStyle cs = DetermineCellStyleColumn(d);
	    return CreateCell(cs, d.name, span);	    
    }
    
    protected static PdfPCell CreateCell(DataTreeNode f, int span, string evenodd)
	  {
	    CellStyle cs = DetermineCellStyleColumn(f, evenodd);
	    return CreateCell(cs, f.identifiedValue.valueStrFormatted, span);	          	    
	  }
	  
	  protected static PdfPCell CreateCell (int agrTitlePos, string agrTitleLabel, int agrTitleSpan)
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
	    
	    PdfPCell cell = CreateCell (cs, agrTitleLabel, agrTitleSpan);	    
	    
	    return cell;
	  }
	  
	  protected static PdfPCell CreateCell (CellStyle cs, string value, int span)
	  {
	    float     fontsize  = (float) cs.font_size;
	    Color     fontcolor = new Color (cs.font_color);
	    Color     bkgcolor  = new Color (cs.background_color);	    
	    
	    Font cfont;
	    
	    if (!cs.bold)
	      cfont = FontFactory.GetFont(BASE_FONT_TIMES_ROMAN, fontsize, fontcolor);
	    else
	      cfont = FontFactory.GetFont(BASE_FONT_TIMES_ROMAN_BOLD, fontsize, fontcolor);
	          	    
	    Chunk    c    = new Chunk (value, cfont);	      
	    Phrase   p    = new Phrase (c);	    
	    PdfPCell cell = new PdfPCell (p);
	          
      cell.BackgroundColor     = bkgcolor;      
      cell.Border              = cs.GetBorder();
      cell.BackgroundColor     = bkgcolor;
	    cell.HorizontalAlignment = cs.alignment;
	    cell.Colspan             = span;
	    
	    return cell;
	    
	  }
	  	      
    /**************************************************************************
     * CreateFillerCells */
    /**
     * Create filler cells
     ***************************************************************************/
     
    protected static PdfPCell[] CreateFillerCells(int fillto)
    {
      
      List<PdfPCell> cells = new List<PdfPCell>();
      	    
	    for (int fill = 0; fill < fillto; fill++)
	    {
	      PdfPCell cell = new PdfPCell(new Phrase(""));
 	      cell.Border   = Rectangle.NO_BORDER;
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
      return File.GenerateFileName(folder, name, "pdf");
    }
    

    /**************************************************************************
     * ReturnRptDataToPDF */
    /**
     * For a given ReturnRptData instance create a pdf.
     ***************************************************************************/
    
    public static Byte[] ReturnRptDataToPDF (ref ReturnRptData rd)
    {

      /*-------------------------------
       * Determine page alignment
       *------------------------------*/

      Rectangle orientation = ORIENTATION_PORTRAIT;

      if (rd.output_orientation == File.ORIENTATION_LANDSCAPE)
        orientation = ORIENTATION_LANDSCAPE;
      
      /*-------------------------------
       * Create PDF document and assign
       * it to a memory stream
       *------------------------------*/
              
      iTextSharp.text.Document     doc    = new iTextSharp.text.Document(orientation,1f,1f,1f,30f);  // Leaves room for page# and date
      MemoryStream                 ms     = new MemoryStream();
      PdfWriter                    writer = PdfWriter.GetInstance(doc, ms);
                       	           
	              
      /*-------------------------------
       * Start creating parts of our
       * document starting with the
       * document titles and footer.  
       * These will be placed in our
       * table as part of the header.
       *------------------------------*/                           
		 	
		 	int titlecount  = 0;
		 	int footercount = 0;
		 	
		 	PdfPCell[] titlecells  = CreateTitleCells(rd.resultSetTitles.ToArray());
		 	PdfPCell[] footercells = CreateFooterCells(rd.resultSetFooters.ToArray());
		 	
     /*-------------------------------
      * Assign page number creator 
      * to document
      *------------------------------*/ 

     PageEventHelperPageNumberAndCreateDate peh = new PageEventHelperPageNumberAndCreateDate();
     writer.PageEvent = peh;      
     
     /*-------------------------------
      * Now create the table object 
      * variable, but we have to wait
      * to instantiate (because we 
      * do not have the column widths
      * yet) so we just pass it a null
      * as a placeholder.
      *------------------------------*/ 
    
     PdfPTable table = null;
               
     /*-------------------------------
      * Define our delegates for
      * generating document content
      * from the data tree starting
      * with the data table header
      *------------------------------*/ 

	  TraverseNodesCallback startheader = delegate (Object[] args)
	  {
	    int       numCols     = (int)       args[0];
	    int       totalWidth  = (int)       args[1];
	    int[]     colWidths   = (int[])     args[2];
	    float[]   colWidthPer = (float[])   args[3];
	    
	    /*----------------------------
       * Create our table
       * Set its width to a percentage
       * of the available page
       * width and then set our
       * column widths
       *----------------------------*/
	    
	    table = new PdfPTable(numCols);
	    table.WidthPercentage = 95f;	   
	    table.SetWidths(colWidthPer);
	    
	    /*----------------------------
       * Add the titles
       * being sure to set the proper
       * column span and count them
       *----------------------------*/
      
      foreach(PdfPCell t in titlecells)
      {
        t.Colspan = numCols;
        table.AddCell(t);
        titlecount++;
      }                       
	  };
	  
	 TraverseNodesCallback headerop = delegate(Object[] args)
	 {	
	    /*----------------------------
       * Create column headings
       * and add them to the table
       *----------------------------*/
	 
	    InputColumnDefinition def  = (InputColumnDefinition) args[0];	    
	    PdfPCell              cell = CreateCell(def, 1);
	    	   	    
	    table.AddCell(cell);
	  };
	  
	  TraverseNodesCallback endheader = delegate(Object[] args)
	  {
	    
	    int numCols = (int) args[0];
	    
	    /*----------------------------
       * Add the footers
       * being sure to set the proper
       * column span and count them
       *----------------------------*/
      
      foreach(PdfPCell f in footercells)
      {
        f.Colspan = numCols;
        table.AddCell(f);
        footercount++;
      }

	    
	    /*----------------------------
       * Tell the table what rows
       * contain our header and 
       * footer.
       * 
       * The number of footer rows 
       * are subtracted from the 
       * header rows. For example
       * for a table with 
       *   two header rows 
       *   and one footer row 
       * 
       * the code would be:
       * 
       * table.setHeaderRows(3);
       * table.setFooterRows(1);
       * 
       * Row 0 and 1 will be the 
       * header rows 
       * 
       * and row 2 will be the 
       * footer row.
       *----------------------------*/
	    
	    table.HeaderRows = titlecount + 1 + footercount;  // title count + col header + footercount
	    table.FooterRows = footercount;
	    
	  };
	  
	  GenericCallBack startbody = delegate()
	  {	  
	  };
	  
	  string evenodd = ""; // Used for row striping
	  
	  TraverseNodesOperation startrow = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	    
	    string rowType         = (string) args[0];
	    string rowStripe       = (string) args[1];	    
	    int    fillto          = (int)    args[2];
		  int    agrTitlePos     = (int)    args[3];
      string agrTitleLabel   = (string) args[4];
	    int    agrTitleSpan    = (int)    args[5];
	    
	    evenodd = rowStripe;
	    	    
	    /*----------------------------
       * If neccessary add filler
       * cells to this row
       *----------------------------*/
	    
	    PdfPCell[] cells = CreateFillerCells(fillto);	    	    
	    	    	    	     
	    /*-------------------------------
       * Insert aggregate title label
       *------------------------------*/ 
	    
	    if (agrTitlePos != -1)
	    {
	      PdfPCell cell = CreateCell (agrTitlePos, agrTitleLabel, agrTitleSpan);	      	      	    	      
	      cells[agrTitlePos] = cell;
	    }
	    
	    foreach (PdfPCell cell in cells)
	      table.AddCell(cell);
	      	    	    	    	  
	  };
	  
	  
	  TraverseNodesOperation nodeop = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	    
	    int span       = (int) args[0];
	    
	    /*----------------------------
       * Add cells to the row
       *----------------------------*/
	    
	    PdfPCell td = CreateCell(f,span,evenodd);
	    table.AddCell(td);

	  };
	  
	  TraverseNodesOperation endrow   = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {
	  };

	  GenericCallBack endbody = delegate()
	  {	    
	  };

    /*-------------------------------
     * Traverse the data tree
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
       * Start rendering document
       *------------------------------*/ 			
            
      doc.Open();
                    
	    /*-------------------------------
       * Add meta data to the document
       * starting with the document
       * title
       *------------------------------*/ 
      
      doc.AddTitle  (rd.title);        
      doc.AddAuthor (File.META_DOCUMENT_AUTHOR);         
      doc.AddCreationDate();
   	  
   	  /*-------------------------------
       * Add the table
       *------------------------------*/ 

      doc.Add(table);
      
      /*-------------------------------
       * Close up document
       *------------------------------*/ 			
      
      doc.Close();
      
	    /*-------------------------------
       * Build a byte array from the
       * document and return it
       *------------------------------*/ 
	    
      byte[] b1 = ms.ToArray();
      return b1;				
      
    }
                     
    /**************************************************************************
     * ReturnDataTableToPDF */
    /**
     * For a given ReturnDataTable instance create a pdf.
     ***************************************************************************/
    
    public static Byte[] ReturnDataTableToPDF (ref ReturnDataTable rd)
    {
      /*-------------------------------
       * Create PDF document and assign
       * it to a memory stream
       *------------------------------*/
              
      iTextSharp.text.Document     doc    = new iTextSharp.text.Document(ORIENTATION_LANDSCAPE,1f,1f,1f,30f);  // Leaves room for page# and date
      MemoryStream                 ms     = new MemoryStream();
      PdfWriter                    writer = PdfWriter.GetInstance(doc, ms);
    
      /*-------------------------------
       * Assign page number creator 
       * to document
       *------------------------------*/ 

      PageEventHelperPageNumberAndCreateDate peh = new PageEventHelperPageNumberAndCreateDate();
      writer.PageEvent = peh;                   
      
      /*-------------------------------
       * Create various objects we will
       * use for this pdf
       *------------------------------*/ 
      
      Font cellfontTit  = FontFactory.GetFont(BASE_FONT_TIMES_ROMAN_BOLD, File.FONT_SIZE_TITLE_2, new Color(File.COLOR_BLACK));
      Font cellfontHdr  = FontFactory.GetFont(BASE_FONT_TIMES_ROMAN_BOLD, File.FONT_SIZE_COL_HDR, new Color(File.COLOR_BLACK));
      Font cellfontFtr  = FontFactory.GetFont(BASE_FONT_TIMES_ROMAN_BOLD, File.FONT_SIZE_FOOTER,  new Color(File.COLOR_DARK_GREY));
      Font cellfont     = FontFactory.GetFont(BASE_FONT_TIMES_ROMAN,      File.FONT_SIZE_LEAF,    new Color(File.COLOR_BLACK));
      
      Color stripeColorEven = new Color(File.COLOR_LIGHT_GREY);
      Color stripeColorOdd  = new Color(File.COLOR_WHITE);
      
      /*-------------------------------
       * Now create the table object 
       * variable, but we have to wait
       * to instantiate (because we 
       * do not have the column widths
       * yet) so we just pass it a null
       * as a placeholder.
       *------------------------------*/ 
    
      PdfPTable table = null;
     
      /*-------------------------------
       * Setup columns
       *------------------------------*/ 

      int numCols = 0;
      
      List <float> fWidthPcts   = new List<float>();     
      List <float> fWidths      = new List<float>();  
      float        fTotalWidth  = 0f;
                  
      /*-------------------------------
       * Determine # of visible columns
       * their widths, and the total
       * width
       *------------------------------*/ 
      
      foreach (aoColumn col in rd.aoColumns)
      {
        if (col.bVisible)
        {                      
          // Get width and undue px conversion
          
          float fWidth = (Convert.ToSingle(col.iWidth)) / 12f;
          
          // If this is not a text column, use the default width for its dataclass
          
          if (col.dataclass != IdentifiedValue.DataClass.TEXT)
            fWidth = IdentifiedValue.DataClassToCharWidth(col.dataclass);
          
          // Store width, compute total width, and count columns
          
          fWidths.Add(fWidth);
          fTotalWidth = fTotalWidth + fWidth;                    
          numCols++;
        }
      }
      
      // Compute percentages
      
      foreach (float fWidth in fWidths)
      {
        float fWidthPct = fWidth / fTotalWidth;
        fWidthPcts.Add(fWidthPct);
      }
      
      /*-------------------------------
       * Create table
       *------------------------------*/ 
      
      table = new PdfPTable(numCols);
	    table.WidthPercentage = 95f;	   
	    table.SetWidths(fWidthPcts.ToArray());
	    
	    /*-------------------------------
       * Populate table starting with
       * the table name (title)
       *------------------------------*/    
      
      PdfPCell title = new PdfPCell(new Phrase(new Chunk(rd.tableName,cellfontTit)));
      title.Padding             = 1f;
      title.PaddingBottom       = 5f;
      title.Colspan             = numCols;
      title.HorizontalAlignment = Rectangle.ALIGN_CENTER;
      title.Border              = Rectangle.NO_BORDER;
      table.AddCell(title);
      
      /*-------------------------------
       * Next put the column headers in
       *------------------------------*/ 
       
       foreach (aoColumn col in rd.aoColumns)
       {
         
         if (col.bVisible)
         { 
           // Create the header cell
           
           Phrase p = new Phrase();
           Chunk  c = new Chunk(col.sTitle, cellfontHdr);
           p.Add(c);
           
           PdfPCell cell = new PdfPCell(p);            
           cell.Border = Rectangle.BOTTOM_BORDER;           
           table.AddCell(cell);
         }
       }
	   
	    /*-------------------------------
       * Then put our table footer in
       *------------------------------*/    
      
      PdfPCell footer = new PdfPCell(new Phrase(new Chunk(rd.tableFooter,cellfontFtr)));
      
      footer.Colspan             = numCols;
      footer.HorizontalAlignment = Rectangle.ALIGN_CENTER;
      footer.Border              = Rectangle.NO_BORDER;      
      table.AddCell(footer);


      /*-------------------------------
       * Tell table where title, header,
       * and footer rows are
       *------------------------------*/

       table.HeaderRows = 3;
       table.FooterRows = 1;
       
       /*-------------------------------
        * Generate our record rows and
        * stripe them
        *------------------------------*/
        
        bool stripe = false;
        
        foreach (Object[] arow in rd.aaData)        
        {
          int colCtr = 0;
          
          foreach (Object fld in arow)
          {
            aoColumn fldDef = rd.aoColumns[colCtr];

            if (fldDef.bVisible)
            {
              //Chunk    c    = new Chunk(fld.ToString(),cellfont);
              Paragraph p   = new Paragraph (fld.ToString(), cellfont);
              //Phrase   p    = new Phrase(c);
              PdfPCell cell = new PdfPCell(p);                         
              cell.Border   = Rectangle.NO_BORDER;
              cell.NoWrap   = false;
              
              if (stripe) 
                cell.BackgroundColor = stripeColorEven;
              else
                cell.BackgroundColor = stripeColorOdd;
              
              table.AddCell(cell);
            }              
            colCtr++;
          }
          
          if (stripe) 
            stripe = false;
          else
            stripe = true;
        }

      /*-------------------------------
       * Start rendering document
       *------------------------------*/ 			
            
      doc.Open();
                    
	    /*-------------------------------
       * Add meta data to the document
       * starting with the document
       * title
       *------------------------------*/ 
      
      doc.AddTitle  (rd.tableName);
      doc.AddAuthor (File.META_DOCUMENT_AUTHOR);         
      doc.AddCreationDate();
   	  
   	  /*-------------------------------
       * Add the table
       *------------------------------*/ 

      doc.Add(table);
      
      /*-------------------------------
       * Close up document
       *------------------------------*/ 			
      
      doc.Close();
      
	    /*-------------------------------
       * Build a byte array from the
       * document and return it
       *------------------------------*/ 
	    
      byte[] b1 = ms.ToArray();
      return b1;		    
    }
    
    /**************************************************************************
     * SplitPDF */
    /**
     * Splits a multipage pdf into single pages
     * 
     * Note: Does not preserve form content
     *
     * Based on burst.cs courtesey of Steven Lee: 
     * http://blog.rubypdf.com/2006/10/11/burstcs-split-a-pdf-in-several-separate-pdf-files-1-per-page/
     ***************************************************************************/
    
    public static List<Byte[]> SplitPDF (string filename)
    {    
      return PDFCommon.splitPDF(filename);  
    }  
  }
}
