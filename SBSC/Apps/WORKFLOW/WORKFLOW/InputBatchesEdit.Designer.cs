namespace WORKFLOW
{
    partial class InputBatchesEdit
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
            this.cancelbutton = new System.Windows.Forms.Button();
            this.statuscomboBox = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
            this.oldDosdateTimePicker = new System.Windows.Forms.DateTimePicker();
            this.label6 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.InputhrnumericUpDown = new System.Windows.Forms.NumericUpDown();
            this.label8 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.prioritynumericUpDown = new System.Windows.Forms.NumericUpDown();
            this.difficultynumericUpDown = new System.Windows.Forms.NumericUpDown();
            this.updatebutton = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.userscomboBox = new System.Windows.Forms.ComboBox();
            this.inputBatchtextBox = new System.Windows.Forms.TextBox();
            this.detailspanel = new System.Windows.Forms.Panel();
            this.workTypelabel = new System.Windows.Forms.Label();
            this.allradioButton = new System.Windows.Forms.RadioButton();
            this.dayradioButton = new System.Windows.Forms.RadioButton();
            this.daytrndradioButton = new System.Windows.Forms.RadioButton();
            this.allAvblWeekradioButton = new System.Windows.Forms.RadioButton();
            this.allAvblradioButton = new System.Windows.Forms.RadioButton();
            this.daydateTimePicker = new System.Windows.Forms.DateTimePicker();
            this.label3 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.notetextBox = new System.Windows.Forms.TextBox();
            this.label5 = new System.Windows.Forms.Label();
            this.editFilenamebutton = new System.Windows.Forms.Button();
            this.oldDostextBox = new System.Windows.Forms.TextBox();
            this.clearDatebutton = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.InputhrnumericUpDown)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.prioritynumericUpDown)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.difficultynumericUpDown)).BeginInit();
            this.detailspanel.SuspendLayout();
            this.SuspendLayout();
            // 
            // cancelbutton
            // 
            this.cancelbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cancelbutton.Location = new System.Drawing.Point(938, 544);
            this.cancelbutton.Margin = new System.Windows.Forms.Padding(4);
            this.cancelbutton.Name = "cancelbutton";
            this.cancelbutton.Size = new System.Drawing.Size(82, 28);
            this.cancelbutton.TabIndex = 1;
            this.cancelbutton.Text = "Close";
            this.cancelbutton.UseVisualStyleBackColor = true;
            this.cancelbutton.Click += new System.EventHandler(this.cancelbutton_Click);
            // 
            // statuscomboBox
            // 
            this.statuscomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.statuscomboBox.FormattingEnabled = true;
            this.statuscomboBox.Location = new System.Drawing.Point(325, 116);
            this.statuscomboBox.Margin = new System.Windows.Forms.Padding(4);
            this.statuscomboBox.Name = "statuscomboBox";
            this.statuscomboBox.Size = new System.Drawing.Size(242, 24);
            this.statuscomboBox.TabIndex = 6;
            this.statuscomboBox.SelectedIndexChanged += new System.EventHandler(this.statuscomboBox_SelectedIndexChanged);
            // 
            // label4
            // 
            this.label4.Location = new System.Drawing.Point(252, 115);
            this.label4.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(65, 28);
            this.label4.TabIndex = 7;
            this.label4.Text = "Status";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // oldDosdateTimePicker
            // 
            this.oldDosdateTimePicker.Location = new System.Drawing.Point(466, 27);
            this.oldDosdateTimePicker.Margin = new System.Windows.Forms.Padding(4);
            this.oldDosdateTimePicker.Name = "oldDosdateTimePicker";
            this.oldDosdateTimePicker.Size = new System.Drawing.Size(21, 22);
            this.oldDosdateTimePicker.TabIndex = 8;
            this.oldDosdateTimePicker.Value = new System.DateTime(2012, 7, 10, 0, 0, 0, 0);
            this.oldDosdateTimePicker.ValueChanged += new System.EventHandler(this.oldDosdateTimePicker_ValueChanged);
            // 
            // label6
            // 
            this.label6.Location = new System.Drawing.Point(144, 82);
            this.label6.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(109, 28);
            this.label6.TabIndex = 11;
            this.label6.Text = "Type of Work";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // label7
            // 
            this.label7.Location = new System.Drawing.Point(567, 23);
            this.label7.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(160, 28);
            this.label7.TabIndex = 12;
            this.label7.Text = "Estimated Input Hours";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // InputhrnumericUpDown
            // 
            this.InputhrnumericUpDown.DecimalPlaces = 2;
            this.InputhrnumericUpDown.Increment = new decimal(new int[] {
            25,
            0,
            0,
            131072});
            this.InputhrnumericUpDown.Location = new System.Drawing.Point(733, 23);
            this.InputhrnumericUpDown.Margin = new System.Windows.Forms.Padding(4);
            this.InputhrnumericUpDown.Name = "InputhrnumericUpDown";
            this.InputhrnumericUpDown.Size = new System.Drawing.Size(59, 22);
            this.InputhrnumericUpDown.TabIndex = 13;
            // 
            // label8
            // 
            this.label8.Location = new System.Drawing.Point(622, 58);
            this.label8.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(105, 28);
            this.label8.TabIndex = 14;
            this.label8.Text = "Priority Number";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // label9
            // 
            this.label9.Location = new System.Drawing.Point(588, 97);
            this.label9.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(137, 28);
            this.label9.TabIndex = 15;
            this.label9.Text = "Degree of Difficulty";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // prioritynumericUpDown
            // 
            this.prioritynumericUpDown.Location = new System.Drawing.Point(735, 62);
            this.prioritynumericUpDown.Margin = new System.Windows.Forms.Padding(4);
            this.prioritynumericUpDown.Name = "prioritynumericUpDown";
            this.prioritynumericUpDown.Size = new System.Drawing.Size(57, 22);
            this.prioritynumericUpDown.TabIndex = 16;
            // 
            // difficultynumericUpDown
            // 
            this.difficultynumericUpDown.Location = new System.Drawing.Point(733, 101);
            this.difficultynumericUpDown.Margin = new System.Windows.Forms.Padding(4);
            this.difficultynumericUpDown.Name = "difficultynumericUpDown";
            this.difficultynumericUpDown.Size = new System.Drawing.Size(59, 22);
            this.difficultynumericUpDown.TabIndex = 17;
            // 
            // updatebutton
            // 
            this.updatebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.updatebutton.Location = new System.Drawing.Point(806, 544);
            this.updatebutton.Margin = new System.Windows.Forms.Padding(4);
            this.updatebutton.Name = "updatebutton";
            this.updatebutton.Size = new System.Drawing.Size(82, 28);
            this.updatebutton.TabIndex = 18;
            this.updatebutton.Text = "Update";
            this.updatebutton.UseVisualStyleBackColor = true;
            this.updatebutton.Click += new System.EventHandler(this.updatebutton_Click);
            // 
            // label2
            // 
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(232, 76);
            this.label2.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(85, 16);
            this.label2.TabIndex = 21;
            this.label2.Text = "Input Batch";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // userscomboBox
            // 
            this.userscomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.userscomboBox.FormattingEnabled = true;
            this.userscomboBox.Location = new System.Drawing.Point(253, 291);
            this.userscomboBox.Margin = new System.Windows.Forms.Padding(4);
            this.userscomboBox.Name = "userscomboBox";
            this.userscomboBox.Size = new System.Drawing.Size(542, 24);
            this.userscomboBox.TabIndex = 22;
            this.userscomboBox.MouseClick += new System.Windows.Forms.MouseEventHandler(this.userscomboBox_MouseClick);
            // 
            // inputBatchtextBox
            // 
            this.inputBatchtextBox.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.inputBatchtextBox.ForeColor = System.Drawing.SystemColors.Control;
            this.inputBatchtextBox.Location = new System.Drawing.Point(324, 71);
            this.inputBatchtextBox.Name = "inputBatchtextBox";
            this.inputBatchtextBox.ReadOnly = true;
            this.inputBatchtextBox.Size = new System.Drawing.Size(423, 22);
            this.inputBatchtextBox.TabIndex = 24;
            // 
            // detailspanel
            // 
            this.detailspanel.Controls.Add(this.clearDatebutton);
            this.detailspanel.Controls.Add(this.oldDostextBox);
            this.detailspanel.Controls.Add(this.workTypelabel);
            this.detailspanel.Controls.Add(this.allradioButton);
            this.detailspanel.Controls.Add(this.dayradioButton);
            this.detailspanel.Controls.Add(this.daytrndradioButton);
            this.detailspanel.Controls.Add(this.allAvblWeekradioButton);
            this.detailspanel.Controls.Add(this.allAvblradioButton);
            this.detailspanel.Controls.Add(this.daydateTimePicker);
            this.detailspanel.Controls.Add(this.label3);
            this.detailspanel.Controls.Add(this.label1);
            this.detailspanel.Controls.Add(this.userscomboBox);
            this.detailspanel.Controls.Add(this.difficultynumericUpDown);
            this.detailspanel.Controls.Add(this.prioritynumericUpDown);
            this.detailspanel.Controls.Add(this.label9);
            this.detailspanel.Controls.Add(this.label8);
            this.detailspanel.Controls.Add(this.InputhrnumericUpDown);
            this.detailspanel.Controls.Add(this.label7);
            this.detailspanel.Controls.Add(this.label6);
            this.detailspanel.Controls.Add(this.oldDosdateTimePicker);
            this.detailspanel.Location = new System.Drawing.Point(80, 191);
            this.detailspanel.Name = "detailspanel";
            this.detailspanel.Size = new System.Drawing.Size(954, 336);
            this.detailspanel.TabIndex = 25;
            // 
            // workTypelabel
            // 
            this.workTypelabel.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.workTypelabel.Location = new System.Drawing.Point(253, 82);
            this.workTypelabel.Name = "workTypelabel";
            this.workTypelabel.Size = new System.Drawing.Size(234, 28);
            this.workTypelabel.TabIndex = 38;
            this.workTypelabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // allradioButton
            // 
            this.allradioButton.AutoSize = true;
            this.allradioButton.Location = new System.Drawing.Point(253, 131);
            this.allradioButton.Name = "allradioButton";
            this.allradioButton.Size = new System.Drawing.Size(148, 20);
            this.allradioButton.TabIndex = 37;
            this.allradioButton.TabStop = true;
            this.allradioButton.Text = "Get the list of all staff ";
            this.allradioButton.UseVisualStyleBackColor = true;
            this.allradioButton.CheckedChanged += new System.EventHandler(this.allradioButton_CheckedChanged);
            // 
            // dayradioButton
            // 
            this.dayradioButton.AutoSize = true;
            this.dayradioButton.Location = new System.Drawing.Point(253, 206);
            this.dayradioButton.Name = "dayradioButton";
            this.dayradioButton.Size = new System.Drawing.Size(290, 20);
            this.dayradioButton.TabIndex = 36;
            this.dayradioButton.TabStop = true;
            this.dayradioButton.Text = "Get the list of available staff on selected date";
            this.dayradioButton.UseVisualStyleBackColor = true;
            this.dayradioButton.CheckedChanged += new System.EventHandler(this.dayradioButton_CheckedChanged);
            // 
            // daytrndradioButton
            // 
            this.daytrndradioButton.AutoSize = true;
            this.daytrndradioButton.Location = new System.Drawing.Point(253, 232);
            this.daytrndradioButton.Name = "daytrndradioButton";
            this.daytrndradioButton.Size = new System.Drawing.Size(360, 20);
            this.daytrndradioButton.TabIndex = 35;
            this.daytrndradioButton.TabStop = true;
            this.daytrndradioButton.Text = "Get the list of trained and available staff on selected date";
            this.daytrndradioButton.UseVisualStyleBackColor = true;
            this.daytrndradioButton.CheckedChanged += new System.EventHandler(this.daytrndradioButton_CheckedChanged);
            // 
            // allAvblWeekradioButton
            // 
            this.allAvblWeekradioButton.AutoSize = true;
            this.allAvblWeekradioButton.Location = new System.Drawing.Point(253, 180);
            this.allAvblWeekradioButton.Name = "allAvblWeekradioButton";
            this.allAvblWeekradioButton.Size = new System.Drawing.Size(348, 20);
            this.allAvblWeekradioButton.TabIndex = 34;
            this.allAvblWeekradioButton.TabStop = true;
            this.allAvblWeekradioButton.Text = "Get the list of available and trained staff in current week";
            this.allAvblWeekradioButton.UseVisualStyleBackColor = true;
            this.allAvblWeekradioButton.CheckedChanged += new System.EventHandler(this.allAvblWeekradioButton_CheckedChanged);
            // 
            // allAvblradioButton
            // 
            this.allAvblradioButton.AutoSize = true;
            this.allAvblradioButton.Location = new System.Drawing.Point(253, 156);
            this.allAvblradioButton.Name = "allAvblradioButton";
            this.allAvblradioButton.Size = new System.Drawing.Size(207, 20);
            this.allAvblradioButton.TabIndex = 33;
            this.allAvblradioButton.TabStop = true;
            this.allAvblradioButton.Text = "Get the list of all available staff ";
            this.allAvblradioButton.UseVisualStyleBackColor = true;
            this.allAvblradioButton.CheckedChanged += new System.EventHandler(this.allAvblradioButton_CheckedChanged);
            // 
            // daydateTimePicker
            // 
            this.daydateTimePicker.Location = new System.Drawing.Point(568, 206);
            this.daydateTimePicker.Name = "daydateTimePicker";
            this.daydateTimePicker.Size = new System.Drawing.Size(227, 22);
            this.daydateTimePicker.TabIndex = 31;
            this.daydateTimePicker.ValueChanged += new System.EventHandler(this.daydateTimePicker_ValueChanged);
            // 
            // label3
            // 
            this.label3.Location = new System.Drawing.Point(176, 288);
            this.label3.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(75, 28);
            this.label3.TabIndex = 26;
            this.label3.Text = "Assign to ";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // label1
            // 
            this.label1.Location = new System.Drawing.Point(70, 24);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(160, 28);
            this.label1.TabIndex = 24;
            this.label1.Text = "Oldest Date of Service";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // notetextBox
            // 
            this.notetextBox.Location = new System.Drawing.Point(611, 116);
            this.notetextBox.Multiline = true;
            this.notetextBox.Name = "notetextBox";
            this.notetextBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.notetextBox.Size = new System.Drawing.Size(355, 69);
            this.notetextBox.TabIndex = 26;
            // 
            // label5
            // 
            this.label5.Location = new System.Drawing.Point(570, 114);
            this.label5.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(40, 28);
            this.label5.TabIndex = 27;
            this.label5.Text = "Note:";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // editFilenamebutton
            // 
            this.editFilenamebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.editFilenamebutton.Location = new System.Drawing.Point(755, 68);
            this.editFilenamebutton.Margin = new System.Windows.Forms.Padding(4);
            this.editFilenamebutton.Name = "editFilenamebutton";
            this.editFilenamebutton.Size = new System.Drawing.Size(98, 28);
            this.editFilenamebutton.TabIndex = 28;
            this.editFilenamebutton.Text = "Rename File";
            this.editFilenamebutton.UseVisualStyleBackColor = true;
            this.editFilenamebutton.Click += new System.EventHandler(this.editFilenamebutton_Click);
            // 
            // oldDostextBox
            // 
            this.oldDostextBox.Location = new System.Drawing.Point(253, 27);
            this.oldDostextBox.Name = "oldDostextBox";
            this.oldDostextBox.ReadOnly = true;
            this.oldDostextBox.Size = new System.Drawing.Size(218, 22);
            this.oldDostextBox.TabIndex = 39;
            // 
            // clearDatebutton
            // 
            this.clearDatebutton.Location = new System.Drawing.Point(493, 26);
            this.clearDatebutton.Name = "clearDatebutton";
            this.clearDatebutton.Size = new System.Drawing.Size(50, 23);
            this.clearDatebutton.TabIndex = 40;
            this.clearDatebutton.Text = "Clear";
            this.clearDatebutton.UseVisualStyleBackColor = true;
            this.clearDatebutton.Click += new System.EventHandler(this.clearDatebutton_Click);
            // 
            // InputBatchesEdit
            // 
            this.AcceptButton = this.updatebutton;
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoScroll = true;
            this.AutoSize = true;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(1062, 614);
            this.Controls.Add(this.editFilenamebutton);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.notetextBox);
            this.Controls.Add(this.detailspanel);
            this.Controls.Add(this.inputBatchtextBox);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.updatebutton);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.statuscomboBox);
            this.Controls.Add(this.cancelbutton);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ForeColor = System.Drawing.SystemColors.ControlText;
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "InputBatchesEdit";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Input Batches Edit";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.InputBatchesEdit_Load);
            ((System.ComponentModel.ISupportInitialize)(this.InputhrnumericUpDown)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.prioritynumericUpDown)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.difficultynumericUpDown)).EndInit();
            this.detailspanel.ResumeLayout(false);
            this.detailspanel.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button cancelbutton;
        private System.Windows.Forms.ComboBox statuscomboBox;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.DateTimePicker oldDosdateTimePicker;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.NumericUpDown InputhrnumericUpDown;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.NumericUpDown prioritynumericUpDown;
        private System.Windows.Forms.NumericUpDown difficultynumericUpDown;
        private System.Windows.Forms.Button updatebutton;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox userscomboBox;
        private System.Windows.Forms.TextBox inputBatchtextBox;
        private System.Windows.Forms.Panel detailspanel;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.DateTimePicker daydateTimePicker;
        private System.Windows.Forms.RadioButton daytrndradioButton;
        private System.Windows.Forms.RadioButton allAvblWeekradioButton;
        private System.Windows.Forms.RadioButton allAvblradioButton;
        private System.Windows.Forms.RadioButton dayradioButton;
        private System.Windows.Forms.TextBox notetextBox;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Button editFilenamebutton;
        private System.Windows.Forms.RadioButton allradioButton;
        private System.Windows.Forms.Label workTypelabel;
        private System.Windows.Forms.TextBox oldDostextBox;
        private System.Windows.Forms.Button clearDatebutton;
    }
}

