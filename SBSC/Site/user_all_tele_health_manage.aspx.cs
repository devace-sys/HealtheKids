using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Spedmon
{
    public class user_all_tele_health_manage : WebUI
    {
        public user_all_tele_health_manage() : base("user_all_tele_health_manage"
                                                                        , WebUI.CreatePageSubTitle(TeleHealthSessions.SEL_LABEL)
                                                                        , @""
                                                                        , @""
                                                                        , Constants.ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC)
        { }

        protected void Page_Load(object sender, EventArgs e)
        {

        }
        /*
        public ReturnSaveRecord deleteinline(string recid)
        {
            return Spedmon.TeleHealthSessions.delete(this.dbConnApp
                                                  , this.log
                                                  , this.uInfo
                                                  , ""
                                                  , "0"
                                                  , recid);
        }
        */
    }
}