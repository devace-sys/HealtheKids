using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Spedmon
{
    public partial class user_all_tele_iep_manage : WebUI
    {
        public bool showActive = true;
        public bool hasCarePlanAccess;

        public user_all_tele_iep_manage() : base("user_all_tele_iep_manage"
                                                           , TeleCommIEPTypes.SEL_LABEL_MANAGE_IEP
                                                           , @""
                                                           , @"tele-iep-sessions.js"
                                                           , Constants.ROLE_ADMIN_CONSULTANT_LEA_BO_PRAC)
        { }
        
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        /*
        public ReturnSaveRecord deleteinline(string recid)
        {
            return Spedmon.TeleIEPSessions.delete(this.dbConnApp
                                                  , this.log
                                                  , this.uInfo
                                                  , ""
                                                  , "0"
                                                  , recid);
        }
        */
    }
}
