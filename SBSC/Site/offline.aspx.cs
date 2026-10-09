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

/***************************************************************************
* OfflineMsg */
/**
* Offline Message Page
***************************************************************************/

namespace Spedmon
{   
  public class OfflineMsg : WebMsg
  {    
    public string OfflineNotice = @"";    

    public OfflineMsg()
    {
      this._msg = @"SpEdCare is Currently Offline";
      this.OfflineNotice = Constants.APP_NOTICE;
      if (Util.IsNullOrEmpty(this.OfflineNotice)) this.OfflineNotice = @"Please try your request later";
    }    
  }
}
