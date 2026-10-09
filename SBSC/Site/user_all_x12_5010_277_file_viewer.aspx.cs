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
   * UserAllX125010277FileViewer */
  /**
   * 
   ***************************************************************************/


  public class UserAllX125010277FileViewer : WebUI

  {

    public UserAllX125010277FileViewer() : base(  Util.createUniqueID()
                                              , @"X12 5010 277 File Viewer"
                                              , @""
                                              , @"components/js-mba-x12-common.js"
										      , Constants.ROLE_SBS_ALL) { }
    
    
    protected void Page_Load(object sender, EventArgs e)
    {      
    }
  }
}
