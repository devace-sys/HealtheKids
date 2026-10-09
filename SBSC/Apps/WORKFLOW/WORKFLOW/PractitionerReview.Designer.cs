namespace WORKFLOW
{
    partial class PractitionerReview
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
            this.tittlelabel = new System.Windows.Forms.Label();
            this.closebutton = new System.Windows.Forms.Button();
            this.addbutton = new System.Windows.Forms.Button();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.Edit = new System.Windows.Forms.DataGridViewButtonColumn();
            this.Delete = new System.Windows.Forms.DataGridViewButtonColumn();
            this.praccomboBox = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.ctgcomboBox = new System.Windows.Forms.ComboBox();
            this.revtextBox = new System.Windows.Forms.TextBox();
            this.label4 = new System.Windows.Forms.Label();
            this.cancelbutton = new System.Windows.Forms.Button();
            this.openFilebutton = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // tittlelabel
            // 
            this.tittlelabel.AutoSize = true;
            this.tittlelabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tittlelabel.Location = new System.Drawing.Point(175, 26);
            this.tittlelabel.Name = "tittlelabel";
            this.tittlelabel.Size = new System.Drawing.Size(172, 20);
            this.tittlelabel.TabIndex = 0;
            this.tittlelabel.Text = "Practitioner Reviews";
            // 
            // closebutton
            // 
            this.closebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.closebutton.Location = new System.Drawing.Point(940, 399);
            this.closebutton.Name = "closebutton";
            this.closebutton.Size = new System.Drawing.Size(75, 23);
            this.closebutton.TabIndex = 10;
            this.closebutton.Text = "Close";
            this.closebutton.UseVisualStyleBackColor = true;
            this.closebutton.Click += new System.EventHandler(this.closebutton_Click);
            // 
            // addbutton
            // 
            this.addbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.addbutton.Location = new System.Drawing.Point(846, 106);
            this.addbutton.Name = "addbutton";
            this.addbutton.Size = new System.Drawing.Size(115, 23);
            this.addbutton.TabIndex = 13;
            this.addbutton.Text = "Add/Edit Review";
            this.addbutton.UseVisualStyleBackColor = true;
            this.addbutton.Click += new System.EventHandler(this.addbutton_Click);
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
            this.dataGridView1.Location = new System.Drawing.Point(5, 181);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.ReadOnly = true;
            this.dataGridView1.RowHeadersVisible = false;
            this.dataGridView1.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridView1.Size = new System.Drawing.Size(1035, 199);
            this.dataGridView1.TabIndex = 14;
            this.dataGridView1.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellContentClick);
            // 
            // Edit
            // 
            this.Edit.HeaderText = "Edit";
            this.Edit.Name = "Edit";
            this.Edit.ReadOnly = true;
            this.Edit.Text = "Edit";
            this.Edit.UseColumnTextForButtonValue = true;
            this.Edit.Width = 31;
            // 
            // Delete
            // 
            this.Delete.HeaderText = "Delete";
            this.Delete.Name = "Delete";
            this.Delete.ReadOnly = true;
            this.Delete.Text = "Delete";
            this.Delete.UseColumnTextForButtonValue = true;
            this.Delete.Width = 44;
            // 
            // praccomboBox
            // 
            this.praccomboBox.FormattingEnabled = true;
            this.praccomboBox.Location = new System.Drawing.Point(179, 75);
            this.praccomboBox.Name = "praccomboBox";
            this.praccomboBox.Size = new System.Drawing.Size(260, 21);
            this.praccomboBox.TabIndex = 15;
            this.praccomboBox.SelectedIndexChanged += new System.EventHandler(this.praccomboBox_SelectedIndexChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(86, 80);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(87, 16);
            this.label2.TabIndex = 16;
            this.label2.Text = "Practitioner";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(482, 80);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(71, 16);
            this.label3.TabIndex = 18;
            this.label3.Text = "Category";
            // 
            // ctgcomboBox
            // 
            this.ctgcomboBox.FormattingEnabled = true;
            this.ctgcomboBox.Location = new System.Drawing.Point(559, 75);
            this.ctgcomboBox.Name = "ctgcomboBox";
            this.ctgcomboBox.Size = new System.Drawing.Size(243, 21);
            this.ctgcomboBox.TabIndex = 17;
            this.ctgcomboBox.SelectedIndexChanged += new System.EventHandler(this.ctgcomboBox_SelectedIndexChanged);
            // 
            // revtextBox
            // 
            this.revtextBox.Location = new System.Drawing.Point(179, 109);
            this.revtextBox.Multiline = true;
            this.revtextBox.Name = "revtextBox";
            this.revtextBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.revtextBox.Size = new System.Drawing.Size(623, 53);
            this.revtextBox.TabIndex = 19;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(114, 109);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(59, 16);
            this.label4.TabIndex = 20;
            this.label4.Text = "Review";
            // 
            // cancelbutton
            // 
            this.cancelbutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cancelbutton.Location = new System.Drawing.Point(938, 139);
            this.cancelbutton.Name = "cancelbutton";
            this.cancelbutton.Size = new System.Drawing.Size(75, 23);
            this.cancelbutton.TabIndex = 21;
            this.cancelbutton.Text = "Clear";
            this.cancelbutton.UseVisualStyleBackColor = true;
            this.cancelbutton.Click += new System.EventHandler(this.cancelbutton_Click);
            // 
            // openFilebutton
            // 
            this.openFilebutton.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.openFilebutton.Location = new System.Drawing.Point(846, 139);
            this.openFilebutton.Name = "openFilebutton";
            this.openFilebutton.Size = new System.Drawing.Size(75, 23);
            this.openFilebutton.TabIndex = 22;
            this.openFilebutton.Text = "Open File";
            this.openFilebutton.UseVisualStyleBackColor = true;
            this.openFilebutton.Click += new System.EventHandler(this.openFilebutton_Click);
            // 
            // PractitionerReview
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1044, 444);
            this.ControlBox = false;
            this.Controls.Add(this.openFilebutton);
            this.Controls.Add(this.cancelbutton);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.revtextBox);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.ctgcomboBox);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.praccomboBox);
            this.Controls.Add(this.dataGridView1);
            this.Controls.Add(this.addbutton);
            this.Controls.Add(this.closebutton);
            this.Controls.Add(this.tittlelabel);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "PractitionerReview";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "PractitionerReview";
            this.Load += new System.EventHandler(this.PractitionerReview_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label tittlelabel;
        private System.Windows.Forms.Button closebutton;
        private System.Windows.Forms.Button addbutton;
        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.ComboBox praccomboBox;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox ctgcomboBox;
        private System.Windows.Forms.TextBox revtextBox;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.DataGridViewButtonColumn Edit;
        private System.Windows.Forms.DataGridViewButtonColumn Delete;
        private System.Windows.Forms.Button cancelbutton;
        private System.Windows.Forms.Button openFilebutton;
    }
}