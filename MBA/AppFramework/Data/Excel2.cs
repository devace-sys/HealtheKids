using System;
using System.Globalization;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Drawing;
using MBA.Reporting;
using MBA.IdentifyData;

// Excel Library

using NPOI.SS;               /* Generic */
using NPOI.SS.UserModel;
using NPOI.SS.Util;

using NPOI.HSSF;             /* Excel */
using NPOI.HSSF.UserModel;
using NPOI.HSSF.Util;

using NPOI.XSSF;
using NPOI.XSSF.UserModel;
using NPOI.XSSF.Util;

using NPOI.HPSF;             /* Properties such as doc summary info, etc */


namespace MBA
{
  public class Excel2:File2
  {      
    
    protected const string FONT_NAME_TIMES = @"Times New Roman";
    
    protected const short  FONT_HEIGHT_8   = (short) 8;
    protected const short  FONT_HEIGHT_10  = (short) 10;
    protected const short  FONT_HEIGHT_12  = (short) 12;
    protected const short  FONT_HEIGHT_14  = (short) 14;
    protected const short  FONT_HEIGHT_16  = (short) 16;

    protected const int    MAX_CHAR_WIDTH_APPROX = 256;        
    protected const int    MAX_COL_CHARS         = 50;
    protected const int    MAX_COL_WIDTH         = MAX_COL_CHARS * MAX_CHAR_WIDTH_APPROX;
    protected const int    COL_WIDTH_PADDING     = MAX_CHAR_WIDTH_APPROX * 2;
    
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
      return GenerateFileName(folder, name, "xlsx");
    }
              
    /**************************************************************************
     * createFormats */
    /**
     * Create formats
     * 
     ***************************************************************************/    
    
    protected static Dictionary <string, short> createFormats ( ref IWorkbook doc )
    {

      Dictionary <string,short> formats = new Dictionary <string, short> ();         
      IDataFormat               format  = doc.CreateDataFormat();     
      
      formats.Add(FS_EMPTY,           format.GetFormat(@"@"));
      formats.Add(FS_TIME,            format.GetFormat(@"h:mm AM/PM"));
      formats.Add(FS_DATE,            format.GetFormat(@"mm/dd/yy"));
      formats.Add(FS_DATE_MONTH_YEAR, format.GetFormat(@"MMM YYYY"));
      formats.Add(FS_BOOLEAN,         format.GetFormat(@"@"));
      formats.Add(FS_INTEGER,         format.GetFormat(@"0"));
      formats.Add(FS_FLOAT,           format.GetFormat(@"0.00"));
      formats.Add(FS_PERCENT,         format.GetFormat(@"0.00%"));
      formats.Add(FS_DECIMAL,         format.GetFormat(@"#,##0.00"));
      formats.Add(FS_STRING,          format.GetFormat(@"@"));
      formats.Add(FS_EMAIL,           format.GetFormat(@"@"));
      formats.Add(FS_URI,             format.GetFormat(@"@"));

      return formats;
    
    }
    
    /**************************************************************************
     * createFormatsFinancial */
    /**
     * Create formats for financial reports
     * 
     ***************************************************************************/    

    protected static Dictionary <string, short> createFormatsFinancial ( ref IWorkbook doc )
    {

      Dictionary <string,short> formats = new Dictionary <string, short> ();         
      IDataFormat               format  = doc.CreateDataFormat();     
      
      formats.Add(FS_EMPTY,           format.GetFormat(@"@"));
      formats.Add(FS_DATE,            format.GetFormat(@"mm/dd/yy"));
      formats.Add(FS_TIME,            format.GetFormat(@"@"));
      formats.Add(FS_DATE_MONTH_YEAR, format.GetFormat(@"MMM YYYY"));
      formats.Add(FS_BOOLEAN,         format.GetFormat(@"@"));
      formats.Add(FS_INTEGER,         format.GetFormat(@"0"));
      formats.Add(FS_FLOAT,           format.GetFormat(@"0.00"));
      formats.Add(FS_PERCENT,         format.GetFormat(@"0%_);(0%)"));
      formats.Add(FS_DECIMAL,         format.GetFormat(@"#,##0_);(#,##0)"));
      formats.Add(FS_STRING,          format.GetFormat(@"@"));
      formats.Add(FS_EMAIL,           format.GetFormat(@"@"));
      formats.Add(FS_URI,             format.GetFormat(@"@"));

      return formats;
    
    }
       
    /**************************************************************************
     * createFont */
    /**
     * Create font
     *  
     ***************************************************************************/    
    
    protected static IFont createFont ( string            fs_name 
                                      , short             fontHeightInPoints
                                      , FontBoldWeight    fontWeight
                                      , short             fontColor
                                      , bool              underline
                                      , ref IWorkbook     doc )
   {
      IFont font = null;
      short fontBoldWeight = (short) fontWeight;
      
     /*###########################################################################
       # See if the font already exists.  If so we will reuse it.
       ###########################################################################*/ 
      
      /*font = doc.FindFont(  fontBoldWeight
                          , fontColor
                          , fontHeightInPoints
                          , FONT_NAME_TIMES
                          , false
                          , false
                          , FontSuperScript.None
                          , ut );
     */
      /*###########################################################################
        # If the font does not exist yet create it.
        ###########################################################################*/ 
      
      font = doc.CreateFont();       
      
      font.Boldweight          = fontBoldWeight;
      font.Color               = fontColor;
      font.FontHeightInPoints  = fontHeightInPoints;
      font.FontName            = FONT_NAME_TIMES;        
      
      if (underline) 
        font.Underline = FontUnderlineType.Single;
      
      return font;   
    }                                   
   
    /**************************************************************************
     * createFonts */
    /**
     * Create fonts 
     * 
     ***************************************************************************/

    protected static Dictionary <string, IFont> createFonts (   ref IWorkbook     doc
                                                              , short             fontHeightInPoints
                                                              , FontBoldWeight    fontWeight
                                                              , short             fontColor )
    {

      Dictionary <string,IFont> fonts = new Dictionary <string, IFont> ();     

      fonts.Add ( FS_EMPTY,             createFont (FS_EMPTY,           fontHeightInPoints, fontWeight, fontColor, false, ref doc ) );
      fonts.Add ( FS_DATE,              createFont (FS_DATE,            fontHeightInPoints, fontWeight, fontColor, false, ref doc ) );
      fonts.Add ( FS_TIME,              createFont (FS_TIME,            fontHeightInPoints, fontWeight, fontColor, false, ref doc ) );      
      fonts.Add ( FS_DATE_MONTH_YEAR,   createFont (FS_DATE_MONTH_YEAR, fontHeightInPoints, fontWeight, fontColor, false, ref doc ) );      
      fonts.Add ( FS_BOOLEAN,           createFont (FS_BOOLEAN,         fontHeightInPoints, fontWeight, fontColor, false, ref doc ) );
      fonts.Add ( FS_INTEGER,           createFont (FS_INTEGER,         fontHeightInPoints, fontWeight, fontColor, false, ref doc ) );
      fonts.Add ( FS_FLOAT,             createFont (FS_FLOAT,           fontHeightInPoints, fontWeight, fontColor, false, ref doc ) );
      fonts.Add ( FS_PERCENT,           createFont (FS_PERCENT,         fontHeightInPoints, fontWeight, fontColor, false, ref doc ) );
      fonts.Add ( FS_DECIMAL,           createFont (FS_DECIMAL,         fontHeightInPoints, fontWeight, fontColor, false, ref doc ) );
      fonts.Add ( FS_STRING,            createFont (FS_STRING,          fontHeightInPoints, fontWeight, fontColor, false, ref doc ) );      
      fonts.Add ( FS_EMAIL,             createFont (FS_EMAIL,           fontHeightInPoints, fontWeight, IndexedColors.Blue.Index, true,  ref doc ));
      fonts.Add ( FS_URI,               createFont (FS_URI,             fontHeightInPoints, fontWeight, IndexedColors.Blue.Index, true,  ref doc ));

      return fonts;
    }
    
    /**************************************************************************
     * createFontsTh */
    /**
     * Create fonts for table headings
     * 
     ***************************************************************************/

    protected static Dictionary <string, IFont> createFontsTh ( ref IWorkbook doc )
    {
      return createFonts (ref doc, FONT_HEIGHT_10, FontBoldWeight.Bold, IndexedColors.White.Index );
    }

    /**************************************************************************
     * createFontsTd */
    /**
     * Create fonts for table details
     * 
     ***************************************************************************/
  
    protected static Dictionary <string, IFont> createFontsTd ( ref IWorkbook doc )
    {
      return createFonts (ref doc, FONT_HEIGHT_10, FontBoldWeight.None, IndexedColors.Black.Index );
    }

    /**************************************************************************
     * createFontsTitle */
    /**
     * Create fonts for common title rows
     * 
     ***************************************************************************/
 
    protected static Dictionary <string, IFont> createFontsTitle ( ref IWorkbook doc )
    {
      return createFonts (ref doc, FONT_HEIGHT_16, FontBoldWeight.Bold, IndexedColors.Black.Index );
    }
  
    /**************************************************************************
     * createFontsFooter */
    /**
     * Create fonts for common footer rows
     * 
     ***************************************************************************/

    protected static Dictionary <string, IFont> createFontsFooter ( ref IWorkbook doc )
    {
      return createFonts (ref doc, FONT_HEIGHT_12, FontBoldWeight.None, IndexedColors.Grey80Percent.Index);
    }
      
    /**************************************************************************
     * createStyle */
    /**
     * Create cell style
     * 
     ***************************************************************************/

    protected static ICellStyle createStyle (  string                         fs_name 
                                             , HorizontalAlignment            ha
                                             , ref IWorkbook                  doc
                                             , ref Dictionary <string, short> formats 
                                             , ref Dictionary <string, IFont> fonts
                                             , short                          fillForegroundColor                                                                                          
                                             , BorderStyle                    bs )
    {
      
      ICellStyle style = doc.CreateCellStyle();

      style.SetFont ( fonts[fs_name] );
      style.DataFormat             = formats[fs_name];
      style.Alignment              = ha;
      style.VerticalAlignment      = VerticalAlignment.Center;
      style.WrapText               = true;
      style.FillForegroundColor    = fillForegroundColor;
      style.FillPattern            = FillPattern.SolidForeground;
      style.BorderLeft             = bs;
      style.BorderTop              = bs;
      style.BorderRight            = bs;
      style.BorderBottom           = bs;  

      return style;
    }
    
    /**************************************************************************
     * createStyles */
    /**
     * Create cell styles
     * 
     ***************************************************************************/
   
   protected static Dictionary <string, ICellStyle> createStyles (   ref IWorkbook                  doc
                                                                   , ref Dictionary <string, short> formats 
                                                                   , ref Dictionary <string, IFont> fonts 
                                                                   , short                          fillForegroundColor                                                                   
                                                                   , HorizontalAlignment            haEmpty
                                                                   , HorizontalAlignment            haDate
                                                                   , HorizontalAlignment            haBoolean
                                                                   , HorizontalAlignment            haNumber
                                                                   , HorizontalAlignment            haString
                                                                   , BorderStyle                    bs)    
   {

     Dictionary <string, ICellStyle> styles = new Dictionary <string,ICellStyle>();
                                        
     /*###########################################################################
       # Add styles for each format style constant to the dictionary
       ###########################################################################*/ 
   
     styles.Add ( FS_EMPTY,           createStyle (FS_EMPTY,              haEmpty,   ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );
     styles.Add ( FS_TIME,            createStyle (FS_TIME,               haDate,    ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );
     styles.Add ( FS_DATE,            createStyle (FS_DATE,               haDate,    ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );
     styles.Add ( FS_DATE_MONTH_YEAR, createStyle (FS_DATE_MONTH_YEAR,    haDate,    ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );
     styles.Add ( FS_BOOLEAN,         createStyle (FS_BOOLEAN,            haBoolean, ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );
     styles.Add ( FS_INTEGER,         createStyle (FS_INTEGER,            haNumber,  ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );
     styles.Add ( FS_FLOAT,           createStyle (FS_FLOAT,              haNumber,  ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );
     styles.Add ( FS_PERCENT,         createStyle (FS_PERCENT,            haNumber,  ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );
     styles.Add ( FS_DECIMAL,         createStyle (FS_DECIMAL,            haNumber,  ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );
     styles.Add ( FS_STRING,          createStyle (FS_STRING,             haString,  ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );
     styles.Add ( FS_EMAIL,           createStyle (FS_EMAIL,              haString,  ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );
     styles.Add ( FS_URI,             createStyle (FS_URI,                haString,  ref doc, ref formats, ref fonts, fillForegroundColor, bs ) );


     return styles;

   }
    
   /**************************************************************************
    * createStylesTitleOrFooter */
   /**
    * Create styles for either common title or footer rows
    * 
    ***************************************************************************/
   
   protected static Dictionary <string, ICellStyle> createStylesTitleOrFooter (  ref IWorkbook                  doc
                                                                               , ref Dictionary <string, short> formats 
                                                                               , ref Dictionary <string, IFont> fonts  )
                                           
   {
   
     return createStyles ( ref doc
                         , ref formats
                         , ref fonts
                         , IndexedColors.White.Index
                         , HorizontalAlignment.Center
                         , HorizontalAlignment.Center
                         , HorizontalAlignment.Center
                         , HorizontalAlignment.Center
                         , HorizontalAlignment.Center
                         , BorderStyle.None);
   } 
   
   /**************************************************************************
    * createStylesTh */
   /**
    * Create fonts for table header.  This is commonly used
    * 
    ***************************************************************************/
      
   protected static Dictionary <string, ICellStyle> createStylesTh (  ref IWorkbook                  doc
                                                                    , ref Dictionary <string, short> formats 
                                                                    , ref Dictionary <string, IFont> fonts  )
                                           
   {
     return createStyles ( ref doc
                         , ref formats
                         , ref fonts
                         , IndexedColors.Black.Index
                         , HorizontalAlignment.Center
                         , HorizontalAlignment.Center
                         , HorizontalAlignment.Center
                         , HorizontalAlignment.Center
                         , HorizontalAlignment.Center
                         , BorderStyle.Thin);
   } 

   /**************************************************************************
    * createStylesTd */
   /**
    * Create fonts for table details.  This is commonly used.
    * 
    ***************************************************************************/
   
   protected static Dictionary <string, ICellStyle> createStylesTd (  ref IWorkbook                  doc
                                                                    , ref Dictionary <string, short> formats 
                                                                    , ref Dictionary <string, IFont> fonts )    
   {
     return createStyles ( ref doc
                         , ref formats
                         , ref fonts
                         , IndexedColors.White.Index
                         , HorizontalAlignment.Left
                         , HorizontalAlignment.Center
                         , HorizontalAlignment.Center
                         , HorizontalAlignment.Right
                         , HorizontalAlignment.Left
                         , BorderStyle.Thin);
   } 
   
   /**************************************************************************
    * createCell */
   /**
    * Create cell 
    * 
    ***************************************************************************/

   protected static ICell createCell (  ref IRow                             row
                                      , ref int                              colCtr
                                      , ref Dictionary <string, ICellStyle>  styles
                                      , ref Object                           value )
	 {
                                    
     /*###########################################################################
       # Get references to styles using format style constants
       ###########################################################################*/ 
    
     ICellStyle emptyStyle         = styles [FS_EMPTY];
     ICellStyle dateStyle          = styles [FS_DATE];
     ICellStyle timeStyle          = styles [FS_TIME];
     ICellStyle dateMonthYearStyle = styles [FS_DATE_MONTH_YEAR];
     ICellStyle booleanStyle       = styles [FS_BOOLEAN];
     ICellStyle integerStyle       = styles [FS_INTEGER];
     ICellStyle floatStyle         = styles [FS_FLOAT];
     ICellStyle percentStyle       = styles [FS_PERCENT];
     ICellStyle decimalStyle       = styles [FS_DECIMAL];
     ICellStyle stringStyle        = styles [FS_STRING];                                  
     ICellStyle emailStyle         = styles [FS_EMAIL];
     ICellStyle uriStyle           = styles [FS_URI];
     
     /*###########################################################################
       # Create cell object and advance column counter
       ###########################################################################*/ 
        
	   ICell cell = row.CreateCell(colCtr);
	   colCtr++;
	  
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
      
	   if (valueDataClass == Util.ValueDataClass.EMPTY)
	   {
	     cell.SetCellType (CellType.String);
	     cell.SetCellValue (valueString);
	     cell.CellStyle = emptyStyle;
	     return cell;
	   }
	   	    	  	
	   /*###########################################################################
       # Datetime, cell will be date
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.DATETIME_MONTH_YEAR ) 
	   {
	     cell.SetCellType ( CellType.Numeric );
	     cell.CellStyle = dateMonthYearStyle;	      	      
	     cell.SetCellValue ( valueDateTime.Value );
	     return cell;
	   }

     /*###########################################################################
       # Time, cell will be string formatted as time.  
       # TODO: Find a way to strip date component out
       ###########################################################################*/ 

	   if (valueDataClass == Util.ValueDataClass.TIME) 
	   {
	     cell.SetCellType (CellType.String);
	     cell.CellStyle = timeStyle;
	     cell.SetCellValue (valueDateTime.Value.ToShortTimeString());
	     return cell;
	   }
	   
	   /*###########################################################################
       # Datetime, cell will be date
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.DATETIME ) 
	   {
	     cell.SetCellType ( CellType.Numeric );
	     cell.CellStyle = dateStyle;	      	      
	     cell.SetCellValue ( valueDateTime.Value );
	     return cell;
	   }
	    
	   /*###########################################################################
       # Boolean, cell will be string rep of boolean (Yes/No)
       ##########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.BOOLEAN )  
	   {
	     cell.SetCellType ( CellType.String );	      
	     cell.CellStyle = booleanStyle;	      
	     cell.SetCellValue ( valueString );	     
	     return cell;
	   }
	    
	   /*###########################################################################
       # Integer, cell will be integer
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.NUMBER_INTEGER )	        
	   {
	     cell.SetCellType ( CellType.Numeric );
       cell.CellStyle = integerStyle;       
       cell.SetCellValue ( valueFloating.Value );
       return cell;
	   }
	    
	   /*###########################################################################
       # Value is a float, cell will be a float
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.NUMBER_FLOATING )
	   {
	     cell.SetCellType ( CellType.Numeric );
	     cell.CellStyle = floatStyle;
	     cell.SetCellValue ( valueFloating.Value );
	     return cell;
	   }
	    
	   /*###########################################################################
       # Value is a decimal, cell will be a decimal
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.NUMBER_FIXED )
	   {
	     cell.SetCellType ( CellType.Numeric );
	     cell.CellStyle = decimalStyle;
	     cell.SetCellValue ( valueFloating.Value );
	     return cell;
	   }

     /*###########################################################################
       # Value is a string percent
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.STRING_PERCENTAGE )
	   {
	     //cell.SetCellType ( CellType.String );
	     cell.SetCellType ( CellType.Numeric );
	     cell.CellStyle = percentStyle;
	     cell.SetCellValue ( valueFloating.Value);
	     //cell.SetCellValue ( valueString );
	     return cell;
	   }
	   
	   /*###########################################################################
       # Value is an email
       ###########################################################################*/ 

     if ( valueDataClass == Util.ValueDataClass.STRING_EMAIL )
     {
       cell.SetCellType ( CellType.String );
	     cell.CellStyle = emailStyle;
	     cell.SetCellValue ( valueString );

	     IHyperlink link = new XSSFHyperlink(HyperlinkType.Email);
	     link.Label      = valueString;
	     link.Address    = @"mailto:" + valueString;
       
       cell.Hyperlink  = link;       
       
	     return cell;
     }
	   
	   /*###########################################################################
       # Value is an Uri
       ###########################################################################*/ 

     if ( valueDataClass == Util.ValueDataClass.STRING_URI )
     {
       cell.SetCellType ( CellType.String );
	     cell.CellStyle = uriStyle;
	     cell.SetCellValue ( valueString );

	     IHyperlink link = new XSSFHyperlink(HyperlinkType.Url);
	     link.Label      = valueString;
	     link.Address    = valueString;
       
       cell.Hyperlink  = link;       
       
	     return cell;
     }
	   
	   /*###########################################################################
       # Value is a native string
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.STRING )
	   {
	     cell.SetCellType ( CellType.String );
	     cell.CellStyle = stringStyle;
	     cell.SetCellValue ( valueString );
	     return cell;
     }
	   
	   if ( valueDataClass == Util.ValueDataClass.UNKNOWN )
     {
       cell.SetCellType ( CellType.String );
	     cell.CellStyle = stringStyle;
	     cell.SetCellValue ( valueString );
	     return cell;
     }   
	    	    	    
	   cell.SetCellType ( CellType.String );
	   cell.CellStyle = stringStyle;
	   cell.SetCellValue ( valueString );
	    
	   return cell;
	  
	 }
   
   /**************************************************************************
    * setupPrinting */
   /**
    * Set print settings
    * 
    ***************************************************************************/
 
   protected static void setupPrinting ( ref IWorkbook doc
                                       , ref ISheet table
                                       , int firstCol
                                       , int lastCol
                                       , int firstRow
                                       , int rowNumRepeatHeader
                                       , int lastRow )
   {
      /*###########################################################################
        # Setup printing
        ###########################################################################*/                         
      
      int estHeight = lastRow / 25;      
      

      doc.SetPrintArea ( 0, firstCol, lastCol, firstRow, lastRow );      
      table.RepeatingRows = new CellRangeAddress ( firstRow, rowNumRepeatHeader, firstCol, lastCol );      

      /*-------------------------------
       * Page header
       *------------------------------*/

      table.Header.Left   = "";
      table.Header.Center = "";
      table.Header.Right  = "";   

      /*-------------------------------
       * Page footer
       *------------------------------*/

      table.Footer.Left   = "Page " + HeaderFooter.Page + " of " + HeaderFooter.NumPages;
      table.Footer.Center = Messages.CONFIDENTIAL;
      table.Footer.Right  = "Generated on " + DateTime.Now.ToString();                      
       
      /*-------------------------------
       * Margins
       *------------------------------*/

      table.SetMargin (MarginType.RightMargin,  (double) 0.25);
      table.SetMargin (MarginType.TopMargin,    (double) 0.50);
      table.SetMargin (MarginType.LeftMargin,   (double) 0.25);
      table.SetMargin (MarginType.BottomMargin, (double) 0.50);       
      table.PrintSetup.HeaderMargin = (double) 0.25;
      table.PrintSetup.FooterMargin = (double) 0.25;                   
       
      /*-------------------------------
       * Scale to fit
       *------------------------------*/

      table.PrintSetup.Landscape    = true;
      table.PrintSetup.PaperSize    = (short) PaperSize.US_Letter;
      table.Autobreaks              = true;
      table.FitToPage               = true;      
      table.VerticallyCenter        = false;
      table.HorizontallyCenter      = true;
      table.PrintSetup.FitHeight    = (short) estHeight;
      table.PrintSetup.FitWidth     = (short) 1;

      /*-------------------------------
       * Print quality and copies
       *------------------------------*/
      
      table.PrintSetup.NoColor      = false;       
      table.PrintSetup.Draft        = false;     
      table.PrintSetup.Copies       = (short) 1;      
   
   }
  
   /**************************************************************************
    * autosizeColWidth */
   /**
    * Adjust column width of given colNum to ideal width
    * 
    * @param  rd    ReturnDataTable
    ***************************************************************************/
  
   protected static void autosizeColWidth ( ref ISheet table, int colNum )
   {
     table.AutoSizeColumn(colNum);
     int w = table.GetColumnWidth(colNum);
     w = w + COL_WIDTH_PADDING;
     if (w >  MAX_COL_WIDTH) w = MAX_COL_WIDTH;         
     table.SetColumnWidth(colNum, w);
   }
   
   /**************************************************************************
    * autosizeColWidths */
   /**
    * Autosize column widths of from firstCol to lastCol
    * 
    * @param  rd    ReturnDataTable
    ***************************************************************************/

   protected static void autosizeColWidths ( ref ISheet table, int firstCol, int lastCol )
   {        
     
     for ( int colNum = firstCol ; colNum <= lastCol ; colNum++ )
     {
       autosizeColWidth (ref table, colNum);
     }
       
   }
   
   /**************************************************************************
    * ReturnDataTableToFile */
   /**
    * Generates a file from a ReturnDataTable instance
    * 
    * @param  rd    ReturnDataTable
    ***************************************************************************/
  
   public static Byte[] returnDataTableToFileFromScratch ( ref ReturnDataTable rd )
   {
                             
      /*###########################################################################
        # File and document objects
        ###########################################################################*/ 

      MemoryStream   ms                 = new MemoryStream ();      
      IWorkbook      doc                = new XSSFWorkbook ();
     
      ISheet         table              = doc.CreateSheet(rd.tableName);                
      IRow           currentRow         = null;         	           
      ICell          currentCell        = null; 

      
      /*###########################################################################
        # Counters
        ###########################################################################*/ 

      int            rowCtr             = 0;
      int            colCtr             = 0;
      int            colPtr             = 0;      
      
      /*###########################################################################
        # Key row numbers
        ###########################################################################*/ 
         
      int            rowNumTitleStart   = 0;
      int            rowNumTitleEnd     = 0;
      int            rowNumTableStart   = 0;
      int            rowNumTableEnd     = 0;
      int            rowNumFooterStart  = 0;
      int            rowNumFooterEnd    = 0;
      
      int            rowNumRepeatHeader = 0;
      int            rowNumFreeze       = 0;
      
         
      /*###########################################################################
        # Max values
        ###########################################################################*/ 
      
      int            firstCol           = 0;
      int            lastCol            = 0;
      int            firstRow           = 0;
      int            lastRow            = 0;           
      //int            maxColChars        = 50;
      //int            maxColWidth        = maxColChars * 256;
      
      /*###########################################################################
        # User defined data formats
        ###########################################################################*/ 
            
      Dictionary <string, short> formats = createFormats (ref doc);            
     
      /*###########################################################################
        # Fonts
        ###########################################################################*/ 
      
      Dictionary <string, IFont> fontsTitle  = createFontsTitle  ( ref doc );
      Dictionary <string, IFont> fontsFooter = createFontsFooter ( ref doc );
      Dictionary <string, IFont> fontsTh     = createFontsTh     ( ref doc );
      Dictionary <string, IFont> fontsTd     = createFontsTd     ( ref doc );
         
      /*###########################################################################
        # Styles
        ###########################################################################*/ 
      
      Dictionary <string, ICellStyle> stylesTitle  = createStylesTitleOrFooter (ref doc, ref formats, ref fontsTitle);
      Dictionary <string, ICellStyle> stylesFooter = createStylesTitleOrFooter (ref doc, ref formats, ref fontsFooter);
      Dictionary <string, ICellStyle> stylesTh     = createStylesTh            (ref doc, ref formats, ref fontsTh);
      Dictionary <string, ICellStyle> stylesTd     = createStylesTd            (ref doc, ref formats, ref fontsTd);
      
      rowCtr = firstRow;
      colCtr = firstCol;
      
      /*###########################################################################
        # Create titles
        ###########################################################################*/ 
        
      rowNumTitleStart          = rowCtr;
      currentRow                = null;
      currentRow                = table.CreateRow(rowCtr);                                
      currentRow.HeightInPoints = (short) -1;
      rowCtr++;                
   
      colCtr                    = firstCol;       
      Object titleVal           = rd.tableName;
      currentCell               = null;
      currentCell               = createCell(ref currentRow, ref colCtr, ref stylesTitle, ref titleVal);
            
      currentRow                = null;
      currentRow                = table.CreateRow(rowCtr);                                
      currentRow.HeightInPoints = (short) -1;
      rowNumTitleEnd            = rowCtr;
      rowCtr++;                
      
      /*###########################################################################
        # Get position of table start and repeating header
        ###########################################################################*/ 
                    
      rowNumTableStart   = rowCtr;
      rowNumRepeatHeader = rowCtr;
      
      /*###########################################################################
        # Create table head
        ###########################################################################*/ 
            
      /*-------------------------------
       * Create row
       *------------------------------*/
      
      currentRow = null; 
      currentRow = table.CreateRow(rowCtr);
      currentRow.HeightInPoints = (short) 75;
      
      /*-------------------------------
       * Create columns
       *------------------------------*/

      colCtr = firstCol;       

      foreach (aoColumn col in rd.aoColumns)
      {        
        if (col.bVisible)
        {           
          /*-------------------------------
           * Replace spaces with breaks
           * if specified
           *------------------------------*/
          
          if (rd.columnTitlesReplaceSpacesWithBreaks == true)
          {
            col.sTitle = col.sTitle.Replace(@" ","\n");
          }

          /*-------------------------------
           * Create cell
           *------------------------------*/
          
          Object colTitle = col.sTitle;
          currentCell = null;
          currentCell = createCell(ref currentRow, ref colCtr, ref stylesTh, ref colTitle);
	        	        
        }
      }
	    
	    /*-------------------------------
       * Update row count
       *------------------------------*/
       
	    rowCtr++;

      /*###########################################################################
        # Get position of freeze
        ###########################################################################*/ 

      rowNumFreeze = rowCtr;
     
      /*###########################################################################
        # Determine last column
        ###########################################################################*/ 

	    lastCol = colCtr-1;
	                          
      /*###########################################################################
        # Merge title cells
        ###########################################################################*/ 

      for (int rowNumTitle = rowNumTitleStart; rowNumTitle <= rowNumTitleEnd; rowNumTitle++)
      {
        table.AddMergedRegion ( new CellRangeAddress (rowNumTitle,rowNumTitle,firstCol,lastCol) ); 
      }
      
      /*###########################################################################
        # Create table body
        ###########################################################################*/ 

      foreach (Object[] arow in rd.aaData)        
      {                
       
       /*-------------------------------
        * Create row
        *------------------------------*/

        currentRow  = null;
        currentRow  = table.CreateRow (rowCtr);
                       
       /*-------------------------------
        * Create columns
        *------------------------------*/
 
        colPtr = firstCol;
        colCtr = firstCol;
        
        foreach (Object fld in arow)
        {

          /*-------------------------------
           * Get related column definition
           *------------------------------*/
 
          aoColumn colDef = rd.aoColumns[colPtr];

          if (colDef.bVisible)
          {              
            /*-------------------------------
             * Create cell
             *------------------------------*/

            Object val  = fld;
            currentCell = null;
            currentCell = createCell(ref currentRow, ref colCtr, ref stylesTd, ref val);           
          }              
          colPtr++;
        }
                         
        /*-------------------------------
         * Update row count
         *------------------------------*/

        rowCtr++;

      }
      
      /*###########################################################################
        # Get position of table data end
        ###########################################################################*/ 

      rowNumTableEnd = rowCtr - 1;
      
      /*###########################################################################
        # Create footer
        ###########################################################################*/ 
        
      rowNumFooterStart         = rowCtr;
      currentRow                = null;
      currentRow                = table.CreateRow(rowCtr);                                
      currentRow.HeightInPoints = (short) -1;
      rowNumTitleEnd            = rowCtr;
      rowCtr++;                

      rowNumFooterEnd           = rowCtr;
      currentRow                = null;
      currentRow                = table.CreateRow(rowCtr);                                
      currentRow.HeightInPoints = (short) -1;
      rowCtr++;                
      
      colCtr                    = firstCol;       
      Object footerVal          = rd.tableFooter;
      currentCell               = null;
      currentCell               = createCell(ref currentRow, ref colCtr, ref stylesFooter, ref footerVal);
      colCtr                    = firstCol;
      
      /*###########################################################################
        # Merge footer cells
        ###########################################################################*/ 
            
      for (int rowNumFooter = rowNumFooterStart; rowNumFooter <= rowNumFooterEnd; rowNumFooter++)
      {
        table.AddMergedRegion ( new CellRangeAddress (rowNumFooter,rowNumFooter,firstCol,lastCol) ); 
      }
      
      /*###########################################################################
        # Determine last row
        ###########################################################################*/ 
    
      lastRow = rowCtr - 1;
   
      /*###########################################################################
        # Setup printing
        ###########################################################################*/                         
  
      setupPrinting ( ref doc, ref table, firstCol, lastCol, firstRow, rowNumRepeatHeader, lastRow );
      
      /*###########################################################################
        # Setup user interface
        ###########################################################################*/                         
      
      table.DisplayGridlines = false;

      /*-------------------------------
       * Create fixed table header
       *------------------------------*/

      table.CreateFreezePane   (firstCol, rowNumFreeze );            
      
      /*-------------------------------
       * Create autofilter
       *------------------------------*/

      table.SetAutoFilter    ( new CellRangeAddress (rowNumTableStart, rowNumTableEnd, firstCol, lastCol) );
      
      /*-------------------------------
       * Autosize rows
       *------------------------------*/
       
      for (int rowNum = rowNumFreeze; rowNum < rowNumFooterStart; rowNum++)
      {
        table.GetRow(rowNum).Height = (short) - 1;
      }

      /*-------------------------------
       * Autosize columns 
       * Can take awhile for big sheets
       * May want to disable if needed
       *------------------------------*/
      
      if (rd.excelFileFromScratchAutoSizeColumns == true)
      {         
        autosizeColWidths (ref table, firstCol, lastCol);
      }  
      
      /*-------------------------------
       * Set active cell to first cell
       * in table body
       *------------------------------*/
                                
      table.SetActiveCell (1, 0);
                 
      /*###########################################################################
        # Create file bytes and return
        ###########################################################################*/
              
	    doc.Write(ms);
      byte[] b1 = ms.ToArray();
      return b1;	
    }    
   
   /**************************************************************************
    * populateExistingCell */
   /**
    ***************************************************************************/

   protected static void populateExistingCell (   ref ICell   cell
                                                , ref Object  value )
	 {
                                    
     if (cell == null) return;
     if (cell.CellType == CellType.Formula) return;
     
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
      
	   if (valueDataClass == Util.ValueDataClass.EMPTY)
	   {
	     cell.SetCellType (CellType.String);
	     cell.SetCellValue (valueString);	     
	     return;
	   }
	   	    	  	
	   /*###########################################################################
       # Datetime, cell will be date
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.DATETIME_MONTH_YEAR ) 
	   {
	     cell.SetCellType ( CellType.Numeric );
	     cell.SetCellValue ( valueDateTime.Value );
	     return;
	   }

     /*###########################################################################
       # Time, cell will be string formatted as time.  
       # TODO: Find a way to strip date component out
       ###########################################################################*/ 

	   if (valueDataClass == Util.ValueDataClass.TIME) 
	   {
	     cell.SetCellType (CellType.String);
	     cell.SetCellValue (valueDateTime.Value.ToShortTimeString());
	     return;
	   }
	   
	   /*###########################################################################
       # Datetime, cell will be date
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.DATETIME ) 
	   {
	     cell.SetCellType ( CellType.Numeric );
	     cell.SetCellValue ( valueDateTime.Value );
	     return;
	   }
	    
	   /*###########################################################################
       # Boolean, cell will be string rep of boolean (Yes/No)
       ##########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.BOOLEAN )  
	   {
	     cell.SetCellType ( CellType.String );	      
	     cell.SetCellValue ( valueString );	     
	     return;
	   }
	    
	   /*###########################################################################
       # Integer, cell will be integer
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.NUMBER_INTEGER )	        
	   {
	     cell.SetCellType ( CellType.Numeric );
       cell.SetCellValue ( valueFloating.Value );
       return;
	   }
	    
	   /*###########################################################################
       # Value is a float, cell will be a float
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.NUMBER_FLOATING )
	   {
	     cell.SetCellType ( CellType.Numeric );
	     cell.SetCellValue ( valueFloating.Value );
	     return;
	   }
	    
	   /*###########################################################################
       # Value is a decimal, cell will be a decimal
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.NUMBER_FIXED )
	   {
	     cell.SetCellType ( CellType.Numeric );
	     cell.SetCellValue ( valueFloating.Value );
	     return;
	   }

     /*###########################################################################
       # Value is a string percent
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.STRING_PERCENTAGE )
	   {
	     cell.SetCellType ( CellType.Numeric );
	     cell.SetCellValue ( valueFloating.Value);
	     return;
	   }
	   
	   /*###########################################################################
       # Value is an email
       ###########################################################################*/ 

     if ( valueDataClass == Util.ValueDataClass.STRING_EMAIL )
     {
       cell.SetCellType ( CellType.String );
	     cell.SetCellValue ( valueString );              
	     return;
     }
	   
	   /*###########################################################################
       # Value is an Uri
       ###########################################################################*/ 

     if ( valueDataClass == Util.ValueDataClass.STRING_URI )
     {
       cell.SetCellType ( CellType.String );
	     cell.SetCellValue ( valueString );       
	     return;
     }
	   
	   /*###########################################################################
       # Value is a native string
       ###########################################################################*/ 

	   if ( valueDataClass == Util.ValueDataClass.STRING )
	   {
	     cell.SetCellType ( CellType.String );
	     cell.SetCellValue ( valueString );
	     return;
     }
	   
	   if ( valueDataClass == Util.ValueDataClass.UNKNOWN )
     {
       cell.SetCellType ( CellType.String );
	     cell.SetCellValue ( valueString );
	     return;
     }   
	    	    	    
	   cell.SetCellType ( CellType.String );
	   cell.SetCellValue ( valueString );
	   
	   return;
	  
	 }
	 
   /**************************************************************************
    * returnDataTableToFileUsingTemplate */
   /**
    * Generates file bytes from a ReturnDataTable instance and a template
    * file.  Falls back to generation from scratch if there is a problem
    * with the template.
    * 
    * @param  rd                   ReturnDataTable
    ***************************************************************************/
 
   public static byte[] returnDataTableToFileUsingTemplate (  ref ReturnDataTable rd )
   {            
    
      /*###########################################################################
        # Fallback if template flag not set
        ###########################################################################*/

      if (!rd.useTemplates) 
      {        
        return returnDataTableToFileFromScratch(ref rd);
      }
      
      /*###########################################################################
        # Fallback if template object for Excel not defined
        ###########################################################################*/

      if (rd.excelTemplate == null) 
      {
        return returnDataTableToFileFromScratch(ref rd);
      }
      
      /*###########################################################################
        # Fallback if template flag in templateObject not set
        ###########################################################################*/

      if (!rd.excelTemplate.useTemplate) 
      {
        rd.useTemplates              = false;
   	    rd.excelTemplate.useTemplate = false;
        return returnDataTableToFileFromScratch(ref rd);
      }
      
      /*###########################################################################
        # Fallback if template file not defined
        ###########################################################################*/

   	  if (String.IsNullOrEmpty(rd.excelTemplate.templateFilePathAndName()))
   	  {
   	    rd.useTemplates              = false;
   	    rd.excelTemplate.useTemplate = false;
   	    return returnDataTableToFileFromScratch(ref rd);
   	  }
   	  
   	  /*###########################################################################
        # Fallback if template file not found
        ###########################################################################*/

   	  if (!System.IO.File.Exists(rd.excelTemplate.templateFilePathAndName()))
      {
        rd.useTemplates              = false;
        rd.excelTemplate.useTemplate = false;
   	    return returnDataTableToFileFromScratch(ref rd);
      }
   	          
      /*###########################################################################
        # Set default value for sheet number if needed
        ###########################################################################*/

      if (!rd.excelTemplate.sheetNum.HasValue)          rd.excelTemplate.sheetNum          = 0;
      if (!rd.excelTemplate.startOfDataColNum.HasValue) rd.excelTemplate.startOfDataColNum = 0; 
      if (!rd.excelTemplate.startOfDataRowNum.HasValue) rd.excelTemplate.startOfDataRowNum = 1; /* Assuming a header row */

      /*###########################################################################
        # Get template workbook and fall back if there is a problem
        ###########################################################################*/
      
      FileStream fs = null;
      IWorkbook  wb = null;
      
      try
      {
        fs = new FileStream (   rd.excelTemplate.templateFilePathAndName()
                              , FileMode.Open
                              , FileAccess.Read
                              , FileShare.Read );

        wb = WorkbookFactory.Create(fs);      
      }
      catch
      {
        rd.useTemplates              = false;
        rd.excelTemplate.useTemplate = false;    
        return returnDataTableToFileFromScratch(ref rd);
      }
      finally
      {
        if (fs != null) {
          fs.Close();
        }
      }
      
      if (wb == null)
      {
        rd.useTemplates              = false;
        rd.excelTemplate.useTemplate = false;       	  
   	    return returnDataTableToFileFromScratch(ref rd);
      }
      
      /*###########################################################################
        # Get template sheet and fall back if there is a problem with it
        ###########################################################################*/
           
      ISheet sheet = null;
      
      try
      {
        sheet = wb.GetSheetAt (rd.excelTemplate.sheetNum.Value);
			}
			catch
			{
			  rd.useTemplates              = false;
        rd.excelTemplate.useTemplate = false;       	  
   	    return returnDataTableToFileFromScratch(ref rd);
			}    
			
			if (sheet == null)
			{
			  rd.useTemplates              = false;
        rd.excelTemplate.useTemplate = false;       	  
   	    return returnDataTableToFileFromScratch(ref rd);
			}
			                       
      /*###########################################################################
        # Get formula evaluator and clear all cached results
        # Note: We will use the formula evaluator in post population 
        ###########################################################################*/
      
      IFormulaEvaluator fe = wb.GetCreationHelper().CreateFormulaEvaluator();
			fe.ClearAllCachedResultValues();
     	              
      /*###########################################################################
        # Set default values for start of row and col numbers if needed
        ###########################################################################*/

      if (!rd.excelTemplate.startOfDataColNum.HasValue) rd.excelTemplate.startOfDataColNum = 0; 
      if (!rd.excelTemplate.startOfDataRowNum.HasValue) rd.excelTemplate.startOfDataRowNum = 1; /* Assuming a header row */

      /*###########################################################################
        # Populate sheet with data
        ###########################################################################*/

      int  rowPtr        = 0;
      int  colPtr        = 0;      
      
      int  rowIdx        = rd.excelTemplate.startOfDataRowNum.Value;
      int  colIdx        = rd.excelTemplate.startOfDataColNum.Value;
      bool templateIsXls = rd.excelTemplate.templateFileIsXLS();
                         
      foreach (Object[] arow in rd.aaData)        
      {                                          
       /*-------------------------------
         * Stop processing rows if we
         * reach a limit
         *------------------------------*/
       
        if (rd.excelTemplate.endOfDataRowNum.HasValue)
        {
          if (rowIdx > rd.excelTemplate.endOfDataRowNum.Value) break;        
        }
                                       
        int minRowIdxForThisSheet = 0;
        int maxRowIdxForThisSheet = sheet.LastRowNum -1;
        
        if (!Util.IntegerValueIsBetween(rowIdx,minRowIdxForThisSheet,maxRowIdxForThisSheet)) break;                 
        if ((templateIsXls) && (rowIdx > Rules.MAX_EXCEL_ROWS))                              break;

       /*-------------------------------
         * Get row from template sheet
         *------------------------------*/

        IRow row = sheet.GetRow(rowIdx);
                
        if (row == null) break;
        
        colPtr = 0;        
        colIdx = rd.excelTemplate.startOfDataColNum.Value;
        
        foreach (Object fld in arow)
        {                   
          /* Get column def */
          aoColumn colDef = rd.aoColumns[colPtr];          
        
          /* Only process visible colums */        
          if (colDef.bVisible)
          {                                      
            /* Stop processing this rows columns and move on to next if we reach a limit */
            
            if (rd.excelTemplate.endOfDataColNum.HasValue)
            {
              if (colIdx > rd.excelTemplate.endOfDataColNum) break;
            }
            
            if (row.Cells == null) break;
            
            int minColIdxForThisRow = 0;
            int maxColIdxForThisRow = row.PhysicalNumberOfCells-1;
            
            if (rd.excelTemplate.limitToPhysicalCells)
              if (!Util.IntegerValueIsBetween(colIdx,minColIdxForThisRow,maxColIdxForThisRow)) break;

            ICell  cell = row.GetCell(colIdx,MissingCellPolicy.CREATE_NULL_AS_BLANK);            
            Object val  = fld;            
            populateExistingCell ( ref cell, ref val);
            colIdx++;
          }                        
          colPtr++;
        }
                
        rowIdx++;
        rowPtr++;                
     }       
        
 
     /*###########################################################################
      # Post Processing 
      ###########################################################################*/
    
    if (rd.excelTemplate.postPopulationProcessing)
    {

          if (rd.excelTemplate.forceFormulaRecalculate) sheet.ForceFormulaRecalculation = true;
   
          for (int rowNum = sheet.FirstRowNum; rowNum <= sheet.LastRowNum; rowNum++)
		  {

		   /*-------------------------------
        * Get row
        *------------------------------*/

		    IRow row = sheet.GetRow(rowNum);             
  			if (row == null) continue;        
      
        /*-------------------------------
         * Collapse row groups
         *------------------------------*/

        if (rd.excelTemplate.collapseRowGroups)
        {
          try
          {
            sheet.SetRowGroupCollapsed(rowNum,true);
          }
          catch
          {
            continue;
          }
			  }
       
        for (int colNum = row.FirstCellNum ; colNum <= row.LastCellNum; colNum++)
			  {

				  ICell cell = row.GetCell(colNum);
          if (cell == null) continue;           

          /*-------------------------------
           * Collapse column groups
           *------------------------------*/

          if (rd.excelTemplate.collapseColGroups)
          {
            try
            {
              sheet.SetColumnGroupCollapsed(colNum,true);
            }
            catch
            {
              continue;
            }
			    }
  
          /*-------------------------------
           * Reevaluate formulas
           *------------------------------*/

				  if (rd.excelTemplate.reEvaluateFormulas)
				  {
				    try
				    {
					    if (cell.CellType == CellType.Formula) fe.Evaluate(cell);
				    }
		        catch
				    {
				      continue;
			      }
			    }
		    }
		  }

		}
				
		 /*###########################################################################
       # Create file bytes and return
       ###########################################################################*/
     
     MemoryStream  ms = new MemoryStream();      
     wb.Write(ms);
     return ms.ToArray();      
      
   }
   
  /**************************************************************************
   * returnDataTableToFile */
  /**
   * Generates a file from a ReturnDataTable instance
   * 
   * @param  rd    ReturnDataTable
   ***************************************************************************/

   public static Byte[] returnDataTableToFile ( ref ReturnDataTable rd )
   {
     if (!rd.useTemplates) return returnDataTableToFileFromScratch   (ref rd);
     if (rd.useTemplates)  return returnDataTableToFileUsingTemplate (ref rd);
     return null;
   } 
    
    /**************************************************************************
     * returnRptDataToFile */
    /**
     * Generates a file from a ReturnRptData instance (Report Data)
     * 
     * @param  rd    ReturnRptData
     ***************************************************************************/
   
    public static Byte[] returnRptDataToFile ( ref ReturnRptData rd )
    {

      /*###########################################################################
        # Title
        ###########################################################################*/ 

      string tableTitle = @"Report";
           
      /*###########################################################################
        # File and document objects
        ###########################################################################*/ 

      MemoryStream   ms                 = new MemoryStream ();      
      IWorkbook      doc                = new XSSFWorkbook ();
      ISheet         table              = doc.CreateSheet(tableTitle);                
      IRow           currentRow         = null;         	           
      ICell          currentCell        = null; 

      /*###########################################################################
        # Counters
        ###########################################################################*/ 

      int            rowCtr             = 0;
      int            colCtr             = 0;
     
      /*###########################################################################
        # Key flags
        ###########################################################################*/ 
    
      bool           hasTitles          = false;
      bool           hasFooters         = false;
      
      /*###########################################################################
        # Key row numbers
        ###########################################################################*/ 
         
      int            rowNumTitleStart   = 0;
      int            rowNumTitleEnd     = 0;
      
      int            rowNumFooterStart  = 0;
      int            rowNumFooterEnd    = 0;
      
      int            rowNumRepeatHeader = 0;
      int            rowNumFreeze       = 0;
      
      /*###########################################################################
        # Max values
        ###########################################################################*/ 

      int            firstCol           = 0;
      int            lastCol            = 0;
      int            firstRow           = 0;
      int            lastRow            = 0;   
      int            estCharWidth       = 256;        
      int            maxColChars        = 50;
      int            maxColWidth        = maxColChars * estCharWidth;
      
      /*###########################################################################
        # User defined data formats
        ###########################################################################*/ 
            
      Dictionary <string, short> formats = createFormatsFinancial (ref doc);            
     
      /*###########################################################################
        # Fonts
        ###########################################################################*/ 
        
      Dictionary <string, IFont> fontsTitle     = createFontsTitle  ( ref doc );
      Dictionary <string, IFont> fontsFooter    = createFontsFooter ( ref doc );
      Dictionary <string, IFont> fontsTh        = createFontsTh     ( ref doc );
      Dictionary <string, IFont> fontsTd        = createFontsTd     ( ref doc );
      
      Dictionary <string, IFont> fontsAggregateSubTotal = createFonts (  ref doc
                                                                       , FONT_HEIGHT_10
                                                                       , FontBoldWeight.Bold
                                                                       , IndexedColors.Black.Index );

      Dictionary <string, IFont> fontsAggregateTotal = createFonts (  ref doc
                                                                       , FONT_HEIGHT_12
                                                                       , FontBoldWeight.Bold
                                                                       , IndexedColors.Black.Index );
      
      
      Dictionary <string, IFont> fontsBranch = createFonts (  ref doc
                                                            , FONT_HEIGHT_12
                                                            , FontBoldWeight.Bold
                                                            , IndexedColors.Black.Index );
            
      /*###########################################################################
        # Styles
        ###########################################################################*/ 
      
      Dictionary <string, ICellStyle> stylesTh     = createStylesTh            (ref doc, ref formats, ref fontsTh);
      Dictionary <string, ICellStyle> stylesTd     = createStylesTd            (ref doc, ref formats, ref fontsTd);
      Dictionary <string, ICellStyle> stylesTitle  = createStylesTitleOrFooter (ref doc, ref formats, ref fontsTitle);
      Dictionary <string, ICellStyle> stylesFooter = createStylesTitleOrFooter (ref doc, ref formats, ref fontsFooter);

      Dictionary <string, ICellStyle> stylesFill = createStyles (  ref doc
                                                                 , ref formats
                                                                 , ref fontsTd
                                                                 , IndexedColors.White.Index
                                                                 , HorizontalAlignment.Left
                                                                 , HorizontalAlignment.Left
                                                                 , HorizontalAlignment.Left
                                                                 , HorizontalAlignment.Left
                                                                 , HorizontalAlignment.Left
                                                                 , BorderStyle.None);
      
      Dictionary <string, ICellStyle> stylesAggregateSubTotal = createStyles ( ref doc
                                                                              , ref formats
                                                                              , ref fontsAggregateSubTotal
                                                                              , IndexedColors.LightYellow.Index
                                                                              , HorizontalAlignment.Left
                                                                              , HorizontalAlignment.Center
                                                                              , HorizontalAlignment.Center
                                                                              , HorizontalAlignment.Right
                                                                              , HorizontalAlignment.Left
                                                                              , BorderStyle.Hair);

      Dictionary <string, ICellStyle> stylesAggregateTotal = createStyles ( ref doc
                                                                           , ref formats
                                                                           , ref fontsAggregateTotal
                                                                           , IndexedColors.White.Index
                                                                           , HorizontalAlignment.Left
                                                                           , HorizontalAlignment.Center
                                                                           , HorizontalAlignment.Center                                                                      
                                                                           , HorizontalAlignment.Center
                                                                           , HorizontalAlignment.Left
                                                                           , BorderStyle.Hair);

      Dictionary <string, ICellStyle> stylesBranch = createStyles (  ref doc
                                                                   , ref formats
                                                                   , ref fontsBranch
                                                                   , IndexedColors.White.Index
                                                                   , HorizontalAlignment.Left
                                                                   , HorizontalAlignment.Left
                                                                   , HorizontalAlignment.Left
                                                                   , HorizontalAlignment.Left
                                                                   , HorizontalAlignment.Left
                                                                   , BorderStyle.None);          
                                                
      /*###########################################################################
        # Get copies of titles and footers we can use in our delegates
        ###########################################################################*/ 

      List<TitleOrFooter> titles  = rd.resultSetTitles;
      List<TitleOrFooter> footers = rd.resultSetFooters;
      
      /*###########################################################################
        # Create delegates for report data tree traversal
        ###########################################################################*/ 

	    TraverseNodesCallback startheader = delegate (Object[] args)
	    {	          
        
        firstRow = 0;
        firstCol = 0;
    	  rowCtr   = firstRow;
        colCtr   = firstCol;
        
    	  /*-------------------------------
         * Create title rows
         *------------------------------*/

        hasTitles        = false;
        rowNumTitleStart = rowCtr;

        foreach (TitleOrFooter title in titles)
        {
          if (!Util.IsNullOrEmpty(title.name))
          {         
            hasTitles                 = true;
            currentRow                = null;
            currentRow                = table.CreateRow(rowCtr);                                
            currentRow.HeightInPoints = (short) -1;
            rowCtr++;
                
            colCtr         = firstCol;       
            Object cellVal = title.name;
            currentCell    = null;
            currentCell    = createCell(ref currentRow, ref colCtr, ref stylesTitle, ref cellVal);
          }
        }
        	      
	      /*-------------------------------
         * If title rows exist put a blank
         * row in 
         *------------------------------*/

	      if (hasTitles == true)
        {
	        currentRow = table.CreateRow(rowCtr);
    	    rowCtr++;
	      }
	      
	      rowNumTitleEnd = rowCtr - 1;

	      /*-------------------------------
         * Get row number that will be
         * used for column headings
         * this will be used for a 
         * repeat header
         *------------------------------*/

	      rowNumRepeatHeader = rowCtr;
	      
	      /*-------------------------------
         * Create row for column headers
         *------------------------------*/
	      
	      currentRow = table.CreateRow(rowCtr); 	     	     
        currentRow.HeightInPoints = (short) 25;	      
        rowCtr++;
        colCtr = firstCol;            
	      
	    };
	  
	    TraverseNodesCallback headerop = delegate(Object[] args)
	    {
	      /*-------------------------------
         * Get column header title
         *------------------------------*/

	      InputColumnDefinition def = (InputColumnDefinition) args[0];	  	     	    
	     
        /*-------------------------------
         * Create cell
         *------------------------------*/
          
        Object colTitle = def.name;
        currentCell = null;
        currentCell = createCell(ref currentRow, ref colCtr, ref stylesTh, ref colTitle);
	     
	    };
	  
	    TraverseNodesCallback endheader = delegate(Object[] args)
	    {	      
       
        /*-------------------------------
         * Get total number of columns
         * and reset column ctr
         *------------------------------*/
       
        lastCol = colCtr-1;	   	                 	   
	      colCtr  = firstCol;
	      
	      /*-------------------------------
         * Now that we have the total 
         * number of columns, if we have
         * title rows we can merge title 
         * cells
         *------------------------------*/
        
        if (hasTitles == true)
        {
          for (int rowNumTitle = rowNumTitleStart; rowNumTitle <= rowNumTitleEnd; rowNumTitle++)
          {
            table.AddMergedRegion ( new CellRangeAddress (rowNumTitle,rowNumTitle,firstCol,lastCol) ); 
          }
	      }  	      
	   };
	  
	   GenericCallBack startbody = delegate()
	   {	 
	    
	     /*-------------------------------
        * Get row to freeze at
        *------------------------------*/

	     rowNumFreeze = rowCtr;

	   };
	  
	   
	   bool currentRowIsSubTotal   = false;
	   bool currentRowIsGrandTotal = false;
	   
	   TraverseNodesOperation startrow = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	   {
	    
	     string rowType         = (string) args[0];
	     string rowStripe       = (string) args[1];	    
	     int    fillto          = (int)    args[2];
	     int    agrTitlePos     = (int)    args[3];
       string agrTitleLabel   = (string) args[4];
	     int    agrTitleSpan    = (int)    args[5];
	     		     	    
	     /*-------------------------------
        * Reset column counter
        *------------------------------*/

	     colCtr = firstCol;

	     /*-------------------------------
        * Create row for table body
        *------------------------------*/

	     currentRow = table.CreateRow(rowCtr); 	
	     
	     /*-------------------------------
        * Create filler cells
        *------------------------------*/

	     for (int fill = 0; fill < fillto; fill++)
	     {	       
	      
	      /*-------------------------------
         * Create cell
         *------------------------------*/
          
        Object cellVal = @"";
        currentCell = null;
        currentCell = createCell(ref currentRow, ref colCtr, ref stylesFill, ref cellVal);
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
	       cell.SetCellValue(agrTitleLabel);       	       
	       
	       currentRowIsSubTotal   = false;
	       currentRowIsGrandTotal = false;
	       
	       if (agrTitlePos > 0) 
	       {
	         currentRowIsSubTotal   = true;
	         currentRowIsGrandTotal = false;	         
	         cell.CellStyle         = stylesAggregateSubTotal [FS_STRING];  
	       }
	       else
	       {
	         currentRowIsSubTotal   = false;
	         currentRowIsGrandTotal = true;
	         cell.CellStyle         = stylesBranch [FS_STRING];
	       }
	     
	     }
	     
	     rowCtr++;    	    	    	  
	  };
	  
	  TraverseNodesOperation nodeop  = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {	    
	    int span = (int) args[0];	    	    	                      
	  
      /*-------------------------------
       * If the node is a branch
       * treat it different
       *------------------------------*/ 

	    if (f.nodetype == TreeNodeType.BRANCH)
      {        
        /*-------------------------------
         * Create cell
         *------------------------------*/
          
        Object cellVal = f.identifiedValue.value;
        int branchStartCol = colCtr;
        currentCell = null;        
        currentCell = createCell(ref currentRow, ref colCtr, ref stylesBranch, ref cellVal);
        table.AddMergedRegion(new CellRangeAddress(currentRow.RowNum, currentRow.RowNum, branchStartCol, lastCol)); 
        currentRow.HeightInPoints = (short) 50;        
        return;
      }
      
      /*-------------------------------
       * If row type is detail
       *------------------------------*/ 

      if (f.rowtype == RowAttribute.DETAIL)
      {          
        Object cellVal = f.identifiedValue.value;
        currentCell = null;
        currentCell = createCell(ref currentRow, ref colCtr, ref stylesTd, ref cellVal);
        currentRow.HeightInPoints = (short) -1;
      }

      /*-------------------------------
       * If row type is aggregate
       *------------------------------*/ 

      else
      {        
        Object cellVal = f.identifiedValue.value;
        currentCell = null;
        
        if (currentRowIsSubTotal)   
        {
          currentCell = createCell(ref currentRow, ref colCtr, ref stylesAggregateSubTotal, ref cellVal);
          currentRow.HeightInPoints = (short) 25;
        }
        
        if (currentRowIsGrandTotal) 
        {
          currentCell = createCell(ref currentRow, ref colCtr, ref stylesAggregateTotal, ref cellVal);
          currentRow.HeightInPoints = (short) 75;
        }
      
      }

	  };
	  
	  TraverseNodesOperation endrow = delegate (ref DataTree dt, ref DataTreeNode f, Object[] args)
	  {	  	    
	  
	  };

	  GenericCallBack endbody = delegate()
	  {	    	            

      /*-------------------------------
       * Create extra row 
       *------------------------------*/

      currentRow = table.CreateRow(rowCtr);                                
      rowCtr++;
      
      /*-------------------------------
       * Create footer rows
       *------------------------------*/

      hasFooters        = false;
      rowNumFooterStart = rowCtr;
      
      foreach (TitleOrFooter footer in footers)
      {
        if (!Util.IsNullOrEmpty(footer.name))
        {         
          hasFooters                = true;
          currentRow                = null;
          currentRow                = table.CreateRow(rowCtr);                                
          currentRow.HeightInPoints = (short) -1;
          rowCtr++;
                
          colCtr         = firstCol;      
          Object cellVal = footer.name;
          currentCell    = null;
          currentCell    = createCell(ref currentRow, ref colCtr, ref stylesFooter, ref cellVal);
        }
      }
      
      rowNumFooterEnd = rowCtr - 1;
            
      /*-------------------------------
       * Get last row
       *------------------------------*/

      lastRow = rowCtr - 1;
      
      /*-------------------------------
       * Merge footer cells
       *------------------------------*/
        
      if (hasFooters == true)
      {
          for (int rowNumFooter = rowNumFooterStart; rowNumFooter <= rowNumFooterEnd; rowNumFooter++)
          {
            table.AddMergedRegion ( new CellRangeAddress (rowNumFooter,rowNumFooter,firstCol,lastCol) ); 
          }
	    }

     
	  };

                      	  
    /*###########################################################################
      # Create table
      ###########################################################################*/ 

	  int safetyCtr = 0;
	  int levelCtr  = DataTree.ROOT_LEVEL;

	  DataTree.TraverseForReport ( ref rd.datatree
	                             , DataTree.ROOT_NODE_ID
                               , ref safetyCtr
                               , ref levelCtr
                               , startheader
                               , headerop
                               , endheader
                               , startbody
                               , startrow
                               , nodeop
                               , endrow
                               , endbody );                                                                                    
   
      /*###########################################################################
        # Setup printing
        ###########################################################################*/                         
  
      setupPrinting ( ref doc, ref table, firstCol, lastCol, firstRow, rowNumRepeatHeader, lastRow );
      
                        
      /*###########################################################################
        # Setup user interface
        ###########################################################################*/                         
      
      table.DisplayGridlines = false;
      
      /*-------------------------------
       * Create fixed table header
       *------------------------------*/

      table.CreateFreezePane ( 0, rowNumFreeze );            
                
     /*-------------------------------
      * Autosize columns
      *------------------------------*/
      
      autosizeColWidths (ref table, firstCol, lastCol);
                           
      /*-------------------------------
       * Set active cell to first cell
       * in table body
       *------------------------------*/
                                
      table.SetActiveCell (rowNumFreeze, 0);
      
      /*###########################################################################
        # Create file bytes and return
        ###########################################################################*/
              
	    doc.Write(ms);
      byte[] b1 = ms.ToArray();
      return b1;	
    }    
    	            
  }
}
