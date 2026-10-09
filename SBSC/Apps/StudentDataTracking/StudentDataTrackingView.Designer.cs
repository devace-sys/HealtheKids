namespace StudentDataTracking
{
    partial class StudentDataTrackingView
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.Edit = new System.Windows.Forms.DataGridViewButtonColumn();
            this.Delete = new System.Windows.Forms.DataGridViewButtonColumn();
            this.FollowUpEmail = new System.Windows.Forms.DataGridViewCheckBoxColumn();
            this.clientcomboBox = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.fileTypecomboBox = new System.Windows.Forms.ComboBox();
            this.closebutton = new System.Windows.Forms.Button();
            this.viewbutton = new System.Windows.Forms.Button();
            this.fycomboBox = new System.Windows.Forms.ComboBox();
            this.quartercomboBox = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.excelbutton = new System.Windows.Forms.Button();
            this.followUpEmailbutton = new System.Windows.Forms.Button();
            this.followUpEmail2button = new System.Windows.Forms.Button();
            this.rcvdradioButton = new System.Windows.Forms.RadioButton();
            this.allradioButton = new System.Windows.Forms.RadioButton();
            this.notRcvdradioButton = new System.Windows.Forms.RadioButton();
            this.label5 = new System.Windows.Forms.Label();
            this.reqBycomboBox = new System.Windows.Forms.ComboBox();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.AllowUserToAddRows = false;
            this.dataGridView1.AllowUserToDeleteRows = false;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.Silver;
            this.dataGridView1.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            this.dataGridView1.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.dataGridView1.BackgroundColor = System.Drawing.SystemColors.Control;
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Edit,
            this.Delete,
            this.FollowUpEmail});
            this.dataGridView1.Location = new System.Drawing.Point(12, 122);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowHeadersVisible = false;
            this.dataGridView1.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridView1.Size = new System.Drawing.Size(986, 441);
            this.dataGridView1.TabIndex = 2;
            this.dataGridView1.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellContentClick);
            // 
            // Edit
            // 
            this.Edit.HeaderText = "Edit";
            this.Edit.Name = "Edit";
            this.Edit.ReadOnly = true;
            this.Edit.Text = "Edit";
            this.Edit.UseColumnTextForButtonValue = true;
            this.Edit.Width = 41;
            // 
            // Delete
            // 
            this.Delete.HeaderText = "Delete";
            this.Delete.Name = "Delete";
            this.Delete.ReadOnly = true;
            this.Delete.Text = "Delete";
            this.Delete.UseColumnTextForButtonValue = true;
            this.Delete.Width = 60;
            // 
            // FollowUpEmail
            // 
            this.FollowUpEmail.FalseValue = "False";
            this.FollowUpEmail.HeaderText = "FollowUpEmail";
            this.FollowUpEmail.IndeterminateValue = "False";
            this.FollowUpEmail.Name = "FollowUpEmail";
            this.FollowUpEmail.TrueValue = "True";
            this.FollowUpEmail.Width = 118;
            // 
            // clientcomboBox
            // 
            this.clientcomboBox.FormattingEnabled = true;
            this.clientcomboBox.Location = new System.Drawing.Point(18, 87);
            this.clientcomboBox.Name = "clientcomboBox";
            this.clientcomboBox.Size = new System.Drawing.Size(223, 24);
            this.clientcomboBox.TabIndex = 3;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(15, 68);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(47, 16);
            this.label2.TabIndex = 4;
            this.label2.Text = "Client";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(241, 68);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(74, 16);
            this.label3.TabIndex = 6;
            this.label3.Text = "File Type";
            // 
            // fileTypecomboBox
            // 
            this.fileTypecomboBox.FormattingEnabled = true;
            this.fileTypecomboBox.Location = new System.Drawing.Point(244, 87);
            this.fileTypecomboBox.Name = "fileTypecomboBox";
            this.fileTypecomboBox.Size = new System.Drawing.Size(223, 24);
            this.fileTypecomboBox.TabIndex = 5;
            // 
            // closebutton
            // 
            this.closebutton.Location = new System.Drawing.Point(892, 579);
            this.closebutton.Name = "closebutton";
            this.closebutton.Size = new System.Drawing.Size(96, 23);
            this.closebutton.TabIndex = 7;
            this.closebutton.Text = "Close";
            this.closebutton.UseVisualStyleBackColor = true;
            this.closebutton.Click += new System.EventHandler(this.closebutton_Click);
            // 
            // viewbutton
            // 
            this.viewbutton.Location = new System.Drawing.Point(730, 87);
            this.viewbutton.Name = "viewbutton";
            this.viewbutton.Size = new System.Drawing.Size(96, 23);
            this.viewbutton.TabIndex = 8;
            this.viewbutton.Text = "View";
            this.viewbutton.UseVisualStyleBackColor = true;
            this.viewbutton.Click += new System.EventHandler(this.viewbutton_Click);
            // 
            // fycomboBox
            // 
            this.fycomboBox.FormattingEnabled = true;
            this.fycomboBox.Location = new System.Drawing.Point(18, 41);
            this.fycomboBox.Name = "fycomboBox";
            this.fycomboBox.Size = new System.Drawing.Size(151, 24);
            this.fycomboBox.TabIndex = 9;
            this.fycomboBox.SelectedIndexChanged += new System.EventHandler(this.fycomboBox_SelectedIndexChanged);
            // 
            // quartercomboBox
            // 
            this.quartercomboBox.FormattingEnabled = true;
            this.quartercomboBox.Items.AddRange(new object[] {
            "1",
            "2",
            "3",
            "4"});
            this.quartercomboBox.Location = new System.Drawing.Point(175, 41);
            this.quartercomboBox.Name = "quartercomboBox";
            this.quartercomboBox.Size = new System.Drawing.Size(47, 24);
            this.quartercomboBox.TabIndex = 10;
            this.quartercomboBox.SelectedIndexChanged += new System.EventHandler(this.quartercomboBox_SelectedIndexChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(172, 23);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(59, 16);
            this.label1.TabIndex = 11;
            this.label1.Text = "Quarter";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(18, 22);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(87, 16);
            this.label4.TabIndex = 12;
            this.label4.Text = "Fiscal Year";
            // 
            // excelbutton
            // 
            this.excelbutton.Location = new System.Drawing.Point(757, 579);
            this.excelbutton.Name = "excelbutton";
            this.excelbutton.Size = new System.Drawing.Size(129, 23);
            this.excelbutton.TabIndex = 13;
            this.excelbutton.Text = "Export To Excel";
            this.excelbutton.UseVisualStyleBackColor = true;
            this.excelbutton.Click += new System.EventHandler(this.excelbutton_Click);
            // 
            // followUpEmailbutton
            // 
            this.followUpEmailbutton.Location = new System.Drawing.Point(409, 570);
            this.followUpEmailbutton.Name = "followUpEmailbutton";
            this.followUpEmailbutton.Size = new System.Drawing.Size(168, 40);
            this.followUpEmailbutton.TabIndex = 14;
            this.followUpEmailbutton.Text = "Send Follow up Email to Client contact";
            this.followUpEmailbutton.UseVisualStyleBackColor = true;
            this.followUpEmailbutton.Click += new System.EventHandler(this.followUpEmailbutton_Click);
            // 
            // followUpEmail2button
            // 
            this.followUpEmail2button.Location = new System.Drawing.Point(583, 570);
            this.followUpEmail2button.Name = "followUpEmail2button";
            this.followUpEmail2button.Size = new System.Drawing.Size(168, 40);
            this.followUpEmail2button.TabIndex = 15;
            this.followUpEmail2button.Text = "Send Follow up Email to Client Rep";
            this.followUpEmail2button.UseVisualStyleBackColor = true;
            this.followUpEmail2button.Click += new System.EventHandler(this.followUpEmail2button_Click);
            // 
            // rcvdradioButton
            // 
            this.rcvdradioButton.AutoSize = true;
            this.rcvdradioButton.Location = new System.Drawing.Point(845, 50);
            this.rcvdradioButton.Name = "rcvdradioButton";
            this.rcvdradioButton.Size = new System.Drawing.Size(93, 20);
            this.rcvdradioButton.TabIndex = 16;
            this.rcvdradioButton.TabStop = true;
            this.rcvdradioButton.Text = "Received";
            this.rcvdradioButton.UseVisualStyleBackColor = true;
            this.rcvdradioButton.CheckedChanged += new System.EventHandler(this.rcvdradioButton_CheckedChanged);
            // 
            // allradioButton
            // 
            this.allradioButton.AutoSize = true;
            this.allradioButton.Location = new System.Drawing.Point(845, 96);
            this.allradioButton.Name = "allradioButton";
            this.allradioButton.Size = new System.Drawing.Size(81, 20);
            this.allradioButton.TabIndex = 17;
            this.allradioButton.TabStop = true;
            this.allradioButton.Text = "View All";
            this.allradioButton.UseVisualStyleBackColor = true;
            this.allradioButton.CheckedChanged += new System.EventHandler(this.allradioButton_CheckedChanged);
            // 
            // notRcvdradioButton
            // 
            this.notRcvdradioButton.AutoSize = true;
            this.notRcvdradioButton.Location = new System.Drawing.Point(845, 72);
            this.notRcvdradioButton.Name = "notRcvdradioButton";
            this.notRcvdradioButton.Size = new System.Drawing.Size(121, 20);
            this.notRcvdradioButton.TabIndex = 18;
            this.notRcvdradioButton.TabStop = true;
            this.notRcvdradioButton.Text = "Not Received";
            this.notRcvdradioButton.UseVisualStyleBackColor = true;
            this.notRcvdradioButton.CheckedChanged += new System.EventHandler(this.notRcvdradioButton_CheckedChanged);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(470, 68);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(106, 16);
            this.label5.TabIndex = 20;
            this.label5.Text = "Requested By";
            // 
            // reqBycomboBox
            // 
            this.reqBycomboBox.FormattingEnabled = true;
            this.reqBycomboBox.Location = new System.Drawing.Point(473, 87);
            this.reqBycomboBox.Name = "reqBycomboBox";
            this.reqBycomboBox.Size = new System.Drawing.Size(223, 24);
            this.reqBycomboBox.TabIndex = 19;
            // 
            // StudentDataTrackingView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1010, 644);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.reqBycomboBox);
            this.Controls.Add(this.notRcvdradioButton);
            this.Controls.Add(this.allradioButton);
            this.Controls.Add(this.rcvdradioButton);
            this.Controls.Add(this.followUpEmail2button);
            this.Controls.Add(this.followUpEmailbutton);
            this.Controls.Add(this.excelbutton);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.quartercomboBox);
            this.Controls.Add(this.fycomboBox);
            this.Controls.Add(this.viewbutton);
            this.Controls.Add(this.closebutton);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.fileTypecomboBox);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.clientcomboBox);
            this.Controls.Add(this.dataGridView1);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "StudentDataTrackingView";
            this.Text = "StudentDataTrackingView";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.StudentDataTrackingView_Load);
            this.Activated += new System.EventHandler(this.StudentDataTrackingView_Activated);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.ComboBox clientcomboBox;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox fileTypecomboBox;
        private System.Windows.Forms.Button closebutton;
        private System.Windows.Forms.Button viewbutton;
        private System.Windows.Forms.ComboBox fycomboBox;
        private System.Windows.Forms.ComboBox quartercomboBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Button excelbutton;
        private System.Windows.Forms.Button followUpEmailbutton;
        private System.Windows.Forms.DataGridViewButtonColumn Edit;
        private System.Windows.Forms.DataGridViewButtonColumn Delete;
        private System.Windows.Forms.DataGridViewCheckBoxColumn FollowUpEmail;
        private System.Windows.Forms.Button followUpEmail2button;
        private System.Windows.Forms.RadioButton rcvdradioButton;
        private System.Windows.Forms.RadioButton allradioButton;
        private System.Windows.Forms.RadioButton notRcvdradioButton;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.ComboBox reqBycomboBox;
    }
}