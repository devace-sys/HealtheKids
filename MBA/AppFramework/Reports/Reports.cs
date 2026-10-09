using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;
using MBA.Reporting;
using ca = MBA.ColumnAttribute;

namespace MBA
{
  
  /***************************************************************************
   * Reports */
  /**
   * Common methods used for working with reports
   ***************************************************************************/   
  
  public abstract class Reports
  {

    
    /***************************************************************************
     * viewRpt */
    /**
     * 
     * @param    rptUDF           The name of the report udf and its parameters
     * @param    rpttitles        Report titles
     * @param    rptfooters       Report footers
     * @param    parms            Parameters for udf
     * @param    vp               Parameter validation delegate
     * @param    dc               Column definition
     * @param    orientation      Output orientation
     * @param    createTitle      Combinined title creation delegate
     * @param    createFileName   File name creation delegate
     * @return                    ReturnDataTable
     ***************************************************************************/
    
    protected static ReturnRptData viewRpt(SqlConnection connApp, DetailsLog log, UserInfo uInfo, 
                                           string rptudf, 
                                           TitleOrFooter[] rpttitles, 
                                           TitleOrFooter[] rptfooters, 
                                           List<SqlParameter>   parms, 
                                           validateParms vp, 
                                           defineCols    dc)
    {
      return viewRpt(connApp, log, uInfo, rptudf, rpttitles, rptfooters, parms, vp, dc, File.ORIENTATION_PORTRAIT, null, null);
    }
    
    protected static ReturnRptData viewRpt(SqlConnection connApp, DetailsLog log, UserInfo uInfo, 
                                      string rptudf, 
                                      TitleOrFooter[] rpttitles, 
                                      TitleOrFooter[] rptfooters, 
                                      List<SqlParameter> parms, 
                                      validateParms vp, 
                                      defineCols dc,
                                      int orientation)
    {
      return viewRpt(connApp, log, uInfo, rptudf, rpttitles, rptfooters, parms, vp, dc, orientation, null, null);
    }
    
    protected static ReturnRptData viewRpt(SqlConnection connApp, DetailsLog log, UserInfo uInfo, 
                                      string rptudf, 
                                      TitleOrFooter[] rpttitles,
                                      TitleOrFooter[] rptfooters,
                                      List<SqlParameter> parms, 
                                      validateParms vp, 
                                      defineCols dc,
                                      int orientation,
                                      ReturnRptDataCallback createTitle,
                                      ReturnRptDataCallback createFileName)
    {
      
      /*----------------------------
       * Create our return class
       *----------------------------*/

      ReturnRptData so      = new ReturnRptData();
      so.resultSetTitles    = new List<TitleOrFooter>();
      so.resultSetFooters   = new List<TitleOrFooter>();
      so.output_orientation = orientation;
      
      /*----------------------------
       * Validate parameters provided
       * by caller
       *----------------------------*/

      if (vp != null) vp();

      /*----------------------------
       * Add commonly used parms
       *----------------------------*/
      
      parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt,  uInfo.userid,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,     uInfo.userGroup,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,     uInfo.userRank,   ParameterDirection.Input));
      
      /*----------------------------
       * Generate the SQL statement
       * and insert it into our output
       * class
       *----------------------------*/
      
      string       sql          = "";  
      string       pageroworder = "";
      SQLStatement ss           = new SQLStatement(rptudf, SQLResultSetPurpose.REPORT);
      
      so.sqlstatement = ss;

      /*----------------------------
       * Column definitions
       *----------------------------*/

      if (dc != null) 
        dc(ref ss, ref pageroworder, ref parms);

      /*----------------------------
       * Generate sql from our
       * SQL statement object
       *----------------------------*/
      
      sql = ss.ToString();     
      
      /*----------------------------
       * Execute it
       *----------------------------*/
      
      ReturnDB rd = Database.execQuery(connApp, log, sql, false, parms); 

      /*----------------------------
       * Determine number of rows
       * and columns
       *----------------------------*/
              
       if (rd.hasRecords)
       {
         so.numRows = rd.records.Length;                  
         so.numCols = rd.records[0].fields.Length;
       }
       else
       {
         so.numRows = 0;
         so.numCols = 0;
         throw new Warning(Messages.NO_RECORDS_FOUND);
       }

      /*----------------------------
       * Inject report titles and
       * footers
       *----------------------------*/
      
      foreach(TitleOrFooter title in rpttitles)
         so.resultSetTitles.Add(title);
            
      foreach(TitleOrFooter footer in rptfooters)
         so.resultSetFooters.Add(footer);
           
      /*----------------------------
       * Create data tree
       *----------------------------*/
      
      so.datatree = new MBA.Reporting.DataTree();            
      so.datatree.AddInputFieldDefinitions(so.sqlstatement.InputFieldDefinitions);
      so.datatree.AddRecords(rd.records);
          
      /*----------------------------
       * Inject additional report 
       * titles and footers
       * from data tree
       *----------------------------*/
      
      foreach(TitleOrFooter title in so.datatree.displayTitles)
         so.resultSetTitles.Add(title);
      
      foreach(TitleOrFooter footer in so.datatree.displayFooters)
         so.resultSetFooters.Add(footer);
      
      /*----------------------------
       * Sort titles and footers
       *----------------------------*/

      so.resultSetTitles.Sort();
      so.resultSetFooters.Sort();
      
      /*----------------------------
       * Create title
       * from user supplied delegate
       * or standard method
       *----------------------------*/
         
      if (createTitle != null)
        createTitle(ref so);
      else
      {
        so.title = ReturnRptData.CreateTitle(ref so);
      } 
           
      /*----------------------------
       * Create file name
       * (name only, not extension)
       * from user supplied delegate
       * or standard method
       *----------------------------*/
     
      if (createFileName != null)
        createFileName(ref so);
      else
      {
        so.filename = ReturnRptData.CreateFileName(ref so);
      }
      
      /*----------------------------
       * Done
       *----------------------------*/
      
      return so;
    }
  
  }
}
