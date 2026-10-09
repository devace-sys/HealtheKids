namespace Spedmon
{
  partial class FileUploadReviewAppFormMain
  {
    /// <summary>
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing)
    {
      if (disposing && (components != null))
      {
        components.Dispose();
      }
      base.Dispose(disposing);
    }

    #region Windows Form Designer generated code

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>

    private void InitializeComponent()
    {
      System.Windows.Forms.TreeNode treeNode1 = new System.Windows.Forms.TreeNode("Unprocessed");
      System.Windows.Forms.TreeNode treeNode2 = new System.Windows.Forms.TreeNode("Requires Review");
      System.Windows.Forms.TreeNode treeNode3 = new System.Windows.Forms.TreeNode("Filed");
      System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FileUploadReviewAppFormMain));
      this.statusStrip1 = new System.Windows.Forms.StatusStrip();
      this.toolStripStatusLabelUser = new System.Windows.Forms.ToolStripStatusLabel();
      this.splitContainer1 = new System.Windows.Forms.SplitContainer();
      this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
      this.treeViewFileUploads = new System.Windows.Forms.TreeView();
      this.toolStripFileListOptions = new System.Windows.Forms.ToolStrip();
      this.toolStripButtonRefresh = new System.Windows.Forms.ToolStripButton();
      this.toolStripButtonShowUnprocessed = new System.Windows.Forms.ToolStripButton();
      this.toolStripButtonShowReview = new System.Windows.Forms.ToolStripButton();
      this.toolStripButtonShowFiled = new System.Windows.Forms.ToolStripButton();
      this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
      this.toolStripSelectedFileOptions = new System.Windows.Forms.ToolStrip();
      this.toolStripLabelSelectedFile = new System.Windows.Forms.ToolStripLabel();
      this.toolStripButtonReplaceFile = new System.Windows.Forms.ToolStripButton();
      this.dataGridViewStatusLog = new System.Windows.Forms.DataGridView();
      this.ColumnState = new System.Windows.Forms.DataGridViewImageColumn();
      this.ColumnDateTime = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.ColumnStatusCode = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.ColumnStatusName = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.ColumnSource = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.ColumnDestination = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.ColumnNote = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.dataGridViewFormData = new System.Windows.Forms.DataGridView();
      this.ColumnQuestion = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.AnswerText = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.ColumnAnswerValue = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.richTextBoxFileSummary = new System.Windows.Forms.RichTextBox();
      this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
      this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
      this.menuStrip1 = new System.Windows.Forms.MenuStrip();
      this.flowLayoutPanel2 = new System.Windows.Forms.FlowLayoutPanel();
      this.statusStrip1.SuspendLayout();
      this.splitContainer1.Panel1.SuspendLayout();
      this.splitContainer1.Panel2.SuspendLayout();
      this.splitContainer1.SuspendLayout();
      this.tableLayoutPanel1.SuspendLayout();
      this.toolStripFileListOptions.SuspendLayout();
      this.tableLayoutPanel2.SuspendLayout();
      this.toolStripSelectedFileOptions.SuspendLayout();
      ((System.ComponentModel.ISupportInitialize)(this.dataGridViewStatusLog)).BeginInit();
      ((System.ComponentModel.ISupportInitialize)(this.dataGridViewFormData)).BeginInit();
      this.menuStrip1.SuspendLayout();
      this.SuspendLayout();
      // 
      // statusStrip1
      // 
      this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabelUser});
      this.statusStrip1.Location = new System.Drawing.Point(0, 491);
      this.statusStrip1.Name = "statusStrip1";
      this.statusStrip1.RightToLeft = System.Windows.Forms.RightToLeft.Yes;
      this.statusStrip1.Size = new System.Drawing.Size(1306, 22);
      this.statusStrip1.TabIndex = 0;
      this.statusStrip1.Text = "statusStrip1";
      // 
      // toolStripStatusLabelUser
      // 
      this.toolStripStatusLabelUser.Name = "toolStripStatusLabelUser";
      this.toolStripStatusLabelUser.Size = new System.Drawing.Size(0, 17);
      // 
      // splitContainer1
      // 
      this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
      this.splitContainer1.Location = new System.Drawing.Point(0, 24);
      this.splitContainer1.Name = "splitContainer1";
      // 
      // splitContainer1.Panel1
      // 
      this.splitContainer1.Panel1.Controls.Add(this.tableLayoutPanel1);
      // 
      // splitContainer1.Panel2
      // 
      this.splitContainer1.Panel2.Controls.Add(this.tableLayoutPanel2);
      this.splitContainer1.Size = new System.Drawing.Size(1306, 467);
      this.splitContainer1.SplitterDistance = 429;
      this.splitContainer1.TabIndex = 3;
      // 
      // tableLayoutPanel1
      // 
      this.tableLayoutPanel1.ColumnCount = 1;
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 20F));
      this.tableLayoutPanel1.Controls.Add(this.treeViewFileUploads, 0, 1);
      this.tableLayoutPanel1.Controls.Add(this.toolStripFileListOptions, 0, 0);
      this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
      this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 0);
      this.tableLayoutPanel1.Name = "tableLayoutPanel1";
      this.tableLayoutPanel1.RowCount = 2;
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 10F));
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 90F));
      this.tableLayoutPanel1.Size = new System.Drawing.Size(429, 467);
      this.tableLayoutPanel1.TabIndex = 0;
      // 
      // treeViewFileUploads
      // 
      this.treeViewFileUploads.Dock = System.Windows.Forms.DockStyle.Fill;
      this.treeViewFileUploads.FullRowSelect = true;
      this.treeViewFileUploads.HideSelection = false;
      this.treeViewFileUploads.Location = new System.Drawing.Point(3, 49);
      this.treeViewFileUploads.Name = "treeViewFileUploads";
      treeNode1.Name = "treeNodeUploadFilesUnprocessed";
      treeNode1.Text = "Unprocessed";
      treeNode1.ToolTipText = "Files that have just been uploaded";
      treeNode2.Name = "treeNodeUploadFilesRequiresReview";
      treeNode2.Text = "Requires Review";
      treeNode2.ToolTipText = "Files that require review";
      treeNode3.Name = "treeNodeUploadFilesFiled";
      treeNode3.Text = "Filed";
      treeNode3.ToolTipText = "Uploads that are ready for use";
      this.treeViewFileUploads.Nodes.AddRange(new System.Windows.Forms.TreeNode[] {
            treeNode1,
            treeNode2,
            treeNode3});
      this.treeViewFileUploads.SelectedImageKey = "NavigateForward_6271.png";
      this.treeViewFileUploads.Size = new System.Drawing.Size(423, 415);
      this.treeViewFileUploads.TabIndex = 3;
      this.treeViewFileUploads.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.treeViewFileUploads_AfterSelect);
      // 
      // toolStripFileListOptions
      // 
      this.toolStripFileListOptions.Dock = System.Windows.Forms.DockStyle.Fill;
      this.toolStripFileListOptions.GripStyle = System.Windows.Forms.ToolStripGripStyle.Hidden;
      this.toolStripFileListOptions.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripButtonRefresh,
            this.toolStripButtonShowUnprocessed,
            this.toolStripButtonShowReview,
            this.toolStripButtonShowFiled});
      this.toolStripFileListOptions.Location = new System.Drawing.Point(0, 0);
      this.toolStripFileListOptions.Name = "toolStripFileListOptions";
      this.toolStripFileListOptions.Padding = new System.Windows.Forms.Padding(1);
      this.toolStripFileListOptions.Size = new System.Drawing.Size(429, 46);
      this.toolStripFileListOptions.TabIndex = 4;
      this.toolStripFileListOptions.Text = "Uploaded Files List Options";
      // 
      // toolStripButtonRefresh
      // 
      this.toolStripButtonRefresh.Image = ((System.Drawing.Image)(resources.GetObject("toolStripButtonRefresh.Image")));
      this.toolStripButtonRefresh.ImageTransparentColor = System.Drawing.Color.Magenta;
      this.toolStripButtonRefresh.Name = "toolStripButtonRefresh";
      this.toolStripButtonRefresh.Size = new System.Drawing.Size(87, 41);
      this.toolStripButtonRefresh.Text = "Refresh List";
      this.toolStripButtonRefresh.Click += new System.EventHandler(this.toolStripButtonRefresh_Click);
      // 
      // toolStripButtonShowUnprocessed
      // 
      this.toolStripButtonShowUnprocessed.CheckOnClick = true;
      this.toolStripButtonShowUnprocessed.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
      this.toolStripButtonShowUnprocessed.Image = ((System.Drawing.Image)(resources.GetObject("toolStripButtonShowUnprocessed.Image")));
      this.toolStripButtonShowUnprocessed.ImageTransparentColor = System.Drawing.Color.Magenta;
      this.toolStripButtonShowUnprocessed.Name = "toolStripButtonShowUnprocessed";
      this.toolStripButtonShowUnprocessed.Size = new System.Drawing.Size(111, 41);
      this.toolStripButtonShowUnprocessed.Text = "Show Unprocessed";
      this.toolStripButtonShowUnprocessed.Click += new System.EventHandler(this.toolStripButtonShowUnprocessed_Click);
      // 
      // toolStripButtonShowReview
      // 
      this.toolStripButtonShowReview.Checked = true;
      this.toolStripButtonShowReview.CheckOnClick = true;
      this.toolStripButtonShowReview.CheckState = System.Windows.Forms.CheckState.Checked;
      this.toolStripButtonShowReview.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
      this.toolStripButtonShowReview.Image = ((System.Drawing.Image)(resources.GetObject("toolStripButtonShowReview.Image")));
      this.toolStripButtonShowReview.ImageTransparentColor = System.Drawing.Color.Magenta;
      this.toolStripButtonShowReview.Name = "toolStripButtonShowReview";
      this.toolStripButtonShowReview.Size = new System.Drawing.Size(128, 41);
      this.toolStripButtonShowReview.Text = "Show Requires Review";
      this.toolStripButtonShowReview.Click += new System.EventHandler(this.toolStripButtonShowReview_Click);
      // 
      // toolStripButtonShowFiled
      // 
      this.toolStripButtonShowFiled.CheckOnClick = true;
      this.toolStripButtonShowFiled.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
      this.toolStripButtonShowFiled.Image = ((System.Drawing.Image)(resources.GetObject("toolStripButtonShowFiled.Image")));
      this.toolStripButtonShowFiled.ImageTransparentColor = System.Drawing.Color.Magenta;
      this.toolStripButtonShowFiled.Name = "toolStripButtonShowFiled";
      this.toolStripButtonShowFiled.Size = new System.Drawing.Size(68, 41);
      this.toolStripButtonShowFiled.Text = "Show Filed";
      this.toolStripButtonShowFiled.Click += new System.EventHandler(this.toolStripButtonShowFiled_Click);
      // 
      // tableLayoutPanel2
      // 
      this.tableLayoutPanel2.CellBorderStyle = System.Windows.Forms.TableLayoutPanelCellBorderStyle.Single;
      this.tableLayoutPanel2.ColumnCount = 1;
      this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
      this.tableLayoutPanel2.Controls.Add(this.toolStripSelectedFileOptions, 0, 0);
      this.tableLayoutPanel2.Controls.Add(this.dataGridViewStatusLog, 0, 3);
      this.tableLayoutPanel2.Controls.Add(this.dataGridViewFormData, 0, 2);
      this.tableLayoutPanel2.Controls.Add(this.richTextBoxFileSummary, 0, 1);
      this.tableLayoutPanel2.Dock = System.Windows.Forms.DockStyle.Fill;
      this.tableLayoutPanel2.Location = new System.Drawing.Point(0, 0);
      this.tableLayoutPanel2.Name = "tableLayoutPanel2";
      this.tableLayoutPanel2.RowCount = 5;
      this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 10F));
      this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 30F));
      this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 30F));
      this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 30F));
      this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
      this.tableLayoutPanel2.Size = new System.Drawing.Size(873, 467);
      this.tableLayoutPanel2.TabIndex = 1;
      // 
      // toolStripSelectedFileOptions
      // 
      this.toolStripSelectedFileOptions.Dock = System.Windows.Forms.DockStyle.Fill;
      this.toolStripSelectedFileOptions.GripStyle = System.Windows.Forms.ToolStripGripStyle.Hidden;
      this.toolStripSelectedFileOptions.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripLabelSelectedFile,
            this.toolStripButtonReplaceFile});
      this.toolStripSelectedFileOptions.Location = new System.Drawing.Point(1, 1);
      this.toolStripSelectedFileOptions.Name = "toolStripSelectedFileOptions";
      this.toolStripSelectedFileOptions.Padding = new System.Windows.Forms.Padding(1);
      this.toolStripSelectedFileOptions.Size = new System.Drawing.Size(871, 44);
      this.toolStripSelectedFileOptions.TabIndex = 7;
      this.toolStripSelectedFileOptions.Text = "Selected File Options";
      // 
      // toolStripLabelSelectedFile
      // 
      this.toolStripLabelSelectedFile.IsLink = true;
      this.toolStripLabelSelectedFile.Name = "toolStripLabelSelectedFile";
      this.toolStripLabelSelectedFile.Size = new System.Drawing.Size(91, 39);
      this.toolStripLabelSelectedFile.Text = "No File Selected";
      this.toolStripLabelSelectedFile.Click += new System.EventHandler(this.toolStripLabelSelectedFile_Click);
      // 
      // toolStripButtonReplaceFile
      // 
      this.toolStripButtonReplaceFile.Image = ((System.Drawing.Image)(resources.GetObject("toolStripButtonReplaceFile.Image")));
      this.toolStripButtonReplaceFile.ImageTransparentColor = System.Drawing.Color.Magenta;
      this.toolStripButtonReplaceFile.Name = "toolStripButtonReplaceFile";
      this.toolStripButtonReplaceFile.Size = new System.Drawing.Size(136, 39);
      this.toolStripButtonReplaceFile.Text = "Replace Selected File";
      this.toolStripButtonReplaceFile.Click += new System.EventHandler(this.toolStripButtonReplaceFile_Click);
      // 
      // dataGridViewStatusLog
      // 
      this.dataGridViewStatusLog.AllowUserToAddRows = false;
      this.dataGridViewStatusLog.AllowUserToDeleteRows = false;
      this.dataGridViewStatusLog.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
      this.dataGridViewStatusLog.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.dataGridViewStatusLog.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.ColumnState,
            this.ColumnDateTime,
            this.ColumnStatusCode,
            this.ColumnStatusName,
            this.ColumnSource,
            this.ColumnDestination,
            this.ColumnNote});
      this.dataGridViewStatusLog.Dock = System.Windows.Forms.DockStyle.Fill;
      this.dataGridViewStatusLog.Location = new System.Drawing.Point(4, 315);
      this.dataGridViewStatusLog.MultiSelect = false;
      this.dataGridViewStatusLog.Name = "dataGridViewStatusLog";
      this.dataGridViewStatusLog.ReadOnly = true;
      this.dataGridViewStatusLog.Size = new System.Drawing.Size(865, 126);
      this.dataGridViewStatusLog.TabIndex = 5;
      // 
      // ColumnState
      // 
      this.ColumnState.HeaderText = "State";
      this.ColumnState.Name = "ColumnState";
      this.ColumnState.ReadOnly = true;
      this.ColumnState.Width = 38;
      // 
      // ColumnDateTime
      // 
      this.ColumnDateTime.HeaderText = "Date/Time";
      this.ColumnDateTime.Name = "ColumnDateTime";
      this.ColumnDateTime.ReadOnly = true;
      this.ColumnDateTime.Width = 83;
      // 
      // ColumnStatusCode
      // 
      this.ColumnStatusCode.HeaderText = "Status Code";
      this.ColumnStatusCode.Name = "ColumnStatusCode";
      this.ColumnStatusCode.ReadOnly = true;
      this.ColumnStatusCode.Width = 90;
      // 
      // ColumnStatusName
      // 
      this.ColumnStatusName.HeaderText = "Status";
      this.ColumnStatusName.Name = "ColumnStatusName";
      this.ColumnStatusName.ReadOnly = true;
      this.ColumnStatusName.Width = 62;
      // 
      // ColumnSource
      // 
      this.ColumnSource.HeaderText = "Source";
      this.ColumnSource.Name = "ColumnSource";
      this.ColumnSource.ReadOnly = true;
      this.ColumnSource.Resizable = System.Windows.Forms.DataGridViewTriState.True;
      this.ColumnSource.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
      this.ColumnSource.Width = 47;
      // 
      // ColumnDestination
      // 
      this.ColumnDestination.HeaderText = "Destination";
      this.ColumnDestination.Name = "ColumnDestination";
      this.ColumnDestination.ReadOnly = true;
      this.ColumnDestination.Resizable = System.Windows.Forms.DataGridViewTriState.True;
      this.ColumnDestination.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
      this.ColumnDestination.Width = 66;
      // 
      // ColumnNote
      // 
      this.ColumnNote.HeaderText = "Note";
      this.ColumnNote.Name = "ColumnNote";
      this.ColumnNote.ReadOnly = true;
      this.ColumnNote.Width = 55;
      // 
      // dataGridViewFormData
      // 
      this.dataGridViewFormData.AllowUserToAddRows = false;
      this.dataGridViewFormData.AllowUserToDeleteRows = false;
      this.dataGridViewFormData.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
      this.dataGridViewFormData.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.dataGridViewFormData.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.ColumnQuestion,
            this.AnswerText,
            this.ColumnAnswerValue});
      this.dataGridViewFormData.Dock = System.Windows.Forms.DockStyle.Fill;
      this.dataGridViewFormData.Location = new System.Drawing.Point(4, 182);
      this.dataGridViewFormData.MultiSelect = false;
      this.dataGridViewFormData.Name = "dataGridViewFormData";
      this.dataGridViewFormData.ReadOnly = true;
      this.dataGridViewFormData.Size = new System.Drawing.Size(865, 126);
      this.dataGridViewFormData.TabIndex = 2;
      // 
      // ColumnQuestion
      // 
      this.ColumnQuestion.HeaderText = "Question";
      this.ColumnQuestion.Name = "ColumnQuestion";
      this.ColumnQuestion.ReadOnly = true;
      this.ColumnQuestion.Width = 74;
      // 
      // AnswerText
      // 
      this.AnswerText.HeaderText = "Answer Text";
      this.AnswerText.Name = "AnswerText";
      this.AnswerText.ReadOnly = true;
      this.AnswerText.Width = 91;
      // 
      // ColumnAnswerValue
      // 
      this.ColumnAnswerValue.HeaderText = "Answer Value";
      this.ColumnAnswerValue.Name = "ColumnAnswerValue";
      this.ColumnAnswerValue.ReadOnly = true;
      this.ColumnAnswerValue.Width = 97;
      // 
      // richTextBoxFileSummary
      // 
      this.richTextBoxFileSummary.Dock = System.Windows.Forms.DockStyle.Fill;
      this.richTextBoxFileSummary.Location = new System.Drawing.Point(4, 49);
      this.richTextBoxFileSummary.Name = "richTextBoxFileSummary";
      this.richTextBoxFileSummary.ReadOnly = true;
      this.richTextBoxFileSummary.Size = new System.Drawing.Size(865, 126);
      this.richTextBoxFileSummary.TabIndex = 9;
      this.richTextBoxFileSummary.Text = "";
      // 
      // fileToolStripMenuItem
      // 
      this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.exitToolStripMenuItem});
      this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
      this.fileToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
      this.fileToolStripMenuItem.Text = "File";
      // 
      // exitToolStripMenuItem
      // 
      this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
      this.exitToolStripMenuItem.Size = new System.Drawing.Size(92, 22);
      this.exitToolStripMenuItem.Text = "Exit";
      this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
      // 
      // menuStrip1
      // 
      this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem});
      this.menuStrip1.Location = new System.Drawing.Point(0, 0);
      this.menuStrip1.Name = "menuStrip1";
      this.menuStrip1.Size = new System.Drawing.Size(1306, 24);
      this.menuStrip1.TabIndex = 2;
      this.menuStrip1.Text = "menuStrip1";
      // 
      // flowLayoutPanel2
      // 
      this.flowLayoutPanel2.Location = new System.Drawing.Point(3, 3);
      this.flowLayoutPanel2.Name = "flowLayoutPanel2";
      this.flowLayoutPanel2.Size = new System.Drawing.Size(8, 8);
      this.flowLayoutPanel2.TabIndex = 1;
      // 
      // FileUploadReviewAppFormMain
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.BackColor = System.Drawing.SystemColors.Control;
      this.ClientSize = new System.Drawing.Size(1306, 513);
      this.Controls.Add(this.splitContainer1);
      this.Controls.Add(this.statusStrip1);
      this.Controls.Add(this.menuStrip1);
      this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
      this.MainMenuStrip = this.menuStrip1;
      this.Name = "FileUploadReviewAppFormMain";
      this.Text = "Form1";
      this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
      this.Load += new System.EventHandler(this.Form1_Load);
      this.statusStrip1.ResumeLayout(false);
      this.statusStrip1.PerformLayout();
      this.splitContainer1.Panel1.ResumeLayout(false);
      this.splitContainer1.Panel2.ResumeLayout(false);
      this.splitContainer1.ResumeLayout(false);
      this.tableLayoutPanel1.ResumeLayout(false);
      this.tableLayoutPanel1.PerformLayout();
      this.toolStripFileListOptions.ResumeLayout(false);
      this.toolStripFileListOptions.PerformLayout();
      this.tableLayoutPanel2.ResumeLayout(false);
      this.tableLayoutPanel2.PerformLayout();
      this.toolStripSelectedFileOptions.ResumeLayout(false);
      this.toolStripSelectedFileOptions.PerformLayout();
      ((System.ComponentModel.ISupportInitialize)(this.dataGridViewStatusLog)).EndInit();
      ((System.ComponentModel.ISupportInitialize)(this.dataGridViewFormData)).EndInit();
      this.menuStrip1.ResumeLayout(false);
      this.menuStrip1.PerformLayout();
      this.ResumeLayout(false);
      this.PerformLayout();

    }

    #endregion
 
    private System.Windows.Forms.StatusStrip statusStrip1;
    private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabelUser;
    private System.Windows.Forms.SplitContainer splitContainer1;
    private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
    private System.Windows.Forms.MenuStrip menuStrip1;
    private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel2;
    private System.Windows.Forms.TableLayoutPanel tableLayoutPanel2;
    private System.Windows.Forms.DataGridView dataGridViewStatusLog;
    private System.Windows.Forms.DataGridView dataGridViewFormData;
    private System.Windows.Forms.DataGridViewTextBoxColumn ColumnQuestion;
    private System.Windows.Forms.DataGridViewTextBoxColumn AnswerText;
    private System.Windows.Forms.DataGridViewTextBoxColumn ColumnAnswerValue;
    private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
    private System.Windows.Forms.TreeView treeViewFileUploads;
    private System.Windows.Forms.ToolStrip toolStripFileListOptions;
    private System.Windows.Forms.ToolStripButton toolStripButtonRefresh;
    private System.Windows.Forms.ToolStrip toolStripSelectedFileOptions;
    private System.Windows.Forms.ToolStripLabel toolStripLabelSelectedFile;
    private System.Windows.Forms.ToolStripButton toolStripButtonReplaceFile;
    private System.Windows.Forms.DataGridViewImageColumn ColumnState;
    private System.Windows.Forms.DataGridViewTextBoxColumn ColumnDateTime;
    private System.Windows.Forms.DataGridViewTextBoxColumn ColumnStatusCode;
    private System.Windows.Forms.DataGridViewTextBoxColumn ColumnStatusName;
    private System.Windows.Forms.DataGridViewTextBoxColumn ColumnSource;
    private System.Windows.Forms.DataGridViewTextBoxColumn ColumnDestination;
    private System.Windows.Forms.DataGridViewTextBoxColumn ColumnNote;
    private System.Windows.Forms.RichTextBox richTextBoxFileSummary;
    private System.Windows.Forms.ToolStripButton toolStripButtonShowUnprocessed;
    private System.Windows.Forms.ToolStripButton toolStripButtonShowReview;
    private System.Windows.Forms.ToolStripButton toolStripButtonShowFiled;
  }
}

