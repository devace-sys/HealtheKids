namespace StudentDataTracking
{
    partial class StudentDataFiles
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
            this.EDIT = new System.Windows.Forms.DataGridViewButtonColumn();
            this.DELETE = new System.Windows.Forms.DataGridViewButtonColumn();
            this.label1 = new System.Windows.Forms.Label();
            this.clientcomboBox = new System.Windows.Forms.ComboBox();
            this.companycomboBox = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.viewbutton = new System.Windows.Forms.Button();
            this.fileTypecomboBox = new System.Windows.Forms.ComboBox();
            this.label3 = new System.Windows.Forms.Label();
            this.quarterlyradioButton = new System.Windows.Forms.RadioButton();
            this.monthlyradioButton = new System.Windows.Forms.RadioButton();
            this.closebutton = new System.Windows.Forms.Button();
            this.savebutton = new System.Windows.Forms.Button();
            this.cancelbutton = new System.Windows.Forms.Button();
            this.autoReqcheckBox = new System.Windows.Forms.CheckBox();
            this.userscomboBox = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
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
            this.EDIT,
            this.DELETE});
            this.dataGridView1.Location = new System.Drawing.Point(25, 175);
            this.dataGridView1.MultiSelect = false;
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowHeadersVisible = false;
            this.dataGridView1.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridView1.Size = new System.Drawing.Size(963, 387);
            this.dataGridView1.TabIndex = 0;
            this.dataGridView1.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellContentClick);
            // 
            // EDIT
            // 
            this.EDIT.HeaderText = "EDIT";
            this.EDIT.Name = "EDIT";
            this.EDIT.ReadOnly = true;
            this.EDIT.Resizable = System.Windows.Forms.DataGridViewTriState.True;
            this.EDIT.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
            this.EDIT.Text = "EDIT";
            this.EDIT.UseColumnTextForButtonValue = true;
            this.EDIT.Width = 57;
            // 
            // DELETE
            // 
            this.DELETE.HeaderText = "DELETE";
            this.DELETE.Name = "DELETE";
            this.DELETE.ReadOnly = true;
            this.DELETE.Text = "DELETE";
            this.DELETE.UseColumnTextForButtonValue = true;
            this.DELETE.Width = 55;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(53, 93);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(47, 16);
            this.label1.TabIndex = 2;
            this.label1.Text = "Client";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // clientcomboBox
            // 
            this.clientcomboBox.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.clientcomboBox.FormattingEnabled = true;
            this.clientcomboBox.Location = new System.Drawing.Point(106, 86);
            this.clientcomboBox.Name = "clientcomboBox";
            this.clientcomboBox.Size = new System.Drawing.Size(284, 24);
            this.clientcomboBox.TabIndex = 3;
            // 
            // companycomboBox
            // 
            this.companycomboBox.FormattingEnabled = true;
            this.companycomboBox.Location = new System.Drawing.Point(576, 89);
            this.companycomboBox.Name = "companycomboBox";
            this.companycomboBox.Size = new System.Drawing.Size(114, 21);
            this.companycomboBox.TabIndex = 8;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(420, 92);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(150, 16);
            this.label2.TabIndex = 4;
            this.label2.Text = "Company requesting";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // viewbutton
            // 
            this.viewbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.viewbutton.Location = new System.Drawing.Point(893, 125);
            this.viewbutton.Name = "viewbutton";
            this.viewbutton.Size = new System.Drawing.Size(75, 23);
            this.viewbutton.TabIndex = 6;
            this.viewbutton.Text = "VIEW";
            this.viewbutton.UseVisualStyleBackColor = true;
            this.viewbutton.Click += new System.EventHandler(this.viewbutton_Click);
            // 
            // fileTypecomboBox
            // 
            this.fileTypecomboBox.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.fileTypecomboBox.FormattingEnabled = true;
            this.fileTypecomboBox.Location = new System.Drawing.Point(106, 124);
            this.fileTypecomboBox.Name = "fileTypecomboBox";
            this.fileTypecomboBox.Size = new System.Drawing.Size(284, 24);
            this.fileTypecomboBox.TabIndex = 5;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(26, 128);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(74, 16);
            this.label3.TabIndex = 7;
            this.label3.Text = "File Type";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // quarterlyradioButton
            // 
            this.quarterlyradioButton.AutoSize = true;
            this.quarterlyradioButton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.quarterlyradioButton.Location = new System.Drawing.Point(424, 128);
            this.quarterlyradioButton.Name = "quarterlyradioButton";
            this.quarterlyradioButton.Size = new System.Drawing.Size(89, 20);
            this.quarterlyradioButton.TabIndex = 9;
            this.quarterlyradioButton.TabStop = true;
            this.quarterlyradioButton.Text = "Quarterly";
            this.quarterlyradioButton.UseVisualStyleBackColor = true;
            // 
            // monthlyradioButton
            // 
            this.monthlyradioButton.AutoSize = true;
            this.monthlyradioButton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.monthlyradioButton.Location = new System.Drawing.Point(514, 128);
            this.monthlyradioButton.Name = "monthlyradioButton";
            this.monthlyradioButton.Size = new System.Drawing.Size(79, 20);
            this.monthlyradioButton.TabIndex = 10;
            this.monthlyradioButton.TabStop = true;
            this.monthlyradioButton.Text = "Monthly";
            this.monthlyradioButton.UseVisualStyleBackColor = true;
            // 
            // closebutton
            // 
            this.closebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.closebutton.Location = new System.Drawing.Point(893, 581);
            this.closebutton.Name = "closebutton";
            this.closebutton.Size = new System.Drawing.Size(75, 23);
            this.closebutton.TabIndex = 11;
            this.closebutton.Text = "CLOSE";
            this.closebutton.UseVisualStyleBackColor = true;
            this.closebutton.Click += new System.EventHandler(this.closebutton_Click);
            // 
            // savebutton
            // 
            this.savebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.savebutton.Location = new System.Drawing.Point(731, 125);
            this.savebutton.Name = "savebutton";
            this.savebutton.Size = new System.Drawing.Size(75, 23);
            this.savebutton.TabIndex = 12;
            this.savebutton.Text = "Save";
            this.savebutton.UseVisualStyleBackColor = true;
            this.savebutton.Click += new System.EventHandler(this.savebutton_Click);
            // 
            // cancelbutton
            // 
            this.cancelbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cancelbutton.Location = new System.Drawing.Point(812, 125);
            this.cancelbutton.Name = "cancelbutton";
            this.cancelbutton.Size = new System.Drawing.Size(75, 23);
            this.cancelbutton.TabIndex = 13;
            this.cancelbutton.Text = "CANCEL";
            this.cancelbutton.UseVisualStyleBackColor = true;
            this.cancelbutton.Click += new System.EventHandler(this.cancelbutton_Click);
            // 
            // autoReqcheckBox
            // 
            this.autoReqcheckBox.AutoSize = true;
            this.autoReqcheckBox.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.autoReqcheckBox.Location = new System.Drawing.Point(600, 130);
            this.autoReqcheckBox.Name = "autoReqcheckBox";
            this.autoReqcheckBox.Size = new System.Drawing.Size(120, 20);
            this.autoReqcheckBox.TabIndex = 14;
            this.autoReqcheckBox.Text = "Auto Request";
            this.autoReqcheckBox.UseVisualStyleBackColor = true;
            this.autoReqcheckBox.CheckedChanged += new System.EventHandler(this.autoReqcheckBox_CheckedChanged);
            // 
            // userscomboBox
            // 
            this.userscomboBox.FormattingEnabled = true;
            this.userscomboBox.Location = new System.Drawing.Point(810, 89);
            this.userscomboBox.Name = "userscomboBox";
            this.userscomboBox.Size = new System.Drawing.Size(163, 21);
            this.userscomboBox.TabIndex = 16;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(698, 92);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(106, 16);
            this.label4.TabIndex = 15;
            this.label4.Text = "Requested By";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // StudentDataFiles
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1010, 644);
            this.Controls.Add(this.userscomboBox);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.autoReqcheckBox);
            this.Controls.Add(this.cancelbutton);
            this.Controls.Add(this.savebutton);
            this.Controls.Add(this.closebutton);
            this.Controls.Add(this.monthlyradioButton);
            this.Controls.Add(this.quarterlyradioButton);
            this.Controls.Add(this.fileTypecomboBox);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.viewbutton);
            this.Controls.Add(this.companycomboBox);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.clientcomboBox);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.dataGridView1);
            this.Name = "StudentDataFiles";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "StudentDataFiles";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.StudentDataFileTypes_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.DataGridViewButtonColumn EDIT;
        private System.Windows.Forms.DataGridViewButtonColumn DELETE;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox clientcomboBox;
        private System.Windows.Forms.ComboBox companycomboBox;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button viewbutton;
        private System.Windows.Forms.ComboBox fileTypecomboBox;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.RadioButton quarterlyradioButton;
        private System.Windows.Forms.RadioButton monthlyradioButton;
        private System.Windows.Forms.Button closebutton;
        private System.Windows.Forms.Button savebutton;
        private System.Windows.Forms.Button cancelbutton;
        private System.Windows.Forms.CheckBox autoReqcheckBox;
        private System.Windows.Forms.ComboBox userscomboBox;
        private System.Windows.Forms.Label label4;
    }
}