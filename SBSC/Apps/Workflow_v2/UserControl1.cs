using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using MBA;
using Spedmon;
using System.Data.SqlClient;

namespace Workflow_v2
{
    public partial class UserControl1 : UserControl
    {
        public DetailsLog ctrlDetailsLog;
        public UserInfo ctrlUserInfo;

        public UserControl1()
        {
            InitializeComponent();
            ctrlDetailsLog = new DetailsLog();
            ctrlUserInfo = new UserInfo();
        }
    }
}
