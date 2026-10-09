using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using MBA;
using Spedmon;
using System.Data.SqlClient;

using DataGridViewAutoFilter;

namespace Workflow_v2
{
    public partial class SqlRptPanel : UserControl1
    {
        string ConnSpedmonStr;

        int dgvColumnFilterBuffer = 0;


        public SqlRptPanel(string SqlConnString)
        {
            InitializeComponent();
            this.Dock = DockStyle.Fill;
            ConnSpedmonStr = SqlConnString;

            getReportDropdownData(ConnSpedmonStr,reportSelectionPanelComboBox);

        }

        public void refresh()
        {
            this.Refresh();
            getReportDropdownData(ConnSpedmonStr, reportSelectionPanelComboBox);



        }

        public void getReportDropdownData(string ConnSpedmonStr, System.Windows.Forms.ComboBox cb)
        {  
            using (SqlConnection conn = new SqlConnection(ConnSpedmonStr))
            {
                    List<SqlParameter> rptNum = new List<SqlParameter>();

                    rptNum.Add(Database.SqlParm("@reportNum", SqlDbType.BigInt, null, ParameterDirection.Input));

                    string sql = "WORKFLOW_REPORTS_VIEW";

                    conn.Open();

                    WinFormsCommon.PopulateComboBox(conn, sql, true, rptNum, cb, "Reports", "repName","repValue",true, "Select A Report");
            }
        }

        public System.Data.DataTable runSelectedReport(string ConnSpedmonStr, string sqlRptSelected)
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

        private void btnSelectedReportRunPanel_Click(object sender, EventArgs e)
        {
            /* Todo: Timer and spinner while this runs? */
            bkgrndRptSqlProgressPanel.Visible = true;

            reportSelectionPanelComboBox.Enabled = false;
            btnSelectedReportRunPanel.Enabled = false;

            while (sqlRptPanelBkrndWrkr.IsBusy == true)
            {
                if (!sqlRptPanelBkrndWrkr.CancellationPending)
                    sqlRptPanelBkrndWrkr.CancelAsync();

            }
            SqlAsyncArgObj asyncArgs = new SqlAsyncArgObj(ConnSpedmonStr, reportSelectionPanelComboBox.SelectedValue.ToString(), sqlReportDGVPanel);
            sqlRptPanelBkrndWrkr.RunWorkerAsync(asyncArgs);
            

        }

        private void sqlRptTabBkrndWrkr_DoWork(object sender, DoWorkEventArgs e)
        {
            BackgroundWorker bw = sender as BackgroundWorker;

            SqlAsyncArgObj asyncArgs = e.Argument as SqlAsyncArgObj;
            e.Result = SqlRptTabMthd.runSelectedReport(asyncArgs.dbConnStr, asyncArgs.sqlQueryRpt);

            if (bw.CancellationPending)
                e.Cancel = true;

        }

        private void sqlRptTabBkrndWrkr_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            BackgroundWorker bw = sender as BackgroundWorker;
            bkgrndRptSqlProgressPanel.Visible = false;
            reportSelectionPanelComboBox.Enabled = true;
            btnSelectedReportRunPanel.Enabled = true;

            if (!e.Cancelled)
            {
                sqlReportDGVPanel.DataSource = null;
                
                DataTable queryResults = e.Result as DataTable;

                sqlReportDGVPanel.DataSource = new BindingSource(queryResults, null);
                sqlReportDGVPanel_BindingContextChanged(sender, e);

            }
        }

        private void sqlReportDGVPanel_BindingContextChanged(object sender, EventArgs e)
        {
            if (sqlReportDGVPanel.DataSource == null) return;

            foreach (DataGridViewColumn col in sqlReportDGVPanel.Columns)
            {
                col.HeaderCell = new
                    DataGridViewAutoFilterColumnHeaderCell(col.HeaderCell);
            }
            sqlReportDGVPanel.AutoResizeColumns();

        }

        private void SqlRptPanel_Load(object sender, EventArgs e)
        {
            
            
        }
    }
}
