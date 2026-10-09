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
 * client_prov_svc_notes_save */
/**
 * Service notes view 
 ***************************************************************************/

namespace Spedmon
{
  public class client_prov_svc_notes_save : WebUiJqm
  {

    public client_prov_svc_notes_save () : base("Service Notes",Constants.ROLE_ALL_PCAL_AND_CLIENT){}

    public ServiceNotesSaveRequest req;
    
    protected void Page_Load (object sender, EventArgs e)
    {
      req = new ServiceNotesSaveRequest();
      
      req.process(dbConnApp, log, uInfo, Request.Params);
           
      if (req.needToRedirect)
      {
        Response.Redirect(req.newURL, false);
        Context.ApplicationInstance.CompleteRequest();
      }      
    }
  }
}
