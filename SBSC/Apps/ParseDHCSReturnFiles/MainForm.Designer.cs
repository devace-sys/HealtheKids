
namespace Spedmon
{
  partial class ParseDHCSReturnFilesAppFormMain
  {
    /// <summary>
    /// Designer variable used to keep track of non-visual components.
    /// </summary>
    private System.ComponentModel.IContainer components = null;
    private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
    private System.Windows.Forms.ListBox listBox1;

    /// <summary>
    /// Disposes resources used by the form.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing)
    {
      if (disposing)
      {
        if (components != null)
        {
          components.Dispose();
        }
      }
      base.Dispose(disposing);
    }

    /// <summary>
    /// This method is required for Windows Forms designer support.
    /// Do not change the method contents inside the source code editor. The Forms designer might
    /// not be able to load this method if it was changed manually.
    /// </summary>
    private void InitializeComponent()
    {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ParseDHCSReturnFilesAppFormMain));
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.groupBoxOutputFile = new System.Windows.Forms.GroupBox();
            this.textBoxOutputFileName = new System.Windows.Forms.TextBox();
            this.textBoxOutputFolder = new System.Windows.Forms.TextBox();
            this.buttonSelectInputFolder = new System.Windows.Forms.Button();
            this.buttonSelectOutputFolder = new System.Windows.Forms.Button();
            this.textBoxInputFolder = new System.Windows.Forms.TextBox();
            this.selectInputFiles = new System.Windows.Forms.CheckedListBox();
            this.buttonReloadInputFiles = new System.Windows.Forms.Button();
            this.groupBoxParsingMode = new System.Windows.Forms.GroupBox();
            this.radioButtonCombinedMode = new System.Windows.Forms.RadioButton();
            this.radioButtonSeperateMode = new System.Windows.Forms.RadioButton();
            this.buttonParse = new System.Windows.Forms.Button();
            this.listOutputFiles = new System.Windows.Forms.ListBox();
            this.listBox1 = new System.Windows.Forms.ListBox();
            this.fileToolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.exitToolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
            this.menuStripMain = new System.Windows.Forms.MenuStrip();
            this.selectFolderInputFolder = new System.Windows.Forms.FolderBrowserDialog();
            this.selectFolderOutputFolder = new System.Windows.Forms.FolderBrowserDialog();
            this.backgroundWorkerParse = new System.ComponentModel.BackgroundWorker();
            this.buttonSelectAllInputFiles = new System.Windows.Forms.Button();
            this.buttonUnSelectAllInputFiles = new System.Windows.Forms.Button();
            this.buttonOpenInputFolder = new System.Windows.Forms.Button();
            this.buttonOpenOutputFolder = new System.Windows.Forms.Button();
            this.tableLayoutPanel1.SuspendLayout();
            this.groupBoxOutputFile.SuspendLayout();
            this.groupBoxParsingMode.SuspendLayout();
            this.menuStripMain.SuspendLayout();
            this.SuspendLayout();
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.tableLayoutPanel1.BackColor = System.Drawing.SystemColors.Control;
            this.tableLayoutPanel1.ColumnCount = 4;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 40F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 10F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 40F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 10F));
            this.tableLayoutPanel1.Controls.Add(this.buttonSelectAllInputFiles, 1, 2);
            this.tableLayoutPanel1.Controls.Add(this.buttonUnSelectAllInputFiles, 1, 3);
            this.tableLayoutPanel1.Controls.Add(this.groupBoxOutputFile, 2, 4);
            this.tableLayoutPanel1.Controls.Add(this.textBoxOutputFolder, 2, 0);
            this.tableLayoutPanel1.Controls.Add(this.buttonSelectInputFolder, 1, 0);
            this.tableLayoutPanel1.Controls.Add(this.buttonSelectOutputFolder, 3, 0);
            this.tableLayoutPanel1.Controls.Add(this.textBoxInputFolder, 0, 0);
            this.tableLayoutPanel1.Controls.Add(this.selectInputFiles, 0, 1);
            this.tableLayoutPanel1.Controls.Add(this.buttonReloadInputFiles, 3, 3);
            this.tableLayoutPanel1.Controls.Add(this.groupBoxParsingMode, 0, 4);
            this.tableLayoutPanel1.Controls.Add(this.buttonParse, 3, 4);
            this.tableLayoutPanel1.Controls.Add(this.listOutputFiles, 2, 1);
            this.tableLayoutPanel1.Controls.Add(this.buttonOpenInputFolder, 1, 1);
            this.tableLayoutPanel1.Controls.Add(this.buttonOpenOutputFolder, 3, 1);
            this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel1.GrowStyle = System.Windows.Forms.TableLayoutPanelGrowStyle.FixedSize;
            this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 30);
            this.tableLayoutPanel1.Margin = new System.Windows.Forms.Padding(4);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 5;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 20F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 20F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 20F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 20F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 20F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(1296, 408);
            this.tableLayoutPanel1.TabIndex = 0;
            // 
            // groupBoxOutputFile
            // 
            this.groupBoxOutputFile.AccessibleRole = System.Windows.Forms.AccessibleRole.None;
            this.groupBoxOutputFile.Controls.Add(this.textBoxOutputFileName);
            this.groupBoxOutputFile.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBoxOutputFile.Location = new System.Drawing.Point(650, 327);
            this.groupBoxOutputFile.Name = "groupBoxOutputFile";
            this.groupBoxOutputFile.Size = new System.Drawing.Size(512, 78);
            this.groupBoxOutputFile.TabIndex = 14;
            this.groupBoxOutputFile.TabStop = false;
            this.groupBoxOutputFile.Text = "Combined File Name";
            // 
            // textBoxOutputFileName
            // 
            this.textBoxOutputFileName.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textBoxOutputFileName.Location = new System.Drawing.Point(3, 18);
            this.textBoxOutputFileName.Name = "textBoxOutputFileName";
            this.textBoxOutputFileName.Size = new System.Drawing.Size(506, 22);
            this.textBoxOutputFileName.TabIndex = 0;
            // 
            // textBoxOutputFolder
            // 
            this.textBoxOutputFolder.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textBoxOutputFolder.Location = new System.Drawing.Point(650, 3);
            this.textBoxOutputFolder.Name = "textBoxOutputFolder";
            this.textBoxOutputFolder.ReadOnly = true;
            this.textBoxOutputFolder.Size = new System.Drawing.Size(512, 22);
            this.textBoxOutputFolder.TabIndex = 6;
            // 
            // buttonSelectInputFolder
            // 
            this.buttonSelectInputFolder.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonSelectInputFolder.Location = new System.Drawing.Point(521, 3);
            this.buttonSelectInputFolder.Name = "buttonSelectInputFolder";
            this.buttonSelectInputFolder.Size = new System.Drawing.Size(123, 75);
            this.buttonSelectInputFolder.TabIndex = 2;
            this.buttonSelectInputFolder.Text = "Select Input Folder";
            this.buttonSelectInputFolder.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.buttonSelectInputFolder.UseVisualStyleBackColor = true;
            this.buttonSelectInputFolder.Click += new System.EventHandler(this.buttonSelectInputFolder_Click);
            // 
            // buttonSelectOutputFolder
            // 
            this.buttonSelectOutputFolder.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonSelectOutputFolder.Location = new System.Drawing.Point(1168, 3);
            this.buttonSelectOutputFolder.Name = "buttonSelectOutputFolder";
            this.buttonSelectOutputFolder.Size = new System.Drawing.Size(125, 75);
            this.buttonSelectOutputFolder.TabIndex = 1;
            this.buttonSelectOutputFolder.Text = "Select Output Folder";
            this.buttonSelectOutputFolder.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.buttonSelectOutputFolder.UseVisualStyleBackColor = true;
            this.buttonSelectOutputFolder.Click += new System.EventHandler(this.buttonSelectOutputFolder_Click);
            // 
            // textBoxInputFolder
            // 
            this.textBoxInputFolder.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textBoxInputFolder.Location = new System.Drawing.Point(3, 3);
            this.textBoxInputFolder.Name = "textBoxInputFolder";
            this.textBoxInputFolder.ReadOnly = true;
            this.textBoxInputFolder.Size = new System.Drawing.Size(512, 22);
            this.textBoxInputFolder.TabIndex = 3;
            // 
            // selectInputFiles
            // 
            this.selectInputFiles.CheckOnClick = true;
            this.selectInputFiles.Dock = System.Windows.Forms.DockStyle.Fill;
            this.selectInputFiles.FormattingEnabled = true;
            this.selectInputFiles.Location = new System.Drawing.Point(3, 84);
            this.selectInputFiles.Name = "selectInputFiles";
            this.tableLayoutPanel1.SetRowSpan(this.selectInputFiles, 3);
            this.selectInputFiles.Size = new System.Drawing.Size(512, 237);
            this.selectInputFiles.TabIndex = 5;
            this.selectInputFiles.SelectedIndexChanged += new System.EventHandler(this.selectInputFiles_SelectedIndexChanged);
            // 
            // buttonReloadInputFiles
            // 
            this.buttonReloadInputFiles.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonReloadInputFiles.Location = new System.Drawing.Point(1168, 246);
            this.buttonReloadInputFiles.Name = "buttonReloadInputFiles";
            this.buttonReloadInputFiles.Size = new System.Drawing.Size(125, 75);
            this.buttonReloadInputFiles.TabIndex = 9;
            this.buttonReloadInputFiles.Text = "Refresh";
            this.buttonReloadInputFiles.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.buttonReloadInputFiles.UseVisualStyleBackColor = true;
            this.buttonReloadInputFiles.Click += new System.EventHandler(this.buttonReloadInputFiles_Click);
            // 
            // groupBoxParsingMode
            // 
            this.tableLayoutPanel1.SetColumnSpan(this.groupBoxParsingMode, 2);
            this.groupBoxParsingMode.Controls.Add(this.radioButtonCombinedMode);
            this.groupBoxParsingMode.Controls.Add(this.radioButtonSeperateMode);
            this.groupBoxParsingMode.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBoxParsingMode.Location = new System.Drawing.Point(3, 327);
            this.groupBoxParsingMode.Name = "groupBoxParsingMode";
            this.groupBoxParsingMode.Size = new System.Drawing.Size(641, 78);
            this.groupBoxParsingMode.TabIndex = 10;
            this.groupBoxParsingMode.TabStop = false;
            this.groupBoxParsingMode.Text = "Parsing Mode";
            // 
            // radioButtonCombinedMode
            // 
            this.radioButtonCombinedMode.AutoSize = true;
            this.radioButtonCombinedMode.Dock = System.Windows.Forms.DockStyle.Left;
            this.radioButtonCombinedMode.Location = new System.Drawing.Point(283, 18);
            this.radioButtonCombinedMode.Name = "radioButtonCombinedMode";
            this.radioButtonCombinedMode.Size = new System.Drawing.Size(278, 57);
            this.radioButtonCombinedMode.TabIndex = 1;
            this.radioButtonCombinedMode.Text = "Parse Selected Files Into Combined File";
            this.radioButtonCombinedMode.UseVisualStyleBackColor = true;
            this.radioButtonCombinedMode.CheckedChanged += new System.EventHandler(this.radioButtonCombinedMode_CheckedChanged);
            // 
            // radioButtonSeperateMode
            // 
            this.radioButtonSeperateMode.AutoSize = true;
            this.radioButtonSeperateMode.Checked = true;
            this.radioButtonSeperateMode.Dock = System.Windows.Forms.DockStyle.Left;
            this.radioButtonSeperateMode.Location = new System.Drawing.Point(3, 18);
            this.radioButtonSeperateMode.Name = "radioButtonSeperateMode";
            this.radioButtonSeperateMode.Size = new System.Drawing.Size(280, 57);
            this.radioButtonSeperateMode.TabIndex = 0;
            this.radioButtonSeperateMode.TabStop = true;
            this.radioButtonSeperateMode.Text = "Parse Selected Files Into Seperate Files";
            this.radioButtonSeperateMode.UseVisualStyleBackColor = true;
            this.radioButtonSeperateMode.CheckedChanged += new System.EventHandler(this.radioButtonSeperateMode_CheckedChanged);
            // 
            // buttonParse
            // 
            this.buttonParse.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonParse.Location = new System.Drawing.Point(1168, 327);
            this.buttonParse.Name = "buttonParse";
            this.buttonParse.Size = new System.Drawing.Size(125, 78);
            this.buttonParse.TabIndex = 11;
            this.buttonParse.Text = "Parse";
            this.buttonParse.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.buttonParse.UseVisualStyleBackColor = true;
            this.buttonParse.Click += new System.EventHandler(this.buttonParse_Click);
            // 
            // listOutputFiles
            // 
            this.listOutputFiles.Dock = System.Windows.Forms.DockStyle.Fill;
            this.listOutputFiles.FormattingEnabled = true;
            this.listOutputFiles.ItemHeight = 16;
            this.listOutputFiles.Location = new System.Drawing.Point(650, 84);
            this.listOutputFiles.Name = "listOutputFiles";
            this.tableLayoutPanel1.SetRowSpan(this.listOutputFiles, 3);
            this.listOutputFiles.SelectionMode = System.Windows.Forms.SelectionMode.None;
            this.listOutputFiles.Size = new System.Drawing.Size(512, 237);
            this.listOutputFiles.TabIndex = 15;
            // 
            // listBox1
            // 
            this.listBox1.FormattingEnabled = true;
            this.listBox1.Location = new System.Drawing.Point(0, 0);
            this.listBox1.Name = "listBox1";
            this.listBox1.Size = new System.Drawing.Size(120, 95);
            this.listBox1.TabIndex = 0;
            // 
            // fileToolStripMenuItem1
            // 
            this.fileToolStripMenuItem1.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripSeparator2,
            this.exitToolStripMenuItem1});
            this.fileToolStripMenuItem1.Name = "fileToolStripMenuItem1";
            this.fileToolStripMenuItem1.Size = new System.Drawing.Size(46, 26);
            this.fileToolStripMenuItem1.Text = "&File";
            // 
            // toolStripSeparator2
            // 
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(113, 6);
            // 
            // exitToolStripMenuItem1
            // 
            this.exitToolStripMenuItem1.Name = "exitToolStripMenuItem1";
            this.exitToolStripMenuItem1.Size = new System.Drawing.Size(116, 26);
            this.exitToolStripMenuItem1.Text = "E&xit";
            this.exitToolStripMenuItem1.Click += new System.EventHandler(this.ExitToolStripMenuItem1Click);
            // 
            // menuStripMain
            // 
            this.menuStripMain.BackColor = System.Drawing.SystemColors.Control;
            this.menuStripMain.ImageScalingSize = new System.Drawing.Size(20, 20);
            this.menuStripMain.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem1});
            this.menuStripMain.Location = new System.Drawing.Point(0, 0);
            this.menuStripMain.Name = "menuStripMain";
            this.menuStripMain.RenderMode = System.Windows.Forms.ToolStripRenderMode.System;
            this.menuStripMain.Size = new System.Drawing.Size(1296, 30);
            this.menuStripMain.TabIndex = 1;
            this.menuStripMain.Text = "menuStrip1";
            // 
            // backgroundWorkerParse
            // 
            this.backgroundWorkerParse.WorkerReportsProgress = true;
            this.backgroundWorkerParse.DoWork += new System.ComponentModel.DoWorkEventHandler(this.backgroundWorkerParse_DoWork);
            this.backgroundWorkerParse.ProgressChanged += new System.ComponentModel.ProgressChangedEventHandler(this.backgroundWorkerParse_ProgressChanged);
            this.backgroundWorkerParse.RunWorkerCompleted += new System.ComponentModel.RunWorkerCompletedEventHandler(this.backgroundWorkerParse_RunWorkerCompleted);
            // 
            // buttonSelectAllInputFiles
            // 
            this.buttonSelectAllInputFiles.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonSelectAllInputFiles.Location = new System.Drawing.Point(521, 165);
            this.buttonSelectAllInputFiles.Name = "buttonSelectAllInputFiles";
            this.buttonSelectAllInputFiles.Size = new System.Drawing.Size(123, 75);
            this.buttonSelectAllInputFiles.TabIndex = 16;
            this.buttonSelectAllInputFiles.Text = "Select All";
            this.buttonSelectAllInputFiles.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.buttonSelectAllInputFiles.UseVisualStyleBackColor = true;
            this.buttonSelectAllInputFiles.Click += new System.EventHandler(this.buttonSelectAllInputFiles_Click_1);
            // 
            // buttonUnSelectAllInputFiles
            // 
            this.buttonUnSelectAllInputFiles.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonUnSelectAllInputFiles.Location = new System.Drawing.Point(521, 246);
            this.buttonUnSelectAllInputFiles.Name = "buttonUnSelectAllInputFiles";
            this.buttonUnSelectAllInputFiles.Size = new System.Drawing.Size(123, 75);
            this.buttonUnSelectAllInputFiles.TabIndex = 17;
            this.buttonUnSelectAllInputFiles.Text = "Unselect All";
            this.buttonUnSelectAllInputFiles.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.buttonUnSelectAllInputFiles.UseVisualStyleBackColor = true;
            this.buttonUnSelectAllInputFiles.Click += new System.EventHandler(this.buttonUnSelectAllInputFiles_Click_1);
            // 
            // buttonOpenInputFolder
            // 
            this.buttonOpenInputFolder.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonOpenInputFolder.Location = new System.Drawing.Point(521, 84);
            this.buttonOpenInputFolder.Name = "buttonOpenInputFolder";
            this.buttonOpenInputFolder.Size = new System.Drawing.Size(123, 75);
            this.buttonOpenInputFolder.TabIndex = 18;
            this.buttonOpenInputFolder.Text = "Open Input Folder";
            this.buttonOpenInputFolder.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.buttonOpenInputFolder.UseVisualStyleBackColor = true;
            this.buttonOpenInputFolder.Click += new System.EventHandler(this.buttonOpenInputFolder_Click);
            // 
            // buttonOpenOutputFolder
            // 
            this.buttonOpenOutputFolder.Dock = System.Windows.Forms.DockStyle.Fill;
            this.buttonOpenOutputFolder.Location = new System.Drawing.Point(1168, 84);
            this.buttonOpenOutputFolder.Name = "buttonOpenOutputFolder";
            this.buttonOpenOutputFolder.Size = new System.Drawing.Size(125, 75);
            this.buttonOpenOutputFolder.TabIndex = 19;
            this.buttonOpenOutputFolder.Text = "Open Output Folder";
            this.buttonOpenOutputFolder.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.buttonOpenOutputFolder.UseVisualStyleBackColor = true;
            this.buttonOpenOutputFolder.Click += new System.EventHandler(this.buttonOpenOutputFolder_Click);
            // 
            // ParseDHCSReturnFilesAppFormMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1296, 438);
            this.Controls.Add(this.tableLayoutPanel1);
            this.Controls.Add(this.menuStripMain);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MainMenuStrip = this.menuStripMain;
            this.Margin = new System.Windows.Forms.Padding(4);
            this.MaximizeBox = false;
            this.Name = "ParseDHCSReturnFilesAppFormMain";
            this.Text = "Parse DHCS Return Files";
            this.Load += new System.EventHandler(this.ParseDHCSReturnFilesAppFormMain_Load);
            this.tableLayoutPanel1.ResumeLayout(false);
            this.tableLayoutPanel1.PerformLayout();
            this.groupBoxOutputFile.ResumeLayout(false);
            this.groupBoxOutputFile.PerformLayout();
            this.groupBoxParsingMode.ResumeLayout(false);
            this.groupBoxParsingMode.PerformLayout();
            this.menuStripMain.ResumeLayout(false);
            this.menuStripMain.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

    }

        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem1;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
        private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem1;
        private System.Windows.Forms.MenuStrip menuStripMain;
        private System.Windows.Forms.FolderBrowserDialog selectFolderInputFolder;
        private System.Windows.Forms.Button buttonSelectOutputFolder;
        private System.Windows.Forms.Button buttonSelectInputFolder;
        private System.Windows.Forms.TextBox textBoxInputFolder;
        private System.Windows.Forms.FolderBrowserDialog selectFolderOutputFolder;
        private System.Windows.Forms.CheckedListBox selectInputFiles;
        private System.Windows.Forms.TextBox textBoxOutputFolder;
        private System.Windows.Forms.Button buttonReloadInputFiles;
        private System.Windows.Forms.GroupBox groupBoxParsingMode;
        private System.Windows.Forms.RadioButton radioButtonCombinedMode;
        private System.Windows.Forms.RadioButton radioButtonSeperateMode;
        private System.Windows.Forms.Button buttonParse;
        private System.ComponentModel.BackgroundWorker backgroundWorkerParse;
        private System.Windows.Forms.GroupBox groupBoxOutputFile;
        private System.Windows.Forms.TextBox textBoxOutputFileName;
        private System.Windows.Forms.ListBox listOutputFiles;
        private System.Windows.Forms.Button buttonSelectAllInputFiles;
        private System.Windows.Forms.Button buttonUnSelectAllInputFiles;
        private System.Windows.Forms.Button buttonOpenInputFolder;
        private System.Windows.Forms.Button buttonOpenOutputFolder;
    }
}
