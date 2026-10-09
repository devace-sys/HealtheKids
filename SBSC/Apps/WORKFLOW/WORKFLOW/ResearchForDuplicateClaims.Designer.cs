namespace WORKFLOW
{
    partial class ResearchForDuplicateClaims
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
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.open = new System.Windows.Forms.DataGridViewButtonColumn();
            this.filename = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.filepath = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.clearbutton = new System.Windows.Forms.Button();
            this.closebutton = new System.Windows.Forms.Button();
            this.searchbutton = new System.Windows.Forms.Button();
            this.fileNametextBox = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.statusIndicator = new System.Windows.Forms.Label();
            this.staffFoldersradioButton = new System.Windows.Forms.RadioButton();
            this.finishedFilesradioButton = new System.Windows.Forms.RadioButton();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.AllowUserToAddRows = false;
            this.dataGridView1.AllowUserToDeleteRows = false;
            this.dataGridView1.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.dataGridView1.BackgroundColor = System.Drawing.SystemColors.Control;
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.open,
            this.filename,
            this.filepath});
            this.dataGridView1.Location = new System.Drawing.Point(12, 98);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.ReadOnly = true;
            this.dataGridView1.RowHeadersVisible = false;
            this.dataGridView1.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridView1.Size = new System.Drawing.Size(993, 420);
            this.dataGridView1.TabIndex = 6;
            this.dataGridView1.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellContentClick);
            // 
            // open
            // 
            this.open.HeaderText = "OpenFile";
            this.open.Name = "open";
            this.open.ReadOnly = true;
            this.open.Text = "OpenFile";
            this.open.UseColumnTextForButtonValue = true;
            this.open.Width = 63;
            // 
            // filename
            // 
            this.filename.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.filename.DataPropertyName = "filename";
            this.filename.HeaderText = "File Name";
            this.filename.Name = "filename";
            this.filename.ReadOnly = true;
            this.filename.Width = 89;
            // 
            // filepath
            // 
            this.filepath.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.filepath.DataPropertyName = "filepath";
            this.filepath.HeaderText = "File Location";
            this.filepath.Name = "filepath";
            this.filepath.ReadOnly = true;
            this.filepath.Width = 102;
            // 
            // clearbutton
            // 
            this.clearbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.clearbutton.Location = new System.Drawing.Point(716, 55);
            this.clearbutton.Name = "clearbutton";
            this.clearbutton.Size = new System.Drawing.Size(87, 27);
            this.clearbutton.TabIndex = 8;
            this.clearbutton.Text = "Clear";
            this.clearbutton.UseVisualStyleBackColor = true;
            this.clearbutton.Click += new System.EventHandler(this.clearbutton_Click);
            // 
            // closebutton
            // 
            this.closebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.closebutton.Location = new System.Drawing.Point(918, 545);
            this.closebutton.Name = "closebutton";
            this.closebutton.Size = new System.Drawing.Size(87, 27);
            this.closebutton.TabIndex = 9;
            this.closebutton.Text = "Close";
            this.closebutton.UseVisualStyleBackColor = true;
            this.closebutton.Click += new System.EventHandler(this.closebutton_Click);
            // 
            // searchbutton
            // 
            this.searchbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.searchbutton.Location = new System.Drawing.Point(825, 55);
            this.searchbutton.Name = "searchbutton";
            this.searchbutton.Size = new System.Drawing.Size(87, 27);
            this.searchbutton.TabIndex = 10;
            this.searchbutton.Text = "Search";
            this.searchbutton.UseVisualStyleBackColor = true;
            this.searchbutton.Click += new System.EventHandler(this.searchbutton_Click);
            // 
            // fileNametextBox
            // 
            this.fileNametextBox.Location = new System.Drawing.Point(12, 61);
            this.fileNametextBox.Name = "fileNametextBox";
            this.fileNametextBox.Size = new System.Drawing.Size(409, 21);
            this.fileNametextBox.TabIndex = 11;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(12, 39);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(187, 13);
            this.label1.TabIndex = 12;
            this.label1.Text = "Enter all or part of the file name";
            // 
            // statusIndicator
            // 
            this.statusIndicator.BackColor = System.Drawing.SystemColors.HighlightText;
            this.statusIndicator.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.statusIndicator.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.statusIndicator.Location = new System.Drawing.Point(272, 545);
            this.statusIndicator.Name = "statusIndicator";
            this.statusIndicator.Size = new System.Drawing.Size(432, 25);
            this.statusIndicator.TabIndex = 13;
            this.statusIndicator.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // staffFoldersradioButton
            // 
            this.staffFoldersradioButton.AutoSize = true;
            this.staffFoldersradioButton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.staffFoldersradioButton.Location = new System.Drawing.Point(443, 62);
            this.staffFoldersradioButton.Name = "staffFoldersradioButton";
            this.staffFoldersradioButton.Size = new System.Drawing.Size(211, 19);
            this.staffFoldersradioButton.TabIndex = 14;
            this.staffFoldersradioButton.TabStop = true;
            this.staffFoldersradioButton.Text = "Search Staff Working Folders";
            this.staffFoldersradioButton.UseVisualStyleBackColor = true;
            // 
            // finishedFilesradioButton
            // 
            this.finishedFilesradioButton.AutoSize = true;
            this.finishedFilesradioButton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.finishedFilesradioButton.Location = new System.Drawing.Point(443, 39);
            this.finishedFilesradioButton.Name = "finishedFilesradioButton";
            this.finishedFilesradioButton.Size = new System.Drawing.Size(164, 19);
            this.finishedFilesradioButton.TabIndex = 15;
            this.finishedFilesradioButton.TabStop = true;
            this.finishedFilesradioButton.Text = "Search Finished Files";
            this.finishedFilesradioButton.UseVisualStyleBackColor = true;
            // 
            // ResearchForDuplicateClaims
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1017, 588);
            this.Controls.Add(this.finishedFilesradioButton);
            this.Controls.Add(this.staffFoldersradioButton);
            this.Controls.Add(this.statusIndicator);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.fileNametextBox);
            this.Controls.Add(this.searchbutton);
            this.Controls.Add(this.closebutton);
            this.Controls.Add(this.clearbutton);
            this.Controls.Add(this.dataGridView1);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "ResearchForDuplicateClaims";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Research for Duplicate claims";
            this.Load += new System.EventHandler(this.FinishedWorkView_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.Button clearbutton;
        private System.Windows.Forms.Button closebutton;
        private System.Windows.Forms.Button searchbutton;
        private System.Windows.Forms.TextBox fileNametextBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.DataGridViewButtonColumn open;
        private System.Windows.Forms.DataGridViewTextBoxColumn filename;
        private System.Windows.Forms.DataGridViewTextBoxColumn filepath;
        private System.Windows.Forms.Label statusIndicator;
        private System.Windows.Forms.RadioButton staffFoldersradioButton;
        private System.Windows.Forms.RadioButton finishedFilesradioButton;
    }
}