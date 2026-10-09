using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

// SBC Added for TimeKeeper
namespace MBA.Web
{
    public class TimeSheetSession
    {
        public long EmployeeId { get; set; }
        public long RoleId { get; set; }

        public static TimeSheetSession Current
        {
            get
            {
                TimeSheetSession _session = (TimeSheetSession)HttpContext.Current.Session["__TimeSheetSession__"];
                if (_session == null)
                {
                    _session = new TimeSheetSession();
                    HttpContext.Current.Session["__TimeSheetSession__"] = _session;
                }
                return _session;
            }
        }
    }
}
