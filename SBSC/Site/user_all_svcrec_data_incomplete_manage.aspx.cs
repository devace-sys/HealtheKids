using System;
using MBA;

namespace Spedmon
{
    public class userAllSvcrecDataIncompleteManage : WebUI
    {
        public userAllSvcrecDataIncompleteManage() : base("user_all_svcrec_data_incomplete_manage"
                                                         , ServiceRecordsDataIncomplete.SEL_LABEL_MANAGE
                                                         , "user_all_svcrec_data_incomplete_manage.css"
                                                         , ""
                                                         , Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST)
        { }

        public bool isPcalStaff = false;

        protected void Page_Load(object sender, EventArgs e)
        {

            /* determine if user is pcal staff */

            if (uInfo.pcalStaff)
            {
                isPcalStaff = true;
            }

        }
    }
}