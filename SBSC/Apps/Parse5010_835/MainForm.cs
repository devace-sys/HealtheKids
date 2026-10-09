using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using MBA.X12;
using MBA.X12.XDOC;
using MBA.X12.X835;
using MBA.X12.X835_5010;
 
namespace Spedmon
{
  /// <summary>
  /// Description of MainForm.
  /// </summary>
  
  public partial class Parse835AppFormMain : Form
  {
    private const string APP_SETTING_ZIP_PWD = @"zippwd";
    private const string APP_TITLE           = @"Parse 835 File";
    
    private MBA.X12.ParsingWorkflow.ParseX835_5010 pwf;
   
    private void UpdateNotifyIconToolTipText (string text)
    {      
      if (text.Length > 60) text = text.Substring(0,60);
      this.notifyIconStatus.Text = text;
    }
    
    private void HandleProcessingStatusEvent (object sender, ProcessingStatusEventArgs e)
    {
      listBoxParsingMessages.AddItemThreadSafe(e.Message);
      UpdateNotifyIconToolTipText(e.Message);
    }
   
    public Parse835AppFormMain()
    {
      //
      // The InitializeComponent() call is required for Windows Forms designer support.
      //
      InitializeComponent();      

      /*###########################################################################
        # Decorate buttons with images
        ###########################################################################*/  
      
      this.buttonSelect835File.Image = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_FOLDER_OPEN);
      this.buttonParseFile.Image = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_PROCEED);

      pwf = new MBA.X12.ParsingWorkflow.ParseX835_5010();
      pwf.ProcessingStatusEvent += HandleProcessingStatusEvent;
      textBoxZipPassword.Text = MBA.X12.Utility.GetAppSetting(APP_SETTING_ZIP_PWD);
    }
    
    void UpdateIconStatus (int timeout, string message)
    {          
      notifyIconStatus.ShowBalloonTip (timeout, APP_TITLE,message,ToolTipIcon.Info);
    }
    
    void Select835FileAndPath()
    {
      var res = openFileDialog835In.ShowDialog();
      if (res == DialogResult.OK)
      {
        textBox835FileIn.Text = openFileDialog835In.FileName;
      }      
    }
        
    void LockParse835File()
    {
      saveToolStripMenuItem.Enabled = false;
      buttonParseFile.Enabled       = false;
      UpdateIconStatus(1000,@"Parsing started");      
    }
    
    void UnLockParse835File()
    {
      saveToolStripMenuItem.Enabled = true;
      buttonParseFile.Enabled = true;
      notifyIconStatus.Text = @"Parsing complete";
      UpdateIconStatus(2000,@"Parsing complete");                
    }
    
    void ClearStatus()
    {
      listBoxParsingMessages.Items.Clear();
      listBoxParsingMessages.Refresh();
    }
    
    void LoadParameters()
    {
      pwf.X12FileIn                   = textBox835FileIn.Text;
      pwf.ZipFilePassword             = textBoxZipPassword.Text;
      pwf.GenerateCleanWrappedFile    = checkBoxGenerateWrappedFile.Checked;
      pwf.GenerateCSVImportFile       = checkBoxGenerateCSV.Checked;
      pwf.ContentReportIncludeDetails = checkBoxIncDetsInRept.Checked;
      pwf.GenerateContentReportFile   = checkBoxGenerateContentReport.Checked;
      pwf.GenerateXMLImportFile       = checkBoxGeneratContentXML.Checked;      
    }
    
    void Parse835File()
    {
      LockParse835File();      
      ClearStatus();
      LoadParameters();           
      backgroundWorkerParseFile.RunWorkerAsync();
    }
    
    void ButtonSelect835FileClick(object sender, EventArgs e)
    {
      Select835FileAndPath();
    }
        
    void ButtonParseFileClick(object sender, EventArgs e)
    {
      Parse835File();
    }

    void BackgroundWorkerParseFileDoWork(object sender, System.ComponentModel.DoWorkEventArgs e)
    {
      pwf.RunParser();  
    }
    
    void BackgroundWorkerParseFileRunWorkerCompleted(object sender, System.ComponentModel.RunWorkerCompletedEventArgs e)
    {
        UnLockParse835File ();        
    }
    
    void OpenToolStripMenuItemClick(object sender, EventArgs e)
    {
      Select835FileAndPath();
    }
    
    void SaveToolStripMenuItemClick(object sender, EventArgs e)
    {
      Parse835File();
    }

    void ExitToolStripMenuItem1Click(object sender, EventArgs e)
    {
      Application.Exit();
    }
    void ButtonSaveZipPwdClick(object sender, EventArgs e)
    {  
      MBA.X12.Utility.SetAppSetting(APP_SETTING_ZIP_PWD, textBoxZipPassword.Text);
    }
    
    void ButtonOpenOutputFolderClick(object sender, EventArgs e)
    {           
      MBA.X12.Utility.OpenFolderFileIsIn(textBox835FileIn.Text);
    }

    private void Parse835AppFormMain_Load(object sender, EventArgs e)
    {
      this.toolStripStatusLabelUser.Text = Parse835App.dbConnInfoSummary + " | " + 
                                           MBA.Machine.GetMachineName() + " | " +
                                           Parse835App.networkUserName   + " | " + 
                                           Parse835App.uInfo.userRole;
    }
  }
}