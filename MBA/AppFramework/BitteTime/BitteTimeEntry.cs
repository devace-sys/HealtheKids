using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;

// SBC Added for TimeKeeper
namespace MBA.BitteTime
{
     public class BitteTimeEntry
     {
        public long EmployeeId;
        public string FirstName;
		public string LastName;
		public string Oranization;
		public long OrganizationID;
		public string Position;
		public DateTime StartDate;
		public DateTime? EndDate;
		public string PayStatus;
		public double HourlyPay;
		public string EligibleHolidayPay;

		public static BitteTimeEntry getTimeEntryPersonDetail(SqlConnection connTimeSheet
                                               , DetailsLog log
                                               , long employeeID)
		{
		       BitteTimeEntry _bitteTimeEntry = new BitteTimeEntry();
               List<SqlParameter> _parms = new List<SqlParameter>();

               _parms.Add(Database.SqlParm("@EmployeeId", SqlDbType.BigInt, employeeID, ParameterDirection.Input));


               try
               {
                    ReturnDB rd = Database.execQuery(connTimeSheet, log, "TimeKeeper_TIMESHEET_GetPresonInfo", true, _parms);

                    if (!rd.hasRecords)
                    {
                         return null;
                    }
                    _bitteTimeEntry.EmployeeId = employeeID;
                    foreach(Record _record in rd.records)
                    {
                         foreach(Field _field in _record.fields)
                         {
                              switch(_field.name)
                              {
                                   case "FirstName":
                                        _bitteTimeEntry.FirstName = Convert.ToString(_field.value);
                                        break;
                                   case "LastName":
                                        _bitteTimeEntry.LastName = Convert.ToString(_field.value);
                                        break;
                                   case "Oranization":
                                        _bitteTimeEntry.Oranization = Convert.ToString(_field.value);
                                        break;
                                   case "OrganizationID":
                                        _bitteTimeEntry.OrganizationID = Convert.ToInt64(_field.value);
                                        break;     
                                   case "Position":
                                        _bitteTimeEntry.Position = Convert.ToString(_field.value);
                                        break;
                                   case "startDate":
                                        _bitteTimeEntry.StartDate = Convert.ToDateTime(_field.value);
                                        break;
                                   case "endDate":
                                        if (_field.value != null)
                                        {
                                             try
                                             {
                                                  _bitteTimeEntry.EndDate = Convert.ToDateTime(_field.value);
                                             }
                                             catch(Exception e)
                                             {
                                                  _bitteTimeEntry.EndDate = null;
                                             }
                                        }
                                        break;
                                   case "PayStatus":
                                        _bitteTimeEntry.PayStatus = Convert.ToString(_field.value);
                                        break;
                                   case "HourlyPay":
                                        _bitteTimeEntry.HourlyPay = Convert.ToDouble(_field.value);
                                        break;
                                   case "EligibleHolidayPay":
                                        _bitteTimeEntry.EligibleHolidayPay = Convert.ToString(_field.value);
                                        break;
                              }
                         }
                    }
               }
               catch (Exception e)
               {
               }

               return _bitteTimeEntry;
		     
		}

     }
}
