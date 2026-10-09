using System;
using System.IO;
using System.Collections.Generic;
using NPOI.SS.UserModel;
using NPOI.SS.Util;
using NPOI.XSSF.UserModel;
using MBA.X12.XDOC;

namespace MBA.X12.X835
{
  /// <summary>
  /// Creates report files from X12 data
  /// </summary>
  /// <remarks>
  /// TODO: Refactor when MBA libraries are ported.
  /// This is a temporary solution until we can port the rest of the MBA libraries to .NET 4
  /// or higher.  It would be better to use some of the data export tools we have in the MBA libraries.
  /// </remarks>

  public class CreateReportFile : ProcessFileBase
  {

		/// <summary>
		/// Converts decimal to double
		/// </summary>
		/// <param name="value"></param>
		/// <returns></returns>
		
    private Double DecimalToDouble (Decimal value)
		{
			Double result;
			Double.TryParse(value.ToString(), out result);
			return result;
    }
    
    private ICellStyle CreateDateStyle (ref IWorkbook workbook)
    {
      ICellStyle style = workbook.CreateCellStyle();
      style.DataFormat = 14;
      return style;
    }
    
    private ICellStyle CreateMoneyStyle (ref IWorkbook workbook)
    {
      ICellStyle style = workbook.CreateCellStyle();
      style.DataFormat = 8;
      return style;
    }
      
    private ICellStyle CreateQuantityStyle (ref IWorkbook workbook)
    {
      ICellStyle style = workbook.CreateCellStyle();
      style.DataFormat = 2;
      return style;
    }
    
    private ICellStyle CreateHeaderStyle (ref IWorkbook workbook)
    {
      ICellStyle style = workbook.CreateCellStyle();
      style.DataFormat = 0;
      style.WrapText = true;      
      return style;
    }

    private Dictionary<String, ICellStyle> CreateStylesDict (ref IWorkbook workbook)
    {
      var dict = new Dictionary<String,ICellStyle>();
      dict.Add(@"date",     CreateDateStyle     (ref workbook));
      dict.Add(@"header",   CreateHeaderStyle   (ref workbook));
      dict.Add(@"money",    CreateMoneyStyle    (ref workbook));
      dict.Add(@"quantity", CreateQuantityStyle (ref workbook));
      return dict;
    }

    private ICell CreateEmptyCell ( ref Dictionary<String, ICellStyle> styles 
                                  , ref ISheet sheet
                                  , ref IRow   row
                                  , int colIdx)
    {
      ICell cell = row.CreateCell(colIdx);
      return cell;
    }
    
    private ICell CreateDateCell (  ref Dictionary<String, ICellStyle> styles
                                 , ref ISheet sheet
                                 , ref IRow   row
                                 , int colIdx
                                 , DateTime? value)
    {
      if (value.HasValue) 
      {
        ICell cell     = row.CreateCell(colIdx);
        cell.CellStyle = styles[@"date"];
        cell.SetCellValue(value.Value);
        return cell;
      }
      else return CreateEmptyCell(ref styles, ref sheet, ref row, colIdx);
    }

    private ICell CreateMoneyCell (  ref Dictionary<String, ICellStyle> styles
                                   , ref ISheet sheet
                                   , ref IRow   row
                                   , int colIdx
                                   , Decimal? value)
    {
      if (value.HasValue) 
      {
        Double dblVal;
        if(Double.TryParse(value.Value.ToString(), out dblVal)) 
        {
          ICell cell     = row.CreateCell(colIdx, CellType.Numeric);      
          cell.CellStyle = styles[@"money"];
          cell.SetCellValue(dblVal);
          return cell;
        }
        else return CreateEmptyCell(ref styles, ref sheet, ref row, colIdx);       
      }
      else return CreateEmptyCell(ref styles, ref sheet, ref row, colIdx);
    }


    private ICell CreateNumberCell  (  ref Dictionary<String, ICellStyle> styles
                                       , ref ISheet sheet
                                       , ref IRow   row
                                       , int        colIdx
                                       , Decimal?   value)
    {
      if (value.HasValue) 
      {
        Double dblVal;
        if(Double.TryParse(value.Value.ToString(), out dblVal)) 
        {
          ICell cell     = row.CreateCell(colIdx, CellType.Numeric);      
          cell.SetCellValue(dblVal);
          return cell;
        }
        else return CreateEmptyCell(ref styles, ref sheet, ref row, colIdx);       
      }
      else return CreateEmptyCell(ref styles, ref sheet, ref row, colIdx);      
    }
    
    private ICell CreateQuantityCell (  ref Dictionary<String, ICellStyle> styles
                                       , ref ISheet sheet
                                       , ref IRow   row
                                       , int        colIdx
                                       , Decimal?   value)
    {
      if (value.HasValue) 
      {
        Double dblVal;
        if(Double.TryParse(value.Value.ToString(), out dblVal)) 
        {
          ICell cell     = row.CreateCell(colIdx, CellType.Numeric);      
          cell.CellStyle = styles[@"quantity"];
          cell.SetCellValue(dblVal);
          return cell;
        }
        else return CreateEmptyCell(ref styles, ref sheet, ref row, colIdx);       
      }
      else return CreateEmptyCell(ref styles, ref sheet, ref row, colIdx);
    }

    private ICell CreateHeaderCell (    ref Dictionary<String, ICellStyle> styles
                                       , ref ISheet sheet
                                       , ref IRow   row
                                       , int        colIdx
                                       , String     value)
    {
      ICell cell     = row.CreateCell(colIdx, CellType.String);      
      cell.CellStyle = styles[@"header"];
      cell.SetCellValue(value);        
      return cell;      
    }

    private IRow CreateHeaderRow (ref ISheet sheet)
    {     
      return CreateHeaderRow(ref sheet,5);
    }
    
    private IRow CreateHeaderRow (ref ISheet sheet, float heightMultiplier )
    {     
      IRow rowHeader = sheet.CreateRow(0);        
      rowHeader.HeightInPoints = (sheet.DefaultRowHeightInPoints * heightMultiplier);
      return rowHeader;
    }
            
    private int CalcColPadding (int prevWidthInt, Decimal padFactor)
    {
      var prevWidthDec = (Decimal) prevWidthInt;
      var newWidthDec  = (prevWidthDec + (prevWidthDec * padFactor));
      var newWidthInt  = (int) Math.Floor(newWidthDec);
      return newWidthInt;
    }
       
    private void AutoSizeCol (ref IWorkbook wb, ref ISheet sheet, ref IRow hdrRow, int colNum)
    {                
      ICell cell = hdrRow.GetCell(colNum);
      sheet.AutoSizeColumn (colNum);
      int     prevWidthInt = sheet.GetColumnWidth(colNum);     
      int     newWidthInt  = CalcColPadding(prevWidthInt,.25m);
      sheet.SetColumnWidth(colNum,newWidthInt);
    }
    
    private void PrepSheetForHumanUse (ref IWorkbook wb, ref ISheet sheet, ref IRow hdrRow, int endRow, int endCol)
    {                                  
      sheet.CreateFreezePane(0,1);
      sheet.SetAutoFilter ( new CellRangeAddress (0, endRow, 0, endCol));
      for (int col = 0; col <= endCol; col++) AutoSizeCol(ref wb, ref sheet, ref hdrRow, col);
    }
    
    
    public bool ParsedFileTransactionSetToExcel (   ref List<TransactionSetSummary> txSetSummaries
                                                  , ref List<TransactionSetDetail> txSetDetails 
                                                  , bool includeDetails
                                                  , String XLSXFileOut)
    {
      bool retState = false;
      
      RaiseProcessingStatusEvent("Creating Data Report - Starting");
  
      try
      {
        IWorkbook   wb                 = new XSSFWorkbook();

        ISheet      sheetTotals        = wb.CreateSheet(@"Provider Level Summary");
        ISheet      sheetAdjust        = wb.CreateSheet(@"Provider Level Adjustments");
        
        ISheet      sheetDetails       = null;
        ISheet      sheetHcRemarkCodes = null;
        ISheet      sheetClaimAdjust   = null;
        ISheet      sheetServiceAdjust = null;

        if (includeDetails)
        {
          sheetDetails       = wb.CreateSheet (@"Claim and Service Level Details");
          sheetHcRemarkCodes = wb.CreateSheet (@"Health Care Remark Codes");
          sheetClaimAdjust   = wb.CreateSheet (@"Claim Level Adjustments");
          sheetServiceAdjust = wb.CreateSheet (@"Service Level Adjustments");
        }
        
        var styles = CreateStylesDict (ref wb);
    
        /* Create header row for totals sheet */
        
        IRow totsRowHeader = CreateHeaderRow(ref sheetTotals, 4);
          
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,0 , "Provider Name");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,1 , "Provider NPI");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,2 , "Warrant\nNumber");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,3 , "Warrant\nDate");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,4 , "Warrant\nAmount");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,5 , "Total Claims Paid\nAmount\nAll");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,6 , "Total Claims Paid\nAmount\nUs");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,7 , "Total Claims Paid\nAmount\nOther Vendors");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,8 , "Total Adjustments\nAmount\nAll");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,9 , "Processing Fee\nPercentage\nPer Our Claim");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,10, "Subtotal Adjustments\nAmount\nProcessing Fees");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,11, "Subtotal Adjustments\nAmount\nOther");
        CreateHeaderCell (ref styles, ref sheetTotals, ref totsRowHeader,12, "Transaction\nControl\nNumber");
        
        /* Create header row for provider level adjustements sheet */
        
        IRow adjsRowHeader = CreateHeaderRow(ref sheetAdjust,4);

        adjsRowHeader.CreateCell (0,  CellType.String).SetCellValue (@"Provider Name");
        adjsRowHeader.CreateCell (1,  CellType.String).SetCellValue (@"Provider NPI");
        adjsRowHeader.CreateCell (2,  CellType.String).SetCellValue (@"Reason Code"); 
        adjsRowHeader.CreateCell (3,  CellType.String).SetCellValue (@"Reference");
        adjsRowHeader.CreateCell (4,  CellType.String).SetCellValue (@"Amount");

        IRow detsRowHeader     = null;
        IRow hcRmksRowHeader   = null;
        IRow clmAdjsRowHeader  = null;
        IRow svcAdjsRowHeader  = null;
        
        if (includeDetails)
        {
        
          /* Create header row for details sheet */
        
          detsRowHeader = CreateHeaderRow (ref sheetDetails, 4);
          
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,0 , "Provider Name");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,1 , "Provider NPI");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,2 , "Claim\nControl\nNumber");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,3 , "Our\nClaim\nID");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,4 , "Claim\nStatus");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,5 , "Claim\nAmount\nSubmitted");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,6 , "Claim\nAmount\nPaid");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,7 , "Patient\nLast\nName");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,8 , "Patient\nFirst\nName");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,9 , "Patient\nBIC");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,10, "Procedure");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,11, "Service\nAmount\nSubmitted");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,12, "Service\nAmount\nPaid");
          CreateHeaderCell (ref styles, ref sheetDetails, ref detsRowHeader,13, "Service\nUnits\nPaid");

          /* Create header row for remark codes (RARC) */
          
          hcRmksRowHeader = CreateHeaderRow(ref sheetHcRemarkCodes, 4);

          CreateHeaderCell (ref styles, ref sheetHcRemarkCodes, ref hcRmksRowHeader ,0 , "Provider Name");
          CreateHeaderCell (ref styles, ref sheetHcRemarkCodes, ref hcRmksRowHeader ,1 , "Provider NPI");
          CreateHeaderCell (ref styles, ref sheetHcRemarkCodes, ref hcRmksRowHeader ,2 , "Claim\nControl\nNumber");
          CreateHeaderCell (ref styles, ref sheetHcRemarkCodes, ref hcRmksRowHeader ,3 , "Our\nClaim\nID");
          CreateHeaderCell (ref styles, ref sheetHcRemarkCodes, ref hcRmksRowHeader ,4 , "Code\nList\nQualifier");
          CreateHeaderCell (ref styles, ref sheetHcRemarkCodes, ref hcRmksRowHeader ,5 , "Remark\nCode");
                    
          /* Create header row for claim level adjusts sheet */
        
          clmAdjsRowHeader = CreateHeaderRow (ref sheetClaimAdjust, 4);
          
          CreateHeaderCell (ref styles, ref sheetClaimAdjust, ref clmAdjsRowHeader,0 , "Provider Name");
          CreateHeaderCell (ref styles, ref sheetClaimAdjust, ref clmAdjsRowHeader,1 , "Provider NPI");
          CreateHeaderCell (ref styles, ref sheetClaimAdjust, ref clmAdjsRowHeader,2 , "Claim\nControl\nNumber");
          CreateHeaderCell (ref styles, ref sheetClaimAdjust, ref clmAdjsRowHeader,3 , "Our\nClaim\nID");
          CreateHeaderCell (ref styles, ref sheetClaimAdjust, ref clmAdjsRowHeader,4 , "Group\nCode");
          CreateHeaderCell (ref styles, ref sheetClaimAdjust, ref clmAdjsRowHeader,5 , "Reason\nCode");        
          CreateHeaderCell (ref styles, ref sheetClaimAdjust, ref clmAdjsRowHeader,6 , "Quantity");

         /* Create header row for service level adjusts sheet */
        
          svcAdjsRowHeader = CreateHeaderRow (ref sheetServiceAdjust, 4);
          
          CreateHeaderCell (ref styles, ref sheetServiceAdjust, ref svcAdjsRowHeader,0 , "Provider Name");
          CreateHeaderCell (ref styles, ref sheetServiceAdjust, ref svcAdjsRowHeader,1 , "Provider NPI");
          CreateHeaderCell (ref styles, ref sheetServiceAdjust, ref svcAdjsRowHeader,2 , "Claim\nControl\nNumber");
          CreateHeaderCell (ref styles, ref sheetServiceAdjust, ref svcAdjsRowHeader,3 , "Our\nClaim\nID");
          CreateHeaderCell (ref styles, ref sheetServiceAdjust, ref svcAdjsRowHeader,4 , "Group\nCode");
          CreateHeaderCell (ref styles, ref sheetServiceAdjust, ref svcAdjsRowHeader,5 , "Reason\nCode");        
          CreateHeaderCell (ref styles, ref sheetServiceAdjust, ref svcAdjsRowHeader,6 , "Quantity");
        }
        
        int totsRowNum    = 1;
        int adjsRowNum    = 1;
        int detsRowNum    = 1;
        int hcRmksRowNum  = 1;
        int clmAdjsRowNum = 1;
        int svcAdjsRowNum = 1;
        
        /* Create summary level rows */
        
        RaiseProcessingStatusEvent(@"Generating summary level rows");
        
        foreach (var txSetSummary in txSetSummaries)
        {
          
          RaiseProcessingStatusEvent(txSetSummary.ProviderName);

          IRow totsRowDetail = sheetTotals.CreateRow(totsRowNum);

          totsRowDetail.CreateCell(0, CellType.String).SetCellValue(txSetSummary.ProviderName);
          totsRowDetail.CreateCell(1, CellType.String).SetCellValue(txSetSummary.ProviderNPI);
          totsRowDetail.CreateCell(2, CellType.String).SetCellValue(txSetSummary.WarrantNumber);
          
          CreateDateCell   (ref styles, ref sheetTotals, ref totsRowDetail, 3,  txSetSummary.WarrantDate);
          CreateMoneyCell  (ref styles, ref sheetTotals, ref totsRowDetail, 4,  txSetSummary.WarrantAmount);
          CreateMoneyCell  (ref styles, ref sheetTotals, ref totsRowDetail, 5,  txSetSummary.TotalClaimsPaidAmountAll);
          CreateMoneyCell  (ref styles, ref sheetTotals, ref totsRowDetail, 6,  txSetSummary.TotalClaimsPaidAmountUs);
          CreateMoneyCell  (ref styles, ref sheetTotals, ref totsRowDetail, 7,  txSetSummary.TotalClaimsPaidAmountOther);

          CreateMoneyCell  (ref styles, ref sheetTotals, ref totsRowDetail, 8,  txSetSummary.TotalAdjustmentsAmount);
          CreateNumberCell (ref styles, ref sheetTotals, ref totsRowDetail, 9,  txSetSummary.ProcessingFeePercentagePerClaimFromUs);
          CreateMoneyCell  (ref styles, ref sheetTotals, ref totsRowDetail, 10, txSetSummary.TotalAdjustmentsAmountProcessingFees);
          CreateMoneyCell  (ref styles, ref sheetTotals, ref totsRowDetail, 11, txSetSummary.TotalAdjustmentsAmountNonProcessingFees);

          totsRowDetail.CreateCell(12, CellType.String).SetCellValue(txSetSummary.TSControlNumber);          
          
          foreach (var adj in txSetSummary.ProviderLevelAdjustments)
          {
            IRow adjsRowDetail = sheetAdjust.CreateRow(adjsRowNum);                  
            adjsRowDetail.CreateCell(0, CellType.String).SetCellValue(txSetSummary.ProviderName);
            adjsRowDetail.CreateCell(1, CellType.String).SetCellValue(txSetSummary.ProviderNPI);
            adjsRowDetail.CreateCell(2, CellType.String).SetCellValue(adj.Identifier.ReasonCode);
            adjsRowDetail.CreateCell(3, CellType.String).SetCellValue(adj.Identifier.Reference);            
            CreateMoneyCell (ref styles, ref sheetAdjust, ref adjsRowDetail, 4, adj.Amount);            
            adjsRowNum++;
          }          
          totsRowNum++;       
        }
        
        /* Create detail level rows */
        
        if (includeDetails)
        {
          RaiseProcessingStatusEvent(@"Generating detail level rows");
        
          foreach (var txSetDetail in txSetDetails)
          {

            RaiseProcessingStatusEvent(String.Format(@"{0} {1}",txSetDetail.ProviderName,txSetDetail.IDX));
          
            IRow detsRowDetail = sheetDetails.CreateRow(detsRowNum);

            detsRowDetail.CreateCell(0, CellType.String).SetCellValue(txSetDetail.ProviderName);
            detsRowDetail.CreateCell(1, CellType.String).SetCellValue(txSetDetail.ProviderNPI);
            detsRowDetail.CreateCell(2, CellType.String).SetCellValue(txSetDetail.ClaimControlNumber);
            detsRowDetail.CreateCell(3, CellType.String).SetCellValue(txSetDetail.ClaimIDRef);
            detsRowDetail.CreateCell(4, CellType.String).SetCellValue(txSetDetail.ClaimStatusCode);
            CreateMoneyCell  (ref styles, ref sheetDetails, ref detsRowDetail, 5,  txSetDetail.ClaimAmountSubmitted);
            CreateMoneyCell  (ref styles, ref sheetDetails, ref detsRowDetail, 6,  txSetDetail.ClaimAmountPaid);
            detsRowDetail.CreateCell(7, CellType.String).SetCellValue(txSetDetail.PatientLastName);
            detsRowDetail.CreateCell(8, CellType.String).SetCellValue(txSetDetail.PatientFirstName);
            detsRowDetail.CreateCell(9, CellType.String).SetCellValue(txSetDetail.PatientBIC);
            detsRowDetail.CreateCell(10, CellType.String).SetCellValue(txSetDetail.ProcedureSubElements);
            CreateMoneyCell  (ref styles, ref sheetDetails, ref detsRowDetail, 11,  txSetDetail.SvcAmountSubmitted);
            CreateMoneyCell  (ref styles, ref sheetDetails, ref detsRowDetail, 12,  txSetDetail.SvcAmountPaid);
            CreateQuantityCell  (ref styles, ref sheetDetails, ref detsRowDetail, 13,  txSetDetail.SvcUnitsPaid);
                             
            /* RARC Codes */
            
            foreach (var rc in txSetDetail.HealthCareRemarkCodes)
            {
              IRow hcRmksRowDetail = sheetHcRemarkCodes.CreateRow(hcRmksRowNum);                  
              hcRmksRowDetail.CreateCell(0, CellType.String).SetCellValue(txSetDetail.ProviderName);
              hcRmksRowDetail.CreateCell(1, CellType.String).SetCellValue(txSetDetail.ProviderNPI);
              hcRmksRowDetail.CreateCell(2, CellType.String).SetCellValue(txSetDetail.ClaimControlNumber);
              hcRmksRowDetail.CreateCell(3, CellType.String).SetCellValue(txSetDetail.ClaimIDRef);            
              hcRmksRowDetail.CreateCell(4, CellType.String).SetCellValue(rc.CodeListQualifierCode);            
              hcRmksRowDetail.CreateCell(5, CellType.String).SetCellValue(rc.IndustryCode);
              hcRmksRowNum++;
            }
            
            /* Claim level adjustments */
            
            foreach (var adj in txSetDetail.ClaimLevelAdjustments)
            {
              IRow adjsRowDetail = sheetClaimAdjust.CreateRow(clmAdjsRowNum);                  
              adjsRowDetail.CreateCell(0, CellType.String).SetCellValue(txSetDetail.ProviderName);
              adjsRowDetail.CreateCell(1, CellType.String).SetCellValue(txSetDetail.ProviderNPI);
              adjsRowDetail.CreateCell(2, CellType.String).SetCellValue(txSetDetail.ClaimControlNumber);
              adjsRowDetail.CreateCell(3, CellType.String).SetCellValue(txSetDetail.ClaimIDRef);            
              adjsRowDetail.CreateCell(4, CellType.String).SetCellValue(adj.GroupCode);
              adjsRowDetail.CreateCell(5, CellType.String).SetCellValue(adj.ReasonCode);
              CreateQuantityCell  (ref styles, ref sheetClaimAdjust, ref adjsRowDetail, 6, adj.Quantity);
              clmAdjsRowNum++;
            }          

            /* Service level adjustments */
          
            foreach (var adj in txSetDetail.ServiceLevelAdjustments)
            {
              IRow adjsRowDetail = sheetServiceAdjust.CreateRow(svcAdjsRowNum);                  
              adjsRowDetail.CreateCell(0, CellType.String).SetCellValue(txSetDetail.ProviderName);
              adjsRowDetail.CreateCell(1, CellType.String).SetCellValue(txSetDetail.ProviderNPI);
              adjsRowDetail.CreateCell(2, CellType.String).SetCellValue(txSetDetail.ClaimControlNumber);
              adjsRowDetail.CreateCell(3, CellType.String).SetCellValue(txSetDetail.ClaimIDRef);    
              adjsRowDetail.CreateCell(4, CellType.String).SetCellValue(adj.GroupCode);
              adjsRowDetail.CreateCell(5, CellType.String).SetCellValue(adj.ReasonCode);
              CreateQuantityCell  (ref styles, ref sheetServiceAdjust, ref adjsRowDetail, 6, adj.Quantity);
              svcAdjsRowNum++;
            }          
            detsRowNum++;
          }
        }
        
        RaiseProcessingStatusEvent(@"Formatting sheets");

        PrepSheetForHumanUse(ref wb, ref sheetTotals, ref totsRowHeader, totsRowNum, 11);
        PrepSheetForHumanUse(ref wb, ref sheetAdjust, ref adjsRowHeader, adjsRowNum, 4);

        if (includeDetails)
        {
          PrepSheetForHumanUse (ref wb, ref sheetDetails,       ref detsRowHeader,    detsRowNum,    13);
          PrepSheetForHumanUse (ref wb, ref sheetHcRemarkCodes, ref hcRmksRowHeader,  hcRmksRowNum,  5);                        
          PrepSheetForHumanUse (ref wb, ref sheetClaimAdjust,   ref clmAdjsRowHeader, clmAdjsRowNum, 6);
          PrepSheetForHumanUse (ref wb, ref sheetServiceAdjust, ref svcAdjsRowHeader, svcAdjsRowNum, 6);
        }

        RaiseProcessingStatusEvent(@"Writing file");
        
        using (var fsOut = new FileStream(XLSXFileOut, FileMode.Create, FileAccess.Write, FileShare.Read))
        {
          wb.Write(fsOut);
          fsOut.Close();
        }
        retState = true;
      }    
      catch (Exception e)
      {
        retState = false;
        RaiseProcessingStatusEvent(e.Message);
      }
      finally
      {
        RaiseProcessingStatusEvent("Creating Data Report - Complete");    
      }
      return retState;
    }

  }
}