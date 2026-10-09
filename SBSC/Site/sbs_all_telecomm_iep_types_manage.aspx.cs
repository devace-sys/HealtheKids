using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MBA;

namespace Spedmon
{
    public class TelecommIEPTypesManage : WebUI
    {
        public TelecommIEPTypesManage() : base("telecomm_iep_types_manage"
                                                     , TeleCommIEPTypes.SEL_LABEL_MANAGE
                                                     , ""
                                                     , ""
                                                     , Constants.ROLE_SBS_ALL)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {

        }
    }
}