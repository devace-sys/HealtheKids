using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;

namespace MBA
{
    /**************************************************************************
     * DataEntryBoxText */
    /**
     * 
     **************************************************************************/

    public class DataEntryBoxText : DataEntryBoxBase
    {
        public DataEntryBoxText() : base("text") { }
        protected override void Render(HtmlTextWriter writer)
        {
           base.Render(writer);
        }
    }
}
