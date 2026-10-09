using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MBA;
using System.Data.SqlClient;
using System.Security.Permissions;
using System.IO;
using System.Threading;
using System.Configuration;
using System.Net.Configuration;


using NPOI.HSSF.UserModel;
using NPOI.HPSF;
using NPOI.POIFS.FileSystem;
using NPOI.HSSF.Record;
using NPOI.Util;
using NPOI.SS.Util;
using NPOI.HSSF.Model;
using NPOI.SS.UserModel;
using NPOI.HSSF.EventModel;
using NPOI.HSSF.Util;
using NPOI.SS.Formula;

namespace StudentDataTracking
{
    public partial class StudentDataTrackingView : System.Windows.Forms.Form
    {
        private string emailFrom;

        public StudentDataTrackingView(string EmailFrom)
        {
            emailFrom = EmailFrom;
            InitializeComponent();
        }

        private static StudentDataTrackingView m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance of the form
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static StudentDataTrackingView GetChildInstance(string fromEmail)
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new StudentDataTrackingView(fromEmail);
            return m_SChildform1;
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        public static StudentDataTrackingEdit editForm;
        private string recID;
        private string sql;
        private string notes;
        private string received;
        string curFY;
        private DialogResult r = new DialogResult();
        static HSSFWorkbook hssfworkbook;
        static HSSFWorkbook templateWorkbook;
        private DateTime toDay = DateTime.Now;
        private bool formLoad = false;
        DataTable dt = new DataTable();
        private bool refreshView = false;     

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            GetFileAttributes(0);
            if (e.ColumnIndex == 0)
            {
                editForm           = StudentDataTrackingEdit.GetChildInstance();
                editForm.MdiParent = this.ParentForm;
                editForm.recID     = recID;
                editForm.Show();
                editForm.BringToFront();
            }
            if (e.ColumnIndex == 1)
            {
                r = MessageBox.Show("Are you sure you want to delete this student data tracking record?", "Delete", MessageBoxButtons.OKCancel);
                if (r == DialogResult.OK)
                {
                    notes = Microsoft.VisualBasic.Interaction.InputBox("Enter reason for delete", "File Delete", "", 183, 308);

                    StudentData.StudentDataTrackingRecDelete(StudentDataTracking.connSpedmon, notes, "1", recID, StudentDataTracking.userID.ToString());

                    viewbutton_Click(sender, e);                    
                }
            }
           
        }

        private static DataGridViewRow dgvRow;
      /***************************************************************************
       * Gets the selected row values in the datagrid.
       ***************************************************************************/
        private void GetFileAttributes(int row)
        {
            if (dataGridView1.SelectedRows.Count >= 1)
            {
                dgvRow  = dataGridView1.SelectedRows[row];                
                recID   = dgvRow.Cells["id"].Value.ToString();
            }
        }

        private void StudentDataTrackingView_Activated(object sender, EventArgs e)
        {
         /***************************************************************************
          * Refreshes the datagrid when the form is activated except the first time.
          ***************************************************************************/  
            if (formLoad) viewbutton_Click(sender, e);
            formLoad = true;    
        }


        /***************************************************************************
         * Refreshes the datagrid and restores the sort order and selected rows.
         ***************************************************************************/
        private void viewbutton_Click(object sender, EventArgs e)
        {
            //To filter the Received files in the view
            
            if (rcvdradioButton.Checked) received = "1";
            else if (notRcvdradioButton.Checked) received = "2";
            else received = "0";

            WinFormsCommon.loadDataGrid(ref dataGridView1, 32, 43, delegate
            {
                return StudentData.StudentDataTrackingView(StudentDataTracking.connSpedmon,
                    WinFormsCommon.IsNull(clientcomboBox.SelectedValue),
                    WinFormsCommon.IsNull(fileTypecomboBox.SelectedValue),
                    WinFormsCommon.IsNull(quartercomboBox.SelectedItem),
                    WinFormsCommon.IsNull(fycomboBox.SelectedValue), "", "",received,
                    WinFormsCommon.IsNull(reqBycomboBox.SelectedValue),"1");
            });
            
        }

        private void StudentDataTrackingView_Load(object sender, EventArgs e)
        {
            //filling the comboBoxes
            sql = "select ID, FY_DEFINITION as name from COMPANY_FISCAL_YEARS";
            WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, fycomboBox, "FiscalYears", "name", "id", false, null);

            sql = "select id,name from CLIENTS_VIEW(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null) where id != 112 order by name";
            WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, clientcomboBox, "Clients", "name", "id", true, "All");

            sql = "select id,type_name as name from STUDENT_DATA_FILE_TYPES_View(null,1,null) order by name";
            WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, fileTypecomboBox, "FileTypes", "name", "id", true, "All");

            sql = "select distinct RequestedUserID as id, REQUESTED_BY as name from STUDENT_DATA_TRACKING_VIEW(null,null,null,null,null,null,null,null) order by name";
            WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, reqBycomboBox, "Requested", "name", "id", true, "All");

            curFY                        = StudentDataTracking.fiscalYrID;
            fycomboBox.SelectedValue     = Convert.ToInt32(curFY);
            quartercomboBox.SelectedItem = StudentDataTracking.currentQuarter;
            viewbutton_Click(sender, e);
        } 

        static void InitializeWorkbook()
        {
            hssfworkbook = new HSSFWorkbook();
            //create a entry of DocumentSummaryInformation
            DocumentSummaryInformation dsi = PropertySetFactory.CreateDocumentSummaryInformation();
            dsi.Company = "NPOI Team";
            hssfworkbook.DocumentSummaryInformation = dsi;
            //create a entry of SummaryInformation
            SummaryInformation si = PropertySetFactory.CreateSummaryInformation();
            si.Subject = "NPOI SDK Example";
            hssfworkbook.SummaryInformation = si;
        }

        private void excelbutton_Click(object sender, EventArgs e)
        {
            if (fycomboBox.Text == "" || quartercomboBox.Text == "")
                MessageBox.Show("Please select the fiscal yesr and quarter!");
            else
            {
                dt = StudentData.StudentDataTrackingView(StudentDataTracking.connSpedmon,
                    WinFormsCommon.IsNull(clientcomboBox.SelectedValue),
                    WinFormsCommon.IsNull(fileTypecomboBox.SelectedValue),
                    WinFormsCommon.IsNull(quartercomboBox.SelectedItem),
                    WinFormsCommon.IsNull(fycomboBox.SelectedValue), "", "", received,
                    WinFormsCommon.IsNull(reqBycomboBox.SelectedValue), "1");
                try
                {
                    InitializeWorkbook();

                    FileStream fs   = new System.IO.FileStream(@"StudentDataTrackingTemplate.xls",
                                                            System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.Read);
                    HSSFSheet sheet = (HSSFSheet)hssfworkbook.CreateSheet("test");

                    // Load the template into a NPOI workbook  
                    templateWorkbook = new HSSFWorkbook(fs, true);

                    // Load the sheet1 you are going to use as a template into NPOI  
                    sheet = (HSSFSheet)templateWorkbook.GetSheet("test");

                    int i = 0;
                    int k = 2;
                    double d;
                    DateTime d2;
                    NPOI.SS.UserModel.IRow row;

                    /*------------------------------------------------------------------
                     * Go through each row in the data reader and copy them to the sheet
                     * Convert the string values from datareader into numeric values.
                     * This is needed to apply conditional formating and formulas.
                     *------------------------------------------------------------------*/
                    if (dt.Rows.Count > 0)
                    {
                        foreach (DataRow row1 in dt.Rows)
                        {
                            row = sheet.CreateRow(k);
                            //row = sheet.CreateRow(k);                        
                            for (i = 0; i < 28; i++)
                            {

                                NPOI.SS.UserModel.ICell cell = row.CreateCell(i);//row.CreateCell(i);

                                if (row1[i] == DBNull.Value) continue;
                                else
                                {
                                    if (double.TryParse(row1[i].ToString(), out d))
                                        cell.SetCellValue(d);
                                    else if (DateTime.TryParse(row1[i].ToString(), out d2))
                                        cell.SetCellValue(d2.ToShortDateString());
                                    else cell.SetCellValue(row1[i].ToString());
                                }
                            }
                            k = k + 1;
                        }
                    }

                    sheet.DisplayZeros              = false;
                    sheet.HorizontallyCenter        = true;
                    sheet.ForceFormulaRecalculation = true;

                    WriteToFile("StudentDataTracking " + fycomboBox.Text + " Q#" + quartercomboBox.Text, true);
                    fs.Close();

                    dt.Dispose();
                }
                catch (Exception ex)
                { /*-------------------------------
                     * Exit with errors
                     *------------------------------*/
                    Database.closeConn(StudentDataTracking.connSpedmon);
                    MessageBox.Show(ex.Message);
                }
            }            
        }

        static void WriteToFile(string name, bool template)
        {
           /******************************************************************
            * Opens a savefile dialog to save the excel in a desired location
            ******************************************************************/

            SaveFileDialog saveFileDialog1 = new SaveFileDialog();
            saveFileDialog1.Filter = "Microsoft Office Excel Workbook |*.xls";
            saveFileDialog1.DefaultExt = "xls";
            saveFileDialog1.Title = "Save a File";
            saveFileDialog1.FileName = name;
            try
            {
                if (saveFileDialog1.ShowDialog() == DialogResult.OK)
                {
                    System.IO.FileStream fs = (System.IO.FileStream)saveFileDialog1.OpenFile();
                    if (template)
                        templateWorkbook.Write(fs);
                    else
                        hssfworkbook.Write(fs);
                    fs.Close();
                }
                else
                    saveFileDialog1.Dispose();
            }
            catch
            {
                MessageBox.Show("A file with the name " + name + " is already open.");
            }
        }

        private void followUpEmailbutton_Click(object sender, EventArgs e)
        {
          /******************************************************************
           * Sends two week followup email to client contact. only sends the 
           * follow up email if date requested is not blank and date followedup
           * is blank
           ******************************************************************/

            List<string> attachments = new List<string>();
            attachments.Add("Student Data Format (SpEd) (2).doc");
            foreach (DataGridViewRow row in dataGridView1.Rows)                            
            {
               
               object value = row.Cells["FollowUpEmail"].Value;
               r = DialogResult.Yes;
               if (value != null && value.ToString() == "True")
               {
                   string dateReq    = row.Cells["DATE_REQUESTED"].Value.ToString();
                   string clientName = row.Cells["District_Full_ Name"].Value.ToString();
                   string fileType   = row.Cells["DATA_TYPE"].Value.ToString();
                   string datefollowUp = row.Cells["DATE_FOLLOWED_UP"].Value.ToString();
                   //check if date requested is filled, if not dont send the follow-up email
                   if (dateReq == "")
                   {
                       MessageBox.Show("Follow-up email is not sent. Date requested field is empty for the client:"+clientName+" fileType:"+fileType);
                       row.Cells["FollowUpEmail"].Value = "False";
                       continue;
                   }
                   else
                       //check if date followed-up is filled, if filled do not send the follow-up email
                       if (datefollowUp != "")
                       {
                           MessageBox.Show("Follow-up email is not sent. Two week follow-up email is already sent to the client:" + clientName + " fileType:" + fileType);
                           row.Cells["FollowUpEmail"].Value = "False";
                           continue;
                       }
                   else
                     if (dateReq != "" && Convert.ToDateTime(dateReq).AddDays(14) > toDay)
                         r = MessageBox.Show("Student data requested for the client "+ clientName+" filetype - "+ fileType + 
                                             " is less than two weeks ago on "+dateReq+". Do you want to send the follow-up email anyway?", 
                                             "Follow-up?", MessageBoxButtons.YesNo);
                   
                   if (r == DialogResult.Yes)
                   {                       
                       string contactEmail     = row.Cells["CONTACT EMAIL"].Value.ToString();
                       string contactFirstName = row.Cells["CONTACT_FIRST_NAME"].Value.ToString();
                       //convert name to tittle case
                       contactFirstName        = System.Threading.Thread.CurrentThread.CurrentCulture.TextInfo.ToTitleCase(contactFirstName);
                       string quarter          = row.Cells["QUARTER"].Value.ToString();
                       string fy               = row.Cells["FISCAL_YEAR"].Value.ToString();
                       string recID            = row.Cells["id"].Value.ToString();
                       string repEmail         = row.Cells["CLIENT_REP_EMAIL"].Value.ToString();


                       string body;

                       attachments = ConfigurationManager.AppSettings["emailFileAttachments"].ToString().Split(',').ToList<string>();

                       string fileBodyName = ConfigurationManager.AppSettings["StudentDataTrackingEmailReminder"].ToString();

                       string emailBody;

                       using (StreamReader sr = new StreamReader(fileBodyName))
                       { emailBody = sr.ReadToEnd(); }


                       string contactName = char.ToUpper(contactFirstName[0]) + contactFirstName.Substring(1);
                       string replyAddress = ConfigurationManager.AppSettings["appEmailFrom"].ToString();
                       string origRequestDate = Convert.ToDateTime(dateReq).ToShortDateString();

                       emailBody = string.Format(emailBody, contactName, clientName, replyAddress, origRequestDate);

                       emailBody = emailBody.Replace("\r\n", "");

                       body = emailBody;
                                     
                       string[] to = WinFormsCommon.splitString(contactEmail);
                       string[] cc = WinFormsCommon.splitString(StudentDataTracking.emailCc + "," + repEmail);                                                                                            

                       try
                       {
                           WinFormsCommon.emailFile(StudentDataTracking.smtp, emailFrom, to, cc, "Practi-Cal Student Data Request " + fy + "[Q#" + quarter + " " + clientName + "]", body, attachments);
                           sql = "update STUDENT_DATA_TRACKING set DATE_FOLLOWED_UP = @date where id = @id";
                           List<SqlParameter> parms = new List<SqlParameter>();
                           parms.Add(Database.SqlParm("@date", SqlDbType.DateTime, toDay, ParameterDirection.Input, 7000));
                           parms.Add(Database.SqlParm("@id",   SqlDbType.BigInt,   recID, ParameterDirection.Input, 7000));
                           Database.execQuery(StudentDataTracking.connSpedmon, null, sql, false, parms);
                           refreshView = true;
                          
                       }
                       catch (Exception ex) { MessageBox.Show(ex.Message); }
                   }
               }
               row.Cells["FollowUpEmail"].Value = "False";
            }
            if (refreshView)
            {
                viewbutton_Click(sender, e);
                MessageBox.Show("Finished sending followup emails.", "Follow-up Emails");
                refreshView = false;
            }
        }

        private void followUpEmail2button_Click(object sender, EventArgs e)
        {
            /******************************************************************
             * Sends four week followup email to client reps. only sends the 
             * follow up email if date requested and date followedup is not blank 
             * and date notified rep is blank.
             ******************************************************************/
            foreach (DataGridViewRow row in dataGridView1.Rows)            
            {
                object value = row.Cells["FollowUpEmail"].Value;
                r = DialogResult.Yes;
                if (value != null && value.ToString() == "True")
                {
                    string dateReq       = row.Cells["DATE_REQUESTED"].Value.ToString();
                    string clientName    = row.Cells["District_Full_ Name"].Value.ToString();
                    string fileType      = row.Cells["DATA_TYPE"].Value.ToString();
                    string datefollowUp  = row.Cells["DATE_FOLLOWED_UP"].Value.ToString();
                    string dateNotifyRep = row.Cells["DATE_NOTIFIED_REP"].Value.ToString();

                    //check if date requested is filled, if not dont send the follow-up email
                    if (dateReq == "")
                    {
                        MessageBox.Show("Follow-up email is not sent. Date requested field is empty for the client:" + clientName + " fileType:" + fileType);
                        row.Cells["FollowUpEmail"].Value = "False";
                        continue;
                    }
                    else
                        //check if date followed-up is already filled, if yes don't send the follow-up email
                        if (datefollowUp == "")
                        {
                            MessageBox.Show("Follow-up email is not sent. Date followed up field is empty for the client:" + clientName + " fileType:" + fileType);
                            row.Cells["FollowUpEmail"].Value = "False";
                            continue;
                        }
                        else
                            //check if date notified to rep is filled, if filled dont send the follow-up email
                            if (dateNotifyRep != "")
                            {
                                MessageBox.Show("Follow-up email with Rep is already sent for the client:" + clientName + " fileType:" + fileType);
                                row.Cells["FollowUpEmail"].Value = "False";
                                continue;
                            }
                            else
                               if (dateReq != "" && Convert.ToDateTime(dateReq).AddDays(28) > toDay)
                                  r = MessageBox.Show("Student data requested from the client " + clientName + " filetype - " + fileType +
                                                  " is less than four weeks ago on " + dateReq + ". Do you want to send the follow-up email anyway?",
                                                  "Follow-up?", MessageBoxButtons.YesNo);

                    if (r == DialogResult.Yes)
                    {
                        string repEmail     = row.Cells["CLIENT_REP_EMAIL"].Value.ToString();
                        string repFirstName = row.Cells["CLIENT_REP_FIRST_NAME"].Value.ToString();
                        //convert name to tittle case
                        repFirstName        = System.Threading.Thread.CurrentThread.CurrentCulture.TextInfo.ToTitleCase(repFirstName);
                        string quarter      = row.Cells["QUARTER"].Value.ToString();
                        string fy           = row.Cells["FISCAL_YEAR"].Value.ToString();
                        string recID        = row.Cells["id"].Value.ToString();

                        string body = "Hi " + repFirstName + @",<br/><br/>" + "  We haven’t received any data for " + clientName + " yet.  The last correspondence to/from the client was on " +
                                      Convert.ToDateTime(datefollowUp).ToShortDateString() + ".  Would it be possible to check with client regarding the student data?" + @"<br/><br/>" +
                                      "Thank you," + @"<br/><br/>" +
                                      "it@practi-cal.com" + @"<br/>" +
                                      "School Business Services of California, Inc." + @"<br/>" +
                                      "1275 Halyard Drive Suite 150" + @"<br/>" +
                                      "West Sacramento, CA 95691" + @"<br/>" +
                                      "Phone: (877) 957-7272" + @"<br/>" +
                                      "Fax: (916) 375-1735" + @"<br/><br/>";
                                      
                        string[] to = WinFormsCommon.splitString(repEmail);
                        string[] cc = WinFormsCommon.splitString(StudentDataTracking.emailCc);
                       
                        try
                        {
                            WinFormsCommon.emailFile(StudentDataTracking.smtp, emailFrom, to, cc, "Practi-Cal Student Data Request " + fy + "[Q#" + quarter + " " + clientName + "]", body, null);
                            sql = "update STUDENT_DATA_TRACKING set DATE_NOTIFIED_REP = @date where id = @id";
                            List<SqlParameter> parms = new List<SqlParameter>();
                            parms.Add(Database.SqlParm("@date", SqlDbType.DateTime, toDay, ParameterDirection.Input, 7000));
                            parms.Add(Database.SqlParm("@id",   SqlDbType.BigInt,   recID, ParameterDirection.Input, 7000));
                            Database.execQuery(StudentDataTracking.connSpedmon, null, sql, false, parms);
                            refreshView = true;
                        }
                        catch (Exception ex) { MessageBox.Show(ex.Message); }
                    }
                }
                row.Cells["FollowUpEmail"].Value = "False";
            }
            if (refreshView)
            {
                viewbutton_Click(sender, e);
                MessageBox.Show("Finished sending followup emails.", "Follow-up Emails");
                refreshView = false;
            }
        }

        private void quartercomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (formLoad)
            {
                viewbutton_Click(sender, e);
                if (StudentDataTracking.currentQuarter != quartercomboBox.SelectedItem.ToString() || StudentDataTracking.fiscalYrID != fycomboBox.SelectedValue.ToString())
                {
                    //Disable followup buttons if the selected quarter is not current quarter to avoid sending unwanted emails
                    followUpEmail2button.Enabled = false;
                    followUpEmailbutton.Enabled  = false;
                }
                else
                {
                    followUpEmail2button.Enabled = true;
                    followUpEmailbutton.Enabled  = true;
                }
            }
        }

        private void fycomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (formLoad)
            {
                viewbutton_Click(sender, e);
                if (StudentDataTracking.currentQuarter != quartercomboBox.SelectedItem.ToString() || StudentDataTracking.fiscalYrID != fycomboBox.SelectedValue.ToString())
                {
                    //Disable followup buttons if the selected fiscal year is not current fiscal year to avoid sending unwanted emails
                    followUpEmail2button.Enabled = false;
                    followUpEmailbutton.Enabled  = false;
                }
                else
                {
                    followUpEmail2button.Enabled = true;
                    followUpEmailbutton.Enabled  = true;
                }
            }
        }       

        private void rcvdradioButton_CheckedChanged(object sender, EventArgs e)
        {
            viewbutton_Click(sender, e);
        }

        private void notRcvdradioButton_CheckedChanged(object sender, EventArgs e)
        {
            viewbutton_Click(sender, e);
        }

        private void allradioButton_CheckedChanged(object sender, EventArgs e)
        {
            viewbutton_Click(sender, e);
        }      

    }

}
