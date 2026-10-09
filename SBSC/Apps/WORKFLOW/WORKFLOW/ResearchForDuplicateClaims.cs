using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Diagnostics;
using System.IO;
using System.Threading;

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace WORKFLOW
{
    public partial class ResearchForDuplicateClaims : Form
    {
        public ResearchForDuplicateClaims()
        {
            InitializeComponent();
        }

        private static ResearchForDuplicateClaims m_SChildform1;
        /***************************************************************************
         * if not created yet or disposed, Create an instance
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static ResearchForDuplicateClaims GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new ResearchForDuplicateClaims();
            return m_SChildform1;
        }

        delegate void searchDelegate(string filename);
        delegate void StringParameterDelegate(string value);

        readonly object stateLock = new object();

        Random rng = new Random();

        private string fname;
        private string fileLocation;

        /***************************************************************************
         * Clears the file name textbox
         ***************************************************************************/
        private void clearbutton_Click(object sender, EventArgs e)
        {
            fileNametextBox.Text = "";
            searchbutton_Click(sender, e);
            statusIndicator.Hide();
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }


        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            if (dataGridView1.SelectedRows.Count != 0)
                if (e.ColumnIndex == 0)
                    openFile();
        }

        /***************************************************************************
         * Gets the selected Input Batch record properties in the datagrid.
         ***************************************************************************/
        private void GetFileAttributes(int row)
        {
            if (dataGridView1.SelectedRows.Count >= 1)
            {
                DataGridViewRow dgvRow = dataGridView1.SelectedRows[row];
                fname = dgvRow.Cells["filename"].Value.ToString();
                fileLocation = dgvRow.Cells["filepath"].Value.ToString();

            }
        }


        /***************************************************************************
         * opens the selected file in the datagrid.
         ***************************************************************************/
        private void openFile()
        {
            /***************************************************************************
             * saves a copy in the users temp folder and opens it from there to avoid corrupting 
             * the original file. All the files in the temp folder are deleted when the user exits the app.
             ***************************************************************************/
            try
            {
                if (dt.Rows.Count > 0 && dataGridView1.SelectedRows.Count == 1)
                {
                    GetFileAttributes(0);
                    if (!Directory.Exists(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + SBSCParent.userName + @"\Temp\"))
                        System.IO.Directory.CreateDirectory(SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + SBSCParent.userName + @"\Temp\");

                    string tempFolder = SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER + SBSCParent.userName + @"\Temp\";
                    System.IO.File.Copy(fileLocation, tempFolder + fname, true);
                    Process.Start(tempFolder + fname);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        private List<string> searchedFilesSoFar = new List<string>();
        private DataTable dt = new DataTable();
        private string searchDirectory;
        private void SearchFile()
        {
            string searchFile = fileNametextBox.Text.ToLower().Trim();
            if (searchFile != "")
            {

                UpdateStatus("Searching file(s). Please wait!");

                FileInfo[] fi;

                if (Directory.Exists(searchDirectory))
                {
                    DirectoryInfo drInfo = new DirectoryInfo(searchDirectory);
                    fi = drInfo.GetFiles("*.*", SearchOption.AllDirectories);


                    foreach (FileInfo f in fi)
                    {
                        if (!f.FullName.Contains("SafetyCopies") && f.Name.ToLower().Contains(searchFile))
                        {
                            DataRow dr = dt.NewRow();
                            dr["filename"] = f.Name;
                            dr["filepath"] = f.FullName;
                            dt.Rows.Add(dr);
                            searchedFilesSoFar.Add(f.Name);
                        }
                    }

                }
                UpdateStatus("Finished searching!");

            }

        }

        private void searchbutton_Click(object sender, EventArgs e)
        {
            statusIndicator.Show();
            /***************************************************************************
             * Searches the file system for the given file
             ***************************************************************************/
            UpdateStatus("Searching please wait");

            if (finishedFilesradioButton.Checked)
                searchDirectory = SBSCParent.basePath + FilePaths.PATH_FinishedClaims;
            else
                searchDirectory = SBSCParent.basePath + FilePaths.PATH_STAFF_FOLDER;

            Thread t = new Thread(delegate ()
            {
                SearchFile();
            });

            t.Start();
            dataGridView1.DataSource = dt;
            dt.Clear();
        }



        void UpdateStatus(string value)
        {
            if (InvokeRequired)
            {
                // We're not in the UI thread, so we need to call BeginInvoke
                BeginInvoke(new StringParameterDelegate(UpdateStatus), new object[] { value });
                return;
            }
            // Must be on the UI thread if we've got this far
            statusIndicator.Text = value;
        }

        private void FinishedWorkView_Load(object sender, EventArgs e)
        {
            DataColumn dc1 = new DataColumn("filename");
            DataColumn dc2 = new DataColumn("filepath"); ;
            dt.Columns.Add(dc1);
            dt.Columns.Add(dc2);
            statusIndicator.Hide();
            finishedFilesradioButton.Checked = true;
        }

    }
}
