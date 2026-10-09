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
  
  /**************************************************************************
   * RenderPdfCallBack
  /**
   ***************************************************************************/    
  
  public delegate void RenderPdfCallBack (   ref iTextSharp.text.Document doc
                                           , ref MemoryStream             ms
                                           , ref PdfWriter                writer
                                           , ref String                   title
                                           , ref String                   author
                                           , ref String                   batch
                                           , ref String                   filename
                                         );
  
  /**************************************************************************
   * PageEventHelperPageNumberAndCreateDate
  /**
   * This is our version of the iText PdfPageEventHelper class
   * 
   * We currently use this class to render a page number and creation date/time
   * and insert this in the bottom of every pdf page.
   * 
   * This is a modifed version of Massoud Mazar's TwoColumnHeaderFooter helper class
   * 
   * http://www.mazsoft.com/blog/post/2008/04/30/Code-sample-for-using-iTextSharp-PDF-library.aspx
   ***************************************************************************/    
    
  public class PageEventHelperPageNumberAndCreateDate : PdfPageEventHelper
  {
    // This is the contentbyte object of the writer

    protected PdfContentByte cb;

    // we will put the final number of pages in a template

    protected PdfTemplate template;

    // this is the BaseFont we are going to use for the header / footer

    protected BaseFont bf = BaseFont.CreateFont(BaseFont.TIMES_ROMAN, BaseFont.CP1252, true);

    // This keeps track of the creation time
      
    protected DateTime PrintTime = DateTime.Now;
      
    // we override the onOpenDocument method
            
    public override void OnOpenDocument(PdfWriter writer, iTextSharp.text.Document document)
    {        
      PrintTime = DateTime.Now;
      cb        = writer.DirectContent;
      template  = cb.CreateTemplate(50, 10);
    }
       
    public override void OnEndPage(PdfWriter writer,  iTextSharp.text.Document document)
    {
        
      base.OnEndPage(writer, document);
                                      
      /*-------------------------------
       * Page number
       *------------------------------*/
        
      int    pageN = writer.PageNumber;
      String text  = "Page " + pageN + " of ";
      float  len   = bf.GetWidthPoint(text, 8);

      Rectangle pageSize = document.PageSize;
        
      cb.SetRGBColorFill(100, 100, 100);
      cb.SetColorFill(new Color(File.COLOR_DARK_GREY));
      cb.BeginText();
      cb.SetFontAndSize(bf, 8);
      cb.SetTextMatrix(pageSize.GetLeft(40), pageSize.GetBottom(10));
      cb.ShowText(text);
      cb.EndText();

      cb.AddTemplate(template, pageSize.GetLeft(40) + len, pageSize.GetBottom(10));
                   
      cb.BeginText();
      cb.SetFontAndSize(bf, 8);
        
      cb.ShowTextAligned(PdfContentByte.ALIGN_RIGHT,
      "Created On " + PrintTime.ToString(),
      pageSize.GetRight(40),
      pageSize.GetBottom(10), 0);
         
      cb.EndText();
      
    }

    public override void OnCloseDocument(PdfWriter writer, iTextSharp.text.Document document)
    {
      base.OnCloseDocument(writer, document);

      template.BeginText();
      template.SetFontAndSize(bf, 8);
      template.SetTextMatrix(0, 0);
      template.ShowText("" + (writer.PageNumber - 1));
      template.EndText();
    }
  }
  
  

  /***************************************************************************
   * PDFCommon */
  /**
   * 
   ***************************************************************************/
  
  public class PDFCommon
  {  
  
	  /***************************************************************************
     * PAGE_SIZE_X */
    /**
     * The various page sizes we will use
     ***************************************************************************/
        
	  public static readonly Rectangle ORIENTATION_PORTRAIT  = PageSize.LETTER;
	  public static readonly Rectangle ORIENTATION_LANDSCAPE = PageSize.LETTER.Rotate();	
	    
	  public static readonly Color     COLOR_FE_FE_EE        = new Color(254,254,238);
	  public static readonly Color     COLOR_F5_F5_DC        = new Color(245,245,220);
	  public static readonly Color     COLOR_PARCHMENT       = new Color(216,213,210);
	  public static readonly Color     COLOR_LIGHTER_GRAY    = new Color(235,235,235);
	 	  
	  /***************************************************************************
     * BASE_FONT_ */
    /**
     * The various fonts we will use
     ***************************************************************************/
     
    public static readonly string  BASE_FONT_TIMES_ROMAN          = BaseFont.TIMES_ROMAN;
    public static readonly string  BASE_FONT_TIMES_ROMAN_ITALIC   = BaseFont.TIMES_ITALIC;
    public static readonly string  BASE_FONT_TIMES_ROMAN_BOLD     = BaseFont.TIMES_BOLD;
                    
    public enum StandardFont
    {
        BLACK_6
      , BLACK_6_BOLD
      , BLACK_8
      , BLACK_8_BOLD
      , BLACK_10
      , BLACK_10_BOLD
      , BLACK_12
      , BLACK_12_BOLD
   }


    public static readonly int     CELL_BORDERS_TOP_LEFT          = Rectangle.TOP_BORDER    | Rectangle.LEFT_BORDER;
    public static readonly int     CELL_BORDERS_TOP_MIDDLE        = Rectangle.TOP_BORDER;
    public static readonly int     CELL_BORDERS_TOP_RIGHT         = Rectangle.TOP_BORDER    | Rectangle.RIGHT_BORDER;    
    public static readonly int     CELL_BORDERS_MIDDLE_LEFT       = Rectangle.LEFT_BORDER;
    public static readonly int     CELL_BORDERS_MIDDLE_MIDDLE     = Rectangle.NO_BORDER;
    public static readonly int     CELL_BORDERS_MIDDLE_RIGHT      = Rectangle.RIGHT_BORDER;  
    
    public static readonly int     CELL_BORDERS_BOTTOM_LEFT       = Rectangle.BOTTOM_BORDER | Rectangle.LEFT_BORDER;
    public static readonly int     CELL_BORDERS_BOTTOM_MIDDLE     = Rectangle.BOTTOM_BORDER;
    public static readonly int     CELL_BORDERS_BOTTOM_RIGHT      = Rectangle.BOTTOM_BORDER | Rectangle.RIGHT_BORDER;      
    public static readonly int     CELL_BORDERS_TOP_BOTTOM_LEFT   = Rectangle.TOP_BORDER    | Rectangle.BOTTOM_BORDER  | Rectangle.LEFT_BORDER;
    public static readonly int     CELL_BORDERS_TOP_BOTTOM_MIDDLE = Rectangle.TOP_BORDER    | Rectangle.BOTTOM_BORDER;
    public static readonly int     CELL_BORDERS_TOP_BOTTOM_RIGHT  = Rectangle.TOP_BORDER    | Rectangle.BOTTOM_BORDER  | Rectangle.RIGHT_BORDER;    
    
    public static readonly int     CELL_BORDERS_TOP_LEFT_MIDDLE_RIGHT    = Rectangle.LEFT_BORDER | Rectangle.TOP_BORDER  | Rectangle.RIGHT_BORDER;
    public static readonly int     CELL_BORDERS_MIDDLE_LEFT_RIGHT        = Rectangle.LEFT_BORDER | Rectangle.RIGHT_BORDER;
    public static readonly int     CELL_BORDERS_BOTTOM_LEFT_MIDDLE_RIGHT = Rectangle.LEFT_BORDER | Rectangle.BOTTOM_BORDER  | Rectangle.RIGHT_BORDER;
    
    
    public static readonly int     CELL_BORDERS_ALL               = Rectangle.TOP_BORDER    | Rectangle.BOTTOM_BORDER  | Rectangle.LEFT_BORDER | Rectangle.RIGHT_BORDER;
    public static readonly int     CELL_BORDERS_NONE              = Rectangle.NO_BORDER;
    
    public static readonly int     BARCODE_TYPE_128     = 1;
    public static readonly int     BARCODE_TYPE_PDF_417 = 2;

    /***************************************************************************
     * generateFont
    /**
     *
     ***************************************************************************/

    public static Font generateFont (string name, int size, int style, Color color)
    {
      Font font  = FontFactory.GetFont (name, size, style, color);
      return font;
    }

    /***************************************************************************
     * generateCommonDocumentTitleFont
    /**
     *
     ***************************************************************************/

    public static Font generateCommonDocumentTitleFont ()
    {
      return generateFont(FontFactory.TIMES_ROMAN ,18 ,Font.BOLDITALIC , Color.BLACK);
    }

    /***************************************************************************
     * generateCommonDocumentTitleFont
    /**
     *
     ***************************************************************************/

    public static Font generateCommonDocumentTitleFontNotItalic ()
    {
      return generateFont(FontFactory.TIMES_ROMAN ,18 ,Font.BOLD , Color.BLACK);
    }
    
    /***************************************************************************
     * generateCommonDocumentDisclaimerFont 
    /**
     *
     ***************************************************************************/

    public static Font generateCommonDocumentDisclaimerFont ()
    {
      return generateFont(FontFactory.TIMES_ROMAN ,8,Font.ITALIC, Color.BLACK); 
    }

    /***************************************************************************
     * generateCommonDocumentCellLabelFont
    /**
     *
     ***************************************************************************/

    public static Font generateCommonDocumentCellLabelFont ()
    {
      return generateFont(FontFactory.TIMES_ROMAN ,10 ,Font.BOLD, Color.BLACK); 
    }

    /***************************************************************************
     * generateCommonDocumentCellTextFont
    /**
     *
     ***************************************************************************/

    public static Font generateCommonDocumentCellTextFont ()
    {
      return generateFont(FontFactory.TIMES_ROMAN ,10 ,Font.NORMAL, Color.BLACK); 
    }

    /***************************************************************************
     * generateCommonDocumentCellTextFontDescription
    /**
     *
     ***************************************************************************/

    public static Font generateCommonDocumentCellTextFontDescription ()
    {
      return generateFont(FontFactory.TIMES_ROMAN ,8 ,Font.NORMAL, Color.BLACK); 
    }

    /***************************************************************************
     * generateCommonDocumentCellUniqueKeyFon
    /**
     *
     ***************************************************************************/

    public static Font generateCommonDocumentCellUniqueKeyFont ()
    {
      return generateFont(FontFactory.COURIER ,10 ,Font.BOLD, Color.RED); 
    }

    /***************************************************************************
     * generateChapter
    /**
     *
     ***************************************************************************/

    public static Chapter generateHiddenChapter (string title, int number, Color color)
    {
      Font font = generateFont(BASE_FONT_TIMES_ROMAN,1,Font.NORMAL,color);            
      Chunk chunk = new Chunk (title,font);
      Paragraph paragraph = new Paragraph (chunk);     
      paragraph.SpacingBefore = 0;
      paragraph.SpacingAfter  = 0;     
      Chapter chapter = new Chapter (paragraph, number);  
      return chapter;
    }
    
    /***************************************************************************
     * generateExternalAnchor
    /**
     *
     ***************************************************************************/

    public static Anchor generateExternalAnchor (string label, string url, ref Font font)
    {
      Anchor anchor  = new Anchor(label, font);
      anchor.Reference = url;
      return anchor;
    }

    /***************************************************************************
     * generateImageFromSystemImage
    /**
     *
     ***************************************************************************/

    public static Image generateImageFromSystemImage (  System.Drawing.Image image 
                                                      , Color                backGroundColor )
    {
      Image i1 = Image.GetInstance (image, backGroundColor);     
      return i1;
    }

    /***************************************************************************
     * generateBarcodePDF417
    /**
     *
     ***************************************************************************/

    public static Image generateBarcodePDF417 (string text)
    {
      iTextSharp.text.pdf.BarcodePDF417 bco = new BarcodePDF417();     
      bco.SetText(text);
      Image bci = bco.GetImage();
      return bci;
    }
    
    /***************************************************************************
     * generateBarcode128
    /**
     *
     ***************************************************************************/

    public static Image generateBarcode128 (string text)
    {
      iTextSharp.text.pdf.Barcode128 bco = new Barcode128();      
      bco.Code     = text;       
      bco.CodeType = 3; /* C for numbers */
      System.Drawing.Image di = bco.CreateDrawingImage(System.Drawing.Color.Black, System.Drawing.Color.White);
      return generateImageFromSystemImage(di,Color.WHITE);     
    }

    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/

    protected static PdfPCell generateCell (  ref PdfPCell cell
                                            , int   rowSpan
                                            , int   colSpan                                   
                                            , int   horizontalAlign
                                            , int   verticalAlign
                                            , Color backGroundColor
                                            , int   border )
    {  
      cell.Rowspan             = rowSpan;
      cell.Colspan             = colSpan;
      cell.BackgroundColor     = backGroundColor;
      cell.HorizontalAlignment = horizontalAlign;
      cell.VerticalAlignment   = verticalAlign;
      cell.Border              = border; 
      return cell;
    }

    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/
    public static PdfPCell generateCell (   ref  PdfPTable table
                                          , int   rowSpan
                                          , int   colSpan                                   
                                          , int   horizontalAlign
                                          , int   verticalAlign
                                          , Color backGroundColor
                                          , int   border
                                          , int   padding )
    {  
      var cell = new PdfPCell(table);     
      cell.Rowspan             = rowSpan;
      cell.Colspan             = colSpan;
      cell.BackgroundColor     = backGroundColor;
      cell.HorizontalAlignment = horizontalAlign;
      cell.VerticalAlignment   = verticalAlign;
      cell.Border              = border; 
      cell.Padding             = padding;
      return cell;
    }

    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/

    protected static PdfPCell generateCell (   ref PdfPCell cell
                                             , int          rowSpan
                                             , int          colSpan                                   
                                             , int          horizontalAlign
                                             , int          verticalAlign
                                             , Color        backGroundColor )
    {
      
      int border = CELL_BORDERS_ALL;
      return generateCell(ref cell,rowSpan,colSpan,horizontalAlign,verticalAlign,backGroundColor,border);
    }

    
    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/

    public static PdfPCell generateCell (   iTextSharp.text.Image image
                                          , int                   rowSpan
                                          , int                   colSpan                                   
                                          , int                   horizontalAlign
                                          , int                   verticalAlign
                                          , Color                 backGroundColor
                                          , int                   border )
    {
      PdfPCell cell = new PdfPCell(image);
      return generateCell(ref cell,rowSpan,colSpan,horizontalAlign,verticalAlign,backGroundColor,border);
    }

    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/
     
    public static PdfPCell generateCell (   string  barcodeText
                                          , int     barcodeType
                                          , int     rowSpan
                                          , int     colSpan                                   
                                          , int     horizontalAlign
                                          , int     verticalAlign
                                          , Color   backGroundColor
                                          , int      border )

    {
      Image img = null;
      
      if      (barcodeType == BARCODE_TYPE_128)     img = generateBarcode128    (barcodeText);
      else if (barcodeType == BARCODE_TYPE_PDF_417) img = generateBarcodePDF417 (barcodeText);
      else return null;

      return generateCell(img,rowSpan,colSpan,horizontalAlign,verticalAlign,backGroundColor,border);
    }
    
    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/

    public static PdfPCell generateCell (   System.Drawing.Image  image                                                
                                          , int                   rowSpan
                                          , int                   colSpan                                   
                                          , int                   horizontalAlign
                                          , int                   verticalAlign
                                          , Color                 backGroundColor
                                          , int                   border )
    {
      iTextSharp.text.Image img = Image.GetInstance (image, backGroundColor);
      return generateCell(img, rowSpan, colSpan, horizontalAlign, verticalAlign, backGroundColor, border);
    }
    
    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/

    public static PdfPCell generateCell (   Paragraph    paragraph
                                          , int          rowSpan
                                          , int          colSpan                                   
                                          , int          horizontalAlign
                                          , int          verticalAlign
                                          , Color        backGroundColor )
    {
      PdfPCell cell = new PdfPCell(paragraph);
      return generateCell(ref cell, rowSpan,colSpan,horizontalAlign,verticalAlign,backGroundColor);
    }
    
    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/

    public static PdfPCell generateCell (   Chapter      chapter
                                          , int          rowSpan
                                          , int          colSpan                                   
                                          , int          horizontalAlign
                                          , int          verticalAlign
                                          , Color        backGroundColor )
    {
      PdfPCell cell = new PdfPCell();
      cell.AddElement(chapter);
      return generateCell(ref cell, rowSpan,colSpan,horizontalAlign,verticalAlign,backGroundColor);
    }

    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/
    public static PdfPCell generateCell (   Paragraph    paragraph
                                          , int          rowSpan
                                          , int          colSpan                                   
                                          , int          horizontalAlign
                                          , int          verticalAlign
                                          , Color        backGroundColor
                                          , int          border )
    {
      PdfPCell cell = new PdfPCell(paragraph);
      return generateCell(ref cell, rowSpan,colSpan,horizontalAlign,verticalAlign,backGroundColor,border);
    }
        
    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/
    public static PdfPCell generateCell (   List<Phrase> phrases
                                          , int          rowSpan
                                          , int          colSpan                                   
                                          , int          horizontalAlign
                                          , int          verticalAlign
                                          , bool         useNewLines
                                          , Color        backGroundColor )
    {
      
      Paragraph paragraph = new Paragraph();  
      
      foreach (Phrase phrase in phrases) {
        
        paragraph.Add(phrase);
        if (useNewLines) paragraph.Add(Chunk.NEWLINE);
      }
      
      return generateCell (paragraph, rowSpan,colSpan,horizontalAlign,verticalAlign,backGroundColor);
    
    }

    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/

    public static PdfPCell generateCell (   List<Chunk>  chunks
                                          , int          rowSpan
                                          , int          colSpan                                   
                                          , int          horizontalAlign
                                          , int          verticalAlign
                                          , bool         useNewLines
                                          , Color        backGroundColor )
    {
      
      List<Phrase> phrases = new List<Phrase>();
      
      foreach (Chunk chunk in chunks) {
        Phrase phrase = new Phrase(chunk);
        phrases.Add(phrase);
      }
      
      return generateCell (phrases, rowSpan, colSpan, horizontalAlign, verticalAlign, useNewLines, backGroundColor);
    }

        
    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/

    public static PdfPCell generateCell (   string   label
                                          , string   url
                                          , ref Font font                                                        
                                          , int      rowSpan
                                          , int      colSpan                                   
                                          , int      horizontalAlign
                                          , int      verticalAlign
                                          , Color    backGroundColor
                                          , int      border )
    {
      Anchor    anchor    = generateExternalAnchor(label, url, ref font);      
      Paragraph paragraph = new Paragraph(anchor);
      return generateCell(paragraph,rowSpan,colSpan,horizontalAlign,verticalAlign,backGroundColor,border);      
    }

    /***************************************************************************
     * generateCell
    /**
     *
     ***************************************************************************/

    public static PdfPCell generateCell (string embeddedImageName, int rowSpan, int colSpan, int horizontalAlign, int verticalAlign)
    {         
      System.Drawing.Image img = MBA.EmbeddedResources.CommonImages.GetImage(embeddedImageName);
      return generateCell(img,rowSpan,colSpan,horizontalAlign,verticalAlign,Color.WHITE,Rectangle.NO_BORDER);
    }

    /***************************************************************************
     * generateCell
    /**
     *
     **************************************************************************/  
    public static PdfPCell generateCell (string text, int rowSpan, int colSpan, int horizontalAlign, int verticalAlign, int border, int padding, ref Font font)
    {
      Chunk     chunk     = new Chunk(text,font);
      Paragraph paragraph = new Paragraph(chunk);
      paragraph.Alignment = horizontalAlign;
      PdfPCell cell = generateCell(paragraph, rowSpan, colSpan, horizontalAlign, verticalAlign, Color.WHITE, border);
      cell.Padding  = padding;
      return cell;
    }
    
    /***************************************************************************
     * generateCell
    /**
     *
     **************************************************************************/  
                
    public static PdfPCell generateCell (string text, int rowSpan, int colSpan, int horizontalAlign, int verticalAlign, int border, int padding, ref Font font, Color backGroundColor)
    {
      Chunk     chunk     = new Chunk(text,font);
      Paragraph paragraph = new Paragraph(chunk);
      paragraph.Alignment = horizontalAlign;
      PdfPCell cell = generateCell(paragraph, rowSpan, colSpan, horizontalAlign, verticalAlign, backGroundColor, border);
      cell.Padding  = padding;
      return cell;
    }

    /***************************************************************************
     * generateTable
    /**
     *
     ***************************************************************************/

    public static PdfPTable generateTable (   int            numCols
                                            , int            numHeaderRows
                                            , List<PdfPCell> headerCells                                            
                                            , List<PdfPCell> bodyCells )
    {
     
     PdfPTable table = new PdfPTable(numCols);
     
       
     /*-------------------------------
      * Add header cells
      *------------------------------*/

     foreach (PdfPCell headerCell in headerCells) {          
       table.AddCell (headerCell);       
     }
     
     /*-------------------------------
      * Add body cells
      *------------------------------*/

     foreach (PdfPCell bodyCell in bodyCells) 
     {       
       table.AddCell (bodyCell);
     }
          
     /*-------------------------------
      * Tell table where header rows
      * are located relative to top
      *------------------------------*/
     
     table.HeaderRows = numHeaderRows;
     
     return table;
    }
                         
   /***************************************************************************
    * generateTable
   /**
    *
    ***************************************************************************/

    public static PdfPTable generateTable (   int            numCols                                            
                                            , List<PdfPCell> cells  )
    {
     
      PdfPTable table = new PdfPTable(numCols);
     
       
      foreach (PdfPCell cell in cells) {          
        table.AddCell(cell);
      }
     
      return table;
    }
   
    /**************************************************************************
     * generateDocument*/
    /**
     * 
     ***************************************************************************/
    
    public static ReturnFileBytes generateDocument (  string            title
                                                    , string            author
                                                    , string            batch
                                                    , string            filename
                                                    , Rectangle         orientation
                                                    , float             marginLeft
                                                    , float             marginRight
                                                    , float             marginTop
                                                    , float             marginBottom
                                                    , PageEventHelperPageNumberAndCreateDate   peh
                                                    , RenderPdfCallBack                        cbRenderPdf )
    {
      
      ReturnFileBytes rd = new ReturnFileBytes();
      
      rd.contentType     = @"application/pdf";
      rd.fileName        = @"emptyfile";
      rd.fileBytes       = null;

      /*-------------------------------
       * Create PDF document and assign
       * it to a memory stream
       *------------------------------*/
              
      iTextSharp.text.Document doc = new iTextSharp.text.Document (  orientation
                                                                   , marginLeft
                                                                   , marginRight
                                                                   , marginTop
                                                                   , marginBottom );
                                                                           
      MemoryStream  ms     = new MemoryStream();
      PdfWriter     writer = PdfWriter.GetInstance(doc, ms);
          
      /*-------------------------------
       * Assign page event helper 
       * to document.  Make sure
       * you leave enough room in
       * bottom margin for any rendering
       * this does
       *------------------------------*/ 

      if (peh != null)
        writer.PageEvent = peh;                   
      
      /*-------------------------------
       * Open document and add meta 
       * data
       *------------------------------*/ 			
            
      doc.Open();                         
      doc.AddTitle   (title);
      doc.AddCreator (File.META_DOCUMENT_AUTHOR);
      doc.AddAuthor  (author);         
      doc.AddCreationDate();
   	  
      /*-------------------------------
       * Render doc
       *------------------------------*/ 			
      
      cbRenderPdf(ref doc, ref ms, ref writer, ref title, ref author, ref batch, ref filename);
                  
      /*-------------------------------
       * Close up document
       *------------------------------*/ 			
      
      doc.Close();
      
	    /*-------------------------------
       * Build a byte array from the
       * document and return it
       *------------------------------*/ 

      rd.fileName  = File.GenerateFileName(filename,"pdf");	    
      rd.fileBytes = ms.ToArray();
      return rd;		    
    
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
    
    public static List<Byte[]> splitPDF (string filename)    
    {    
      /*-------------------------------
        * Make sure file exists if not
        * get out
        *------------------------------*/ 
      
      if (!System.IO.File.Exists(filename)) 
        throw new Warning(filename + " does not exist");
       
       
      /*-------------------------------
       * Create a list of byte arrays
       * to hold our various pages
       *------------------------------*/ 
  
      List<Byte[]> pages  = new List<byte[]>();
 
      
      PdfReader reader = null;
      
      try
      {
       
        /*-------------------------------
         * Open pdf and extract number
         * of pages
         *------------------------------*/ 

        reader = new PdfReader(new RandomAccessFileOrArray(filename), null);      
        int numpages = reader.NumberOfPages;
      
        /*-------------------------------
         * For each page in the file
         *------------------------------*/ 
      
        for (int pagenumber = 1; pagenumber < numpages; pagenumber++)
        {
          /*-------------------------------
           * Create a new pdf
           *------------------------------*/ 
        
          iTextSharp.text.Document doc    = new iTextSharp.text.Document(reader.GetPageSizeWithRotation(pagenumber));
          MemoryStream             ms     = new MemoryStream();
          PdfWriter                writer = PdfWriter.GetInstance(doc, ms);         
        
          doc.Open();
        
          PdfContentByte           cb     = writer.DirectContent;
			    PdfImportedPage          page   = writer.GetImportedPage(reader, pagenumber);
			  
			    int rotation = reader.GetPageRotation(pagenumber);			 

			    if (rotation == 90 || rotation == 270)
				    cb.AddTemplate(page, 0, -1f, 1f, 0, 0, reader.GetPageSizeWithRotation(pagenumber).Height);
				  else
			      cb.AddTemplate(page, 1f, 0, 0, 1f, 0, 0);
			  
				  doc.Close();
				
  		 /*-------------------------------
          * Build a byte array from the
          * document and add it to our
          * byte array list
          *------------------------------*/ 
	    
         byte[] b1 = ms.ToArray();
         pages.Add(b1); 
               			        
        }
        
        /*-------------------------------
         * Return array of page bytes
         *------------------------------*/ 

        return pages;

      }
			
			catch (Exception e)
			{
			  throw new Critical(@"Unable to split pdf " + e.Message);
			}	
			
      finally
      {
        
        /*-------------------------------
         * Close original document
         *------------------------------*/ 
        
        if (reader != null)
          reader.Close();      
      
      }
    }

    
  }
}
