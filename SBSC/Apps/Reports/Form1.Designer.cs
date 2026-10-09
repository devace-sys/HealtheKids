namespace Spedmon
{
  partial class ReportsAppFormMain
  {
    /// <summary>
    /// Required designer variable.
    /// </summary>
    
    public System.ComponentModel.IContainer components = null;

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
      System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ReportsAppFormMain));
      this.listBoxClients = new System.Windows.Forms.ListBox();
      this.textBoxReportOutputFolder = new System.Windows.Forms.TextBox();
      this.label1 = new System.Windows.Forms.Label();
      this.buttonGenerateReports = new System.Windows.Forms.Button();
      this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
      this.dateTimePickerP1Start = new System.Windows.Forms.DateTimePicker();
      this.label12 = new System.Windows.Forms.Label();
      this.label8 = new System.Windows.Forms.Label();
      this.label7 = new System.Windows.Forms.Label();
      this.label2 = new System.Windows.Forms.Label();
      this.label4 = new System.Windows.Forms.Label();
      this.dateTimePickerP1End = new System.Windows.Forms.DateTimePicker();
      this.label5 = new System.Windows.Forms.Label();
      this.label6 = new System.Windows.Forms.Label();
      this.label9 = new System.Windows.Forms.Label();
      this.label10 = new System.Windows.Forms.Label();
      this.label11 = new System.Windows.Forms.Label();
      this.groupBoxFormat = new System.Windows.Forms.GroupBox();
      this.radioButtonHTML = new System.Windows.Forms.RadioButton();
      this.radioButtonXLS = new System.Windows.Forms.RadioButton();
      this.radioButtonPDF = new System.Windows.Forms.RadioButton();
      this.label13 = new System.Windows.Forms.Label();
      this.label14 = new System.Windows.Forms.Label();
      this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
      this.checkBoxShowZeros = new System.Windows.Forms.CheckBox();
      this.buttonCancelGenerateReports = new System.Windows.Forms.Button();
      this.buttonExit = new System.Windows.Forms.Button();
      this.flowLayoutPanel2 = new System.Windows.Forms.FlowLayoutPanel();
      this.label3 = new System.Windows.Forms.Label();
      this.buttonClientsSelectAll = new System.Windows.Forms.Button();
      this.buttonClientsClearAll = new System.Windows.Forms.Button();
      this.buttonClearP1StartDate = new System.Windows.Forms.Button();
      this.buttonClearP1EndDate = new System.Windows.Forms.Button();
      this.groupBoxReport = new System.Windows.Forms.GroupBox();
      this.radioButtonClaimsByServiceDate = new System.Windows.Forms.RadioButton();
      this.radioButtonClaimsByCheckDate = new System.Windows.Forms.RadioButton();
      this.flowLayoutPanel3 = new System.Windows.Forms.FlowLayoutPanel();
      this.buttonSelectFolder = new System.Windows.Forms.Button();
      this.buttonOpenOutputFolder = new System.Windows.Forms.Button();
      this.statusStrip1 = new System.Windows.Forms.StatusStrip();
      this.toolStripStatusLabelUser = new System.Windows.Forms.ToolStripStatusLabel();
      this.toolStripProgressBar1 = new System.Windows.Forms.ToolStripProgressBar();
      this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
      this.menuStrip1 = new System.Windows.Forms.MenuStrip();
      this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
      this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
      this.tableLayoutPanel1.SuspendLayout();
      this.groupBoxFormat.SuspendLayout();
      this.flowLayoutPanel1.SuspendLayout();
      this.flowLayoutPanel2.SuspendLayout();
      this.groupBoxReport.SuspendLayout();
      this.flowLayoutPanel3.SuspendLayout();
      this.statusStrip1.SuspendLayout();
      this.menuStrip1.SuspendLayout();
      this.SuspendLayout();
      // 
      // listBoxClients
      // 
      this.tableLayoutPanel1.SetColumnSpan(this.listBoxClients, 2);
      this.listBoxClients.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.listBoxClients.FormattingEnabled = true;
      this.listBoxClients.ItemHeight = 20;
      this.listBoxClients.Location = new System.Drawing.Point(247, 3);
      this.listBoxClients.Name = "listBoxClients";
      this.listBoxClients.SelectionMode = System.Windows.Forms.SelectionMode.MultiSimple;
      this.listBoxClients.Size = new System.Drawing.Size(590, 184);
      this.listBoxClients.TabIndex = 0;
      // 
      // textBoxReportOutputFolder
      // 
      this.textBoxReportOutputFolder.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.textBoxReportOutputFolder.Location = new System.Drawing.Point(247, 257);
      this.textBoxReportOutputFolder.Name = "textBoxReportOutputFolder";
      this.textBoxReportOutputFolder.Size = new System.Drawing.Size(429, 26);
      this.textBoxReportOutputFolder.TabIndex = 4;
      // 
      // label1
      // 
      this.label1.AutoSize = true;
      this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label1.Location = new System.Drawing.Point(65, 190);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(149, 20);
      this.label1.TabIndex = 5;
      this.label1.Text = "Select Start Date";
      // 
      // buttonGenerateReports
      // 
      this.buttonGenerateReports.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.buttonGenerateReports.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
      this.buttonGenerateReports.Location = new System.Drawing.Point(407, 3);
      this.buttonGenerateReports.Name = "buttonGenerateReports";
      this.buttonGenerateReports.Size = new System.Drawing.Size(173, 33);
      this.buttonGenerateReports.TabIndex = 8;
      this.buttonGenerateReports.Text = "Generate Reports";
      this.buttonGenerateReports.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
      this.buttonGenerateReports.UseVisualStyleBackColor = true;
      this.buttonGenerateReports.Click += new System.EventHandler(this.buttonGenerateReports_Click);
      // 
      // tableLayoutPanel1
      // 
      this.tableLayoutPanel1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                  | System.Windows.Forms.AnchorStyles.Left)
                  | System.Windows.Forms.AnchorStyles.Right)));
      this.tableLayoutPanel1.AutoSize = true;
      this.tableLayoutPanel1.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
      this.tableLayoutPanel1.ColumnCount = 4;
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
      this.tableLayoutPanel1.Controls.Add(this.dateTimePickerP1Start, 2, 1);
      this.tableLayoutPanel1.Controls.Add(this.label12, 0, 7);
      this.tableLayoutPanel1.Controls.Add(this.label8, 0, 1);
      this.tableLayoutPanel1.Controls.Add(this.label7, 0, 0);
      this.tableLayoutPanel1.Controls.Add(this.listBoxClients, 2, 0);
      this.tableLayoutPanel1.Controls.Add(this.textBoxReportOutputFolder, 2, 3);
      this.tableLayoutPanel1.Controls.Add(this.label2, 1, 2);
      this.tableLayoutPanel1.Controls.Add(this.label4, 1, 3);
      this.tableLayoutPanel1.Controls.Add(this.dateTimePickerP1End, 2, 2);
      this.tableLayoutPanel1.Controls.Add(this.label1, 1, 1);
      this.tableLayoutPanel1.Controls.Add(this.label5, 1, 5);
      this.tableLayoutPanel1.Controls.Add(this.label6, 1, 7);
      this.tableLayoutPanel1.Controls.Add(this.label9, 0, 2);
      this.tableLayoutPanel1.Controls.Add(this.label10, 0, 3);
      this.tableLayoutPanel1.Controls.Add(this.label11, 0, 5);
      this.tableLayoutPanel1.Controls.Add(this.groupBoxFormat, 2, 6);
      this.tableLayoutPanel1.Controls.Add(this.label13, 0, 6);
      this.tableLayoutPanel1.Controls.Add(this.label14, 1, 6);
      this.tableLayoutPanel1.Controls.Add(this.flowLayoutPanel1, 2, 7);
      this.tableLayoutPanel1.Controls.Add(this.flowLayoutPanel2, 1, 0);
      this.tableLayoutPanel1.Controls.Add(this.buttonClearP1StartDate, 3, 1);
      this.tableLayoutPanel1.Controls.Add(this.buttonClearP1EndDate, 3, 2);
      this.tableLayoutPanel1.Controls.Add(this.groupBoxReport, 2, 5);
      this.tableLayoutPanel1.Controls.Add(this.flowLayoutPanel3, 3, 3);
      this.tableLayoutPanel1.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.tableLayoutPanel1.GrowStyle = System.Windows.Forms.TableLayoutPanelGrowStyle.FixedSize;
      this.tableLayoutPanel1.Location = new System.Drawing.Point(12, 31);
      this.tableLayoutPanel1.Name = "tableLayoutPanel1";
      this.tableLayoutPanel1.RowCount = 8;
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
      this.tableLayoutPanel1.Size = new System.Drawing.Size(840, 477);
      this.tableLayoutPanel1.TabIndex = 11;
      // 
      // dateTimePickerP1Start
      // 
      this.dateTimePickerP1Start.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.dateTimePickerP1Start.Format = System.Windows.Forms.DateTimePickerFormat.Short;
      this.dateTimePickerP1Start.Location = new System.Drawing.Point(247, 193);
      this.dateTimePickerP1Start.Name = "dateTimePickerP1Start";
      this.dateTimePickerP1Start.Size = new System.Drawing.Size(190, 26);
      this.dateTimePickerP1Start.TabIndex = 28;
      // 
      // label12
      // 
      this.label12.AutoSize = true;
      this.label12.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label12.Location = new System.Drawing.Point(3, 427);
      this.label12.Name = "label12";
      this.label12.Size = new System.Drawing.Size(56, 20);
      this.label12.TabIndex = 20;
      this.label12.Text = "Step 6";
      // 
      // label8
      // 
      this.label8.AutoSize = true;
      this.label8.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label8.Location = new System.Drawing.Point(3, 190);
      this.label8.Name = "label8";
      this.label8.Size = new System.Drawing.Size(56, 20);
      this.label8.TabIndex = 19;
      this.label8.Text = "Step 2";
      // 
      // label7
      // 
      this.label7.AutoSize = true;
      this.label7.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label7.Location = new System.Drawing.Point(3, 0);
      this.label7.Name = "label7";
      this.label7.Size = new System.Drawing.Size(56, 20);
      this.label7.TabIndex = 18;
      this.label7.Text = "Step 1";
      // 
      // label2
      // 
      this.label2.AutoSize = true;
      this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label2.Location = new System.Drawing.Point(65, 222);
      this.label2.Name = "label2";
      this.label2.Size = new System.Drawing.Size(141, 20);
      this.label2.TabIndex = 11;
      this.label2.Text = "Select End Date";
      // 
      // label4
      // 
      this.label4.AutoSize = true;
      this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label4.Location = new System.Drawing.Point(65, 254);
      this.label4.Name = "label4";
      this.label4.Size = new System.Drawing.Size(176, 20);
      this.label4.TabIndex = 12;
      this.label4.Text = "Select Output Folder";
      // 
      // dateTimePickerP1End
      // 
      this.dateTimePickerP1End.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.dateTimePickerP1End.Format = System.Windows.Forms.DateTimePickerFormat.Short;
      this.dateTimePickerP1End.Location = new System.Drawing.Point(247, 225);
      this.dateTimePickerP1End.Name = "dateTimePickerP1End";
      this.dateTimePickerP1End.Size = new System.Drawing.Size(190, 26);
      this.dateTimePickerP1End.TabIndex = 13;
      // 
      // label5
      // 
      this.label5.AutoSize = true;
      this.label5.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label5.Location = new System.Drawing.Point(65, 294);
      this.label5.Name = "label5";
      this.label5.Size = new System.Drawing.Size(120, 20);
      this.label5.TabIndex = 15;
      this.label5.Text = "Select Report";
      // 
      // label6
      // 
      this.label6.AutoSize = true;
      this.label6.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label6.Location = new System.Drawing.Point(65, 427);
      this.label6.Name = "label6";
      this.label6.Size = new System.Drawing.Size(118, 20);
      this.label6.TabIndex = 17;
      this.label6.Text = "Select Option";
      // 
      // label9
      // 
      this.label9.AutoSize = true;
      this.label9.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label9.Location = new System.Drawing.Point(3, 222);
      this.label9.Name = "label9";
      this.label9.Size = new System.Drawing.Size(56, 20);
      this.label9.TabIndex = 20;
      this.label9.Text = "Step 3";
      // 
      // label10
      // 
      this.label10.AutoSize = true;
      this.label10.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label10.Location = new System.Drawing.Point(3, 254);
      this.label10.Name = "label10";
      this.label10.Size = new System.Drawing.Size(56, 20);
      this.label10.TabIndex = 21;
      this.label10.Text = "Step 4";
      // 
      // label11
      // 
      this.label11.AutoSize = true;
      this.label11.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label11.Location = new System.Drawing.Point(3, 294);
      this.label11.Name = "label11";
      this.label11.Size = new System.Drawing.Size(56, 20);
      this.label11.TabIndex = 22;
      this.label11.Text = "Step 5";
      // 
      // groupBoxFormat
      // 
      this.groupBoxFormat.Anchor = System.Windows.Forms.AnchorStyles.Top;
      this.tableLayoutPanel1.SetColumnSpan(this.groupBoxFormat, 2);
      this.groupBoxFormat.Controls.Add(this.radioButtonHTML);
      this.groupBoxFormat.Controls.Add(this.radioButtonXLS);
      this.groupBoxFormat.Controls.Add(this.radioButtonPDF);
      this.groupBoxFormat.Location = new System.Drawing.Point(247, 379);
      this.groupBoxFormat.Margin = new System.Windows.Forms.Padding(0);
      this.groupBoxFormat.Name = "groupBoxFormat";
      this.groupBoxFormat.Padding = new System.Windows.Forms.Padding(1);
      this.groupBoxFormat.Size = new System.Drawing.Size(590, 48);
      this.groupBoxFormat.TabIndex = 23;
      this.groupBoxFormat.TabStop = false;
      // 
      // radioButtonHTML
      // 
      this.radioButtonHTML.Anchor = System.Windows.Forms.AnchorStyles.None;
      this.radioButtonHTML.AutoSize = true;
      this.radioButtonHTML.Location = new System.Drawing.Point(386, 18);
      this.radioButtonHTML.Name = "radioButtonHTML";
      this.radioButtonHTML.Size = new System.Drawing.Size(70, 24);
      this.radioButtonHTML.TabIndex = 2;
      this.radioButtonHTML.Text = "HTML";
      this.radioButtonHTML.UseVisualStyleBackColor = true;
      // 
      // radioButtonXLS
      // 
      this.radioButtonXLS.Anchor = System.Windows.Forms.AnchorStyles.None;
      this.radioButtonXLS.AutoSize = true;
      this.radioButtonXLS.Location = new System.Drawing.Point(287, 18);
      this.radioButtonXLS.Name = "radioButtonXLS";
      this.radioButtonXLS.Size = new System.Drawing.Size(65, 24);
      this.radioButtonXLS.TabIndex = 1;
      this.radioButtonXLS.Text = "Excel";
      this.radioButtonXLS.UseVisualStyleBackColor = true;
      // 
      // radioButtonPDF
      // 
      this.radioButtonPDF.Anchor = System.Windows.Forms.AnchorStyles.None;
      this.radioButtonPDF.AutoSize = true;
      this.radioButtonPDF.Checked = true;
      this.radioButtonPDF.Location = new System.Drawing.Point(184, 18);
      this.radioButtonPDF.Name = "radioButtonPDF";
      this.radioButtonPDF.Size = new System.Drawing.Size(59, 24);
      this.radioButtonPDF.TabIndex = 0;
      this.radioButtonPDF.TabStop = true;
      this.radioButtonPDF.Text = "PDF";
      this.radioButtonPDF.UseVisualStyleBackColor = true;
      // 
      // label13
      // 
      this.label13.AutoSize = true;
      this.label13.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label13.Location = new System.Drawing.Point(3, 379);
      this.label13.Name = "label13";
      this.label13.Size = new System.Drawing.Size(56, 20);
      this.label13.TabIndex = 24;
      this.label13.Text = "Step 6";
      // 
      // label14
      // 
      this.label14.AutoSize = true;
      this.label14.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label14.Location = new System.Drawing.Point(65, 379);
      this.label14.Name = "label14";
      this.label14.Size = new System.Drawing.Size(122, 20);
      this.label14.TabIndex = 25;
      this.label14.Text = "Select Format";
      // 
      // flowLayoutPanel1
      // 
      this.flowLayoutPanel1.Anchor = System.Windows.Forms.AnchorStyles.Top;
      this.tableLayoutPanel1.SetColumnSpan(this.flowLayoutPanel1, 2);
      this.flowLayoutPanel1.Controls.Add(this.buttonGenerateReports);
      this.flowLayoutPanel1.Controls.Add(this.checkBoxShowZeros);
      this.flowLayoutPanel1.Controls.Add(this.buttonCancelGenerateReports);
      this.flowLayoutPanel1.Controls.Add(this.buttonExit);
      this.flowLayoutPanel1.FlowDirection = System.Windows.Forms.FlowDirection.RightToLeft;
      this.flowLayoutPanel1.Location = new System.Drawing.Point(250, 430);
      this.flowLayoutPanel1.Name = "flowLayoutPanel1";
      this.flowLayoutPanel1.Size = new System.Drawing.Size(583, 44);
      this.flowLayoutPanel1.TabIndex = 26;
      // 
      // checkBoxShowZeros
      // 
      this.checkBoxShowZeros.AutoSize = true;
      this.checkBoxShowZeros.Checked = true;
      this.checkBoxShowZeros.CheckState = System.Windows.Forms.CheckState.Checked;
      this.checkBoxShowZeros.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.checkBoxShowZeros.Location = new System.Drawing.Point(216, 3);
      this.checkBoxShowZeros.Name = "checkBoxShowZeros";
      this.checkBoxShowZeros.Size = new System.Drawing.Size(185, 20);
      this.checkBoxShowZeros.TabIndex = 30;
      this.checkBoxShowZeros.Text = "Show Records with Zeros?";
      this.checkBoxShowZeros.UseVisualStyleBackColor = true;
      // 
      // buttonCancelGenerateReports
      // 
      this.buttonCancelGenerateReports.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
      this.buttonCancelGenerateReports.Location = new System.Drawing.Point(100, 3);
      this.buttonCancelGenerateReports.Name = "buttonCancelGenerateReports";
      this.buttonCancelGenerateReports.Size = new System.Drawing.Size(110, 33);
      this.buttonCancelGenerateReports.TabIndex = 28;
      this.buttonCancelGenerateReports.Text = "Cancel";
      this.buttonCancelGenerateReports.UseVisualStyleBackColor = true;
      // 
      // buttonExit
      // 
      this.buttonExit.Anchor = System.Windows.Forms.AnchorStyles.None;
      this.buttonExit.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
      this.buttonExit.Location = new System.Drawing.Point(21, 3);
      this.buttonExit.Name = "buttonExit";
      this.buttonExit.Size = new System.Drawing.Size(73, 33);
      this.buttonExit.TabIndex = 27;
      this.buttonExit.Text = "Exit";
      this.buttonExit.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
      this.buttonExit.UseVisualStyleBackColor = true;
      this.buttonExit.Click += new System.EventHandler(this.buttonExit_Click);
      // 
      // flowLayoutPanel2
      // 
      this.flowLayoutPanel2.Controls.Add(this.label3);
      this.flowLayoutPanel2.Controls.Add(this.buttonClientsSelectAll);
      this.flowLayoutPanel2.Controls.Add(this.buttonClientsClearAll);
      this.flowLayoutPanel2.Location = new System.Drawing.Point(65, 3);
      this.flowLayoutPanel2.Name = "flowLayoutPanel2";
      this.flowLayoutPanel2.Size = new System.Drawing.Size(176, 121);
      this.flowLayoutPanel2.TabIndex = 27;
      // 
      // label3
      // 
      this.label3.AutoSize = true;
      this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.label3.Location = new System.Drawing.Point(3, 0);
      this.label3.Name = "label3";
      this.label3.Padding = new System.Windows.Forms.Padding(0, 0, 0, 10);
      this.label3.Size = new System.Drawing.Size(132, 30);
      this.label3.TabIndex = 8;
      this.label3.Text = "Select Client(s)";
      // 
      // buttonClientsSelectAll
      // 
      this.buttonClientsSelectAll.Location = new System.Drawing.Point(3, 33);
      this.buttonClientsSelectAll.Name = "buttonClientsSelectAll";
      this.buttonClientsSelectAll.Size = new System.Drawing.Size(173, 34);
      this.buttonClientsSelectAll.TabIndex = 9;
      this.buttonClientsSelectAll.Text = "Select All Clients";
      this.buttonClientsSelectAll.UseVisualStyleBackColor = true;
      this.buttonClientsSelectAll.Click += new System.EventHandler(this.buttonClientsSelectAll_Click);
      // 
      // buttonClientsClearAll
      // 
      this.buttonClientsClearAll.Location = new System.Drawing.Point(3, 73);
      this.buttonClientsClearAll.Name = "buttonClientsClearAll";
      this.buttonClientsClearAll.Size = new System.Drawing.Size(173, 34);
      this.buttonClientsClearAll.TabIndex = 10;
      this.buttonClientsClearAll.Text = "Clear Selection";
      this.buttonClientsClearAll.UseVisualStyleBackColor = true;
      this.buttonClientsClearAll.Click += new System.EventHandler(this.buttonClientsClearAll_Click);
      // 
      // buttonClearP1StartDate
      // 
      this.buttonClearP1StartDate.Location = new System.Drawing.Point(682, 193);
      this.buttonClearP1StartDate.Name = "buttonClearP1StartDate";
      this.buttonClearP1StartDate.Size = new System.Drawing.Size(152, 26);
      this.buttonClearP1StartDate.TabIndex = 29;
      this.buttonClearP1StartDate.Text = "Clear Start Date";
      this.buttonClearP1StartDate.UseVisualStyleBackColor = true;
      this.buttonClearP1StartDate.Click += new System.EventHandler(this.buttonClearP1StartDate_Click);
      // 
      // buttonClearP1EndDate
      // 
      this.buttonClearP1EndDate.Location = new System.Drawing.Point(682, 225);
      this.buttonClearP1EndDate.Name = "buttonClearP1EndDate";
      this.buttonClearP1EndDate.Size = new System.Drawing.Size(152, 26);
      this.buttonClearP1EndDate.TabIndex = 30;
      this.buttonClearP1EndDate.Text = "Clear End Date";
      this.buttonClearP1EndDate.UseVisualStyleBackColor = true;
      this.buttonClearP1EndDate.Click += new System.EventHandler(this.buttonClearP1EndDate_Click);
      // 
      // groupBoxReport
      // 
      this.groupBoxReport.Anchor = System.Windows.Forms.AnchorStyles.Top;
      this.groupBoxReport.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
      this.tableLayoutPanel1.SetColumnSpan(this.groupBoxReport, 2);
      this.groupBoxReport.Controls.Add(this.radioButtonClaimsByServiceDate);
      this.groupBoxReport.Controls.Add(this.radioButtonClaimsByCheckDate);
      this.groupBoxReport.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.groupBoxReport.Location = new System.Drawing.Point(245, 294);
      this.groupBoxReport.Margin = new System.Windows.Forms.Padding(0);
      this.groupBoxReport.Name = "groupBoxReport";
      this.groupBoxReport.Padding = new System.Windows.Forms.Padding(1);
      this.groupBoxReport.Size = new System.Drawing.Size(593, 85);
      this.groupBoxReport.TabIndex = 16;
      this.groupBoxReport.TabStop = false;
      // 
      // radioButtonClaimsByServiceDate
      // 
      this.radioButtonClaimsByServiceDate.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                  | System.Windows.Forms.AnchorStyles.Left)
                  | System.Windows.Forms.AnchorStyles.Right)));
      this.radioButtonClaimsByServiceDate.AutoSize = true;
      this.radioButtonClaimsByServiceDate.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.radioButtonClaimsByServiceDate.Location = new System.Drawing.Point(14, 46);
      this.radioButtonClaimsByServiceDate.Name = "radioButtonClaimsByServiceDate";
      this.radioButtonClaimsByServiceDate.Size = new System.Drawing.Size(567, 24);
      this.radioButtonClaimsByServiceDate.TabIndex = 1;
      this.radioButtonClaimsByServiceDate.Text = "Amounts Collected by Practitioner and Date Services Rendered (One Period)";
      this.radioButtonClaimsByServiceDate.UseVisualStyleBackColor = true;
      // 
      // radioButtonClaimsByCheckDate
      // 
      this.radioButtonClaimsByCheckDate.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                  | System.Windows.Forms.AnchorStyles.Left)
                  | System.Windows.Forms.AnchorStyles.Right)));
      this.radioButtonClaimsByCheckDate.AutoSize = true;
      this.radioButtonClaimsByCheckDate.Checked = true;
      this.radioButtonClaimsByCheckDate.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.radioButtonClaimsByCheckDate.Location = new System.Drawing.Point(14, 19);
      this.radioButtonClaimsByCheckDate.Name = "radioButtonClaimsByCheckDate";
      this.radioButtonClaimsByCheckDate.Size = new System.Drawing.Size(477, 24);
      this.radioButtonClaimsByCheckDate.TabIndex = 0;
      this.radioButtonClaimsByCheckDate.TabStop = true;
      this.radioButtonClaimsByCheckDate.Text = "Amounts Collected by Practitioner and Check Date (One Period)";
      this.radioButtonClaimsByCheckDate.UseVisualStyleBackColor = true;
      // 
      // flowLayoutPanel3
      // 
      this.flowLayoutPanel3.Controls.Add(this.buttonSelectFolder);
      this.flowLayoutPanel3.Controls.Add(this.buttonOpenOutputFolder);
      this.flowLayoutPanel3.Location = new System.Drawing.Point(682, 257);
      this.flowLayoutPanel3.Name = "flowLayoutPanel3";
      this.flowLayoutPanel3.Size = new System.Drawing.Size(145, 34);
      this.flowLayoutPanel3.TabIndex = 31;
      // 
      // buttonSelectFolder
      // 
      this.buttonSelectFolder.AccessibleRole = System.Windows.Forms.AccessibleRole.TitleBar;
      this.buttonSelectFolder.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.buttonSelectFolder.Location = new System.Drawing.Point(3, 3);
      this.buttonSelectFolder.Name = "buttonSelectFolder";
      this.buttonSelectFolder.Size = new System.Drawing.Size(66, 26);
      this.buttonSelectFolder.TabIndex = 4;
      this.buttonSelectFolder.Text = "Select";
      this.buttonSelectFolder.UseVisualStyleBackColor = true;
      this.buttonSelectFolder.Click += new System.EventHandler(this.buttonSelectFolder_Click);
      // 
      // buttonOpenOutputFolder
      // 
      this.buttonOpenOutputFolder.AccessibleRole = System.Windows.Forms.AccessibleRole.TitleBar;
      this.buttonOpenOutputFolder.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.buttonOpenOutputFolder.Location = new System.Drawing.Point(75, 3);
      this.buttonOpenOutputFolder.Name = "buttonOpenOutputFolder";
      this.buttonOpenOutputFolder.Size = new System.Drawing.Size(66, 26);
      this.buttonOpenOutputFolder.TabIndex = 27;
      this.buttonOpenOutputFolder.Text = "Open";
      this.buttonOpenOutputFolder.UseVisualStyleBackColor = true;
      this.buttonOpenOutputFolder.Click += new System.EventHandler(this.buttonOpenOutputFolder_Click);
      // 
      // statusStrip1
      // 
      this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabelUser,
            this.toolStripProgressBar1,
            this.toolStripStatusLabel1});
      this.statusStrip1.Location = new System.Drawing.Point(0, 500);
      this.statusStrip1.Name = "statusStrip1";
      this.statusStrip1.RightToLeft = System.Windows.Forms.RightToLeft.Yes;
      this.statusStrip1.Size = new System.Drawing.Size(861, 22);
      this.statusStrip1.SizingGrip = false;
      this.statusStrip1.TabIndex = 12;
      this.statusStrip1.Text = "statusStrip1";
      // 
      // toolStripStatusLabelUser
      // 
      this.toolStripStatusLabelUser.Name = "toolStripStatusLabelUser";
      this.toolStripStatusLabelUser.RightToLeft = System.Windows.Forms.RightToLeft.No;
      this.toolStripStatusLabelUser.Size = new System.Drawing.Size(30, 17);
      this.toolStripStatusLabelUser.Text = "User";
      // 
      // toolStripProgressBar1
      // 
      this.toolStripProgressBar1.Name = "toolStripProgressBar1";
      this.toolStripProgressBar1.Size = new System.Drawing.Size(100, 16);
      // 
      // toolStripStatusLabel1
      // 
      this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
      this.toolStripStatusLabel1.Size = new System.Drawing.Size(39, 17);
      this.toolStripStatusLabel1.Text = "Ready";
      // 
      // menuStrip1
      // 
      this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem});
      this.menuStrip1.Location = new System.Drawing.Point(0, 0);
      this.menuStrip1.Name = "menuStrip1";
      this.menuStrip1.Size = new System.Drawing.Size(861, 24);
      this.menuStrip1.TabIndex = 13;
      this.menuStrip1.Text = "menuStrip1";
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
      // Form1
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.ClientSize = new System.Drawing.Size(861, 522);
      this.Controls.Add(this.statusStrip1);
      this.Controls.Add(this.menuStrip1);
      this.Controls.Add(this.tableLayoutPanel1);
      this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
      this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
      this.MainMenuStrip = this.menuStrip1;
      this.MaximizeBox = false;
      this.Name = "Form1";
      this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Hide;
      this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
      this.Text = "Form1";
      this.Load += new System.EventHandler(this.Form1_Load);
      this.tableLayoutPanel1.ResumeLayout(false);
      this.tableLayoutPanel1.PerformLayout();
      this.groupBoxFormat.ResumeLayout(false);
      this.groupBoxFormat.PerformLayout();
      this.flowLayoutPanel1.ResumeLayout(false);
      this.flowLayoutPanel1.PerformLayout();
      this.flowLayoutPanel2.ResumeLayout(false);
      this.flowLayoutPanel2.PerformLayout();
      this.groupBoxReport.ResumeLayout(false);
      this.groupBoxReport.PerformLayout();
      this.flowLayoutPanel3.ResumeLayout(false);
      this.statusStrip1.ResumeLayout(false);
      this.statusStrip1.PerformLayout();
      this.menuStrip1.ResumeLayout(false);
      this.menuStrip1.PerformLayout();
      this.ResumeLayout(false);
      this.PerformLayout();

    }

    #endregion

    private System.Windows.Forms.TextBox textBoxReportOutputFolder;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.Button buttonGenerateReports;
    private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.Label label4;
    private System.Windows.Forms.DateTimePicker dateTimePickerP1End;
    private System.Windows.Forms.ListBox listBoxClients;
    private System.Windows.Forms.Label label5;
    private System.Windows.Forms.GroupBox groupBoxReport;
    private System.Windows.Forms.RadioButton radioButtonClaimsByServiceDate;
    private System.Windows.Forms.RadioButton radioButtonClaimsByCheckDate;
    private System.Windows.Forms.Label label6;
    private System.Windows.Forms.Label label7;
    private System.Windows.Forms.Label label12;
    private System.Windows.Forms.Label label8;
    private System.Windows.Forms.Label label9;
    private System.Windows.Forms.Label label10;
    private System.Windows.Forms.Label label11;
    private System.Windows.Forms.GroupBox groupBoxFormat;
    private System.Windows.Forms.RadioButton radioButtonXLS;
    private System.Windows.Forms.RadioButton radioButtonPDF;
    private System.Windows.Forms.Label label13;
    private System.Windows.Forms.Label label14;
    private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
    private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel2;
    private System.Windows.Forms.Label label3;
    private System.Windows.Forms.Button buttonClientsSelectAll;
    private System.Windows.Forms.Button buttonClientsClearAll;
    private System.Windows.Forms.DateTimePicker dateTimePickerP1Start;
    private System.Windows.Forms.Button buttonClearP1StartDate;
    private System.Windows.Forms.Button buttonClearP1EndDate;
    private System.Windows.Forms.Button buttonExit;
    private System.Windows.Forms.Button buttonCancelGenerateReports;
    private System.Windows.Forms.StatusStrip statusStrip1;
    private System.Windows.Forms.MenuStrip menuStrip1;
    private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
    private System.Windows.Forms.ToolStripProgressBar toolStripProgressBar1;
    private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel1;
    private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel3;
    private System.Windows.Forms.Button buttonSelectFolder;
    private System.Windows.Forms.Button buttonOpenOutputFolder;
    private System.Windows.Forms.RadioButton radioButtonHTML;
    private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabelUser;
    private System.Windows.Forms.CheckBox checkBoxShowZeros;
  }
}

