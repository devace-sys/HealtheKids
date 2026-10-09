using System;

namespace Spedmon
{
    public class UserAllPracEfficiencyRpt : WebUI
    {

        public UserAllPracEfficiencyRpt() : base(  PractitionersEfficiency.BODY_ID
                                                 , PractitionersEfficiency.SEL_LABEL
                                                 , ""
                                                 , ""
                                                 , Constants.ROLE_PRAC_DIR_SUP_ADMINS)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {
        }

    }
}
