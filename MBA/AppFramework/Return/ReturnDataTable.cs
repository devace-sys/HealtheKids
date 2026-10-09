using System;
using System.Globalization;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using System.Linq;
using System.IO;
using System.Web.Script.Serialization;
using MBA.IdentifyData;
using MBA.Reporting;
using System.Text.RegularExpressions;

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
  
  /***************************************************************************
   * aoColumn */
  /**
   * Column definition for client side data table
   * Based on documentation from http://www.datatables.net/usage/columns
   ***************************************************************************/   

  public class aoColumn
  {
    public aoColumn()
    {

      this.bSearchable = false;
      this.bSortable   = false;
      this.bVisible    = true;
    }
    
    /* Client side datatables data */
    
    public string sTitle;       // title of the column
    public string sType;        // string, numeric, date, or html
    public bool   bSearchable;  // Searchable true or false
    public bool   bSortable;    // Sortable true or false
    public bool   bVisible;     // Visible true or false
    public string sWidth;       // Width based on content in px
    public string sClass;       // CSS class to assign to cells in column
    
    /* Server side meta data (used for processing) */
            
    [ScriptIgnore]
    public int iWidth;                          // Column width                  
        
    [ScriptIgnore]
    public IdentifiedValue.DataClass dataclass; // Presumed column dataclass
    
    [ScriptIgnore]
    public IdentifiedValue.DataType  datatype;  // Presumed column datatype

    [ScriptIgnore]
    public bool colTitleReplacement;

    [ScriptIgnore]
    public string colTitleToReplace;

    [ScriptIgnore]
    public string colTitleReplacementValue;

  }
     
  /***************************************************************************
   * ExcelFileTemplateInfo
  /**
   ***************************************************************************/   

  public class ExcelFileTempateInfo 
  {
    public ExcelFileTempateInfo()
    {
      this.templateFilePath         = Constants.REPORT_TEMPLATES_PATH;      
      this.useTemplate              = true;
      this.limitToPhysicalCells     = true;
      this.postPopulationProcessing = true;
      this.forceFormulaRecalculate  = false;
      this.reEvaluateFormulas       = true;
      this.collapseRowGroups        = true;
      this.collapseColGroups        = true;
    }

    [ScriptIgnore]
    public bool useTemplate = true;
    
    [ScriptIgnore]
    public string templateFilePath = Constants.REPORT_TEMPLATES_PATH;
    
    [ScriptIgnore]
    public string templateFileName;
        
    [ScriptIgnore]
    public int? sheetNum;
    
    [ScriptIgnore]
    public int? startOfDataRowNum;
    
    [ScriptIgnore]
    public int? endOfDataRowNum;
    
    [ScriptIgnore]
    public int? startOfDataColNum;
    
    [ScriptIgnore]
    public int? endOfDataColNum; 
  
    [ScriptIgnore]
    public bool limitToPhysicalCells; 
  
    [ScriptIgnore]
    public bool postPopulationProcessing; 
  
    [ScriptIgnore]
    public bool reEvaluateFormulas;

    [ScriptIgnore]
    public bool forceFormulaRecalculate; 
  
    [ScriptIgnore]
    public bool collapseRowGroups; 
  
    [ScriptIgnore]
    public bool collapseColGroups; 
    
    public bool templateFileIsXLS ()
    {
      if (this.templateFileName.EndsWith(@".xls")) return true;
      return false;
    }
    
    public bool templateFileIsXLSX ()
    {
      if (this.templateFileName.EndsWith(@".xlsx")) return true;
      return false;
    }
    
    public string templateFilePathAndName()
    {           
      if (String.IsNullOrEmpty(this.templateFileName)) return null;
      if (String.IsNullOrEmpty(this.templateFilePath)) return this.templateFileName;      
      return System.IO.Path.Combine (this.templateFilePath, this.templateFileName);
    }
    
    public void setDataCellRegion (int startRowLabel, int endRowLabel, string startColLabel, string endColLabel)
    {
      
      int startRowNumber = startRowLabel - 1;
      int endRowNumber   = endRowLabel   - 1;
      int startColNumber = ExcelFileTempateInfo.colLabelToColNumber(startColLabel);
      int endColNumber   = ExcelFileTempateInfo.colLabelToColNumber(endColLabel);

      this.startOfDataRowNum = startRowNumber;
      this.endOfDataRowNum   = endRowNumber;
      this.startOfDataColNum = startColNumber;
      this.endOfDataColNum   = endColNumber;

    }
        
    public static int colLabelToColNumber (string colLabel)
    {     
      return NPOI.SS.Util.CellReference.ConvertColStringToIndex(colLabel);
    }
    
    public static string colNumberToColLabel (int colNumber)
    {
      return NPOI.SS.Util.CellReference.ConvertNumToColString(colNumber);
    }
        
  }
  
  /***************************************************************************
   * ReturnDataTable */
  /**
   * Data table data in json array form
   * Based on documentation from
   * http://www.datatables.net/examples/data_sources/js_array.html
   ***************************************************************************/

  public class ReturnDataTable : Return, DataFileDistributable
  {
    public ReturnDataTable ()                 : base(){}
    public ReturnDataTable (string msg)       : base(msg){}
    public ReturnDataTable (Exception e)      : base(e){}
    public ReturnDataTable (Warning e)        : base(e){}
    public ReturnDataTable (Critical e)       : base(e){}
    public ReturnDataTable (SessionExpired e) : base(e){}

      
    /* Client side datatables data */
  
    public bool         hasRecords;
    public bool         recordsPaged;
    public string       tableName;
    public string       tableFooter;
    public int          sEcho;
    public long         iTotalRecords;
    public long         iTotalDisplayRecords;
    public long         iRecordPageSize;
    
    /* Server side data */

    public aoColumn[]   aoColumns;
    public Object[]     aaData;          // Rows (array of arrays)
    public int          iTotalWidth;
    public string       sColumns;

    /* Server side data */
    
    [ScriptIgnore]
    public bool useTemplates = false;
    
    [ScriptIgnore]
    public ExcelFileTempateInfo excelTemplate;
    
    [ScriptIgnore]
    public int numVisibleCols;

    [ScriptIgnore]
    private ReturnDB retdb;

    [ScriptIgnore]
    public bool excelFileFromScratchAutoSizeColumns = true;

    [ScriptIgnore]
    public bool columnTitlesReplaceSpacesWithBreaks = false;

    [ScriptIgnore]
    public List<FixedWidthFieldDefinition> fixedWidthFieldDefinitions;
      
    /***************************************************************************
     * FindColumnIndexByTitle
    /**
     * Finds index of column that has sTitle = title
     *
     ***************************************************************************/  

    public int FindColumnIndexByTitle (string title)
    {
      int idx = 0;
      if (this.aoColumns == null)     return -1;
      if (this.aoColumns.Length == 0) return -1;
      foreach (aoColumn col in this.aoColumns)
      {
         if (col.sTitle == title) return idx;
         idx++;
      }
      return -1;
    }


    /***************************************************************************
     * GetCell
    /**
     * Gets cell at rowIdx, colIdx
     *
     ***************************************************************************/  

    public Object GetCell(int rowIdx, int colIdx)
    {
        if (!this.hasRecords) throw new MBA.Critical(@"No records");
        int maxRowIdx = this.aaData.Length - 1;
        int maxColIdx = this.aoColumns.Length - 1;
        if (!Util.IntegerValueIsBetween(rowIdx, 0, maxRowIdx)) throw new MBA.Critical(@"Row index is out of bounds");
        if (!Util.IntegerValueIsBetween(rowIdx, 0, maxRowIdx)) throw new MBA.Critical("@Column index is out of bounds");

        Object[] r = (Object[])aaData[rowIdx]; /* Get row */
        //Object c = r[public_col_idx_to_internal_idx[colIdx]];                /* Get cell */
        Object c = r[colIdx];

        return c;
    }

    /***************************************************************************
     * createHTMLTable */
    /**
     * Renders contents of rd into an HTML table and returns it as a string
     *
     * @param rd   ReturnDataTable
     ***************************************************************************/  
    
    public static string createHTMLTable(ref ReturnDataTable rd) 
    {

      StringBuilder sb             = new StringBuilder();
      int           numVisibleCols = 0;

      if (rd.hasRecords == false)
      {
        sb.AppendFormat(@"<p>{0}</p>",rd.tableName);
        sb.Append(@"<p>No records</p>");
        return sb.ToString();
      }
      
      sb.Append(@"<table style=""width:95%;margin:0 auto;"">");

      /*###########################################################################
        # Caption
        ###########################################################################*/ 

      sb.Append(@"<caption>");
      sb.Append(rd.tableName);
      sb.Append(@"</caption>");
      
      /*###########################################################################
        # Header
        ###########################################################################*/ 

      sb.Append(@"<thead>");
      sb.Append(@"<tr>");
      
      /*============================================================
       * Include all visible columns
       *============================================================*/
     
      foreach (aoColumn col in rd.aoColumns)
      {
        if (col.bVisible)
        {
          sb.AppendFormat(@"<th class=""{0} ui-state-default"" style=""width:{1}px"">",col.sClass, col.iWidth);
          sb.Append(col.sTitle);
          sb.Append (@"</th>");
          numVisibleCols++;
        }
      }
      
      sb.Append(@"</tr>");
      sb.Append(@"</thead>");

      /*###########################################################################
        # Footer
        ###########################################################################*/ 

      sb.Append(@"<tfoot>");
      sb.Append(@"<tr>");
      sb.AppendFormat(@"<th class=""ui-state-default"" colspan=""{0}"">",numVisibleCols);
      sb.Append(rd.tableFooter);
      sb.Append(@"</th>");
      sb.Append(@"</tr>");
      sb.Append(@"</tfoot>");
      
      /*###########################################################################
        # Body
        ###########################################################################*/ 
      
      int curRow = 1;

      sb.Append(@"<tbody>");
                
      foreach(Object[] row in rd.aaData)
      {
        string evenodd = ((curRow % 2) == 0) ? "even":"odd";
        
        sb.AppendFormat (@"<tr class=""{0}"">",evenodd);
        
        int curCol = 0;
        
        foreach (Object cell in row)
        {
          aoColumn curaoCol = rd.aoColumns[curCol];
          if (curaoCol.bVisible)
          {
            sb.AppendFormat(@"<td class=""{0}"">{1}</td>",curaoCol.sClass, cell);
          }
          curCol++;
        }
        sb.Append(@"</tr>");
        curRow++;
      }
      
      sb.Append(@"</tbody>");
      sb.Append(@"</table>");

      return sb.ToString();
    }

    /***************************************************************************
     * createHTMLTableNoStyle */
    /**
     * Renders contents of rd into an HTML table and returns it as a string
     *
     * @param rd   ReturnDataTable
     ***************************************************************************/  
    
    public static string createHTMLTableNoStyle (ref ReturnDataTable rd) //TODO: consider combining with createHTMLTable(), above
    {

      StringBuilder sb             = new StringBuilder();
      int           numVisibleCols = 0;
      
      if (rd.hasRecords == false)
      {
        sb.Append(@"");        
        return sb.ToString();
      }

      sb.Append(@"<table>");

      /*###########################################################################
        # Caption
        ###########################################################################*/ 

      sb.Append(@"<caption>");
      sb.Append(rd.tableName);
      sb.Append(@"</caption>");
            
    
      /*###########################################################################
        # Header
        ###########################################################################*/ 

      sb.Append(@"<thead>");
      sb.Append(@"<tr>");
      
      /*============================================================
       * Include all visible columns
       *============================================================*/
     
      foreach (aoColumn col in rd.aoColumns)
      {
        if (col.bVisible)
        {
          sb.AppendFormat(@"<th class=""{0}"">",col.sClass);
          sb.Append(col.sTitle);
          sb.Append (@"</th>");
          numVisibleCols++;
        }
      }
      
      sb.Append(@"</tr>");
      sb.Append(@"</thead>");

      /*###########################################################################
        # Footer
        ###########################################################################*/ 

      sb.Append(@"<tfoot>");
      sb.Append(@"<tr>");
      sb.AppendFormat(@"<th colspan=""{0}"">",numVisibleCols);
      sb.Append(rd.tableFooter);
      sb.Append(@"</th>");
      sb.Append(@"</tr>");
      sb.Append(@"</tfoot>");
      
      /*###########################################################################
        # Body
        ###########################################################################*/ 
      
      int curRow = 1;

      sb.Append(@"<tbody>");
                
      foreach(Object[] row in rd.aaData)
      {
        string evenodd = ((curRow % 2) == 0) ? "even":"odd";
        
        sb.AppendFormat (@"<tr class=""{0}"">",evenodd);
        
        int curCol = 0;
        
        foreach (Object cell in row)
        {
          aoColumn curaoCol = rd.aoColumns[curCol];
          if (curaoCol.bVisible)
          {
            sb.AppendFormat(@"<td class=""{0}"">{1}</td>",curaoCol.sClass, cell);
          }
          curCol++;
        }
        sb.Append(@"</tr>");
        curRow++;
      }
      
      sb.Append(@"</tbody>");
      sb.Append(@"</table>");

      return sb.ToString();
    }

    public Byte[] DataToXLS()
    {
        ReturnDataTable refthis = this;
        return Excel2.returnDataTableToFile(ref refthis);
    }

    public Byte[] DataToPDF()
    {
        ReturnDataTable refthis = this;
        return PDF.ReturnDataTableToPDF(ref refthis);
    }

    public Byte[] DataToHTML()
    {
        ReturnDataTable refthis = this;
        return HTML2.ReturnDataTableToHTML(ref refthis);
    }

    public string GenerateFileName(string ext)
    {
        return File.GenerateFileName("", this.tableName, ext);
    }

    public new int status { get { return base.status; } }

    public new string message { get { return base.message; } }

        
  }  
}
