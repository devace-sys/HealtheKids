namespace Spedmon
{
  partial class FileUploadReviewAppFormReplaceFile
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
      System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FileUploadReviewAppFormReplaceFile));
      this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
      this.linkLabelReplacementFile = new System.Windows.Forms.LinkLabel();
      this.linkLabelSelectedFile = new System.Windows.Forms.LinkLabel();
      this.buttonCancel = new System.Windows.Forms.Button();
      this.buttonSelectReplacementFile = new System.Windows.Forms.Button();
      this.checkBoxReplaceFileConfirm = new System.Windows.Forms.CheckBox();
      this.buttonProceed = new System.Windows.Forms.Button();
      this.label1 = new System.Windows.Forms.Label();
      this.label2 = new System.Windows.Forms.Label();
      this.openFileDialogReplacement = new System.Windows.Forms.OpenFileDialog();
      this.tableLayoutPanel1.SuspendLayout();
      this.SuspendLayout();
      // 
      // tableLayoutPanel1
      // 
      this.tableLayoutPanel1.ColumnCount = 2;
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
      this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
      this.tableLayoutPanel1.Controls.Add(this.linkLabelReplacementFile, 0, 3);
      this.tableLayoutPanel1.Controls.Add(this.linkLabelSelectedFile, 0, 1);
      this.tableLayoutPanel1.Controls.Add(this.buttonCancel, 0, 5);
      this.tableLayoutPanel1.Controls.Add(this.buttonSelectReplacementFile, 0, 4);
      this.tableLayoutPanel1.Controls.Add(this.checkBoxReplaceFileConfirm, 1, 4);
      this.tableLayoutPanel1.Controls.Add(this.buttonProceed, 1, 5);
      this.tableLayoutPanel1.Controls.Add(this.label1, 0, 0);
      this.tableLayoutPanel1.Controls.Add(this.label2, 0, 2);
      this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
      this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 0);
      this.tableLayoutPanel1.Name = "tableLayoutPanel1";
      this.tableLayoutPanel1.RowCount = 6;
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
      this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 16.66667F));
      this.tableLayoutPanel1.Size = new System.Drawing.Size(394, 271);
      this.tableLayoutPanel1.TabIndex = 0;
      // 
      // linkLabelReplacementFile
      // 
      this.linkLabelReplacementFile.AutoSize = true;
      this.tableLayoutPanel1.SetColumnSpan(this.linkLabelReplacementFile, 2);
      this.linkLabelReplacementFile.Dock = System.Windows.Forms.DockStyle.Fill;
      this.linkLabelReplacementFile.Location = new System.Drawing.Point(3, 135);
      this.linkLabelReplacementFile.Name = "linkLabelReplacementFile";
      this.linkLabelReplacementFile.Size = new System.Drawing.Size(388, 45);
      this.linkLabelReplacementFile.TabIndex = 2;
      this.linkLabelReplacementFile.TabStop = true;
      this.linkLabelReplacementFile.Text = "No File Selected";
      this.linkLabelReplacementFile.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
      this.linkLabelReplacementFile.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkLabelReplacementFile_LinkClicked);
      // 
      // linkLabelSelectedFile
      // 
      this.linkLabelSelectedFile.AutoSize = true;
      this.tableLayoutPanel1.SetColumnSpan(this.linkLabelSelectedFile, 2);
      this.linkLabelSelectedFile.Dock = System.Windows.Forms.DockStyle.Fill;
      this.linkLabelSelectedFile.Location = new System.Drawing.Point(3, 45);
      this.linkLabelSelectedFile.Name = "linkLabelSelectedFile";
      this.linkLabelSelectedFile.Size = new System.Drawing.Size(388, 45);
      this.linkLabelSelectedFile.TabIndex = 1;
      this.linkLabelSelectedFile.TabStop = true;
      this.linkLabelSelectedFile.Text = "No File Selected";
      this.linkLabelSelectedFile.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
      this.linkLabelSelectedFile.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkLabelSelectedFile_LinkClicked);
      // 
      // buttonCancel
      // 
      this.buttonCancel.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
      this.buttonCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
      this.buttonCancel.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
      this.buttonCancel.Location = new System.Drawing.Point(48, 243);
      this.buttonCancel.Name = "buttonCancel";
      this.buttonCancel.Padding = new System.Windows.Forms.Padding(1);
      this.buttonCancel.Size = new System.Drawing.Size(100, 25);
      this.buttonCancel.TabIndex = 6;
      this.buttonCancel.Text = "Cancel";
      this.buttonCancel.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
      this.buttonCancel.UseVisualStyleBackColor = true;
      this.buttonCancel.Click += new System.EventHandler(this.buttonCancel_Click);
      // 
      // buttonSelectReplacementFile
      // 
      this.buttonSelectReplacementFile.Anchor = System.Windows.Forms.AnchorStyles.Top;
      this.buttonSelectReplacementFile.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
      this.buttonSelectReplacementFile.Location = new System.Drawing.Point(23, 183);
      this.buttonSelectReplacementFile.Name = "buttonSelectReplacementFile";
      this.buttonSelectReplacementFile.Padding = new System.Windows.Forms.Padding(1);
      this.buttonSelectReplacementFile.Size = new System.Drawing.Size(150, 25);
      this.buttonSelectReplacementFile.TabIndex = 3;
      this.buttonSelectReplacementFile.Text = "Select Replacement File";
      this.buttonSelectReplacementFile.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
      this.buttonSelectReplacementFile.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
      this.buttonSelectReplacementFile.UseVisualStyleBackColor = true;
      this.buttonSelectReplacementFile.Click += new System.EventHandler(this.buttonSelectReplacementFile_Click);
      // 
      // checkBoxReplaceFileConfirm
      // 
      this.checkBoxReplaceFileConfirm.Anchor = System.Windows.Forms.AnchorStyles.Top;
      this.checkBoxReplaceFileConfirm.AutoSize = true;
      this.checkBoxReplaceFileConfirm.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
      this.checkBoxReplaceFileConfirm.Location = new System.Drawing.Point(207, 183);
      this.checkBoxReplaceFileConfirm.Name = "checkBoxReplaceFileConfirm";
      this.checkBoxReplaceFileConfirm.Padding = new System.Windows.Forms.Padding(5);
      this.checkBoxReplaceFileConfirm.Size = new System.Drawing.Size(176, 27);
      this.checkBoxReplaceFileConfirm.TabIndex = 4;
      this.checkBoxReplaceFileConfirm.Text = "I Am Sure I Want To Proceed";
      this.checkBoxReplaceFileConfirm.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
      this.checkBoxReplaceFileConfirm.UseVisualStyleBackColor = true;
      this.checkBoxReplaceFileConfirm.CheckedChanged += new System.EventHandler(this.checkBoxReplaceFileConfirm_CheckedChanged);
      // 
      // buttonProceed
      // 
      this.buttonProceed.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
      this.buttonProceed.DialogResult = System.Windows.Forms.DialogResult.OK;
      this.buttonProceed.Enabled = false;
      this.buttonProceed.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
      this.buttonProceed.Location = new System.Drawing.Point(245, 243);
      this.buttonProceed.Name = "buttonProceed";
      this.buttonProceed.Padding = new System.Windows.Forms.Padding(1);
      this.buttonProceed.Size = new System.Drawing.Size(100, 25);
      this.buttonProceed.TabIndex = 5;
      this.buttonProceed.Text = "Proceed";
      this.buttonProceed.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
      this.buttonProceed.UseVisualStyleBackColor = true;
      this.buttonProceed.Click += new System.EventHandler(this.buttonProceed_Click);
      // 
      // label1
      // 
      this.label1.AutoSize = true;
      this.tableLayoutPanel1.SetColumnSpan(this.label1, 2);
      this.label1.Dock = System.Windows.Forms.DockStyle.Fill;
      this.label1.Location = new System.Drawing.Point(3, 0);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(388, 45);
      this.label1.TabIndex = 0;
      this.label1.Text = "Existing File";
      this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
      // 
      // label2
      // 
      this.label2.AutoSize = true;
      this.tableLayoutPanel1.SetColumnSpan(this.label2, 2);
      this.label2.Dock = System.Windows.Forms.DockStyle.Fill;
      this.label2.Location = new System.Drawing.Point(3, 90);
      this.label2.Name = "label2";
      this.label2.Size = new System.Drawing.Size(388, 45);
      this.label2.TabIndex = 0;
      this.label2.Text = "Replacement File";
      this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
      // 
      // openFileDialogReplacement
      // 
      this.openFileDialogReplacement.FileName = "openFileDialog1";
      // 
      // FileUploadReviewAppFormReplaceFile
      // 
      this.AcceptButton = this.buttonProceed;
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.BackColor = System.Drawing.SystemColors.ControlLight;
      this.CancelButton = this.buttonCancel;
      this.ClientSize = new System.Drawing.Size(394, 271);
      this.Controls.Add(this.tableLayoutPanel1);
      this.ForeColor = System.Drawing.SystemColors.ControlText;
      this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
      this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
      this.MaximizeBox = false;
      this.MinimizeBox = false;
      this.Name = "FileUploadReviewAppFormReplaceFile";
      this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
      this.Text = "Replace File";
      this.tableLayoutPanel1.ResumeLayout(false);
      this.tableLayoutPanel1.PerformLayout();
      this.ResumeLayout(false);

    }

    #endregion

    private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
    private System.Windows.Forms.OpenFileDialog openFileDialogReplacement;
    private System.Windows.Forms.Button buttonSelectReplacementFile;
    private System.Windows.Forms.LinkLabel linkLabelSelectedFile;
    private System.Windows.Forms.Button buttonCancel;
    private System.Windows.Forms.LinkLabel linkLabelReplacementFile;
    private System.Windows.Forms.CheckBox checkBoxReplaceFileConfirm;
    private System.Windows.Forms.Button buttonProceed;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.Label label2;
  }
}