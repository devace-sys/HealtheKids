namespace StudentDataTracking
{
    partial class StudentDataContact
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
            this.label1 = new System.Windows.Forms.Label();
            this.clientcomboBox = new System.Windows.Forms.ComboBox();
            this.fileTypecomboBox = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.firstNametextBox = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.emailtextBox = new System.Windows.Forms.TextBox();
            this.label5 = new System.Windows.Forms.Label();
            this.lastNametextBox = new System.Windows.Forms.TextBox();
            this.closebutton = new System.Windows.Forms.Button();
            this.cancelbutton = new System.Windows.Forms.Button();
            this.viewbutton = new System.Windows.Forms.Button();
            this.savebutton = new System.Windows.Forms.Button();
            this.label6 = new System.Windows.Forms.Label();
            this.notestextBox = new System.Windows.Forms.TextBox();
            this.label7 = new System.Windows.Forms.Label();
            this.secondayEmailtextBox = new System.Windows.Forms.TextBox();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.AllowUserToAddRows = false;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.Silver;
            this.dataGridView1.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            this.dataGridView1.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.dataGridView1.BackgroundColor = System.Drawing.SystemColors.Control;
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Edit});
            this.dataGridView1.Location = new System.Drawing.Point(18, 227);
            this.dataGridView1.Margin = new System.Windows.Forms.Padding(4);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowHeadersVisible = false;
            this.dataGridView1.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridView1.Size = new System.Drawing.Size(973, 352);
            this.dataGridView1.TabIndex = 0;
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
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(73, 67);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(47, 16);
            this.label1.TabIndex = 1;
            this.label1.Text = "Client";
            // 
            // clientcomboBox
            // 
            this.clientcomboBox.FormattingEnabled = true;
            this.clientcomboBox.Location = new System.Drawing.Point(128, 59);
            this.clientcomboBox.Margin = new System.Windows.Forms.Padding(4);
            this.clientcomboBox.Name = "clientcomboBox";
            this.clientcomboBox.Size = new System.Drawing.Size(265, 24);
            this.clientcomboBox.TabIndex = 2;
            // 
            // fileTypecomboBox
            // 
            this.fileTypecomboBox.FormattingEnabled = true;
            this.fileTypecomboBox.Location = new System.Drawing.Point(128, 93);
            this.fileTypecomboBox.Margin = new System.Windows.Forms.Padding(4);
            this.fileTypecomboBox.Name = "fileTypecomboBox";
            this.fileTypecomboBox.Size = new System.Drawing.Size(265, 24);
            this.fileTypecomboBox.TabIndex = 4;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(52, 99);
            this.label2.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(70, 16);
            this.label2.TabIndex = 3;
            this.label2.Text = "FileType";
            // 
            // firstNametextBox
            // 
            this.firstNametextBox.Location = new System.Drawing.Point(650, 59);
            this.firstNametextBox.Margin = new System.Windows.Forms.Padding(4);
            this.firstNametextBox.Name = "firstNametextBox";
            this.firstNametextBox.Size = new System.Drawing.Size(271, 22);
            this.firstNametextBox.TabIndex = 5;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(564, 62);
            this.label3.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(83, 16);
            this.label3.TabIndex = 6;
            this.label3.Text = "First Name";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(598, 130);
            this.label4.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(47, 16);
            this.label4.TabIndex = 8;
            this.label4.Text = "Email";
            // 
            // emailtextBox
            // 
            this.emailtextBox.Location = new System.Drawing.Point(650, 124);
            this.emailtextBox.Margin = new System.Windows.Forms.Padding(4);
            this.emailtextBox.Name = "emailtextBox";
            this.emailtextBox.Size = new System.Drawing.Size(271, 22);
            this.emailtextBox.TabIndex = 9;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label5.Location = new System.Drawing.Point(564, 95);
            this.label5.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(82, 16);
            this.label5.TabIndex = 10;
            this.label5.Text = "Last Name";
            // 
            // lastNametextBox
            // 
            this.lastNametextBox.Location = new System.Drawing.Point(650, 92);
            this.lastNametextBox.Margin = new System.Windows.Forms.Padding(4);
            this.lastNametextBox.Name = "lastNametextBox";
            this.lastNametextBox.Size = new System.Drawing.Size(271, 22);
            this.lastNametextBox.TabIndex = 7;
            // 
            // closebutton
            // 
            this.closebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.closebutton.Location = new System.Drawing.Point(891, 583);
            this.closebutton.Margin = new System.Windows.Forms.Padding(4);
            this.closebutton.Name = "closebutton";
            this.closebutton.Size = new System.Drawing.Size(84, 28);
            this.closebutton.TabIndex = 11;
            this.closebutton.Text = "Close";
            this.closebutton.UseVisualStyleBackColor = true;
            this.closebutton.Click += new System.EventHandler(this.closebutton_Click);
            // 
            // cancelbutton
            // 
            this.cancelbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cancelbutton.Location = new System.Drawing.Point(664, 189);
            this.cancelbutton.Margin = new System.Windows.Forms.Padding(4);
            this.cancelbutton.Name = "cancelbutton";
            this.cancelbutton.Size = new System.Drawing.Size(89, 28);
            this.cancelbutton.TabIndex = 12;
            this.cancelbutton.Text = "Cancel";
            this.cancelbutton.UseVisualStyleBackColor = true;
            this.cancelbutton.Click += new System.EventHandler(this.cancelbutton_Click);
            // 
            // viewbutton
            // 
            this.viewbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.viewbutton.Location = new System.Drawing.Point(887, 189);
            this.viewbutton.Margin = new System.Windows.Forms.Padding(4);
            this.viewbutton.Name = "viewbutton";
            this.viewbutton.Size = new System.Drawing.Size(89, 28);
            this.viewbutton.TabIndex = 13;
            this.viewbutton.Text = "View";
            this.viewbutton.UseVisualStyleBackColor = true;
            this.viewbutton.Click += new System.EventHandler(this.viewbutton_Click);
            // 
            // savebutton
            // 
            this.savebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.savebutton.Location = new System.Drawing.Point(777, 189);
            this.savebutton.Margin = new System.Windows.Forms.Padding(4);
            this.savebutton.Name = "savebutton";
            this.savebutton.Size = new System.Drawing.Size(89, 28);
            this.savebutton.TabIndex = 14;
            this.savebutton.Text = "Save";
            this.savebutton.UseVisualStyleBackColor = true;
            this.savebutton.Click += new System.EventHandler(this.savebutton_Click);
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label6.Location = new System.Drawing.Point(71, 126);
            this.label6.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(49, 16);
            this.label6.TabIndex = 15;
            this.label6.Text = "Notes";
            // 
            // notestextBox
            // 
            this.notestextBox.Location = new System.Drawing.Point(128, 126);
            this.notestextBox.Margin = new System.Windows.Forms.Padding(4);
            this.notestextBox.Multiline = true;
            this.notestextBox.Name = "notestextBox";
            this.notestextBox.Size = new System.Drawing.Size(318, 79);
            this.notestextBox.TabIndex = 16;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label7.Location = new System.Drawing.Point(465, 157);
            this.label7.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(182, 16);
            this.label7.TabIndex = 17;
            this.label7.Text = "Secondary Contact Email";
            // 
            // secondayEmailtextBox
            // 
            this.secondayEmailtextBox.Location = new System.Drawing.Point(650, 154);
            this.secondayEmailtextBox.Margin = new System.Windows.Forms.Padding(4);
            this.secondayEmailtextBox.Name = "secondayEmailtextBox";
            this.secondayEmailtextBox.Size = new System.Drawing.Size(271, 22);
            this.secondayEmailtextBox.TabIndex = 18;
            // 
            // StudentDataContact
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1010, 644);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.secondayEmailtextBox);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.notestextBox);
            this.Controls.Add(this.savebutton);
            this.Controls.Add(this.viewbutton);
            this.Controls.Add(this.cancelbutton);
            this.Controls.Add(this.closebutton);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.lastNametextBox);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.emailtextBox);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.firstNametextBox);
            this.Controls.Add(this.fileTypecomboBox);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.clientcomboBox);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.dataGridView1);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "StudentDataContact";
            this.Text = "StudentDataContact";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.StudentDataContact_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.DataGridViewButtonColumn Edit;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox clientcomboBox;
        private System.Windows.Forms.ComboBox fileTypecomboBox;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox firstNametextBox;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.TextBox emailtextBox;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TextBox lastNametextBox;
        private System.Windows.Forms.Button closebutton;
        private System.Windows.Forms.Button cancelbutton;
        private System.Windows.Forms.Button viewbutton;
        private System.Windows.Forms.Button savebutton;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.TextBox notestextBox;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.TextBox secondayEmailtextBox;
    }
}