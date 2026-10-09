using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace SBSCParentTemplate
{
    public partial class form1 : Form
    {
        public form1()
        {
            InitializeComponent();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            DialogResult d = new DialogResult();
            d = MessageBox.Show("Are you sure you want to exit the application", "Exit", MessageBoxButtons.YesNo);
            if (d == DialogResult.Yes)
                e.Cancel = false;
            else
                e.Cancel = true;
        }

        private void form1_Load(object sender, EventArgs e)
        {
            label2.Text = "Hello " + Environment.UserName;
        }
    }
}
