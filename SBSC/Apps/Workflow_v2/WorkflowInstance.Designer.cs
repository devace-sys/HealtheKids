namespace Workflow_v2
{
    partial class WorkflowInstance
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
            this.workflowTabControl1 = new System.Windows.Forms.TabControl();
            this.singleStaffPickerTab = new System.Windows.Forms.TabPage();
            this.SqlRptTab = new System.Windows.Forms.TabPage();
            this.PermissionsTab = new System.Windows.Forms.TabPage();
            this.sqlRptTabBkrndWrkr = new System.ComponentModel.BackgroundWorker();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.workflowTabControl1.SuspendLayout();
            this.PermissionsTab.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // workflowTabControl1
            // 
            this.workflowTabControl1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.workflowTabControl1.Controls.Add(this.singleStaffPickerTab);
            this.workflowTabControl1.Controls.Add(this.SqlRptTab);
            this.workflowTabControl1.Controls.Add(this.PermissionsTab);
            this.workflowTabControl1.Location = new System.Drawing.Point(13, 13);
            this.workflowTabControl1.Name = "workflowTabControl1";
            this.workflowTabControl1.SelectedIndex = 0;
            this.workflowTabControl1.Size = new System.Drawing.Size(726, 478);
            this.workflowTabControl1.TabIndex = 0;
            // 
            // singleStaffPickerTab
            // 
            this.singleStaffPickerTab.Location = new System.Drawing.Point(4, 22);
            this.singleStaffPickerTab.Name = "singleStaffPickerTab";
            this.singleStaffPickerTab.Padding = new System.Windows.Forms.Padding(3);
            this.singleStaffPickerTab.Size = new System.Drawing.Size(718, 452);
            this.singleStaffPickerTab.TabIndex = 3;
            this.singleStaffPickerTab.Text = "Individual Staff Assignments";
            this.singleStaffPickerTab.UseVisualStyleBackColor = true;
            // 
            // SqlRptTab
            // 
            this.SqlRptTab.BackColor = System.Drawing.SystemColors.ControlLight;
            this.SqlRptTab.Location = new System.Drawing.Point(4, 22);
            this.SqlRptTab.Name = "SqlRptTab";
            this.SqlRptTab.Padding = new System.Windows.Forms.Padding(3);
            this.SqlRptTab.Size = new System.Drawing.Size(718, 452);
            this.SqlRptTab.TabIndex = 0;
            this.SqlRptTab.Text = "SQL Reports";
            this.SqlRptTab.UseVisualStyleBackColor = true;
            // 
            // PermissionsTab
            // 
            this.PermissionsTab.BackColor = System.Drawing.Color.LightGray;
            this.PermissionsTab.Controls.Add(this.dataGridView1);
            this.PermissionsTab.Location = new System.Drawing.Point(4, 22);
            this.PermissionsTab.Name = "PermissionsTab";
            this.PermissionsTab.Padding = new System.Windows.Forms.Padding(3);
            this.PermissionsTab.Size = new System.Drawing.Size(718, 452);
            this.PermissionsTab.TabIndex = 2;
            this.PermissionsTab.Text = "User Permissions";
            this.PermissionsTab.UseVisualStyleBackColor = true;
            this.PermissionsTab.Click += new System.EventHandler(this.PermissionsTab_Click);
            // 
            // dataGridView1
            // 
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Location = new System.Drawing.Point(4, 21);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.Size = new System.Drawing.Size(708, 425);
            this.dataGridView1.TabIndex = 0;
            // 
            // WorkflowInstance
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(751, 503);
            this.Controls.Add(this.workflowTabControl1);
            this.Name = "WorkflowInstance";
            this.Text = "Workflow";
            this.Load += new System.EventHandler(this.WorkflowInstance_Load);
            this.workflowTabControl1.ResumeLayout(false);
            this.PermissionsTab.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TabControl workflowTabControl1;
        private System.Windows.Forms.TabPage SqlRptTab;
        private System.ComponentModel.BackgroundWorker sqlRptTabBkrndWrkr;
        private System.Windows.Forms.TabPage PermissionsTab;
        private System.Windows.Forms.TabPage singleStaffPickerTab;
        private System.Windows.Forms.DataGridView dataGridView1;

    }
}

