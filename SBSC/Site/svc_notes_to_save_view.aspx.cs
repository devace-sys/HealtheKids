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
 * svc_notes_to_save_view */
/**
 * Service notes view 
 ***************************************************************************/

namespace Spedmon
{
  public class svc_notes_to_save_view : WebUiJqm
  {

    public svc_notes_to_save_view() : base("Service Notes",Constants.ROLE_ALL){}

    public ServiceNotesToSaveListRequest req;
    
    protected void Page_Load (object sender, EventArgs e)
    {
      req = new ServiceNotesToSaveListRequest();
      req.process(dbConnApp, log, uInfo, Request.Params);
           
      if (req.needToRedirect)
      {
        Response.Redirect(req.newURL, false);
        Context.ApplicationInstance.CompleteRequest();
      }      
    }
  }
}
