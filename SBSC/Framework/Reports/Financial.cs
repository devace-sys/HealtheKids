using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
using ca = MBA.ColumnAttribute;

namespace Spedmon.Reports
{
  /***************************************************************************
   * Financial */
  /**
   * Various financial reports
   ***************************************************************************/

  public class Fianancial:MBA.Reports
  {

    /*-----------------------------
     * Constant report names
     * for financial reports
     *----------------------------*/

    public const string RPT_NAME_AMTS_BY_PRAC_WD_1P      = "Amounts Collected by Practitioner and Check Date (One Period)";
    public const string RPT_NAME_AMTS_BY_PRAC_WD_2P      = "Amounts Collected by Practitioner and Check Date (Two Periods Compared)";        
    public const string RPT_NAME_AMTS_BY_PRAC_SD_1P      = "Amounts Collected by Practitioner and Date Services Rendered (One Period)";
    public const string RPT_NAME_AMTS_BY_PRAC_SD_2P      = "Amounts Collected by Practitioner and Date Services Rendered (Two Periods Compared)";      
    public const string RPT_NAME_AMTS_BY_ELIG_PAT_SD_2P  = "Amounts Collected by Eligible Patient and Date Services Rendered (Two Periods Compared)";
   
    /*-----------------------------
     * Constant sub title "patterns"
     * for financial reports
     *----------------------------*/

    public const string SUB_TITLE_DATE_RANGE_1P     = "For the period {0} - {1}";
    public const string SUB_TITLE_DATE_RANGE_2P     = "Periods {0} - {1} (P1) compared to {2} - {3} (P2)";
    public const string FOOTER_AMOUNTS_ROUNDED      = "The rows and columns may not add across or down since all amounts displayed are rounded to the nearest even dollar";
    
    public static readonly string FOOTER_CONFIDENTIAL = Messages.CONFIDENTIAL;

    public const string URL_RPT_CLAIMS_PAID                 = @"rpt_claims_paid.aspx";
    public const string URL_RPT_CLAIMS_PAID_BY_DOS          = @"rpt_claims_paid_by_dos.aspx";
    public const string URL_RPT_CLAIMS_PAID_BY_DOS_COMPARED = @"rpt_claims_paid_by_dos_compared.aspx";

    public const string URL_REPORT  = "reports_fin.ashx";

    public static string URL_REPORT_BASE()
    { 
       return MBA.HttpApplication.createLink(Fianancial.URL_REPORT, true);
    }

    public static string URL_RPT_CLAIMS_PAID_BASE()
    {
        return MBA.HttpApplication.createLink(Fianancial.URL_RPT_CLAIMS_PAID, true);
    }

    public static string URL_RPT_CLAIMS_PAID_BY_DOS_BASE()
    {
        return MBA.HttpApplication.createLink(Fianancial.URL_RPT_CLAIMS_PAID_BY_DOS, true);
    }

    public static string URL_RPT_CLAIMS_PAID_BY_DOS_COMPARED_BASE()
    {
        return MBA.HttpApplication.createLink(Fianancial.URL_RPT_CLAIMS_PAID_BY_DOS_COMPARED, true);
    }
    
    /***************************************************************************
     * rptClaimsPaidByCheckDate1P */
    /**
     * Claims paid by check date
     * 
     * @param  clientID        Client ID
     * @param  pracID          Practitioner ID 
     * @param  patID           Patient ID
     * @param  dateRange       Date range
     * @return                 Claim records
     ***************************************************************************/
    
     public static ReturnRptData rptClaimsPaidByCheckDate1P (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                             string clientID,                                               
                                                             string dateRange,
                                                             string includezeros)                                               
    {

      return rptClaimsPaidByCheckDate1P(connSpedmon, log, uInfo, clientID, dateRange, includezeros, false); 
    }   
    
    public static ReturnRptData rptClaimsPaidByCheckDate1P (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                            string clientID,
                                                            string dateRange,
                                                            string includezeros,
                                                            bool   allowFutureDates)
    {

      string rptName  = RPT_NAME_AMTS_BY_PRAC_WD_1P;
      string rptTitle = "";

      /*-------------------------------
       * Parse date range into start
       * and end dates
       *----------------------------*/

      string startDate = "";
      string endDate   = "";
      Util.parseDateRange(dateRange, out startDate, out endDate);
      
      /*-------------------------------
       * Create dates title
       *----------------------------*/

      rptTitle = Util.createMessageString(SUB_TITLE_DATE_RANGE_1P, Util.dateTimeToShortDate(startDate), Util.dateTimeToShortDate(endDate));
      
      /*----------------------------
       * Validate parameters specific
       * to this report
       *----------------------------*/

      List<SqlParameter> prms = new List<SqlParameter>();

      int       vClientID     = Validate.reqClientID (uInfo, clientID);      
      bool      vIncludeZeros = Validate.reqFlag     (includezeros, Messages.INVALID_FLAG_INCLUDE_ZEROS);
      
      DateTime  vStartDate;
      DateTime  vEndDate;

      if (!allowFutureDates)
      {
        vStartDate = Validate.reqDate (startDate,  Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
        vEndDate   = Validate.reqDate (endDate,    Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
      }
      else
      {
        vStartDate = Validate.reqDate (startDate,  Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NONE);
        vEndDate   = Validate.reqDate (endDate,    Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NONE);      
      }
      
      return rptClaimsPaidByDateByPrac1P(connSpedmon, log, uInfo, vClientID, null, null, vStartDate, vEndDate, vIncludeZeros, rptName, rptTitle);

    }   

    /***************************************************************************
     * rptClaimsPaidByCheckDate2P */
    /**
     * Claims paid by check date
     * 
     * @param  clientID        Client ID
     * @param  pracID          Practitioner ID 
     * @param  patID           Patient ID
     * @param  dateRange       Date range
     * @return                 Claim records
     ***************************************************************************/

    public static ReturnRptData rptClaimsPaidByCheckDate2P (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                            string clientID,
                                                            string dateRange1,
                                                            string dateRange2,
                                                            string includezeros)
    {
      
      string rptName  = RPT_NAME_AMTS_BY_PRAC_WD_2P;
      string rptTitle = "";  

      /*-----------------------------
       * Parse date range into start
       * and end dates
       *----------------------------*/

      string startDate1 = "";
      string endDate1   = "";
      Util.parseDateRange(dateRange1, out startDate1, out endDate1);

      string startDate2 = "";
      string endDate2   = "";
      Util.parseDateRange(dateRange2, out startDate2, out endDate2);

      /*-----------------------------
       * Create dates title
       *----------------------------*/

      rptTitle = Util.createMessageString(SUB_TITLE_DATE_RANGE_2P, 
                                          Util.dateTimeToShortDate(startDate1), 
                                          Util.dateTimeToShortDate(endDate1),
                                          Util.dateTimeToShortDate(startDate2),
                                          Util.dateTimeToShortDate(endDate2));

      /*-----------------------------
       * Validate parameters specific
       * to this report
       *----------------------------*/

      int    vClientID     = Validate.reqClientID (uInfo, clientID);      
      Object vStartDate1   = Validate.reqDate     (startDate1,   Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
      Object vEndDate1     = Validate.reqDate     (endDate1,     Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
      Object vStartDate2   = Validate.reqDate     (startDate2,   Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
      Object vEndDate2     = Validate.reqDate     (endDate2,     Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
      bool   vIncludeZeros = Validate.reqFlag     (includezeros, Messages.INVALID_FLAG_INCLUDE_ZEROS);
      
      /*-----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
    
      return rptClaimsPaidByDateByPrac2P(connSpedmon, log, uInfo, vClientID, null, null, vStartDate1, vEndDate1, null, null, vStartDate2, vEndDate2, vIncludeZeros, rptName, rptTitle);

    }   

    /***************************************************************************
     * rptClaimsPaidByServiceDate1P */
    /**
     * Claims paid by service date
     * 
     * @param  clientID        Client ID
     * @param  pracID          Practitioner ID 
     * @param  patID           Patient ID
     * @param  dateRange       Date range
     * @return                 Claim records
     ***************************************************************************/
    
    public static ReturnRptData rptClaimsPaidByServiceDate1P (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                              string clientID,
                                                              string dateRange,
                                                              string includezeros)
    {
      return rptClaimsPaidByServiceDate1P(connSpedmon, log, uInfo, clientID, dateRange, includezeros, false);
    }                                               
    
    public static ReturnRptData rptClaimsPaidByServiceDate1P (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                              string clientID,
                                                              string dateRange,
                                                              string includezeros,
                                                              bool   allowFutureDates)
    {

      string rptName  = RPT_NAME_AMTS_BY_PRAC_SD_1P;
      string rptTitle = "";
     
      /*-------------------------------
       * Parse date range into start
       * and end dates
       *----------------------------*/

      string startDate = "";
      string endDate   = "";
      Util.parseDateRange(dateRange, out startDate, out endDate);

      /*-------------------------------
       * Create dates title
       *----------------------------*/

      rptTitle = Util.createMessageString(SUB_TITLE_DATE_RANGE_1P, Util.dateTimeToShortDate(startDate), Util.dateTimeToShortDate(endDate));

      /*----------------------------
       * Validate parameters specific
       * to this report
       *----------------------------*/

      List<SqlParameter> prms = new List<SqlParameter>();

      int       vClientID     = Validate.reqClientID (uInfo, clientID);      
      bool      vIncludeZeros = Validate.reqFlag     (includezeros, Messages.INVALID_FLAG_INCLUDE_ZEROS);
      
      DateTime  vStartDate;
      DateTime  vEndDate;

      if (!allowFutureDates)
      {
        vStartDate = Validate.reqDate (startDate,  Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
        vEndDate   = Validate.reqDate (endDate,    Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
      }
      else
      {
        vStartDate = Validate.reqDate (startDate,  Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NONE);
        vEndDate   = Validate.reqDate (endDate,    Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NONE);      
      }
      

      /*----------------------------
       * Call helper and return
       *----------------------------*/
      
      return rptClaimsPaidByDateByPrac1P(connSpedmon, log, uInfo, vClientID, vStartDate, vEndDate, null, null, vIncludeZeros, rptName, rptTitle);

    }   

    /***************************************************************************
     * rptClaimsPaidByServiceDate2P */
    /**
     * Claims paid by service date for 2P
     * 
     * @param  clientID        Client ID
     * @param  pracID          Practitioner ID 
     * @param  patID           Patient ID
     * @param  dateRange       Date range
     * @return                 Claim records
     ***************************************************************************/

    public static ReturnRptData rptClaimsPaidByServiceDate2P (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                              string clientID,
                                                              string dateRange1,
                                                              string dateRange2,
                                                              string includezeros)
    {
      
      string rptName  = RPT_NAME_AMTS_BY_PRAC_SD_2P;
      string rptTitle = "";

      /*-------------------------------
       * Parse date range into start
       * and end dates
       *----------------------------*/

      string startDate1 = "";
      string endDate1   = "";
      Util.parseDateRange(dateRange1, out startDate1, out endDate1);

      string startDate2 = "";
      string endDate2   = "";
      Util.parseDateRange(dateRange2, out startDate2, out endDate2);

      /*-------------------------------
       * Create dates title
       *----------------------------*/

      rptTitle = Util.createMessageString(SUB_TITLE_DATE_RANGE_2P, 
                                          Util.dateTimeToShortDate(startDate1), 
                                          Util.dateTimeToShortDate(endDate1),
                                          Util.dateTimeToShortDate(startDate2),
                                          Util.dateTimeToShortDate(endDate2));

      /*----------------------------
       * Validate parameters specific
       * to this report
       *----------------------------*/

      int    vClientID     = Validate.reqClientID (uInfo, clientID);      
      Object vStartDate1   = Validate.reqDate     (startDate1,   Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
      Object vEndDate1     = Validate.reqDate     (endDate1,     Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
      Object vStartDate2   = Validate.reqDate     (startDate2,   Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
      Object vEndDate2     = Validate.reqDate     (endDate2,     Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
      bool   vIncludeZeros = Validate.reqFlag     (includezeros, Messages.INVALID_FLAG_INCLUDE_ZEROS);      
      
      /*----------------------------
       * Call helper and return
       *----------------------------*/
    
      return rptClaimsPaidByDateByPrac2P(connSpedmon, log, uInfo, vClientID, vStartDate1, vEndDate1, null, null, vStartDate2, vEndDate2, null, null, vIncludeZeros, rptName, rptTitle);

    }   
  
    /***************************************************************************
     * rptClaimsPaidByDateByEligPat2P */
    /**
     * "Chuck Report"
     * 
     * @param  clientID        Patients client id
     * @param  siteID          Patients site id
     * @param  groupID         Group ID
     * @param  pracID          Practitioner ID 
     * @param  patID           Patient ID
     * @param  dateRange       Date range
     * @return                 Claim records
     ***************************************************************************/

    public static ReturnRptData rptClaimsPaidByDOSByEligPat2P(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                              string clientID,
                                                              string siteID,
                                                              string groupID,
                                                              string pracID,
                                                              string patID,
                                                              string dateRange)
    {

        string rptName    = RPT_NAME_AMTS_BY_ELIG_PAT_SD_2P;
        string rptTitle   = "";
        string startDate1 = "";
        string endDate1   = "";
        string startDate2 = "";
        string endDate2   = "";
        
        /*-------------------------------
         * Parse date range into start
         * and end dates
         *----------------------------*/

        Util.parseDateRange(dateRange, out startDate1, out endDate1);
     
        /*----------------------------
         * Validate parameters specific
         * to this report
         *----------------------------*/

        int      vClientID   = Validate.reqClientID (uInfo, clientID);                
        DateTime vStartDate1 = Validate.reqDate     (startDate1, Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
        DateTime vEndDate1   = Validate.reqDate     (endDate1,   Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
        
        Object   vSiteID     = Validate.optInteger  (siteID,     Messages.INVALID_SITE_ID);
        Object   vGroupID    = Validate.optInteger  (groupID,    Messages.INVALID_GROUP_ID);
        Object   vPracID     = Validate.optInteger  (pracID,     Messages.INVALID_PRAC_ID);
        Object   vPatID      = Validate.optInteger  (patID,      Messages.INVALID_PAT_ID);
                
       
        /*----------------------------
         * Force startdate 1 to start
         * of its month
         *----------------------------*/

        vStartDate1 = Util.dateStart(vStartDate1, 3);
       
       /*-------------------------------
        * Compute second date range
        * 
        * The second date range needs 
        * to be the 12 months PRIOR to
        * the START DATE in the first 
        * date range.
        *------------------------------*/
                
        DateTime vEndDate2    = vStartDate1.AddDays(-1);              // End date 2 is start date - 1 day
        DateTime vStartDate2  = vEndDate2.AddMonths(-12).AddDays(1);  // Start date 2 is end date 2 - 12 months + 1 day
        
        startDate2 = vStartDate2.ToShortDateString();
        endDate2   = vEndDate2.ToShortDateString();
                        
       /*-------------------------------
        * Compute the minimum
        * reference date
        * 
        * Start of current month - 11
        * months
        *------------------------------*/
        
        DateTime todayStartMonth = Util.generateStartDate(3);
        DateTime vMinRefDate     = todayStartMonth.AddMonths(-11);
                                
        /*-------------------------------
         * Create dates title
         *----------------------------*/

        rptTitle = Util.createMessageString(SUB_TITLE_DATE_RANGE_2P,
                                            Util.dateTimeToShortDate(startDate1),
                                            Util.dateTimeToShortDate(endDate1),
                                            Util.dateTimeToShortDate(startDate2),
                                            Util.dateTimeToShortDate(endDate2));
    
  
        /*-------------------------------
         * Define the udf that generates
         * the report data
         *------------------------------*/

        string rptUDF = "dbo.RPT_CLAIMS_PAID_BY_DATE_BY_ELIG_PAT_2P (@clientID, @siteID, @groupID, @pracID, @patID, @startDateDOS1, @endDateDOS1, @startDateDOS2, @endDateDOS2, @minrefdate)";

        /*----------------------------
         * Validate parameters specific
         * to this report
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

        List<SqlParameter> prms = new List<SqlParameter>();

        /*----------------------------
         * Add database paramaters
         *----------------------------*/

        prms.Add(Database.SqlParm("@clientID",      SqlDbType.Int,       vClientID,     ParameterDirection.Input));
        prms.Add(Database.SqlParm("@siteID",        SqlDbType.Int,       vSiteID,       ParameterDirection.Input));
        prms.Add(Database.SqlParm("@groupID",       SqlDbType.Int,       vGroupID,      ParameterDirection.Input));
        prms.Add(Database.SqlParm("@pracID",        SqlDbType.Int,       vPracID,       ParameterDirection.Input));
        prms.Add(Database.SqlParm("@patID",         SqlDbType.Int,       vPatID,        ParameterDirection.Input));

        prms.Add(Database.SqlParm("@startDateDOS1", SqlDbType.DateTime,  vStartDate1,   ParameterDirection.Input));
        prms.Add(Database.SqlParm("@endDateDOS1",   SqlDbType.DateTime,  vEndDate1,     ParameterDirection.Input));

        prms.Add(Database.SqlParm("@startDateDOS2", SqlDbType.DateTime,  vStartDate2,   ParameterDirection.Input));
        prms.Add(Database.SqlParm("@endDateDOS2",   SqlDbType.DateTime,  vEndDate2,     ParameterDirection.Input));

        prms.Add(Database.SqlParm("@minrefdate",    SqlDbType.DateTime,  vMinRefDate, ParameterDirection.Input));


        /*----------------------------
         * Define our columns 
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            ss.addRptColumn(0,  "Client",               ca.DATA_VIEW_GROUP, ca.DATA_CLASS_TEXT, ca.DISPLAY_HEADER_TITLE_1);        
            ss.addRptColumn(1,  "Patient",           9, ca.DATA_VIEW_GROUP, ca.DATA_CLASS_TEXT, ca.DISPLAY_CONTENT_TITLE_4);                    
            
            ss.addRptColumn(2,  "Practitioner",     19, ca.DATA_CLASS_TEXT);
            ss.addRptColumn(3,  "Discipline",       25, ca.DATA_CLASS_TEXT);                                    
              
            ss.addRptColumn(4,  "Asmts P1",         ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE, ca.STYLE_BORDER_LEFT);
            ss.addRptColumn(5,  "Svcs & Trans P1",  ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);
            ss.addRptColumn(6,  "TCM P1",           ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);
            ss.addRptColumn(7,  "Total P1",         ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);

            ss.addRptColumn(8,  "Asmts P2",         ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE, ca.STYLE_BORDER_LEFT);
            ss.addRptColumn(9,  "Svcs & Trans P2",  ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);
            ss.addRptColumn(10, "TCM P2",           ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);
            ss.addRptColumn(11, "Total P2",         ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);

            ss.addRptColumn(12, Constants.RPT_COL_NAME_ROW_TYPE, ca.META);
            ss.addRptColumn(13, Constants.RPT_COL_NAME_GROUP_ID, ca.META);
        };

        /*----------------------------
         * Define our titles
         *----------------------------*/

        TitleOrFooter[] titles = new TitleOrFooter[2];      
        titles[0] = new TitleOrFooter(rptName,  2, TitleOrFooterAttribute.Contains_Report_Name);
        titles[1] = new TitleOrFooter(rptTitle, 3, TitleOrFooterAttribute.Contains_Parameter_Dates);
        
        /*----------------------------
         * Define our footers
         *----------------------------*/
        
        TitleOrFooter[] footers = new TitleOrFooter[2];
        footers[0] = new TitleOrFooter(FOOTER_AMOUNTS_ROUNDED, 1);
        footers[1] = new TitleOrFooter(FOOTER_CONFIDENTIAL,    2);
        
        /*----------------------------
         * Define custom filename
         * Client + 'By Patient' + now
         *----------------------------*/
        
        ReturnRptDataCallback createFileName = delegate(ref ReturnRptData so)
        {          
          string client  = so.resultSetTitles[0].name;
		      string rundate = Util.dateTimeToShortDate(DateTime.Now,FormatStrings.DATETIME_YYYY_MM_DD);
          string ttl     = client + " By Patient " + rundate;          
          
          so.filename = ttl;
          
        };
        
        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/      
        
        return viewRpt(connSpedmon, log, uInfo, rptUDF, titles, footers, prms, null, dc, File.ORIENTATION_LANDSCAPE,null,createFileName);

    }

    /*----------------------------
     * Helpers
     *----------------------------*/

    /***************************************************************************
     * rptClaimsPaidByDate1P */
    /**
     * Internal helper for generating claims paid by practitioner/date reports
     * Dates can be date of service (dos), date of warrant (check) (dow) or both.
     * 
     * @param  clientID        Client ID
     * @param  startDateDOS    Starting DOS date
     * @param  endDateDOS      Ending DOS date
     * @param  startDateDOW    Starting DOW date
     * @param  endDateDOW      Ending DOW date
     * @param  rptName         Name of the report
     * @return                 Claim records
     ***************************************************************************/

    protected static ReturnRptData rptClaimsPaidByDateByPrac1P (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                                long     clientID,
                                                                Object   startDateDOS,
                                                                Object   endDateDOS,
                                                                Object   startDateDOW,
                                                                Object   endDateDOW,
                                                                bool     includeZeros,
                                                                string   rptName,
                                                                string   rptTitle)
    {
      /*-------------------------------
       * Define the udf that generates
       * the report data
       *----------------------------*/
      
      string rptUDF = "dbo.RPT_CLAIMS_PAID_BY_DATE_1P(@clientID,@startDateDOS,@endDateDOS,@startDateDOW,@endDateDOW,@includeZeros,1)"; 
      
      /*----------------------------
       * Validate parameters specific
       * to this report
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> prms = new List<SqlParameter>();

      /*----------------------------
       * Add database paramaters
       *----------------------------*/

      prms.Add(Database.SqlParm("@clientID",      SqlDbType.Int,       clientID,      ParameterDirection.Input));
      prms.Add(Database.SqlParm("@startDateDOS",  SqlDbType.DateTime,  startDateDOS,  ParameterDirection.Input));
      prms.Add(Database.SqlParm("@endDateDOS",    SqlDbType.DateTime,  endDateDOS,    ParameterDirection.Input));
      prms.Add(Database.SqlParm("@startDateDOW",  SqlDbType.DateTime,  startDateDOW,  ParameterDirection.Input));
      prms.Add(Database.SqlParm("@endDateDOW",    SqlDbType.DateTime,  endDateDOW,    ParameterDirection.Input));
      prms.Add(Database.SqlParm("@includeZeros",  SqlDbType.Bit,       includeZeros,  ParameterDirection.Input));
      
      /*----------------------------
       * Define our columns 
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addRptColumn(0,   "Client",                        ca.DATA_VIEW_GROUP, ca.DATA_CLASS_TEXT, ca.DISPLAY_HEADER_TITLE_1);        
        ss.addRptColumn(1,   "Group",                     10, ca.DATA_VIEW_GROUP, ca.DATA_CLASS_TEXT, ca.DISPLAY_CONTENT_TITLE_4);        
        
        ss.addRptColumn(2,   "Practitioner",              40, ca.DATA_CLASS_TEXT);
        ss.addRptColumn(3,   "Active",                        ca.DATA_CLASS_BOOL);

        ss.addRptColumn(4,   "Assessments",                   ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE, ca.STYLE_BORDER_LEFT);
        ss.addRptColumn(5,   "Services & Transportation",     ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);
        ss.addRptColumn(6,   "TCM",                           ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE, ca.STYLE_BORDER_RIGHT);
        ss.addRptColumn(7,   "Total",                         ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);
        ss.addRptColumn(8,   Constants.RPT_COL_NAME_ROW_TYPE, ca.META);
        ss.addRptColumn(9,   Constants.RPT_COL_NAME_GROUP_ID, ca.META);
      };
      
      /*----------------------------
       * Define our titles
       *----------------------------*/
      
      TitleOrFooter[] titles = new TitleOrFooter[2];
      titles[0] = new TitleOrFooter(rptName,  2, TitleOrFooterAttribute.Contains_Report_Name);
      titles[1] = new TitleOrFooter(rptTitle, 3, TitleOrFooterAttribute.Contains_Parameter_Dates);

      /*----------------------------
       * Define our footers
       *----------------------------*/
      
      TitleOrFooter[] footers = new TitleOrFooter[2];
      footers[0] = new TitleOrFooter(FOOTER_AMOUNTS_ROUNDED, 1);
      footers[1] = new TitleOrFooter(FOOTER_CONFIDENTIAL,    2);
     
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return viewRpt(connSpedmon, log, uInfo, rptUDF, titles, footers, prms, null, dc, File.ORIENTATION_PORTRAIT);
    } 
  

    /***************************************************************************
     * rptClaimsPaidByDate2P */
    /**
     * Internal helper for generating claims paid by date reports
     * 
     * @param  clientID        Client ID
     * @param  startDateDOS    Starting DOS date
     * @param  endDateDOS      Ending DOS date
     * @param  startDateDOW    Starting DOW date
     * @param  endDateDOW      Ending DOW date
     * @param  rptName         Name of the report
     * @return                 Claim records
     ***************************************************************************/

    protected static ReturnRptData rptClaimsPaidByDateByPrac2P (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                                long     clientID,
                                                                Object   startDateDOS1,
                                                                Object   endDateDOS1,
                                                                Object   startDateDOW1,
                                                                Object   endDateDOW1,
                                                                Object   startDateDOS2,
                                                                Object   endDateDOS2,
                                                                Object   startDateDOW2,
                                                                Object   endDateDOW2,
                                                                bool     includeZeros,
                                                                string   rptName,
                                                                string   rptTitle)
    {
      /*-------------------------------
       * Define the udf that generates
       * the report data
       *----------------------------*/
      
      string rptUDF = "dbo.RPT_CLAIMS_PAID_BY_DATE_2P(@clientID,@startDateDOS1,@endDateDOS1,@startDateDOW1,@endDateDOW1,@startDateDOS2,@endDateDOS2,@startDateDOW2,@endDateDOW2,@includeZeros,1)"; 
      
      /*----------------------------
       * Add database paramaters
       *----------------------------*/

      List<SqlParameter> prms = new List<SqlParameter>();
      
      prms.Add(Database.SqlParm("@clientID",       SqlDbType.Int,       clientID,       ParameterDirection.Input));
      
      prms.Add(Database.SqlParm("@startDateDOS1",  SqlDbType.DateTime,  startDateDOS1,  ParameterDirection.Input));
      prms.Add(Database.SqlParm("@endDateDOS1",    SqlDbType.DateTime,  endDateDOS1,    ParameterDirection.Input));
      prms.Add(Database.SqlParm("@startDateDOW1",  SqlDbType.DateTime,  startDateDOW1,  ParameterDirection.Input));
      prms.Add(Database.SqlParm("@endDateDOW1",    SqlDbType.DateTime,  endDateDOW1,    ParameterDirection.Input));
      
      prms.Add(Database.SqlParm("@startDateDOS2",  SqlDbType.DateTime,  startDateDOS2,  ParameterDirection.Input));
      prms.Add(Database.SqlParm("@endDateDOS2",    SqlDbType.DateTime,  endDateDOS2,    ParameterDirection.Input));
      prms.Add(Database.SqlParm("@startDateDOW2",  SqlDbType.DateTime,  startDateDOW2,  ParameterDirection.Input));
      prms.Add(Database.SqlParm("@endDateDOW2",    SqlDbType.DateTime,  endDateDOW2,    ParameterDirection.Input));
      prms.Add(Database.SqlParm("@includeZeros",   SqlDbType.Bit,       includeZeros,   ParameterDirection.Input));
 
      /*----------------------------
       * Define our columns 
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addRptColumn(0,  "Client",               ca.DATA_VIEW_GROUP, ca.DISPLAY_HEADER_TITLE_1);
        ss.addRptColumn(1,  "Group",            10, ca.DATA_VIEW_GROUP, ca.DISPLAY_CONTENT_TITLE_4);
        
        ss.addRptColumn(2,  "Practitioner",     50, ca.DATA_CLASS_TEXT);
        ss.addRptColumn(3,  "Active",               ca.DATA_CLASS_BOOL);
       
        ss.addRptColumn(4,  "Asmts P1",          ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE, ca.STYLE_BORDER_LEFT);        
        ss.addRptColumn(5,  "Svcs & Trans P1",   ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);
        ss.addRptColumn(6,  "TCM P1",            ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);
        ss.addRptColumn(7,  "Total P1",          ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);

        ss.addRptColumn(8,  "Asmts P2",          ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE, ca.STYLE_BORDER_LEFT);
        ss.addRptColumn(9,  "Svcs & Trans P2",   ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);
        ss.addRptColumn(10, "TCM P2",            ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);
        ss.addRptColumn(11, "Total P2",          ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE);
        
        ss.addRptColumn(12, "Change - $",        ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_NUMBER_FINANCIAL_NO_ZERO, ca.AGGREGATE, ca.STYLE_BORDER_LEFT);
        ss.addRptColumn(13, "Change - %",        ca.DATA_CLASS_NUMBER, ca.DATA_FORMAT_PERCENTAGE_FINANCIAL,     ca.AGGREGATE);
        
        ss.addRptColumn(14, Constants.RPT_COL_NAME_ROW_TYPE,  ca.META);
        ss.addRptColumn(15, Constants.RPT_COL_NAME_GROUP_ID,  ca.META);

      };
      
      /*----------------------------
       * Define our titles
       *----------------------------*/
      
      TitleOrFooter[] titles = new TitleOrFooter[2];      
      titles[0] = new TitleOrFooter(rptName,  2, TitleOrFooterAttribute.Contains_Report_Name);
      titles[1] = new TitleOrFooter(rptTitle, 3, TitleOrFooterAttribute.Contains_Parameter_Dates);
      
      /*----------------------------
       * Define our footers
       *----------------------------*/
      
      TitleOrFooter[] footers = new TitleOrFooter[2];
      footers[0] = new TitleOrFooter(FOOTER_AMOUNTS_ROUNDED, 1);
      footers[1] = new TitleOrFooter(FOOTER_CONFIDENTIAL,    2);
     
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return viewRpt(connSpedmon, log, uInfo, rptUDF, titles, footers, prms, null, dc, File.ORIENTATION_LANDSCAPE);
    }

    

    
  }
}
