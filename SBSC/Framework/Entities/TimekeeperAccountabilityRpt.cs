using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;


// judging from the file ServicesByPracRpt.cs, it seems we are creating new Entities classes for report-out logic for a given Entities class,
// while the original Entities class will retain all the basic dumb terminal store-and-retrieval logic.

// Calling this TimekeeperAccountabilityRpt, as we will have the ability to add more productivity and biz intel reports here.

namespace Spedmon
{

  /***************************************************************************
   * ServiceRecordsPerMinute */
  /**
   * This class contains data representing the cells of the per-minute productivity report,
   * on a per-row basis
   * 
   * TODO: Add page row order method
   ***************************************************************************/
  public class ServiceRecordsPerMinute : Entity
  {

     public DateTime workDay;
     public string   workDayStr;  
     public TimeSpan startTime;
     public TimeSpan endTime;
     public string   startTimeStr;
     public string   endTimeStr;
     public string   timeEntryTask;
     public string   timeEntryWorkBatch;
     public long     timeEntryNumMins;
     public long     svcRecsNumEntered;
     public Double   entriesPerMinute;                                        
     public string   timeEntryNote;
     public long     employeeID;
	 public long     userID;
	 public long     timeEntryID;

 }

  /***************************************************************************
   * TimekeeperAccountabilityRpt */
  /**
   * Entities class for the per-minute productivity report; implements, handles
   * database connection, is called from ASHX handler and restview API handler
   ***************************************************************************/

  public class TimekeeperAccountabilityRpt : Entities
  {


     public const string SEL_LABEL_PER_MIN_RPT          = @"Service Records Per Minute";
     public const string PER_MIN_RPT_VIEWPAGE_BASE      = @"EmployeeTimeEntryServiceRecordsPerMinute.aspx";
     public const string PER_MIN_RPT_REST_VIEW_BASE     = @"api/v1/timekeeperservicerecordspermin";
     public const string PER_MIN_RPT_VIEWPAGE_MENU_ID   =  @"timekeepereportssvcsrecspermin";
     public static string URL_WEB_REPORT_BASE           = "timekeeper_accountability_rpt.ashx";

     public static string URL_WEB_REPORT()
     {
         return MBA.HttpApplication.createLink(TimekeeperAccountabilityRpt.URL_WEB_REPORT_BASE, true);
     }

     public static string PER_MIN_RPT_REST_VIEW()
     {
         return MBA.HttpApplication.createLink(TimekeeperAccountabilityRpt.PER_MIN_RPT_REST_VIEW_BASE, true);
     }


    /***************************************************************************
    * viewRptServiceRecsPerMinute */
    /**
    * Retrieves report listings of timekeeper entries, with statistical measures of data entry productivity, from the database
    *
    * @param startDate     fetch timeclock entries as of this date; required param
    * @param endDate       fetch timeclock entries on or before this date; required param
    *
    * @return              serializable ReturnSaveRecord object containing exception from database call, if any
    ***************************************************************************/


    public static ReturnDB viewRptServiceRecsPerMinute(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                int recViewType,
                                bool pagedOrTop,
                                string idx,
                                string dateRange,

                                string canEdit,
                                string active,
                                defineCols dc
                                )
    {

        string viewUDF = "dbo.TIMEKEEPER_SERVICE_RECORDS_PER_HOUR_RPT (@userID, @userGroup, @userRank, @startDate, @endDate)";

        var vDates = Validate.reqDateRange(dateRange,@"Please provide a date range");

        var parms = new List<SqlParameter>();
        parms.Add(Database.SqlParm("@startDate", SqlDbType.Date, vDates[0], ParameterDirection.Input));
        parms.Add(Database.SqlParm("@endDate",   SqlDbType.Date, vDates[1], ParameterDirection.Input));

        return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }

    /***************************************************************************
    * viewObjectsRptServiceRecsPerMinute */
    /**
    * Retrieves report listings of timekeeper entries, with statistical measures of data entry productivity, from the database
    *
    * @param startDate     fetch timeclock entries as of this date; required param
    * @param endDate       fetch timeclock entries on or before this date; required param
    *
    * @return Instance of ReturnObjects
    ***************************************************************************/

    public static ReturnObjects viewObjectsRptServiceRecsPerMinute(SqlConnection connSpedmon
                                            , DetailsLog log
                                            , UserInfo   uInfo
                                            , bool       pageObjectList
                                            , string     pageOrder
                                            , string     idx
                                            , string     dateRange )
    {

        /* Default page order */
        /* TODO: Replace with entity.page row order method per standards */

        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = "name, workDay, startTime"; //"[name] asc, workDay asc, startTime asc";

        /* Define columns delegate is used to specify columns and page order 
            * We pass in the desired page row order here */

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };

        return Entities.viewObjects(

            // NOTE: Entities.viewObjects() is used both for fetching 1 item and fetching a result set of multiple records;
            //       Entities.viewObject() is rarely used for any purpose.

            connSpedmon
            , log
            , uInfo
            , typeof(ServiceRecordsPerMinute)
            , pageObjectList
            , pageOrder
            , delegate {

                return TimekeeperAccountabilityRpt.viewRptServiceRecsPerMinute(
                connSpedmon,
                log,
                uInfo,

                Entities.REC_VIEW_OBJECTS,
                // REC_VIEW_OBJECTS is used for all api calls, fetching 1 or fetching a paginated result set;
                // Entities.REC_VIEW_OBJECT is not used for anything as of yet

                pageObjectList,
                idx,

                dateRange,
                
                "", //string canEdit,
                "1", //string active,
                dc
                );

            });


    }

        /***************************************************************************
        * viewTblRptServiceRecsPerMinute */
        /**
         * Returns a data table of report listings of timekeeper entries,
         * with statistical measures of data entry productivity, from the database
         * 
         * @param startDate     fetch timeclock entries as of this date; required param
         * @param endDate       fetch timeclock entries on or before this date; required param
         *
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTblRptServiceRecsPerMinute(
                                            SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                            bool paged,
                                            string pageNumber,
                                            string dateRange,                                            
                                            string canEdit,
                                            string active)
    {
        ReturnDataTable so = new ReturnDataTable();


        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            ss.addDisplayColumn("name as Name");
            ss.addDisplayColumn("workDayStr as [Work Day]");
            ss.addDisplayColumn("startTimeStr as [Start Time]");
            ss.addDisplayColumn("endTimeStr   as [End Time]");
            ss.addDisplayColumn("timeEntryTask as [Time Entry Task]");
            ss.addDisplayColumn("timeEntryWorkBatch as [Work Batch]");
            ss.addDisplayColumn("timeEntryNumMins as [Time\nEntry\nMinutes]");
            ss.addDisplayColumn("svcRecsNumEntered as [Service\nRecords\nEntered]");
            ss.addDisplayColumn("entriesPerMinute as [Service\nRecord\nEntries\nPer\nMinute]");
            ss.addDisplayColumn("timeEntryNote as [Time Entry Note]");

            //ss.addPageOrderColumn("[Patient Name (Last, First)]");

            pageroworder = "name, workDay, startTime"; //"[name] asc, workDay asc, startTime asc";

        };

        /*----------------------------
            * Call base method which
            * handles the rest 
            *----------------------------*/

        so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
            delegate { return TimekeeperAccountabilityRpt.viewRptServiceRecsPerMinute(
                          connSpedmon, log, uInfo,

                          Entities.REC_VIEW_TBL,
                                    paged,
                                    pageNumber,

                                    dateRange,

                                    canEdit, active,
                                    dc

                              ); });

        /*----------------------------
            * Add a title and footer
            *----------------------------*/

        so.tableName = "REPORT - Entries Per Minute";
        so.tableFooter = Messages.CONFIDENTIAL;

        /*----------------------------
            * Done
            *----------------------------*/

        return so;

    }

  }

}