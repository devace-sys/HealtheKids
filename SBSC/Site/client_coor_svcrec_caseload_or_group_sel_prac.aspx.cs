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
     * ClientCoorServiceRecordCaseloadOrGroupSelPrac */
    /**
     * Saves a service record
     ***************************************************************************/

    public class ClientCoorServiceRecordCaseloadOrGroupSelPrac: WebUI
    {
      public int saveType = Constants.SAVE_TYPE_NEW;

      public ClientCoorServiceRecordCaseloadOrGroupSelPrac() : base("",ServiceRecords.SEL_LABEL_SVREC_NON_PRAC, "", "", Constants.ROLE_CLIENT_BO) { }

      public string clientID = "";
      public string urlProceed = @"";
      
      protected void Page_Load(object sender, EventArgs e)
      {
          /* If user is logged in get client and prac id */

          if (rd.loggedIn)
          {
              clientID = Spedmon.Validate.optClientID(uInfo, "").ToString();

              urlProceed = MBA.HttpApplication.createLink(ServiceRecords.URL_CLIENT_COOR_SVCREC_CSLD_OR_GRP_SAVE, true)
                         + "&clientID="
                         + clientID;

          }
      
      }
    }
}