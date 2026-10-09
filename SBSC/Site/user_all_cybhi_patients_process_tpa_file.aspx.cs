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
   * UserAllCybhiPatientsProcessTpaFile */
  /**
   * 
   ***************************************************************************/


  public class UserAllCybhiPatientsProcessTpaFile : WebUI

  {

    public UserAllCybhiPatientsProcessTpaFile() : base(  Util.createUniqueID()
                                              , @"Process CYBHI TPA Batch Registration File"
                                              , @""
                                              , @""
										      , Constants.ROLE_SBS_ALL) { }

    public string urlEditPatInfo = @"";
 
    protected void Page_Load(object sender, EventArgs e)
    {
      

      var ctrlClientID   = findControlRecu (this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
      string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
      
      /* preselect clientid if passed */


      if (!String.IsNullOrEmpty(clientIDStr))
      {
        var _clt = Clients.load(dbConnApp,log,uInfo,clientIDStr);
        ctrlClientID.selectName  = _clt.name;
        ctrlClientID.selectValue = clientIDStr;
      }

      urlEditPatInfo = MBA.HttpApplication.createLink(Patients.URL_USER_ALL_SAVE
                                            , true
                                            , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                            , new NameValue(Constants.PARM_REC_ID, @""));
    }
  }
}
