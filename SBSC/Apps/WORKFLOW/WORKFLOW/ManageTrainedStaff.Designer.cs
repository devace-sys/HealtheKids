namespace WORKFLOW
{
    partial class ManageTrainedStaff
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
            this.closebutton = new System.Windows.Forms.Button();
            this.workTypecomboBox = new System.Windows.Forms.ComboBox();
            this.staffcomboBox = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.trnrecsradioButton = new System.Windows.Forms.RadioButton();
            this.auditRecradioButton = new System.Windows.Forms.RadioButton();
            this.manageTrnpanel = new System.Windows.Forms.Panel();
            this.notTrainedradioButton = new System.Windows.Forms.RadioButton();
            this.trainedradioButton = new System.Windows.Forms.RadioButton();
            this.ratingcomboBox = new System.Windows.Forms.ComboBox();
            this.label6 = new System.Windows.Forms.Label();
            this.auditpanel = new System.Windows.Forms.Panel();
            this.notetextBox = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.percentGoodnumericUpDown = new System.Windows.Forms.NumericUpDown();
            this.auditdateTimePicker = new System.Windows.Forms.DateTimePicker();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.savebutton = new System.Windows.Forms.Button();
            this.label = new System.Windows.Forms.Label();
            this.cancelbutton = new System.Windows.Forms.Button();
            this.manageTrnpanel.SuspendLayout();
            this.auditpanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.percentGoodnumericUpDown)).BeginInit();
            this.SuspendLayout();
            // 
            // closebutton
            // 
            this.closebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.closebutton.Location = new System.Drawing.Point(908, 537);
            this.closebutton.Name = "closebutton";
            this.closebutton.Size = new System.Drawing.Size(75, 23);
            this.closebutton.TabIndex = 1;
            this.closebutton.Text = "Close";
            this.closebutton.UseVisualStyleBackColor = true;
            this.closebutton.Click += new System.EventHandler(this.closebutton_Click);
            // 
            // workTypecomboBox
            // 
            this.workTypecomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.workTypecomboBox.FormattingEnabled = true;
            this.workTypecomboBox.Location = new System.Drawing.Point(295, 270);
            this.workTypecomboBox.Name = "workTypecomboBox";
            this.workTypecomboBox.Size = new System.Drawing.Size(248, 21);
            this.workTypecomboBox.TabIndex = 2;
            // 
            // staffcomboBox
            // 
            this.staffcomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.staffcomboBox.FormattingEnabled = true;
            this.staffcomboBox.Location = new System.Drawing.Point(591, 270);
            this.staffcomboBox.Name = "staffcomboBox";
            this.staffcomboBox.Size = new System.Drawing.Size(226, 21);
            this.staffcomboBox.TabIndex = 3;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(292, 240);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(97, 16);
            this.label1.TabIndex = 6;
            this.label1.Text = "Type of work";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(588, 240);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(43, 16);
            this.label2.TabIndex = 7;
            this.label2.Text = " Staff";
            // 
            // trnrecsradioButton
            // 
            this.trnrecsradioButton.AutoSize = true;
            this.trnrecsradioButton.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.trnrecsradioButton.Location = new System.Drawing.Point(257, 196);
            this.trnrecsradioButton.Name = "trnrecsradioButton";
            this.trnrecsradioButton.Size = new System.Drawing.Size(277, 24);
            this.trnrecsradioButton.TabIndex = 15;
            this.trnrecsradioButton.Text = "Manage Staff Training Records";
            this.trnrecsradioButton.UseVisualStyleBackColor = true;
            this.trnrecsradioButton.CheckedChanged += new System.EventHandler(this.trnrecsradioButton_CheckedChanged);
            // 
            // auditRecradioButton
            // 
            this.auditRecradioButton.AutoSize = true;
            this.auditRecradioButton.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.auditRecradioButton.Location = new System.Drawing.Point(593, 196);
            this.auditRecradioButton.Name = "auditRecradioButton";
            this.auditRecradioButton.Size = new System.Drawing.Size(223, 24);
            this.auditRecradioButton.TabIndex = 16;
            this.auditRecradioButton.Text = "Add Staff Audit Records";
            this.auditRecradioButton.UseVisualStyleBackColor = true;
            this.auditRecradioButton.CheckedChanged += new System.EventHandler(this.auditRecradioButton_CheckedChanged);
            // 
            // manageTrnpanel
            // 
            this.manageTrnpanel.Controls.Add(this.notTrainedradioButton);
            this.manageTrnpanel.Controls.Add(this.trainedradioButton);
            this.manageTrnpanel.Controls.Add(this.ratingcomboBox);
            this.manageTrnpanel.Controls.Add(this.label6);
            this.manageTrnpanel.Location = new System.Drawing.Point(256, 306);
            this.manageTrnpanel.Name = "manageTrnpanel";
            this.manageTrnpanel.Size = new System.Drawing.Size(605, 38);
            this.manageTrnpanel.TabIndex = 21;
            this.manageTrnpanel.TabStop = true;
            // 
            // notTrainedradioButton
            // 
            this.notTrainedradioButton.AutoSize = true;
            this.notTrainedradioButton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.notTrainedradioButton.Location = new System.Drawing.Point(462, 8);
            this.notTrainedradioButton.Name = "notTrainedradioButton";
            this.notTrainedradioButton.Size = new System.Drawing.Size(108, 20);
            this.notTrainedradioButton.TabIndex = 16;
            this.notTrainedradioButton.TabStop = true;
            this.notTrainedradioButton.Text = "Not Trained";
            this.notTrainedradioButton.UseVisualStyleBackColor = true;
            // 
            // trainedradioButton
            // 
            this.trainedradioButton.AutoSize = true;
            this.trainedradioButton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.trainedradioButton.Location = new System.Drawing.Point(366, 8);
            this.trainedradioButton.Name = "trainedradioButton";
            this.trainedradioButton.Size = new System.Drawing.Size(80, 20);
            this.trainedradioButton.TabIndex = 15;
            this.trainedradioButton.TabStop = true;
            this.trainedradioButton.Text = "Trained";
            this.trainedradioButton.UseVisualStyleBackColor = true;
            // 
            // ratingcomboBox
            // 
            this.ratingcomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.ratingcomboBox.FormattingEnabled = true;
            this.ratingcomboBox.Location = new System.Drawing.Point(101, 9);
            this.ratingcomboBox.Name = "ratingcomboBox";
            this.ratingcomboBox.Size = new System.Drawing.Size(242, 21);
            this.ratingcomboBox.TabIndex = 14;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label6.Location = new System.Drawing.Point(28, 14);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(53, 16);
            this.label6.TabIndex = 13;
            this.label6.Text = "Rating";
            // 
            // auditpanel
            // 
            this.auditpanel.Controls.Add(this.notetextBox);
            this.auditpanel.Controls.Add(this.label3);
            this.auditpanel.Controls.Add(this.percentGoodnumericUpDown);
            this.auditpanel.Controls.Add(this.auditdateTimePicker);
            this.auditpanel.Controls.Add(this.label4);
            this.auditpanel.Controls.Add(this.label5);
            this.auditpanel.Location = new System.Drawing.Point(258, 350);
            this.auditpanel.Name = "auditpanel";
            this.auditpanel.Size = new System.Drawing.Size(603, 116);
            this.auditpanel.TabIndex = 22;
            // 
            // notetextBox
            // 
            this.notetextBox.Location = new System.Drawing.Point(37, 50);
            this.notetextBox.Multiline = true;
            this.notetextBox.Name = "notetextBox";
            this.notetextBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.notetextBox.Size = new System.Drawing.Size(531, 61);
            this.notetextBox.TabIndex = 7;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(41, 34);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(38, 13);
            this.label3.TabIndex = 6;
            this.label3.Text = "Note:";
            // 
            // percentGoodnumericUpDown
            // 
            this.percentGoodnumericUpDown.Increment = new decimal(new int[] {
            10,
            0,
            0,
            0});
            this.percentGoodnumericUpDown.Location = new System.Drawing.Point(474, 6);
            this.percentGoodnumericUpDown.Name = "percentGoodnumericUpDown";
            this.percentGoodnumericUpDown.Size = new System.Drawing.Size(46, 20);
            this.percentGoodnumericUpDown.TabIndex = 3;
            // 
            // auditdateTimePicker
            // 
            this.auditdateTimePicker.Location = new System.Drawing.Point(133, 7);
            this.auditdateTimePicker.Name = "auditdateTimePicker";
            this.auditdateTimePicker.Size = new System.Drawing.Size(200, 20);
            this.auditdateTimePicker.TabIndex = 2;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(339, 9);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(134, 16);
            this.label4.TabIndex = 1;
            this.label4.Text = "Percentage Good:";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label5.Location = new System.Drawing.Point(6, 11);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(130, 16);
            this.label5.TabIndex = 0;
            this.label5.Text = "Select Audit date:";
            // 
            // savebutton
            // 
            this.savebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.savebutton.Location = new System.Drawing.Point(687, 537);
            this.savebutton.Name = "savebutton";
            this.savebutton.Size = new System.Drawing.Size(79, 23);
            this.savebutton.TabIndex = 5;
            this.savebutton.Text = "Save";
            this.savebutton.UseVisualStyleBackColor = true;
            this.savebutton.Click += new System.EventHandler(this.savebutton_Click);
            // 
            // label
            // 
            this.label.AutoSize = true;
            this.label.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label.Location = new System.Drawing.Point(252, 114);
            this.label.Name = "label";
            this.label.Size = new System.Drawing.Size(318, 20);
            this.label.TabIndex = 23;
            this.label.Text = "Please select one of the options below";
            // 
            // cancelbutton
            // 
            this.cancelbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cancelbutton.Location = new System.Drawing.Point(797, 537);
            this.cancelbutton.Name = "cancelbutton";
            this.cancelbutton.Size = new System.Drawing.Size(75, 23);
            this.cancelbutton.TabIndex = 24;
            this.cancelbutton.Text = "Cancel";
            this.cancelbutton.UseVisualStyleBackColor = true;
            this.cancelbutton.Click += new System.EventHandler(this.cancelbutton_Click);
            // 
            // ManageTrainedStaff
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoScroll = true;
            this.AutoSize = true;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(1062, 626);
            this.Controls.Add(this.cancelbutton);
            this.Controls.Add(this.label);
            this.Controls.Add(this.savebutton);
            this.Controls.Add(this.auditRecradioButton);
            this.Controls.Add(this.trnrecsradioButton);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.staffcomboBox);
            this.Controls.Add(this.workTypecomboBox);
            this.Controls.Add(this.closebutton);
            this.Controls.Add(this.auditpanel);
            this.Controls.Add(this.manageTrnpanel);
            this.Name = "ManageTrainedStaff";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Manage Trained Staff";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.ManageTrainedStaff_Load);
            this.manageTrnpanel.ResumeLayout(false);
            this.manageTrnpanel.PerformLayout();
            this.auditpanel.ResumeLayout(false);
            this.auditpanel.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.percentGoodnumericUpDown)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button closebutton;
        private System.Windows.Forms.ComboBox workTypecomboBox;
        private System.Windows.Forms.ComboBox staffcomboBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.RadioButton trnrecsradioButton;
        private System.Windows.Forms.RadioButton auditRecradioButton;
        private System.Windows.Forms.Panel manageTrnpanel;
        private System.Windows.Forms.Panel auditpanel;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.NumericUpDown percentGoodnumericUpDown;
        private System.Windows.Forms.DateTimePicker auditdateTimePicker;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.RadioButton notTrainedradioButton;
        private System.Windows.Forms.RadioButton trainedradioButton;
        private System.Windows.Forms.ComboBox ratingcomboBox;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label;
        private System.Windows.Forms.Button savebutton;
        private System.Windows.Forms.TextBox notetextBox;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button cancelbutton;
    }
}

