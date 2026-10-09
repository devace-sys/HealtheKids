namespace WORKFLOW
{
    partial class StaffHoursView
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            this.closebutton = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.staffHoursdataGridView = new System.Windows.Forms.DataGridView();
            this.staffcomboBox = new System.Windows.Forms.ComboBox();
            this.stafflabel = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.daycomboBox = new System.Windows.Forms.ComboBox();
            this.clearbutton = new System.Windows.Forms.Button();
            this.editbutton = new System.Windows.Forms.Button();
            this.workWeekdateTimePicker = new System.Windows.Forms.DateTimePicker();
            ((System.ComponentModel.ISupportInitialize)(this.staffHoursdataGridView)).BeginInit();
            this.SuspendLayout();
            // 
            // closebutton
            // 
            this.closebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.closebutton.Location = new System.Drawing.Point(908, 525);
            this.closebutton.Name = "closebutton";
            this.closebutton.Size = new System.Drawing.Size(75, 23);
            this.closebutton.TabIndex = 1;
            this.closebutton.Text = "Close";
            this.closebutton.UseVisualStyleBackColor = true;
            this.closebutton.Click += new System.EventHandler(this.closebutton_Click);
            // 
            // label2
            // 
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(46, 31);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(172, 23);
            this.label2.TabIndex = 3;
            this.label2.Text = "Start Date of the week:";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // staffHoursdataGridView
            // 
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.Silver;
            this.staffHoursdataGridView.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            this.staffHoursdataGridView.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.staffHoursdataGridView.BackgroundColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.staffHoursdataGridView.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
            this.staffHoursdataGridView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle3.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle3.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle3.ForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle3.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle3.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.staffHoursdataGridView.DefaultCellStyle = dataGridViewCellStyle3;
            this.staffHoursdataGridView.Location = new System.Drawing.Point(60, 122);
            this.staffHoursdataGridView.MultiSelect = false;
            this.staffHoursdataGridView.Name = "staffHoursdataGridView";
            this.staffHoursdataGridView.ReadOnly = true;
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle4.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle4.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle4.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle4.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle4.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle4.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.staffHoursdataGridView.RowHeadersDefaultCellStyle = dataGridViewCellStyle4;
            this.staffHoursdataGridView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.staffHoursdataGridView.Size = new System.Drawing.Size(923, 356);
            this.staffHoursdataGridView.TabIndex = 4;
            // 
            // staffcomboBox
            // 
            this.staffcomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.staffcomboBox.FormattingEnabled = true;
            this.staffcomboBox.Location = new System.Drawing.Point(473, 56);
            this.staffcomboBox.Name = "staffcomboBox";
            this.staffcomboBox.Size = new System.Drawing.Size(186, 21);
            this.staffcomboBox.TabIndex = 5;
            this.staffcomboBox.SelectedIndexChanged += new System.EventHandler(this.staffcomboBox_SelectedIndexChanged);
            // 
            // stafflabel
            // 
            this.stafflabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.stafflabel.Location = new System.Drawing.Point(457, 30);
            this.stafflabel.Name = "stafflabel";
            this.stafflabel.Size = new System.Drawing.Size(52, 23);
            this.stafflabel.TabIndex = 6;
            this.stafflabel.Text = "Staff:";
            this.stafflabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // label1
            // 
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(287, 30);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(52, 23);
            this.label1.TabIndex = 9;
            this.label1.Text = "Day:";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // daycomboBox
            // 
            this.daycomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.daycomboBox.FormattingEnabled = true;
            this.daycomboBox.Items.AddRange(new object[] {
            "",
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday"});
            this.daycomboBox.Location = new System.Drawing.Point(303, 56);
            this.daycomboBox.Name = "daycomboBox";
            this.daycomboBox.Size = new System.Drawing.Size(142, 21);
            this.daycomboBox.TabIndex = 8;
            this.daycomboBox.SelectedIndexChanged += new System.EventHandler(this.daycomboBox_SelectedIndexChanged);
            // 
            // clearbutton
            // 
            this.clearbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.clearbutton.Location = new System.Drawing.Point(807, 55);
            this.clearbutton.Name = "clearbutton";
            this.clearbutton.Size = new System.Drawing.Size(75, 23);
            this.clearbutton.TabIndex = 10;
            this.clearbutton.Text = "Clear";
            this.clearbutton.UseVisualStyleBackColor = true;
            this.clearbutton.Click += new System.EventHandler(this.clearbutton_Click);
            // 
            // editbutton
            // 
            this.editbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.editbutton.Location = new System.Drawing.Point(690, 55);
            this.editbutton.Name = "editbutton";
            this.editbutton.Size = new System.Drawing.Size(84, 23);
            this.editbutton.TabIndex = 11;
            this.editbutton.Text = "Edit/Save";
            this.editbutton.UseVisualStyleBackColor = true;
            this.editbutton.Click += new System.EventHandler(this.editbutton_Click);
            // 
            // workWeekdateTimePicker
            // 
            this.workWeekdateTimePicker.Location = new System.Drawing.Point(59, 56);
            this.workWeekdateTimePicker.Name = "workWeekdateTimePicker";
            this.workWeekdateTimePicker.Size = new System.Drawing.Size(200, 20);
            this.workWeekdateTimePicker.TabIndex = 12;
            this.workWeekdateTimePicker.ValueChanged += new System.EventHandler(this.workWeekdateTimePicker_ValueChanged_1);
            // 
            // StaffHoursView
            // 
            this.AcceptButton = this.editbutton;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoScroll = true;
            this.AutoSize = true;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(1073, 623);
            this.Controls.Add(this.workWeekdateTimePicker);
            this.Controls.Add(this.editbutton);
            this.Controls.Add(this.clearbutton);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.daycomboBox);
            this.Controls.Add(this.stafflabel);
            this.Controls.Add(this.staffcomboBox);
            this.Controls.Add(this.staffHoursdataGridView);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.closebutton);
            this.Name = "StaffHoursView";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Staff Hours View";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.StaffHoursView_Load);
            this.Activated += new System.EventHandler(this.StaffHoursView_Activated);
            ((System.ComponentModel.ISupportInitialize)(this.staffHoursdataGridView)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button closebutton;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.DataGridView staffHoursdataGridView;
        private System.Windows.Forms.ComboBox staffcomboBox;
        private System.Windows.Forms.Label stafflabel;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox daycomboBox;
        private System.Windows.Forms.Button clearbutton;
        private System.Windows.Forms.Button editbutton;
        private System.Windows.Forms.DateTimePicker workWeekdateTimePicker;
    }
}

