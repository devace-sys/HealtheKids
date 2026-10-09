
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


  public class UserAllRmtsHealthdashStats : WebUI

  {

    public string clientIDStr;

    public string ispreview;  //

    public bool isPcalStaff;

    public UserAllRmtsHealthdashStats() : base(  Util.createUniqueID()   // why????
                                              , "RMTS 2A Stats Dashboard"
                                              , @"user_all_rmts_healthdash_stats.css"
                                              , @""
										      , Constants.ROLE_ALL_PCAL_AND_CLIENT
    ) { }
    

    protected void Page_Load(object sender, EventArgs e)
    {

      isPcalStaff = this.uInfo.pcalStaff;

      var ctrlClientID   = findControlRecu (this.Page, "selectClient") as MBA.DataEntryRowSelectClient;        //
      clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
      
      /* preselect clientid if passed */

      if (!String.IsNullOrEmpty(clientIDStr))
      {
        var _clt = Clients.load(dbConnApp,log,uInfo,clientIDStr);
        ctrlClientID.selectName  = _clt.name;
        ctrlClientID.selectValue = clientIDStr;

        ctrlClientID.Visible = false;
      }

      ispreview = MBA.HttpApplication.getParameter( "ispreview" );

      //Validate.reqClientID(


    }
  }
}
