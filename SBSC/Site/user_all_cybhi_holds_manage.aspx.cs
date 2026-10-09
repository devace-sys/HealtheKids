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
using MBA;

namespace Spedmon
{
    public class UserAllCybhiHoldsManage : WebUI
    {
        public UserAllCybhiHoldsManage()
            : base (   Spedmon.CYBHIHoldsManageCommon.BODY_ID_MANAGE_HOLDS
                     , Spedmon.CYBHIHoldsManageCommon.SEL_MANAGE_HOLDS
                     , "user_all_cybhi_holds_manage.css"
                     , "patient-persons.js"
                     , Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD )
        { }

        protected void Page_Load(object sender, EventArgs e)
        {
           
        }
    }
}
