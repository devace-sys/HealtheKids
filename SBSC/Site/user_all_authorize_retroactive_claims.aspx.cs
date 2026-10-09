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
using System.Text;
using MBA;
using System.Collections.Generic;

namespace Spedmon
{

    public class UserAllAuthorizeRetroactiveClaims : WebUI
    {
        public UserAllAuthorizeRetroactiveClaims() : base(@"user_all_authorize_retroactive_claims"
                                                         , ClaimsRetroactiveForSpa.SEL_LABEL_AUTHORIZATION
                                                         , @"user_all_authorize_retroactive_claims.css"
                                                         , @"user_all_authorize_retroactive_claims.js"
                                                         , Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD)
        {
        }

        protected void Page_Load(object sender, EventArgs e)
        {
          
          var ctrlAuthYesNoUnknown = findControlRecu (this.Page, "authynu") as MBA.RadioBox;

          ctrlAuthYesNoUnknown.value = "?"; /* Default */

          ctrlAuthYesNoUnknown.AddSelection(@"Review",   "?");
          ctrlAuthYesNoUnknown.AddSelection(@"Deferred", "N");
          ctrlAuthYesNoUnknown.AddSelection(@"Released", "Y");

        }
    }
}