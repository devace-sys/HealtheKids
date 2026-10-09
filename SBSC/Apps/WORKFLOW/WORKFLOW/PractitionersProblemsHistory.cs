using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Data.SqlClient;
using MBA;

namespace WORKFLOW
{
   /***************************************************************************
    * Practitioner Problem History */
    /**
    **************************************************************************/
    public partial class PractitionersProblemsHistory : System.Windows.Forms.Form
    {
        public PractitionersProblemsHistory()
        {
            InitializeComponent();
        }

        private static PractitionersProblemsHistory m_SChildform1;
       /***************************************************************************
        * if not created yet or disposed, Create an instance
        * if just created or created earlier.Return it
        ***************************************************************************/
        public static PractitionersProblemsHistory GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new PractitionersProblemsHistory();
            return m_SChildform1;
        }

        private string sql;
        private bool loaded = false;
        private List<SqlParameter> parms = new List<SqlParameter>();

        private void PractitionersProblemsHistory_Load(object sender, EventArgs e)
        {
            sql = "select id,name from CLIENTS_VIEW(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null) order by name";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql,null, clientcomboBox, "Clients", "name", "id", false, "");

            sql = "select id,CATEGORY_NAME as name from STAMP_CATEGORIES";
            WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql,null, ctgrycomboBox, "Categories", "name", "id", true, "");
            loaded = true;
            if (loaded) clientcomboBox_SelectedIndexChanged(sender, e);
        }

       /***************************************************************************
        * Refreshes the datagrid and restores the sort order and selected rows.
        ***************************************************************************/
        private void viewbutton_Click(object sender, EventArgs e)
        {

             WinFormsCommon.loadDataGrid(ref dataGridView1, 5, 8,
                                         delegate{return WORKFLOW.InputBatches.Practitioners_Problems_VIEW(SBSCParent.connSpedmon,
                                                  WinFormsCommon.IsNull(clientcomboBox.SelectedValue),
                                                  WinFormsCommon.IsNull(praccomboBox.SelectedValue),"",
                                                  FileStatus.QuestionFormToAnI.ToString(),
                                                  WinFormsCommon.IsNull(ctgrycomboBox.SelectedValue),"1"
                                                 );
            });

        }

       /***************************************************************************
        * clears the selections
        ***************************************************************************/
        private void clearbutton_Click(object sender, EventArgs e)
        {
            praccomboBox.SelectedIndex  = 0;
            ctgrycomboBox.SelectedIndex = 0;
            viewbutton_Click(sender, e);
        }


       /***************************************************************************
        * updates the practitioner drop down list when the client selection changes
        ***************************************************************************/
        private void clientcomboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (loaded)
            {
                sql = "select id,name from dbo.PRACTITONERS_VIEW (null, null, null, 0, null, @clientID, null, null, null, null, null, null, 1, null,null)";
                parms.Clear();
                object vClientID = MBA.Validate.optInteger(clientcomboBox.SelectedValue.ToString(), "", true);
                parms.Add(MBA.Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
                WinFormsCommon.PopulateComboBox(SBSCParent.connSpedmon, sql,parms, praccomboBox, "Practitioners", "name", "id", true, "");
                viewbutton_Click(sender, e);
            }
        }

        private void closebutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

      /***************************************************************************
       * refreshes the datagridview when the form is activated
       ***************************************************************************/
        private void PractitionersProblemsHistory_Activated(object sender, EventArgs e)
        {
            viewbutton_Click(sender, e);
        }

    }
}
