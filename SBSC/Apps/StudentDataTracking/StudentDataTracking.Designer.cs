namespace StudentDataTracking
{
    partial class StudentDataTracking
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
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.studentDataToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.viewToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.saveToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.manageDataToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.fileTypesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.dataContactToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.DataFilesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.userlabel = new System.Windows.Forms.Label();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.studentDataToolStripMenuItem,
            this.manageDataToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(1014, 24);
            this.menuStrip1.TabIndex = 1;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // studentDataToolStripMenuItem
            // 
            this.studentDataToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.viewToolStripMenuItem,
            this.saveToolStripMenuItem});
            this.studentDataToolStripMenuItem.Name = "studentDataToolStripMenuItem";
            this.studentDataToolStripMenuItem.Size = new System.Drawing.Size(114, 20);
            this.studentDataToolStripMenuItem.Text = "TrackingRecords";
            // 
            // viewToolStripMenuItem
            // 
            this.viewToolStripMenuItem.Name = "viewToolStripMenuItem";
            this.viewToolStripMenuItem.Size = new System.Drawing.Size(184, 22);
            this.viewToolStripMenuItem.Text = "View/ Edit/Delete";
            this.viewToolStripMenuItem.Click += new System.EventHandler(this.viewToolStripMenuItem_Click);
            // 
            // saveToolStripMenuItem
            // 
            this.saveToolStripMenuItem.Name = "saveToolStripMenuItem";
            this.saveToolStripMenuItem.Size = new System.Drawing.Size(184, 22);
            this.saveToolStripMenuItem.Text = "Save new";
            this.saveToolStripMenuItem.Click += new System.EventHandler(this.saveToolStripMenuItem_Click);
            // 
            // manageDataToolStripMenuItem
            // 
            this.manageDataToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileTypesToolStripMenuItem,
            this.dataContactToolStripMenuItem,
            this.DataFilesToolStripMenuItem});
            this.manageDataToolStripMenuItem.Name = "manageDataToolStripMenuItem";
            this.manageDataToolStripMenuItem.Size = new System.Drawing.Size(94, 20);
            this.manageDataToolStripMenuItem.Text = "Manage Data";
            // 
            // fileTypesToolStripMenuItem
            // 
            this.fileTypesToolStripMenuItem.Name = "fileTypesToolStripMenuItem";
            this.fileTypesToolStripMenuItem.Size = new System.Drawing.Size(142, 22);
            this.fileTypesToolStripMenuItem.Text = "File types ";
            this.fileTypesToolStripMenuItem.Click += new System.EventHandler(this.fileTypesToolStripMenuItem_Click);
            // 
            // dataContactToolStripMenuItem
            // 
            this.dataContactToolStripMenuItem.Name = "dataContactToolStripMenuItem";
            this.dataContactToolStripMenuItem.Size = new System.Drawing.Size(142, 22);
            this.dataContactToolStripMenuItem.Text = "Contacts";
            this.dataContactToolStripMenuItem.Click += new System.EventHandler(this.dataContactToolStripMenuItem_Click);
            // 
            // DataFilesToolStripMenuItem
            // 
            this.DataFilesToolStripMenuItem.Name = "DataFilesToolStripMenuItem";
            this.DataFilesToolStripMenuItem.Size = new System.Drawing.Size(142, 22);
            this.DataFilesToolStripMenuItem.Text = "Data files";
            this.DataFilesToolStripMenuItem.Click += new System.EventHandler(this.DataFilesToolStripMenuItem_Click);
            // 
            // userlabel
            // 
            this.userlabel.Location = new System.Drawing.Point(830, 27);
            this.userlabel.Name = "userlabel";
            this.userlabel.Size = new System.Drawing.Size(178, 13);
            this.userlabel.TabIndex = 3;
            this.userlabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // StudentDataTracking
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1014, 655);
            this.Controls.Add(this.userlabel);
            this.Controls.Add(this.menuStrip1);
            this.IsMdiContainer = true;
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "StudentDataTracking";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "SBSC - StudentDataTracking";
            this.Load += new System.EventHandler(this.StudentDataTracking_Load);
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.StudentDataTracking_FormClosing);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem studentDataToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem manageDataToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem dataContactToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem DataFilesToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem fileTypesToolStripMenuItem;
        private System.Windows.Forms.Label userlabel;
        private System.Windows.Forms.ToolStripMenuItem viewToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem saveToolStripMenuItem;
    }
}

