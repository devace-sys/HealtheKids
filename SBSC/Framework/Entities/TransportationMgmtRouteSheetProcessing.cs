using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.IO;

// PDF

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.html;
using MBA;

namespace Spedmon
{
  
  /***************************************************************************
   * ReturnTransMgmtProcessingData
  /**
   *
   ***************************************************************************/

  public class ReturnTransportationMgmtProcessingData : Return
  {
    public ReturnTransportationMgmtProcessingData ()                 : base(){}
    public ReturnTransportationMgmtProcessingData (string msg)       : base(msg){}
    public ReturnTransportationMgmtProcessingData (Exception e)      : base(e){}
    public ReturnTransportationMgmtProcessingData (Warning e)        : base(e){}
    public ReturnTransportationMgmtProcessingData (Critical e)       : base(e){}  
    public ReturnTransportationMgmtProcessingData (SessionExpired e) : base(e){}
    
    public TransportationMgmtRecord  mgmtRec;      
  }
  
  /***************************************************************************
   * ReturnRouteSheetData
  /**
   *
   ***************************************************************************/

  public class ReturnRouteSheetData : Return
  {
    public ReturnRouteSheetData ()                 : base(){}
    public ReturnRouteSheetData (string msg)       : base(msg){}
    public ReturnRouteSheetData (Exception e)      : base(e){}
    public ReturnRouteSheetData (Warning e)        : base(e){}
    public ReturnRouteSheetData (Critical e)       : base(e){}  
    public ReturnRouteSheetData (SessionExpired e) : base(e){}
    
    public TransportationMgmtRecord                  mgmtRec;
    public TransportationMgmtRouteSheet              routeSheet;
    public List<TransportationMgmtRouteSheetMember>  routeSheetMembers;  
  
  }
      
  /***************************************************************************
   * RouteSheetTripDetail */
  /**
   * 
   **************************************************************************/   
  
  public class RouteSheetTripDetail
  {   
    public RouteSheetTripDetail(){}
        
    [IsDataGridCol(1)]
    [DataGridColTitle("Patient Sheet Member ID")]
    [DataGridColIsInputLabel(true)]
    [DataGridColIsInputKey(true)]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(1)]    
    public int sheetMemberID;
    
    [IsDataGridCol(2)]
    [DataGridColTitle("Patient SpEdCare ID")]
    [DataGridColIsInputLabel(true)]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(1)]    
    public int patID;
        
    [IsDataGridCol(3)]
    [DataGridColTitle("Student Name")]
    [DataGridColIsInputLabel(true)]
    [DataGridColWidth(200)]
    public string patName;
            
    [IsDataGridCol(4)]
    [DataGridColTitle("Miles")]
    [DataGridColIsInputLabel(true)]
    [DataGridColWidth(50)]
    public string miles;
    
    [IsDataGridCol(5)]       
    [DataGridColTitle("Mon")]    
    [DataGridColWidth(75)]    
    public bool? billMon;    

    [IsDataGridCol(6)]       
    [DataGridColTitle("Tue")]    
    [DataGridColWidth(75)]    
    public bool? billTue;    

    [IsDataGridCol(7)]       
    [DataGridColTitle("Wed")]    
    [DataGridColWidth(75)]    
    public bool? billWed;    

    [IsDataGridCol(8)]       
    [DataGridColTitle("Thu")]    
    [DataGridColWidth(75)]    
    public bool? billThu;    

    [IsDataGridCol(9)]       
    [DataGridColTitle("Fri")]    
    [DataGridColWidth(75)]    
    public bool? billFri;    
    
  }

  /***************************************************************************
   * RouteSheetTripDetails */
  /**
   *
   **************************************************************************/   
  
  public class RouteSheetTripDetails
  {
    public List<RouteSheetTripDetail> details;
  }
  
  /***************************************************************************
   * TransportationMgmtRouteSheetProcessing */
  /**
   *
   ***************************************************************************/
  
  public class TransportationMgmtRouteSheetProcessing : Entities
  {
        
    public const string URL_WEB_REPORT   = @"transport_mgmt_route_sheets_file.ashx";

    public static string URL_WEB_REPORT_BASE()
    {
        return MBA.HttpApplication.createLink(TransportationMgmtRouteSheetProcessing.URL_WEB_REPORT, true);
    }

    /***************************************************************************
     * rptGenerateRptHeaderLogoCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderLogoCell (string embeddedImageName, int rowSpan, int colSpan)
    {         
      System.Drawing.Image i1 = MBA.EmbeddedResources.CommonImages.GetImage(embeddedImageName);
      return PDFCommon.generateCell(i1,rowSpan,colSpan,1,1,Color.WHITE,Rectangle.NO_BORDER);
    }

    /***************************************************************************
     * rptGenerateRptHeaderBarcode */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderBarcodeCell (string text, int barCodeType, int rowSpan, int colSpan)
    {
       return PDFCommon.generateCell(text,barCodeType, rowSpan,colSpan,2,1,Color.WHITE,Rectangle.NO_BORDER);     
    }
    
    /***************************************************************************
     * rptGenerateRptHeaderLinkCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderLinkCell (string link, int rowSpan, int colSpan, ref Font font)
    {
      return PDFCommon.generateCell(link, link, ref font, rowSpan, colSpan, 1, 1, Color.WHITE,Rectangle.NO_BORDER);
    }
        
    /***************************************************************************
     * rptGenerateRptHeaderTitleCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderCellNoBorder (string text, int rowSpan, int colSpan, ref Font font)
    {      
      Chunk     chunk     = new Chunk(text,font);
      Paragraph paragraph = new Paragraph(chunk);
      return PDFCommon.generateCell(paragraph,rowSpan,colSpan,1,1,Color.WHITE,Rectangle.NO_BORDER);
    }
     
    /***************************************************************************
     * rptGenerateRptHeaderCellWithBorder */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderCellWithBorder (string text, int rowSpan, int colSpan, ref Font font)
    {
      Chunk     chunk     = new Chunk(text,font);
      Paragraph paragraph = new Paragraph(chunk);
      PdfPCell cell = PDFCommon.generateCell(paragraph,rowSpan,colSpan,1,1,Color.WHITE);
      cell.Padding = 5;
      return cell;
    }

    /***************************************************************************
     * rptGenerateRptHeaderWriteInCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderWriteInCell (int rowSpan, int colSpan) 
    {
      Paragraph paragraph = new Paragraph();
      PdfPCell cell        = PDFCommon.generateCell(paragraph,rowSpan,colSpan,1,1,Color.WHITE);      
      cell.Padding     = 15;
      return cell;
    }
        
    /***************************************************************************
     * rptGenerateRptHeaderServiceWeekCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderServiceWeekCell (long weekNum, DateTime startDate, int rowSpan, int colSpan, ref Font font1, ref Font font2)
    {
      List <Chunk> chunks = new List<Chunk>();      
      String weekNumStr = weekNum.ToString();
      String yearStr    = startDate.Year.ToString();
      chunks.Add(new Chunk(weekNumStr));      
      chunks.Add(new Chunk(yearStr,font2));      
      PdfPCell cell = PDFCommon.generateCell(chunks, rowSpan, colSpan, 1, 1, true, Color.WHITE);
      return cell;                
    }

    /***************************************************************************
     * rptGenerateRptHeaderPlaceCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderPlaceCell (string name, string address, int rowSpan, int colSpan, ref Font font1, ref Font font2)
    {
      List <Chunk> chunks = new List<Chunk>();      
      chunks.Add(new Chunk(name,   font1));
      chunks.Add(new Chunk(address,font2));      
      PdfPCell cell = PDFCommon.generateCell(chunks, rowSpan, colSpan, 1, 1, true, Color.WHITE);
      return cell;                
    }

    /***************************************************************************
     * rptGenerateColHeaderCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderColHeaderCell (string line1, string line2, int rowSpan, int colSpan, ref Font font1, ref Font font2)
    {      
      List <Chunk> chunks = new List<Chunk>();      
      chunks.Add(new Chunk(line1,font1));
      chunks.Add(new Chunk(line2,font2));      
      PdfPCell cell = PDFCommon.generateCell(chunks,rowSpan, colSpan,1,1,true,PDFCommon.COLOR_FE_FE_EE);
      return cell;            
    }
    
    /***************************************************************************
     * rptGenerateRptHeaderColHeaderDowDateCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderColHeaderDowDateCell(string dow, string date, ref Font font1, ref Font font2)
    {      
      PdfPCell cell = rptGenerateRptHeaderColHeaderCell (dow, date, 1, 2, ref font1, ref font2);            
      return cell;      
    }
    
    /***************************************************************************
     * rptGenerateRptHeaderColHeaderPickUpTimeCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderColHeaderPickUpTimeCell (ref Font font)
    {
      PdfPCell cell = rptGenerateRptHeaderColHeaderCell ("Pick", "Up", 1, 1, ref font, ref font);
      return cell;
    }
    
    /***************************************************************************
     * rptGenerateRptHeaderColHeaderDropOffTimeCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateRptHeaderColHeaderDropOffTimeCell (ref Font font)
    {
      PdfPCell cell = rptGenerateRptHeaderColHeaderCell ("Drop", "Off", 1, 1, ref font, ref font);            
      return cell;
    }
    
    /***************************************************************************
     * rptGenerateBodyCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateBodyCell (string line1, string line2, int rowSpan, int colSpan, ref Font font1, ref Font font2)
    {      
      List <Chunk> chunks = new List<Chunk>();      
      chunks.Add(new Chunk(line1,font1));
      chunks.Add(new Chunk(line2,font2));      
      PdfPCell cell = PDFCommon.generateCell(chunks, rowSpan, colSpan, 1, 1, true, Color.WHITE);
      return cell;            
    }
    
    /***************************************************************************
     * rptGenerateBodyCellNonActive */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateBodyCellNonActive (string line1, string line2, int rowSpan, int colSpan, ref Font font1, ref Font font2)
    {      
      List <Chunk> chunks = new List<Chunk>();      
      chunks.Add(new Chunk(line1,font1));
      chunks.Add(new Chunk(line2,font2));      
      PdfPCell cell = PDFCommon.generateCell(chunks, rowSpan, colSpan, 1, 1, true, PDFCommon.COLOR_LIGHTER_GRAY);
      return cell;            
    }

    /***************************************************************************
     * rptGenerateBodyPlaceCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateBodyPlaceCell (string name, string address, ref Font font1, ref Font font2)
    {
      return rptGenerateBodyCell (name, address , 1, 1, ref font1, ref font2); 
    }
    
    /***************************************************************************
     * rptGenerateBodyNameDobCell */
    /**
     *
     **************************************************************************/  

    protected static PdfPCell rptGenerateBodyNameDobCell (string name, string dob, ref Font font1, ref Font font2)
    {
      return rptGenerateBodyCell (name, dob , 1, 1, ref font1, ref font2); 
    }

    /***************************************************************************
     * rptGenerateBodyPickUpTimeCell */
    /**
     *
     **************************************************************************/  
    
    protected static PdfPCell rptGenerateBodyPickUpTimeCell(ref Font font, bool active)
    {
     PdfPCell cell = (active) ? rptGenerateBodyCell          ( @" ", @" ", 1, 1, ref font, ref font)
                              : rptGenerateBodyCellNonActive ( @" ", @" ", 1, 1, ref font, ref font);     
     return cell;     
    }
    
    /***************************************************************************
     * rptGenerateBodyDropOffTimeCell */
    /**
     *
     **************************************************************************/  
    
    protected static PdfPCell rptGenerateBodyDropOffTimeCell(ref Font font, bool active)
    {
      PdfPCell cell = (active) ? rptGenerateBodyCell          ( @" ", @" ", 1, 1, ref font, ref font)
                               : rptGenerateBodyCellNonActive ( @" ", @" ", 1, 1, ref font, ref font);                 
      return cell;     
    }
                
    /***************************************************************************
     * rptGenerateRouteSheetHeader */
    /**
     *
     **************************************************************************/  

    protected static List<PdfPCell> rptGenerateRouteSheetHeaderCells (  int rteCtr
                                                                      , int numCols
                                                                      , ref iTextSharp.text.Document                 doc
                                                                      , ref MemoryStream                             ms
                                                                      , ref PdfWriter                                writer
                                                                      , ref TransportationMgmtRouteSheet             route
                                                                      , ref List<TransportationMgmtRouteSheetMember> members
                                                                      , ref Font cellFont6 
                                                                      , ref Font cellFont6Bold   
                                                                      , ref Font cellFont8  
                                                                      , ref Font cellFont8Bold
                                                                      , ref Font cellFont10
                                                                      , ref Font cellFont10Bold )
    {
      
      Font titleFont = PDFCommon.generateCommonDocumentTitleFont();
      Font discFont  = PDFCommon.generateCommonDocumentDisclaimerFont();
   
      List<PdfPCell> headerCells = new List<PdfPCell>();      
                        
      string logoName = MBA.EmbeddedResources.CommonImages.IMAGE_NAME_LOGO_SPEDCARE;
      string title    = route.clientName + @" - Weekly SpEdCare Route Sheet";   
      string link     = @"www.spedcare.com";
      string disc1    = @"LEA medical transportation services must be provided in a litter van, wheelchair van/bus or other specialized form of transporation in order to be reimbursable under the LEA Billing Option Program.";
      string disc2    = @"LEA verifies that every student on this list has transportation authorized in their IEP/IFSP.  Practi-Cal will seek reimbursment, on behalf of " + route.clientName + " for all eligible students listed on this form.";
      string ins1     = @"For every student on this list, mark the Pick Up and Drop Off box with an 'X'.  If the student was absent, mark the box with an 'A'.";
      
      /* Generate table to hold report header row 1 content */
      
      PdfPTable rptHdrTbl1 = new PdfPTable(5);

      /* Row 1 */
      
      rptHdrTbl1.AddCell(rptGenerateRptHeaderBarcodeCell    (route.sheetCode  ,1 ,1 ,5));

      /* Row 2 */
      
      rptHdrTbl1.AddCell(rptGenerateRptHeaderLogoCell       (logoName          ,1 ,1));      
      rptHdrTbl1.AddCell(rptGenerateRptHeaderCellNoBorder   (title             ,1 ,4 ,ref titleFont));            
      
      /* Row 3 -- First cell spans 2 rows  */
      
      rptHdrTbl1.AddCell(rptGenerateRptHeaderLinkCell       (link              ,2 ,1 ,ref cellFont10));
      rptHdrTbl1.AddCell(rptGenerateRptHeaderCellNoBorder   (@"Route Name"     ,1 ,2 ,ref cellFont10Bold));
      rptHdrTbl1.AddCell(rptGenerateRptHeaderCellNoBorder   (@"Bus Number"     ,1 ,1 ,ref cellFont10Bold));
      rptHdrTbl1.AddCell(rptGenerateRptHeaderCellNoBorder   (@"Sheet Code"     ,1 ,1 ,ref cellFont10Bold));            
      
      /* Row 4 */
      
      rptHdrTbl1.AddCell(rptGenerateRptHeaderCellWithBorder (route.name        ,1 ,2, ref cellFont10));
      rptHdrTbl1.AddCell(rptGenerateRptHeaderCellWithBorder (route.busNumber   ,1 ,1, ref cellFont10));
      rptHdrTbl1.AddCell(rptGenerateRptHeaderCellWithBorder (route.sheetCode   ,1 ,1, ref cellFont10));
                 
      /* Row 5 */
      
      rptHdrTbl1.AddCell(rptGenerateRptHeaderCellNoBorder   (@"Origination"    ,1 ,2 ,ref cellFont10Bold));
      rptHdrTbl1.AddCell(rptGenerateRptHeaderCellNoBorder   (@"Termination"    ,1 ,2 ,ref cellFont10Bold));      
      rptHdrTbl1.AddCell(rptGenerateRptHeaderCellNoBorder   (@"Service Week"   ,1 ,1 ,ref cellFont10Bold));

      /* Row 6 */

      rptHdrTbl1.AddCell(rptGenerateRptHeaderPlaceCell      (route.origName          ,route.origAddress ,1 ,2 ,ref cellFont10 ,ref cellFont10));
      rptHdrTbl1.AddCell(rptGenerateRptHeaderPlaceCell      (route.destName          ,route.destAddress ,1 ,2 ,ref cellFont10 ,ref cellFont10));      
      rptHdrTbl1.AddCell(rptGenerateRptHeaderServiceWeekCell(route.weekOfServiceVal  ,route.startDate   ,1 ,1 ,ref cellFont10 ,ref cellFont10));
      
      /* Generate table to hold report header row 2 content */
      
      PdfPTable rptHdrTbl2 = new PdfPTable(2);
            
      
      /* Row 3 */
      
      rptHdrTbl2.AddCell(rptGenerateRptHeaderCellNoBorder (@"Driver's Name (Please Print)" ,1 ,1 ,ref cellFont10Bold));
      rptHdrTbl2.AddCell(rptGenerateRptHeaderCellNoBorder (@"Driver's Signature"           ,1 ,1 ,ref cellFont10Bold));      
      
      /* Row 4 */
      
      if (!String.IsNullOrWhiteSpace(route.busDriverName))
        rptHdrTbl2.AddCell(rptGenerateRptHeaderCellWithBorder (route.busDriverName,1 ,1, ref cellFont10));
      else
        rptHdrTbl2.AddCell(rptGenerateRptHeaderWriteInCell(1 ,1));
      
      rptHdrTbl2.AddCell(rptGenerateRptHeaderWriteInCell(1 ,1));
                        
      /* Row 5 */
      
      rptHdrTbl2.AddCell(rptGenerateRptHeaderCellNoBorder(disc1 ,1 ,2, ref discFont));
      rptHdrTbl2.AddCell(rptGenerateRptHeaderCellNoBorder(disc2 ,1 ,2, ref discFont));

      /* Add header row 1 */

      PdfPCell rptHdrCell1        = new PdfPCell(rptHdrTbl1);
      rptHdrCell1.Rowspan         = 1;
      rptHdrCell1.Colspan         = numCols;
      rptHdrCell1.Border          = Rectangle.NO_BORDER;
      rptHdrCell1.BackgroundColor = Color.WHITE;
      headerCells.Add(rptHdrCell1);                         
      
      /* Add header row 2 */

      PdfPCell rptHdrCell2        = new PdfPCell(rptHdrTbl2);
      rptHdrCell2.Rowspan         = 1;
      rptHdrCell2.Colspan         = numCols;
      rptHdrCell2.Border          = Rectangle.NO_BORDER;
      rptHdrCell2.BackgroundColor = Color.WHITE;
      rptHdrCell2.PaddingTop      = 4;
      rptHdrCell2.PaddingBottom   = 12;
      headerCells.Add(rptHdrCell2);                         
            
      /* Columns */
                  
      /* Row 1 */
      
      headerCells.Add(rptGenerateRptHeaderCellNoBorder        (ins1 ,1 ,4 ,ref cellFont8Bold));
      
      headerCells.Add(rptGenerateRptHeaderColHeaderDowDateCell("Mon", route.monDateStr, ref cellFont6Bold, ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderDowDateCell("Tue", route.tueDateStr, ref cellFont6Bold, ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderDowDateCell("Wed", route.wedDateStr, ref cellFont6Bold, ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderDowDateCell("Thu", route.thuDateStr, ref cellFont6Bold, ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderDowDateCell("Fri", route.friDateStr, ref cellFont6Bold, ref cellFont6Bold));
     
      headerCells.Add(rptGenerateRptHeaderColHeaderCell ("Student Last Name, First Name", "Date of Birth"       ,1, 1, ref cellFont6Bold, ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderCell ("Pick Up"                      , "Place"               ,1, 1, ref cellFont6Bold, ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderCell ("Drop Off"                     , "Place"               ,1, 1, ref cellFont6Bold, ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderCell ("Miles"                        , ""                    ,1, 1, ref cellFont6Bold, ref cellFont6Bold));
      
      
      headerCells.Add(rptGenerateRptHeaderColHeaderPickUpTimeCell  (ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderDropOffTimeCell (ref cellFont6Bold));
      
      headerCells.Add(rptGenerateRptHeaderColHeaderPickUpTimeCell  (ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderDropOffTimeCell (ref cellFont6Bold));

      headerCells.Add(rptGenerateRptHeaderColHeaderPickUpTimeCell  (ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderDropOffTimeCell (ref cellFont6Bold));
      
      headerCells.Add(rptGenerateRptHeaderColHeaderPickUpTimeCell  (ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderDropOffTimeCell (ref cellFont6Bold));
      
      headerCells.Add(rptGenerateRptHeaderColHeaderPickUpTimeCell  (ref cellFont6Bold));
      headerCells.Add(rptGenerateRptHeaderColHeaderDropOffTimeCell (ref cellFont6Bold));

      return headerCells;
    
    }
        
    /***************************************************************************
     * rptGenerateRouteSheetBody */
    /**
     *
     **************************************************************************/  

    protected static List<PdfPCell> rptGenerateRouteSheetBodyCells (  int  numCols                                                                    
                                                                    , int  numRowsPerPage
                                                                    , ref iTextSharp.text.Document                 doc
                                                                    , ref MemoryStream                             ms
                                                                    , ref PdfWriter                                writer
                                                                    , ref TransportationMgmtRouteSheet             route
                                                                    , ref List<TransportationMgmtRouteSheetMember> members                                                                    
                                                                    , ref Font cellFont6
                                                                    , ref Font cellFont6Bold
                                                                    , ref Font cellFont8
                                                                    , ref Font cellFont8Bold
                                                                    , ref Font cellFont10
                                                                    , ref Font cellFont10Bold )
    {
    
      List<PdfPCell> bodyCells = new List<PdfPCell>();
      
      int numExtraRows = 0;
      
      /* If no members generate a blank page */
           
      if (members.Count == 0)
      {
        numExtraRows = numRowsPerPage;
      }
      else
      {
        numExtraRows = 4;
      }
                                      
      /* Add extra rows */
      
      for (int i=1;i <= numExtraRows; i++)
          members.Add(new TransportationMgmtRouteSheetMember());      
      
      foreach(TransportationMgmtRouteSheetMember member in members)
      {
  
        bodyCells.Add(rptGenerateBodyNameDobCell (member.name             , member.patDOBStr   , ref cellFont8 , ref cellFont6));
        bodyCells.Add(rptGenerateBodyPlaceCell   (member.origName         , member.origAddress , ref cellFont8 , ref cellFont6));
        bodyCells.Add(rptGenerateBodyPlaceCell   (member.destName         , member.destAddress , ref cellFont8 , ref cellFont6));
        bodyCells.Add(rptGenerateBodyPlaceCell   (member.distanceMilesStr , " "                , ref cellFont8 , ref cellFont8));

        bodyCells.Add(rptGenerateBodyPickUpTimeCell  (ref cellFont10, member.scheduledForMon));
        bodyCells.Add(rptGenerateBodyDropOffTimeCell (ref cellFont10, member.scheduledForMon));

        bodyCells.Add(rptGenerateBodyPickUpTimeCell  (ref cellFont10, member.scheduledForTue));
        bodyCells.Add(rptGenerateBodyDropOffTimeCell (ref cellFont10, member.scheduledForTue));

        bodyCells.Add(rptGenerateBodyPickUpTimeCell  (ref cellFont10, member.scheduledForWed));
        bodyCells.Add(rptGenerateBodyDropOffTimeCell (ref cellFont10, member.scheduledForWed));

        bodyCells.Add(rptGenerateBodyPickUpTimeCell  (ref cellFont10, member.scheduledForThur));
        bodyCells.Add(rptGenerateBodyDropOffTimeCell (ref cellFont10, member.scheduledForThur));
        
        bodyCells.Add(rptGenerateBodyPickUpTimeCell  (ref cellFont10, member.scheduledForFri));
        bodyCells.Add(rptGenerateBodyDropOffTimeCell (ref cellFont10, member.scheduledForFri));

      }
 
      return bodyCells;

    }

    /***************************************************************************
     * rptGenerateRouteSheetFileContent */
    /**
     *
     **************************************************************************/  

    protected static void rptGenerateRouteSheetFileContent (  int rteCtr
                                                            , ref iTextSharp.text.Document     doc
                                                            , ref MemoryStream                 ms
                                                            , ref PdfWriter                    writer
                                                            , ref TransportationMgmtRouteSheet route
                                                            , ref List<TransportationMgmtRouteSheetMember> members )
    {
          
      int  numCols          = 14;
      int  numRowsPerPage   = 10;
      int  numHeaderRows    = 4;
      
      Font cellFont6        = FontFactory.GetFont(PDFCommon.BASE_FONT_TIMES_ROMAN,       6,   new Color(MBA.File.COLOR_BLACK));
      Font cellFont6Bold    = FontFactory.GetFont(PDFCommon.BASE_FONT_TIMES_ROMAN_BOLD,  6,   new Color(MBA.File.COLOR_BLACK));
      Font cellFont8        = FontFactory.GetFont(PDFCommon.BASE_FONT_TIMES_ROMAN,       8,   new Color(MBA.File.COLOR_BLACK));
      Font cellFont8Bold    = FontFactory.GetFont(PDFCommon.BASE_FONT_TIMES_ROMAN_BOLD,  8,   new Color(MBA.File.COLOR_BLACK));
      Font cellFont10       = FontFactory.GetFont(PDFCommon.BASE_FONT_TIMES_ROMAN,       10,  new Color(MBA.File.COLOR_BLACK));
      Font cellFont10Bold   = FontFactory.GetFont(PDFCommon.BASE_FONT_TIMES_ROMAN_BOLD,  10,  new Color(MBA.File.COLOR_BLACK));

 
      List<PdfPCell> headerCells = rptGenerateRouteSheetHeaderCells (   rteCtr
                                                                      , numCols 
                                                                      , ref doc
                                                                      , ref ms
                                                                      , ref writer
                                                                      , ref route
                                                                      , ref members
                                                                      , ref cellFont6
                                                                      , ref cellFont6Bold   
                                                                      , ref cellFont8  
                                                                      , ref cellFont8Bold
                                                                      , ref cellFont10
                                                                      , ref cellFont10Bold);
  
      List<PdfPCell> bodyCells = rptGenerateRouteSheetBodyCells (   numCols                                                                   
                                                                  , numRowsPerPage
                                                                  , ref doc
                                                                  , ref ms
                                                                  , ref writer
                                                                  , ref route
                                                                  , ref members
                                                                  , ref cellFont6
                                                                  , ref cellFont6Bold   
                                                                  , ref cellFont8  
                                                                  , ref cellFont8Bold
                                                                  , ref cellFont10
                                                                  , ref cellFont10Bold );    
           
      PdfPTable tbl = PDFCommon.generateTable (  numCols
                                               , numHeaderRows                                               
                                               , headerCells
                                               , bodyCells );
      
      
      tbl.TotalWidth  = 720f;  // 10in (1in = 72 pts)
      tbl.LockedWidth = true;

      float[] widths = new float[] { 100f, 170f, 170f, 30f ,25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f};
      
      tbl.SetWidths(widths);
      doc.Add(tbl);
      
    }
    
    /**************************************************************************
     * rptGenerateRouteSheetsFile */
    /**
     *
     **************************************************************************/  

    protected static ReturnFileBytes rptGenerateRouteSheetsFile  (   SqlConnection connSpedmon
                                                                   , DetailsLog    log
                                                                   , UserInfo      uInfo
                                                                   , string        clientID
                                                                   , string        transMgmtID
                                                                   , string        sheetBatchID )
    {                        
            
                  
      RenderPdfCallBack cb = new RenderPdfCallBack( delegate (   ref iTextSharp.text.Document     doc
                                                               , ref MemoryStream                 ms
                                                               , ref PdfWriter                    writer
                                                               , ref String                       title
                                                               , ref String                       author
                                                               , ref String                       batch
                                                               , ref String                       filename
                                                              )
      {
    
        bool   multiRoute   = false;
        int    rteCtr       = 0;        
        title               = "";
        string dateparts    = "";
        
        List <TransportationMgmtRouteSheet> routes = TransportationMgmtRouteSheets.loadAllRecords (  connSpedmon
                                                                                                   , log
                                                                                                   , uInfo
                                                                                                   , clientID
                                                                                                   , transMgmtID
                                                                                                   , sheetBatchID
                                                                                                   , ""
                                                                                                   , "" );  
      
        multiRoute = false;        
        rteCtr     = 0;
        
        if (routes.Count == 0) {
          multiRoute = false;
          title      = "No Route Sheets";
          rteCtr     = 0;         
        }
        else if (routes.Count == 1) {
          multiRoute = false;
          title      = "Route Sheet";
          rteCtr     = 1;
        }
        else {
          multiRoute = true;
          rteCtr     = 1;
          title      = @"Route Sheets";
        }
      
        foreach(TransportationMgmtRouteSheet route in routes)
        {
                          
          if (multiRoute == true)
          {
            if (rteCtr > 1) doc.NewPage();
            Chapter chapter = PDFCommon.generateHiddenChapter(route.name,rteCtr,Color.WHITE);
            doc.Add(chapter);
          }
          else
          {
            title = route.name;
          }          

          dateparts = Util.startAndEndDateToDateRangeFileNamePart(route.monDateVal,route.friDateVal);
          
          TransportationMgmtRouteSheet             rte     = route;                                
          List<TransportationMgmtRouteSheetMember> members = TransportationMgmtRouteSheetMembers.loadAllRecords (   connSpedmon
                                                                                                                  , log
                                                                                                                  , uInfo
                                                                                                                  , clientID
                                                                                                                  , transMgmtID
                                                                                                                  , ""
                                                                                                                  , sheetBatchID
                                                                                                                  , rte.sheetCode
                                                                                                                  , rte.routeID.ToString()
                                                                                                                  , rte.sheetID.ToString());
        
        
         
          rptGenerateRouteSheetFileContent (  rteCtr
                                            , ref doc
                                            , ref ms
                                            , ref writer
                                            , ref rte
                                            , ref members ); 
          rteCtr++;
        }
        
        filename = author + "-" + title + "-" + dateparts + "-" + batch;

      });
      
      Client c  = Clients.load (connSpedmon, log, uInfo, clientID);      
      
      string _ttle     = @"";
      string _author   = c.name;
      string _batch    = sheetBatchID;
      string _filename = @"";
      
      
      PageEventHelperPageNumberAndCreateDate peh = new PageEventHelperPageNumberAndCreateDate();
      
      return PDFCommon.generateDocument (   _ttle
                                          , _author
                                          , _batch
                                          , _filename
                                          , PDFCommon.ORIENTATION_LANDSCAPE
                                          , 1f
                                          , 1f
                                          , 15f
                                          , 40f
                                          , peh
                                          , cb);

      
    }

    /***************************************************************************
     * generateOutgoingRouteSheetFile */
    /**
     *
     **************************************************************************/  
    
    public static ReturnFileBytes generateOutgoingRouteSheetsFile (  SqlConnection connSpedmon
                                                                   , DetailsLog    log
                                                                   , UserInfo      uInfo
                                                                   , string        clientID
                                                                   , string        transMgmtID 
                                                                   , string        routeID
                                                                   , string        startDate )
    {
    
               
      ReturnFileBytes rfb = new ReturnFileBytes();
      
      if (Util.IsNullOrEmpty(clientID))    return rfb;
      if (Util.IsNullOrEmpty(transMgmtID)) return rfb;
      if (Util.IsNullOrEmpty(startDate))   startDate = DateTime.Now.ToShortDateString();
      
	    /* Refresh all trip calculations in bulk if neccessary */
	    
	    TransportationMgmtTripCalculations.refreshAllTripCalcsWithClientID (connSpedmon,log,uInfo,clientID);
	      
	    ReturnSaveRecord rsr = TransportationMgmtRouteSheets.save (   connSpedmon
	                                                               , log
	                                                               , uInfo
	                                                               , clientID
	                                                               , transMgmtID
	                                                               , routeID
	                                                               , startDate
	                                                               , @""
	                                                               , "N"
	                                                               , Constants.SAVE_TYPE_NEW.ToString()
	                                                               , null);
	    
	    string sheetBatchID = rsr.recordID.ToString();
	    
	    rfb = TransportationMgmtRouteSheetProcessing.rptGenerateRouteSheetsFile (   connSpedmon
	                                                                              , log
	                                                                              , uInfo
	                                                                              , clientID
	                                                                              , transMgmtID
 	                                                                              , sheetBatchID	                                                                                     
	                                                                            );
	   
	    return rfb;
	   
    }
    
    /***************************************************************************
     * loadProcessingData  */
    /**
     *
     **************************************************************************/  

    public static ReturnTransportationMgmtProcessingData loadProcessingData (  SqlConnection connSpedmon
                                                                              , DetailsLog    log
                                                                              , UserInfo      uInfo
                                                                              , string        clientID)
    {
      ReturnTransportationMgmtProcessingData rd = new ReturnTransportationMgmtProcessingData(); 
      rd.mgmtRec  = TransportationMgmtRecords.loadCurrent(connSpedmon, log, uInfo, clientID );      
      return rd;
    }
    
    /***************************************************************************
     * loadIncomingRouteSheet  */
    /**
     *
     **************************************************************************/  
    
    public static ReturnRouteSheetData loadIncomingRouteSheetData (  SqlConnection connSpedmon
                                                                   , DetailsLog    log
                                                                   , UserInfo      uInfo
                                                                   , string        clientID
                                                                   , string        sheetCode )
    {      
      ReturnRouteSheetData rd = new ReturnRouteSheetData(); 
      rd.mgmtRec           = TransportationMgmtRecords.loadCurrent(connSpedmon, log, uInfo, clientID );      
      string transMgmtID   = rd.mgmtRec.id.ToString();
      rd.routeSheet        = TransportationMgmtRouteSheets.load(connSpedmon,log,uInfo,clientID,transMgmtID,sheetCode);
      rd.routeSheetMembers = TransportationMgmtRouteSheetMembers.loadAllRecords(connSpedmon, log, uInfo, clientID, transMgmtID, null, null, sheetCode, null, null);      
      return rd;
    }
    
    /***************************************************************************
     * saveIncomingRouteSheetTripDetails */
    /**
     *
     **************************************************************************/  
        
    public static ReturnSaveRecord saveIncomingRouteSheetTripDetails (  SqlConnection connSpedmon
                                                                      , DetailsLog    log
                                                                      , UserInfo      uInfo    
                                                                      , string        clientID
                                                                      , string        reference 
                                                                      , string        pracID
                                                                      , string        sheetCode
                                                                      , string        details
                                                                      , string        validateRec ) 
    {
        
      
      ReturnSaveRecord rd = new ReturnSaveRecord();
      
      /*----------------------------
       * Batch save is for new records
       * only so we provide the required
       * values for save here
       *----------------------------*/
      
      string editDelReason  = "";
      string saveType       = Constants.SAVE_TYPE_NEW.ToString();
      string recID          = "";

      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      string      vReference      = Validate.reqSvcRecReference (uInfo, reference);
      int         vClientID       = Validate.reqClientID        (uInfo, clientID);
      int         vPracID         = Validate.reqPracID          (uInfo, pracID);  
      string      vSheetCode      = Validate.reqString          (sheetCode, @"Invalid sheet code"); 
            
      ReturnRouteSheetData rsd = loadIncomingRouteSheetData (connSpedmon, log, uInfo,clientID,sheetCode);
      
      /*----------------------------
       * Create additional validation
       * steps for the following 
       * reqObject validation check.
       *----------------------------*/

      AdditionalValidation av = delegate(Object o){
        
        /*-------------------------------
         * Cast o to RouteSheetTripDetails
         *-------------------------------*/ 

        RouteSheetTripDetails vDetails = (RouteSheetTripDetails) o;

        /*-------------------------------
         * Perform range checks on 
         * dates and minutes and check
         * patient absent flag
         *-------------------------------*/ 
        
        int  rowNum = 1;

        foreach (RouteSheetTripDetail vDetail in vDetails.details)
        {                
          bool? vBillMon = Util.evaluateFlag (vDetail.billMon, true);
          bool? vBillTue = Util.evaluateFlag (vDetail.billTue, true);
          bool? vBillWed = Util.evaluateFlag (vDetail.billWed, true);
          bool? vBillThu = Util.evaluateFlag (vDetail.billThu, true);
          bool? vBillFri = Util.evaluateFlag (vDetail.billFri, true);
                                        
          rowNum++;
        }
      };      
           
      /*----------------------------
       * Parse and convert details
       * string (JSON) to object 
       * 
       * Note: The parsing will
       * peform datatype validation
       *----------------------------*/

      RouteSheetTripDetails vTripDetails = (RouteSheetTripDetails) Validate.reqObject (details, Messages.INVALID_SVC_REC_DETAIL , "Spedmon", "Spedmon.RouteSheetTripDetails", av);
                       
      List<SqlParameter> parms = new List<SqlParameter>();
           
      parms.Add(Database.SqlParm("@reference",       SqlDbType.VarChar,  vReference,                      ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@clientID",        SqlDbType.BigInt,   vClientID,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@transMgmtID",     SqlDbType.BigInt,   rsd.mgmtRec.id,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",          SqlDbType.BigInt,   vPracID,                         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@sheetCode",       SqlDbType.VarChar,  vSheetCode,                      ParameterDirection.Input, 512)); 
      parms.Add(Database.SqlParm("@MsgInvCombo",     SqlDbType.VarChar,  Messages.INVALID_PPN_COMBO,      ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMinReq",       SqlDbType.VarChar,  Messages.MIN_REQ,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMinDef",       SqlDbType.VarChar,  Messages.MIN_DEF,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMilReq",       SqlDbType.VarChar,  Messages.MIL_REQ,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatElg",       SqlDbType.VarChar,  Messages.PAT_ELG,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar,  Messages.PAT_DOB_GTE_DOS,        ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatAbsent",    SqlDbType.VarChar,  Messages.PAT_ABSENT_NO_CLAIM,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgFutureDOS",    SqlDbType.VarChar,  Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

      parms.Add(Database.SqlParmDataTable <RouteSheetTripDetail> ("@tripdetails", vTripDetails.details, "RouteSheetTripDetails"));
      
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESS_SAVE_INCOMING_TRIP_DETAILS", @"A transportation service has already been entered", ref parms,
        delegate()
        {
          // Note: No additional validation steps needed
        });      
      
    }
    
   
  }
}