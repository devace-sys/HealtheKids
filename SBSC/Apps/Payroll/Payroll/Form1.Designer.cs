namespace Payroll
{
  partial class Form1
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
        this.components = new System.ComponentModel.Container();
        this.payrollbutton = new System.Windows.Forms.Button();
        this.claimLinesbutton = new System.Windows.Forms.Button();
        this.startdateTimePicker = new System.Windows.Forms.DateTimePicker();
        this.enddateTimePicker = new System.Windows.Forms.DateTimePicker();
        this.empcomboBox = new System.Windows.Forms.ComboBox();
        this.label1 = new System.Windows.Forms.Label();
        this.label2 = new System.Windows.Forms.Label();
        this.label3 = new System.Windows.Forms.Label();
        this.statuslabel = new System.Windows.Forms.Label();
        this.accountabilitybutton = new System.Windows.Forms.Button();
        this.menuStrip1 = new System.Windows.Forms.MenuStrip();
        this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.editToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.cutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.copyToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.pasteToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.changeRateToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.changeRemoteFlagToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.changeJobTitleToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.helpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.howToToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
        this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
        this.mbatextBox = new System.Windows.Forms.TextBox();
        this.dougtextBox = new System.Windows.Forms.TextBox();
        this.douglabel = new System.Windows.Forms.Label();
        this.mbalabel = new System.Windows.Forms.Label();
        this.radioButton1 = new System.Windows.Forms.RadioButton();
        this.radioButton2 = new System.Windows.Forms.RadioButton();
        this.hidebutton = new System.Windows.Forms.Button();
        this.chngtitletextBox = new System.Windows.Forms.TextBox();
        this.chngtitlelabel = new System.Windows.Forms.Label();
        this.chngTitlebutton = new System.Windows.Forms.Button();
        this.staffInfobutton = new System.Windows.Forms.Button();
        this.menuStrip1.SuspendLayout();
        this.SuspendLayout();
        // 
        // payrollbutton
        // 
        this.payrollbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.payrollbutton.Location = new System.Drawing.Point(468, 66);
        this.payrollbutton.Name = "payrollbutton";
        this.payrollbutton.Size = new System.Drawing.Size(113, 42);
        this.payrollbutton.TabIndex = 0;
        this.payrollbutton.Text = "Payroll Hours";
        this.payrollbutton.UseVisualStyleBackColor = true;
        this.payrollbutton.Click += new System.EventHandler(this.payrollbutton_Click);
        // 
        // claimLinesbutton
        // 
        this.claimLinesbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.claimLinesbutton.Location = new System.Drawing.Point(468, 183);
        this.claimLinesbutton.Name = "claimLinesbutton";
        this.claimLinesbutton.Size = new System.Drawing.Size(113, 42);
        this.claimLinesbutton.TabIndex = 3;
        this.claimLinesbutton.Text = "Claim Lines PerHour";
        this.claimLinesbutton.UseVisualStyleBackColor = true;
        this.claimLinesbutton.Click += new System.EventHandler(this.claimLinesbutton_Click);
        // 
        // startdateTimePicker
        // 
        this.startdateTimePicker.Format = System.Windows.Forms.DateTimePickerFormat.Short;
        this.startdateTimePicker.Location = new System.Drawing.Point(218, 126);
        this.startdateTimePicker.Name = "startdateTimePicker";
        this.startdateTimePicker.Size = new System.Drawing.Size(174, 20);
        this.startdateTimePicker.TabIndex = 4;
        this.toolTip1.SetToolTip(this.startdateTimePicker, "Select StartDate by clicking the down arrow.");
        // 
        // enddateTimePicker
        // 
        this.enddateTimePicker.Format = System.Windows.Forms.DateTimePickerFormat.Short;
        this.enddateTimePicker.Location = new System.Drawing.Point(218, 194);
        this.enddateTimePicker.Name = "enddateTimePicker";
        this.enddateTimePicker.Size = new System.Drawing.Size(174, 20);
        this.enddateTimePicker.TabIndex = 5;
        this.toolTip1.SetToolTip(this.enddateTimePicker, "Select EndDate by clicking the down arrow.");
        // 
        // empcomboBox
        // 
        this.empcomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
        this.empcomboBox.FormattingEnabled = true;
        this.empcomboBox.Location = new System.Drawing.Point(218, 254);
        this.empcomboBox.Name = "empcomboBox";
        this.empcomboBox.Size = new System.Drawing.Size(174, 21);
        this.empcomboBox.TabIndex = 6;
        this.toolTip1.SetToolTip(this.empcomboBox, "Select an Employee.");
        // 
        // label1
        // 
        this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.label1.Location = new System.Drawing.Point(82, 255);
        this.label1.Name = "label1";
        this.label1.Size = new System.Drawing.Size(133, 23);
        this.label1.TabIndex = 7;
        this.label1.Text = "Select Employee:";
        this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
        // 
        // label2
        // 
        this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.label2.Location = new System.Drawing.Point(134, 197);
        this.label2.Name = "label2";
        this.label2.Size = new System.Drawing.Size(83, 23);
        this.label2.TabIndex = 8;
        this.label2.Text = "End Date:";
        this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
        // 
        // label3
        // 
        this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.label3.Location = new System.Drawing.Point(129, 130);
        this.label3.Name = "label3";
        this.label3.Size = new System.Drawing.Size(89, 23);
        this.label3.TabIndex = 9;
        this.label3.Text = "Start Date:";
        this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
        // 
        // statuslabel
        // 
        this.statuslabel.BackColor = System.Drawing.SystemColors.ActiveCaptionText;
        this.statuslabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))), System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.statuslabel.ForeColor = System.Drawing.SystemColors.Desktop;
        this.statuslabel.Location = new System.Drawing.Point(23, 352);
        this.statuslabel.Name = "statuslabel";
        this.statuslabel.Size = new System.Drawing.Size(603, 23);
        this.statuslabel.TabIndex = 11;
        this.statuslabel.Text = "Processing Please wait.......................";
        this.statuslabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        // 
        // accountabilitybutton
        // 
        this.accountabilitybutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.accountabilitybutton.Location = new System.Drawing.Point(467, 126);
        this.accountabilitybutton.Name = "accountabilitybutton";
        this.accountabilitybutton.Size = new System.Drawing.Size(113, 42);
        this.accountabilitybutton.TabIndex = 12;
        this.accountabilitybutton.Text = "Accountability";
        this.accountabilitybutton.UseVisualStyleBackColor = true;
        this.accountabilitybutton.Click += new System.EventHandler(this.accountabilitybutton_Click);
        // 
        // menuStrip1
        // 
        this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.editToolStripMenuItem,
            this.helpToolStripMenuItem});
        this.menuStrip1.Location = new System.Drawing.Point(0, 0);
        this.menuStrip1.Name = "menuStrip1";
        this.menuStrip1.Size = new System.Drawing.Size(652, 24);
        this.menuStrip1.TabIndex = 13;
        this.menuStrip1.Text = "menuStrip1";
        // 
        // fileToolStripMenuItem
        // 
        this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.exitToolStripMenuItem});
        this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
        this.fileToolStripMenuItem.Size = new System.Drawing.Size(35, 20);
        this.fileToolStripMenuItem.Text = "File";
        // 
        // exitToolStripMenuItem
        // 
        this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
        this.exitToolStripMenuItem.Size = new System.Drawing.Size(103, 22);
        this.exitToolStripMenuItem.Text = "Exit";
        this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
        // 
        // editToolStripMenuItem
        // 
        this.editToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.cutToolStripMenuItem,
            this.copyToolStripMenuItem,
            this.pasteToolStripMenuItem,
            this.changeRateToolStripMenuItem,
            this.changeRemoteFlagToolStripMenuItem,
            this.changeJobTitleToolStripMenuItem});
        this.editToolStripMenuItem.Name = "editToolStripMenuItem";
        this.editToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
        this.editToolStripMenuItem.Text = "Edit";
        // 
        // cutToolStripMenuItem
        // 
        this.cutToolStripMenuItem.Name = "cutToolStripMenuItem";
        this.cutToolStripMenuItem.Size = new System.Drawing.Size(183, 22);
        this.cutToolStripMenuItem.Text = "Cut";
        // 
        // copyToolStripMenuItem
        // 
        this.copyToolStripMenuItem.Name = "copyToolStripMenuItem";
        this.copyToolStripMenuItem.Size = new System.Drawing.Size(183, 22);
        this.copyToolStripMenuItem.Text = "Copy";
        // 
        // pasteToolStripMenuItem
        // 
        this.pasteToolStripMenuItem.Name = "pasteToolStripMenuItem";
        this.pasteToolStripMenuItem.Size = new System.Drawing.Size(183, 22);
        this.pasteToolStripMenuItem.Text = "Paste";
        // 
        // changeRateToolStripMenuItem
        // 
        this.changeRateToolStripMenuItem.Name = "changeRateToolStripMenuItem";
        this.changeRateToolStripMenuItem.Size = new System.Drawing.Size(183, 22);
        this.changeRateToolStripMenuItem.Text = "Change_Rate";
        this.changeRateToolStripMenuItem.Click += new System.EventHandler(this.changeRateToolStripMenuItem_Click);
        // 
        // changeRemoteFlagToolStripMenuItem
        // 
        this.changeRemoteFlagToolStripMenuItem.Name = "changeRemoteFlagToolStripMenuItem";
        this.changeRemoteFlagToolStripMenuItem.Size = new System.Drawing.Size(183, 22);
        this.changeRemoteFlagToolStripMenuItem.Text = "Change Remote flag";
        this.changeRemoteFlagToolStripMenuItem.Click += new System.EventHandler(this.changeRemoteFlagToolStripMenuItem_Click);
        // 
        // changeJobTitleToolStripMenuItem
        // 
        this.changeJobTitleToolStripMenuItem.Name = "changeJobTitleToolStripMenuItem";
        this.changeJobTitleToolStripMenuItem.Size = new System.Drawing.Size(183, 22);
        this.changeJobTitleToolStripMenuItem.Text = "Change JobTitle";
        this.changeJobTitleToolStripMenuItem.Click += new System.EventHandler(this.changeJobTitleToolStripMenuItem_Click);
        // 
        // helpToolStripMenuItem
        // 
        this.helpToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.howToToolStripMenuItem});
        this.helpToolStripMenuItem.Name = "helpToolStripMenuItem";
        this.helpToolStripMenuItem.Size = new System.Drawing.Size(40, 20);
        this.helpToolStripMenuItem.Text = "Help";
        // 
        // howToToolStripMenuItem
        // 
        this.howToToolStripMenuItem.Name = "howToToolStripMenuItem";
        this.howToToolStripMenuItem.Size = new System.Drawing.Size(121, 22);
        this.howToToolStripMenuItem.Text = "How To";
        // 
        // toolTip1
        // 
        this.toolTip1.AutoPopDelay = 5000;
        this.toolTip1.InitialDelay = 100;
        this.toolTip1.ReshowDelay = 100;
        // 
        // mbatextBox
        // 
        this.mbatextBox.Location = new System.Drawing.Point(215, 389);
        this.mbatextBox.Name = "mbatextBox";
        this.mbatextBox.Size = new System.Drawing.Size(63, 20);
        this.mbatextBox.TabIndex = 14;
        // 
        // dougtextBox
        // 
        this.dougtextBox.Location = new System.Drawing.Point(491, 387);
        this.dougtextBox.Name = "dougtextBox";
        this.dougtextBox.Size = new System.Drawing.Size(49, 20);
        this.dougtextBox.TabIndex = 15;
        // 
        // douglabel
        // 
        this.douglabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.douglabel.Location = new System.Drawing.Point(327, 389);
        this.douglabel.Name = "douglabel";
        this.douglabel.Size = new System.Drawing.Size(164, 23);
        this.douglabel.TabIndex = 16;
        this.douglabel.Text = "Doug Osanna,Sr. rate:";
        // 
        // mbalabel
        // 
        this.mbalabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.mbalabel.Location = new System.Drawing.Point(90, 391);
        this.mbalabel.Name = "mbalabel";
        this.mbalabel.Size = new System.Drawing.Size(125, 23);
        this.mbalabel.TabIndex = 17;
        this.mbalabel.Text = "MBA billing rate:";
        // 
        // radioButton1
        // 
        this.radioButton1.AutoSize = true;
        this.radioButton1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.radioButton1.Location = new System.Drawing.Point(218, 291);
        this.radioButton1.Name = "radioButton1";
        this.radioButton1.Size = new System.Drawing.Size(75, 19);
        this.radioButton1.TabIndex = 20;
        this.radioButton1.TabStop = true;
        this.radioButton1.Text = "Remote";
        this.radioButton1.UseVisualStyleBackColor = true;
        this.radioButton1.CheckedChanged += new System.EventHandler(this.radioButton1_CheckedChanged);
        // 
        // radioButton2
        // 
        this.radioButton2.AutoSize = true;
        this.radioButton2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.radioButton2.Location = new System.Drawing.Point(299, 291);
        this.radioButton2.Name = "radioButton2";
        this.radioButton2.Size = new System.Drawing.Size(105, 19);
        this.radioButton2.TabIndex = 21;
        this.radioButton2.TabStop = true;
        this.radioButton2.Text = "Non Remote";
        this.radioButton2.UseVisualStyleBackColor = true;
        this.radioButton2.CheckedChanged += new System.EventHandler(this.radioButton2_CheckedChanged);
        // 
        // hidebutton
        // 
        this.hidebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.hidebutton.Location = new System.Drawing.Point(468, 296);
        this.hidebutton.Name = "hidebutton";
        this.hidebutton.Size = new System.Drawing.Size(112, 23);
        this.hidebutton.TabIndex = 22;
        this.hidebutton.Text = "Hide Options";
        this.hidebutton.UseVisualStyleBackColor = true;
        this.hidebutton.Click += new System.EventHandler(this.hidebutton_Click);
        // 
        // chngtitletextBox
        // 
        this.chngtitletextBox.Location = new System.Drawing.Point(215, 317);
        this.chngtitletextBox.Name = "chngtitletextBox";
        this.chngtitletextBox.Size = new System.Drawing.Size(177, 20);
        this.chngtitletextBox.TabIndex = 23;
        // 
        // chngtitlelabel
        // 
        this.chngtitlelabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.chngtitlelabel.Location = new System.Drawing.Point(48, 315);
        this.chngtitlelabel.Name = "chngtitlelabel";
        this.chngtitlelabel.Size = new System.Drawing.Size(165, 23);
        this.chngtitlelabel.TabIndex = 24;
        this.chngtitlelabel.Text = "Enter new job title:";
        this.chngtitlelabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
        // 
        // chngTitlebutton
        // 
        this.chngTitlebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.chngTitlebutton.Location = new System.Drawing.Point(468, 329);
        this.chngTitlebutton.Name = "chngTitlebutton";
        this.chngTitlebutton.Size = new System.Drawing.Size(111, 23);
        this.chngTitlebutton.TabIndex = 25;
        this.chngTitlebutton.Text = "Change Job Title";
        this.chngTitlebutton.UseVisualStyleBackColor = true;
        this.chngTitlebutton.Click += new System.EventHandler(this.chngTitlebutton_Click);
        // 
        // staffInfobutton
        // 
        this.staffInfobutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
        this.staffInfobutton.Location = new System.Drawing.Point(468, 242);
        this.staffInfobutton.Name = "staffInfobutton";
        this.staffInfobutton.Size = new System.Drawing.Size(113, 42);
        this.staffInfobutton.TabIndex = 26;
        this.staffInfobutton.Text = "Check HoursWorked";
        this.staffInfobutton.UseVisualStyleBackColor = true;
        this.staffInfobutton.Click += new System.EventHandler(this.staffInfobutton_Click);
        // 
        // Form1
        // 
        this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
        this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        this.ClientSize = new System.Drawing.Size(652, 443);
        this.Controls.Add(this.staffInfobutton);
        this.Controls.Add(this.chngTitlebutton);
        this.Controls.Add(this.chngtitlelabel);
        this.Controls.Add(this.chngtitletextBox);
        this.Controls.Add(this.hidebutton);
        this.Controls.Add(this.radioButton2);
        this.Controls.Add(this.radioButton1);
        this.Controls.Add(this.mbalabel);
        this.Controls.Add(this.douglabel);
        this.Controls.Add(this.dougtextBox);
        this.Controls.Add(this.mbatextBox);
        this.Controls.Add(this.accountabilitybutton);
        this.Controls.Add(this.statuslabel);
        this.Controls.Add(this.label3);
        this.Controls.Add(this.label2);
        this.Controls.Add(this.label1);
        this.Controls.Add(this.empcomboBox);
        this.Controls.Add(this.enddateTimePicker);
        this.Controls.Add(this.startdateTimePicker);
        this.Controls.Add(this.claimLinesbutton);
        this.Controls.Add(this.payrollbutton);
        this.Controls.Add(this.menuStrip1);
        this.MainMenuStrip = this.menuStrip1;
        this.MaximizeBox = false;
        this.Name = "Form1";
        this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
        this.Text = "HR Management Tool";
        this.Load += new System.EventHandler(this.Form1_Load);
        this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Form1_FormClosing);
        this.menuStrip1.ResumeLayout(false);
        this.menuStrip1.PerformLayout();
        this.ResumeLayout(false);
        this.PerformLayout();

    }

    #endregion

      private System.Windows.Forms.Button payrollbutton;
    private System.Windows.Forms.Button claimLinesbutton;
    private System.Windows.Forms.DateTimePicker startdateTimePicker;
    private System.Windows.Forms.DateTimePicker enddateTimePicker;
    private System.Windows.Forms.ComboBox empcomboBox;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.Label label3;
    private System.Windows.Forms.Label statuslabel;
    private System.Windows.Forms.Button accountabilitybutton;
    private System.Windows.Forms.MenuStrip menuStrip1;
    private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem editToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem cutToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem copyToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem pasteToolStripMenuItem;
      private System.Windows.Forms.ToolStripMenuItem helpToolStripMenuItem;
      private System.Windows.Forms.ToolStripMenuItem howToToolStripMenuItem;
      private System.Windows.Forms.ToolTip toolTip1;
      private System.Windows.Forms.TextBox mbatextBox;
      private System.Windows.Forms.TextBox dougtextBox;
      private System.Windows.Forms.Label douglabel;
      private System.Windows.Forms.Label mbalabel;
      private System.Windows.Forms.ToolStripMenuItem changeRateToolStripMenuItem;
      private System.Windows.Forms.ToolStripMenuItem changeRemoteFlagToolStripMenuItem;
      private System.Windows.Forms.RadioButton radioButton1;
      private System.Windows.Forms.RadioButton radioButton2;
      private System.Windows.Forms.Button hidebutton;
      private System.Windows.Forms.ToolStripMenuItem changeJobTitleToolStripMenuItem;
      private System.Windows.Forms.TextBox chngtitletextBox;
      private System.Windows.Forms.Label chngtitlelabel;
      private System.Windows.Forms.Button chngTitlebutton;
      private System.Windows.Forms.Button staffInfobutton;
  }
}

