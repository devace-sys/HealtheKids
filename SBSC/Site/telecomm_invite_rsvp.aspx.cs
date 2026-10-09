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

  public class telecommInviteRsvp : MBA.WebUITeleCommRSVPBase
  {
    public telecommInviteRsvp() : base( Constants.APP_NAME, "RSVP") {

    }
    

    /***************************************************************************
     * Page_Load */
    /**
     ***************************************************************************/   
    protected new void Page_Load (object sender, EventArgs e)
    {
      base.Page_Load(sender, e);
    }

  }
}