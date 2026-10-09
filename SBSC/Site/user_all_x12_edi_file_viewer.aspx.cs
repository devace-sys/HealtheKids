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
   * UserAllX12EdiFileViewer */
  /**
   * 
   ***************************************************************************/


  public class UserAllX12EdiFileViewer : WebUI

  {

    public UserAllX12EdiFileViewer() : base(  Util.createUniqueID()
                                              , @"X12 EDI File Viewer"
                                              , @""
                                              , @"components/js-mba-x12-common.js"
										      , Constants.ROLE_SBS_ALL) { }
    
    
    protected void Page_Load(object sender, EventArgs e)
    {      
    }
  }
}
