using System;

namespace Spedmon
{
    public class UserAllDepartmentServicesReview : WebUI
    {
        public UserAllDepartmentServicesReview() : base( PractitionerDepartmentServicesReview.BODY_ID
                                                  , PractitionerDepartmentServicesReview.SEL_LABEL
                                                  , ""
                                                  , ""
                                                  , Constants.ROLE_PRAC_DIR_SUP_ADMINS)
        { 
	
  	    }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
