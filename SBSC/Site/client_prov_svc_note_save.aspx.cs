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
 * client_prov_svc_note_save */
/**
 * Service note
 ***************************************************************************/

namespace Spedmon
{
  public class client_prov_svc_note_save : WebUiJqm
  {

    public client_prov_svc_note_save() : base("Service Note",Constants.ROLE_LEA_PROVIDER){}

    public ServiceNoteRequest req;

    protected void Page_Load (object sender, EventArgs e)
    {
      
      req = ServiceNoteRequests.process (dbConnApp, log, uInfo, Request.Params, Request.Files);
      
      if (req.needToRedirect)
      {
        Response.Redirect(req.newURL, false);
        Context.ApplicationInstance.CompleteRequest();
      }
    }    
  }
}
