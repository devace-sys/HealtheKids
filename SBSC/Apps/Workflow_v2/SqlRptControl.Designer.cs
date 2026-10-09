namespace Workflow_v2
{
    partial class SqlRptPanel
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

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.bkgrndRptSqlProgressPanel = new System.Windows.Forms.ProgressBar();
            this.btnSelectedReportRunPanel = new System.Windows.Forms.Button();
            this.reportSelectionPanelComboBox = new System.Windows.Forms.ComboBox();
            this.sqlReportDGVPanel = new System.Windows.Forms.DataGridView();
            this.sqlRptPanelBkrndWrkr = new System.ComponentModel.BackgroundWorker();
            this.dgvColumnContext = new System.Windows.Forms.ContextMenuStrip(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.sqlReportDGVPanel)).BeginInit();
            this.SuspendLayout();
            // 
            // bkgrndRptSqlProgressPanel
            // 
            this.bkgrndRptSqlProgressPanel.Location = new System.Drawing.Point(428, 7);
            this.bkgrndRptSqlProgressPanel.Name = "bkgrndRptSqlProgressPanel";
            this.bkgrndRptSqlProgressPanel.Size = new System.Drawing.Size(96, 23);
            this.bkgrndRptSqlProgressPanel.Style = System.Windows.Forms.ProgressBarStyle.Marquee;
            this.bkgrndRptSqlProgressPanel.TabIndex = 7;
            this.bkgrndRptSqlProgressPanel.Visible = false;
            // 
            // btnSelectedReportRunPanel
            // 
            this.btnSelectedReportRunPanel.Location = new System.Drawing.Point(302, 7);
            this.btnSelectedReportRunPanel.Name = "btnSelectedReportRunPanel";
            this.btnSelectedReportRunPanel.Size = new System.Drawing.Size(120, 23);
            this.btnSelectedReportRunPanel.TabIndex = 6;
            this.btnSelectedReportRunPanel.Text = "Run Selected Report";
            this.btnSelectedReportRunPanel.UseVisualStyleBackColor = true;
            this.btnSelectedReportRunPanel.Click += new System.EventHandler(this.btnSelectedReportRunPanel_Click);
            // 
            // reportSelectionPanelComboBox
            // 
            this.reportSelectionPanelComboBox.AutoCompleteMode = System.Windows.Forms.AutoCompleteMode.Suggest;
            this.reportSelectionPanelComboBox.AutoCompleteSource = System.Windows.Forms.AutoCompleteSource.ListItems;
            this.reportSelectionPanelComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.reportSelectionPanelComboBox.FormattingEnabled = true;
            this.reportSelectionPanelComboBox.Location = new System.Drawing.Point(3, 6);
            this.reportSelectionPanelComboBox.Name = "reportSelectionPanelComboBox";
            this.reportSelectionPanelComboBox.Size = new System.Drawing.Size(292, 21);
            this.reportSelectionPanelComboBox.TabIndex = 5;
            // 
            // sqlReportDGVPanel
            // 
            this.sqlReportDGVPanel.AllowDrop = true;
            this.sqlReportDGVPanel.AllowUserToAddRows = false;
            this.sqlReportDGVPanel.AllowUserToDeleteRows = false;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.sqlReportDGVPanel.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle2;
            this.sqlReportDGVPanel.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.sqlReportDGVPanel.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.sqlReportDGVPanel.EditMode = System.Windows.Forms.DataGridViewEditMode.EditProgrammatically;
            this.sqlReportDGVPanel.Location = new System.Drawing.Point(3, 33);
            this.sqlReportDGVPanel.Name = "sqlReportDGVPanel";
            this.sqlReportDGVPanel.Size = new System.Drawing.Size(521, 410);
            this.sqlReportDGVPanel.TabIndex = 4;
            this.sqlReportDGVPanel.BindingContextChanged += new System.EventHandler(this.sqlReportDGVPanel_BindingContextChanged);
            
            // 
            // sqlRptPanelBkrndWrkr
            // 
            this.sqlRptPanelBkrndWrkr.WorkerSupportsCancellation = true;
            this.sqlRptPanelBkrndWrkr.DoWork += new System.ComponentModel.DoWorkEventHandler(this.sqlRptTabBkrndWrkr_DoWork);
            this.sqlRptPanelBkrndWrkr.RunWorkerCompleted += new System.ComponentModel.RunWorkerCompletedEventHandler(this.sqlRptTabBkrndWrkr_RunWorkerCompleted);
            // 
            // dgvColumnContext
            // 
            this.dgvColumnContext.Name = "dgvColumnContext";
            this.dgvColumnContext.Size = new System.Drawing.Size(61, 4);
            
            // 
            // SqlRptPanel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.bkgrndRptSqlProgressPanel);
            this.Controls.Add(this.btnSelectedReportRunPanel);
            this.Controls.Add(this.reportSelectionPanelComboBox);
            this.Controls.Add(this.sqlReportDGVPanel);
            this.Name = "SqlRptPanel";
            this.Size = new System.Drawing.Size(527, 446);
            this.Load += new System.EventHandler(this.SqlRptPanel_Load);
            ((System.ComponentModel.ISupportInitialize)(this.sqlReportDGVPanel)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ProgressBar bkgrndRptSqlProgressPanel;
        private System.Windows.Forms.Button btnSelectedReportRunPanel;
        private System.Windows.Forms.ComboBox reportSelectionPanelComboBox;
        private System.Windows.Forms.DataGridView sqlReportDGVPanel;
        private System.ComponentModel.BackgroundWorker sqlRptPanelBkrndWrkr;
        private System.Windows.Forms.ContextMenuStrip dgvColumnContext;
    }
}
