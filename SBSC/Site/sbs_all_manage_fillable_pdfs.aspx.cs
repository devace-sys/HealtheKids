using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;
using MBA;
using System.Collections.Generic;

namespace Spedmon
{

    public class SBSAllManageFillablePdfs : WebUI
    {
        public SBSAllManageFillablePdfs() : base( @"sbs_all_manage_fillable_pdfs"
                                                  , "Manage"
                                                  , @""
                                                  , @""
                                                  , Constants.ROLE_ANNOUNCEMENT_ADMIN)
        {
        }
        
        protected void Page_Load(object sender, EventArgs e)
        {
        
        }
    }
}