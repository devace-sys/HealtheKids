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
 * svcnotesave */
/**
 * Service note
 ***************************************************************************/

namespace Spedmon
{
  public class svcnotesave : WebUiJqm
  {

    public svcnotesave() : base("Service Note",Constants.ROLE_ALL){}

    public ServiceNoteRequest req;

    protected void Page_Load (object sender, EventArgs e)
    {
      
    }    
  }
}
