namespace WORKFLOW
{
    partial class WorkControl
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
            this.clientcomboBox = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.workTypecomboBox = new System.Windows.Forms.ComboBox();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.Edit = new System.Windows.Forms.DataGridViewButtonColumn();
            this.Delete = new System.Windows.Forms.DataGridViewButtonColumn();
            this.savebutton = new System.Windows.Forms.Button();
            this.viewbutton = new System.Windows.Forms.Button();
            this.label3 = new System.Windows.Forms.Label();
            this.notestextBox = new System.Windows.Forms.TextBox();
            this.startdateTimePicker = new System.Windows.Forms.DateTimePicker();
            this.enddateTimePicker = new System.Windows.Forms.DateTimePicker();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.clearbutton = new System.Windows.Forms.Button();
            this.startdatetextBox = new System.Windows.Forms.TextBox();
            this.enddatetextBox = new System.Windows.Forms.TextBox();
            this.clrDatesbutton = new System.Windows.Forms.Button();
            this.closebutton = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.button1.Location = new System.Drawing.Point(1368, 768);
            this.button1.Margin = new System.Windows.Forms.Padding(5);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(133, 34);
            this.button1.TabIndex = 1;
            this.button1.Text = "Close";
            this.button1.UseVisualStyleBackColor = true;
            // 
            // clientcomboBox
            // 
            this.clientcomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.clientcomboBox.FormattingEnabled = true;
            this.clientcomboBox.Location = new System.Drawing.Point(147, 76);
            this.clientcomboBox.Name = "clientcomboBox";
            this.clientcomboBox.Size = new System.Drawing.Size(296, 24);
            this.clientcomboBox.TabIndex = 2;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(102, 84);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(44, 16);
            this.label1.TabIndex = 3;
            this.label1.Text = "Client:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(68, 120);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(78, 16);
            this.label2.TabIndex = 5;
            this.label2.Text = "Work Type:";
            // 
            // workTypecomboBox
            // 
            this.workTypecomboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.workTypecomboBox.FormattingEnabled = true;
            this.workTypecomboBox.Location = new System.Drawing.Point(147, 115);
            this.workTypecomboBox.Name = "workTypecomboBox";
            this.workTypecomboBox.Size = new System.Drawing.Size(296, 24);
            this.workTypecomboBox.TabIndex = 4;
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
            this.Delete});
            this.dataGridView1.Location = new System.Drawing.Point(12, 247);
            this.dataGridView1.MultiSelect = false;
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.ReadOnly = true;
            this.dataGridView1.RowHeadersVisible = false;
            this.dataGridView1.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridView1.Size = new System.Drawing.Size(1040, 348);
            this.dataGridView1.TabIndex = 6;
            this.dataGridView1.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellContentClick);
            // 
            // Edit
            // 
            this.Edit.HeaderText = "Edit";
            this.Edit.Name = "Edit";
            this.Edit.ReadOnly = true;
            this.Edit.Resizable = System.Windows.Forms.DataGridViewTriState.True;
            this.Edit.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
            this.Edit.Text = "Edit";
            this.Edit.UseColumnTextForButtonValue = true;
            this.Edit.Width = 56;
            // 
            // Delete
            // 
            this.Delete.HeaderText = "Delete";
            this.Delete.Name = "Delete";
            this.Delete.ReadOnly = true;
            this.Delete.Text = "Delete";
            this.Delete.UseColumnTextForButtonValue = true;
            this.Delete.Width = 54;
            // 
            // savebutton
            // 
            this.savebutton.Location = new System.Drawing.Point(561, 191);
            this.savebutton.Name = "savebutton";
            this.savebutton.Size = new System.Drawing.Size(97, 23);
            this.savebutton.TabIndex = 7;
            this.savebutton.Text = "Save";
            this.savebutton.UseVisualStyleBackColor = true;
            this.savebutton.Click += new System.EventHandler(this.savebutton_Click);
            // 
            // viewbutton
            // 
            this.viewbutton.Location = new System.Drawing.Point(767, 191);
            this.viewbutton.Name = "viewbutton";
            this.viewbutton.Size = new System.Drawing.Size(97, 23);
            this.viewbutton.TabIndex = 8;
            this.viewbutton.Text = "Refresh View";
            this.viewbutton.UseVisualStyleBackColor = true;
            this.viewbutton.Click += new System.EventHandler(this.viewbutton_Click);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(477, 77);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(47, 16);
            this.label3.TabIndex = 9;
            this.label3.Text = "Notes:";
            // 
            // notestextBox
            // 
            this.notestextBox.Location = new System.Drawing.Point(527, 77);
            this.notestextBox.Multiline = true;
            this.notestextBox.Name = "notestextBox";
            this.notestextBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.notestextBox.Size = new System.Drawing.Size(440, 70);
            this.notestextBox.TabIndex = 10;
            // 
            // startdateTimePicker
            // 
            this.startdateTimePicker.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.startdateTimePicker.Location = new System.Drawing.Point(248, 154);
            this.startdateTimePicker.Name = "startdateTimePicker";
            this.startdateTimePicker.Size = new System.Drawing.Size(21, 22);
            this.startdateTimePicker.TabIndex = 11;
            this.startdateTimePicker.Value = new System.DateTime(2013, 8, 2, 0, 0, 0, 0);
            this.startdateTimePicker.ValueChanged += new System.EventHandler(this.startdateTimePicker_ValueChanged);
            // 
            // enddateTimePicker
            // 
            this.enddateTimePicker.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.enddateTimePicker.Location = new System.Drawing.Point(247, 191);
            this.enddateTimePicker.Name = "enddateTimePicker";
            this.enddateTimePicker.Size = new System.Drawing.Size(21, 22);
            this.enddateTimePicker.TabIndex = 12;
            this.enddateTimePicker.ValueChanged += new System.EventHandler(this.enddateTimePicker_ValueChanged);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(76, 160);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(70, 16);
            this.label4.TabIndex = 13;
            this.label4.Text = "Start Date:";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(79, 198);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(67, 16);
            this.label5.TabIndex = 14;
            this.label5.Text = "End Date:";
            // 
            // clearbutton
            // 
            this.clearbutton.Location = new System.Drawing.Point(664, 191);
            this.clearbutton.Name = "clearbutton";
            this.clearbutton.Size = new System.Drawing.Size(97, 23);
            this.clearbutton.TabIndex = 15;
            this.clearbutton.Text = "Cancel";
            this.clearbutton.UseVisualStyleBackColor = true;
            this.clearbutton.Click += new System.EventHandler(this.clearbutton_Click);
            // 
            // startdatetextBox
            // 
            this.startdatetextBox.BackColor = System.Drawing.SystemColors.ControlLightLight;
            this.startdatetextBox.Location = new System.Drawing.Point(147, 154);
            this.startdatetextBox.Name = "startdatetextBox";
            this.startdatetextBox.ReadOnly = true;
            this.startdatetextBox.Size = new System.Drawing.Size(100, 22);
            this.startdatetextBox.TabIndex = 16;
            // 
            // enddatetextBox
            // 
            this.enddatetextBox.BackColor = System.Drawing.SystemColors.ControlLightLight;
            this.enddatetextBox.Location = new System.Drawing.Point(147, 191);
            this.enddatetextBox.Name = "enddatetextBox";
            this.enddatetextBox.ReadOnly = true;
            this.enddatetextBox.Size = new System.Drawing.Size(100, 22);
            this.enddatetextBox.TabIndex = 17;
            // 
            // clrDatesbutton
            // 
            this.clrDatesbutton.Location = new System.Drawing.Point(292, 191);
            this.clrDatesbutton.Name = "clrDatesbutton";
            this.clrDatesbutton.Size = new System.Drawing.Size(97, 23);
            this.clrDatesbutton.TabIndex = 20;
            this.clrDatesbutton.Text = "Clear Dates";
            this.clrDatesbutton.UseVisualStyleBackColor = true;
            this.clrDatesbutton.Click += new System.EventHandler(this.clrDatesbutton_Click);
            // 
            // closebutton
            // 
            this.closebutton.Location = new System.Drawing.Point(870, 191);
            this.closebutton.Name = "closebutton";
            this.closebutton.Size = new System.Drawing.Size(97, 23);
            this.closebutton.TabIndex = 21;
            this.closebutton.Text = "Close";
            this.closebutton.UseVisualStyleBackColor = true;
            this.closebutton.Click += new System.EventHandler(this.closebutton_Click);
            // 
            // WorkControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1064, 628);
            this.Controls.Add(this.closebutton);
            this.Controls.Add(this.clrDatesbutton);
            this.Controls.Add(this.enddatetextBox);
            this.Controls.Add(this.startdatetextBox);
            this.Controls.Add(this.clearbutton);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.enddateTimePicker);
            this.Controls.Add(this.startdateTimePicker);
            this.Controls.Add(this.notestextBox);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.viewbutton);
            this.Controls.Add(this.savebutton);
            this.Controls.Add(this.dataGridView1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.workTypecomboBox);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.clientcomboBox);
            this.Controls.Add(this.button1);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "WorkControl";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = " Work Control";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.WorkControl_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.ComboBox clientcomboBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox workTypecomboBox;
        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.Button savebutton;
        private System.Windows.Forms.DataGridViewButtonColumn Edit;
        private System.Windows.Forms.DataGridViewButtonColumn Delete;
        private System.Windows.Forms.Button viewbutton;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox notestextBox;
        private System.Windows.Forms.DateTimePicker startdateTimePicker;
        private System.Windows.Forms.DateTimePicker enddateTimePicker;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Button clearbutton;
        private System.Windows.Forms.TextBox startdatetextBox;
        private System.Windows.Forms.TextBox enddatetextBox;
        private System.Windows.Forms.Button clrDatesbutton;
        private System.Windows.Forms.Button closebutton;
    }
}

