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
   * ClientAttendanceScheduleTime */
  /**
   * A client attendance schedule time
   **************************************************************************/
   
  public class ClientAttendanceScheduleTime:ClientAttendanceYearlyDataDetail
  {            
    public long     scheduleID;
    public string   scheduleName;
    public TimeSpan attendanceTimeStart;
    public TimeSpan attendanceTimeEnd;
    public TimeSpan period0TimeStart;
    public TimeSpan period0TimeEnd;
    public TimeSpan period1TimeStart ;
    public TimeSpan period1TimeEnd ;
    public TimeSpan period2TimeStart; 
    public TimeSpan period2TimeEnd ;
    public TimeSpan period3TimeStart; 
    public TimeSpan period3TimeEnd ;
    public TimeSpan period4TimeStart; 
    public TimeSpan period4TimeEnd ;
    public TimeSpan period5TimeStart; 
    public TimeSpan period5TimeEnd ;
    public TimeSpan period6TimeStart; 
    public TimeSpan period6TimeEnd ;
    public TimeSpan period7TimeStart; 
    public TimeSpan period7TimeEnd ;
    public TimeSpan period8TimeStart; 
    public TimeSpan period8TimeEnd ;
    public TimeSpan period9TimeStart; 
    public TimeSpan period9TimeEnd ;
    public TimeSpan period10TimeStart;
    public TimeSpan period10TimeEnd;

    public string   timeStartStr;
    public string   timeEndStr;
    public string   p0StartTimeStr;
    public string   p0EndTimeStr;
    public string   p1StartTimeStr;
    public string   p1EndTimeStr; 
    public string   p2StartTimeStr;
    public string   p2EndTimeStr; 
    public string   p3StartTimeStr;
    public string   p3EndTimeStr; 
    public string   p4StartTimeStr;
    public string   p4EndTimeStr;
    public string   p5StartTimeStr;
    public string   p5EndTimeStr; 
    public string   p6StartTimeStr;
    public string   p6EndTimeStr; 
    public string   p7StartTimeStr;
    public string   p7EndTimeStr; 
    public string   p8StartTimeStr;
    public string   p8EndTimeStr; 
    public string   p9StartTimeStr;
    public string   p9EndTimeStr; 
    public string   p10StartTimeStr;
    public string   p10EndTimeStr;
   
  }

  
  /***************************************************************************
   * ClientAttendanceScheduleTimes*/
  /**
   * Methods to work with ClientAttendanceScheduleTimes
   *
   **************************************************************************/

  public class ClientAttendanceScheduleTimes:ClientAttendanceEntities
  {          
        
    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       
    
    public const string SEL_LABEL = "Bell Schedule Times";
    
    /***************************************************************************
     * save */
    /**
     * Save a schedule time 
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
                                         string scheduleID,                                   
                                         string attendanceDayTypeID,
                                         string startTime,
                                         string endTime,
                                         string	period0TimeStart,
                                         string	period0TimeEnd ,
                                         string	period1TimeStart, 
                                         string	period1TimeEnd ,
                                         string	period2TimeStart, 
                                         string	period2TimeEnd ,
                                         string	period3TimeStart, 
                                         string	period3TimeEnd ,
                                         string	period4TimeStart, 
                                         string	period4TimeEnd ,
                                         string	period5TimeStart, 
                                         string	period5TimeEnd ,
                                         string	period6TimeStart, 
                                         string	period6TimeEnd ,
                                         string	period7TimeStart, 
                                         string	period7TimeEnd ,
                                         string	period8TimeStart, 
                                         string	period8TimeEnd ,
                                         string	period9TimeStart, 
                                         string	period9TimeEnd ,
                                         string	period10TimeStart, 
                                         string	period10TimeEnd ,
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
      long      vScheduleID          = Validate.reqInteger  (scheduleID,          Messages.INVALID_SCHEDULE_ID);
      long      vAttendanceDayTypeID = Validate.reqInteger  (attendanceDayTypeID, Messages.INVALID_DAY_TYPE_ID);
      object    vStartTime           = Validate.optTime     (startTime,           Messages.INVALID_START_TIME);
      object    vEndTime             = Validate.optTime     (endTime,             Messages.INVALID_END_TIME);

      object    vP0StartTime         = Validate.optTime     (period0TimeStart,    Messages.INVALID_START_TIME);
      object    vP0EndTime           = Validate.optTime     (period0TimeEnd,      Messages.INVALID_END_TIME);
      object    vP1StartTime         = Validate.optTime     (period1TimeStart,    Messages.INVALID_START_TIME);
      object    vP1EndTime           = Validate.optTime     (period1TimeEnd,      Messages.INVALID_END_TIME); 
      object    vP2StartTime         = Validate.optTime     (period2TimeStart,    Messages.INVALID_START_TIME);
      object    vP2EndTime           = Validate.optTime     (period2TimeEnd,      Messages.INVALID_END_TIME); 
      object    vP3StartTime         = Validate.optTime     (period3TimeStart,    Messages.INVALID_START_TIME);
      object    vP3EndTime           = Validate.optTime     (period3TimeEnd,      Messages.INVALID_END_TIME);
      object    vP4StartTime         = Validate.optTime     (period4TimeStart,    Messages.INVALID_START_TIME);
      object    vP4EndTime           = Validate.optTime     (period4TimeEnd,      Messages.INVALID_END_TIME); 
      object    vP5StartTime         = Validate.optTime     (period5TimeStart,    Messages.INVALID_START_TIME);
      object    vP5EndTime           = Validate.optTime     (period5TimeEnd,      Messages.INVALID_END_TIME); 
      object    vP6StartTime         = Validate.optTime     (period6TimeStart,    Messages.INVALID_START_TIME);
      object    vP6EndTime           = Validate.optTime     (period6TimeEnd,      Messages.INVALID_END_TIME); 
      object    vP7StartTime         = Validate.optTime     (period7TimeStart,    Messages.INVALID_START_TIME);
      object    vP7EndTime           = Validate.optTime     (period7TimeEnd,      Messages.INVALID_END_TIME); 
      object    vP8StartTime         = Validate.optTime     (period8TimeStart,    Messages.INVALID_START_TIME);
      object    vP8EndTime           = Validate.optTime     (period8TimeEnd,      Messages.INVALID_END_TIME); 
      object    vP9StartTime         = Validate.optTime     (period9TimeStart,    Messages.INVALID_START_TIME);
      object    vP9EndTime           = Validate.optTime     (period9TimeEnd,      Messages.INVALID_END_TIME); 
      object    vP10StartTime        = Validate.optTime     (period10TimeStart,   Messages.INVALID_START_TIME);
      object    vP10EndTime          = Validate.optTime     (period10TimeEnd,     Messages.INVALID_END_TIME);

            
      /*----------------------------
       * Populate db params
       *----------------------------*/          

      parms.Add(Database.SqlParm("@clientID",                      SqlDbType.Int,      vClientID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fiscalYearID",                  SqlDbType.Int,      vFiscalYearID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clientAttendanceScheduleID",    SqlDbType.BigInt,   vScheduleID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@attendanceDayTypeID",           SqlDbType.BigInt,   vAttendanceDayTypeID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@attendanceTimeStart",           SqlDbType.Time,     vStartTime,            ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@attendanceTimeEnd",             SqlDbType.Time,     vEndTime,              ParameterDirection.Input));

      parms.Add(Database.SqlParm("@period0TimeStart",              SqlDbType.Time,     vP0StartTime,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period0TimeEnd",                SqlDbType.Time,     vP0EndTime,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period1TimeStart",              SqlDbType.Time,     vP1StartTime,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period1TimeEnd",                SqlDbType.Time,     vP1EndTime,            ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@period2TimeStart",              SqlDbType.Time,     vP2StartTime,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period2TimeEnd",                SqlDbType.Time,     vP2EndTime,            ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@period3TimeStart",              SqlDbType.Time,     vP3StartTime,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period3TimeEnd",                SqlDbType.Time,     vP3EndTime,            ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@period4TimeStart",              SqlDbType.Time,     vP4StartTime,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period4TimeEnd",                SqlDbType.Time,     vP4EndTime,            ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@period5TimeStart",              SqlDbType.Time,     vP5StartTime,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period5TimeEnd",                SqlDbType.Time,     vP5EndTime,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period6TimeStart",              SqlDbType.Time,     vP6StartTime,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period6TimeEnd",                SqlDbType.Time,     vP6EndTime,            ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@period7TimeStart",              SqlDbType.Time,     vP7StartTime,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period7TimeEnd",                SqlDbType.Time,     vP7EndTime,            ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@period8TimeStart",              SqlDbType.Time,     vP8StartTime,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period8TimeEnd",                SqlDbType.Time,     vP8EndTime,            ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@period9TimeStart",              SqlDbType.Time,     vP9StartTime,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period9TimeEnd",                SqlDbType.Time,     vP9EndTime,            ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@period10TimeStart",             SqlDbType.Time,     vP10StartTime,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@period10TimeEnd",               SqlDbType.Time,     vP10EndTime,           ParameterDirection.Input));

      parms.Add(Database.SqlParm("@MsgNoClient",           SqlDbType.VarChar,  Messages.INVALID_CLIENT_ID,     ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoSch",              SqlDbType.VarChar,  Messages.INVALID_SCHEDULE_ID,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoTimes",            SqlDbType.VarChar,  Messages.INVALID_TIME_RANGE,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgDupTimes",           SqlDbType.VarChar,  Messages.INVALID_TIME_RANGE,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgOutOrderTimes",      SqlDbType.VarChar,  Messages.PERIODS_OUT_OF_ORDER,  ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgOutRangeTimes",      SqlDbType.VarChar,  Messages.INVALID_TIME_RANGE,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPeriodsOverlap",     SqlDbType.VarChar,  Messages.PERIODS_OVERLAPPING,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgInvalidStartPeriod", SqlDbType.VarChar,  Messages.INVALID_START_PERIOD,  ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgInvDayType",         SqlDbType.VarChar,  Messages.INVALID_DAY_TYPE_ID,   ParameterDirection.Input, 1000));
 
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "CLIENT_ATTENDANCE_SCHEDULE_TIMES_Save", Messages.DUP_CLIENT_ATTENDANCE_SCHEDULE_TIMES , ref parms, null);
    }     

   /***************************************************************************
    * getValuesAlreadyInUse */
   /**
    * Returns day types that are already in use
    ***************************************************************************/   
   
    public static ReturnValue getValuesAlreadyInUse(SqlConnection connSpedmon, 
                                                    DetailsLog    log, 
                                                    UserInfo      uInfo,                                            
                                                    string        clientID,
                                                    string        fiscalYearID,
                                                    string        scheduleID,
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
      long   vScheduleID   = Validate.reqInteger  (scheduleID,   Messages.INVALID_SCHEDULE_ID);      
      Object vDayTypeID    = Validate.optInteger  (dayTypeID,    Messages.INVALID_DAY_TYPE_ID);      
      int    vWhatValues   = Validate.reqInteger  (whatValues,   Messages.INVALID_WHAT_VALUE);

      string vValues = "";
      
      parms.Add(Database.SqlParm("@clientID",      SqlDbType.Int,     vClientID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fiscalYearID",  SqlDbType.Int,     vFiscalYearID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@scheduleID",    SqlDbType.BigInt,  vScheduleID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@dayTypeID",     SqlDbType.BigInt,  vDayTypeID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@whatValues",    SqlDbType.Int,     vWhatValues,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@includeQuotes", SqlDbType.Bit,     includeQuotes,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@values",        SqlDbType.VarChar, vValues,        ParameterDirection.Output, 8000));    
      
      string sql = "select @values = [Values] from CLIENT_ATTENDANCE_SCHEDULE_VALUES_ALREADY_IN_USE (@clientID, @fiscalYearID, @scheduleID, @dayTypeID, @whatValues, @includeQuotes)";
       
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
                                 string scheduleID,
                                 defineCols dc) 
    {

        string viewUDF = "dbo.CLIENT_ATTENDANCE_SCHEDULE_TIMES_VIEW (@userID, @userGroup, @userRank , @clientID, @fiscalYearID, @scheduleID, @active, @recID)";    

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
      Object vScheduleID   = Validate.optInteger  (scheduleID,   Messages.INVALID_SCHEDULE_ID);
      
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.Int, vClientID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.Int, vFiscalYearID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@scheduleID",   SqlDbType.Int, vScheduleID,   ParameterDirection.Input));
      
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
     * "Deletes" a schedule time record
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

        return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "CLIENT_ATTENDANCE_SCHEDULE_TIMES_DELETE", ref parms);
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

    public static ClientAttendanceScheduleTime load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     string recID)
    {
        return (ClientAttendanceScheduleTime)Entities.load(connSpedmon, log, uInfo, recID, typeof(ClientAttendanceScheduleTime),
        delegate { return ClientAttendanceScheduleTimes.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", "", null); });
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
                                           string scheduleID,
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
            ss.addDisplayColumn("clientName                           as [Client Name]");
            ss.addDisplayColumn("fiscalYearName                       as [Fiscal Year]");
            ss.addDisplayColumn("scheduleName                         as [Bell Schedule Name]");
            ss.addDisplayColumn("attendanceDayType                    as [Day Type]");
            ss.addDisplayColumn("timeStartStr                         as [Start Time]", true);
            ss.addDisplayColumn("timeEndStr                           as [End Time]");
            ss.addDisplayColumn("p0StartTimeStr  +'  '+p0EndTimeStr  as [Period - 0]");
            ss.addDisplayColumn("p1StartTimeStr  +'  '+p1EndTimeStr  as [Period - 1]");
            ss.addDisplayColumn("p2StartTimeStr  +'  '+p2EndTimeStr  as [Period - 2]");
            ss.addDisplayColumn("p3StartTimeStr  +'  '+p3EndTimeStr  as [Period - 3]");
            ss.addDisplayColumn("p4StartTimeStr  +'  '+p4EndTimeStr  as [Period - 4]");
            ss.addDisplayColumn("p5StartTimeStr  +'  '+p5EndTimeStr  as [Period - 5]");
            ss.addDisplayColumn("p6StartTimeStr  +'  '+p6EndTimeStr  as [Period - 6]");
            ss.addDisplayColumn("p7StartTimeStr  +'  '+p7EndTimeStr  as [Period - 7]");
            ss.addDisplayColumn("p8StartTimeStr  +'  '+p8EndTimeStr  as [Period - 8]");
            ss.addDisplayColumn("p9StartTimeStr  +'  '+p9EndTimeStr  as [Period - 9]");
            ss.addDisplayColumn("p10StartTimeStr +'  '+p10EndTimeStr as [Period - 10]");

           // ss.addPageOrderColumn("[]");

            pageroworder = ss.pageRowOrder();

        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
          delegate { return ClientAttendanceScheduleTimes.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, fiscalYearID, scheduleID, dc); });
    }
  }
}
