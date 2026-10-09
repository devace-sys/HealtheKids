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
    /***************************************************************************
     * UserAllUserSave */
    /**
     ***************************************************************************/

    public class UserAllUserSave : WebUI
    {

        public UserAllUserSave() : base(  @"user_all_user_save"
                                         , "User Save"
                                         , @""
                                         , @""
                                         , Constants.ROLE_SBS_ADMIN)
        { 
		}

        protected void Page_Load(object sender, EventArgs e)
        {
            
            var ctrlSelectSelpa   = findControlRecu(this.Page, "selectSELPA")        as MBA.DataEntryRowSelectSELPA;
            var ctrlSelectClient  = findControlRecu(this.Page, "selectClient")       as MBA.DataEntryRowSelectClient;
            var ctrlSelectPrac    = findControlRecu(this.Page, "selectPractitioner") as MBA.DataEntryRowSelectPractitioner;
          
            ctrlSelectSelpa.entryInitiallyHidden  = true;
            ctrlSelectClient.entryInitiallyHidden = true;
            ctrlSelectPrac.entryInitiallyHidden   = true;
            
        }
    }
}