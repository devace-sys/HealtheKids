using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    public class ScheduleableTask : Entity
    {
        public long id;
        public string taskName;
        public Object starttime;
        public Object stoptime;
        public long numberOfMinutes;
        public long daynum;
        public string tetid_daynum;
    }

    public class TimeKeeperTaskEntryCalendarEvents : Entities
    {

        public static ReturnDB viewEntriedObjects  (  SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , string dispmode
                                      , string        empid
                                      , string        start
                                      , defineCols    dc )
        {

            string viewUDF;
            if (dispmode == "week")
              viewUDF = @"[dbo].[TimeKeeper_TIMESHEET_ViewCalendarRecordedTasksRptWeekGlance] (@empid, @dispdate)";
            else
              viewUDF = @"[dbo].[TimeKeeper_TIMESHEET_ViewCalendarRecordedTasksRpt] (@empid, @dispdate)";


            List<SqlParameter> parms = new List<SqlParameter>();

            Object v_empid = Validate.reqInteger(empid, "invalid employee");

            Object v_date = Validate.reqDate(start, "invalid start");

            parms.Add(Database.SqlParm("@empid", SqlDbType.BigInt, v_empid, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@dispdate", SqlDbType.DateTime, v_date, ParameterDirection.Input));


            return Entities.view (  connSpedmon
                                  , log
                                  , uInfo
                                  , Entities.REC_VIEW_ALL
                                  , false
                                  , ""
                                  , ""
                                  , ""
                                  , viewUDF
                                  , ref parms
                                  , null
                                  , dc );
        }


        public static ReturnDB fetchEntriedObjects(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , string empid
                                      , string dispmode
                                      , string start)
        {
            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
            };

            return TimeKeeperTaskEntryCalendarEvents.viewEntriedObjects(connSpedmon
                                                                                          , log
                                                                                          , uInfo
                                                                                          , dispmode
                                                                                          , empid
                                                                                          , start
                                                                                          , dc);

        }

        public static ReturnDB viewScheduledObjects(SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , string dispmode
                                      , string empid
                                      , string start
                                      , defineCols dc)
        {

            string viewUDF;
            if (dispmode == "week")
                viewUDF = @"[dbo].[TimeKeeper_TIMESHEET_ViewCalendarScheduledTasksRptWeekGlance] (@empid, @dispdate)";
            else
                viewUDF = @"[dbo].[TimeKeeper_TIMESHEET_ViewCalendarScheduledTasksRpt] (@empid, @dispdate)";


            List<SqlParameter> parms = new List<SqlParameter>();

            Object v_empid = Validate.reqInteger(empid, "invalid employee");

            Object v_date = Validate.reqDate(start, "invalid start");

            parms.Add(Database.SqlParm("@empid", SqlDbType.BigInt, v_empid, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@dispdate", SqlDbType.DateTime, v_date, ParameterDirection.Input));


            return Entities.view(connSpedmon
                                  , log
                                  , uInfo
                                  , Entities.REC_VIEW_ALL
                                  , false
                                  , ""
                                  , ""
                                  , ""
                                  , viewUDF
                                  , ref parms
                                  , null
                                  , dc);
        }

        public static ReturnDB fetchScheduledObjects(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , string empid
                                      , string dispmode
                                      , string start)
        {
            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
            };

            return TimeKeeperTaskEntryCalendarEvents.viewScheduledObjects(connSpedmon
                                                                                          , log
                                                                                          , uInfo
                                                                                          , dispmode
                                                                                          , empid
                                                                                          , start
                                                                                          , dc);

        }

        public static ReturnDB viewScheduledAndRecordedObjects(SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , string dispmode
                                      , string empid
                                      , string start
                                      , string includeFormData
                                      , defineCols dc)
        {

            string viewUDF;
            if (dispmode == "week")
                viewUDF = @"[dbo].[TimeKeeper_TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRptWeekGlance] (@empid, @dispdate, @includeFormData)";
            else
                viewUDF = @"[dbo].[TimeKeeper_TIMESHEET_ViewCalendarCombinedScheduledRecordedTasksRpt] (@empid, @dispdate, @includeFormData)";


            List<SqlParameter> parms = new List<SqlParameter>();

            Object v_empid = Validate.reqInteger(empid, "invalid employee");

            Object v_date = Validate.reqDate(start, "invalid start");

            parms.Add(Database.SqlParm("@empid", SqlDbType.BigInt, v_empid, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@dispdate", SqlDbType.DateTime, v_date, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@includeFormData", SqlDbType.Bit, Validate.reqFlag(includeFormData, "include form data?"), ParameterDirection.Input));


            return Entities.view(connSpedmon
                                  , log
                                  , uInfo
                                  , Entities.REC_VIEW_ALL
                                  , false
                                  , ""
                                  , ""
                                  , ""
                                  , viewUDF
                                  , ref parms
                                  , null
                                  , dc);
        }


        private static void validate_empid_for_request(MBA.User usr, ref string empid)
        {
            if (usr.timeSheetUserInfo == null)
                usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(usr.userName);

            if (usr.timeSheetUserInfo.roleID == 2 /* employee role from [TimeKeeper].[dbo].[TimeSystemRole] */
                ||
                Util.IsNullOrEmpty(empid) )

                empid = usr.timeSheetUserInfo.employeeid.ToString();
        }


        public static ReturnDB fetchScheduledAndRecordedObjects(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , MBA.User usr
                                                , string empid
                                      , string dispmode
                                      , string start
                                      , string includeFormData)
        {
            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
            };

            validate_empid_for_request(usr, ref empid);

            return TimeKeeperTaskEntryCalendarEvents.viewScheduledAndRecordedObjects(connSpedmon
                                                                                          , log
                                                                                          , uInfo
                                                                                          , dispmode
                                                                                          , empid
                                                                                          , start
                                                                                          , includeFormData
                                                                                   , dc);
        }

        public static ReturnDB viewSchedule(SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , string dispmode
                                      , string empid
                                      , string start
                                      , defineCols dc)
        {

            string viewUDF = @"[dbo].[TimeKeeper_TIMESHEET_ViewCalendarScheduleableTasks] (@empid, @startdate, @enddate)";

            List<SqlParameter> parms = new List<SqlParameter>();

            //Object v_empid = Validate.reqInteger(empid, "invalid employee");

            //Object v_date = Validate.reqDate(start, "invalid start");

            parms.Add(Database.SqlParm("@empid", SqlDbType.BigInt, 71 /* v_empid */, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@startdate", SqlDbType.DateTime, "2021-08-16" /* v_date */, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@enddate", SqlDbType.DateTime, "2021-08-16" /* v_date */, ParameterDirection.Input));

            return Entities.view(connSpedmon
                                  , log
                                  , uInfo
                                  , Entities.REC_VIEW_ALL
                                  , false
                                  , ""
                                  , ""
                                  , ""
                                  , viewUDF
                                  , ref parms
                                  , null
                                  , dc);
        }


        public static ReturnObjects /* ReturnDB */ voFetchSchedule(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , string empid
                                      //, string dispmode
                                      , string start)
        {
            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
            };

            /* return TaskEntryCalendarEvents.viewSchedule(connSpedmon
                                                                                          , log
                                                                                          , uInfo
                                                                                          , dispmode
                                                                                          , empid
                                                                                          , start
                                                                                          , dc);
            */
            var rd = Entities.viewObjects(connSpedmon
                                    , log
                                    , uInfo
                                    , typeof(ScheduleableTask)
                                    , true //pageObjectList
                                    , "id" //pageOrder
                                    , delegate {
                                        return TimeKeeperTaskEntryCalendarEvents.viewSchedule(connSpedmon
                                                                                        , log
                                                                                        , uInfo

                                                                                        //, Entities.REC_VIEW_OBJECTS
                                                                                        //, true //pageObjectList

                                                                                        , "1" //idx

                                                                                        //, "" /* Can Edit */
                                                                                        //, "1" //active

                                                                                        , "" //clientID
                                                                                        , ""// groupSvcClassNameID

                                                                                        //, ""
                                                                                        //, ""

                                                                                        //, ""//term

                                                                                        , dc);
                                    });

            return rd;
        }


        public static ReturnDB saveTimeEntry(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo, MBA.User usr)
        {

            string validated_empid_for_request = "";  // TODO: we need to get the e_id from the webform, so that a manager can enter an entry for a direct report.


            validate_empid_for_request(usr, ref validated_empid_for_request);

            //var con = new SqlConnection("dbConnApp"); // dbConnApp;
            //{
            //con.Open();
            //SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_CreateTimeEntry", con);
            //cmd.CommandType = CommandType.StoredProcedure;

            var parms = new List<SqlParameter>();

                var v_ted_id = MBA.HttpApplication.getParameter("addentry_ted_id");

                if ( Util.IsNullOrEmpty(v_ted_id)) {

                  SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_CreateTimeEntryDay", connSpedmon);
                  cmd.CommandType = CommandType.StoredProcedure;

                  cmd.Parameters.AddWithValue("@EmployeeId", validated_empid_for_request);
                  cmd.Parameters.AddWithValue("@dateForTimeEntry", MBA.HttpApplication.getParameter("addentry_date_val"));
                  cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                  cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                  cmd.ExecuteNonQuery();
                  v_ted_id = cmd.Parameters["@Id"].Value.ToString();
                }


                parms.Add(
                  Database.SqlParm("@timeEntryDayID", SqlDbType.BigInt, v_ted_id, ParameterDirection.Input)
                );

                // SBC TODO: Version 1.5 rename column to smart sheet and remove IsHelp and IsProject management fields
                // along with ITPM_ID.  Rename HD_ROW_ID to SmartSheetID
                bool _isProjectManagement = false, _isHelpDesk = false;

                string _displayStartTime = MBA.HttpApplication.getParameter("TextBoxStartTime");

                //DateTime.TryParse(
                //    MBA.HttpApplication.getParameter("TextBoxStartTime"),
                //     _displayStartTime
                //);

                var hiddenFieldDateTimeEntry = MBA.HttpApplication.getParameter("addentry_date_val");

                var TextBoxStartTime = MBA.HttpApplication.getParameter("TextBoxStartTime");

                DateTime TextBoxStartTime_testOut;

                if ( DateTime.TryParse(TextBoxStartTime, out TextBoxStartTime_testOut) )
                {
                    //cmd.Parameters.AddWithValue(
                    //    "@timeOfTask",
                    //    DateTime.Parse(
                    //        hiddenFieldDateTimeEntry +
                    //         " " +
                    //         TextBoxStartTime
                    //    )
                    // );
                    parms.Add(
                    Database.SqlParm(
                        "@timeOfTask",
                        SqlDbType.DateTime,
                        DateTime.Parse(
                          hiddenFieldDateTimeEntry +
                             " " +
                             TextBoxStartTime
                        ),
                        ParameterDirection.Input
                    )
                 );

                }
                else
                {
                    //cmd.Parameters.AddWithValue("@timeOfTask", DateTime.Parse(hiddenFieldDateTimeEntry));
                    parms.Add(
                    Database.SqlParm(
                        "@timeOfTask",
                        SqlDbType.DateTime,
                        DateTime.Parse( hiddenFieldDateTimeEntry ),
                        ParameterDirection.Input
                    )
                 );

                }


                //int _numberOfMinutes = 0;
                short _hours = 0;
                short _minutes = 0;

                Int16.TryParse( MBA.HttpApplication.getParameter("TextBoxMinutes")  , out _minutes);

                Int16.TryParse( MBA.HttpApplication.getParameter("TextBoxHours")  , out _hours);

                if (_hours > 0)
                    _minutes += (short)(_hours * 60);

                // If multiple client select numberOfMinutes will be 0
                /*
                if (calcMinutes)
                {
                    if (TextBoxHours.Visible && TextBoxMinutes.Visible)
                    {
                        _numberOfMinutes = Convert.ToInt32(TextBoxHours.Text) * 60 + Convert.ToInt32(TextBoxMinutes.Text);
                    }
                    else if (!string.IsNullOrEmpty(LiteralHours.Text) && !string.IsNullOrEmpty(LiteralMinutes.Text))
                    {
                        int.TryParse(LiteralHours.Text, out _hours);
                        int.TryParse(LiteralMinutes.Text, out _minutes);
                        _numberOfMinutes = _hours * 60 + _minutes;
                    }
                    else
                    {
                        DateTime _startTime = DateTime.Parse("1-1-2000 " + TextBoxStartTime.Text);
                        DateTime _endTime = DateTime.Parse("1-1-2000 " + TextBoxStopTime.Text);
                        TimeSpan _timeSpan = _endTime - _startTime;
                        _numberOfMinutes = _timeSpan.Hours * 60 + _timeSpan.Minutes;
                    }
                }
                */



                long _timeEntryTaskID = Convert.ToInt64(
                    MBA.HttpApplication.getParameter("ListBoxFavoriteTaskTimeEntry")
                );

                parms.Add(
                  Database.SqlParm("@timeEntrytaskID", SqlDbType.BigInt, _timeEntryTaskID, ParameterDirection.Input)
                );

            //cmd.Parameters.AddWithValue("@numberMinutes", _numberOfMinutes);

            parms.Add(
                  Database.SqlParm("@numberMinutes", SqlDbType.BigInt, _minutes, ParameterDirection.Input)
                );

                //cmd.Parameters.AddWithValue("@timeEntrytaskID", _timeEntryTaskID);

                var orgClientID = MBA.HttpApplication.getParameter("ListBoxFavoriteClientTimeEntry");

                if (Util.IsNullOrEmpty(orgClientID) || orgClientID == "0")
                {
                    //cmd.Parameters.AddWithValue("@orgClientID", DBNull.Value);
                    parms.Add(
                    Database.SqlParm("@orgClientID", SqlDbType.BigInt, DBNull.Value, ParameterDirection.Input)
                    );
                }
                else
                {
                    //cmd.Parameters.AddWithValue("@orgClientID", orgClientID);
                    parms.Add(
                    Database.SqlParm("@orgClientID", SqlDbType.BigInt, orgClientID, ParameterDirection.Input)
                    );
                }

                var TextBoxNotes = MBA.HttpApplication.getParameter("TextBoxNotes");

                if (Util.IsNullOrEmpty(TextBoxNotes))
                {
                    //cmd.Parameters.AddWithValue("@note", DBNull.Value);
                    parms.Add(
                    Database.SqlParm("@note", SqlDbType.NVarChar, DBNull.Value, ParameterDirection.Input)
                    );
                }
                else
                {
                    // This is done client side string _note = TextBoxNotes.Text.Replace("&","&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;").Replace("'", "&apos;");
                    //cmd.Parameters.AddWithValue("@note", TextBoxNotes);
                    parms.Add(
                    Database.SqlParm("@note", SqlDbType.NVarChar, TextBoxNotes, ParameterDirection.Input)
                    );
                }

                //cmd.Parameters.AddWithValue("@dateEntryCreated", DateTime.Now);
                parms.Add(
                    Database.SqlParm("@dateEntryCreated", SqlDbType.DateTime, DateTime.Now, ParameterDirection.Input)
                    );

                //cmd.Parameters.AddWithValue("@IsProjectManagement", _isProjectManagement);
                parms.Add(
                    Database.SqlParm("@IsProjectManagement", SqlDbType.Bit, _isProjectManagement, ParameterDirection.Input)
                    );

                //cmd.Parameters.AddWithValue("@IsHelpDesk", _isHelpDesk);
                parms.Add(
                    Database.SqlParm("@IsHelpDesk", SqlDbType.Bit, _isHelpDesk, ParameterDirection.Input)
                    );

                // SBC TODO: Release to live they no longer wanted this value  insert null for now
                // Do clean up in 1.5
                //cmd.Parameters.AddWithValue("@ITPM_ID", DBNull.Value);
                parms.Add(
                    Database.SqlParm("@ITPM_ID", SqlDbType.BigInt, DBNull.Value, ParameterDirection.Input)
                    );

                // SBC TODO: HD_ROW_ID represents the smartsheet ID for now refactor code in 1.5 to avoid confustion
                var TextBoxSmartSheetID = MBA.HttpApplication.getParameter("TextBoxSmartSheetID");

                if (Util.IsNullOrEmpty(TextBoxSmartSheetID))
                {
                    //cmd.Parameters.AddWithValue("@HD_ROW_ID", DBNull.Value);
                    parms.Add(
                    Database.SqlParm("@HD_ROW_ID", SqlDbType.BigInt, DBNull.Value, ParameterDirection.Input)
                    );
                }
                else
                {
                    //cmd.Parameters.AddWithValue("@HD_ROW_ID", TextBoxSmartSheetID);
                    parms.Add(
                    Database.SqlParm("@HD_ROW_ID", SqlDbType.BigInt, TextBoxSmartSheetID, ParameterDirection.Input)
                    );
                }

                // SBC - TODO: When we went live description was no longer desired.  
                // Remove column and refractor code in 1.5

                //cmd.Parameters.AddWithValue("@Description", DBNull.Value);

                parms.Add(
                    Database.SqlParm("@Description", SqlDbType.NVarChar, DBNull.Value, ParameterDirection.Input)
                    );

                var TextBoxReferenceDocumentFileName = MBA.HttpApplication.getParameter("TextBoxReferenceDocumentFileName");

                if (Util.IsNullOrEmpty(TextBoxReferenceDocumentFileName))
                {
                    //cmd.Parameters.AddWithValue("@FileNameReference", DBNull.Value);
                    parms.Add(
                    Database.SqlParm("@FileNameReference", SqlDbType.NVarChar, DBNull.Value, ParameterDirection.Input)
                    );
                }
                else
                {
                    //cmd.Parameters.AddWithValue("@FileNameReference", TextBoxReferenceDocumentFileName);
                    parms.Add(
                    Database.SqlParm("@FileNameReference", SqlDbType.NVarChar, TextBoxReferenceDocumentFileName, ParameterDirection.Input)
                    );
                }

                var textBoxFile = MBA.HttpApplication.getParameter("TextBoxFile");

                if (Util.IsNullOrEmpty(textBoxFile))
                {
                    //cmd.Parameters.AddWithValue("@FileComments", DBNull.Value);
                    parms.Add(
                    Database.SqlParm("@FileComments", SqlDbType.NVarChar, DBNull.Value, ParameterDirection.Input)
                    );
                }
                else
                {
                    //cmd.Parameters.AddWithValue("@FileComments", textBoxFile);
                    parms.Add(
                    Database.SqlParm("@FileComments", SqlDbType.NVarChar, textBoxFile, ParameterDirection.Input)
                    );
                }

                if (!(Util.IsNullOrEmpty(
                    MBA.HttpApplication.getParameter("CheckboxComplete")
                    ))
                )
                {
                    //cmd.Parameters.AddWithValue("@FileComplete", true);
                    parms.Add(
                    Database.SqlParm("@FileComplete", SqlDbType.Bit, true, ParameterDirection.Input)
                    );
                }
                else
                {
                    //cmd.Parameters.AddWithValue("@FileComplete", false);
                    parms.Add(
                    Database.SqlParm("@FileComplete", SqlDbType.Bit, false, ParameterDirection.Input)
                    );
                }

                //cmd.Parameters.AddWithValue("@HasMultipleClients", 0); // TODO: fix
                parms.Add(
                    Database.SqlParm("@HasMultipleClients", SqlDbType.Bit, false, ParameterDirection.Input)
                    );

                if (!(Util.IsNullOrEmpty(TextBoxStartTime)))
                {
                    //cmd.Parameters.AddWithValue("@StartEntryDateTime",
                    //    hiddenFieldDateTimeEntry + " " + TextBoxStartTime);

                    parms.Add(
                      Database.SqlParm(
                        "@StartEntryDateTime",
                        SqlDbType.DateTime,
                        DateTime.Parse(hiddenFieldDateTimeEntry + " " + TextBoxStartTime),
                        ParameterDirection.Input
                      )
                    );
                }
                else
                {
                    //cmd.Parameters.AddWithValue("@StartEntryDateTime", DBNull.Value);
                    parms.Add(
                      Database.SqlParm(
                        "@StartEntryDateTime",
                        SqlDbType.DateTime,
                        DBNull.Value,
                        ParameterDirection.Input
                      )
                    );
                }

                var TextBoxStopTime = MBA.HttpApplication.getParameter("TextBoxStopTime");

                if (!(Util.IsNullOrEmpty(TextBoxStopTime)))
                {
                    //cmd.Parameters.AddWithValue("@EndEntryDateTime",
                    //    hiddenFieldDateTimeEntry + " " + TextBoxStopTime);
                    parms.Add(
                      Database.SqlParm(
                        "@EndEntryDateTime",
                        SqlDbType.DateTime,
                        DateTime.Parse(hiddenFieldDateTimeEntry + " " + TextBoxStopTime),
                        ParameterDirection.Input
                      )
                    );
                }
                else
                {
                    //cmd.Parameters.AddWithValue("@EndEntryDateTime", DBNull.Value);
                    parms.Add(
                      Database.SqlParm(
                        "@EndEntryDateTime",
                        SqlDbType.DateTime,
                        DBNull.Value,
                        ParameterDirection.Input
                      )
                    );
                }

                parms.Add(
                      Database.SqlParm(
                        "@e_id",
                        SqlDbType.BigInt,
                        validated_empid_for_request,
                        ParameterDirection.Input
                      )
                    );

                //cmd.Parameters.Add("@Id", SqlDbType.BigInt);
                //cmd.Parameters["@Id"].Direction = ParameterDirection.Output;

                //cmd.ExecuteNonQuery();
                parms.Add(
                      Database.SqlParm(
                        "@Id",
                        SqlDbType.BigInt,
                        DBNull.Value,
                        ParameterDirection.Output
                      )
                    );

                return Database.execSproc(connSpedmon, log, "TimeKeeper_TIMESHEET_CreateTimeEntry" , parms);
            //}

        }

        public static ReturnDB deleteTimeEntry(SqlConnection connSpedmon
                                        , DetailsLog log
                                        , UserInfo uInfo, MBA.User usr, string te_id)
        {

            //var con = new SqlConnection("dbConnApp"); // dbConnApp;
            //{
            //con.Open();
            //SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_CreateTimeEntry", con);
            //cmd.CommandType = CommandType.StoredProcedure;



            //string validated_empid_for_request = "";  // TODO: we need to get the e_id from the webform, so that a manager can enter an entry for a direct report.


            //validate_empid_for_request(usr, ref validated_empid_for_request);

            var parms = new List<SqlParameter>();

            parms.Add(
                  Database.SqlParm(
                    "@Id",
                    SqlDbType.BigInt,
                    Int32.Parse(
                      MBA.HttpApplication.getParameter("te_id")
                    ),
                    ParameterDirection.Input
                  )
                );


            return Database.execSproc(connSpedmon, log, "TimeKeeper_TIMESHEET_DeleteTimeEntry", parms);

        }


        public static ReturnDB updateTimeEntry(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo, MBA.User usr)
        {

            //var con = new SqlConnection("dbConnApp"); // dbConnApp;
            //{
            //con.Open();
            //SqlCommand cmd = new SqlCommand("TimeKeeper_TIMESHEET_CreateTimeEntry", con);
            //cmd.CommandType = CommandType.StoredProcedure;



            string validated_empid_for_request = "";  // TODO: we need to get the e_id from the webform, so that a manager can enter an entry for a direct report.


            validate_empid_for_request(usr, ref validated_empid_for_request);

            var parms = new List<SqlParameter>();

            //cmd.Parameters.AddWithValue(
            //    "@timeEntryDayID",
            //    MBA.HttpApplication.getParameter("addentry_ted_id")
            //);

            parms.Add(
              Database.SqlParm("@timeEntryDayID", SqlDbType.BigInt, MBA.HttpApplication.getParameter("addentry_ted_id"), ParameterDirection.Input)
            );

            // SBC TODO: Version 1.5 rename column to smart sheet and remove IsHelp and IsProject management fields
            // along with ITPM_ID.  Rename HD_ROW_ID to SmartSheetID
            bool _isProjectManagement = false, _isHelpDesk = false;

            string _displayStartTime = MBA.HttpApplication.getParameter("TextBoxStartTime");

            //DateTime.TryParse(
            //    MBA.HttpApplication.getParameter("TextBoxStartTime"),
            //     _displayStartTime
            //);

            var hiddenFieldDateTimeEntry = MBA.HttpApplication.getParameter("addentry_date_val");

            var TextBoxStartTime = MBA.HttpApplication.getParameter("TextBoxStartTime");

            DateTime TextBoxStartTime_testOut;

            if (DateTime.TryParse(TextBoxStartTime, out TextBoxStartTime_testOut))
            {
                //cmd.Parameters.AddWithValue(
                //    "@timeOfTask",
                //    DateTime.Parse(
                //        hiddenFieldDateTimeEntry +
                //         " " +
                //         TextBoxStartTime
                //    )
                // );
                parms.Add(
                Database.SqlParm(
                    "@timeOfTask",
                    SqlDbType.DateTime,
                    DateTime.Parse(
                      hiddenFieldDateTimeEntry +
                         " " +
                         TextBoxStartTime
                    ),
                    ParameterDirection.Input
                )
             );

            }
            else
            {
                //cmd.Parameters.AddWithValue("@timeOfTask", DateTime.Parse(hiddenFieldDateTimeEntry));
                parms.Add(
                Database.SqlParm(
                    "@timeOfTask",
                    SqlDbType.DateTime,
                    DateTime.Parse(hiddenFieldDateTimeEntry),
                    ParameterDirection.Input
                )
             );

            }

            //int _numberOfMinutes = 0;
            short _hours = 0;
            short _minutes = 0;

            Int16.TryParse(MBA.HttpApplication.getParameter("TextBoxMinutes"), out _minutes);

            Int16.TryParse(MBA.HttpApplication.getParameter("TextBoxHours"), out _hours);

            if (_hours > 0)
                _minutes += (short)(_hours * 60);

            // If multiple client select numberOfMinutes will be 0
            /*
            if (calcMinutes)
            {
                if (TextBoxHours.Visible && TextBoxMinutes.Visible)
                {
                    _numberOfMinutes = Convert.ToInt32(TextBoxHours.Text) * 60 + Convert.ToInt32(TextBoxMinutes.Text);
                }
                else if (!string.IsNullOrEmpty(LiteralHours.Text) && !string.IsNullOrEmpty(LiteralMinutes.Text))
                {
                    int.TryParse(LiteralHours.Text, out _hours);
                    int.TryParse(LiteralMinutes.Text, out _minutes);
                    _numberOfMinutes = _hours * 60 + _minutes;
                }
                else
                {
                    DateTime _startTime = DateTime.Parse("1-1-2000 " + TextBoxStartTime.Text);
                    DateTime _endTime = DateTime.Parse("1-1-2000 " + TextBoxStopTime.Text);
                    TimeSpan _timeSpan = _endTime - _startTime;
                    _numberOfMinutes = _timeSpan.Hours * 60 + _timeSpan.Minutes;
                }
            }
            */



            long _timeEntryTaskID = Convert.ToInt64(
                MBA.HttpApplication.getParameter("ListBoxFavoriteTaskTimeEntry")
            );

            parms.Add(
              Database.SqlParm("@timeEntrytaskID", SqlDbType.BigInt, _timeEntryTaskID, ParameterDirection.Input)
            );

            //cmd.Parameters.AddWithValue("@numberMinutes", _numberOfMinutes);

            parms.Add(
                  Database.SqlParm("@numberMinutes", SqlDbType.BigInt, _minutes, ParameterDirection.Input)
                );

            //cmd.Parameters.AddWithValue("@timeEntrytaskID", _timeEntryTaskID);

            var orgClientID = MBA.HttpApplication.getParameter("ListBoxFavoriteClientTimeEntry");

            if (Util.IsNullOrEmpty(orgClientID) || orgClientID == "0")
            {
                //cmd.Parameters.AddWithValue("@orgClientID", DBNull.Value);
                parms.Add(
                Database.SqlParm("@orgClientID", SqlDbType.BigInt, DBNull.Value, ParameterDirection.Input)
                );
            }
            else
            {
                //cmd.Parameters.AddWithValue("@orgClientID", orgClientID);
                parms.Add(
                Database.SqlParm("@orgClientID", SqlDbType.BigInt, orgClientID, ParameterDirection.Input)
                );
            }

            var TextBoxNotes = MBA.HttpApplication.getParameter("TextBoxNotes");

            if (Util.IsNullOrEmpty(TextBoxNotes))
            {
                //cmd.Parameters.AddWithValue("@note", DBNull.Value);
                parms.Add(
                Database.SqlParm("@note", SqlDbType.NVarChar, DBNull.Value, ParameterDirection.Input)
                );
            }
            else
            {
                // This is done client side string _note = TextBoxNotes.Text.Replace("&","&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;").Replace("'", "&apos;");
                //cmd.Parameters.AddWithValue("@note", TextBoxNotes);
                parms.Add(
                Database.SqlParm("@note", SqlDbType.NVarChar, TextBoxNotes, ParameterDirection.Input)
                );
            }

            //cmd.Parameters.AddWithValue("@dateEntryCreated", DateTime.Now);
            parms.Add(
                Database.SqlParm("@dateEntryUpdated", SqlDbType.DateTime, DateTime.Now, ParameterDirection.Input)
                );

            //cmd.Parameters.AddWithValue("@IsProjectManagement", _isProjectManagement);
            parms.Add(
                Database.SqlParm("@IsProjectManagement", SqlDbType.Bit, _isProjectManagement, ParameterDirection.Input)
                );

            //cmd.Parameters.AddWithValue("@IsHelpDesk", _isHelpDesk);
            parms.Add(
                Database.SqlParm("@IsHelpDesk", SqlDbType.Bit, _isHelpDesk, ParameterDirection.Input)
                );

            // SBC TODO: Release to live they no longer wanted this value  insert null for now
            // Do clean up in 1.5
            //cmd.Parameters.AddWithValue("@ITPM_ID", DBNull.Value);
            parms.Add(
                Database.SqlParm("@ITPM_ID", SqlDbType.BigInt, DBNull.Value, ParameterDirection.Input)
                );

            // SBC TODO: HD_ROW_ID represents the smartsheet ID for now refactor code in 1.5 to avoid confustion
            var TextBoxSmartSheetID = MBA.HttpApplication.getParameter("TextBoxSmartSheetID");

            if (Util.IsNullOrEmpty(TextBoxSmartSheetID))
            {
                //cmd.Parameters.AddWithValue("@HD_ROW_ID", DBNull.Value);
                parms.Add(
                Database.SqlParm("@HD_ROW_ID", SqlDbType.BigInt, DBNull.Value, ParameterDirection.Input)
                );
            }
            else
            {
                //cmd.Parameters.AddWithValue("@HD_ROW_ID", TextBoxSmartSheetID);
                parms.Add(
                Database.SqlParm("@HD_ROW_ID", SqlDbType.BigInt, TextBoxSmartSheetID, ParameterDirection.Input)
                );
            }

            // SBC - TODO: When we went live description was no longer desired.  
            // Remove column and refractor code in 1.5

            //cmd.Parameters.AddWithValue("@Description", DBNull.Value);

            parms.Add(
                Database.SqlParm("@Description", SqlDbType.NVarChar, DBNull.Value, ParameterDirection.Input)
                );

            var TextBoxReferenceDocumentFileName = MBA.HttpApplication.getParameter("TextBoxReferenceDocumentFileName");

            if (Util.IsNullOrEmpty(TextBoxReferenceDocumentFileName))
            {
                parms.Add(
                Database.SqlParm("@FileNameReference", SqlDbType.NVarChar, DBNull.Value, ParameterDirection.Input)
                );
            }
            else
            {
                parms.Add(
                Database.SqlParm("@FileNameReference", SqlDbType.NVarChar, TextBoxReferenceDocumentFileName, ParameterDirection.Input)
                );
            }

            var textBoxFile = MBA.HttpApplication.getParameter("TextBoxFile");

            if (Util.IsNullOrEmpty(textBoxFile))
            {
                parms.Add(
                Database.SqlParm("@FileComments", SqlDbType.NVarChar, DBNull.Value, ParameterDirection.Input)
                );
            }
            else
            {
                parms.Add(
                Database.SqlParm("@FileComments", SqlDbType.NVarChar, textBoxFile, ParameterDirection.Input)
                );
            }

            if (!(Util.IsNullOrEmpty(
                MBA.HttpApplication.getParameter("CheckboxComplete")
                ))
            )
            {
                parms.Add(
                Database.SqlParm("@FileComplete", SqlDbType.Bit, true, ParameterDirection.Input)
                );
            }
            else
            {
                parms.Add(
                Database.SqlParm("@FileComplete", SqlDbType.Bit, false, ParameterDirection.Input)
                );
            }

            //cmd.Parameters.AddWithValue("@HasMultipleClients", 0); // TODO: fix
            parms.Add(
                Database.SqlParm("@HasMultipleClients", SqlDbType.Bit, false, ParameterDirection.Input)
                );

            if (!(Util.IsNullOrEmpty(TextBoxStartTime)))
            {

                parms.Add(
                  Database.SqlParm(
                    "@StartEntryDateTime",
                    SqlDbType.DateTime,
                    DateTime.Parse(hiddenFieldDateTimeEntry + " " + TextBoxStartTime),
                    ParameterDirection.Input
                  )
                );
            }
            else
            {
                //cmd.Parameters.AddWithValue("@StartEntryDateTime", DBNull.Value);
                parms.Add(
                  Database.SqlParm(
                    "@StartEntryDateTime",
                    SqlDbType.DateTime,
                    DBNull.Value,
                    ParameterDirection.Input
                  )
                );
            }

            var TextBoxStopTime = MBA.HttpApplication.getParameter("TextBoxStopTime");

            if (!(Util.IsNullOrEmpty(TextBoxStopTime)))
            {
                parms.Add(
                  Database.SqlParm(
                    "@EndEntryDateTime",
                    SqlDbType.DateTime,
                    DateTime.Parse(hiddenFieldDateTimeEntry + " " + TextBoxStopTime),
                    ParameterDirection.Input
                  )
                );
            }
            else
            {
                parms.Add(
                  Database.SqlParm(
                    "@EndEntryDateTime",
                    SqlDbType.DateTime,
                    DBNull.Value,
                    ParameterDirection.Input
                  )
                );
            }

            parms.Add(
                  Database.SqlParm(
                    "@Id",
                    SqlDbType.BigInt,
                    Int32.Parse(
                      MBA.HttpApplication.getParameter("te_id")
                    ),
                    ParameterDirection.Input
                  )
                );

                parms.Add(
                      Database.SqlParm(
                        "@e_id",
                        SqlDbType.BigInt,
                        validated_empid_for_request,
                        ParameterDirection.Input
                      )
                    );

            return Database.execSproc(connSpedmon, log, "TimeKeeper_TIMESHEET_UpdateTimeEntry", parms);

        }


        public static ReturnDB updateTimeVerification(SqlConnection connSpedmon
                                        , DetailsLog log
                                        , UserInfo uInfo, MBA.User usr)
        {

            var parms = new List<SqlParameter>();

            string e_id = MBA.HttpApplication.getParameter("e_id");

            if (usr.timeSheetUserInfo == null)
                usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(usr.userName);

            if (usr.timeSheetUserInfo.employeeid.ToString() != e_id)
                //empid = usr.timeSheetUserInfo.employeeid.ToString();
                Validate.reqInteger("", "You cannot submit time verification for somebody else's TimeKeeper.", false); // throw this error

            parms.Add(
              Database.SqlParm("@isVerified", SqlDbType.Bit, true, ParameterDirection.Input)
            );

            parms.Add(
              Database.SqlParm("@employeeID", SqlDbType.BigInt, e_id, ParameterDirection.Input)
            ); ;

            parms.Add(
              Database.SqlParm("@WhoVerifiedHours", SqlDbType.BigInt, uInfo.userid, ParameterDirection.Input)
            );

            var lastDayOfSchedule = MBA.HttpApplication.getParameter("lastDayOfSchedule");

            DateTime lastDayOfSchedule_testOut;

            if (DateTime.TryParse(lastDayOfSchedule, out lastDayOfSchedule_testOut))
            {
                parms.Add(
                Database.SqlParm(
                    "@lastDayOfSchedule",
                    SqlDbType.DateTime,
                    lastDayOfSchedule_testOut,
                    ParameterDirection.Input
                )
             );
            }

            parms.Add(
                Database.SqlParm(
                    "@dateVerified",
                    SqlDbType.DateTime,
                    DateTime.Today,
                    ParameterDirection.Input
                )
             );

            parms.Add(
              Database.SqlParm("@comments", SqlDbType.NVarChar, MBA.HttpApplication.getParameter("comments"), ParameterDirection.Input)
            );

            parms.Add(
                  Database.SqlParm(
                    "@Id",
                    SqlDbType.BigInt,
                    Int32.Parse(
                      MBA.HttpApplication.getParameter("etv_id")
                    ),
                    ParameterDirection.Input
                  )
                );

            var r_db_update = Database.execSproc(connSpedmon, log, "TimeKeeper_TIMESHEET_UpdateEmployeeTimeVerfication", parms);

            string warning_out="", warning_out_hidden="", _lastDayOfSchedule="";
            var isDelinquentDTKUser = MBA.Security.BitteTimePeople.isHourVerifyRequired(connSpedmon, log, uInfo, e_id, ref warning_out, ref warning_out_hidden, ref _lastDayOfSchedule);

            if (isDelinquentDTKUser)
            {
                r_db_update.message = "MORE_VERIFICATIONS_REQUIRED";
                string out_str
                    = @"{ ""warning_out"": """ + /* System.Web.HttpUtility.JavaScriptStringEncode( */ warning_out.Replace('"','\'')  +
                      @""", ""warning_out_hidden"": """ + /* System.Web.HttpUtility.JavaScriptStringEncode( */ warning_out_hidden +
                      @""", ""lastDayOfSchedule"": """ + /* System.Web.HttpUtility.JavaScriptStringEncode( */ _lastDayOfSchedule + @"""}";
                r_db_update.details = new string[1];
                r_db_update.details[0] = out_str;
            }
            
            return r_db_update;

            //}

        }


        public static ReturnSaveRecord saveTaskWeekHours(SqlConnection connSpedmon
                                        , DetailsLog log
                                        , UserInfo uInfo
                                        , MBA.User usr
                                        , string daysHoursInfo, string emp_id)
        {

            var parms = new List<SqlParameter>();

            validate_empid_for_request(usr, ref emp_id);

            parms.Add(
                 Database.SqlParm(
                   "@e_id",
                   SqlDbType.BigInt,
                   Int32.Parse(
                     emp_id
                   ),
                   ParameterDirection.Input
                 )
               );
            //TODO: need to figure out how to validate and edit the string in the daysHoursInfo JSON blob
            //validate_empid_for_request(usr, ref empid);


            return Entities.recordOpArbitraryDataPayload(connSpedmon, log, uInfo, "", "0", daysHoursInfo, "TimeKeeper_TaskCalendar_SAVE_TaskWeekHours", ref parms);

        }

    }
}
