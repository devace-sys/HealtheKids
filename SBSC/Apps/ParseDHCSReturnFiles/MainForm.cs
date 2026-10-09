using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using System.IO;
using System.Text;
using System.Globalization;
using MBA.X12;
using CsvHelper;

namespace Spedmon
{ 
  public partial class ParseDHCSReturnFilesAppFormMain : Form
  {
    public const string APP_SETTING_INPUT_FOLDER     = @"INPUT_FOLDER";
    public const string APP_SETTING_OUTPUT_FOLDER    = @"OUTPUT_FOLDER";
    public const string APP_SETTING_MAPPING_FILE     = @"MAPPING_FILE";

    public const string INPUT_FILE_EXTENSION         = @".csv";
    public const string OUTPUT_FILE_EXTENSION        = @".txt";

    public const string INPUT_FILE_PATTERN           = @"*.csv";
    public const string OUTPUT_FILE_PATTERN          = @"*.txt";

    public string mappingFile    = @"mapping.csv";
    public bool   combineIntoOne = false;
    public ParseDHCSReturnFilesAppFormMain()
    {
      //
      // The InitializeComponent() call is required for Windows Forms designer support.
      //

      InitializeComponent();      

     /*###########################################################################
       # Decorate buttons with images
       ###########################################################################*/  
      
      this.buttonSelectInputFolder.Image  = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_FOLDER_CLOSE);
      this.buttonSelectOutputFolder.Image = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_FOLDER_CLOSE);
      this.buttonOpenInputFolder.Image    = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_FOLDER_OPEN);
      this.buttonOpenOutputFolder.Image   = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_FOLDER_OPEN);
      this.buttonReloadInputFiles.Image   = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_REFRESH);
      this.buttonParse.Image              = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_PROCEED);
      
     /*###########################################################################
       # Get various app settings 
       ###########################################################################*/  

      mappingFile = MBA.X12.Utility.GetAppSetting(APP_SETTING_MAPPING_FILE);
      this.textBoxInputFolder.Text  = MBA.X12.Utility.GetAppSetting(APP_SETTING_INPUT_FOLDER); 
      this.textBoxOutputFolder.Text = MBA.X12.Utility.GetAppSetting(APP_SETTING_OUTPUT_FOLDER); 
      this.selectFolderInputFolder.SelectedPath = this.textBoxInputFolder.Text;
      this.selectFolderOutputFolder.SelectedPath = this.textBoxOutputFolder.Text;    

     /*###########################################################################
       # Set task bar progress initial state 
       ###########################################################################*/  

      MBA.WinFormsTaskbarProgress.SetState(this.Handle, MBA.WinFormsTaskbarProgress.TaskbarStates.Normal);
    }
   
    private void determineParsingMode ()
    {
      /*###########################################################################
        # Set initial/default mode
        ###########################################################################*/  

      combineIntoOne = false;
      this.groupBoxOutputFile.Visible = false;

      /*###########################################################################
        # Determine mode based on user selection
        ###########################################################################*/  

      if (this.radioButtonCombinedMode.Checked == true) combineIntoOne = true;
      if (combineIntoOne) this.groupBoxOutputFile.Visible = true;
    }

    void ExitToolStripMenuItem1Click(object sender, EventArgs e)
    {
      Application.Exit();
    }

    private void ParseDHCSReturnFilesAppFormMain_Load(object sender, EventArgs e)
    {     
      /*###########################################################################
        # On form load, populate file list and determine parsing mode
        ###########################################################################*/  
     
      populateInputFilesList();
      populateOutputFilesList();
      determineParsingMode();
    }

    private void populateInputFilesList()
    {
      
      /*###########################################################################
        # Clear list
        ###########################################################################*/  
      
      this.selectInputFiles.Items.Clear();

      /*###########################################################################
        # If no input folder specified or folder does not exist get out
        ###########################################################################*/  
      
      if (String.IsNullOrWhiteSpace(this.textBoxInputFolder.Text)) {
        return;
      }

      if (!System.IO.Directory.Exists(this.textBoxInputFolder.Text)) {       
        return;
      }
      
      /*###########################################################################
        # Get list of files in input folder.  Please note that this is a list of
        # FileInfo instances.
        ###########################################################################*/  
      
      var di = new System.IO.DirectoryInfo(this.textBoxInputFolder.Text);
      var files = di.GetFiles(INPUT_FILE_PATTERN);

      /*###########################################################################
        # Add each FileInfo instance (yes you read that right) to the control
        # The control accepts Objects so we can pass these on and cast them as 
        # FileInfo classes when we get a list of selected items
        ###########################################################################*/  
      
      foreach(var file in files) {                   
        this.selectInputFiles.Items.Add(file);
      }     
    }

    private void populateOutputFilesList()
    {
      
      /*###########################################################################
        # Clear list
        ###########################################################################*/  
      
      this.listOutputFiles.Items.Clear();

      /*###########################################################################
        # If no output folder specified or folder does not exist get out
        ###########################################################################*/  
      
      if (String.IsNullOrWhiteSpace(this.textBoxOutputFolder.Text)) {
        return;
      }

      if (!System.IO.Directory.Exists(this.textBoxOutputFolder.Text)) {       
        return;
      }
      
      /*###########################################################################
        # Get list of files in output folder.  Please note that this is a list of
        # FileInfo instances.
        ###########################################################################*/  
      
      var di = new System.IO.DirectoryInfo(this.textBoxOutputFolder.Text);
      var files = di.GetFiles(OUTPUT_FILE_PATTERN);

      /*###########################################################################
        # Add each FileInfo instance (yes you read that right) to the control
        # The control accepts Objects so we can pass these on and cast them as 
        # FileInfo classes when we get a list of selected items
        ###########################################################################*/  
      
      foreach(var file in files) {                   
        this.listOutputFiles.Items.Add(file);
      }     
    }


    private void selectInputFilesSetCheckOrUncheckState (bool checkState)
    {
      /*###########################################################################
        # For each item in the control set the checked state to the value of 
        # checkState
        ###########################################################################*/  

      for (var itemIdx = 0; itemIdx < this.selectInputFiles.Items.Count; itemIdx++)
      {
        this.selectInputFiles.SetItemChecked(itemIdx,checkState);
      }

      /*###########################################################################
        # Then autoGenerate a output file name for combined file mode 
        # (if applicable)
        ###########################################################################*/  
    
      var files = getSelectedInputFiles();
      autoGenerateAndSetOutputFileNameForCombinedFile (ref files);
    }
   
    private void buttonSelectInputFolder_Click(object sender, EventArgs e)
    {
      /*###########################################################################
        # Prompt user for input folder and if one is provided capture and save its
        # value and populate the input files list control
        ###########################################################################*/  
    
      var dr = this.selectFolderInputFolder.ShowDialog();
      if (dr == DialogResult.OK) {
        this.textBoxInputFolder.Text = this.selectFolderInputFolder.SelectedPath;
        MBA.X12.Utility.SetAppSetting(APP_SETTING_INPUT_FOLDER,this.textBoxInputFolder.Text);
        populateInputFilesList();
      }
    }
    private void buttonSelectOutputFolder_Click(object sender, EventArgs e)
    {
      /*###########################################################################
        # Prompt user for output folder and if one is provided capture and save its
        # value 
        ###########################################################################*/  

      var dr = this.selectFolderOutputFolder.ShowDialog();
      if (dr == DialogResult.OK) {
        this.textBoxOutputFolder.Text = this.selectFolderOutputFolder.SelectedPath;
        MBA.X12.Utility.SetAppSetting(APP_SETTING_OUTPUT_FOLDER,this.textBoxOutputFolder.Text);        
        populateOutputFilesList();
      }
    }

    private void doRefresh()
    {
      /*###########################################################################
        # Reload input files control, reload output files control, and 
        # (if applicable) autoGenerate a output file name for combined file mode  
        ###########################################################################*/  

      populateInputFilesList();
      populateOutputFilesList();
      var files = getSelectedInputFiles();
      autoGenerateAndSetOutputFileNameForCombinedFile (ref files);
    }

    private void buttonReloadInputFiles_Click(object sender, EventArgs e)
    {    
      doRefresh();          
    }

    private void buttonSelectAllInputFiles_Click(object sender, EventArgs e)
    {          
      selectInputFilesSetCheckOrUncheckState(true);
    }

    private void buttonUnSelectAllInputFiles_Click(object sender, EventArgs e)
    {
      selectInputFilesSetCheckOrUncheckState(false);
    }

    private List<System.IO.FileInfo> getSelectedInputFiles()
    {
      /*###########################################################################
        # Return a list of fileInfo instances for all selected items.
        # Recall that the possible selections are FileInfo instances
        ###########################################################################*/  

      var files = new List<System.IO.FileInfo>();
      foreach (var checkedItem in this.selectInputFiles.CheckedItems) {
        files.Add((System.IO.FileInfo) checkedItem);                
      }      
      return files;
    }

    private void autoGenerateAndSetOutputFileNameForCombinedFile (ref List<FileInfo> inputFiles)
    {      
      /*###########################################################################
        # Initially there is no name so reset value of control
        ###########################################################################*/  

      textBoxOutputFileName.Text = @"";

      /*###########################################################################
        # If there are no input files get out
        ###########################################################################*/  

      if (inputFiles.Count == 0) { 
        return;
      }
      
      /*###########################################################################
        # If we are not in the combine into one mode get out
        ###########################################################################*/  

      if (!combineIntoOne) {                
        return;
      }

      /*###########################################################################
        # Get index of last selection
        ###########################################################################*/  

      var lastSelection = (inputFiles.Count - 1);
      
      /*###########################################################################
        # The combined file nameing standard is DHCSmonthlyYYYYMMDD.txt
        # For example DHCSmonthly20230627.txt
        # The first 19 characters of any input file that would be combined contains
        # this value so that is what we extract and then we add the output file
        # extension and set the control value
        ###########################################################################*/  

      string outputFile = inputFiles[lastSelection].Name.Substring(0,19) + OUTPUT_FILE_EXTENSION;      
      textBoxOutputFileName.Text = outputFile.Replace(INPUT_FILE_EXTENSION,OUTPUT_FILE_EXTENSION);
    }

    private bool parseInputFiles (ref List<FileInfo> inputFiles)
    {
      /*###########################################################################
        # Get column mapping.  If there is a problem doing this, get out
        ###########################################################################*/  

      var colMaps = Spedmon.FromDHCSFiles.getReturnFileColumnMaps(mappingFile);
      if (colMaps.Count == 0)
      {
        ParseDHCSReturnFilesApp.DisplayNotice(MBA.Return.RET_ERROR,"There appears to be an issue with the column mapping file. Please contact IT.");
        return false;
      }

      string outputFile = @"";
     
      /*###########################################################################
        # If we are in combine into one mode
        ###########################################################################*/  

      if (combineIntoOne == true) {
        
        /* If no output file name provided get out */
        
        if (String.IsNullOrWhiteSpace(textBoxOutputFileName.Text)) {           
          return false;
        }

        /* Take output folder and output file name and combine */

        outputFile = System.IO.Path.Combine(textBoxOutputFolder.Text,textBoxOutputFileName.Text);          
      
        /* Create empty file out (this overwrites existing file) so we can start fresh and not append to an earlier run */

        if (!Spedmon.FromDHCSFiles.createEmptyFileOut(outputFile))
        {
          return false; 
        }
      }
      
      /*###########################################################################
        # Setup counters for progress reporting
        ###########################################################################*/  
      
      int progressPct = 0;
      int progressMax = inputFiles.Count;
      int progressCtr = 0;

      /*###########################################################################
        # Parse each file
        ###########################################################################*/  

      foreach (var inputFile in inputFiles)
      {       

        /* If we are not combining into one file we need to specify a new file name
         * for the output.  Otherwise we will use the output file name previously 
         * setup. */

        if (combineIntoOne == false) {           
          outputFile = System.IO.Path.Combine(textBoxOutputFolder.Text,inputFile.Name);
          outputFile = outputFile.Replace(INPUT_FILE_EXTENSION,OUTPUT_FILE_EXTENSION);
        }
        
        /* Parse and if there is a problem parsing, exit early */

        if (!Spedmon.FromDHCSFiles.parseReturnFile(ref colMaps,inputFile.FullName,outputFile,combineIntoOne)) {
          return false;
        }

        /* Track, calculate, and report progress */
        
        progressCtr++;
        progressPct = MBA.Util.calculateProgress(progressCtr,progressMax);
        this.backgroundWorkerParse.ReportProgress(progressPct);
      }
      return true;
    }
    private void doParseFiles()
    {
      /*###########################################################################
        # Get any and all selected files and if there are none let user know and
        # get out.
        ###########################################################################*/  

      var files = getSelectedInputFiles();
      if (files.Count == 0) { 
        ParseDHCSReturnFilesApp.DisplayNotice(MBA.Return.RET_WARNING,"Please select one or more files");
        return;
      }

      /*###########################################################################
        # If in combineIntoOne mode check for output file.  If no file name provided
        # let user know and get out
        ###########################################################################*/  

      if (combineIntoOne)
      {         
        if (String.IsNullOrWhiteSpace(textBoxOutputFileName.Text)) {           
          ParseDHCSReturnFilesApp.DisplayNotice(MBA.Return.RET_WARNING,"Please provide an output file name.");
          return;
        }
      
      }

      /*###########################################################################
        # Start parsing and let user know outcome
        ###########################################################################*/  

      if (parseInputFiles(ref files)) {
        ParseDHCSReturnFilesApp.DisplayNotice(MBA.Return.RET_SUCCESS,"Parsing completed normally");
      }
      else {
        ParseDHCSReturnFilesApp.DisplayNotice(MBA.Return.RET_WARNING,"Parsing had some issues");
      }
    }

    private void buttonParse_Click(object sender, EventArgs e)
    { 
      this.tableLayoutPanel1.Enabled = false;       
      backgroundWorkerParse.RunWorkerAsync();              
    }
    private void radioButtonCombinedMode_CheckedChanged(object sender, EventArgs e)
    {
      determineParsingMode();
       var files = getSelectedInputFiles();
       autoGenerateAndSetOutputFileNameForCombinedFile (ref files);
    }

    private void radioButtonSeperateMode_CheckedChanged(object sender, EventArgs e)
    {
      determineParsingMode();
       var files = getSelectedInputFiles();
       autoGenerateAndSetOutputFileNameForCombinedFile (ref files);

    }

    private void selectInputFiles_SelectedIndexChanged(object sender, EventArgs e)
    {
       var files = getSelectedInputFiles();
       autoGenerateAndSetOutputFileNameForCombinedFile (ref files);
    }

    private void backgroundWorkerParse_DoWork(object sender, System.ComponentModel.DoWorkEventArgs e)
    {
      doParseFiles();
    }

    private void backgroundWorkerParse_RunWorkerCompleted(object sender, System.ComponentModel.RunWorkerCompletedEventArgs e)
    {
      this.tableLayoutPanel1.Enabled = true;
      doRefresh();
    }

    private void backgroundWorkerParse_ProgressChanged(object sender, System.ComponentModel.ProgressChangedEventArgs e)
    {         
      MBA.WinFormsTaskbarProgress.SetValue(this.Handle,e.ProgressPercentage,100);
    }

    private void buttonSelectAllInputFiles_Click_1(object sender, EventArgs e)
    {
       selectInputFilesSetCheckOrUncheckState(true);
    }

    private void buttonUnSelectAllInputFiles_Click_1(object sender, EventArgs e)
    {
       selectInputFilesSetCheckOrUncheckState(false);
    }

     private void buttonOpenInputFolder_Click(object sender, EventArgs e)
     {
       MBA.X12.Utility.OpenFolder(textBoxInputFolder.Text);
     }

     private void buttonOpenOutputFolder_Click(object sender, EventArgs e)
     {
       MBA.X12.Utility.OpenFolder(textBoxOutputFolder.Text);
     }
  }
}