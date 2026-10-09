using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using MBA.BitteTime;
using MBA.Web;
using System.Text;

namespace Spedmon
{
     public class EmployeeTimeEntryServiceRecordsPerMinuteViewPage : WebUI
     {
          public EmployeeTimeEntryServiceRecordsPerMinuteViewPage()
               : base("timekeepersvcrecspermin", TimekeeperAccountabilityRpt.SEL_LABEL_PER_MIN_RPT, "", "", Constants.ROLE_SBS_ALL
                                                                                                                   // THIS IS THE ROLE used for PayrollReport1.aspx;
                                                                                                                   // following that pattern
                 )
          { 
          }
        protected void Page_Load(object sender, EventArgs e)
        {
        
        }  
    }
}
