using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Threading;
using System.Diagnostics;

namespace Spedmon
{
  public partial class ReportsAppFormMain : Form
  {
    
   /*----------------------------
    * Default start and end dates
    * for period 1
    *----------------------------*/
    
    protected DateTime startDateP1Default;
    protected DateTime endDateP1Default;
              
    public ReportsAppFormMain()
    {
      InitializeComponent();      
      buttonExit.Image            = MBA.EmbeddedResources.CommonImages.GetImage("exit.png");
      buttonGenerateReports.Image = MBA.EmbeddedResources.CommonImages.GetImage("proceed.png");
    }

    private void Form1_Load(object sender, EventArgs e)
    {
            
      /*----------------------------
       * Populate client list box
       * by binding to a list of
       * clients we fetched earlier
       *----------------------------*/
      
      this.listBoxClients.DataSource    = ReportsApp.clients;
      this.listBoxClients.DisplayMember = "name";
      this.listBoxClients.ValueMember   = "id";
      this.listBoxClients.ClearSelected();
 
      /*----------------------------
       * Compute current fiscal year
       *----------------------------*/
 
            
      MBA.Util.computeFiscalYear(Constants.FY_START_MONTH_DEFAULT,
                                 Constants.FY_START_DAY_DEFAULT,
                                 Constants.FY_END_MONTH_DEFAULT,
                                 Constants.FY_END_DAY_DEFAULT,
                                 DateTime.Now,
                                 out startDateP1Default, 
                                 out endDateP1Default);
      
      /*----------------------------
       * Set our start and end
       * default dates for period 1
       * to the current fiscal year
       * and todays date
       *----------------------------*/

      endDateP1Default = DateTime.Now;
      
      /*----------------------------
       * Set date picker date values
       *----------------------------*/

      this.dateTimePickerP1Start.Value = startDateP1Default;
      this.dateTimePickerP1End.Value   = endDateP1Default;
          
      /*----------------------------
       * Set button states
       *----------------------------*/

      this.buttonCancelGenerateReports.Enabled = false;
      
      this.toolStripStatusLabelUser.Text = ReportsApp.dbConnInfoSummary + " | " + 
                                           MBA.Machine.GetMachineName() + " | " +
                                           ReportsApp.networkUserName   + " | " + 
                                           ReportsApp.uInfo.userRole;
      
    }
    
  
    private void buttonSelectFolder_Click(object sender, EventArgs e)
    {      
      /*----------------------------
       * Create a folder browser
       * dialog and set the value
       * of our folder text box
       * if the user did not cancel
       *----------------------------*/

      FolderBrowserDialog fb = new FolderBrowserDialog();
      DialogResult r = fb.ShowDialog();
      if (r != DialogResult.Cancel)
        textBoxReportOutputFolder.Text = fb.SelectedPath;
    
    }
    

    
    private void buttonGenerateReports_Click(object sender, EventArgs e)
    {                            
     /*----------------------------
      * Get parameters
      *----------------------------*/
       
      string folder    = textBoxReportOutputFolder.Text;
      string startdate = dateTimePickerP1Start.Value.ToShortDateString();      
      string enddate   = dateTimePickerP1End.Value.ToShortDateString();
      string daterange = startdate + " - " + enddate;
      int    report    = Constants.REPT_NUM_CLAIMS_PAID_BY_DOW_1P;
      int    format    = Constants.REPT_FORMAT_PDF_REPORT;      
      string showzeros = MBA.Util.boolToYesNo(checkBoxShowZeros.Checked);
      
      /*----------------------------
       * Check output folder
       *----------------------------*/
           
      bool state = ReportsApp.CheckFolder(folder);
      
      if (!state) 
        return;
      
      /*----------------------------
       * Check if a report has been
       * selected and get that 
       * report
       *----------------------------*/
      
      if      (radioButtonClaimsByCheckDate.Checked)   report = Constants.REPT_NUM_CLAIMS_PAID_BY_DOW_1P;      
      else if (radioButtonClaimsByServiceDate.Checked) report = Constants.REPT_NUM_CLAIMS_PAID_BY_DOS_1P;
      else
      {
        ReportsApp.DisplayNotice(MBA.Return.RET_INFO,"You have not selected a report.");
        return;
      }
      
      /*----------------------------
       * Check if a format has been
       * selected and get that
       * format
       *----------------------------*/
        
      if      (radioButtonPDF.Checked)  format = Constants.REPT_FORMAT_PDF_REPORT;                  
      else if (radioButtonXLS.Checked)  format = Constants.REPT_FORMAT_XLS_REPORT;      
      else if (radioButtonHTML.Checked) format = Constants.REPT_FORMAT_HTML_REPORT;    
      else
      {
        ReportsApp.DisplayNotice(MBA.Return.RET_INFO,"You have not selected an output format.");
        return;
      }
      
      /*----------------------------
       * Get selected clients
       *----------------------------*/
                  
      if (listBoxClients.SelectedItems.Count == 0)
      {
        ReportsApp.DisplayNotice(MBA.Return.RET_INFO,"You have not selected any clients.");
        return;
      }
      
      List <ReportsApp.Client> selectedclients = new List<ReportsApp.Client>();
      
      foreach (ReportsApp.Client c in listBoxClients.SelectedItems)
        selectedclients.Add(c);
      
      /*----------------------------
       * Run reports
       *----------------------------*/              
      
      BackgroundWorker worker = new BackgroundWorker();
      worker.WorkerReportsProgress      = true;
      worker.WorkerSupportsCancellation = true;
                  
      /*----------------------------
       * DoWork
       *----------------------------*/     
      
      worker.DoWork += delegate{
       
        ReportsApp.generateClaimsPaidByDate1PReports(worker, selectedclients, daterange, showzeros, folder, report, format);
      };
      
      /*----------------------------
       * Wire up progress delegate
       *----------------------------*/     

      worker.ProgressChanged += delegate (object bworker, ProgressChangedEventArgs progress){
        toolStripStatusLabel1.Text  = (String) progress.UserState;
        toolStripProgressBar1.Value = progress.ProgressPercentage;
      };
      
      /*----------------------------
       * Wire up work complete delegate
       *----------------------------*/     

      worker.RunWorkerCompleted += delegate{
        buttonCancelGenerateReports.Click += null;
        buttonGenerateReports.Enabled = true;
        buttonCancelGenerateReports.Enabled = false;          
      };
      
      /*----------------------------
       * Wire up cancel button
       *----------------------------*/         
      
      buttonCancelGenerateReports.Click += delegate{
        if (worker.CancellationPending) return;
        buttonCancelGenerateReports.Enabled = false;
        worker.CancelAsync();
      };

      /*----------------------------
       * Set button states
       *----------------------------*/     

      buttonGenerateReports.Enabled       = false;
      buttonCancelGenerateReports.Enabled = true;

      /*----------------------------
       * Set initial status
       *----------------------------*/     

      toolStripStatusLabel1.Text  = "Running reports";
      toolStripProgressBar1.Value = 0;
      
      /*----------------------------
       * Kick off worker thread
       *----------------------------*/     

      worker.RunWorkerAsync();
                                                                      
     
    }

    private void buttonOpenOutputFolder_Click(object sender, EventArgs e)
    {      
      
     /*----------------------------
      * Get folder and check it
      *----------------------------*/
      
      string folder = textBoxReportOutputFolder.Text;     
      bool   state  = ReportsApp.CheckFolder(folder);
      
      if (!state) 
        return;
      
      /*----------------------------
       * Open folder
       *----------------------------*/

       Process outputFolder = Process.Start(folder);
      
    }

    private void buttonClientsSelectAll_Click(object sender, EventArgs e)
    {
      /*----------------------------
       * Select all clients
       *----------------------------*/
      
      if (listBoxClients.Items.Count > 0)
      {
        this.listBoxClients.ClearSelected();
        int numItems = this.listBoxClients.Items.Count;
        for(int i = 1; i < numItems;i++)
          listBoxClients.SetSelected(i,true); 
        this.listBoxClients.Focus();
        this.listBoxClients.SetSelected(0,true);
      }
    }
    
    private void buttonClientsClearAll_Click(object sender, EventArgs e)
    {
      /*----------------------------
       * Clear all client selections
       *----------------------------*/
      
      if (listBoxClients.Items.Count > 0)
      {
        this.listBoxClients.ClearSelected();     
        this.listBoxClients.Focus();
        this.listBoxClients.SetSelected(0,true);
        this.listBoxClients.SetSelected(0,false);
      }
    }

    private void buttonClearP1StartDate_Click(object sender, EventArgs e)
    {
     /*----------------------------
      * Reset start date to default
      *----------------------------*/

      this.dateTimePickerP1Start.Value = startDateP1Default;
    }

    private void buttonClearP1EndDate_Click(object sender, EventArgs e)
    {
      /*----------------------------
       * Reset end date to default
       *----------------------------*/

      this.dateTimePickerP1End.Value = endDateP1Default;
    }

    protected void Exit()
    {
      /*----------------------------
       * Exit application
       *----------------------------*/

      Application.Exit();
    }
    
    private void buttonExit_Click(object sender, EventArgs e)
    {     
      Exit();
    }

    private void exitToolStripMenuItem_Click(object sender, EventArgs e)
    {
      Exit();
    }

 
   
  }
}
