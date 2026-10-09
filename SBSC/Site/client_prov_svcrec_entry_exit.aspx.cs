using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Spedmon;
using MBA;

/***************************************************************************
 * client_prov_svcrec_entry_exit */
/**
 * Service notes entry and exit point
 ***************************************************************************/

namespace Spedmon
{
  
  public class client_prov_svcrec_entry_exit : WebUiJqm
  {

    public client_prov_svcrec_entry_exit() : base("Service Records", Constants.ROLE_LEA_PROVIDER) { }

    public ServiceRecordEntryExitRequest req = new ServiceRecordEntryExitRequest();
    
    protected void Page_Load (object sender, EventArgs e)
    {

      req = ServiceRecordEntryExitRequest.process(dbConnApp, log, uInfo, Request.Params);
      
      if (req.needToRedirect) 
      {
        Response.Redirect(req.newURL,false);
        Context.ApplicationInstance.CompleteRequest();
      }
                 
    }  
  }
}
