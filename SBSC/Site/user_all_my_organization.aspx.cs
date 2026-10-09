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
   * UserAllMyOrganization */
  /**
   * 
   ***************************************************************************/


  public class UserAllMyOrganization : WebUI

  {

    public UserAllMyOrganization() : base (   Util.createUniqueID()
                                            , Clients.SEL_LABEL_MY_ORGANIZATION
                                            , @""
                                            , @"client-school-session-academic-years.js|client-school-session-breaks.js"
										    , Constants.ROLE_SCHOOL_SESSIONS_ACADEMIC_YEARS_MANAGE) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {
            var ctrlClientID   = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
            string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);

            if (!String.IsNullOrEmpty(clientIDStr)) { 
                var _clt = Clients.load(dbConnApp,log,uInfo,clientIDStr);
                ctrlClientID.selectName  = _clt.name;
                ctrlClientID.selectValue = clientIDStr;
            }
    }
  
  }
}
