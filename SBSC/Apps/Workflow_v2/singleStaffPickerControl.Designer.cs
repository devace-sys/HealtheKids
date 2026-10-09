namespace Workflow_v2
{
    partial class singleStaffPickerPanel
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
            this.btnDBRefresh = new System.Windows.Forms.Button();
            this.btnGetNewBatch = new System.Windows.Forms.Button();
            this.testUserIDDebugField = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.btnOpenFile = new System.Windows.Forms.Button();
            this.btnCopyReference = new System.Windows.Forms.Button();
            this.currentBatchNameLabel = new System.Windows.Forms.Label();
            this.doneWithBatchBtn = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // btnDBRefresh
            // 
            this.btnDBRefresh.Location = new System.Drawing.Point(11, 206);
            this.btnDBRefresh.Name = "btnDBRefresh";
            this.btnDBRefresh.Size = new System.Drawing.Size(194, 50);
            this.btnDBRefresh.TabIndex = 1;
            this.btnDBRefresh.Text = "Refresh Screen";
            this.btnDBRefresh.UseVisualStyleBackColor = true;
            this.btnDBRefresh.Click += new System.EventHandler(this.btnDBRefresh_Click);
            // 
            // btnGetNewBatch
            // 
            this.btnGetNewBatch.Location = new System.Drawing.Point(11, 153);
            this.btnGetNewBatch.Name = "btnGetNewBatch";
            this.btnGetNewBatch.Size = new System.Drawing.Size(194, 47);
            this.btnGetNewBatch.TabIndex = 2;
            this.btnGetNewBatch.Text = "I need more work!";
            this.btnGetNewBatch.UseVisualStyleBackColor = true;
            this.btnGetNewBatch.Click += new System.EventHandler(this.btnGetNewBatch_Click);
            // 
            // testUserIDDebugField
            // 
            this.testUserIDDebugField.Location = new System.Drawing.Point(4, 4);
            this.testUserIDDebugField.Name = "testUserIDDebugField";
            this.testUserIDDebugField.Size = new System.Drawing.Size(164, 20);
            this.testUserIDDebugField.TabIndex = 5;
            this.testUserIDDebugField.Text = "DEBUG ONLY - USER ID FIELD";
            this.testUserIDDebugField.TextChanged += new System.EventHandler(this.testUserIDDebugField_TextChanged);
            // 
            // label1
            // 
            this.label1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(8, 27);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(160, 13);
            this.label1.TabIndex = 6;
            this.label1.Text = "Your currently assigned batch is:";
            // 
            // btnOpenFile
            // 
            this.btnOpenFile.Location = new System.Drawing.Point(130, 68);
            this.btnOpenFile.Name = "btnOpenFile";
            this.btnOpenFile.Size = new System.Drawing.Size(75, 23);
            this.btnOpenFile.TabIndex = 9;
            this.btnOpenFile.Text = "Open File";
            this.btnOpenFile.UseVisualStyleBackColor = true;
            this.btnOpenFile.Click += new System.EventHandler(this.btnOpenFile_Click);
            // 
            // btnCopyReference
            // 
            this.btnCopyReference.Location = new System.Drawing.Point(11, 68);
            this.btnCopyReference.Name = "btnCopyReference";
            this.btnCopyReference.Size = new System.Drawing.Size(113, 23);
            this.btnCopyReference.TabIndex = 10;
            this.btnCopyReference.Text = "Copy to Clipboard";
            this.btnCopyReference.UseVisualStyleBackColor = true;
            this.btnCopyReference.Click += new System.EventHandler(this.btnCopyReference_Click);
            // 
            // currentBatchNameLabel
            // 
            this.currentBatchNameLabel.AutoSize = true;
            this.currentBatchNameLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.currentBatchNameLabel.Location = new System.Drawing.Point(6, 40);
            this.currentBatchNameLabel.Name = "currentBatchNameLabel";
            this.currentBatchNameLabel.Size = new System.Drawing.Size(70, 25);
            this.currentBatchNameLabel.TabIndex = 11;
            this.currentBatchNameLabel.Text = "label2";
            this.currentBatchNameLabel.Click += new System.EventHandler(this.currentBatchNameLabel_Click);
            // 
            // doneWithBatchBtn
            // 
            this.doneWithBatchBtn.Location = new System.Drawing.Point(11, 97);
            this.doneWithBatchBtn.Name = "doneWithBatchBtn";
            this.doneWithBatchBtn.Size = new System.Drawing.Size(194, 50);
            this.doneWithBatchBtn.TabIndex = 12;
            this.doneWithBatchBtn.Text = "I\'m done with this batch!";
            this.doneWithBatchBtn.UseVisualStyleBackColor = true;
            this.doneWithBatchBtn.Click += new System.EventHandler(this.doneWithBatchBtn_Click);
            // 
            // singleStaffPickerPanel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.doneWithBatchBtn);
            this.Controls.Add(this.currentBatchNameLabel);
            this.Controls.Add(this.btnCopyReference);
            this.Controls.Add(this.btnOpenFile);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.testUserIDDebugField);
            this.Controls.Add(this.btnGetNewBatch);
            this.Controls.Add(this.btnDBRefresh);
            this.Name = "singleStaffPickerPanel";
            this.Size = new System.Drawing.Size(230, 349);
            this.Load += new System.EventHandler(this.singleStaffPickerPanel_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnDBRefresh;
        private System.Windows.Forms.Button btnGetNewBatch;
        private System.Windows.Forms.TextBox testUserIDDebugField;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnOpenFile;
        private System.Windows.Forms.Button btnCopyReference;
        private System.Windows.Forms.Label currentBatchNameLabel;
        private System.Windows.Forms.Button doneWithBatchBtn;
    }
}
