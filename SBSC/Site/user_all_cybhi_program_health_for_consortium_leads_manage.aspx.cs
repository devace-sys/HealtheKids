using System;
using System.Collections;
using MBA;

namespace Spedmon
{
    public class UserAllCYBHIProgramHealthForConsortiumLeadsManage : WebUI
    {
        public UserAllCYBHIProgramHealthForConsortiumLeadsManage() : base(
                                              @"user_all_cybhi_program_health_for_consortium_leads_manage"
                                            , CYBHIConsortiumMembers.SEL_LABEL_MANAGE
                                            , ""
                                            , ""
                                            , Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD_CYBHI_COORD)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {     

        }
    }
}