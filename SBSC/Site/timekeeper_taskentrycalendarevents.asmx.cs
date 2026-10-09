using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * RolesSvc */
  /*
   * Web services end point for user roles.
   *
   * Unless indicated, each of these methods require that the caller is 
   * logged in.
   * 
   * Each end point method provides a wrapper for a coresponding framework
   * method that is not accessible from the outside.
   * 
   * These wrappers handle access control and parameter replacement.
   * 
   * The method is restricted to calls for given user groups
   * 
   * Parameter replacement is used to enforce additional access control within
   * the user group but this is limited.
   *
   * The final line of defense for access control are the database udfs or 
   * sprocs that return or save data
   ***************************************************************************/

  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class TaskEntryCalendarEventsSvc : MBA.WebSvc
  {

        [WebMethod]
        [ScriptMethod(UseHttpGet = true /*,  ResponseFormat = ResponseFormat.Json */ )]
        public void fetchScheduledAndRecordedObjs()
        {

            var o_rdb = callMethod(typeof(ReturnDB),
            delegate ()
            {
                var rdb = TimeKeeperTaskEntryCalendarEvents.fetchScheduledAndRecordedObjects(
                            dbConnApp, log, uInfo, rd.wu.usr,
                            MBA.HttpApplication.getParameter("empid"),
                            MBA.HttpApplication.getParameter("dispmode"),
                            MBA.HttpApplication.getParameter("date"),
                            MBA.HttpApplication.getParameter("inclFormInfo")
                        );
                return rdb;
            }
            ,
            Constants.ROLE_SBS_ALL);

            ReturnDB r_rdb = (ReturnDB)o_rdb;

            string json_str;
            if (!(r_rdb.hasRecords)) json_str = "[]"; else json_str = (string)r_rdb.records[0].fields[0].value;
            Context.Response.ContentType = "application/json; charset=utf-8";
            Context.Response.Output.Write(json_str);


        }


        [WebMethod]
        [ScriptMethod(UseHttpGet = true //,  ResponseFormat = ResponseFormat.Json
        )]
        public void deleteTimeEntry(string te_id)
        {

            var o_rdb = callMethod(typeof(ReturnObjects),
            delegate ()
            {
                var rdb = TimeKeeperTaskEntryCalendarEvents.deleteTimeEntry(
                            dbConnApp, log, uInfo, rd.wu.usr, te_id
                        );

                return rdb;
            }
            ,
            Constants.ROLE_SBS_ALL);

            ReturnDB r_rdb = (ReturnDB)o_rdb;

            string json_str;
            json_str = JSON.toJSONString(r_rdb);// (string)r_rdb.records[0].fields[0].value;
            Context.Response.ContentType = "application/json; charset=utf-8";
            Context.Response.Output.Write(json_str);


        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = true /*,  ResponseFormat = ResponseFormat.Json */ )]
        public void saveTaskWeekHours(string daysHoursInfo, string emp_id)
        {

            var o_rdb = callMethod(typeof(ReturnDB),
            delegate ()
            {
                //return Roles.viewSel(dbConnUser, log, uInfo, false,"", Constants.APP_NAME, term);},
                //Constants.ROLE_SVC_PRAC);  // Who can call this method
                var rdb = TimeKeeperTaskEntryCalendarEvents.saveTaskWeekHours(
                            dbConnApp, log, uInfo, rd.wu.usr, daysHoursInfo, emp_id
                        );
                return rdb;
            }
            ,
            Constants.ROLE_SBS_ALL);

            //return (Object[])ro_d;
            ReturnSaveRecord r_rdb = (ReturnSaveRecord)o_rdb;

            string json_str;
            json_str = JSON.toJSONString(r_rdb);// (string)r_rdb.records[0].fields[0].value;
            Context.Response.ContentType = "application/json; charset=utf-8";
            Context.Response.Output.Write(json_str);


        }



        [WebMethod]
        [ScriptMethod(UseHttpGet = true /*,  ResponseFormat = ResponseFormat.Json */ )]
        public void saveTimeEntry()
        {

            var o_rdb = callMethod(typeof(ReturnDB),
            delegate ()
            {
                //return Roles.viewSel(dbConnUser, log, uInfo, false,"", Constants.APP_NAME, term);},
                //Constants.ROLE_SVC_PRAC);  // Who can call this method
                var rdb = TimeKeeperTaskEntryCalendarEvents.saveTimeEntry(
                            dbConnApp, log, uInfo, rd.wu.usr
                        );
                return rdb;
            }
            ,
            Constants.ROLE_SBS_ALL);

            //return (Object[])ro_d;
            ReturnDB r_rdb = (ReturnDB)o_rdb;

            string json_str;
            json_str = JSON.toJSONString(r_rdb);// (string)r_rdb.records[0].fields[0].value;
            Context.Response.ContentType = "application/json; charset=utf-8";
            Context.Response.Output.Write(json_str);

        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = true /*,  ResponseFormat = ResponseFormat.Json */ )]
        public void updateTimeEntry()
        {

            var o_rdb = callMethod(typeof(ReturnDB),
            delegate ()
            {
                //return Roles.viewSel(dbConnUser, log, uInfo, false,"", Constants.APP_NAME, term);},
                //Constants.ROLE_SVC_PRAC);  // Who can call this method
                var rdb = TimeKeeperTaskEntryCalendarEvents.updateTimeEntry(
                            dbConnApp, log, uInfo, rd.wu.usr
                        );
                return rdb;
            }
            ,
            Constants.ROLE_SBS_ALL);

            //return (Object[])ro_d;
            ReturnDB r_rdb = (ReturnDB)o_rdb;

            string json_str;
            json_str = JSON.toJSONString(r_rdb);// (string)r_rdb.records[0].fields[0].value;
            Context.Response.ContentType = "application/json; charset=utf-8";
            Context.Response.Output.Write(json_str);

        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = true /*,  ResponseFormat = ResponseFormat.Json */ )]
        public void updateTimeVerification()
        {

            var o_rdb = callMethod(typeof(ReturnDB),
            delegate ()
            {
                //return Roles.viewSel(dbConnUser, log, uInfo, false,"", Constants.APP_NAME, term);},
                //Constants.ROLE_SVC_PRAC);  // Who can call this method
                var rdb = TimeKeeperTaskEntryCalendarEvents.updateTimeVerification(
                            dbConnApp, log, uInfo, rd.wu.usr
                        );
                return rdb;
            }
            ,
            Constants.ROLE_SBS_ALL);

            //return (Object[])ro_d;
            ReturnDB r_rdb = (ReturnDB)o_rdb;

            string json_str;
            json_str = JSON.toJSONString(r_rdb);// (string)r_rdb.records[0].fields[0].value;
            Context.Response.ContentType = "application/json; charset=utf-8";
            Context.Response.Output.Write(json_str);

        }


    }
}
