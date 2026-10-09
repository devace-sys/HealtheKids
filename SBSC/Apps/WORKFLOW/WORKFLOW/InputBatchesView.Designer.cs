namespace WORKFLOW
{
    partial class InputBatchesView
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
            this.button1 = new System.Windows.Forms.Button();
            this.statuscomboBox = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.OpenFile = new System.Windows.Forms.DataGridViewButtonColumn();
            this.EditInfo = new System.Windows.Forms.DataGridViewButtonColumn();
            this.label3 = new System.Windows.Forms.Label();
            this.clientcomboBox = new System.Windows.Forms.ComboBox();
            this.viewbutton = new System.Windows.Forms.Button();
            this.userslabel = new System.Windows.Forms.Label();
            this.userscomboBox = new System.Windows.Forms.ComboBox();
            this.label5 = new System.Windows.Forms.Label();
            this.typecomboBox = new System.Windows.Forms.ComboBox();
            this.clearbutton = new System.Windows.Forms.Button();
            this.splitbutton = new System.Windows.Forms.Button();
            this.deletebutton = new System.Windows.Forms.Button();
            this.restorebutton = new System.Windows.Forms.Button();
            this.attachFilebutton = new System.Windows.Forms.Button();
            this.changeStatuscomboBox = new System.Windows.Forms.ComboBox();
            this.avblStaffcomboBox = new System.Windows.Forms.ComboBox();
            this.stafflabel = new System.Windows.Forms.Label();
            this.assignbutton = new System.Windows.Forms.Button();
            this.changeStatusbutton = new System.Windows.Forms.Button();
            this.estHrslabel = new System.Windows.Forms.Label();
            this.estInputnumericUpDown = new System.Windows.Forms.NumericUpDown();
            this.oldDoslabel = new System.Windows.Forms.Label();
            this.oldDosdateTimePicker = new System.Windows.Forms.DateTimePicker();
            this.searchbutton = new System.Windows.Forms.Button();
            this.allradioButton = new System.Windows.Forms.RadioButton();
            this.avblradioButton = new System.Windows.Forms.RadioButton();
            this.trnrecordbutton = new System.Windows.Forms.Button();
            this.schedulebutton = new System.Windows.Forms.Button();
            this.assignWorkpanel = new System.Windows.Forms.Panel();
            this.nextweekcheckBox = new System.Windows.Forms.CheckBox();
            this.renamebutton = new System.Windows.Forms.Button();
            this.changeStatustextBox = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.editPracRevbutton = new System.Windows.Forms.Button();
            this.editStaffRevbutton = new System.Windows.Forms.Button();
            this.prioritynumericUpDown = new System.Windows.Forms.NumericUpDown();
            this.priorlabel = new System.Windows.Forms.Label();
            this.prioritybutton = new System.Windows.Forms.Button();
            this.editQuestionsbutton = new System.Windows.Forms.Button();
            this.AddcoverPagebutton = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.estInputnumericUpDown)).BeginInit();
            this.assignWorkpanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.prioritynumericUpDown)).BeginInit();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.button1.Location = new System.Drawing.Point(984, 571);
            this.button1.Margin = new System.Windows.Forms.Padding(4);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(81, 28);
            this.button1.TabIndex = 1;
            this.button1.Text = "Close";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // statuscomboBox
            // 
            this.statuscomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.statuscomboBox.FormattingEnabled = true;
            this.statuscomboBox.Location = new System.Drawing.Point(12, 55);
            this.statuscomboBox.Name = "statuscomboBox";
            this.statuscomboBox.Size = new System.Drawing.Size(220, 24);
            this.statuscomboBox.TabIndex = 2;
            // 
            // label2
            // 
            this.label2.Location = new System.Drawing.Point(10, 35);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(100, 16);
            this.label2.TabIndex = 3;
            this.label2.Text = "Status";
            // 
            // dataGridView1
            // 
            this.dataGridView1.AllowUserToAddRows = false;
            this.dataGridView1.AllowUserToDeleteRows = false;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.dataGridView1.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            this.dataGridView1.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.dataGridView1.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.AllCells;
            this.dataGridView1.BackgroundColor = System.Drawing.SystemColors.Control;
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.OpenFile,
            this.EditInfo});
            this.dataGridView1.Location = new System.Drawing.Point(12, 87);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.ReadOnly = true;
            this.dataGridView1.RowHeadersVisible = false;
            this.dataGridView1.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridView1.Size = new System.Drawing.Size(1049, 388);
            this.dataGridView1.TabIndex = 7;
            this.dataGridView1.Tag = "";
            this.dataGridView1.SelectionChanged += new System.EventHandler(this.dataGridView1_SelectionChanged);
            this.dataGridView1.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellContentClick);
            // 
            // OpenFile
            // 
            this.OpenFile.HeaderText = "OpenFile";
            this.OpenFile.MinimumWidth = 3;
            this.OpenFile.Name = "OpenFile";
            this.OpenFile.ReadOnly = true;
            this.OpenFile.Text = "OpenFile";
            this.OpenFile.UseColumnTextForButtonValue = true;
            this.OpenFile.Width = 69;
            // 
            // EditInfo
            // 
            this.EditInfo.HeaderText = "EditInfo";
            this.EditInfo.MinimumWidth = 3;
            this.EditInfo.Name = "EditInfo";
            this.EditInfo.ReadOnly = true;
            this.EditInfo.Text = "EditInfo";
            this.EditInfo.UseColumnTextForButtonValue = true;
            this.EditInfo.Width = 58;
            // 
            // label3
            // 
            this.label3.Location = new System.Drawing.Point(235, 35);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(127, 16);
            this.label3.TabIndex = 13;
            this.label3.Text = "Client";
            // 
            // clientcomboBox
            // 
            this.clientcomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.clientcomboBox.FormattingEnabled = true;
            this.clientcomboBox.Location = new System.Drawing.Point(236, 55);
            this.clientcomboBox.Name = "clientcomboBox";
            this.clientcomboBox.Size = new System.Drawing.Size(161, 24);
            this.clientcomboBox.TabIndex = 12;
            // 
            // viewbutton
            // 
            this.viewbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.viewbutton.Location = new System.Drawing.Point(851, 52);
            this.viewbutton.Margin = new System.Windows.Forms.Padding(4);
            this.viewbutton.Name = "viewbutton";
            this.viewbutton.Size = new System.Drawing.Size(65, 28);
            this.viewbutton.TabIndex = 14;
            this.viewbutton.Text = "View";
            this.viewbutton.UseVisualStyleBackColor = true;
            this.viewbutton.Click += new System.EventHandler(this.viewbutton_Click);
            // 
            // userslabel
            // 
            this.userslabel.Location = new System.Drawing.Point(579, 36);
            this.userslabel.Name = "userslabel";
            this.userslabel.Size = new System.Drawing.Size(91, 16);
            this.userslabel.TabIndex = 16;
            this.userslabel.Text = "Staff";
            // 
            // userscomboBox
            // 
            this.userscomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.userscomboBox.FormattingEnabled = true;
            this.userscomboBox.Location = new System.Drawing.Point(575, 55);
            this.userscomboBox.Name = "userscomboBox";
            this.userscomboBox.Size = new System.Drawing.Size(175, 24);
            this.userscomboBox.TabIndex = 15;
            // 
            // label5
            // 
            this.label5.Location = new System.Drawing.Point(404, 35);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(146, 16);
            this.label5.TabIndex = 18;
            this.label5.Text = "Work Type";
            // 
            // typecomboBox
            // 
            this.typecomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.typecomboBox.FormattingEnabled = true;
            this.typecomboBox.Location = new System.Drawing.Point(402, 55);
            this.typecomboBox.Name = "typecomboBox";
            this.typecomboBox.Size = new System.Drawing.Size(167, 24);
            this.typecomboBox.TabIndex = 17;
            // 
            // clearbutton
            // 
            this.clearbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.clearbutton.Location = new System.Drawing.Point(924, 52);
            this.clearbutton.Margin = new System.Windows.Forms.Padding(4);
            this.clearbutton.Name = "clearbutton";
            this.clearbutton.Size = new System.Drawing.Size(65, 28);
            this.clearbutton.TabIndex = 20;
            this.clearbutton.Text = "Clear";
            this.clearbutton.UseVisualStyleBackColor = true;
            this.clearbutton.Click += new System.EventHandler(this.clearbutton_Click);
            // 
            // splitbutton
            // 
            this.splitbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.splitbutton.Location = new System.Drawing.Point(984, 541);
            this.splitbutton.Margin = new System.Windows.Forms.Padding(4);
            this.splitbutton.Name = "splitbutton";
            this.splitbutton.Size = new System.Drawing.Size(81, 28);
            this.splitbutton.TabIndex = 21;
            this.splitbutton.Text = "Split File";
            this.splitbutton.UseVisualStyleBackColor = true;
            this.splitbutton.Click += new System.EventHandler(this.splitbutton_Click);
            // 
            // deletebutton
            // 
            this.deletebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.deletebutton.Location = new System.Drawing.Point(814, 541);
            this.deletebutton.Name = "deletebutton";
            this.deletebutton.Size = new System.Drawing.Size(81, 28);
            this.deletebutton.TabIndex = 22;
            this.deletebutton.Text = "Delete";
            this.deletebutton.UseVisualStyleBackColor = true;
            this.deletebutton.Click += new System.EventHandler(this.deletebutton_Click);
            // 
            // restorebutton
            // 
            this.restorebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.restorebutton.Location = new System.Drawing.Point(899, 541);
            this.restorebutton.Name = "restorebutton";
            this.restorebutton.Size = new System.Drawing.Size(81, 28);
            this.restorebutton.TabIndex = 27;
            this.restorebutton.Text = "Restore File";
            this.restorebutton.UseVisualStyleBackColor = true;
            this.restorebutton.Click += new System.EventHandler(this.restorebutton_Click);
            // 
            // attachFilebutton
            // 
            this.attachFilebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.attachFilebutton.Location = new System.Drawing.Point(899, 571);
            this.attachFilebutton.Margin = new System.Windows.Forms.Padding(4);
            this.attachFilebutton.Name = "attachFilebutton";
            this.attachFilebutton.Size = new System.Drawing.Size(81, 28);
            this.attachFilebutton.TabIndex = 30;
            this.attachFilebutton.Text = "Attach File";
            this.attachFilebutton.UseVisualStyleBackColor = true;
            this.attachFilebutton.Click += new System.EventHandler(this.attachFilebutton_Click);
            // 
            // changeStatuscomboBox
            // 
            this.changeStatuscomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.changeStatuscomboBox.FormattingEnabled = true;
            this.changeStatuscomboBox.Location = new System.Drawing.Point(51, 499);
            this.changeStatuscomboBox.Name = "changeStatuscomboBox";
            this.changeStatuscomboBox.Size = new System.Drawing.Size(255, 24);
            this.changeStatuscomboBox.TabIndex = 33;
            this.changeStatuscomboBox.SelectedIndexChanged += new System.EventHandler(this.changeStatuscomboBox_SelectedIndexChanged);
            // 
            // avblStaffcomboBox
            // 
            this.avblStaffcomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.avblStaffcomboBox.FormattingEnabled = true;
            this.avblStaffcomboBox.Location = new System.Drawing.Point(3, 22);
            this.avblStaffcomboBox.Name = "avblStaffcomboBox";
            this.avblStaffcomboBox.Size = new System.Drawing.Size(478, 24);
            this.avblStaffcomboBox.TabIndex = 34;
            // 
            // stafflabel
            // 
            this.stafflabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.stafflabel.Location = new System.Drawing.Point(3, 5);
            this.stafflabel.Name = "stafflabel";
            this.stafflabel.Size = new System.Drawing.Size(68, 19);
            this.stafflabel.TabIndex = 35;
            this.stafflabel.Text = "Staff list  ";
            // 
            // assignbutton
            // 
            this.assignbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.assignbutton.Location = new System.Drawing.Point(19, 71);
            this.assignbutton.Margin = new System.Windows.Forms.Padding(4);
            this.assignbutton.Name = "assignbutton";
            this.assignbutton.Size = new System.Drawing.Size(81, 24);
            this.assignbutton.TabIndex = 40;
            this.assignbutton.Text = "Assign";
            this.assignbutton.UseVisualStyleBackColor = true;
            this.assignbutton.Click += new System.EventHandler(this.assignbutton_Click);
            // 
            // changeStatusbutton
            // 
            this.changeStatusbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.changeStatusbutton.Location = new System.Drawing.Point(225, 525);
            this.changeStatusbutton.Margin = new System.Windows.Forms.Padding(4);
            this.changeStatusbutton.Name = "changeStatusbutton";
            this.changeStatusbutton.Size = new System.Drawing.Size(81, 24);
            this.changeStatusbutton.TabIndex = 41;
            this.changeStatusbutton.Text = "Save";
            this.changeStatusbutton.UseVisualStyleBackColor = true;
            this.changeStatusbutton.Click += new System.EventHandler(this.changeStatusbutton_Click);
            // 
            // estHrslabel
            // 
            this.estHrslabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.estHrslabel.Location = new System.Drawing.Point(17, 527);
            this.estHrslabel.Name = "estHrslabel";
            this.estHrslabel.Size = new System.Drawing.Size(141, 18);
            this.estHrslabel.TabIndex = 43;
            this.estHrslabel.Text = "Estimated Input Hours:";
            this.estHrslabel.TextAlign = System.Drawing.ContentAlignment.BottomRight;
            // 
            // estInputnumericUpDown
            // 
            this.estInputnumericUpDown.DecimalPlaces = 2;
            this.estInputnumericUpDown.Increment = new decimal(new int[] {
            25,
            0,
            0,
            131072});
            this.estInputnumericUpDown.Location = new System.Drawing.Point(156, 527);
            this.estInputnumericUpDown.Maximum = new decimal(new int[] {
            10,
            0,
            0,
            0});
            this.estInputnumericUpDown.Name = "estInputnumericUpDown";
            this.estInputnumericUpDown.Size = new System.Drawing.Size(63, 22);
            this.estInputnumericUpDown.TabIndex = 44;
            // 
            // oldDoslabel
            // 
            this.oldDoslabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.oldDoslabel.Location = new System.Drawing.Point(15, 554);
            this.oldDoslabel.Name = "oldDoslabel";
            this.oldDoslabel.Size = new System.Drawing.Size(141, 18);
            this.oldDoslabel.TabIndex = 45;
            this.oldDoslabel.Text = "Oldest date of service:";
            this.oldDoslabel.TextAlign = System.Drawing.ContentAlignment.BottomRight;
            // 
            // oldDosdateTimePicker
            // 
            this.oldDosdateTimePicker.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.oldDosdateTimePicker.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.oldDosdateTimePicker.Location = new System.Drawing.Point(156, 555);
            this.oldDosdateTimePicker.Name = "oldDosdateTimePicker";
            this.oldDosdateTimePicker.Size = new System.Drawing.Size(85, 20);
            this.oldDosdateTimePicker.TabIndex = 46;
            // 
            // searchbutton
            // 
            this.searchbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.searchbutton.Location = new System.Drawing.Point(997, 52);
            this.searchbutton.Margin = new System.Windows.Forms.Padding(4);
            this.searchbutton.Name = "searchbutton";
            this.searchbutton.Size = new System.Drawing.Size(65, 28);
            this.searchbutton.TabIndex = 47;
            this.searchbutton.Text = "Search ";
            this.searchbutton.UseVisualStyleBackColor = true;
            this.searchbutton.Click += new System.EventHandler(this.searchbutton_Click);
            // 
            // allradioButton
            // 
            this.allradioButton.AutoSize = true;
            this.allradioButton.Location = new System.Drawing.Point(19, 51);
            this.allradioButton.Name = "allradioButton";
            this.allradioButton.Size = new System.Drawing.Size(41, 20);
            this.allradioButton.TabIndex = 48;
            this.allradioButton.TabStop = true;
            this.allradioButton.Text = "All";
            this.allradioButton.UseVisualStyleBackColor = true;
            this.allradioButton.CheckedChanged += new System.EventHandler(this.allradioButton_CheckedChanged);
            // 
            // avblradioButton
            // 
            this.avblradioButton.AutoSize = true;
            this.avblradioButton.Location = new System.Drawing.Point(80, 51);
            this.avblradioButton.Name = "avblradioButton";
            this.avblradioButton.Size = new System.Drawing.Size(83, 20);
            this.avblradioButton.TabIndex = 49;
            this.avblradioButton.TabStop = true;
            this.avblradioButton.Text = "Available";
            this.avblradioButton.UseVisualStyleBackColor = true;
            this.avblradioButton.CheckedChanged += new System.EventHandler(this.avblradioButton_CheckedChanged);
            // 
            // trnrecordbutton
            // 
            this.trnrecordbutton.Location = new System.Drawing.Point(297, 77);
            this.trnrecordbutton.Name = "trnrecordbutton";
            this.trnrecordbutton.Size = new System.Drawing.Size(113, 23);
            this.trnrecordbutton.TabIndex = 50;
            this.trnrecordbutton.Text = "Training Record";
            this.trnrecordbutton.UseVisualStyleBackColor = true;
            this.trnrecordbutton.Click += new System.EventHandler(this.trnrecordbutton_Click);
            // 
            // schedulebutton
            // 
            this.schedulebutton.Location = new System.Drawing.Point(297, 48);
            this.schedulebutton.Name = "schedulebutton";
            this.schedulebutton.Size = new System.Drawing.Size(113, 23);
            this.schedulebutton.TabIndex = 51;
            this.schedulebutton.Text = "Staff schedule";
            this.schedulebutton.UseVisualStyleBackColor = true;
            this.schedulebutton.Click += new System.EventHandler(this.schedulebutton_Click);
            // 
            // assignWorkpanel
            // 
            this.assignWorkpanel.Controls.Add(this.nextweekcheckBox);
            this.assignWorkpanel.Controls.Add(this.schedulebutton);
            this.assignWorkpanel.Controls.Add(this.trnrecordbutton);
            this.assignWorkpanel.Controls.Add(this.avblradioButton);
            this.assignWorkpanel.Controls.Add(this.allradioButton);
            this.assignWorkpanel.Controls.Add(this.assignbutton);
            this.assignWorkpanel.Controls.Add(this.avblStaffcomboBox);
            this.assignWorkpanel.Controls.Add(this.stafflabel);
            this.assignWorkpanel.Location = new System.Drawing.Point(315, 497);
            this.assignWorkpanel.Name = "assignWorkpanel";
            this.assignWorkpanel.Size = new System.Drawing.Size(484, 102);
            this.assignWorkpanel.TabIndex = 53;
            // 
            // nextweekcheckBox
            // 
            this.nextweekcheckBox.AutoSize = true;
            this.nextweekcheckBox.Location = new System.Drawing.Point(188, 51);
            this.nextweekcheckBox.Name = "nextweekcheckBox";
            this.nextweekcheckBox.Size = new System.Drawing.Size(93, 20);
            this.nextweekcheckBox.TabIndex = 52;
            this.nextweekcheckBox.Text = "Next Week";
            this.nextweekcheckBox.UseVisualStyleBackColor = true;
            this.nextweekcheckBox.CheckedChanged += new System.EventHandler(this.nextweekcheckBox_CheckedChanged);
            // 
            // renamebutton
            // 
            this.renamebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.renamebutton.Location = new System.Drawing.Point(814, 571);
            this.renamebutton.Name = "renamebutton";
            this.renamebutton.Size = new System.Drawing.Size(81, 28);
            this.renamebutton.TabIndex = 54;
            this.renamebutton.Text = "Rename ";
            this.renamebutton.UseVisualStyleBackColor = true;
            this.renamebutton.Click += new System.EventHandler(this.renamebutton_Click);
            // 
            // changeStatustextBox
            // 
            this.changeStatustextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.changeStatustextBox.Location = new System.Drawing.Point(51, 480);
            this.changeStatustextBox.Name = "changeStatustextBox";
            this.changeStatustextBox.ReadOnly = true;
            this.changeStatustextBox.Size = new System.Drawing.Size(274, 15);
            this.changeStatustextBox.TabIndex = 55;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 481);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(38, 16);
            this.label1.TabIndex = 56;
            this.label1.Text = "Mark";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(19, 502);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(26, 16);
            this.label4.TabIndex = 57;
            this.label4.Text = "as:";
            // 
            // editPracRevbutton
            // 
            this.editPracRevbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.editPracRevbutton.Location = new System.Drawing.Point(814, 491);
            this.editPracRevbutton.Margin = new System.Windows.Forms.Padding(4);
            this.editPracRevbutton.Name = "editPracRevbutton";
            this.editPracRevbutton.Size = new System.Drawing.Size(166, 24);
            this.editPracRevbutton.TabIndex = 59;
            this.editPracRevbutton.Text = "Add/EditPracReviews";
            this.editPracRevbutton.UseVisualStyleBackColor = true;
            this.editPracRevbutton.Click += new System.EventHandler(this.editPracRevbutton_Click);
            // 
            // editStaffRevbutton
            // 
            this.editStaffRevbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.editStaffRevbutton.Location = new System.Drawing.Point(814, 514);
            this.editStaffRevbutton.Margin = new System.Windows.Forms.Padding(4);
            this.editStaffRevbutton.Name = "editStaffRevbutton";
            this.editStaffRevbutton.Size = new System.Drawing.Size(166, 24);
            this.editStaffRevbutton.TabIndex = 60;
            this.editStaffRevbutton.Text = "Add/EditStaffReviews";
            this.editStaffRevbutton.UseVisualStyleBackColor = true;
            this.editStaffRevbutton.Click += new System.EventHandler(this.editStaffRevbutton_Click);
            // 
            // prioritynumericUpDown
            // 
            this.prioritynumericUpDown.Location = new System.Drawing.Point(156, 581);
            this.prioritynumericUpDown.Name = "prioritynumericUpDown";
            this.prioritynumericUpDown.Size = new System.Drawing.Size(42, 22);
            this.prioritynumericUpDown.TabIndex = 61;
            // 
            // priorlabel
            // 
            this.priorlabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.priorlabel.Location = new System.Drawing.Point(15, 583);
            this.priorlabel.Name = "priorlabel";
            this.priorlabel.Size = new System.Drawing.Size(141, 18);
            this.priorlabel.TabIndex = 62;
            this.priorlabel.Text = "Change priority:";
            this.priorlabel.TextAlign = System.Drawing.ContentAlignment.BottomRight;
            // 
            // prioritybutton
            // 
            this.prioritybutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.prioritybutton.Location = new System.Drawing.Point(205, 580);
            this.prioritybutton.Margin = new System.Windows.Forms.Padding(4);
            this.prioritybutton.Name = "prioritybutton";
            this.prioritybutton.Size = new System.Drawing.Size(98, 23);
            this.prioritybutton.TabIndex = 63;
            this.prioritybutton.Text = "Update priority";
            this.prioritybutton.UseVisualStyleBackColor = true;
            this.prioritybutton.Click += new System.EventHandler(this.prioritybutton_Click);
            // 
            // editQuestionsbutton
            // 
            this.editQuestionsbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.editQuestionsbutton.Location = new System.Drawing.Point(984, 490);
            this.editQuestionsbutton.Margin = new System.Windows.Forms.Padding(4);
            this.editQuestionsbutton.Name = "editQuestionsbutton";
            this.editQuestionsbutton.Size = new System.Drawing.Size(81, 49);
            this.editQuestionsbutton.TabIndex = 64;
            this.editQuestionsbutton.Text = "Request Response form";
            this.editQuestionsbutton.UseVisualStyleBackColor = true;
            this.editQuestionsbutton.Click += new System.EventHandler(this.editQuestionsbutton_Click);
            // 
            // AddcoverPagebutton
            // 
            this.AddcoverPagebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.AddcoverPagebutton.Location = new System.Drawing.Point(757, 36);
            this.AddcoverPagebutton.Margin = new System.Windows.Forms.Padding(4);
            this.AddcoverPagebutton.Name = "AddcoverPagebutton";
            this.AddcoverPagebutton.Size = new System.Drawing.Size(86, 44);
            this.AddcoverPagebutton.TabIndex = 65;
            this.AddcoverPagebutton.Text = "Add cover page";
            this.AddcoverPagebutton.UseVisualStyleBackColor = true;
            this.AddcoverPagebutton.Click += new System.EventHandler(this.AddcoverPagebutton_Click);
            // 
            // InputBatchesView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoScroll = true;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(1073, 623);
            this.Controls.Add(this.AddcoverPagebutton);
            this.Controls.Add(this.editQuestionsbutton);
            this.Controls.Add(this.prioritybutton);
            this.Controls.Add(this.priorlabel);
            this.Controls.Add(this.prioritynumericUpDown);
            this.Controls.Add(this.editStaffRevbutton);
            this.Controls.Add(this.editPracRevbutton);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.changeStatustextBox);
            this.Controls.Add(this.renamebutton);
            this.Controls.Add(this.dataGridView1);
            this.Controls.Add(this.searchbutton);
            this.Controls.Add(this.oldDosdateTimePicker);
            this.Controls.Add(this.oldDoslabel);
            this.Controls.Add(this.estInputnumericUpDown);
            this.Controls.Add(this.estHrslabel);
            this.Controls.Add(this.changeStatusbutton);
            this.Controls.Add(this.changeStatuscomboBox);
            this.Controls.Add(this.attachFilebutton);
            this.Controls.Add(this.restorebutton);
            this.Controls.Add(this.deletebutton);
            this.Controls.Add(this.splitbutton);
            this.Controls.Add(this.clearbutton);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.typecomboBox);
            this.Controls.Add(this.userslabel);
            this.Controls.Add(this.userscomboBox);
            this.Controls.Add(this.viewbutton);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.clientcomboBox);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.statuscomboBox);
            this.Controls.Add(this.button1);
            this.Controls.Add(this.assignWorkpanel);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "InputBatchesView";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Input Batches View";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.InputBatchesView_Load);
            this.Activated += new System.EventHandler(this.InputBatchesView_Activated);
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.InputBatchesView_FormClosing);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.estInputnumericUpDown)).EndInit();
            this.assignWorkpanel.ResumeLayout(false);
            this.assignWorkpanel.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.prioritynumericUpDown)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.ComboBox statuscomboBox;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox clientcomboBox;
        private System.Windows.Forms.Button viewbutton;
        private System.Windows.Forms.Label userslabel;
        private System.Windows.Forms.ComboBox userscomboBox;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.ComboBox typecomboBox;
        private System.Windows.Forms.Button clearbutton;
        private System.Windows.Forms.DataGridViewButtonColumn OpenFile;
        private System.Windows.Forms.DataGridViewButtonColumn EditInfo;
        private System.Windows.Forms.Button splitbutton;
        private System.Windows.Forms.Button deletebutton;
        private System.Windows.Forms.Button restorebutton;
        private System.Windows.Forms.Button attachFilebutton;
        private System.Windows.Forms.ComboBox changeStatuscomboBox;
        private System.Windows.Forms.ComboBox avblStaffcomboBox;
        private System.Windows.Forms.Label stafflabel;
        private System.Windows.Forms.Button assignbutton;
        private System.Windows.Forms.Button changeStatusbutton;
        private System.Windows.Forms.Label estHrslabel;
        private System.Windows.Forms.NumericUpDown estInputnumericUpDown;
        private System.Windows.Forms.Label oldDoslabel;
        private System.Windows.Forms.DateTimePicker oldDosdateTimePicker;
        private System.Windows.Forms.Button searchbutton;
        private System.Windows.Forms.RadioButton allradioButton;
        private System.Windows.Forms.RadioButton avblradioButton;
        private System.Windows.Forms.Button trnrecordbutton;
        private System.Windows.Forms.Button schedulebutton;
        private System.Windows.Forms.Panel assignWorkpanel;
        private System.Windows.Forms.CheckBox nextweekcheckBox;
        private System.Windows.Forms.Button renamebutton;
        private System.Windows.Forms.TextBox changeStatustextBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Button editPracRevbutton;
        private System.Windows.Forms.Button editStaffRevbutton;
        private System.Windows.Forms.NumericUpDown prioritynumericUpDown;
        private System.Windows.Forms.Label priorlabel;
        private System.Windows.Forms.Button prioritybutton;
        private System.Windows.Forms.Button editQuestionsbutton;
        private System.Windows.Forms.Button AddcoverPagebutton;
    }
}

