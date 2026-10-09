using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{   
  /***************************************************************************
   * ClientAttendanceCalendarDate */
  /**
   * A client attendance calendar date
   **************************************************************************/
   
  public class ClientAttendanceCalendarDate:ClientAttendanceYearlyDataDetail
  {            
    public long   calendarID;
    public string datesStr;
  }
  
  
  /***************************************************************************
   * ClientAttendanceCalendarDates*/
  /**
   * Methods to work with ClientAttendanceCalendarDate
   *
   **************************************************************************/

  public class ClientAttendanceCalendarDates:ClientAttendanceEntities
  {          
        
    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       
   
    public const string SEL_LABEL = "Calendar Dates";
    
    /***************************************************************************
     * save */
    /**
     * Save a calendar date assignment
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Patient's client id
     * 
     * @param  editDelReason   Reason for record edit or delete
     * @param  validateRec     1 = Performs data integrity validation tasks
     *                             Perform advisory validation tasks that can
     *                             only be conducted by referencing data from the
     *                             database and then exits WITHOUT saving the record
     *                         0 = Peform data integrity validation tasks and
     *                             if these tasks succeed peforms the desired
     *                             operation (saveType) on the record and exits
     * @param  saveType        Type of operation to perform
     *                         1 = New, 2 = Edit, 3 = Delete
     * @param  recID           Record id of existing patient record to edit or
     *                         delete.
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord save (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                         string clientID,
                                         string fiscalYearID,
                                         string calendarID,                                   
                                         string attendanceDayTypeID,
                                         string datesStr,                                       
                                         string editDelReason,
                                         string validateRec,
                                         string saveType, 
                                         string recID)
    {           
            
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      long      vClientID            = Validate.reqClientID (uInfo, clientID);                       
      
      Object    vFiscalYearID        = Validate.optInteger  (fiscalYearID,        Messages.INVALID_FISCAL_YEAR_ID);
      long      vCalendarID          = Validate.reqInteger  (calendarID,          Messages.INVALID_CALENDAR_ID);
      long      vAttendanceDayTypeID = Validate.reqInteger  (attendanceDayTypeID, Messages.INVALID_DAY_TYPE_ID);
      string    vDatesStr            = Validate.reqString   (datesStr,            Messages.INVALID_DATES);
      
      /*----------------------------
       * Populate db params
       *----------------------------*/          

      parms.Add(Database.SqlParm("@clientID",                      SqlDbType.Int,      vClientID,                      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fiscalYearID",                  SqlDbType.Int,      vFiscalYearID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clientAttendanceCalendarID",    SqlDbType.BigInt,   vCalendarID,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@attendanceDayTypeID",           SqlDbType.BigInt,   vAttendanceDayTypeID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@datesStr",                      SqlDbType.VarChar,  vDatesStr,                      ParameterDirection.Input, 8000));            
      parms.Add(Database.SqlParm("@MsgNoClient",                   SqlDbType.VarChar,  Messages.INVALID_CLIENT_ID,     ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoCal",                      SqlDbType.VarChar,  Messages.INVALID_CALENDAR_ID,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoDates",                    SqlDbType.VarChar,  Messages.DATES_NOT_ENOUGH,       ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgTooManyDates",               SqlDbType.VarChar,  Messages.DATES_TOO_MANY,         ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgInvDates",                   SqlDbType.VarChar,  Messages.INVALID_DATES,         ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgDupDates",                   SqlDbType.VarChar,  Messages.DATES_DUP,             ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgOutRangeDates",              SqlDbType.VarChar,  Messages.DATES_OUT_OF_RANGE,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgOverlapDates",               SqlDbType.VarChar,  Messages.DATES_OVERLAP,         ParameterDirection.Input, 1000));      
      parms.Add(Database.SqlParm("@MsgInvDayType",                 SqlDbType.VarChar,  Messages.INVALID_DAY_TYPE_ID,   ParameterDirection.Input, 1000));
 
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, 
                           log, 
                           uInfo, 
                           saveType, 
                           validateRec, 
                           editDelReason, 
                           recID, 
                           "CLIENT_ATTENDANCE_CALENDAR_DATES_Save", 
                           Messages.DUP_CLIENT_ATTENDANCE_CALENDAR_DATES, 
                           ref parms, 
                           null);
    }     
        
   /***************************************************************************
    * getValuesAlreadyInUse */
   /**
    * Returns dates or day types that are already in use
    ***************************************************************************/   
   
    public static ReturnValue getValuesAlreadyInUse(SqlConnection connSpedmon, 
                                                    DetailsLog    log, 
                                                    UserInfo      uInfo,                                            
                                                    string        clientID,
                                                    string        fiscalYearID,
                                                    string        calendarID,
                                                    string        dayTypeID,                                          
                                                    string        whatValues,
                                                    bool          includeQuotes)
    {
      
      ReturnValue so = new ReturnValue();
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      int    vClientID     = Validate.reqClientID (uInfo,        clientID);
      int    vFiscalYearID = Validate.reqInteger  (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);      
      long   vCalendarID   = Validate.reqInteger  (calendarID,   Messages.INVALID_CALENDAR_ID);      
      Object vDayTypeID    = Validate.optInteger  (dayTypeID,    Messages.INVALID_DAY_TYPE_ID);      
      int    vWhatValues   = Validate.reqInteger  (whatValues,   Messages.INVALID_WHAT_VALUE);

      string vValues = "";
      
      parms.Add(Database.SqlParm("@clientID",      SqlDbType.Int,     vClientID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fiscalYearID",  SqlDbType.Int,     vFiscalYearID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@calendarID",    SqlDbType.BigInt,  vCalendarID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@dayTypeID",     SqlDbType.BigInt,  vDayTypeID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@whatValues",    SqlDbType.Int,     vWhatValues,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@includeQuotes", SqlDbType.Bit,     includeQuotes,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@values",        SqlDbType.VarChar, vValues,        ParameterDirection.Output, 8000));    
      
      string sql = "select @values = [Values] from CLIENT_ATTENDANCE_CALENDAR_VALUES_ALREADY_IN_USE (@clientID, @fiscalYearID, @calendarID, @dayTypeID, @whatValues, @includeQuotes)";
       
     /*----------------------------
      * Setup our output class
      *----------------------------*/

      ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      so.value = (String) Database.getParameterValue("@values",ref parms);
      return so;
    }
    
    /***************************************************************************
     * view */
    /**
     * 
     **************************************************************************/  
    
    public static ReturnDB view (SqlConnection connSpedmon, 
                                 DetailsLog log, 
                                 UserInfo uInfo,
                                 int    recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 string clientID,
                                 string fiscalYearID,
                                 string calendarID,
                                 defineCols dc) 
    {
    
      string viewUDF = "dbo.CLIENT_ATTENDANCE_CALENDAR_DATES_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @calendarID, @active, @recID)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      Object vClientID     = Validate.optClientID (uInfo,        clientID);
      Object vFiscalYearID = Validate.optInteger  (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);      
      Object vCalendarID   = Validate.optInteger  (calendarID,   Messages.INVALID_CALENDAR_ID);
      
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.Int, vClientID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.Int, vFiscalYearID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@calendarID",   SqlDbType.Int, vCalendarID,   ParameterDirection.Input));
       
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }

    /***************************************************************************
     * delete */
    /**
     * "Deletes" a Attendance calendar dates record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/

    public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           string editDelReason, string validateRec, string recID)
    {

        /*----------------------------
         * Check for required and 
         * optional parameters
         * and validate data integrity
         * of all supplied parameters
         *----------------------------*/

        Object vClientID = Validate.optClientID(uInfo, "");

        /*----------------------------
         * Collect all of the parameters
         * that are specific to this
         * delete method.
         *----------------------------*/

        List<SqlParameter> parms = new List<SqlParameter>();
        parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

        /*----------------------------
         * Call base method 
         *----------------------------*/

        return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "CLIENT_ATTENDANCE_CALENDAR_DATES_DELETE", ref parms);
    }

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single 
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id.
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  ID              ID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static ClientAttendanceCalendarDate load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     string recID)
    {
        return (ClientAttendanceCalendarDate)Entities.load(connSpedmon, log, uInfo, recID, typeof(ClientAttendanceCalendarDate),
        delegate { return ClientAttendanceCalendarDates.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", "", null); });
    }

    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           bool   paged,
                                           string pageNumber,                                          
                                           string clientID,
                                           string fiscalYearID,
                                           string calendarID,
                                           string canEdit,
                                           string active)
    {
        /*----------------------------
         * Define our columns and
         * set the page order for 
         * paging
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            ss.addDisplayColumn("id");
            ss.addDisplayColumn("clientName             as [Client]");
            ss.addDisplayColumn("fiscalYearName         as [Fiscal Year]");
            ss.addDisplayColumn("name                   as [Calendar Name]");
            ss.addDisplayColumn("attendanceDayType      as [Day Type]");
            ss.addDisplayColumn("datesStr               as [Dates]", true);

            //ss.addPageOrderColumn("[]");

            pageroworder = ss.pageRowOrder();

        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber, delegate { 
          return ClientAttendanceCalendarDates.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, fiscalYearID, calendarID, dc); });
    }
  }
}
