/*
 * Created by SharpDevelop.
 * User: awebb
 * Date: 10/01/2018
 * Time: 13:59
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
namespace Parse_835_5010_WinFormsApp
{
  partial class MainForm
  {
    /// <summary>
    /// Designer variable used to keep track of non-visual components.
    /// </summary>
    private System.ComponentModel.IContainer components = null;
    private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.TextBox textBox835FileIn;
    private System.Windows.Forms.Button buttonSelect835File;
    private System.Windows.Forms.OpenFileDialog openFileDialog835In;
    private System.Windows.Forms.Button buttonParseFile;
    private System.Windows.Forms.Label label3;
    private System.Windows.Forms.TextBox textBoxZipPassword;
    private System.Windows.Forms.CheckBox checkBoxGenerateContentReport;
    private System.Windows.Forms.CheckBox checkBoxGeneratContentXML;
    private System.Windows.Forms.ListBox listBoxParsingMessages;
    private System.Windows.Forms.ListBox listBox1;
    private System.ComponentModel.BackgroundWorker backgroundWorkerParseFile;
    private System.Windows.Forms.CheckBox checkBoxGenerateCSV;
    private System.Windows.Forms.MenuStrip menuStripMain;
    private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem1;
    private System.Windows.Forms.ToolStripMenuItem openToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem saveToolStripMenuItem;
    private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
    private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem1;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.Button buttonSaveZipPwd;
    private System.Windows.Forms.NotifyIcon notifyIconStatus;
    private System.Windows.Forms.Button buttonOpenOutputFolder;
    private System.Windows.Forms.FlowLayoutPanel flowLayoutPanel1;
    private System.Windows.Forms.CheckBox checkBoxIncDetsInRept;
    
    /// <summary>
    /// Disposes resources used by the form.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing)
    {
      if (disposing) {
        if (components != null) {
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
      this.components = new System.ComponentModel.Container();
      System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
      this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
      this.label1 = new System.Windows.Forms.Label();
      this.textBox835FileIn = new System.Windows.Forms.TextBox();
      this.buttonSelect835File = new System.Windows.Forms.Button();
      this.buttonParseFile = new System.Windows.Forms.Button();
      this.label3 = new System.Windows.Forms.Label();
      this.listBoxParsingMessages = new System.Windows.Forms.ListBox();
      this.label2 = new System.Windows.Forms.Label();
      this.textBoxZipPassword = new System.Windows.Forms.TextBox();
      this.buttonSaveZipPwd = new System.Windows.Forms.Button();
      this.buttonOpenOutputFolder = new System.Windows.Forms.Button();
      this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
      this.checkBoxGeneratContentXML = new System.Windows.Forms.CheckBox();
      this.checkBoxGenerateContentReport = new System.Windows.Forms.CheckBox();
      this.checkBoxGenerateCSV = new System.Windows.Forms.CheckBox();
      this.checkBoxIncDetsInRept = new System.Windows.Forms.CheckBox();
      this.openFileDialog835In = new System.Windows.Forms.OpenFileDialog();
      this.listBox1 = new System.Windows.Forms.ListBox();
      this.backgroundWorkerParseFile = new System.ComponentModel.BackgroundWorker();
      this.menuStripMain = new System.Windows.Forms.MenuStrip();
      this.fileToolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
      this.openToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
      this.saveToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
      this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
      this.exitToolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
      this.notifyIconStatus = new System.Windows.Forms.NotifyIcon(this.components);
      this.tableLayoutPanel1.SuspendLayout();
      this.flowLayoutPanel1.SuspendLayout();
      this.menuStripMain.SuspendLayout();
      this.SuspendLayout();
      // 
      // tableLayoutPanel1
      // 
      this.tableLayoutPanel1.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
      this.tableLayoutPanel1.BackColor = System.Drawing.SystemColors.Control;
      this.tableLayoutPanel1.ColumnCount = 4;
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 25F));
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 25F));
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 25F));
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 25F));
      this.tableLayoutPanel1.Controls.Add(this.label1, 0, 0);
      this.tableLayoutPanel1.Controls.Add(this.textBox835FileIn, 1, 0);
      this.tableLayoutPanel1.Controls.Add(this.buttonSelect835File, 3, 0);
      this.tableLayoutPanel1.Controls.Add(this.buttonParseFile, 3, 3);
      this.tableLayoutPanel1.Controls.Add(this.label3, 0, 1);
      this.tableLayoutPanel1.Controls.Add(this.listBoxParsingMessages, 0, 3);
      this.tableLayoutPanel1.Controls.Add(this.label2, 0, 2);
      this.tableLayoutPanel1.Controls.Add(this.textBoxZipPassword, 1, 1);
      this.tableLayoutPanel1.Controls.Add(this.buttonSaveZipPwd, 3, 1);
      this.tableLayoutPanel1.Controls.Add(this.buttonOpenOutputFolder, 3, 4);
      this.tableLayoutPanel1.Controls.Add(this.flowLayoutPanel1, 1, 2);
      this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
      this.tableLayoutPanel1.GrowStyle = System.Windows.Forms.TableLayoutPanelGrowStyle.FixedSize;
      this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 24);
      this.tableLayoutPanel1.Name = "tableLayoutPanel1";
      this.tableLayoutPanel1.RowCount = 5;
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 20F));
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 20F));
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 20F));
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 20F));
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 20F));
      this.tableLayoutPanel1.Size = new System.Drawing.Size(704, 199);
      this.tableLayoutPanel1.TabIndex = 0;
      // 
      // label1
      // 
      this.label1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.label1.Location = new System.Drawing.Point(3, 0);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(170, 39);
      this.label1.TabIndex = 0;
      this.label1.Text = "Select 835 File To Parse";
      this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
      // 
      // textBox835FileIn
      // 
      this.textBox835FileIn.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.tableLayoutPanel1.SetColumnSpan(this.textBox835FileIn, 2);
      this.textBox835FileIn.Enabled = false;
      this.textBox835FileIn.Location = new System.Drawing.Point(179, 3);
      this.textBox835FileIn.Name = "textBox835FileIn";
      this.textBox835FileIn.Size = new System.Drawing.Size(346, 20);
      this.textBox835FileIn.TabIndex = 1;
      // 
      // buttonSelect835File
      // 
      this.buttonSelect835File.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.buttonSelect835File.Image = global::Parse_835_5010_WinFormsApp.Icons.open_Image;
      this.buttonSelect835File.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
      this.buttonSelect835File.Location = new System.Drawing.Point(531, 3);
      this.buttonSelect835File.Name = "buttonSelect835File";
      this.buttonSelect835File.Size = new System.Drawing.Size(170, 33);
      this.buttonSelect835File.TabIndex = 2;
      this.buttonSelect835File.Text = "Select 835 File";
      this.buttonSelect835File.UseVisualStyleBackColor = true;
      this.buttonSelect835File.Click += new System.EventHandler(this.ButtonSelect835FileClick);
      // 
      // buttonParseFile
      // 
      this.buttonParseFile.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.buttonParseFile.Image = global::Parse_835_5010_WinFormsApp.Icons.save_Image;
      this.buttonParseFile.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
      this.buttonParseFile.Location = new System.Drawing.Point(531, 120);
      this.buttonParseFile.Name = "buttonParseFile";
      this.buttonParseFile.Size = new System.Drawing.Size(170, 33);
      this.buttonParseFile.TabIndex = 7;
      this.buttonParseFile.Text = "Parse 835 File";
      this.buttonParseFile.UseVisualStyleBackColor = true;
      this.buttonParseFile.Click += new System.EventHandler(this.ButtonParseFileClick);
      // 
      // label3
      // 
      this.label3.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.label3.Location = new System.Drawing.Point(3, 39);
      this.label3.Name = "label3";
      this.label3.Size = new System.Drawing.Size(170, 39);
      this.label3.TabIndex = 9;
      this.label3.Text = "Enter ZIP Password";
      this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
      // 
      // listBoxParsingMessages
      // 
      this.listBoxParsingMessages.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.listBoxParsingMessages.BorderStyle = System.Windows.Forms.BorderStyle.None;
      this.tableLayoutPanel1.SetColumnSpan(this.listBoxParsingMessages, 3);
      this.listBoxParsingMessages.FormattingEnabled = true;
      this.listBoxParsingMessages.HorizontalScrollbar = true;
      this.listBoxParsingMessages.Location = new System.Drawing.Point(3, 120);
      this.listBoxParsingMessages.Name = "listBoxParsingMessages";
      this.tableLayoutPanel1.SetRowSpan(this.listBoxParsingMessages, 2);
      this.listBoxParsingMessages.Size = new System.Drawing.Size(522, 65);
      this.listBoxParsingMessages.TabIndex = 0;
      this.listBoxParsingMessages.TabStop = false;
      this.listBoxParsingMessages.UseTabStops = false;
      // 
      // label2
      // 
      this.label2.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.label2.AutoSize = true;
      this.label2.Location = new System.Drawing.Point(3, 78);
      this.label2.Name = "label2";
      this.label2.Size = new System.Drawing.Size(170, 39);
      this.label2.TabIndex = 15;
      this.label2.Text = "Select Options";
      this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
      // 
      // textBoxZipPassword
      // 
      this.textBoxZipPassword.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.tableLayoutPanel1.SetColumnSpan(this.textBoxZipPassword, 2);
      this.textBoxZipPassword.Location = new System.Drawing.Point(179, 42);
      this.textBoxZipPassword.Name = "textBoxZipPassword";
      this.textBoxZipPassword.Size = new System.Drawing.Size(346, 20);
      this.textBoxZipPassword.TabIndex = 3;
      // 
      // buttonSaveZipPwd
      // 
      this.buttonSaveZipPwd.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.buttonSaveZipPwd.Location = new System.Drawing.Point(531, 42);
      this.buttonSaveZipPwd.Name = "buttonSaveZipPwd";
      this.buttonSaveZipPwd.Size = new System.Drawing.Size(170, 33);
      this.buttonSaveZipPwd.TabIndex = 16;
      this.buttonSaveZipPwd.Text = "Save Password";
      this.buttonSaveZipPwd.UseVisualStyleBackColor = true;
      this.buttonSaveZipPwd.Click += new System.EventHandler(this.ButtonSaveZipPwdClick);
      // 
      // buttonOpenOutputFolder
      // 
      this.buttonOpenOutputFolder.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.buttonOpenOutputFolder.Location = new System.Drawing.Point(531, 159);
      this.buttonOpenOutputFolder.Name = "buttonOpenOutputFolder";
      this.buttonOpenOutputFolder.Size = new System.Drawing.Size(170, 37);
      this.buttonOpenOutputFolder.TabIndex = 17;
      this.buttonOpenOutputFolder.Text = "Open Output Folder";
      this.buttonOpenOutputFolder.UseVisualStyleBackColor = true;
      this.buttonOpenOutputFolder.Click += new System.EventHandler(this.ButtonOpenOutputFolderClick);
      // 
      // flowLayoutPanel1
      // 
      this.flowLayoutPanel1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.tableLayoutPanel1.SetColumnSpan(this.flowLayoutPanel1, 3);
      this.flowLayoutPanel1.Controls.Add(this.checkBoxGenerateCSV);
      this.flowLayoutPanel1.Controls.Add(this.checkBoxGenerateContentReport);
      this.flowLayoutPanel1.Controls.Add(this.checkBoxIncDetsInRept);
      this.flowLayoutPanel1.Controls.Add(this.checkBoxGeneratContentXML);
      this.flowLayoutPanel1.Location = new System.Drawing.Point(179, 81);
      this.flowLayoutPanel1.Name = "flowLayoutPanel1";
      this.flowLayoutPanel1.Size = new System.Drawing.Size(522, 33);
      this.flowLayoutPanel1.TabIndex = 18;
      // 
      // checkBoxGeneratContentXML
      // 
      this.checkBoxGeneratContentXML.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.checkBoxGeneratContentXML.AutoSize = true;
      this.checkBoxGeneratContentXML.Location = new System.Drawing.Point(371, 3);
      this.checkBoxGeneratContentXML.Name = "checkBoxGeneratContentXML";
      this.checkBoxGeneratContentXML.Size = new System.Drawing.Size(95, 24);
      this.checkBoxGeneratContentXML.TabIndex = 9;
      this.checkBoxGeneratContentXML.Text = "Generate XML";
      this.checkBoxGeneratContentXML.UseVisualStyleBackColor = true;
      // 
      // checkBoxGenerateContentReport
      // 
      this.checkBoxGenerateContentReport.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.checkBoxGenerateContentReport.AutoSize = true;
      this.checkBoxGenerateContentReport.Checked = true;
      this.checkBoxGenerateContentReport.CheckState = System.Windows.Forms.CheckState.Checked;
      this.checkBoxGenerateContentReport.Location = new System.Drawing.Point(103, 3);
      this.checkBoxGenerateContentReport.Name = "checkBoxGenerateContentReport";
      this.checkBoxGenerateContentReport.Size = new System.Drawing.Size(105, 24);
      this.checkBoxGenerateContentReport.TabIndex = 8;
      this.checkBoxGenerateContentReport.Text = "Generate Report";
      this.checkBoxGenerateContentReport.UseVisualStyleBackColor = true;
      // 
      // checkBoxGenerateCSV
      // 
      this.checkBoxGenerateCSV.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
      | System.Windows.Forms.AnchorStyles.Left) 
      | System.Windows.Forms.AnchorStyles.Right)));
      this.checkBoxGenerateCSV.AutoSize = true;
      this.checkBoxGenerateCSV.Checked = true;
      this.checkBoxGenerateCSV.CheckState = System.Windows.Forms.CheckState.Checked;
      this.checkBoxGenerateCSV.Location = new System.Drawing.Point(3, 3);
      this.checkBoxGenerateCSV.Name = "checkBoxGenerateCSV";
      this.checkBoxGenerateCSV.Size = new System.Drawing.Size(94, 24);
      this.checkBoxGenerateCSV.TabIndex = 7;
      this.checkBoxGenerateCSV.Text = "Generate CSV";
      this.checkBoxGenerateCSV.UseVisualStyleBackColor = true;
      // 
      // checkBoxIncDetsInRept
      // 
      this.checkBoxIncDetsInRept.Location = new System.Drawing.Point(214, 3);
      this.checkBoxIncDetsInRept.Name = "checkBoxIncDetsInRept";
      this.checkBoxIncDetsInRept.Size = new System.Drawing.Size(151, 24);
      this.checkBoxIncDetsInRept.TabIndex = 10;
      this.checkBoxIncDetsInRept.Text = "Include Details in Report";
      this.checkBoxIncDetsInRept.UseVisualStyleBackColor = true;
      // 
      // openFileDialog835In
      // 
      this.openFileDialog835In.SupportMultiDottedExtensions = true;
      // 
      // listBox1
      // 
      this.listBox1.FormattingEnabled = true;
      this.listBox1.Location = new System.Drawing.Point(0, 0);
      this.listBox1.Name = "listBox1";
      this.listBox1.Size = new System.Drawing.Size(120, 95);
      this.listBox1.TabIndex = 0;
      // 
      // backgroundWorkerParseFile
      // 
      this.backgroundWorkerParseFile.DoWork += new System.ComponentModel.DoWorkEventHandler(this.BackgroundWorkerParseFileDoWork);
      this.backgroundWorkerParseFile.RunWorkerCompleted += new System.ComponentModel.RunWorkerCompletedEventHandler(this.BackgroundWorkerParseFileRunWorkerCompleted);
      // 
      // menuStripMain
      // 
      this.menuStripMain.BackColor = System.Drawing.SystemColors.Control;
      this.menuStripMain.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
      this.fileToolStripMenuItem1});
      this.menuStripMain.Location = new System.Drawing.Point(0, 0);
      this.menuStripMain.Name = "menuStripMain";
      this.menuStripMain.RenderMode = System.Windows.Forms.ToolStripRenderMode.System;
      this.menuStripMain.Size = new System.Drawing.Size(704, 24);
      this.menuStripMain.TabIndex = 1;
      this.menuStripMain.Text = "menuStrip1";
      // 
      // fileToolStripMenuItem1
      // 
      this.fileToolStripMenuItem1.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
      this.openToolStripMenuItem,
      this.saveToolStripMenuItem,
      this.toolStripSeparator2,
      this.exitToolStripMenuItem1});
      this.fileToolStripMenuItem1.Name = "fileToolStripMenuItem1";
      this.fileToolStripMenuItem1.Size = new System.Drawing.Size(37, 20);
      this.fileToolStripMenuItem1.Text = "&File";
      // 
      // openToolStripMenuItem
      // 
      this.openToolStripMenuItem.Image = global::Parse_835_5010_WinFormsApp.Icons.open_Image;
      this.openToolStripMenuItem.ImageTransparentColor = System.Drawing.Color.Magenta;
      this.openToolStripMenuItem.Name = "openToolStripMenuItem";
      this.openToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.O)));
      this.openToolStripMenuItem.Size = new System.Drawing.Size(239, 22);
      this.openToolStripMenuItem.Text = "Select 835 File To &Open";
      this.openToolStripMenuItem.Click += new System.EventHandler(this.OpenToolStripMenuItemClick);
      // 
      // saveToolStripMenuItem
      // 
      this.saveToolStripMenuItem.Image = global::Parse_835_5010_WinFormsApp.Icons.save_Image;
      this.saveToolStripMenuItem.ImageTransparentColor = System.Drawing.Color.Magenta;
      this.saveToolStripMenuItem.Name = "saveToolStripMenuItem";
      this.saveToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S)));
      this.saveToolStripMenuItem.Size = new System.Drawing.Size(239, 22);
      this.saveToolStripMenuItem.Text = "Parse 835 File and &Save";
      this.saveToolStripMenuItem.Click += new System.EventHandler(this.SaveToolStripMenuItemClick);
      // 
      // toolStripSeparator2
      // 
      this.toolStripSeparator2.Name = "toolStripSeparator2";
      this.toolStripSeparator2.Size = new System.Drawing.Size(236, 6);
      // 
      // exitToolStripMenuItem1
      // 
      this.exitToolStripMenuItem1.Name = "exitToolStripMenuItem1";
      this.exitToolStripMenuItem1.Size = new System.Drawing.Size(239, 22);
      this.exitToolStripMenuItem1.Text = "E&xit";
      this.exitToolStripMenuItem1.Click += new System.EventHandler(this.ExitToolStripMenuItem1Click);
      // 
      // notifyIconStatus
      // 
      this.notifyIconStatus.BalloonTipIcon = System.Windows.Forms.ToolTipIcon.Info;
      this.notifyIconStatus.BalloonTipTitle = "Parse 835 File";
      this.notifyIconStatus.Icon = ((System.Drawing.Icon)(resources.GetObject("notifyIconStatus.Icon")));
      this.notifyIconStatus.Text = "Ready";
      this.notifyIconStatus.Visible = true;
      // 
      // MainForm
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.ClientSize = new System.Drawing.Size(704, 223);
      this.Controls.Add(this.tableLayoutPanel1);
      this.Controls.Add(this.menuStripMain);
      this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
      this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
      this.MainMenuStrip = this.menuStripMain;
      this.MaximizeBox = false;
      this.Name = "MainForm";
      this.Text = "Parse 835 File";
      this.tableLayoutPanel1.ResumeLayout(false);
      this.tableLayoutPanel1.PerformLayout();
      this.flowLayoutPanel1.ResumeLayout(false);
      this.flowLayoutPanel1.PerformLayout();
      this.menuStripMain.ResumeLayout(false);
      this.menuStripMain.PerformLayout();
      this.ResumeLayout(false);
      this.PerformLayout();

    }
  }
}
