using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Security.Permissions;
using System.IO;
using System.Diagnostics;
using System.Drawing.Imaging;
using System.Text.RegularExpressions;

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.xml;
using iTextSharp.text.xml.xmp;

using MBA;

namespace WORKFLOW
{
    public partial class SplitFile : System.Windows.Forms.Form
    {
        public SplitFile()
        {
            InitializeComponent();
        }

        private static SplitFile m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static SplitFile GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new SplitFile();
            return m_SChildform1;
        }
      /***************************************************************************
       * global varaibles to get input batch details
       ***************************************************************************/
        public int    filestatus;
        public string fname;
        public string fileLocation;
        public string fileLoc;
        public string clientID;
        public string clientShortName;
        public string clientCDS;
        public string dateSent;
        public string dateRecieved;
        public string recID;
        public string assignedTo;
        public string assignedID;
        public string oldDOS;
        public string estTime;
        public string workType;
        public string priority;
        public string difficulty;
       

      /***************************************************************************
       * Local varaibles  
       ***************************************************************************/
        #region
      /***************************************************************************
       * list varaibles to store page numbers included in each file that is being split 
       ***************************************************************************/
        private List<int> f1list  = new List<int> { };
        private List<int> f2list  = new List<int> { };
        private List<int> f3list  = new List<int> { };
        private List<int> f4list  = new List<int> { };
        private List<int> f5list  = new List<int> { };
        private List<int> f6list  = new List<int> { };
        private List<int> f7list  = new List<int> { };
        private List<int> f8list  = new List<int> { };
        private List<int> f9list  = new List<int> { };
        private List<int> f10list = new List<int> { };
        private List<int> removePageslist = new List<int> { };

      /***************************************************************************
       * varibles to store file paths to save each file that is being split
       ***************************************************************************/
        private string f1path;
        private string f2path;
        private string f3path;
        private string f4path;
        private string f5path;
        private string f6path;
        private string f7path;
        private string f8path;
        private string f9path;
        private string f10path;
      /***************************************************************************
       * variables to store the name of Qform or NBSlip forms that are filled for each file.
       ***************************************************************************/
        private string f1Form  = "";
        private string f2Form  = "";
        private string f3Form  = "";
        private string f4Form  = "";
        private string f5Form  = "";
        private string f6Form  = "";
        private string f7Form  = "";
        private string f8Form  = "";
        private string f9Form  = "";
        private string f10Form = "";

        private int len;
        private bool cancelfile  = false;
        private int numQforms    = 1;
        private int numNBslips   = 1;
        private int numCIS       = 1;
        private int numGoodFiles = 1;
        #endregion 


        private void cancelbutton_Click(object sender, EventArgs e)
        {
            SBSCParent.refreshIBView = false;
            this.Close();
        }

        private void SplitFile_Load(object sender, EventArgs e)
        {
            filenamelabel.Text = filenamelabel.Text + fname;
            
            pageslistBox.Hide();
            selectbutton.Hide();
            PdfReader reader = new PdfReader(fileLocation + fname);
            int pages = reader.NumberOfPages;
            for (int i = 1; i <= pages; i++)
                pageslistBox.Items.Add(i);

            /***************************************************************************
             * If the file is being spit by a input staff, do not give the option to
             * remove pages from original file and do not allow to split as good file.
             ***************************************************************************/
            if (SBSCParent.isInputStaff)
            {
                remvPageslabel.Hide();
                f1checkBox.Hide();
                f2checkBox.Hide();
                f3checkBox.Hide();
                f4checkBox.Hide();
                f5checkBox.Hide();
                f6checkBox.Hide();
                f7checkBox.Hide();
                f8checkBox.Hide();
                f9checkBox.Hide();
                f10checkBox.Hide();

                f1TypecomboBox.Items.Remove("Good");
                f2TypecomboBox.Items.Remove("Good");
                f3TypecomboBox.Items.Remove("Good");
                f4TypecomboBox.Items.Remove("Good");
                f5TypecomboBox.Items.Remove("Good");
                f6TypecomboBox.Items.Remove("Good");
                f7TypecomboBox.Items.Remove("Good");
                f8TypecomboBox.Items.Remove("Good");
                f9TypecomboBox.Items.Remove("Good");
                f10TypecomboBox.Items.Remove("Good");
            }
            len = fname.Length;
        }

        private bool CheckForOldestDos(string type, string oldestDos)
        {
            DateTime validateDate;
            if (oldestDos != "" && !DateTime.TryParse(oldestDos, out validateDate))
            {
                MessageBox.Show("Invalid date.");
                return false;
            } 
            else
            if (type == "Qform" && oldestDos == "")
            {
                MessageBox.Show("Enter the oldest date of service for the Qform file.");
                return false;
            }            
            else return true;
        }

        private int currentfile;

       /***************************************************************************
        * Allows to select pages for each file that is being split and opens appropriate form to fill.
        ***************************************************************************/
        private void selectbutton_Click(object sender, EventArgs e)
        {
            switch (currentfile)
            {
                case (1): 
                    {                        
                        processFileToCreate(f1pageslabel, ref f1list, ref f1Form, f1TypecomboBox);

                        if ((f1TypecomboBox.Text == "Qform" || f1TypecomboBox.Text == "NB") && cancelfile)
                            f1UnDobutton_Click(sender, e);                                               
                    }
                    break;
                case (2):
                    {                        
                        processFileToCreate(f2pageslabel, ref f2list, ref f2Form, f2TypecomboBox);

                        if ((f2TypecomboBox.Text == "Qform" || f2TypecomboBox.Text == "NB") && cancelfile)
                            f2UnDobutton_Click(sender, e);                        
                    }
                    break;
                case (3):
                    {                       
                        processFileToCreate(f3pageslabel, ref f3list, ref f3Form, f3TypecomboBox);

                        if ((f3TypecomboBox.Text == "Qform" || f3TypecomboBox.Text == "NB") && cancelfile)
                            f3UnDobutton_Click(sender, e);                        
                    }
                    break;
                case (4):
                    {                        
                        processFileToCreate(f4pageslabel, ref f4list, ref f4Form, f4TypecomboBox);

                        if ((f4TypecomboBox.Text == "Qform" || f4TypecomboBox.Text == "NB") && cancelfile)
                            f4UnDobutton_Click(sender, e);                     
                    }
                    break;
                case (5):
                    {                      
                        processFileToCreate(f5pageslabel, ref f5list, ref f5Form, f5TypecomboBox);

                        if ((f5TypecomboBox.Text == "Qform" || f5TypecomboBox.Text == "NB") && cancelfile)
                            f5UnDobutton_Click(sender, e);                        
                    }
                    break;
                case (6):
                    {                       
                        processFileToCreate(f6pageslabel, ref f6list, ref f6Form, f6TypecomboBox);

                        if ((f6TypecomboBox.Text == "Qform" || f6TypecomboBox.Text == "NB") && cancelfile)
                            f6UnDobutton_Click(sender, e);                        
                    }
                    break;
                case (7):
                    {                       
                        processFileToCreate(f7pageslabel, ref f7list, ref f7Form, f7TypecomboBox);

                        if ((f7TypecomboBox.Text == "Qform" || f7TypecomboBox.Text == "NB") && cancelfile)
                            f7UnDobutton_Click(sender, e);                        
                    }
                    break;
                case (8):
                    {                        
                        processFileToCreate(f8pageslabel, ref f8list, ref f8Form, f8TypecomboBox);

                        if ((f8TypecomboBox.Text == "Qform" || f8TypecomboBox.Text == "NB") && cancelfile)
                            f8UnDobutton_Click(sender, e);                       
                    }
                    break;
                case (9):
                    {                       
                        processFileToCreate(f9pageslabel, ref f9list, ref f9Form, f9TypecomboBox);

                        if ((f9TypecomboBox.Text == "Qform" || f9TypecomboBox.Text == "NB") && cancelfile)
                            f9UnDobutton_Click(sender, e);                       
                    }
                    break;
                case (10):
                    {
                       processFileToCreate(f10pageslabel, ref f10list, ref f10Form, f10TypecomboBox);

                        if ((f10TypecomboBox.Text == "Qform" || f10TypecomboBox.Text == "NB") && cancelfile)
                            f10UnDobutton_Click(sender, e);                                             
                    }
                    break;
            }
            pageslistBox.ClearSelected();
            pageslistBox.Hide();
            selectbutton.Hide();
            cancelfile = false;
        }

       /***************************************************************************
        * Refreshes the listbox and opens the Qform or NB form to fill.
        ***************************************************************************/
        private void processFileToCreate(Label pageslabel,ref List<int> list,ref string form,System.Windows.Forms.ComboBox typecomboBox)
        {
            DialogResult r = DialogResult.Yes;
            pageslabel.Text = "";
            list.Clear();

            foreach (int p in pageslistBox.SelectedItems)
            {
                pageslabel.Text = pageslabel.Text + p.ToString() + ",";
                list.Add(Convert.ToInt16(p));
            }

            if(pageslabel.Text.Length != 0)
               pageslabel.Text = pageslabel.Text.Substring(0, pageslabel.Text.Length - 1);

            /***************************************************************************
             * Fill the form for Qform and Not billable files
             ***************************************************************************/
            if (typecomboBox.Text == "NB")
            {
                form = SBSCParent.basePath + FilePaths.PATH_FilledForms + fname.Substring(0, len - 4) + "-f" + currentfile.ToString() + "form" + ".pdf";
                /***************************************************************************
                 * If the form has already been filled, prompt the user
                 ***************************************************************************/
                if (System.IO.File.Exists(form))
                {
                    if (pageslabel.Text == "")
                    {
                        System.IO.File.Delete(form);
                        MessageBox.Show("Please select the pages to split!");
                    }
                    else
                        r = MessageBox.Show("You have already filled the form for this file. Do you want to modify?", "Fill form", MessageBoxButtons.YesNo);

                    if (r == DialogResult.Yes && pageslabel.Text != "")
                        Process.Start(form);
                }
                else
                if (pageslabel.Text != "") Fillform(ref form, typecomboBox.Text);
                else MessageBox.Show("Please select the pages to split!");
            }
        }        
        
      /***************************************************************************
       * Opens the appropriate form to fill
       ***************************************************************************/
        private void Fillform(ref string fname, string type)
        {
            string pdfTemplate;
            string newFile;
            try
            {
                
                if (type == "NB")
                {
                    pdfTemplate = SBSCParent.basePath + FilePaths.PATH_Template_NBslip;
                    newFile     = fname;
                    PdfReader pdfReader   = new PdfReader(pdfTemplate);
                    PdfStamper pdfStamper = new PdfStamper(pdfReader, new FileStream(newFile, FileMode.Create));
                    AcroFields pdfFormFields = pdfStamper.AcroFields;
                    // set form pdfFormFields
                    pdfFormFields.SetField("Text Box 1", Convert.ToDateTime(dateSent).ToShortDateString());
                    
                    pdfStamper.FormFlattening = false;
                    // close the pdf            
                    pdfStamper.Close();
                    Process.Start(fname);
                }
                else fname = "";
            }
            catch (Exception ex)
            { MessageBox.Show(ex.Message); }
        }

      /***************************************************************************
       * Assigns the name for the new file that is being split.
       ***************************************************************************/
        private string FileName(string type, ref string path)
        {
            string filename = "";
            
            switch (type)
            {
                case ("Qform"):
                    {
                        filename = fname.Substring(0, len - 4) + "-Qform_" + numQforms.ToString() + ".pdf";
                        path = FilePaths.PATH_WorkinProcess;
                        numQforms += 1;
                    }
                    break;
                case ("NB"):
                    {
                        filename = fname.Substring(0, len - 4) + "-NB_" +numNBslips.ToString()+ ".pdf";                        
                        path = FilePaths.PATH_NotBillableForms;
                        numNBslips += 1;
                    }
                    break;
                case ("CIS"):
                    {
                        filename = fname.Substring(0, len - 4) + "-CIS_" + numCIS.ToString() + ".pdf";
                        path = FilePaths.PATH_CIS;
                        numCIS += 1;
                    }
                    break;
                case ("Good"):
                    {
                        filename = fname.Substring(0, len - 4) + "_" + numGoodFiles.ToString() + ".pdf";
                        path     = FilePaths.PATH_WorkinProcess;
                        numGoodFiles += 1;
                    }
                    break;
            }
            return filename;
        }

      /***************************************************************************
       * Creates a new PDF with selected pages and attaches the form.
       ***************************************************************************/
        private void CreateFile(string file, List<int> list,string attachForm)
        {
            if (!System.IO.File.Exists(file))
            {
                iTextSharp.text.Document document = new iTextSharp.text.Document(PageSize.LETTER);

                PdfCopy copy = new PdfCopy(document,
                                   new FileStream(file, FileMode.Create, FileAccess.ReadWrite));

                document.Open();
                try
                {
                    int pages;
                    if (attachForm != "")
                    {
                        PdfReader readerForm = new PdfReader(attachForm);

                        pages = readerForm.NumberOfPages;

                        for (int i = 1; i <= pages; i++)
                            copy.AddPage(copy.GetImportedPage(readerForm, i));
                    }

                    PdfReader reader = new PdfReader(fileLocation + fname);
                    pages = reader.NumberOfPages;

                    for (int i = 1; i <= pages; i++)
                    {
                        /***************************************************************************
                         * Add the cover page for good file.
                         ***************************************************************************/
                        if (i == 1 && !file.Contains("temp") && !file.Contains("Qform") && attachForm == "" && !list.Contains(1))
                            copy.AddPage(copy.GetImportedPage(reader, i));
                        if (list.Contains(i))
                            copy.AddPage(copy.GetImportedPage(reader, i));
                    }
                    object producer = reader.Info["Producer"];

                    document.Close();
                }
                catch (Exception ue)
                {
                    MessageBox.Show(ue.Message);
                }
            }
            
        }

      /***************************************************************************
       * Changes the file name when ever the type is changed.
       ***************************************************************************/
        # region
        private void f1TypecomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            f1nametextBox.Text = FileName(f1TypecomboBox.Text, ref f1path);
            f1nametextBox.Focus();
        }

        private void f2TypecomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            f2nametextBox.Text = FileName(f2TypecomboBox.Text, ref f2path);
            f2nametextBox.Focus();
        }

        private void f3TypecomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            f3nametextBox.Text = FileName(f3TypecomboBox.Text, ref f3path);
            f3nametextBox.Focus();
        }

        private void f4TypecomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            f4nametextBox.Text = FileName(f4TypecomboBox.Text, ref f4path);
            f4nametextBox.Focus();
        }

        private void f5TypecomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            f5nametextBox.Text = FileName(f5TypecomboBox.Text, ref f5path);
            f5nametextBox.Focus();
        }

        private void f6TypecomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            f6nametextBox.Text = FileName(f6TypecomboBox.Text, ref f6path);
            f6nametextBox.Focus();
        }

        private void f7TypecomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            f7nametextBox.Text = FileName(f7TypecomboBox.Text, ref f7path);
            f7nametextBox.Focus();
        }

        private void f8TypecomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            f8nametextBox.Text = FileName(f8TypecomboBox.Text, ref f8path);
            f8nametextBox.Focus();
        }

        private void f9TypecomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            f9nametextBox.Text = FileName(f9TypecomboBox.Text, ref f9path);
            f9nametextBox.Focus();
        }
        private void f10TypecomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            f10nametextBox.Text = FileName(f10TypecomboBox.Text, ref f10path);
            f10nametextBox.Focus();
        }
        #endregion

      /***************************************************************************
       * Checks if the file is open when the user is removing the pages from the file
       * and prevents the user to continue if the file is open.
       * Splits the file in to different types of files selected.
       ***************************************************************************/
        private void splitbutton_Click(object sender, EventArgs e)
        {
            bool inuse = false;
            if (f1list.Count + f2list.Count + f3list.Count + f4list.Count + f5list.Count + f6list.Count + f7list.Count + f8list.Count + f9list.Count + f10list.Count > 0 &&
                (f1checkBox.Checked || f2checkBox.Checked || f3checkBox.Checked || f4checkBox.Checked || f5checkBox.Checked ||
                 f6checkBox.Checked || f7checkBox.Checked || f8checkBox.Checked || f9checkBox.Checked || f10checkBox.Checked) && 
                WinFormsCommon.FileInUse(fileLocation + fname))
            {
                MessageBox.Show("Pages can not be removed when file is open! Please close " + fname + " and try again!");
                inuse = true;                
            }

            if (CheckForOldestDos(f1TypecomboBox.Text, f1dostextBox.Text) && CheckForOldestDos(f2TypecomboBox.Text,  f2dostextBox.Text) &&
                CheckForOldestDos(f3TypecomboBox.Text, f3dostextBox.Text) && CheckForOldestDos(f4TypecomboBox.Text,  f4dostextBox.Text) &&
                CheckForOldestDos(f5TypecomboBox.Text, f5dostextBox.Text) && CheckForOldestDos(f6TypecomboBox.Text,  f6dostextBox.Text) &&
                CheckForOldestDos(f7TypecomboBox.Text, f7dostextBox.Text) && CheckForOldestDos(f8TypecomboBox.Text,  f8dostextBox.Text) &&
                CheckForOldestDos(f9TypecomboBox.Text, f9dostextBox.Text) && CheckForOldestDos(f10TypecomboBox.Text, f10dostextBox.Text))
           if(!inuse)
            {
                if (f1list.Count != 0 && f1nametextBox.Text != "" && f1TypecomboBox.Text != "")
                {
                    SaveRec(f1nametextBox.Text, f1path, f1list, f1checkBox, f1Form, f1TypecomboBox.Text, WinFormsCommon.IsNull(f1dostextBox.Text));
                }
                if (f2list.Count != 0 && f2nametextBox.Text != "" && f2TypecomboBox.Text != "")
                {
                    SaveRec(f2nametextBox.Text, f2path, f2list, f2checkBox, f2Form, f2TypecomboBox.Text, WinFormsCommon.IsNull(f2dostextBox.Text));
                }
                if (f3list.Count != 0 && f3nametextBox.Text != "" && f3TypecomboBox.Text != "")
                {
                    SaveRec(f3nametextBox.Text, f3path, f3list, f3checkBox, f3Form, f3TypecomboBox.Text, WinFormsCommon.IsNull(f3dostextBox.Text));
                }
                if (f4list.Count != 0 && f4nametextBox.Text != "" && f4TypecomboBox.Text != "")
                {
                    SaveRec(f4nametextBox.Text, f4path, f4list, f4checkBox, f4Form, f4TypecomboBox.Text, WinFormsCommon.IsNull(f4dostextBox.Text));
                }
                if (f5list.Count != 0 && f5nametextBox.Text != "" && f5TypecomboBox.Text != "")
                {
                    SaveRec(f5nametextBox.Text, f5path, f5list, f5checkBox, f5Form, f5TypecomboBox.Text, WinFormsCommon.IsNull(f5dostextBox.Text));
                }
                if (f6list.Count != 0 && f6nametextBox.Text != "" && f6TypecomboBox.Text != "")
                {
                    SaveRec(f6nametextBox.Text, f6path, f6list, f6checkBox, f6Form, f6TypecomboBox.Text, WinFormsCommon.IsNull(f6dostextBox.Text));
                }
                if (f7list.Count != 0 && f7nametextBox.Text != "" && f7TypecomboBox.Text != "")
                {
                    SaveRec(f7nametextBox.Text, f7path, f7list, f7checkBox, f7Form, f7TypecomboBox.Text, WinFormsCommon.IsNull(f7dostextBox.Text));
                }
                if (f8list.Count != 0 && f8nametextBox.Text != "" && f8TypecomboBox.Text != "")
                {
                    SaveRec(f8nametextBox.Text, f8path, f8list, f8checkBox, f8Form, f8TypecomboBox.Text, WinFormsCommon.IsNull(f8dostextBox.Text));
                }
                if (f9list.Count != 0 && f9nametextBox.Text != "" && f9TypecomboBox.Text != "")
                {
                    SaveRec(f9nametextBox.Text, f9path, f9list, f9checkBox, f9Form, f9TypecomboBox.Text, WinFormsCommon.IsNull(f9dostextBox.Text));
                }
                if (f10list.Count != 0 && f10nametextBox.Text != "" && f10TypecomboBox.Text != "")
                {
                    SaveRec(f10nametextBox.Text, f10path, f10list, f10checkBox, f10Form, f10TypecomboBox.Text, WinFormsCommon.IsNull(f10dostextBox.Text));
                }

                /***************************************************************************
                 * Removes pages from the original file.
                 ***************************************************************************/
                if (removePageslist.Count > 0)
                {
                    try
                    {
                        List<int> list = new List<int> { };
                        foreach (int i in pageslistBox.Items)
                            if (!removePageslist.Contains(i))
                                list.Add(i);
                        string newfilename = fname.Substring(0, fname.Length - 4) + "temp" + ".pdf";
                        CreateFile(SBSCParent.basePath + FilePaths.PATH_FilledForms + newfilename, list, "");
                        System.IO.File.Copy(SBSCParent.basePath + FilePaths.PATH_FilledForms + newfilename, fileLocation + fname, true);
                        System.IO.File.Delete(SBSCParent.basePath + FilePaths.PATH_FilledForms + newfilename);
                    }
                    catch (Exception ex) { MessageBox.Show(ex.Message); };
                }
                this.Close();
            }            
        }        

        /***************************************************************************
         * If the file is being spLit by a input staff, do not move the files to 
         * A&I folders with out WL review
         ***************************************************************************/
        private void SaveRec(string filename, string path, List<int> list, System.Windows.Forms.CheckBox c, string attachForm, string type, string oldestDos)
        {
            if (!filename.ToLower().Contains(".pdf")) filename = filename + ".pdf";

            string status;
            try
            {
                if (type == "Qform")
                        {                      
                            path = fileLoc;
                            status = FileStatus.ReviewQuestionForm.ToString();
                                                  
                        }
                  else if(path ==  FilePaths.PATH_NotBillableForms)
                        {
                            if (SBSCParent.isInputStaff)
                            {
                                path = fileLoc;
                                status = FileStatus.ReviewNotBillable.ToString();
                            }
                            else
                                status = FileStatus.NonBillableToAnI.ToString();                                                          
                        }
                   else if(path == FilePaths.PATH_CIS) status = FileStatus.CIS.ToString();
                   else if(path == FilePaths.PATH_WorkinProcess)
                        {
                            status = FileStatus.ReadytoBatch.ToString();
                            assignedID = "";
                        }
                        else status = filestatus.ToString();
                       
                

                if (!SBSCParent.isInputStaff && status == FileStatus.NonBillableToAnI.ToString())
                {
                    DialogResult r = DialogResult.Yes;
                    r = MessageBox.Show("Do you want to send "+filename+" directly to A&I folders without Work leader review?", "Message", MessageBoxButtons.YesNo);
                    if (r == DialogResult.No)
                    {
                        path = fileLoc;
                        if (status == FileStatus.NonBillableToAnI.ToString()) status = FileStatus.ReviewNotBillable.ToString();
                    }
                }

                CreateFile(SBSCParent.basePath + path + filename, list, attachForm);
                // get the values from the file name.
                WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, filename, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName);


                WORKFLOW.InputBatches.InputBatchesSave(SBSCParent.connSpedmon, filename, clientID, dateSent, dateRecieved, path,
                                                     "1",recID, workType, oldestDos, "", SBSCParent.userID.ToString(), assignedID, "", "", status, "", "", "0", "1", "");

                //Enter Practitioner review if this is a question form
                if (status == FileStatus.QuestionFormToPrac.ToString() || status == FileStatus.ReviewQuestionForm.ToString())
                {
                    InfoRequestResponseForm QuestionsForm;

                    string batchID;
                    string sql = "SELECT id FROM INPUT_BATCHES_VIEW(null,@filename,null,null,null,null,null,null,null)";
                    List<SqlParameter>  parms = new List<SqlParameter>();
                    object vFilename = MBA.Validate.reqString(filename, "");
                    parms.Add(MBA.Database.SqlParm("@filename", SqlDbType.NVarChar, vFilename, ParameterDirection.Input));
                    batchID                 = WinFormsCommon.execScalar(SBSCParent.connSpedmon,sql,parms);
                    Process.Start(SBSCParent.basePath + path+filename);

                    QuestionsForm           = InfoRequestResponseForm.GetChildInstance();
                    QuestionsForm.QformID   = batchID;
                    QuestionsForm.clientID  = clientID;
                    QuestionsForm.qformName = filename;
                    QuestionsForm.oldDOS    = oldestDos;
                    QuestionsForm.ShowDialog();

                    MessageBox.Show("Please close the file - "+filename+" after filling the Info Request Response form!");
                }
                SBSCParent.refreshIBView = true;
                //do not remove the cover page if the user selects it accidentally
                if (c.Checked == true)
                    foreach (int i in list)
                        if (!removePageslist.Contains(i) && i != 1)
                            removePageslist.Add(i);
                //delete the temporary form created
                if (attachForm != "")
                    System.IO.File.Delete(attachForm);
            }
            catch(Exception ex)
            { MessageBox.Show(ex.Message); }
        }

      /***************************************************************************
       * UnDobuttons, clears the controls and deletes the form if created.
       ***************************************************************************/
        #region
       /***************************************************************************
        * clears the controls and deletes the form if created.
        ***************************************************************************/
        private void f1UnDobutton_Click(object sender, EventArgs e)
        {
          FileUnDo(f1TypecomboBox, f1nametextBox, f1pageslabel, f1list, f1dostextBox, f1Form);
        }

        private void f2UnDobutton_Click(object sender, EventArgs e)
        {
            FileUnDo(f2TypecomboBox, f2nametextBox, f2pageslabel, f2list, f2dostextBox, f2Form);
        }

        private void f3UnDobutton_Click(object sender, EventArgs e)
        {
            FileUnDo(f3TypecomboBox, f3nametextBox, f3pageslabel, f3list, f3dostextBox, f3Form);
        }

        private void f4UnDobutton_Click(object sender, EventArgs e)
        {
            FileUnDo(f4TypecomboBox, f4nametextBox, f4pageslabel, f4list, f4dostextBox, f4Form);
        }

        private void f5UnDobutton_Click(object sender, EventArgs e)
        {
            FileUnDo(f5TypecomboBox, f5nametextBox, f5pageslabel, f5list, f5dostextBox, f5Form);

        }

        private void f6UnDobutton_Click(object sender, EventArgs e)
        {
            FileUnDo(f6TypecomboBox, f6nametextBox, f6pageslabel, f6list, f6dostextBox, f6Form);
        }

        private void f7UnDobutton_Click(object sender, EventArgs e)
        {
            FileUnDo(f7TypecomboBox, f7nametextBox, f7pageslabel, f7list, f7dostextBox, f7Form);
        }

        private void f8UnDobutton_Click(object sender, EventArgs e)
        {
            FileUnDo(f8TypecomboBox, f8nametextBox, f8pageslabel, f8list, f8dostextBox, f8Form);
        }

        private void f9UnDobutton_Click(object sender, EventArgs e)
        {
            FileUnDo(f9TypecomboBox, f9nametextBox, f9pageslabel, f9list, f9dostextBox, f9Form);
        }

        private void f10UnDobutton_Click(object sender, EventArgs e)
        {
            FileUnDo(f10TypecomboBox, f10nametextBox, f10pageslabel, f10list, f10dostextBox, f10Form);
        }

        private void FileUnDo(System.Windows.Forms.ComboBox typecomboBox, System.Windows.Forms.TextBox fnametextBox, System.Windows.Forms.Label pageslabel, List<int> list, System.Windows.Forms.TextBox dostextBox, string form)
        {
            try
            {
                typecomboBox.Text = "";
                fnametextBox.Text = "";
                pageslabel.Text   = "";
                dostextBox.Text   = "";
                list.Clear();
                if (form != "" && System.IO.File.Exists(form)) System.IO.File.Delete(form);
            }
            catch (Exception ex)
            { MessageBox.Show(ex.Message); }
        }

        #endregion

     /***************************************************************************
      * Checks if the file names are provided before selecting the pages 
      ***************************************************************************/
        #region
        private void f1selbutton_Click(object sender, EventArgs e)
        {
            if (f1nametextBox.Text != "")
            {
                if (CheckForOldestDos(f1TypecomboBox.Text, f1dostextBox.Text))
                {
                    pageslistBox.Show();
                    selectbutton.Show();
                    currentfile = 1;
                }
            }
            else MessageBox.Show("Please select the file type!");
        }

        private void f2selbutton_Click(object sender, EventArgs e)
        {
            if (f2nametextBox.Text != "")
            {
                if (CheckForOldestDos(f2TypecomboBox.Text, f2dostextBox.Text))
                {
                    pageslistBox.Show();
                    selectbutton.Show();
                    currentfile = 2;
                }
            }
            else MessageBox.Show("Please select the file type!");
        }

        private void f3selbutton_Click(object sender, EventArgs e)
        {
            if (f3nametextBox.Text != "")
            {
                if (CheckForOldestDos(f3TypecomboBox.Text, f3dostextBox.Text))
                {
                    pageslistBox.Show();
                    selectbutton.Show();
                    currentfile = 3;
                }
            }
            else MessageBox.Show("Please select the file type!");
        }

        private void f4selbutton_Click(object sender, EventArgs e)
        {
            if (f4nametextBox.Text != "")
            {
                if (CheckForOldestDos(f4TypecomboBox.Text, f4dostextBox.Text))
                {
                    pageslistBox.Show();
                    selectbutton.Show();
                    currentfile = 4;
                }
            }
            else MessageBox.Show("Please select the file type!");
        }

        private void f5selbutton_Click(object sender, EventArgs e)
        {
            if (f5nametextBox.Text != "")
            {
                if (CheckForOldestDos(f5TypecomboBox.Text, f5dostextBox.Text))
                {
                    pageslistBox.Show();
                    selectbutton.Show();
                    currentfile = 5;
                }
            }
            else MessageBox.Show("Please select the file type!");
        }

        private void f6selbutton_Click(object sender, EventArgs e)
        {
            if (f6nametextBox.Text != "")
            {
                if (CheckForOldestDos(f6TypecomboBox.Text, f6dostextBox.Text))
                {
                    pageslistBox.Show();
                    selectbutton.Show();
                    currentfile = 6;
                }
            }
            else MessageBox.Show("Please select the file type!");
        }

        private void f7selbutton_Click(object sender, EventArgs e)
        {
            if (f7nametextBox.Text != "")
            {
                if (CheckForOldestDos(f7TypecomboBox.Text, f7dostextBox.Text))
                {
                    pageslistBox.Show();
                    selectbutton.Show();
                    currentfile = 7;
                }
            }
            else MessageBox.Show("Please select the file type!");
        }

        private void f8selbutton_Click(object sender, EventArgs e)
        {
            if (f8nametextBox.Text != "")
            {
                if (CheckForOldestDos(f8TypecomboBox.Text, f8dostextBox.Text))
                {
                    pageslistBox.Show();
                    selectbutton.Show();
                    currentfile = 8;
                }
            }
            else MessageBox.Show("Please select the file type!");
        }

        private void f9selbutton_Click(object sender, EventArgs e)
        {
            if (f9nametextBox.Text != "")
            {
                if (CheckForOldestDos(f9TypecomboBox.Text, f9dostextBox.Text))
                {
                    pageslistBox.Show();
                    selectbutton.Show();
                    currentfile = 9;
                }
            }
            else MessageBox.Show("Please select the file type!");
        }

        private void f10selbutton_Click(object sender, EventArgs e)
        {
            if (f10nametextBox.Text != "")
            {
                if (CheckForOldestDos(f10TypecomboBox.Text, f10dostextBox.Text))
                {
                    pageslistBox.Show();
                    selectbutton.Show();
                    currentfile = 10;
                }
            }
            else MessageBox.Show("Please select the file type!");
        }
        #endregion                                  

        private void SplitFile_FormClosing(object sender, FormClosingEventArgs e)
        {
       /***************************************************************************
        * Deletes the Qform or NBSlip file that is filled for each split file before closing.
        ***************************************************************************/
            try
            {
                if (SBSCParent.OK_TO_MANAGE_FILES)
                {
                    if (f1Form != "" && f1Form != null && System.IO.File.Exists(f1Form)) System.IO.File.Delete(f1Form);
                    if (f2Form != "" && f2Form != null && System.IO.File.Exists(f2Form)) System.IO.File.Delete(f2Form);
                    if (f3Form != "" && f3Form != null && System.IO.File.Exists(f3Form)) System.IO.File.Delete(f3Form);
                    if (f4Form != "" && f4Form != null && System.IO.File.Exists(f4Form)) System.IO.File.Delete(f4Form);
                    if (f5Form != "" && f5Form != null && System.IO.File.Exists(f5Form)) System.IO.File.Delete(f5Form);
                    if (f6Form != "" && f6Form != null && System.IO.File.Exists(f6Form)) System.IO.File.Delete(f6Form);
                    if (f7Form != "" && f7Form != null && System.IO.File.Exists(f7Form)) System.IO.File.Delete(f7Form);
                    if (f8Form != "" && f8Form != null && System.IO.File.Exists(f8Form)) System.IO.File.Delete(f8Form);
                    if (f9Form != "" && f9Form != null && System.IO.File.Exists(f9Form)) System.IO.File.Delete(f9Form);
                    if (f10Form != "" && f10Form != null && System.IO.File.Exists(f10Form)) System.IO.File.Delete(f10Form);
                }
            }
            catch (Exception ex)
            { MessageBox.Show(ex.Message); }
        }

        /***************************************************************************
         * Check if the file name is in the correct format for all the files that are 
         * being split.
         ***************************************************************************/
        #region
        private void f1nametextBox_Leave(object sender, EventArgs e)
        {
            if (f1nametextBox.Text != "")
            {
                if (!WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, f1nametextBox.Text, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
                    f1nametextBox.Focus();
                else
                 if (f1nametextBox.Text == f2nametextBox.Text ||
                     f1nametextBox.Text == f3nametextBox.Text ||
                     f1nametextBox.Text == f4nametextBox.Text ||
                     f1nametextBox.Text == f5nametextBox.Text ||
                     f1nametextBox.Text == f6nametextBox.Text ||
                     f1nametextBox.Text == f7nametextBox.Text ||
                     f1nametextBox.Text == f8nametextBox.Text ||
                     f1nametextBox.Text == f9nametextBox.Text ||
                     f1nametextBox.Text == f10nametextBox.Text)
                {
                    MessageBox.Show("This file name has already been used! please use a different file name.");
                    f1nametextBox.Focus();
                }
            }
        }

        private void f2nametextBox_Leave(object sender, EventArgs e)
        {
            if(f2nametextBox.Text != "" )
            {
                if (!WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, f2nametextBox.Text, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
                    f2nametextBox.Focus();
                else
                if (f2nametextBox.Text == f1nametextBox.Text ||
                    f2nametextBox.Text == f3nametextBox.Text ||
                    f2nametextBox.Text == f4nametextBox.Text ||
                    f2nametextBox.Text == f5nametextBox.Text ||
                    f2nametextBox.Text == f6nametextBox.Text ||
                    f2nametextBox.Text == f7nametextBox.Text ||
                    f2nametextBox.Text == f8nametextBox.Text ||
                    f2nametextBox.Text == f9nametextBox.Text ||
                    f2nametextBox.Text == f10nametextBox.Text)
                {
                    MessageBox.Show("This file name has already been used! please use a different file name.");
                    f2nametextBox.Focus();
                }
            }
        }

        private void f3nametextBox_Leave(object sender, EventArgs e)
        {
            if (f3nametextBox.Text != "")
            {
                if (!WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, f3nametextBox.Text, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
                    f3nametextBox.Focus();
                else
                    if (f3nametextBox.Text == f2nametextBox.Text ||
                        f3nametextBox.Text == f1nametextBox.Text ||
                        f3nametextBox.Text == f4nametextBox.Text ||
                        f3nametextBox.Text == f5nametextBox.Text ||
                        f3nametextBox.Text == f6nametextBox.Text ||
                        f3nametextBox.Text == f7nametextBox.Text ||
                        f3nametextBox.Text == f8nametextBox.Text ||
                        f3nametextBox.Text == f9nametextBox.Text ||
                        f3nametextBox.Text == f10nametextBox.Text)
                    {
                        MessageBox.Show("This file name has already been used! please use a different file name.");
                        f3nametextBox.Focus();
                    }
            }
        }

        private void f4nametextBox_Leave(object sender, EventArgs e)
        {
            if (f4nametextBox.Text != "")
            {
                if (!WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, f4nametextBox.Text, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
                    f4nametextBox.Focus();
                else
                    if (f4nametextBox.Text == f2nametextBox.Text ||
                        f4nametextBox.Text == f3nametextBox.Text ||
                        f4nametextBox.Text == f1nametextBox.Text ||
                        f4nametextBox.Text == f5nametextBox.Text ||
                        f4nametextBox.Text == f6nametextBox.Text ||
                        f4nametextBox.Text == f7nametextBox.Text ||
                        f4nametextBox.Text == f8nametextBox.Text ||
                        f4nametextBox.Text == f9nametextBox.Text ||
                        f4nametextBox.Text == f10nametextBox.Text)
                    {
                        MessageBox.Show("This file name has already been used! please use a different file name.");
                        f4nametextBox.Focus();
                    }
            }
        }

        private void f5nametextBox_Leave(object sender, EventArgs e)
        {
            if (f5nametextBox.Text != "")
            {
                if (!WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, f5nametextBox.Text, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
                    f5nametextBox.Focus();
                else
                    if (f5nametextBox.Text == f2nametextBox.Text ||
                        f5nametextBox.Text == f3nametextBox.Text ||
                        f5nametextBox.Text == f4nametextBox.Text ||
                        f5nametextBox.Text == f1nametextBox.Text ||
                        f5nametextBox.Text == f6nametextBox.Text ||
                        f5nametextBox.Text == f7nametextBox.Text ||
                        f5nametextBox.Text == f8nametextBox.Text ||
                        f5nametextBox.Text == f9nametextBox.Text ||
                        f5nametextBox.Text == f10nametextBox.Text)
                    {
                        MessageBox.Show("This file name has already been used! please use a different file name.");
                        f5nametextBox.Focus();
                    }
            }
        }

        private void f6nametextBox_Leave(object sender, EventArgs e)
        {
            if (f6nametextBox.Text != "")
            {
                if (!WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, f6nametextBox.Text, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
                    f6nametextBox.Focus();
                else
                    if (f6nametextBox.Text == f2nametextBox.Text ||
                        f6nametextBox.Text == f3nametextBox.Text ||
                        f6nametextBox.Text == f4nametextBox.Text ||
                        f6nametextBox.Text == f5nametextBox.Text ||
                        f6nametextBox.Text == f1nametextBox.Text ||
                        f6nametextBox.Text == f7nametextBox.Text ||
                        f6nametextBox.Text == f8nametextBox.Text ||
                        f6nametextBox.Text == f9nametextBox.Text ||
                        f6nametextBox.Text == f10nametextBox.Text)
                    {
                        MessageBox.Show("This file name has already been used! please use a different file name.");
                        f6nametextBox.Focus();
                    }
            }
        }

        private void f7nametextBox_Leave(object sender, EventArgs e)
        {
            if (f7nametextBox.Text != "")
            {
                if (!WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, f7nametextBox.Text, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
                    f7nametextBox.Focus();
                else
                    if (f7nametextBox.Text == f2nametextBox.Text ||
                        f7nametextBox.Text == f3nametextBox.Text ||
                        f7nametextBox.Text == f4nametextBox.Text ||
                        f7nametextBox.Text == f5nametextBox.Text ||
                        f7nametextBox.Text == f6nametextBox.Text ||
                        f7nametextBox.Text == f1nametextBox.Text ||
                        f7nametextBox.Text == f8nametextBox.Text ||
                        f7nametextBox.Text == f9nametextBox.Text ||
                        f7nametextBox.Text == f10nametextBox.Text)
                    {
                        MessageBox.Show("This file name has already been used! please use a different file name.");
                        f7nametextBox.Focus();
                    }
            }
        }

        private void f8nametextBox_Leave(object sender, EventArgs e)
        {
            if (f8nametextBox.Text != "")
            {
                if (!WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, f8nametextBox.Text, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
                    f8nametextBox.Focus();
                else
                    if (f8nametextBox.Text == f2nametextBox.Text ||
                        f8nametextBox.Text == f3nametextBox.Text ||
                        f8nametextBox.Text == f4nametextBox.Text ||
                        f8nametextBox.Text == f5nametextBox.Text ||
                        f8nametextBox.Text == f6nametextBox.Text ||
                        f8nametextBox.Text == f7nametextBox.Text ||
                        f8nametextBox.Text == f1nametextBox.Text ||
                        f8nametextBox.Text == f9nametextBox.Text ||
                        f8nametextBox.Text == f10nametextBox.Text)
                    {
                        MessageBox.Show("This file name has already been used! please use a different file name.");
                        f8nametextBox.Focus();
                    }
            }
        }

        private void f9nametextBox_Leave(object sender, EventArgs e)
        {
            if (f9nametextBox.Text != "")
            {
                if (!WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, f9nametextBox.Text, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
                    f9nametextBox.Focus();
                else
                    if (f9nametextBox.Text == f2nametextBox.Text ||
                        f9nametextBox.Text == f3nametextBox.Text ||
                        f9nametextBox.Text == f4nametextBox.Text ||
                        f9nametextBox.Text == f5nametextBox.Text ||
                        f9nametextBox.Text == f6nametextBox.Text ||
                        f9nametextBox.Text == f7nametextBox.Text ||
                        f9nametextBox.Text == f8nametextBox.Text ||
                        f9nametextBox.Text == f1nametextBox.Text ||
                        f9nametextBox.Text == f10nametextBox.Text)
                    {
                        MessageBox.Show("This file name has already been used! please use a different file name.");
                        f9nametextBox.Focus();
                    }
            }
        }

        private void f10nametextBox_Leave(object sender, EventArgs e)
        {
            if (f10nametextBox.Text != "")
            {
                if (!WinFormsCommon.CheckFileName(SBSCParent.connSpedmon, f10nametextBox.Text, ref dateSent, ref workType, ref clientID, ref clientCDS, ref clientShortName))
                    f10nametextBox.Focus();
                else
                    if (f10nametextBox.Text == f2nametextBox.Text ||
                        f10nametextBox.Text == f3nametextBox.Text ||
                        f10nametextBox.Text == f4nametextBox.Text ||
                        f10nametextBox.Text == f5nametextBox.Text ||
                        f10nametextBox.Text == f6nametextBox.Text ||
                        f10nametextBox.Text == f7nametextBox.Text ||
                        f10nametextBox.Text == f8nametextBox.Text ||
                        f10nametextBox.Text == f9nametextBox.Text ||
                        f10nametextBox.Text == f1nametextBox.Text)
                    {
                        MessageBox.Show("This file name has already been used! please use a different file name.");
                        f10nametextBox.Focus();
                    }
            }
        }
        #endregion

        private void dateTimePicker1_ValueChanged(object sender, EventArgs e)
        {
            f1dostextBox.Text = dateTimePicker1.Value.ToShortDateString();                       
        }

        private void dateTimePicker2_ValueChanged(object sender, EventArgs e)
        {
            f2dostextBox.Text = dateTimePicker2.Value.ToShortDateString();
        }

        private void dateTimePicker3_ValueChanged(object sender, EventArgs e)
        {
            f3dostextBox.Text = dateTimePicker3.Value.ToShortDateString();
        }

        private void dateTimePicker4_ValueChanged(object sender, EventArgs e)
        {
            f4dostextBox.Text = dateTimePicker4.Value.ToShortDateString();
        }

        private void dateTimePicker5_ValueChanged(object sender, EventArgs e)
        {
            f5dostextBox.Text = dateTimePicker5.Value.ToShortDateString();
        }

        private void dateTimePicker6_ValueChanged(object sender, EventArgs e)
        {
            f6dostextBox.Text = dateTimePicker6.Value.ToShortDateString();
        }

        private void dateTimePicker7_ValueChanged(object sender, EventArgs e)
        {
            f7dostextBox.Text = dateTimePicker7.Value.ToShortDateString();
        }

        private void dateTimePicker8_ValueChanged(object sender, EventArgs e)
        {
            f8dostextBox.Text = dateTimePicker8.Value.ToShortDateString();
        }

        private void dateTimePicker9_ValueChanged(object sender, EventArgs e)
        {
            f9dostextBox.Text = dateTimePicker9.Value.ToShortDateString();
        }

        private void dateTimePicker10_ValueChanged(object sender, EventArgs e)
        {
            f10dostextBox.Text = dateTimePicker10.Value.ToShortDateString();
        }

    }
}
