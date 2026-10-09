using System;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;


namespace Spedmon
{
    /***************************************************************************
     * UserAllManageRmtsActivityCodeChangeReasons */
    /**
     *
     ***************************************************************************/


    public class UserAllManageRmtsActivityCodeChangeReasons : WebUI

    {

        public UserAllManageRmtsActivityCodeChangeReasons() : base(Util.createUniqueID()
                                                , RMTSActivityCodeChangeReasons.SEL_LABEL_MANAGE
                                                , @"user_all_manage_rmts_activity_code_change_reasons.css"
                                                , @""
                                                , Constants.ROLE_SBS_ALL)
        { }

        protected void Page_Load(object sender, EventArgs e)
        {

        }

    }
}