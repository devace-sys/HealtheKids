using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MBA;

namespace StudentDataTracking
{
    public partial class StudentDataTrackingEdit : System.Windows.Forms.Form
    {
        public StudentDataTrackingEdit()
        {
            InitializeComponent();
        }

        private static StudentDataTrackingEdit m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance of the form
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static StudentDataTrackingEdit GetChildInstance()
        {
            //if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new StudentDataTrackingEdit();
            return m_SChildform1;
        }

        public string recID;
        private string clientID;
        private string fileTypeID;
        private string quarter;
        private string fiscalyearID;
        private string saveType;
        private DateTime today = DateTime.Now;
        private DialogResult r = new DialogResult();
        
        private string sql;

        private void StudentDataTrackingEdit_Load(object sender, EventArgs e)
        {
            // loading the comboBoxes
            sql = "select id,name from CLIENTS_VIEW(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null) where id != 112 order by name";
            WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, clientcomboBox, "Clients", "name", "id", true, "All");

            sql = "select id,type_name as name from STUDENT_DATA_FILE_TYPES_View(null,1,null) order by name";
            WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, fileTypecomboBox, "FileTypes", "name", "id", true, "All");

            if (recID != null)
            {
                //Loads the record values from the database in to corresponding controls for edit               
                DataTable dt = new DataTable();
                dt = StudentData.StudentDataTrackingView(StudentDataTracking.connSpedmon, "", "", "", "", "", recID, "", "", "");
                DataRow dr = dt.Rows[0];

                clientID     = dr["CLIENT_ID"].ToString();
                fileTypeID   = dr["FILE_TYPE_ID"].ToString();
                quarter      = dr["QUARTER"].ToString();
                fiscalyearID = dr["FISCAL_YEAR_ID"].ToString();

                clientcomboBox.SelectedValue   = clientID;
                fileTypecomboBox.SelectedValue = fileTypeID;

                if(dr["DATE_REQUESTED"] != DBNull.Value)
                   dateReqtextBox.Text   = Convert.ToDateTime(dr["DATE_REQUESTED"]).ToShortDateString();

                sql = "select file_id as ID, File_Name as name from POPULATION_FILES where upload_date >= '" + dateReqtextBox.Text + "'";
                WinFormsCommon.PopulateComboBox(StudentDataTracking.connSpedmon, sql, null, popFilecomboBox, "PopFiles", "name", "id", true, "");

                dateFollowedtextBox.Text     = dr["DATE_FOLLOWED_UP"].ToString();
                dateNotifyReptextBox.Text    = dr["DATE_NOTIFIED_REP"].ToString();
                dateReceivedtextBox.Text     = dr["DATE_Received"].ToString();
                txtFilePrepBytextBox.Text    = dr["WHO_PREPARED_TXTfile"].ToString();
                dateInFolderstextBox.Text    = dr["DATE_PUT_IN_FOLDERS"].ToString();
                dhsFileNametextBox.Text      = dr["DHS_FILENAME"].ToString();
                dateSentDHStextBox.Text      = dr["DATE_SENT_TO_DHS"].ToString();
                dateRecvdDhstextBox.Text     = dr["DATE_Received_DHS"].ToString();
                datemovCLFolderstextBox.Text = dr["DATE_MOVED_CL_FOLDERS"].ToString();
                txtMedFilesMovBytextBox.Text = dr["WHO_MOVED_TXTnMED_FILES"].ToString();
                notestextBox.Text            = dr["NOTES"].ToString();
                reqBytextBox.Text            = dr["REQUESTED_BY"].ToString();
                if (dr["POPULATION_FILE_ID"] != DBNull.Value)
                    popFilecomboBox.SelectedValue = Convert.ToInt32(dr["POPULATION_FILE_ID"]);

                clientcomboBox.Enabled   = false;
                fileTypecomboBox.Enabled = false;
                
                //fyQuartertextBox.Hide();
                saveType = "2";
                
            }
            else
            {
                saveType = "1";                
            }
            
        }

        /***************************************************************************
         * These dates can be empty if the data is not available. so I am 
         * updating the textBox values when ever the DateTimePicker value changes
         * since the datetimepicker control can not be empty.
         ***************************************************************************/
        private void follwedUpdateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            dateFollowedtextBox.Text = follwedUpdateTimePicker.Value.ToShortDateString();
        }

        private void repNotifieddateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            dateNotifyReptextBox.Text = repNotifieddateTimePicker.Value.ToShortDateString();
        }

        private void recvddateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            dateReceivedtextBox.Text = recvddateTimePicker.Value.ToShortDateString();
        }

        private void inFoldersdateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            dateInFolderstextBox.Text = inFoldersdateTimePicker.Value.ToShortDateString();
        }

        private void DHSSentdateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            dateSentDHStextBox.Text = DHSSentdateTimePicker.Value.ToShortDateString();                
        }

        private void recvdFromDHSdateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            dateRecvdDhstextBox.Text = recvdFromDHSdateTimePicker.Value.ToShortDateString();
        }

        private void clFolderMovdateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            datemovCLFolderstextBox.Text = clFolderMovdateTimePicker.Value.ToShortDateString();
        }

        private void dateReqdateTimePicker_ValueChanged(object sender, EventArgs e)
        {
            dateReqtextBox.Text = dateReqdateTimePicker.Value.ToShortDateString();
        }      

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            if (saveType == "2") this.Close();
            else
            {
                clientcomboBox.Text          = "";
                fileTypecomboBox.Text        = "";
                dateReqtextBox.Text          = "";
                popFilecomboBox.Text         = "";
                dateRecvdDhstextBox.Text     = "";
                dateSentDHStextBox.Text      = "";
                dateReceivedtextBox.Text     = "";
                dhsFileNametextBox.Text      = "";
                dateNotifyReptextBox.Text    = "";
                datemovCLFolderstextBox.Text = "";
                dateInFolderstextBox.Text    = "";
                dateFollowedtextBox.Text     = "";
                txtFilePrepBytextBox.Text    = "";
                txtMedFilesMovBytextBox.Text = "";
                notestextBox.Text            = "";
            }
            
        }

        private void savebutton_Click(object sender, EventArgs e)
        {
            //saves the record
            try
            {
                string popID;
                DataTable dt3;
                string fiscalYrID;
                r = DialogResult.Yes;
               /***************************************************************************
                * if there are no corresponding population files then the comboBox will be empty
                ***************************************************************************/
                popID = WinFormsCommon.IsNull(popFilecomboBox.SelectedValue);

                if (saveType == "1")
                {
                    clientID   = clientcomboBox.SelectedValue.ToString();
                    fileTypeID = fileTypecomboBox.SelectedValue.ToString();
                    // calculate the quarter value if we are creating a new record
                    if (dateReqdateTimePicker.Value.Month >= 7  && dateReqdateTimePicker.Value.Month <= 9)  quarter = "1";
                    if (dateReqdateTimePicker.Value.Month >= 10 && dateReqdateTimePicker.Value.Month <= 12) quarter = "2";
                    if (dateReqdateTimePicker.Value.Month >= 1  && dateReqdateTimePicker.Value.Month <= 3)  quarter = "3";
                    if (dateReqdateTimePicker.Value.Month >= 4  && dateReqdateTimePicker.Value.Month <= 6)  quarter = "4";
                    // if a request date is selected then find the fiscal year else get the current fiscal year
                    if (dateReqtextBox.Text != "")
                         fiscalYrID = WinFormsCommon.execScalar(StudentDataTracking.connSpedmon, "SELECT id FROM COMPANY_FISCAL_YEARS where '" + dateReqtextBox.Text + "' between FY_START and FY_END", null);
                    else fiscalYrID = WinFormsCommon.execScalar(StudentDataTracking.connSpedmon, "SELECT id FROM COMPANY_FISCAL_YEARS where getdate() between FY_START and FY_END", null);
                    //check if the student data tracking record already exists. 
                    dt3 = StudentData.StudentDataTrackingView(StudentDataTracking.connSpedmon, clientID, fileTypeID, quarter, fiscalYrID, "", "","0","", "1");
                    if (dt3.Rows.Count > 0 && clientID != "" && fileTypeID != "")
                        r = MessageBox.Show("Student data tracking record already exists for this client. Do you want to create another tracking record?", "Tracking record already exists", MessageBoxButtons.YesNo);                    
                }

                if (clientID != "" && fileTypeID != "" )
                {
                     if (r == DialogResult.Yes)
                     {
                        StudentData.StudentDataTrackingRecSave(StudentDataTracking.connSpedmon, clientID, fileTypeID, quarter
                                                               , dateReqtextBox.Text
                                                               , dateFollowedtextBox.Text
                                                               , dateNotifyReptextBox.Text
                                                               , dateReceivedtextBox.Text
                                                               , txtFilePrepBytextBox.Text
                                                               , dateInFolderstextBox.Text
                                                               , dateSentDHStextBox.Text
                                                               , dateRecvdDhstextBox.Text
                                                               , datemovCLFolderstextBox.Text
                                                               , dhsFileNametextBox.Text
                                                               , txtMedFilesMovBytextBox.Text
                                                               , popID
                                                               , notestextBox.Text
                                                               , StudentDataTracking.userID.ToString(), saveType, recID);
                        
                        cancelbutton_Click(sender, e);
                        MessageBox.Show("Student data tracking record saved!");
                        clientcomboBox.SelectedIndex   = 0;
                        fileTypecomboBox.SelectedIndex = 0;
                        if (saveType == "2") this.Close();
                     }
                }
                else                             
                   MessageBox.Show("Please make sure you have selected a client and file type.");                                
            }
             
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        
    }
}
