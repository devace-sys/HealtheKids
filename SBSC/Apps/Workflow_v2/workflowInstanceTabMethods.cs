using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MBA;
using Spedmon;
using System.Data;

using System.Data.SqlClient;

namespace Workflow_v2
{       /* Placeholder methods for now (cough cough TODO cough cough)*/
    /* SQL calls and data manip should take place here, referencing UI elements
     * pulled in using arguments */


    public class SqlAsyncArgObj
    {
        public string dbConnStr { private set; get; }
        public string sqlQueryRpt { private set; get; }
        public System.Windows.Forms.DataGridView rptDisplayView { private set; get; }

        public SqlAsyncArgObj(string dbconn, string sqlQuery, System.Windows.Forms.DataGridView dispView)
        {
            dbConnStr = dbconn;
            sqlQueryRpt = sqlQuery;
            rptDisplayView = dispView;
        }

    }

    static public class SqlRptTabMthd
    {
        static public void getReportDropdownData(string ConnSpedmonStr, System.Windows.Forms.ComboBox cb)
        {
            using (SqlConnection conn = new SqlConnection(ConnSpedmonStr))
            {
                using (SqlCommand rptView = new SqlCommand("WORKFLOW_REPORTS_VIEW", conn))
                {
                    rptView.CommandType = CommandType.StoredProcedure;

                    rptView.Parameters.Add(Database.SqlParm("@reportNum", SqlDbType.BigInt, null, ParameterDirection.Input));

                    rptView.Connection.Open();

                    WinFormsCommon.depPopulateComboBox(rptView, cb, "Reports", "repName", "repValue", true, "Select A Report");
                }
            }
        }

        static public System.Data.DataTable runSelectedReport(string ConnSpedmonStr, string sqlRptSelected)
        {
            using (SqlConnection conn = new SqlConnection(ConnSpedmonStr))
            {
                using (SqlCommand rptView = new SqlCommand("WORKFLOW_REPORTS_VIEW", conn))
                {
                    rptView.CommandType = CommandType.StoredProcedure;

                    rptView.Parameters.Add(Database.SqlParm("@reportNum", SqlDbType.BigInt, sqlRptSelected, ParameterDirection.Input));

                    rptView.Connection.Open();

                    return WinFormsCommon.tableFromSqlExecQuery(rptView);

                }
            }
        }
    }

  
}