namespace WORKFLOW
{
    partial class TrainedStaffView
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.trainedStaffdataGridView = new System.Windows.Forms.DataGridView();
            this.closebutton = new System.Windows.Forms.Button();
            this.workTypecomboBox = new System.Windows.Forms.ComboBox();
            this.staffcomboBox = new System.Windows.Forms.ComboBox();
            this.clearbutton = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.viewbutton = new System.Windows.Forms.Button();
            this.detailbutton = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.trainedStaffdataGridView)).BeginInit();
            this.SuspendLayout();
            // 
            // trainedStaffdataGridView
            // 
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.Silver;
            this.trainedStaffdataGridView.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle2;
            this.trainedStaffdataGridView.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.trainedStaffdataGridView.BackgroundColor = System.Drawing.SystemColors.Control;
            this.trainedStaffdataGridView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.trainedStaffdataGridView.Location = new System.Drawing.Point(98, 156);
            this.trainedStaffdataGridView.Name = "trainedStaffdataGridView";
            this.trainedStaffdataGridView.ReadOnly = true;
            this.trainedStaffdataGridView.Size = new System.Drawing.Size(870, 363);
            this.trainedStaffdataGridView.TabIndex = 2;
            // 
            // closebutton
            // 
            this.closebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.closebutton.Location = new System.Drawing.Point(875, 547);
            this.closebutton.Name = "closebutton";
            this.closebutton.Size = new System.Drawing.Size(93, 23);
            this.closebutton.TabIndex = 3;
            this.closebutton.Text = "Close";
            this.closebutton.UseVisualStyleBackColor = true;
            this.closebutton.Click += new System.EventHandler(this.closebutton_Click);
            // 
            // workTypecomboBox
            // 
            this.workTypecomboBox.FormattingEnabled = true;
            this.workTypecomboBox.Location = new System.Drawing.Point(100, 90);
            this.workTypecomboBox.Name = "workTypecomboBox";
            this.workTypecomboBox.Size = new System.Drawing.Size(227, 24);
            this.workTypecomboBox.TabIndex = 4;
            // 
            // staffcomboBox
            // 
            this.staffcomboBox.FormattingEnabled = true;
            this.staffcomboBox.Location = new System.Drawing.Point(375, 89);
            this.staffcomboBox.Name = "staffcomboBox";
            this.staffcomboBox.Size = new System.Drawing.Size(221, 24);
            this.staffcomboBox.TabIndex = 5;
            // 
            // clearbutton
            // 
            this.clearbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.clearbutton.Location = new System.Drawing.Point(761, 92);
            this.clearbutton.Name = "clearbutton";
            this.clearbutton.Size = new System.Drawing.Size(75, 23);
            this.clearbutton.TabIndex = 6;
            this.clearbutton.Text = "Clear";
            this.clearbutton.UseVisualStyleBackColor = true;
            this.clearbutton.Click += new System.EventHandler(this.clearbutton_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(97, 60);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(78, 16);
            this.label1.TabIndex = 7;
            this.label1.Text = "Work type";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(372, 60);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(39, 16);
            this.label2.TabIndex = 8;
            this.label2.Text = "Staff";
            // 
            // viewbutton
            // 
            this.viewbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.viewbutton.Location = new System.Drawing.Point(660, 91);
            this.viewbutton.Name = "viewbutton";
            this.viewbutton.Size = new System.Drawing.Size(75, 23);
            this.viewbutton.TabIndex = 9;
            this.viewbutton.Text = "View";
            this.viewbutton.UseVisualStyleBackColor = true;
            this.viewbutton.Click += new System.EventHandler(this.viewbutton_Click);
            // 
            // detailbutton
            // 
            this.detailbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.detailbutton.Location = new System.Drawing.Point(865, 90);
            this.detailbutton.Name = "detailbutton";
            this.detailbutton.Size = new System.Drawing.Size(103, 25);
            this.detailbutton.TabIndex = 10;
            this.detailbutton.Text = "View Details";
            this.detailbutton.UseVisualStyleBackColor = true;
            this.detailbutton.Click += new System.EventHandler(this.detailbutton_Click);
            // 
            // TrainedStaffView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1058, 616);
            this.Controls.Add(this.detailbutton);
            this.Controls.Add(this.viewbutton);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.clearbutton);
            this.Controls.Add(this.staffcomboBox);
            this.Controls.Add(this.workTypecomboBox);
            this.Controls.Add(this.closebutton);
            this.Controls.Add(this.trainedStaffdataGridView);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "TrainedStaffView";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Trained Staff View";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.TrainedStaffView_Load);
            this.Activated += new System.EventHandler(this.TrainedStaffView_Activated);
            ((System.ComponentModel.ISupportInitialize)(this.trainedStaffdataGridView)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView trainedStaffdataGridView;
        private System.Windows.Forms.Button closebutton;
        private System.Windows.Forms.ComboBox workTypecomboBox;
        private System.Windows.Forms.ComboBox staffcomboBox;
        private System.Windows.Forms.Button clearbutton;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button viewbutton;
        private System.Windows.Forms.Button detailbutton;
    }
}

